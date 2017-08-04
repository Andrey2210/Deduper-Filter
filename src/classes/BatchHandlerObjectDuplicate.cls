public class BatchHandlerObjectDuplicate implements TriggerHandler.HandlerInterface {

	private static final Integer RECORDS_TO_SHOW = 5;
	private static final String MERGE_PAGE = 'apex/ManualMerging';

	public static final String FILTER_ID_URL = 'filterId';
	public static final String RECORDS_IDS_URL = 'recordsIds';

	public static final String ACTIVITY_LEAD_STATUS = 'Working/Live';
	public static final String ACTIVITY_OPPO_STAGE = 'Review';

	private List<SObject> newObjects { private get; private set; }
	private List<SObject> oldObjects { private get; private set; }
	private List<SObject> exsObjects { private get; private set; }
	private List<SObject> exsObjectsAccessed { private get; private set; }

	private Set<SObject> recordsToUpdate { private get; private set; }
	private Set<SObject> recordsToDelete { private get; private set; }
	private Set<SObject> recordsToInsert { private get; private set; }
	private Set<Task> tasksToInsert { private get; private set; }
	private Map<List<Duplicate__c>, Map<Alert__c, Filter__c>> alertsToInsert { private get; private set; }

	private Set<String> fields { private get; private set; }
	private List<Filter__c> filters { private get; private set; }

	private Boolean isUpdating {
		get {
			return oldObjects == null ? false : oldObjects.isEmpty() ? false : true;
		}
		private set;
	}

	private Deduper_Custom_Settings__c globalSettings { private get; private set; }

	public BatchHandlerObjectDuplicate() {
		this.recordsToUpdate = new Set<SObject>();
		this.recordsToDelete = new Set<SObject>();
		this.recordsToInsert = new Set<SObject>();
		this.tasksToInsert = new Set<Task>();
		this.alertsToInsert = new Map<List<Duplicate__c>, Map<Alert__c, Filter__c>>();
	}

	public BatchHandlerObjectDuplicate(String objectName, List<SObject> oldObjects, List<SObject> newObjects) {
		this();
		this.filters = getObjectFilters(objectName);
		this.oldObjects = oldObjects;
		this.newObjects = newObjects;

		globalSettings = Deduper_Custom_Settings__c.getInstance();
	}

	public BatchHandlerObjectDuplicate(String objectName, List<SObject> oldObjects, SObject newObject) {
		this(objectName, oldObjects, new List<SObject> {newObject});
	}

	/*
	 * Overrides TriggerHandler.HandlerInterface.getFilter()
	 */
	public List<Filter__c> getFilters() {
		return this.filters;
	}

	public void handle() {

		if (!globalSettings.Fire_Auto_Merge__c && !globalSettings.Fire_Triggers__c) {
			return;
		}

		/*
		 * Functionality for not schedulable
		 */
		/*if (this.oldObjects == null) {
			List<SObject> newObjectsToInsert = new List<SObject>();
			for (SObject newObjectToInsert : this.newObjects) {
				newObjectsToInsert.add(newObjectToInsert.clone(false, true));
			}
			this.newObjects = newObjectsToInsert;

			TriggerHandler.isEnabled = false;
			insert this.newObjects;
			TriggerHandler.isEnabled = true;
		}*/

		Set<String> handledTargetObjects = new Set<String>();
		for (Filter__c filter : this.filters) {
			if (!handledTargetObjects.contains(filter.TargetObjectType__c)) {

				if (handleFilter(filter)) {
					handledTargetObjects.add(filter.TargetObjectType__c);
				}

			}
		}

		TriggerHandler.isEnabled = false;
		finishHandling();
		TriggerHandler.isEnabled = true;
	}

	private void finishHandling() {
		try {
			delete new List<SObject>(recordsToDelete);

			for (SObject recordForUpdate : recordsToUpdate) {
				if (recordsToDelete.contains(recordForUpdate)) {
					recordsToUpdate.remove(recordForUpdate);
				}
			}
			update new List<SObject>(recordsToUpdate);

			if (!alertsToInsert.isEmpty()) {
				List<Alert__c> createdAlerts = new List<Alert__c>();
				List<Filter__c> usedFilters = new List<Filter__c>();
				List<List<Duplicate__c>> createdDuplicates = new List<List<Duplicate__c>>();
				for (List<Duplicate__c> duplicatesKey : alertsToInsert.keySet()) {
					createdDuplicates.add(duplicatesKey);
					createdAlerts.add(new List<Alert__c>(alertsToInsert.get(duplicatesKey).keySet()).get(0));
					usedFilters.add(alertsToInsert.get(duplicatesKey).values().get(0));
				}
				insert createdAlerts;

				for (Integer i = 0; i < createdAlerts.size(); i++) {
					createDuplicationTask(null, createdAlerts[i], usedFilters[i]);

					for (Duplicate__c duplicate : createdDuplicates[i]) {
						duplicate.Alert__c = createdAlerts[i].Id;
						recordsToInsert.add(duplicate);
					}
				}
				insert new List<Task>(tasksToInsert);

				insert new List<SObject>(recordsToInsert);

				deleteDuplicatedAlerts(createdAlerts);
			}
			else {
				insert new List<SObject>(recordsToInsert);
			}
	    }
		catch (Exception exc) {
			//but now... silence

			/*
			 * Error message construction
			 */
			//if (recordsToUpdate.size() == 1) {
			//	SObject errorDisplayingObject = new List<SObject>(recordsToUpdate)[0];
			//	String errorMessage = exc.getMessage();

			//	errorMessage += Constants.COLON_SYMBOL;
			//	errorMessage += Constants.HTML_TAG_BR;
			//	errorMessage += String.format(
			//		Constants.HTML_TAG_A,
			//		new List<String>{
			//			(Url.getSalesforceBaseUrl().toExternalForm() + Constants.SLASH_SYMBOL + errorDisplayingObject.get(Constants.FIELD_NAME_FOR_ID) + Constants.EDIT_URL),
			//			(String.valueOf(errorDisplayingObject.get(Constants.FIELD_NAME_FOR_NAME)))
			//		}
			//	);

			//	for (SObject iterObject : newObjects) {
			//		iterObject.addError(errorMessage, false);
			//	}
			//}
			//else {
			//	for (SObject iterObject : newObjects) {
			//		iterObject.addError(exc.getMessage());
			//	}
			//}
		}
	}

	private void deleteDuplicatedAlerts(List<Alert__c> createdAlerts) {
		Set<Id> existingAlertsToDelete = new Set<Id>();
		List<Alert__c> alertsIs = [SELECT Id, Filter__c, (SELECT Id__c FROM Duplicates__r) FROM Alert__c WHERE Id IN :createdAlerts];
		List<Alert__c> alertsWas = [SELECT Id, Filter__c, (SELECT Id__c FROM Duplicates__r) FROM Alert__c WHERE Id NOT IN :createdAlerts];

		for (Alert__c alertIs : alertsIs) {
			Set<Duplicate__c> duplicatesIs = new Set<Duplicate__c>(alertIs.Duplicates__r);
			Set<Id> duplicatesIsIds = new Set<Id>();
			for (Duplicate__c duplicateIs : duplicatesIs) {
				duplicatesIsIds.add(duplicateIs.Id__c);
			}

			for (Alert__c alertWas : alertsWas) {
				Set<Duplicate__c> duplicatesWas = new Set<Duplicate__c>(alertWas.Duplicates__r);
				Set<Id> duplicatesWasIds = new Set<Id>();

				for (Duplicate__c duplicateWas : duplicatesWas) {
					duplicatesWasIds.add(duplicateWas.Id__c);
				}

				if (duplicatesIsIds.containsAll(duplicatesWasIds)) {
					existingAlertsToDelete.add((Id) alertWas.Id);
				}
			}
		}

		delete [SELECT Id FROM Alert__c WHERE Id IN :existingAlertsToDelete];
	}

	/*
	 * Sets handler instance using chosen filter
	 */
	private void setHandlerByFilter(Filter__c filter, SObject sourceObject) {
		this.fields = new Set<String>();
		this.fields.addAll(getObjectRuledFields(filter).values());
		this.fields.addAll(getObjectRuledMergeFields(filter).values());
		if (Enums.FILTER_TYPES_MAP_TO_SCHEMA.get(filter.TargetObjectType__c) != Schema.sObjectType.Order.Name) {
			this.fields.add('OwnerId');
		}

		if (Enums.FILTER_TYPES_MAP_TO_SCHEMA.get(filter.SourceObjectType__c) == Schema.sObjectType.Lead.Name
			&& Enums.FILTER_TYPES_MAP_TO_SCHEMA.get(filter.TargetObjectType__c) == Schema.sObjectType.Lead.Name) {

			if (Lead.sObjectType.getDescribe().fields.getMap().containsKey(Enums.ENQ_MESSAGE_FIELD_BATCH) && Lead.sObjectType.getDescribe().fields.getMap().containsKey(Enums.ACT_HOME_FIELD_BATCH)) {
				fields.add(Enums.ENQ_MESSAGE_FIELD_BATCH);
				fields.add(Enums.ACT_HOME_FIELD_BATCH);
			}
		}

		if (Enums.FILTER_TYPES_MAP_TO_SCHEMA.get(filter.SourceObjectType__c) == Schema.sObjectType.Lead.Name
			&& Enums.FILTER_TYPES_MAP_TO_SCHEMA.get(filter.TargetObjectType__c) == Schema.sObjectType.Opportunity.Name) {

			if (Opportunity.sObjectType.getDescribe().fields.getMap().containsKey(Enums.ENQ_MESSAGE_FIELD_BATCH) && Opportunity.sObjectType.getDescribe().fields.getMap().containsKey(Enums.OPP_HOME_FIELD_BATCH)) {
				fields.add(Enums.ENQ_MESSAGE_FIELD_BATCH);
				fields.add(Enums.OPP_HOME_FIELD_BATCH);
			}
		}

		if (Enums.FILTER_TYPES_MAP_TO_SCHEMA.get(filter.TargetObjectType__c) == Schema.sObjectType.Lead.Name) {
			if (Lead.sObjectType.getDescribe().fields.getMap().containsKey('Status') && !Test.isRunningTest()) {
				fields.add('Status');
			}
		}
		if (Enums.FILTER_TYPES_MAP_TO_SCHEMA.get(filter.TargetObjectType__c) == Schema.sObjectType.Opportunity.Name) {
			if (Opportunity.sObjectType.getDescribe().fields.getMap().containsKey('StageName') && !Test.isRunningTest()) {
				fields.add('StageName');
			}
		}
		if (Enums.FILTER_TYPES_MAP_TO_SCHEMA.get(filter.TargetObjectType__c) == Schema.sObjectType.Order.Name) {
			if (Order.sObjectType.getDescribe().fields.getMap().containsKey('Status') && !Test.isRunningTest()) {
				fields.add('Status');
			}
		}
		if (Enums.FILTER_TYPES_MAP_TO_SCHEMA.get(filter.TargetObjectType__c) == Schema.sObjectType.Account.Name) {
			if (Account.sObjectType.getDescribe().fields.getMap().containsKey('Guest_Status__c') && !Test.isRunningTest()) {
				fields.add('Guest_Status__c');
			}
			if (Account.sObjectType.getDescribe().fields.getMap().containsKey('Host_Status__c') && !Test.isRunningTest()) {
				fields.add('Host_Status__c');
			}
		}

		if (!this.fields.isEmpty()) {

			this.fields.add(Constants.QUERY_USER_READ_ACCESS);
			if (!filter.AutoMerge__c) {
				this.fields.add(Constants.FIELD_NAME_FOR_NAME);
			}
			this.fields.add(Constants.FIELD_NAME_FOR_LAST_MODIFIED_DATE);

			if (this.fields.contains(Utils.RECORD_TYPE_NAME)) {
				this.fields.remove(Utils.RECORD_TYPE_NAME);
			}

			Integer queryLimit = 1500;

			if (!filter.AutoMerge__c) {
				if (!isUpdating) {
					Enums.MatchOnInsertType matchType = Enums.MATCH_ON_INSERT_TYPES_MAP.get(filter.MatchOnInsert__c);

					if (matchType == Enums.MatchOnInsertType.DO_NOTHING) {
						queryLimit = 1;
					}
					else if (matchType == Enums.MatchOnInsertType.DO_NOT_INSERT) {
						queryLimit = 5;
					}
					else if (matchType == Enums.MatchOnInsertType.DISPLAY_MATCHING) {
						queryLimit = 20;
					}
					else if (matchType == Enums.MatchOnInsertType.REPORT_DUPLICATE) {
						//
					}
				}
				else {
					Enums.MatchOnUpdateType matchType = Enums.MATCH_ON_UPDATE_TYPES_MAP.get(filter.MatchOnUpdate__c);

					if (matchType == Enums.MatchOnUpdateType.DO_NOTHING) {
						queryLimit = 1;
					}
					else if (matchType == Enums.MatchOnUpdateType.DO_NOT_UPDATE) {
						queryLimit = 5;
					}
					else if (matchType == Enums.MatchOnUpdateType.REPORT_DUPLICATE) {
						//
					}
				}
			}

			this.exsObjects = cleanExistingsFromCurrents(
				this.newObjects,
				Database.query(
					Utils.generateQuery(
						this.fields,
						Enums.FILTER_TYPES_MAP_TO_SCHEMA.get(filter.TargetObjectType__c),
						queryLimit,
						filter.Rules__r,
						sourceObject,
						filter.MatchLogic__c == Constants.AND_CONST
					)
				)
			);

			Map<Id, SObject> exsObjectFullMap = new Map<Id, SObject>(exsObjects);
			List<Id> availableObjects = new List<Id>(exsObjectFullMap.keySet());
			List<Id> availableObjectsWithLimit = new List<Id>();
			for (Integer i = 0; i < Constants.RECORD_ACCESS_SIZE && i < availableObjects.size(); i++) {
				availableObjectsWithLimit.add(availableObjects[i]);
			}

			List<UserRecordAccess> exsUserObjects = [
				SELECT RecordId
				FROM UserRecordAccess
				WHERE UserId = :UserInfo.getUserId()
					AND HasReadAccess = true
					AND RecordId IN :availableObjectsWithLimit
				LIMIT 200
			];
			exsObjectsAccessed = new List<SObject>();
			for (UserRecordAccess exsUserObject : exsUserObjects) {
				exsObjectsAccessed.add(exsObjectFullMap.get(exsUserObject.RecordId));
			}
		}
	}

	/*
	 * Handles objects for chosen filter
	 */
	private Boolean handleFilter(Filter__c filter) {
		Boolean wasExecuted = false;
		if (filter.HandledStatus__c == null
			&& !Test.isRunningTest()
			&& Enums.FILTER_TYPES_MAP_TO_SCHEMA.get(filter.TargetObjectType__c) != Schema.sObjectType.Contact.Name) {
			//contact was declined as object which handling is based on statuses

			return false;
		}
		if (filter.Rules__r.isEmpty()) {
			return false;
		}
		if (!filter.SearchAllRecords__c) {
			for (SObject iterObject : newObjects) {

				if (Enums.FILTER_TYPES_MAP_TO_SCHEMA.get(filter.SourceObjectType__c) == Schema.sObjectType.Lead.Name) {
					try {
						setHandlerByFilter(
							filter,
							iterObject
						);

						if (fields.isEmpty()) {
							return false;
						}

						if (handleObject(iterObject, exsObjectsAccessed, filter)) {
							wasExecuted = true;
						}
					}
					catch (Exception exc) {
						/*String defaultVal = null;
						Schema.DescribeFieldResult fieldDescr = Lead.Status.getDescribe();
						List<Schema.PicklistEntry> pickVals = fieldDescr.getPicklistValues();
						for (Schema.PicklistEntry pv: pickVals) {
							if (pv.isDefaultValue()) {
								defaultVal = pv.getValue();
								break;
							}
						}
						if (defaultVal == null) {
							for (Schema.PicklistEntry pv: pickVals) {
								if (pv.getValue() == 'New') {
									defaultVal = pv.getValue();
									break;
								}
							}
						}
						if (defaultVal == null) {
							for (Schema.PicklistEntry pv: pickVals) {
								defaultVal = pv.getValue();
								break;
							}
						}*/
					}
				}
				else {
					setHandlerByFilter(
						filter,
						iterObject
					);

					if (fields.isEmpty()) {
						return false;
					}

					if (handleObject(iterObject, exsObjectsAccessed, filter)) {
						wasExecuted = true;
					}
				}

			}
		}
		else {
			for (SObject iterObject : newObjects) {

				 if (Enums.FILTER_TYPES_MAP_TO_SCHEMA.get(filter.SourceObjectType__c) == Schema.sObjectType.Lead.Name) {
					try {
						setHandlerByFilter(
							filter,
							iterObject
						);

						if (fields.isEmpty()) {
							return false;
						}

						if (handleObject(iterObject, exsObjects, filter)) {
							wasExecuted = true;
						}
					}
					catch (Exception exc) {
						/*String defaultVal = null;
						Schema.DescribeFieldResult fieldDescr = Lead.Status.getDescribe();
						List<Schema.PicklistEntry> pickVals = fieldDescr.getPicklistValues();
						for (Schema.PicklistEntry pv: pickVals) {
							if (pv.isDefaultValue()) {
								defaultVal = pv.getValue();
								break;
							}
						}
						if (defaultVal == null) {
							for (Schema.PicklistEntry pv: pickVals) {
								if (pv.getValue() == 'New') {
									defaultVal = pv.getValue();
									break;
								}
							}
						}
						if (defaultVal == null) {
							for (Schema.PicklistEntry pv: pickVals) {
								defaultVal = pv.getValue();
								break;
							}
						}*/
					}
				}
				else {
					setHandlerByFilter(
						filter,
						iterObject
					);

					if (fields.isEmpty()) {
						return false;
					}

					if (handleObject(iterObject, exsObjects, filter)) {
						wasExecuted = true;
					}
				}
			}
		}

		return wasExecuted;
	}

	private List<SObject> cleanExistingsFromCurrents(List<SObject> newObjects, List<SObject> exsObjects) {
		Map<Id, SObject> exsObjectsMap = new Map<Id, SObject>(exsObjects);
		for (SObject newObject : newObjects) {
			exsObjectsMap.remove((Id) newObject.get(Constants.FIELD_NAME_FOR_ID));
		}

		exsObjects.clear();
		exsObjects.addAll(exsObjectsMap.values());

		return exsObjects;
	}

	private Boolean handleObject(SObject iterObject, List<SObject> exsObjects, Filter__c filter) {
		Map<SObject, Set<Rule__c>> currentFilterDuplicates = new Map<SObject, Set<Rule__c>>();

		for (Rule__c rule : filter.Rules__r) {
			for (SObject exsObject : exsObjects) {

				if (Enums.FILTER_TYPES_MAP_TO_SCHEMA.get(filter.TargetObjectType__c) == Schema.sObjectType.Lead.Name) {
					try {
						if (exsObject.get('Status') == null ||
							exsObject.get('Status') != null && !(new Set<String>(filter.HandledStatus__c.split(';')).contains(String.valueOf(exsObject.get('Status'))))) {
							continue;
						}
					}
					catch (Exception exc) {
						//continue;
					}
				}
				else if (Enums.FILTER_TYPES_MAP_TO_SCHEMA.get(filter.TargetObjectType__c) == Schema.sObjectType.Opportunity.Name) {
					try {
						if (exsObject.get('StageName') == null ||
							exsObject.get('StageName') != null && !(new Set<String>(filter.HandledStatus__c.split(';')).contains(String.valueOf(exsObject.get('StageName'))))) {
							continue;
						}
					}
					catch (Exception exc) {
						//continue;
					}
				}
				else if (Enums.FILTER_TYPES_MAP_TO_SCHEMA.get(filter.TargetObjectType__c) == Schema.sObjectType.Order.Name) {
					try {
						if (exsObject.get('Status') == null ||
							exsObject.get('Status') != null && !(new Set<String>(filter.HandledStatus__c.split(';')).contains(String.valueOf(exsObject.get('Status'))))) {
							continue;
						}
					}
					catch (Exception exc) {
						//continue;
					}
				}
				else if (Enums.FILTER_TYPES_MAP_TO_SCHEMA.get(filter.TargetObjectType__c) == Schema.sObjectType.Account.Name) {
					try {
						if ((exsObject.get('Guest_Status__c') == null ||
							exsObject.get('Guest_Status__c') != null && !(new Set<String>(filter.HandledStatus__c.split(';')).contains(String.valueOf(exsObject.get('Guest_Status__c'))))) &&
							(exsObject.get('Host_Status__c') == null ||
							exsObject.get('Host_Status__c') != null && !(new Set<String>(filter.HandledStatus__c.split(';')).contains(String.valueOf(exsObject.get('Host_Status__c')))))) {
							continue;
						}
					}
					catch (Exception exc) {
						//continue;
					}
				}

				String iterRecordType;
				String exsRecordType;

				try {
					iterRecordType = String.valueOf(iterObject.get(Utils.RECORD_TYPE_NAME));
				}
				catch (SObjectException exc) {
					//silence (null object)
				}

				try {
					exsRecordType = String.valueOf(exsObject.get(Utils.RECORD_TYPE_NAME));
				}
				catch (SObjectException exc) {
					//silence (null object)
				}

				String sourceRecordType;
				if (iterObject.getSObjectType().getDescribe().getRecordTypeInfosByName().get(filter.SourceObjectRecordType__c) != null) {
					sourceRecordType = iterObject.getSObjectType().getDescribe().getRecordTypeInfosByName().get(filter.SourceObjectRecordType__c).getRecordTypeId();
				}
				String targetRecordType;
				if (exsObject.getSObjectType().getDescribe().getRecordTypeInfosByName().get(filter.TargetObjectRecordType__c) != null) {
					targetRecordType = exsObject.getSObjectType().getDescribe().getRecordTypeInfosByName().get(filter.TargetObjectRecordType__c).getRecordTypeId();
				}

				Boolean isReadyForHandle = ((targetRecordType == null || targetRecordType == exsRecordType) && (sourceRecordType == null || sourceRecordType == iterRecordType));

				if (isReadyForHandle && handleField(iterObject, exsObject, rule)) {

					if (currentFilterDuplicates.containsKey(exsObject)) {
						Set<Rule__c> exsObjectRules = currentFilterDuplicates.get(exsObject);
						exsObjectRules.add(rule);
						currentFilterDuplicates.put(exsObject, exsObjectRules);
					}
					else {
						currentFilterDuplicates.put(exsObject, new Set<Rule__c>{rule});
					}

				}
			}
		}

		if (filter.MatchLogic__c == Constants.AND_CONST) {
			for (SObject exsObject : currentFilterDuplicates.keySet()) {
				if (currentFilterDuplicates.get(exsObject).size() != filter.Rules__r.size()) {
					currentFilterDuplicates.remove(exsObject);
				}
			}
		}

		if (!currentFilterDuplicates.isEmpty()) {
			applyFilter(iterObject, currentFilterDuplicates, filter);

			return filter.AutoMerge__c && globalSettings.Fire_Auto_Merge__c && (!getObjectMergeRules(filter).isEmpty() || filter.CreateNewDataTask__c) || !filter.AutoMerge__c && globalSettings.Fire_Triggers__c;
		}

		return false;
	}

	private Boolean handleField(SObject iterObject, SObject exsObject, Rule__c rule) {
		/*
		 * Commented because of used query
		 */

		/*Enums.MatchingApproach ruleApproach = Enums.MATCHING_APPROACH.get(rule.MatchingApproach__c);
		String sourceField = rule.SourceField__c;
		String targetField = rule.TargetField__c;
		String iterField = String.valueOf(iterObject.get(sourceField));
		String exsField = String.valueOf(exsObject.get(targetField));

		if (ruleApproach == null) {
			return false;
		}
		else if (!rule.MatchBlanks__c && (String.isEmpty(iterField) || String.isEmpty(exsField))) {
			return false;
		}
		else if (rule.MatchBlanks__c && ((String.isEmpty(iterField) && !String.isEmpty(exsField)) || (!String.isEmpty(iterField) && String.isEmpty(exsField)))) {
			return false;
		}
		else if (rule.MatchBlanks__c && (String.isEmpty(iterField) && String.isEmpty(exsField))) {
			return true;
		}
		else if (ruleApproach == Enums.MatchingApproach.EXACT) {
			return iterField == exsField;
		}
		else if (ruleApproach == Enums.MatchingApproach.FIRST_N_LETTERS) {
			Boolean fieldsLessLength = (iterField.length() < rule.FirstN__c ||  exsField.length() < rule.FirstN__c);
			if (fieldsLessLength) {
				if (iterField.length() == exsField.length()) {
					return iterField == exsField;
				}
				else {
					return false;
				}
			}

			iterField = iterField.substring(0, Integer.valueOf(rule.FirstN__c));
			exsField = exsField.substring(0, Integer.valueOf(rule.FirstN__c));

			return iterField == exsField;
		}
		else if (ruleApproach == Enums.MatchingApproach.FIRST_N_WORDS) {
			if (String.isEmpty(iterField) || String.isEmpty(exsField)) {
				return false;
			}

			List<String> iterFieldList = iterField.split(Constants.SPACE_SYMBOL);
			List<String> exsFieldList = exsField.split(Constants.SPACE_SYMBOL);

			Integer firstNValue = Integer.valueOf(rule.FirstN__c);

			if (iterFieldList.size() >= firstNValue && exsFieldList.size() >= firstNValue) {
				for (Integer i = iterFieldList.size() - 1; i != firstNValue - 1; i--) {
					iterFieldList.remove(i);
				}
				for (Integer i = exsFieldList.size() - 1; i != firstNValue - 1; i--) {
					exsFieldList.remove(i);
				}
			}

			iterField = String.valueOf(iterFieldList);
			exsField = String.valueOf(exsFieldList);

			return iterField == exsField;
		}
		else if (ruleApproach == Enums.MatchingApproach.N_DAYS) {
			try {
				if (iterObject.getSObjectType().getDescribe().fields.getMap().get(sourceField).getDescribe().getType() == Schema.DisplayType.Date) {
					Date iterDate = (Date) iterObject.get(sourceField);
					Date exsDate = (Date) exsObject.get(targetField);

					Integer daysBetween = Math.abs(iterDate.daysBetween(exsDate));

					return daysBetween > rule.FirstN__c ? false : true;
				}
				else if (iterObject.getSObjectType().getDescribe().fields.getMap().get(sourceField).getDescribe().getType() == Schema.DisplayType.Datetime) {
					Datetime iterDatetime = (Datetime) iterObject.get(sourceField);
					Datetime exsDatetime = (Datetime) exsObject.get(targetField);

					Date iterDate = Date.newinstance(iterDatetime.year(), iterDatetime.month(), iterDatetime.day());
					Date exsDate = Date.newinstance(exsDatetime.year(), exsDatetime.month(), exsDatetime.day());

					Integer daysBetween = Math.abs(iterDate.daysBetween(exsDate));

					return daysBetween > rule.FirstN__c ? false : true;
				}
			}
			catch (Exception exc) {
				//ssh...
			}

			return false;
		}
		else {
			return false;
		}*/

		return true;
	}

	private void applyFilter(SObject iterObject, Map<SObject, Set<Rule__c>> currentDuplicates, Filter__c filter) {
		List<SObject> values = new List<SObject>(currentDuplicates.keyset());
		List<SObject> valuesSortedByDate = new List<SObject>();

		Utils.sortByDateTime(values, 'LastModifiedDate');
		SObject recentSource = values[values.size()-1];

		if (iterObject.getSObjectType().getDescribe().getLabel() == Schema.sObjectType.Order.Name &&
			recentSource.getSObjectType().getDescribe().getLabel() == Schema.sObjectType.Opportunity.Name &&
			iterObject.get('OpportunityId') == null) {

			Order resultOrder = (Order) iterObject.clone(true, true);
			resultOrder.put('OpportunityId', recentSource.get('Id'));
			this.recordsToUpdate.add(resultOrder);
		}

		if (filter.AutoMerge__c) {
			if (!globalSettings.Fire_Auto_Merge__c) {
				return;
			}
			applyAutoActionFilter(iterObject, currentDuplicates, filter);
		}
		else {
			if (!globalSettings.Fire_Triggers__c) {
				return;
			}
			applyManualActionFilter(iterObject, currentDuplicates, filter);
		}
	}

	private void applyManualActionFilter(SObject iterObject, Map<SObject, Set<Rule__c>> currentDuplicates, Filter__c filter) {
		if (!isUpdating) {
			Enums.MatchOnInsertType matchType = Enums.MATCH_ON_INSERT_TYPES_MAP.get(filter.MatchOnInsert__c);

			if (matchType == Enums.MatchOnInsertType.DO_NOTHING) {
				//doing nothing
			}
			else if (matchType == Enums.MatchOnInsertType.DO_NOT_INSERT) {
				if (!Boolean.valueOf(iterObject.get(Enums.OVERRIDE_FIELD))) {
					recordsToDelete.add(iterObject);
				}
				else {
					iterObject.put(Enums.OVERRIDE_FIELD, false);
				}
				/*iterObject.addError(
					buildDuplicationError(currentDuplicates, false, filter),
					false
				);*/
			}
			else if (matchType == Enums.MatchOnInsertType.DISPLAY_MATCHING) {
				if (!Boolean.valueOf(iterObject.get(Enums.OVERRIDE_FIELD))) {
					recordsToDelete.add(iterObject);
				}
				else {
					iterObject.put(Enums.OVERRIDE_FIELD, false);
				}
				/*Alert__c alert = buildAlert(iterObject, currentDuplicates, filter);
				iterObject.addError(
					buildDuplicationError(currentDuplicates, true, filter),
					false
				);*/
			}
			else if (matchType == Enums.MatchOnInsertType.REPORT_DUPLICATE) {
				Alert__c alert = buildAlert(iterObject, currentDuplicates, filter);
			}
		}
		else {
			Enums.MatchOnUpdateType matchType = Enums.MATCH_ON_UPDATE_TYPES_MAP.get(filter.MatchOnUpdate__c);

			if (matchType == Enums.MatchOnUpdateType.DO_NOTHING) {
				//doing nothing
			}
			else if (matchType == Enums.MatchOnUpdateType.DO_NOT_UPDATE) {
				if (!Boolean.valueOf(iterObject.get(Enums.OVERRIDE_FIELD))) {
					recordsToDelete.add(iterObject);
				}
				else {
					iterObject.put(Enums.OVERRIDE_FIELD, false);
				}
				/*iterObject.addError(
					buildDuplicationError(currentDuplicates, false, filter),
					false
				);*/
			}
			else if (matchType == Enums.MatchOnUpdateType.REPORT_DUPLICATE) {
				Alert__c alert = buildAlert(iterObject, currentDuplicates, filter);
			}
		}
	}

	private void applyAutoActionFilter(SObject iterObject, Map<SObject, Set<Rule__c>> currentDuplicates, Filter__c filter) {
		Map<Map<String, String>, MergeRule__c> fields = getObjectMergeRules(filter);
		if (fields.isEmpty() && !filter.CreateNewDataTask__c) {
			return;
		}

		List<SObject> currentDuplicatesList = new List<SObject>(currentDuplicates.keySet());
		SObject latestDuplicate = currentDuplicatesList[0];

		for (SObject currentDuplicate : currentDuplicatesList) {
			Datetime currentModified = Datetime.valueOf(currentDuplicate.get(Constants.FIELD_NAME_FOR_LAST_MODIFIED_DATE));
			Datetime latestModified = Datetime.valueOf(latestDuplicate.get(Constants.FIELD_NAME_FOR_LAST_MODIFIED_DATE));

			if (currentModified > latestModified) {
				latestDuplicate = currentDuplicate;
			}
		}

		for (Integer i = 0; i < currentDuplicatesList.size(); i++) {
			if (currentDuplicatesList[i].Id == latestDuplicate.Id) {
				currentDuplicatesList.remove(i);
				break;
			}
		}

		try {
			for (Map<String, String> fieldsMap : fields.keySet()) {
				String sourceField = new List<String>(fieldsMap.keySet()).get(0);

				Boolean isMergeAllowed =
					(!fields.get(fieldsMap).MergeBlanks__c && !String.isEmpty(String.valueOf(iterObject.get(sourceField)))) ||
					fields.get(fieldsMap).MergeBlanks__c;

				if (isMergeAllowed) {
					Boolean isMergeAvailable = !String.isEmpty(String.valueOf(iterObject.get(sourceField)))
						&& !filter.CreateNewDataTask__c
						&& sourceField != Enums.ACT_HOME_FIELD_BATCH
						&& sourceField != Enums.ENQ_MESSAGE_FIELD_BATCH;

					if (isMergeAvailable) {
						try {
							applyMergeRule(latestDuplicate, fieldsMap.get(sourceField), iterObject.get(sourceField), fields.get(fieldsMap));
						}
						catch (Exception exc) {
							//continue process
						}
					}
					else {
						for (SObject currentDuplicate : currentDuplicatesList) {
							if (!String.isEmpty(String.valueOf(currentDuplicate.get(fieldsMap.get(sourceField))))) {
								try {
									latestDuplicate.put(fieldsMap.get(sourceField), currentDuplicate.get(fieldsMap.get(sourceField)));
								}
								catch (Exception exc) {
									//continue process
								}
								break;
							}
						}
					}
				}
			}

			updateAvailableObjects(currentDuplicatesList, iterObject, latestDuplicate, filter);
		}
		catch (SObjectException exc) {
			//iterObject.addError(Label.DuplicationCannotMerge + Constants.HTML_TAG_BR + exc.getMessage() + Constants.DOT_SYMBOL, false);
		}
	}

	private void applyMergeRule(SObject latestDuplicate, String sourceField, Object sourceValue, MergeRule__c mergingRule) {
		if (mergingRule.MergeAction__c == null) {
			return;
		}
		else if (mergingRule.MergeAction__c.contains(Constants.MERGE_ACT_REPLACE) || String.valueOf(sourceValue) == null || String.valueOf(latestDuplicate.get(sourceField)) == null) {
			latestDuplicate.put(sourceField, sourceValue);
		}
		else if (mergingRule.MergeAction__c.contains(Constants.MERGE_ACT_APPEND)) {
			String mergingResult = Constants.EMPTY_SYMBOL;
			String separator = Constants.EMPTY_SYMBOL;

			if (mergingRule.MergeAction__c.contains(Constants.MERGE_ACT_SPACE)) {
				separator = Constants.SPACE_SYMBOL;
			}
			else if (mergingRule.MergeAction__c.contains(Constants.MERGE_ACT_DATE)) {
				separator = Constants.NEW_LINE_SYMBOL;
				separator += Constants.LEFT_PAR;
				separator += String.valueOf(Date.today().format());
				separator += Constants.RIGHT_PAR;
				separator += Constants.SPACE_SYMBOL;
			}
			else if (mergingRule.MergeAction__c.contains(Constants.MERGE_ACT_LINE)) {
				separator = Constants.NEW_LINE_SYMBOL;
			}
			else if (mergingRule.MergeAction__c.contains(Constants.MERGE_ACT_COMMA)) {
				separator = Constants.COMMA_SYMBOL;
			}
			else if (mergingRule.MergeAction__c.contains(Constants.MERGE_ACT_SEMICOL)) {
				separator = Constants.SEMICOLON_SYMBOL;
			}

			if (String.isNotBlank(String.valueOf(latestDuplicate.get(sourceField)))) {
				mergingResult = String.valueOf(latestDuplicate.get(sourceField));
			}
			if (String.isNotBlank(mergingResult) && String.isNotBlank(String.valueOf(sourceValue))) {
				mergingResult += separator;
			}
			if (String.isNotBlank(String.valueOf(sourceValue))) {
				mergingResult += String.valueOf(sourceValue);
			}

			latestDuplicate.put(sourceField, mergingResult);
		}
		else if (mergingRule.MergeAction__c.contains(Constants.MERGE_ACT_PREPEND)) {
			String mergingResult = Constants.EMPTY_SYMBOL;
			String separator = Constants.EMPTY_SYMBOL;

			if (mergingRule.MergeAction__c.contains(Constants.MERGE_ACT_SPACE)) {
				separator = Constants.SPACE_SYMBOL;
			}
			else if (mergingRule.MergeAction__c.contains(Constants.MERGE_ACT_DATE)) {
				separator = Constants.NEW_LINE_SYMBOL;
				separator += Constants.LEFT_PAR;
				separator += String.valueOf(Date.today().format());
				separator += Constants.RIGHT_PAR;
				separator += Constants.SPACE_SYMBOL;
			}
			else if (mergingRule.MergeAction__c.contains(Constants.MERGE_ACT_LINE)) {
				separator = Constants.NEW_LINE_SYMBOL;
			}
			else if (mergingRule.MergeAction__c.contains(Constants.MERGE_ACT_COMMA)) {
				separator = Constants.COMMA_SYMBOL;
			}
			else if (mergingRule.MergeAction__c.contains(Constants.MERGE_ACT_SEMICOL)) {
				separator = Constants.SEMICOLON_SYMBOL;
			}

			if (String.isNotBlank(String.valueOf(sourceValue))) {
				mergingResult = String.valueOf(sourceValue);
			}
			if (String.isNotBlank(mergingResult) && String.isNotBlank(String.valueOf(latestDuplicate.get(sourceField)))) {
				mergingResult += separator;
			}
			if (String.isNotBlank(String.valueOf(latestDuplicate.get(sourceField)))) {
				mergingResult += String.valueOf(latestDuplicate.get(sourceField));
			}

			latestDuplicate.put(sourceField, mergingResult);
		}
	}

	private void updateAvailableObjects(List<SObject> currentDuplicatesList, SObject iterObject, SObject resultObject, Filter__c filter) {
		if (filter.CreateNewDataTask__c
			&& Enums.FILTER_TYPES_MAP_TO_SCHEMA.get(filter.SourceObjectType__c) == Schema.sObjectType.Lead.Name
			&& Enums.FILTER_TYPES_MAP_TO_SCHEMA.get(filter.TargetObjectType__c) != Schema.sObjectType.Order.Name) {

			Task taskOnObject = new Task();

			Map<String, SObjectField> fields = Task.getSObjectType().getDescribe().fields.getMap();
			for (SObjectField field : fields.values()) {
				if (Enums.ACTIVITY_LEAD_FIELDS.containsKey(field.getDescribe().getName())) {
					try {
						taskOnObject.put(field.getDescribe().getName(), iterObject.get(Enums.ACTIVITY_LEAD_FIELDS.get(field.getDescribe().getName())));
					}
					catch (Exception exc) {
						//shh!
					}
				}
			}

			if (Enums.FILTER_TYPES_MAP_TO_SCHEMA.get(filter.SourceObjectType__c) == Schema.sObjectType.Lead.Name
				&& Enums.FILTER_TYPES_MAP_TO_SCHEMA.get(filter.TargetObjectType__c) == Schema.sObjectType.Lead.Name) {
				try {
					String mergingHome = Constants.EMPTY_SYMBOL;

					if (String.isNotBlank(String.valueOf(resultObject.get(Enums.ACT_HOME_FIELD_BATCH)))) {
						mergingHome = String.valueOf(resultObject.get(Enums.ACT_HOME_FIELD_BATCH));
					}
					if (String.isNotBlank(mergingHome) && String.isNotBlank(String.valueOf(iterObject.get(Enums.ACT_HOME_FIELD_BATCH)))) {
						mergingHome += Constants.SEMICOLON_SYMBOL;
					}
					if (String.isNotBlank(String.valueOf(iterObject.get(Enums.ACT_HOME_FIELD_BATCH)))) {
						mergingHome += String.valueOf(iterObject.get(Enums.ACT_HOME_FIELD_BATCH));
					}

					Schema.DescribeFieldResult homeField = Lead.getSObjectType().getDescribe().fields.getMap().get(Enums.ACT_HOME_FIELD_BATCH).getDescribe();
					Integer lengthOfField = homeField.getLength();
					resultObject.put(Enums.ACT_HOME_FIELD_BATCH, mergingHome.right(lengthOfField));

					String mergingMessage = Constants.EMPTY_SYMBOL;

					if (String.isNotBlank(String.valueOf(resultObject.get(Enums.ENQ_MESSAGE_FIELD_BATCH)))) {
						mergingMessage = String.valueOf(resultObject.get(Enums.ENQ_MESSAGE_FIELD_BATCH));
					}
					if (String.isNotBlank(mergingMessage) && String.isNotBlank(String.valueOf(iterObject.get(Enums.ENQ_MESSAGE_FIELD_BATCH)))) {
						mergingMessage += Constants.NEW_LINE_SYMBOL;
						mergingMessage += Constants.LEFT_PAR;
						mergingMessage += String.valueOf(Date.today().format());
						mergingMessage += Constants.RIGHT_PAR;
						mergingMessage += Constants.SPACE_SYMBOL;
					}
					if (String.isNotBlank(String.valueOf(iterObject.get(Enums.ENQ_MESSAGE_FIELD_BATCH)))) {
						mergingMessage += String.valueOf(iterObject.get(Enums.ENQ_MESSAGE_FIELD_BATCH));
					}

					resultObject.put(Enums.ENQ_MESSAGE_FIELD_BATCH, mergingMessage);
				}
				catch (Exception exc) {
					//shh!
				}
			}

			if (Enums.FILTER_TYPES_MAP_TO_SCHEMA.get(filter.SourceObjectType__c) == Schema.sObjectType.Lead.Name
				&& Enums.FILTER_TYPES_MAP_TO_SCHEMA.get(filter.TargetObjectType__c) == Schema.sObjectType.Opportunity.Name) {
				try {
					String mergingHome = Constants.EMPTY_SYMBOL;

					if (String.isNotBlank(String.valueOf(resultObject.get(Enums.OPP_HOME_FIELD_BATCH)))) {
						mergingHome = String.valueOf(resultObject.get(Enums.OPP_HOME_FIELD_BATCH));
					}
					if (String.isNotBlank(mergingHome) && String.isNotBlank(String.valueOf(iterObject.get(Enums.ACT_HOME_FIELD_BATCH)))) {
						mergingHome += Constants.SEMICOLON_SYMBOL;
					}
					if (String.isNotBlank(String.valueOf(iterObject.get(Enums.ACT_HOME_FIELD_BATCH)))) {
						mergingHome += String.valueOf(iterObject.get(Enums.ACT_HOME_FIELD_BATCH));
					}

					Schema.DescribeFieldResult homeField = Lead.getSObjectType().getDescribe().fields.getMap().get(Enums.ACT_HOME_FIELD_BATCH).getDescribe();
					Integer lengthOfField = homeField.getLength();
					resultObject.put(Enums.OPP_HOME_FIELD_BATCH, mergingHome.right(lengthOfField));

					String mergingMessage = Constants.EMPTY_SYMBOL;

					if (String.isNotBlank(String.valueOf(resultObject.get(Enums.ENQ_MESSAGE_FIELD_BATCH)))) {
						mergingMessage = String.valueOf(resultObject.get(Enums.ENQ_MESSAGE_FIELD_BATCH));
					}
					if (String.isNotBlank(mergingMessage) && String.isNotBlank(String.valueOf(iterObject.get(Enums.ENQ_MESSAGE_FIELD_BATCH)))) {
						mergingMessage += Constants.NEW_LINE_SYMBOL;
						mergingMessage += Constants.LEFT_PAR;
						mergingMessage += String.valueOf(Date.today().format());
						mergingMessage += Constants.RIGHT_PAR;
						mergingMessage += Constants.SPACE_SYMBOL;
					}
					if (String.isNotBlank(String.valueOf(iterObject.get(Enums.ENQ_MESSAGE_FIELD_BATCH)))) {
						mergingMessage += String.valueOf(iterObject.get(Enums.ENQ_MESSAGE_FIELD_BATCH));
					}

					resultObject.put(Enums.ENQ_MESSAGE_FIELD_BATCH, mergingMessage);
				}
				catch (Exception exc) {
					//shh!
				}
			}

			//if (Enums.FILTER_TYPES_MAP_TO_SCHEMA.get(filter.TargetObjectType__c) == Schema.sObjectType.Lead.Name) {
			//  resultObject.put(Schema.sObjectType.Lead.fields.Status.getName(), ACTIVITY_LEAD_STATUS);
			//}
			//else if (Enums.FILTER_TYPES_MAP_TO_SCHEMA.get(filter.TargetObjectType__c) == Schema.sObjectType.Opportunity.Name) {
			//  resultObject.put(Schema.sObjectType.Opportunity.fields.StageName.getName(), ACTIVITY_OPPO_STAGE);
			//}

			String actHomeField = String.isNotBlank(String.valueOf(iterObject.get(Enums.ACT_HOME_FIELD_BATCH))) ? (String.valueOf(iterObject.get(Enums.ACT_HOME_FIELD_BATCH)) + Constants.SPACE_SYMBOL) : Constants.EMPTY_SYMBOL;
			String actMarketField = String.isNotBlank(String.valueOf(iterObject.get(Enums.ACT_MARKET_FIELD_BATCH))) ? (String.valueOf(iterObject.get(Enums.ACT_MARKET_FIELD_BATCH))) : Label.EmptyMarket;

			String resultOwnerId = String.valueOf(resultObject.get('OwnerId'));
			if (resultOwnerId.startsWith('005')) {
				taskOnObject.OwnerId = (Id) resultObject.get('OwnerId');
			}
			if (resultOwnerId.startsWith('00G')) {
				taskOnObject.OwnerId = (Id) iterObject.get('OwnerId');
			}

			taskOnObject.Subject = Enums.ENQUIRY_TYPE + Constants.COLON_SYMBOL + Constants.SPACE_SYMBOL
				+ actHomeField + actMarketField;
			taskOnObject.Status = Constants.TASK_STATUS_OPEN;
			taskOnObject.Priority = Constants.TASK_PRIORITY_NORMAL;
			taskOnObject.ActivityDate = Date.today();
			if (Enums.FILTER_TYPES_MAP_TO_SCHEMA.get(filter.TargetObjectType__c) == Schema.sObjectType.Lead.Name) {
				taskOnObject.WhoId = resultObject.Id;
			}
			if (Enums.FILTER_TYPES_MAP_TO_SCHEMA.get(filter.TargetObjectType__c) == Schema.sObjectType.Contact.Name) {
				taskOnObject.WhoId = resultObject.Id;
			}
			if (Enums.FILTER_TYPES_MAP_TO_SCHEMA.get(filter.TargetObjectType__c) == Schema.sObjectType.Account.Name) {
				taskOnObject.WhatId = resultObject.Id;
			}
			if (Enums.FILTER_TYPES_MAP_TO_SCHEMA.get(filter.TargetObjectType__c) == Schema.sObjectType.Opportunity.Name) {
				taskOnObject.WhatId = resultObject.Id;
			}
			/*if (Enums.FILTER_TYPES_MAP_TO_SCHEMA.get(filter.TargetObjectType__c) == Schema.sObjectType.Order.Name) {
				taskOnObject.WhatId = resultObject.Id;
			}*/
			taskOnObject.RecordTypeId = taskOnObject.getSObjectType().getDescribe().getRecordTypeInfosByName().get(Enums.ENQUIRY_TYPE).getRecordTypeId();

			this.recordsToInsert.add(taskOnObject);
		}

		Set<SObject> exsObjectsSet = new Set<SObject>(this.exsObjects);
		exsObjectsSet.removeAll(currentDuplicatesList);
		exsObjectsSet.remove(resultObject);
		this.exsObjects = new List<SObject>(exsObjectsSet);

		this.recordsToUpdate.add(resultObject);

		AutoMergeResult__c result = new AutoMergeResult__c(
			ResultId__c = resultObject.Id,
			UserId__c = UserInfo.getUserId(),
			Filter__c = filter.Id
		);
		this.recordsToInsert.add(result);

		this.recordsToDelete.add(iterObject.clone(true, true));
		this.recordsToDelete.addAll(new List<SObject>(currentDuplicatesList));
	}

	private String buildDuplicationError(Map<SObject, Set<Rule__c>> currentDuplicates, Boolean includeLink, Filter__c filter) {
		Set<Rule__c> matchingRules = new Set<Rule__c>();
		for (Set<Rule__c> rules : currentDuplicates.values()) {
			matchingRules.addAll(rules);
		}

		String errorMessage = Constants.HTML_TAG_BR;
		for (Rule__c rule : matchingRules) {
			errorMessage += String.format(Label.DuplicationErrorOnField, new List<String>{
				(Schema.getGlobalDescribe().get(Enums.FILTER_TYPES_MAP_TO_SCHEMA.get(filter.SourceObjectType__c)).getDescribe().fields.getMap().get(rule.SourceField__c).getDescribe().getLabel())
			});
			errorMessage += Constants.HTML_TAG_BR;
		}

		errorMessage += Constants.HTML_TAG_BR;
		errorMessage += Label.DuplicationPotentialList;

		List<SObject> duplicatesList = new List<SObject>(currentDuplicates.keySet());
		for (Integer i = 0; i != duplicatesList.size() && i < RECORDS_TO_SHOW; i++) {
			String duplicateLabel = duplicatesList[i].get(Constants.FIELD_NAME_FOR_NAME) != null ?
				String.valueOf(duplicatesList[i].get(Constants.FIELD_NAME_FOR_NAME)) :
				String.valueOf(duplicatesList[i].get(Constants.FIELD_NAME_FOR_ID));

			errorMessage += Constants.HTML_TAG_BR;
			errorMessage += String.format(
				Constants.HTML_TAG_A,
				new List<String>{
					(Url.getSalesforceBaseUrl().toExternalForm() + Constants.SLASH_SYMBOL + duplicatesList[i].get(Constants.FIELD_NAME_FOR_ID)),
					duplicateLabel
				}
			);
		}

		//errorMessage += '<button onclick="getRemoteResult(\'bubuf\'); return false;">Override</button>';
		//errorMessage += '<script>function getRemoteResult(argue) { Visualforce.remoting.Manager.invokeAction(\'{!$RemoteAction.RemoteActionUtils.testRemote}\', argue, function(result, event) { alert(\'it works!1!\'); }, {escape: true} );}</script>';

		if (includeLink) {
			duplicatesList = new List<SObject>(currentDuplicates.keySet());
			String recordIdsString = String.valueOf(duplicatesList[0].get(Constants.FIELD_NAME_FOR_ID));
			for (Integer i = 1; i != duplicatesList.size() && i < Constants.RECORD_MERGE_SIZE; i++) {
				recordIdsString += Constants.COLON_SYMBOL;
				recordIdsString += duplicatesList[i].get(Constants.FIELD_NAME_FOR_ID);
			}

			errorMessage += Constants.HTML_TAG_BR;
			errorMessage += Constants.HTML_TAG_BR;
			errorMessage += String.format(
				Constants.HTML_TAG_A,
				new List<String>{
					(Url.getSalesforceBaseUrl().toExternalForm()
						+ Constants.SLASH_SYMBOL + MERGE_PAGE
						+ Constants.QUESTION_SYMBOL + FILTER_ID_URL + Constants.EQUAL_SYMBOL + filter.Id
						+ Constants.AMPERSAND_SYMBOL + RECORDS_IDS_URL + Constants.EQUAL_SYMBOL + recordIdsString),
					Label.DuplicationShowMore
				}
			);
		}

		return errorMessage;
	}

	private Alert__c buildAlert(SObject iterObject, Map<SObject, Set<Rule__c>> currentDuplicates, Filter__c filter) {
		//could be checked for the same alerts existence
		Alert__c alert = new Alert__c(
			Filter__c = filter.Id,
			Type__c = filter.SourceObjectType__c + Constants.SLASH_SYMBOL + filter.TargetObjectType__c
		);

		List<Duplicate__c> duplicates = new List<Duplicate__c>();
		duplicates.add(
			new Duplicate__c(
				Alert__c = alert.Id,
				Id__c = String.valueOf(iterObject.get(Constants.FIELD_NAME_FOR_ID))
			)
		);
		for (SObject currentDuplicate : currentDuplicates.keyset()) {
			duplicates.add(
				new Duplicate__c(
					Alert__c = alert.Id,
					Id__c = String.valueOf(currentDuplicate.get(Constants.FIELD_NAME_FOR_ID))
				)
			);
		}
		Map<Alert__c, Filter__c> alertsMapToInsert = new Map<Alert__c, Filter__c>();
		alertsMapToInsert.put(alert, filter);
		alertsToInsert.put(duplicates, alertsMapToInsert);

		return alert;
	}

	private void createDuplicationTask(SObject iterObject, Alert__c alert, Filter__c filter) {
		Enums.CreateTasksType createTaskType = Enums.CREATE_TASKS_TYPES_MAP.get(filter.CreateTasks__c);

		if (createTaskType == Enums.CreateTasksType.NO_CREATING) {
			//doing nothing
			return;
		}
		else if (createTaskType == Enums.CreateTasksType.USER_CREATING) {
			Task duplicationTask = new Task(
				OwnerId = UserInfo.getUserId(),
				Subject = Label.DuplicationTaskSubject + Constants.SPACE_SYMBOL + filter.SourceObjectType__c,
				Status = Constants.TASK_STATUS_NOT_STARTED,
				Priority = Constants.TASK_PRIORITY_NORMAL,
				WhatId = alert.Id
			);
			tasksToInsert.add(duplicationTask);
		}
		else if (createTaskType == Enums.CreateTasksType.USER_FILTER_OWNER) {
			Task duplicationTask = new Task(
				OwnerId = filter.OwnerId,
				Subject = Label.DuplicationTaskSubject + Constants.SPACE_SYMBOL + filter.SourceObjectType__c,
				Status = Constants.TASK_STATUS_NOT_STARTED,
				Priority = Constants.TASK_PRIORITY_NORMAL,
				WhatId = alert.Id
			);
			tasksToInsert.add(duplicationTask);
		}
	}

	private List<Filter__c> getObjectFilters(String sourceObjectName) {
		List<Filter__c> availableFilters = [
			SELECT SourceObjectType__c, TargetObjectType__c, Active__c, CreateTasks__c, MatchLogic__c, TargetObjectRecordType__c, CreateNewDataTask__c,
				SourceObjectRecordType__c, MatchOnInsert__c, MatchOnUpdate__c, SearchAllRecords__c, Type__c, AutoMerge__c, Priority__c, HandledStatus__c,
				OwnerId,
			(
				SELECT SourceField__c, TargetField__c, FirstN__c, MatchBlanks__c, MatchingApproach__c
				FROM Rules__r
			),
			(
				SELECT SourceField__c, TargetField__c, MergeBlanks__c, MergeAction__c
				FROM MergeRules__r
			)
			FROM Filter__c
			WHERE SourceObjectType__c = :Enums.FILTER_TYPES_MAP_TO_FILTER.get(sourceObjectName).name()
				AND Active__c = true
			ORDER BY TargetObjectType__c, Priority__c ASC
		];
		if (!availableFilters.isEmpty()) {
			return availableFilters;
		}
		else {
			return null;
		}
	}

	private Map<String, String> getObjectRuledFields(Filter__c filter) {
		if (filter == null || filter.Rules__r.isEmpty()) {
			return new Map<String, String>();
		}

		Map<String, String> fields = new Map<String, String>();
		List<Rule__c> rules = filter.Rules__r;

		for (Rule__c rule : rules) {
			fields.put(rule.SourceField__c, rule.TargetField__c);
		}

		return fields;
	}

	private Map<String, String> getObjectRuledMergeFields(Filter__c filter) {
		if (filter == null || filter.MergeRules__r.isEmpty()) {
			return new Map<String, String>();
		}

		Map<String, String> fields = new Map<String, String>();
		List<MergeRule__c> rules = filter.MergeRules__r;

		for (MergeRule__c rule : rules) {
			fields.put(rule.SourceField__c, rule.TargetField__c);
		}

		return fields;
	}

	private Map<Map<String, String>, MergeRule__c> getObjectMergeRules(Filter__c filter) {
		if (filter == null || filter.MergeRules__r.isEmpty()) {
			return new Map<Map<String, String>, MergeRule__c>();
		}

		Map<Map<String, String>, MergeRule__c> fieldRules = new Map<Map<String, String>, MergeRule__c>();
		List<MergeRule__c> rules = filter.MergeRules__r;

		for (MergeRule__c rule : rules) {
			Map<String, String> fields = new Map<String, String>();
			fields.put(rule.SourceField__c, rule.TargetField__c);
			fieldRules.put(fields, rule);
		}

		return fieldRules;
	}

}
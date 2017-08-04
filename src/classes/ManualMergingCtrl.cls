public with sharing class ManualMergingCtrl {

	public static final String FIELD_PARAM = 'field';
	public static final String VALUE_PARAM = 'value';
	public static final String ID_PARAM = 'id';
	public static final String RECORD_ID_PARAM = 'recordid';

	public Map<String, String> fieldsMap { get; private set; }
	public Map<String, Schema.SObjectField> sourceFieldsMap { get; private set; }
	public Map<String, Schema.SObjectField> targetFieldsMap { get; private set; }
	public List<String> requiredFields { get; private set; }
	public List<String> allObjectsIds { get; private set; }
	public Map<Id, SObject> targetObjects { get; private set; }
	public Map<Id, SObject> sourceObjects { get; private set; }
	public Filter__c connectedFilter { get; private set; }
	public SObject resultObject { get; private set; }
	public String pageMessage { get; private set; }

	private Alert__c connectedAlert { private get; private set; }

	public void init() {
		if ((targetObjects == null || targetObjects.isEmpty())
			&& (sourceObjects == null || sourceObjects.isEmpty())
			&& pageMessage == null) {

			decline();
			pageMessage = Label.MergingPageAlertIsNotActual;
		}
	}

	public ManualMergingCtrl() {
		Map<String, String> parameters = ApexPages.currentPage().getParameters();
		String identifier = parameters.get(ID_PARAM);
		String filterId = parameters.get(TriggerHandlerObjectDuplicate.FILTER_ID_URL);
		String recordsIds = parameters.get(TriggerHandlerObjectDuplicate.RECORDS_IDS_URL);

		try {
			if (identifier != null) {
				connectedAlert = [
					SELECT Filter__c,
					(
						SELECT Id__c
						FROM Duplicates__r
					)
					FROM Alert__c
					WHERE Id = :identifier
					LIMIT 1
				];

				connectedFilter = [
					SELECT SourceObjectType__c, TargetObjectType__c, Active__c, CreateTasks__c,
						MatchOnInsert__c, MatchOnUpdate__c, SearchAllRecords__c, Type__c, AutoMerge__c,
					(
						SELECT SourceField__c, TargetField__c, FirstN__c, MatchBlanks__c, MatchingApproach__c
						FROM Rules__r
					),
					(
						SELECT SourceField__c, TargetField__c, MergeBlanks__c
						FROM MergeRules__r
					)
					FROM Filter__c
					WHERE Id = :connectedAlert.Filter__c
					LIMIT 1
				];

				allObjectsIds = new List<String>();
				for (Duplicate__c duplicate : connectedAlert.Duplicates__r) {
					allObjectsIds.add(duplicate.Id__c);
				}
			}
			else {
				connectedFilter = [
					SELECT SourceObjectType__c, TargetObjectType__c, Active__c, CreateTasks__c,
						MatchOnInsert__c, MatchOnUpdate__c, SearchAllRecords__c, Type__c, AutoMerge__c,
					(
						SELECT SourceField__c, TargetField__c, FirstN__c, MatchBlanks__c, MatchingApproach__c
						FROM Rules__r
					),
					(
						SELECT SourceField__c, TargetField__c, MergeBlanks__c
						FROM MergeRules__r
					)
					FROM Filter__c
					WHERE Id = :filterId
					LIMIT 1
				];

				allObjectsIds = recordsIds.split(Constants.COLON_SYMBOL);
			}

			resultObject = Utils.getNewObjectByType(connectedFilter.TargetObjectType__c);

			fieldsMap = new Map<String, String>();

			sourceFieldsMap = Schema.getGlobalDescribe().get(Enums.FILTER_TYPES_MAP_TO_SCHEMA.get(connectedFilter.SourceObjectType__c)).getDescribe().fields.getMap();
			targetFieldsMap = Schema.getGlobalDescribe().get(Enums.FILTER_TYPES_MAP_TO_SCHEMA.get(connectedFilter.TargetObjectType__c)).getDescribe().fields.getMap();

			if (targetFieldsMap.containsKey(Constants.FIELD_NAME_FOR_NAME)) {
				if (targetFieldsMap.get(Constants.FIELD_NAME_FOR_NAME).getDescribe().isCreateable() ||
					targetFieldsMap.get(Constants.FIELD_NAME_FOR_NAME).getDescribe().isUpdateable()) {

					fieldsMap.put(Constants.FIELD_NAME_FOR_NAME, Constants.FIELD_NAME_FOR_NAME);
				}
				else if (fieldsMap.containsKey(Constants.FIELD_NAME_FOR_NAME)) {
					fieldsMap.remove(Constants.FIELD_NAME_FOR_NAME);
				}
			}

			for (Rule__c rule : connectedFilter.Rules__r) {
				fieldsMap.put(rule.SourceField__c, rule.TargetField__c);
			}
			for (MergeRule__c mergeRule : connectedFilter.MergeRules__r) {
				fieldsMap.put(mergeRule.SourceField__c, mergeRule.TargetField__c);
			}

			Set<String> targetFieldsSet = new Set<String>();
			targetFieldsSet.addAll(fieldsMap.values());

			requiredFields = new List<String>();
			Map<String, SObjectField> allTargetFields = resultObject.getSObjectType().getDescribe().fields.getMap();
			for (SObjectField field : allTargetFields.values()) {
				DescribeFieldResult fieldDescription = field.getDescribe();
				if (fieldDescription.isCreateable() && !fieldDescription.isNillable() && !fieldDescription.isDefaultedOnCreate() && !targetFieldsSet.contains(fieldDescription.getName())) {
					requiredFields.add(fieldDescription.getName());
				}
			}
			targetFieldsSet.addAll(requiredFields);

			String targetFields = '';
			String sourceFields = '';
			if (!fieldsMap.containsKey(Constants.FIELD_NAME_FOR_NAME)) {
				sourceFields = Constants.FIELD_NAME_FOR_NAME;
				sourceFields += Constants.COMMA_SYMBOL;
			}
			if (!targetFieldsSet.contains(Constants.FIELD_NAME_FOR_NAME)) {
				targetFields = Constants.FIELD_NAME_FOR_NAME;
				targetFields += Constants.COMMA_SYMBOL;
			}

			for (String sourceField : fieldsMap.keySet()) {
				sourceFields += sourceField;
				sourceFields += Constants.COMMA_SYMBOL;
			}

			for (String targetField : targetFieldsSet) {
				targetFields += targetField;
				targetFields += Constants.COMMA_SYMBOL;
			}

			targetFields = targetFields.left(targetFields.length() - 1);
			sourceFields = sourceFields.left(sourceFields.length() - 1);

			if (connectedFilter.TargetObjectType__c != connectedFilter.SourceObjectType__c) {
				targetObjects = new Map<Id, SObject>(
					Database.query(
						Constants.QUERY_SELECT + Constants.SPACE_SYMBOL + targetFields + Constants.SPACE_SYMBOL +
						Constants.QUERY_FROM + Constants.SPACE_SYMBOL +	Enums.FILTER_TYPES_MAP_TO_SCHEMA.get(connectedFilter.TargetObjectType__c) + Constants.SPACE_SYMBOL +
						Constants.QUERY_WHERE + Constants.SPACE_SYMBOL + Constants.FIELD_NAME_FOR_ID + Constants.SPACE_SYMBOL +
						Constants.QUERY_IN + Constants.SPACE_SYMBOL + Constants.COLON_SYMBOL + 'allObjectsIds'
					)
				);
				sourceObjects = new Map<Id, SObject>(
					Database.query(
						Constants.QUERY_SELECT + Constants.SPACE_SYMBOL + sourceFields + Constants.SPACE_SYMBOL +
						Constants.QUERY_FROM + Constants.SPACE_SYMBOL +	Enums.FILTER_TYPES_MAP_TO_SCHEMA.get(connectedFilter.SourceObjectType__c) + Constants.SPACE_SYMBOL +
						Constants.QUERY_WHERE + Constants.SPACE_SYMBOL + Constants.FIELD_NAME_FOR_ID + Constants.SPACE_SYMBOL +
						Constants.QUERY_IN + Constants.SPACE_SYMBOL + Constants.COLON_SYMBOL + 'allObjectsIds'
					)
				);
			}
			else {
				targetObjects = new Map<Id, SObject>(
					Database.query(
						Constants.QUERY_SELECT + Constants.SPACE_SYMBOL + targetFields + Constants.SPACE_SYMBOL +
						Constants.QUERY_FROM + Constants.SPACE_SYMBOL +	Enums.FILTER_TYPES_MAP_TO_SCHEMA.get(connectedFilter.TargetObjectType__c) + Constants.SPACE_SYMBOL +
						Constants.QUERY_WHERE + Constants.SPACE_SYMBOL + Constants.FIELD_NAME_FOR_ID + Constants.SPACE_SYMBOL +
						Constants.QUERY_IN + Constants.SPACE_SYMBOL + Constants.COLON_SYMBOL + 'allObjectsIds'
					)
				);
				sourceObjects = new Map<Id, SObject>();
			}

		}
		catch (Exception exc) {
			pageMessage = Label.MergingPageTitleDeclined;
		}
	}

	public void moveField() {
		Map<String, String> parameters = ApexPages.currentPage().getParameters();

		String field = parameters.get(FIELD_PARAM);
		String value = parameters.get(VALUE_PARAM);

		SObjectField fieldType = resultObject.getSObjectType().getDescribe().fields.getMap().get(field).getDescribe().getSObjectField();
		if (sourceObjects.containsKey(value)) {
			resultObject.put(fieldType, sourceObjects.get(value).get(field));
		}
		else if (targetObjects.containsKey(value)) {
			resultObject.put(fieldType, targetObjects.get(value).get(field));
		}
	}

	public void clearField() {
		Map<String, String> parameters = ApexPages.currentPage().getParameters();

		String field = parameters.get(FIELD_PARAM);

		try {
			resultObject.put(field, null);
		}
		catch (Exception exc) {
			ApexPages.addMessages(exc);
		}
	}

	public void moveRecord() {
		Map<String, String> parameters = ApexPages.currentPage().getParameters();

		Id id = (Id) parameters.get(RECORD_ID_PARAM);

		if (targetObjects.containsKey(id)) {
			SObject resultTargetObject = targetObjects.get(id);
			resultObject = resultTargetObject.clone();
		}
		else {
			SObject resultSourceObject = sourceObjects.get(id);
			for (String sourceField : fieldsMap.keySet()) {
				resultObject.put(fieldsMap.get(sourceField), resultSourceObject.get(sourceField));
			}
		}
	}

	public void clearRecord() {
		resultObject = Utils.getNewObjectByType(connectedFilter.TargetObjectType__c);
	}

	public PageReference complete() {
		try {
			delete sourceObjects.values();
			delete targetObjects.values();

			TriggerHandler.isEnabled = false;
			insert resultObject;
			TriggerHandler.isEnabled = true;

			if (connectedAlert != null) {
				delete connectedAlert;
			}

			PageReference returningPage = new PageReference(Url.getSalesforceBaseUrl().toExternalForm() + Constants.SLASH_SYMBOL + resultObject.Id);
			returningPage.setRedirect(true);
			return returningPage;
		}
		catch (Exception exc) {
			ApexPages.addMessages(exc);
		}

		return null;
	}

	public PageReference decline() {
		if (connectedAlert != null) {
			delete connectedAlert;

			PageReference returningPage = new PageReference(Url.getSalesforceBaseUrl().toExternalForm() + Constants.SLASH_SYMBOL +
				String.valueOf(connectedAlert.Id).left(3)
			);
			returningPage.setRedirect(true);
			return returningPage;
		}
		else {
			PageReference returningPage = new PageReference(
				Url.getSalesforceBaseUrl().toExternalForm() + Constants.SLASH_SYMBOL +
				allObjectsIds.get(0).left(3)
			);
			returningPage.setRedirect(true);
			return returningPage;
		}
	}

	public PageReference cancel() {
		if (connectedAlert != null) {
			PageReference returningPage = new PageReference(Url.getSalesforceBaseUrl().toExternalForm() + Constants.SLASH_SYMBOL +
				connectedAlert.Id);

			returningPage.setRedirect(true);
			return returningPage;
		}
		else {
			PageReference returningPage = new PageReference(
				Url.getSalesforceBaseUrl().toExternalForm() + Constants.SLASH_SYMBOL +
				allObjectsIds.get(0).left(3)
			);
			returningPage.setRedirect(true);
			return returningPage;
		}

	}

	public PageReference goToHome() {
		PageReference returningPage = new PageReference(Url.getSalesforceBaseUrl().toExternalForm() + Constants.SLASH_SYMBOL + Constants.HOME_URL);
		returningPage.setRedirect(true);
		return returningPage;
	}

}
global class DuplicatesHandlingNoIteratorBatch implements Database.Batchable<sObject>, Database.Stateful {
	
	String objectName;

	TriggerHandler.Events event;

	global DuplicatesHandlingNoIteratorBatch(String objectName, TriggerHandler.Events event) {
		this.objectName = objectName;
		this.event = event;
	}

	private String getQueryWithAllFields(String objectName) {
		String query = Constants.QUERY_SELECT;

		Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();

		for (String field : objectFields.keySet()) {
			query += Constants.SPACE_SYMBOL + field + Constants.COMMA_SYMBOL + Constants.SPACE_SYMBOL;
		}

		if (query.subString(query.Length() - 2, query.Length() - 1) == Constants.COMMA_SYMBOL){
			query = query.subString(0, query.Length() - 2);
		}

		query += Constants.SPACE_SYMBOL + Constants.QUERY_FROM + Constants.SPACE_SYMBOL + objectName;
		query += Constants.SPACE_SYMBOL + Constants.QUERY_WHERE + Constants.SPACE_SYMBOL + 
			Enums.REQUIRED_DUP_CHECK_FIELD + Constants.EQUAL_SYMBOL + Constants.TRUE_SMNT;

		return query;
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(getQueryWithAllFields(objectName));
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		for (SObject scopeItem : scope) {
   			scopeItem.put(Enums.REQUIRED_DUP_CHECK_FIELD, false);

   			if (objectName == Schema.sObjectType.Lead.Name) {
   				try {
                    scopeItem.put('n2de__Is_distributed__c', false);
                    scopeItem.put('n2de__Last_distributed__c', null);
                    scopeItem.put('n2de__Is_reassigned__c', false);
                    scopeItem.put('n2de__Last_reassigned__c', null);
                }
                catch(Exception exc) {
                    //shhhh...
                }
   			}
   		}
   		TriggerHandler.isEnabled = false;
   		try {
   			update scope;
   		}
   		catch (Exception exc) {
   			//silence
   		}   		
   		TriggerHandler.isEnabled = true;

   		if (this.event != TriggerHandler.Events.AFTER_UPDATE) {
   			new TriggerHandler().bind(
	            this.event, new BatchHandlerObjectDuplicate(
	            	this.objectName,
	            	null,
	            	scope
	            )
	        ).manage();
   		}
   		else {
   			new TriggerHandler().bind(
	            this.event, new BatchHandlerObjectDuplicate(
	            	this.objectName,
	            	scope,
	            	scope
	            )
	        ).manage();
   		}
	}

	global void finish(Database.BatchableContext BC) {
		
	}
	
}
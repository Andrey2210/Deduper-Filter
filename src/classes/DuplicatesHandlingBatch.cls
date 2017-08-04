global class DuplicatesHandlingBatch implements Database.Batchable<sObject>, Database.Stateful {

	List<SObject> recordsToHandle;
	List<SObject> recordsToKeepInMind;

	String objectName;

	TriggerHandler.Events event;

	global DuplicatesHandlingBatch(List<SObject> recordsToHandle, List<SObject> recordsToKeepInMind, String objectName, TriggerHandler.Events event) {
		this.recordsToHandle = recordsToHandle;
		this.recordsToKeepInMind = recordsToKeepInMind;
		this.objectName = objectName;
		this.event = event;
	}

	global Iterable<SObject> start(Database.BatchableContext BC) {
		return new DuplicatesHandlingIterator(recordsToHandle);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		new TriggerHandler().bind(
            this.event, new BatchHandlerObjectDuplicate(
            	this.objectName,
            	this.recordsToKeepInMind,
            	scope
            )
        ).manage();
	}

	global void finish(Database.BatchableContext BC) {

	}

}
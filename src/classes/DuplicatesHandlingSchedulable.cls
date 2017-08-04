global class DuplicatesHandlingSchedulable implements Schedulable {

	String objectName;

	TriggerHandler.Events event;

	global DuplicatesHandlingSchedulable(String objectName, TriggerHandler.Events event) {
		this.objectName = objectName;
		this.event = event;
	}

	global void execute(SchedulableContext sc) {
		Database.executeBatch(
			new DuplicatesHandlingNoIteratorBatch(
				this.objectName, 
				this.event
			), 
			Test.isRunningTest() ? 10 : 1
		);
	}

}
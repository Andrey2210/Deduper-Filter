trigger OrderDuplicate on Order (before insert, before update, after insert, after update) {

	Deduper_Custom_Settings__c globalSettings = Deduper_Custom_Settings__c.getInstance();

	if (!TriggerHandler.isEnabled || (!globalSettings.Fire_Auto_Merge__c && !globalSettings.Fire_Triggers__c)) {
		return;
	}

	if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
		if (Trigger.new.size() > 1) {
			for (Order iterOrder : Trigger.new) {
				iterOrder.RequiresDupCheck__c = true;
			}
		}
	}
	else if (Trigger.isAfter && Trigger.isInsert) {
		if (Trigger.new.size() > 1) {
			if (!TriggerHandler.isScheduled) {
				Utils.scheduleJob(Schema.sObjectType.Order.Name, TriggerHandler.Events.AFTER_INSERT);
			}

			/*
			 * Architecture without schedulables
			 */
			/*List<Order> listToDelete = new List<Order>();
			for (Order newOrder : Trigger.new) {
				listToDelete.add(newOrder.clone(true, true));
			}
			delete listToDelete;
			Database.executeBatch(new DuplicatesHandlingBatch(Trigger.new, null, Schema.sObjectType.Order.Name, TriggerHandler.Events.AFTER_INSERT), Test.isRunningTest() ? 10 : 1);
			//System.enqueueJob(new ObjectDuplicateQueueable(Trigger.new, null, Schema.sObjectType.Account.Name, TriggerHandler.Events.AFTER_INSERT));*/
		}
		else {
			new TriggerHandler().bind(
				TriggerHandler.Events.AFTER_INSERT, new TriggerHandlerObjectDuplicate(Schema.sObjectType.Order.Name)
			).manage();
		}
	}
	else if (Trigger.isAfter && Trigger.isUpdate) {
		if (Trigger.new.size() > 1) {
			if (!TriggerHandler.isScheduled) {
				Utils.scheduleJob(Schema.sObjectType.Order.Name, TriggerHandler.Events.AFTER_UPDATE);
			}

			/*
			 * Architecture without schedulables
			 */
			/*List<Order> listToDelete = new List<Order>();
			for (Order newOrder : Trigger.new) {
				listToDelete.add(newOrder.clone(true, true));
			}
			delete listToDelete;
			Database.executeBatch(new DuplicatesHandlingBatch(Trigger.new, Trigger.old, Schema.sObjectType.Order.Name, TriggerHandler.Events.AFTER_UPDATE), Test.isRunningTest() ? 10 : 1);
			//System.enqueueJob(new ObjectDuplicateQueueable(Trigger.new, Trigger.old, Schema.sObjectType.Account.Name, TriggerHandler.Events.AFTER_UPDATE));*/
		}
		else {
			new TriggerHandler().bind(
				TriggerHandler.Events.AFTER_UPDATE, new TriggerHandlerObjectDuplicate(Schema.sObjectType.Order.Name)
			).manage();
		}
	}

}
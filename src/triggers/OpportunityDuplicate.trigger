trigger OpportunityDuplicate on Opportunity (before insert, before update, after insert, after update) {

	Deduper_Custom_Settings__c globalSettings = Deduper_Custom_Settings__c.getInstance();

	if (!TriggerHandler.isEnabled || (!globalSettings.Fire_Auto_Merge__c && !globalSettings.Fire_Triggers__c)) {
		return;
	}

	if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
		if (Trigger.new.size() > 1) {
			for (Opportunity iterOpportunity : Trigger.new) {
				iterOpportunity.RequiresDupCheck__c = true;
			}
		}
	}
	else if (Trigger.isAfter && Trigger.isInsert) {
		if (Trigger.new.size() > 1) {
			if (!TriggerHandler.isScheduled) {
				Utils.scheduleJob(Schema.sObjectType.Opportunity.Name, TriggerHandler.Events.AFTER_INSERT);
			}

			/*
			 * Architecture without schedulables
			 */
			/*List<Opportunity> listToDelete = new List<Opportunity>();
			for (Opportunity newOpp : Trigger.new) {
				listToDelete.add(newOpp.clone(true, true));
			}
			delete listToDelete;
			Database.executeBatch(new DuplicatesHandlingBatch(Trigger.new, null, Schema.sObjectType.Opportunity.Name, TriggerHandler.Events.AFTER_INSERT), Test.isRunningTest() ? 10 : 1);
			//System.enqueueJob(new ObjectDuplicateQueueable(Trigger.new, null, Schema.sObjectType.Account.Name, TriggerHandler.Events.AFTER_INSERT));*/
		}
		else {
			new TriggerHandler().bind(
				TriggerHandler.Events.AFTER_INSERT, new TriggerHandlerObjectDuplicate(Schema.sObjectType.Opportunity.Name)
			).manage();
		}
	}
	else if (Trigger.isAfter && Trigger.isUpdate) {
		if (Trigger.new.size() > 1) {
			if (!TriggerHandler.isScheduled) {
				Utils.scheduleJob(Schema.sObjectType.Opportunity.Name, TriggerHandler.Events.AFTER_UPDATE);
			}

			/*
			 * Architecture without schedulables
			 */
			/*List<Opportunity> listToDelete = new List<Opportunity>();
			for (Opportunity newOpp : Trigger.new) {
				listToDelete.add(newOpp.clone(true, true));
			}
			delete listToDelete;
			Database.executeBatch(new DuplicatesHandlingBatch(Trigger.new, Trigger.old, Schema.sObjectType.Opportunity.Name, TriggerHandler.Events.AFTER_UPDATE), Test.isRunningTest() ? 10 : 1);
			//System.enqueueJob(new ObjectDuplicateQueueable(Trigger.new, Trigger.old, Schema.sObjectType.Account.Name, TriggerHandler.Events.AFTER_UPDATE));*/
		}
		else {
			new TriggerHandler().bind(
				TriggerHandler.Events.AFTER_UPDATE, new TriggerHandlerObjectDuplicate(Schema.sObjectType.Opportunity.Name)
			).manage();
		}
	}

}
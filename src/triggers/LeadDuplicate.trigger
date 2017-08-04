trigger LeadDuplicate on Lead (before insert, before update, after insert, after update) {

	Deduper_Custom_Settings__c globalSettings = Deduper_Custom_Settings__c.getInstance();

	if (!TriggerHandler.isEnabled || (!globalSettings.Fire_Auto_Merge__c && !globalSettings.Fire_Triggers__c)) {
		return;
	}

	List<Lead> newLeads = new List<Lead>(Trigger.new);

	Boolean isConverted = false;
	if (!newLeads.isEmpty()) {
		isConverted = newLeads.get(0).isConverted;
	}

	if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate) && !isConverted) {
		if (Trigger.new.size() > 1) {
			for (Lead iterLead : Trigger.new) {
				iterLead.RequiresDupCheck__c = true;
			}
		}
	}
	else if (Trigger.isAfter && Trigger.isInsert && !isConverted) {
		if (Trigger.new.size() > 1) {
			if (!TriggerHandler.isScheduled) {
				Utils.scheduleJob(Schema.sObjectType.Lead.Name, TriggerHandler.Events.AFTER_INSERT);
			}

			/*
			 * Architecture without schedulables
			 */
			/*List<Lead> listToDelete = new List<Lead>();
			for (Lead newLead : Trigger.new) {
				listToDelete.add(newLead.clone(true, true));
			}
			delete listToDelete;
			Database.executeBatch(new DuplicatesHandlingBatch(Trigger.new, null, Schema.sObjectType.Lead.Name, TriggerHandler.Events.AFTER_INSERT), Test.isRunningTest() ? 10 : 1);
			//System.enqueueJob(new ObjectDuplicateQueueable(Trigger.new, null, Schema.sObjectType.Account.Name, TriggerHandler.Events.AFTER_INSERT));*/
		}
		else {
			new TriggerHandler().bind(
				TriggerHandler.Events.AFTER_INSERT, new TriggerHandlerObjectDuplicate(Schema.sObjectType.Lead.Name)
			).manage();
		}
	}
	else if (Trigger.isAfter && Trigger.isUpdate && !isConverted) {
		if (Trigger.new.size() > 1) {
			if (!TriggerHandler.isScheduled) {
				Utils.scheduleJob(Schema.sObjectType.Lead.Name, TriggerHandler.Events.AFTER_UPDATE);
			}

			/*
			 * Architecture without schedulables
			 */
			/*List<Lead> listToDelete = new List<Lead>();
			for (Lead newLead : Trigger.new) {
				listToDelete.add(newLead.clone(true, true));
			}
			delete listToDelete;
			Database.executeBatch(new DuplicatesHandlingBatch(Trigger.new, Trigger.old, Schema.sObjectType.Lead.Name, TriggerHandler.Events.AFTER_UPDATE), Test.isRunningTest() ? 10 : 1);
			//System.enqueueJob(new ObjectDuplicateQueueable(Trigger.new, Trigger.old, Schema.sObjectType.Account.Name, TriggerHandler.Events.AFTER_UPDATE));*/
		}
		else {
			new TriggerHandler().bind(
				TriggerHandler.Events.AFTER_UPDATE, new TriggerHandlerObjectDuplicate(Schema.sObjectType.Lead.Name)
			).manage();
		}
	}

}
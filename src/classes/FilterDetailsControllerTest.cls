@isTest
private class FilterDetailsControllerTest {

	@isTest static void test_loadFilter() {
		
		Filter__c filter = new Filter__c();
		filter.SourceObjectType__c = 'Opportunity';
		filter.TargetObjectType__c = 'Opportunity';
		filter.Priority__c = 1;
		insert filter;

		PageReference currPage = Page.FilterDetails;
		currPage.getParameters().put('Filter', filter.Id);
		Test.setCurrentPage(currPage);

		FilterDetailsController controller = new FilterDetailsController();
		controller.priority = 1;
		System.assertEquals(filter.Id, controller.filter.Id);
		System.assertEquals(filter.SourceObjectType__c, controller.selectedSourceObjectType);
		System.assertEquals(filter.TargetObjectType__c, controller.selectedtargetObjectType);
	}
	@isTest static void test_optionsMatchOnInsert() {
		Filter__c filter = new Filter__c();
		filter.SourceObjectType__c = 'Opportunity';
		filter.TargetObjectType__c = 'Opportunity';
		filter.Priority__c = 1;
		insert filter;

		PageReference currPage = Page.FilterDetails;
		currPage.getParameters().put('Filter', filter.Id);
		Test.setCurrentPage(currPage);

		FilterDetailsController controller = new FilterDetailsController();

		System.assertEquals(filter.Id, controller.filter.Id);
		System.assertEquals(4, controller.optionsMatchOnInsert.size());
	}
	@isTest static void test_optionsMatchOnUpdate() {
		Filter__c filter = new Filter__c();
		filter.SourceObjectType__c = 'Opportunity';
		filter.TargetObjectType__c = 'Opportunity';
		filter.Priority__c = 1;
		insert filter;

		PageReference currPage = Page.FilterDetails;
		currPage.getParameters().put('Filter', filter.Id);
		Test.setCurrentPage(currPage);

		FilterDetailsController controller = new FilterDetailsController();

		System.assertEquals(filter.Id, controller.filter.Id);
		System.assertEquals(3, controller.optionsMatchOnUpdate.size());
	}
	@isTest static void test_targetObjectFields() {
		Filter__c filter = new Filter__c();
		filter.SourceObjectType__c = 'Opportunity';
		filter.TargetObjectType__c = 'Opportunity';
		filter.Priority__c = 1;
		insert filter;

		PageReference currPage = Page.FilterDetails;
		currPage.getParameters().put('Filter', filter.Id);
		Test.setCurrentPage(currPage);

		FilterDetailsController controller = new FilterDetailsController();

		System.assertEquals(filter.Id, controller.filter.Id);
		System.assertNotEquals(0, controller.targetObjectFields.size());
	}
	@isTest static void test_sourceObjectFields() {
		Filter__c filter = new Filter__c();
		filter.SourceObjectType__c = 'Opportunity';
		filter.TargetObjectType__c = 'Opportunity';
		filter.Priority__c = 1;
		insert filter;

		PageReference currPage = Page.FilterDetails;
		currPage.getParameters().put('Filter', filter.Id);
		Test.setCurrentPage(currPage);

		FilterDetailsController controller = new FilterDetailsController();

		System.assertEquals(filter.Id, controller.filter.Id);
		System.assertNotEquals(0, controller.sourceObjectFields.size());
	}
	@isTest static void test_objectFieldNamesDict() {
	}
	@isTest static void test_optionsMachingAproach() {
		Filter__c filter = new Filter__c();
		filter.SourceObjectType__c = 'Opportunity';
		filter.TargetObjectType__c = 'Opportunity';
		filter.Priority__c = 1;
		insert filter;

		PageReference currPage = Page.FilterDetails;
		currPage.getParameters().put('Filter', filter.Id);
		Test.setCurrentPage(currPage);

		FilterDetailsController controller = new FilterDetailsController();

		System.assertEquals(filter.Id, controller.filter.Id);
		System.assertEquals(3, controller.optionsMachingAproach.size());
	}
	@isTest static void test_saveFilter() {
		Filter__c filter = new Filter__c();
		filter.SourceObjectType__c = 'Opportunity';
		filter.TargetObjectType__c = 'Opportunity';
		filter.Priority__c = 1;
		insert filter;

		PageReference currPage = Page.FilterDetails;
		currPage.getParameters().put('Filter', filter.Id);
		Test.setCurrentPage(currPage);

		FilterDetailsController controller = new FilterDetailsController();
		controller.priority = 1;
		controller.selectedSourceObjectType = filter.SourceObjectType__c;
		controller.selectedTargetObjectType = filter.TargetObjectType__c;
		controller.selectedMatchOnInsert = controller.optionsMatchOnInsert.get(2).getLabel();
		controller.selectedMatchOnUpdate= controller.optionsMatchOnUpdate.get(2).getLabel();

		controller.saveFilter();
		controller.loadFilter();

		System.assertEquals(filter.Id, controller.filter.Id);
		System.assertEquals(controller.selectedSourceObjectType, controller.filter.SourceObjectType__c);
		System.assertEquals(controller.selectedTargetObjectType, controller.filter.TargetObjectType__c);
		System.assertEquals(controller.selectedMatchOnInsert, controller.filter.MatchOnInsert__c);
		System.assertEquals(controller.selectedMatchOnUpdate, controller.filter.MatchOnUpdate__c);
	}
	@isTest static void test_showTaskAction() {
		Filter__c filter = new Filter__c();
		filter.SourceObjectType__c = 'Opportunity';
		filter.TargetObjectType__c = 'Opportunity';
		filter.Priority__c = 1;
		insert filter;

		PageReference currPage = Page.FilterDetails;
		currPage.getParameters().put('Filter', filter.Id);
		Test.setCurrentPage(currPage);

		FilterDetailsController controller = new FilterDetailsController();

		System.assertEquals(filter.Id, controller.filter.Id);
		controller.selectedMatchOnUpdate = 'Report Duplicate';
		controller.selectedMatchOnInsert = 'Report Duplicate';
		System.assertEquals(true, controller.showTaskAction);
		controller.selectedMatchOnUpdate = 'Do Not Insert';
		controller.selectedMatchOnInsert = 'Do Not Insert';
		System.assertEquals(false, controller.showTaskAction);
		controller.selectedMatchOnUpdate = 'Do Not Insert';
		controller.selectedMatchOnInsert = 'Report Duplicate';
		System.assertEquals(true, controller.showTaskAction);
		controller.selectedMatchOnUpdate = 'Do Not Insert';
		controller.selectedMatchOnInsert = 'Display Matching Records';
		System.assertEquals(false, controller.showTaskAction);
	}
	@isTest static void test_addRule_saveRules() {
		Filter__c filter = new Filter__c();
		filter.SourceObjectType__c = 'Opportunity';
		filter.TargetObjectType__c = 'Opportunity';
		filter.Priority__c = 1;
		insert filter;

		PageReference currPage = Page.FilterDetails;
		currPage.getParameters().put('Filter', filter.Id);
		Test.setCurrentPage(currPage);

		FilterDetailsController controller = new FilterDetailsController();

		controller.addRule();
		controller.selectedMachingAproach = controller.optionsMachingAproach.get(0).getLabel();
		controller.selectedSourceField = 'Name';
		controller.selectedTargetField = 'Name';
		controller.saveRules();
		controller.loadFilter();

		controller.addRule();
		controller.selectedMachingAproach = controller.optionsMachingAproach.get(1).getLabel();
		controller.selectedSourceField = 'Name';
		controller.selectedTargetField = 'Name';
		controller.saveRules();
		controller.loadFilter();

		controller.addRule();
		controller.selectedMachingAproach = controller.optionsMachingAproach.get(2).getLabel();
		controller.selectedSourceField = 'Name';
		controller.selectedTargetField = 'Name';
		controller.saveRules();
		controller.loadFilter();

		System.assertEquals(3, controller.rules.size());
	}
	@isTest static void test_deleteRule() {
		Filter__c filter = new Filter__c();
		filter.SourceObjectType__c = 'Opportunity';
		filter.TargetObjectType__c = 'Opportunity';
		filter.Priority__c = 1;
		insert filter;

		PageReference currPage = Page.FilterDetails;
		currPage.getParameters().put('Filter', filter.Id);
		Test.setCurrentPage(currPage);

		FilterDetailsController controller = new FilterDetailsController();
		String objId_1 = '';
		controller.addRule();
		controller.selectedMachingAproach = controller.optionsMachingAproach.get(0).getLabel();
		controller.selectedSourceField = 'Name';
		controller.selectedTargetField = 'Name';
		controller.saveRules();
		objId_1 = controller.objectId;
		controller.loadFilter();

		String objId_2 = '';
		controller.addRule();
		controller.selectedMachingAproach = controller.optionsMachingAproach.get(1).getLabel();
		controller.selectedSourceField = 'Name';
		controller.selectedTargetField = 'Name';
		controller.saveRules();
		objId_2 = controller.objectId;
		controller.loadFilter();

		String objId_3 = '';
		controller.addRule();
		controller.selectedMachingAproach = controller.optionsMachingAproach.get(2).getLabel();
		controller.selectedSourceField = 'Name';
		controller.selectedTargetField = 'Name';
		controller.saveRules();
		objId_2 = controller.objectId;
		controller.loadFilter();

		controller.objectId = objId_3;
		controller.deleteRule();

		controller.objectId = objId_2;
		controller.deleteRule();

		controller.objectId = objId_1;
		controller.deleteRule();
	}
	@isTest static void test_editRule() {
		Filter__c filter = new Filter__c();
		filter.SourceObjectType__c = 'Opportunity';
		filter.TargetObjectType__c = 'Opportunity';
		filter.Priority__c = 1;
		insert filter;

		PageReference currPage = Page.FilterDetails;
		currPage.getParameters().put('Filter', filter.Id);
		Test.setCurrentPage(currPage);

		FilterDetailsController controller = new FilterDetailsController();
		controller.addRule();
		controller.selectedMachingAproach = controller.optionsMachingAproach.get(0).getLabel();
		controller.selectedSourceField = 'Name';
		controller.selectedTargetField = 'Name';
		controller.saveRules();
		String objectId = controller.rules.get(0).Id;
		System.assertEquals('', controller.objectId);
		controller.objectId = objectId;

		controller.editRule();
		System.assertEquals(objectId, controller.objectId);
		System.assertEquals(objectId, controller.currentRule.Id);
		controller.saveRules();
		System.assertEquals(1, controller.rules.size());
	}
	@isTest static void test_editMergeRule() {
		Filter__c filter = new Filter__c();
		filter.SourceObjectType__c = 'Opportunity';
		filter.TargetObjectType__c = 'Opportunity';
		filter.Priority__c = 1;
		insert filter;

		PageReference currPage = Page.FilterDetails;
		currPage.getParameters().put('Filter', filter.Id);
		Test.setCurrentPage(currPage);

		FilterDetailsController controller = new FilterDetailsController();
		controller.addMergeRule();
		controller.selectedSourceField = 'Name';
		controller.selectedTargetField = 'Name';
		controller.saveMergeRules();
		String objectId = controller.mergeRules.get(0).Id;
		System.assertEquals('', controller.objectId);
		controller.objectId = objectId;

		controller.editMergeRule();
		controller.saveMergeRules();

		System.assertEquals('', controller.objectId);

	}
	@isTest static void test_cancelRule() {
		Filter__c filter = new Filter__c();
		filter.SourceObjectType__c = 'Opportunity';
		filter.TargetObjectType__c = 'Opportunity';
		filter.Priority__c = 1;
		insert filter;

		PageReference currPage = Page.FilterDetails;
		currPage.getParameters().put('Filter', filter.Id);
		Test.setCurrentPage(currPage);

		FilterDetailsController controller = new FilterDetailsController();
		controller.addRule();
		controller.selectedMachingAproach = controller.optionsMachingAproach.get(0).getLabel();
		controller.selectedSourceField = 'Name';
		controller.selectedTargetField = 'Name';
		controller.saveRules();
		String objectId = controller.rules.get(0).Id;
		System.assertEquals('', controller.objectId);
		controller.objectId = objectId;

		controller.cancelRule();
		System.assertEquals('', controller.objectId);
		System.assertEquals('', controller.selectedSourceField);
		System.assertEquals('', controller.selectedTargetField);
	}
	@isTest static void test_deleteMergeRule() {
		Filter__c filter = new Filter__c();
		filter.SourceObjectType__c = 'Opportunity';
		filter.TargetObjectType__c = 'Opportunity';
		filter.Priority__c = 1;
		insert filter;

		PageReference currPage = Page.FilterDetails;
		currPage.getParameters().put('Filter', filter.Id);
		Test.setCurrentPage(currPage);

		FilterDetailsController controller = new FilterDetailsController();
		
		controller.addMergeRule();
		controller.selectedSourceField = 'Name';
		controller.selectedTargetField = 'Name';
		controller.saveMergeRules();
		controller.loadFilter();

		
		controller.addMergeRule();
		controller.selectedSourceField = 'Name';
		controller.selectedTargetField = 'Name';
		controller.saveMergeRules();
		controller.loadFilter();

		
		controller.addMergeRule();
		controller.selectedSourceField = 'Name';
		controller.selectedTargetField = 'Name';
		controller.saveMergeRules();
		controller.loadFilter();

		String objId_1 = controller.mergeRules.get(0).Id;
		String objId_3 = controller.mergeRules.get(1).Id;
		String objId_2 = controller.mergeRules.get(2).Id;
		controller.objectId = objId_1;
		controller.deleteMergeRule();
		controller.loadFilter();
		System.assertEquals(2, controller.mergeRules.size());

		controller.objectId = objId_2;
		controller.deleteMergeRule();
		controller.loadFilter();
		System.assertEquals(1, controller.mergeRules.size());

		controller.objectId = objId_3;
		controller.deleteMergeRule();
		controller.loadFilter();
		System.assertEquals(0, controller.mergeRules.size());
	}
	@isTest static void test_saveMergeRules_addMergeRule() {
		Filter__c filter = new Filter__c();
		filter.SourceObjectType__c = 'Opportunity';
		filter.TargetObjectType__c = 'Opportunity';
		filter.Priority__c = 1;
		insert filter;

		PageReference currPage = Page.FilterDetails;
		currPage.getParameters().put('Filter', filter.Id);
		Test.setCurrentPage(currPage);

		FilterDetailsController controller = new FilterDetailsController();
		System.assertEquals(0, controller.mergeRules.size());

		controller.addMergeRule();
		controller.selectedSourceField = 'Name';
		controller.selectedTargetField = 'Name';
		controller.saveMergeRules();
		controller.loadFilter();
		System.assertEquals(1, controller.mergeRules.size());

		controller.addMergeRule();
		controller.selectedSourceField = 'Name';
		controller.selectedTargetField ='Name';
		controller.saveMergeRules();
		controller.loadFilter();
		System.assertEquals(2, controller.mergeRules.size());

		controller.addMergeRule();
		controller.selectedSourceField = 'Name';
		controller.selectedTargetField = 'Name';
		controller.saveMergeRules();
		controller.loadFilter();
		System.assertEquals(3, controller.mergeRules.size());
	}

	@isTest static void test_fillOriginalValues() {
		Filter__c filter = new Filter__c();
		filter.SourceObjectType__c = 'Bookings';
		filter.TargetObjectType__c = 'Enquiries';
		filter.Priority__c = 1;
		insert filter;
		FilterDetailsController controller = new FilterDetailsController();
		controller.loadFilter();
		System.assertEquals(0, controller.originalValues.size());
	}
	
	@isTest static void test_changePriority() {
		Filter__c filter1 = new Filter__c();
		filter1.SourceObjectType__c = 'Enquiries';
		filter1.TargetObjectType__c = 'Enquiries';
		filter1.Priority__c = 1;
		
		Filter__c filter2 = new Filter__c();
		filter2.SourceObjectType__c = 'Enquiries';
		filter2.TargetObjectType__c = 'Enquiries';
		filter2.Priority__c = 2;
		
		List <Filter__c> filtList = new List <Filter__c> ();
		filtList.add(filter1);
		filtList.add(filter2);
		insert filtList;

		PageReference pr = Page.FilterDetails;
		pr.getParameters().put('Filter', filter1.Id);

		Test.setCurrentPageReference(pr);

		FilterDetailsController controller = new FilterDetailsController();
		controller.priority = 2;

		controller.saveFilter();
		
		Filter__c filt = [
        	SELECT Priority__c, SourceObjectType__c
        	FROM Filter__c
        	WHERE Id = :filter1.Id
        	LIMIT 1
        ];
       	System.assertEquals(2, filt.Priority__c);
        
        filt = [
        	SELECT Priority__c, SourceObjectType__c
        	FROM Filter__c
        	WHERE Id = :filter2.Id
        	LIMIT 1
        ];
    	System.assertEquals(1, filt.Priority__c);
	}

	@isTest static void test_objectFieldNames() {
		Filter__c filter1 = new Filter__c();
		filter1.SourceObjectType__c = 'Enquiries';
		filter1.TargetObjectType__c = 'Enquiries';
		filter1.Priority__c = 1;

		insert filter1;

		PageReference pr = Page.FilterDetails;
		pr.getParameters().put('Filter', filter1.Id);

		Test.setCurrentPageReference(pr);

		FilterDetailsController controller = new FilterDetailsController();
		Map<String, Map<String, String>> result = FilterDetailsController.objectFieldNamesDict;

		List<SelectOption> options = controller.optionsMatchLogic;

		options = controller.optionsMergeAction;
	}

}
@isTest
private class FiltersControllerTest {

	@isTest static void showTaskActionTest() {
		FiltersController controller = new FiltersController();

		controller.selectedMatchOnInsert = 'Report Duplicate';
		System.assertEquals(true, controller.showTaskAction);
		controller.selectedMatchOnInsert = 'Do Not Update';
		System.assertEquals(false, controller.showTaskAction);
		controller.selectedMatchOnInsert = 'Do Nothing';
		System.assertEquals(false, controller.showTaskAction);
		controller.selectedMatchOnInsert = 'Report Duplicate';
		System.assertEquals(true, controller.showTaskAction);
		controller.selectedMatchOnInsert = 'Do Nothing';
		System.assertEquals(false, controller.showTaskAction);
		controller.selectedMatchOnInsert = 'Do Not Update';
		System.assertEquals(false, controller.showTaskAction);
	}

	@isTest static void optionsMatchOnInsertTest() {

		FiltersController controller = new FiltersController();
		List<SelectOption> options = new List<SelectOption>();
		options = controller.optionsMatchOnInsert;
		System.assertEquals('Do Nothing', options.get(0).getlabel());
		System.assertEquals('Do Not Insert', options.get(1).getlabel());
		System.assertEquals('Display Matching Records', options.get(2).getlabel());
		System.assertEquals('Report Duplicate', options.get(3).getlabel());

	    controller.selectedMatchOnInsert = 'Report Duplicate';
	    System.assertEquals('Report Duplicate', controller.selectedMatchOnInsert);
		controller.selectedMatchOnInsert = 'Do Not Update';
		System.assertEquals('Do Not Update', controller.selectedMatchOnInsert);
		controller.selectedMatchOnInsert = 'Do Nothing';
		System.assertEquals('Do Nothing', controller.selectedMatchOnInsert);
		controller.selectedMatchOnInsert = 'Display Matching Records';
		System.assertEquals('Display Matching Records', controller.selectedMatchOnInsert);
	}

	@isTest static void optionsMatchOnUpdateTest() {

		FiltersController controller = new FiltersController();
		List<SelectOption> options = new List<SelectOption>();
		options = controller.optionsMatchOnUpdate;

		System.assertEquals('Do Nothing', options.get(0).getlabel());
		System.assertEquals('Do Not Update', options.get(1).getlabel());
		System.assertEquals('Report Duplicate', options.get(2).getlabel());


	    controller.selectedMatchOnUpdate = 'Do Nothing';
	    System.assertEquals('Do Nothing', controller.selectedMatchOnUpdate);
		controller.selectedMatchOnUpdate = 'Do Not Update';
		System.assertEquals('Do Not Update', controller.selectedMatchOnUpdate);
		controller.selectedMatchOnUpdate = 'Report Duplicate';
		System.assertEquals('Report Duplicate', controller.selectedMatchOnUpdate);

	}
	@isTest static void getFiltersTest() {
		FiltersController controller = new FiltersController();
		List<Filter__c> filters = new List<Filter__c>();
		controller.sourceObjectType = controller.filterTypes.get(0).getlabel();
		controller.targetObjectType = controller.filterTypes.get(0).getlabel();
		controller.selectedMatchOnInsert = controller.optionsMatchOnInsert.get(0).getlabel();
		controller.selectedMatchOnUpdate = controller.optionsMatchOnUpdate.get(0).getlabel();
		controller.priority = 1;
		filters.add(new Filter__c(
			SourceObjectType__c = controller.sourceObjectType,
            TargetObjectType__c = controller.targetObjectType,
            MatchOnInsert__c = controller.selectedMatchOnInsert,
            MatchOnUpdate__c = controller.selectedMatchOnUpdate
		));
		controller.sourceObjectType = controller.filterTypes.get(0).getlabel();
		controller.targetObjectType = controller.filterTypes.get(1).getlabel();
		controller.selectedMatchOnInsert = controller.optionsMatchOnInsert.get(1).getlabel();
		controller.selectedMatchOnUpdate = controller.optionsMatchOnUpdate.get(1).getlabel();
		controller.priority = 2;
		filters.add(new Filter__c(
			SourceObjectType__c = controller.sourceObjectType,
            TargetObjectType__c = controller.targetObjectType,
            MatchOnInsert__c = controller.selectedMatchOnInsert,
            MatchOnUpdate__c = controller.selectedMatchOnUpdate
		));

		controller.sourceObjectType = controller.filterTypes.get(0).getlabel();
		controller.targetObjectType = controller.filterTypes.get(2).getlabel();
		controller.selectedMatchOnInsert = controller.optionsMatchOnInsert.get(2).getlabel();
		controller.selectedMatchOnUpdate = controller.optionsMatchOnUpdate.get(2).getlabel();
		controller.priority = 3;
		filters.add(new Filter__c(
			SourceObjectType__c = controller.sourceObjectType,
            TargetObjectType__c = controller.targetObjectType,
            MatchOnInsert__c = controller.selectedMatchOnInsert,
            MatchOnUpdate__c = controller.selectedMatchOnUpdate
		));

		upsert filters;

		System.assertEquals(filters.size(), [SELECT Id FROM Filter__c LIMIT 100].size());
		System.assertEquals(filters.size(), controller.filters.size());

		controller.sourceObjectType = controller.filterTypes.get(0).getlabel();
		controller.targetObjectType = controller.filterTypes.get(0).getlabel();
		controller.selectedMatchOnInsert = controller.optionsMatchOnInsert.get(2).getlabel();
		controller.selectedMatchOnUpdate = controller.optionsMatchOnUpdate.get(2).getlabel();
		controller.priority = 4;

		controller.saveFilter();

		System.assertEquals(4, controller.filters.size());
	}
	@isTest static void getFilterTypesTest() {
		FiltersController controller = new FiltersController();
		controller.fillFilterSourceRecordTypes();
		controller.fillFilterTargetRecordTypes();
		controller.getunSelectedValues();
		controller.getSelectedValues();
		List<SelectOption> filterTypes = controller.filterTypes;
		System.assertEquals(5, filterTypes.size());

		System.assertEquals(FiltersController.FILTER_OPPORTUNITY, filterTypes.get(0).getlabel());
		System.assertEquals(FiltersController.FILTER_CONTACT, filterTypes.get(1).getlabel());
		System.assertEquals(FiltersController.FILTER_ACCOUNT, filterTypes.get(2).getlabel());
		System.assertEquals(FiltersController.FILTER_ENQUIRIES, filterTypes.get(3).getlabel());
		System.assertEquals(FiltersController.FILTER_BOOKINGS, filterTypes.get(4).getlabel());

	    System.assertEquals(FiltersController.FILTER_OPPORTUNITY, filterTypes.get(0).getvalue());
		System.assertEquals(FiltersController.FILTER_CONTACT, filterTypes.get(1).getvalue());
		System.assertEquals(FiltersController.FILTER_ACCOUNT, filterTypes.get(2).getvalue());
		System.assertEquals(FiltersController.FILTER_ENQUIRIES, filterTypes.get(3).getvalue());
		System.assertEquals(FiltersController.FILTER_BOOKINGS, filterTypes.get(4).getvalue());
	}
	@isTest static void deleteFilterTest() {
		FiltersController controller = new FiltersController();
		controller.sourceObjectType = controller.filterTypes.get(0).getlabel();
        controller.targetObjectType = controller.filterTypes.get(2).getlabel();
        controller.selectedMatchOnInsert = controller.optionsMatchOnInsert.get(2).getlabel();
        controller.selectedMatchOnUpdate = controller.optionsMatchOnUpdate.get(2).getlabel();
        controller.priority = 1;
        controller.saveFilter();
        controller.objectId = controller.filters.get(0).Id;
		System.assertEquals(1, controller.filters.size());
		controller.deleteFilter();
		System.assertEquals(0, controller.filters.size());
	}

	@isTest static void testRecordTypes() {
		FiltersController controller = new FiltersController();
		controller.sourceObjectType = FiltersController.BOOKINGS;
        controller.targetObjectType = FiltersController.BOOKINGS;
        controller.sourceObjectRecordType = 'Booking';
        controller.targetObjectRecordType = 'Booking';
        controller.selectedMatchOnInsert = controller.optionsMatchOnInsert.get(2).getlabel();
        controller.selectedMatchOnUpdate = controller.optionsMatchOnUpdate.get(2).getlabel();
        controller.priority = 1;
        controller.saveFilter();
        Filter__c filt = [
        	SELECT SourceObjectRecordType__c, TargetObjectRecordType__c
        	FROM Filter__c
        	LIMIT 1
        ];
        
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
}
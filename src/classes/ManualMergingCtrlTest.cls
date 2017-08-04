@isTest
private class ManualMergingCtrlTest {

	private static ManualMergingCtrl controller;

	private static void prepare() {
		Lead testLead = new Lead(
			LastName = 'testLead',
			FirstName = 'testLead',
			Company = 'testLead'
		);
		insert testLead;

		Lead testLeadDup = new Lead(
			LastName = 'testLead',
			FirstName = 'testLead',
			Company = 'testLead'
		);
		insert testLeadDup;

		Filter__c filter = new Filter__c(
			SourceObjectType__c = 'Enquiries',
			TargetObjectType__c = 'Enquiries',
			Active__c = true,
			SearchAllRecords__c = true,
			MatchOnInsert__c = 'Display Matching Records',
			AutoMerge__c = false
		);
		insert filter;

		Filter__c difFilter = new Filter__c(
			SourceObjectType__c = 'Contact',
			TargetObjectType__c = 'Enquiries',
			Active__c = true,
			SearchAllRecords__c = true,
			MatchOnInsert__c = 'Display Matching Records',
			AutoMerge__c = false
		);
		insert difFilter;

		Rule__c rule = new Rule__c(
			Filter__c = filter.Id,
			SourceField__c = 'LastName',
			TargetField__c = 'LastName',
			MatchingApproach__c = 'Exact'
		);
		insert rule;

		Rule__c difRule = new Rule__c(
			Filter__c = difFilter.Id,
			SourceField__c = 'LastName',
			TargetField__c = 'LastName',
			MatchingApproach__c = 'Exact'
		);
		insert difRule;

		Alert__c alert = new Alert__c(
            Filter__c = filter.Id,
            Type__c = filter.SourceObjectType__c + Constants.SLASH_SYMBOL + filter.TargetObjectType__c
        );
        insert alert;

        Alert__c difAlert = new Alert__c(
            Filter__c = difFilter.Id,
            Type__c = filter.SourceObjectType__c + Constants.SLASH_SYMBOL + filter.TargetObjectType__c
        );
        insert difAlert;

        Duplicate__c duplicate = new Duplicate__c(
            Alert__c = alert.Id,
            Id__c = testLead.Id
        );
        insert duplicate;

        Duplicate__c difDuplicate = new Duplicate__c(
            Alert__c = difAlert.Id,
            Id__c = testLead.Id
        );
        insert difDuplicate;
	}

	@isTest static void testInit_OnAlertSuccess() {
		prepare();

		PageReference currentPage = Page.ManualMerging;
		currentPage.getParameters().put(ManualMergingCtrl.ID_PARAM, [SELECT Id FROM Alert__c][0].Id);

		Test.setCurrentPage(currentPage);

		Test.startTest();

		controller = new ManualMergingCtrl();

		Test.stopTest();

		System.assertEquals(null, controller.pageMessage);
	}

	@isTest static void testInit_OnAlertDifSuccess() {
		prepare();

		PageReference currentPage = Page.ManualMerging;
		currentPage.getParameters().put(ManualMergingCtrl.ID_PARAM, [SELECT Id FROM Alert__c][1].Id);

		Test.setCurrentPage(currentPage);

		Test.startTest();

		controller = new ManualMergingCtrl();

		Test.stopTest();

		System.assertEquals(null, controller.pageMessage);
	}

	@isTest static void testInit_OnRecordsSuccess() {
		prepare();

		PageReference currentPage = Page.ManualMerging;
		currentPage.getParameters().put(TriggerHandlerObjectDuplicate.FILTER_ID_URL, [SELECT Id FROM Filter__c][0].Id);
		currentPage.getParameters().put(TriggerHandlerObjectDuplicate.RECORDS_IDS_URL, [SELECT Id FROM Lead][0].Id);

		Test.setCurrentPage(currentPage);

		Test.startTest();

		controller = new ManualMergingCtrl();

		Test.stopTest();

		System.assertEquals(null, controller.pageMessage);
	}

	@isTest static void testInit_OnRecordsDifSuccess() {
		prepare();

		PageReference currentPage = Page.ManualMerging;
		currentPage.getParameters().put(TriggerHandlerObjectDuplicate.FILTER_ID_URL, [SELECT Id FROM Filter__c][1].Id);
		currentPage.getParameters().put(TriggerHandlerObjectDuplicate.RECORDS_IDS_URL, [SELECT Id FROM Lead][0].Id);

		Test.setCurrentPage(currentPage);

		Test.startTest();

		controller = new ManualMergingCtrl();

		Test.stopTest();

		System.assertEquals(null, controller.pageMessage);
	}

	@isTest static void testInit_Fail() {
		prepare();

		Test.startTest();

		controller = new ManualMergingCtrl();

		Test.stopTest();

		System.assertNotEquals(null, controller.pageMessage);
	}

	@isTest static void testActionDecline_Success() {
		prepare();

		PageReference currentPage = Page.ManualMerging;
		currentPage.getParameters().put(ManualMergingCtrl.ID_PARAM, [SELECT Id FROM Alert__c][0].Id);
		currentPage.getParameters().put(ManualMergingCtrl.FIELD_PARAM, 'LastName');
		currentPage.getParameters().put(ManualMergingCtrl.VALUE_PARAM, [SELECT Id FROM Lead][0].Id);
		currentPage.getParameters().put(ManualMergingCtrl.RECORD_ID_PARAM, [SELECT Id FROM Lead][0].Id);

		Test.setCurrentPage(currentPage);

		String exceptionString;

		Test.startTest();

		try {
			controller = new ManualMergingCtrl();
			controller.clearField();
			controller.clearRecord();
			controller.moveField();
			controller.moveRecord();
		}
		catch (Exception exc) {
			exceptionString = exc.getMessage();
		}

		Test.stopTest();

		System.assertEquals(null, exceptionString);

		System.assertNotEquals(null, controller.decline());
	}

	@isTest static void testActionCancel_Success() {
		prepare();

		PageReference currentPage = Page.ManualMerging;
		currentPage.getParameters().put(ManualMergingCtrl.ID_PARAM, [SELECT Id FROM Alert__c][0].Id);
		currentPage.getParameters().put(ManualMergingCtrl.FIELD_PARAM, 'LastName');
		currentPage.getParameters().put(ManualMergingCtrl.VALUE_PARAM, [SELECT Id FROM Lead][0].Id);
		currentPage.getParameters().put(ManualMergingCtrl.RECORD_ID_PARAM, [SELECT Id FROM Lead][0].Id);

		Test.setCurrentPage(currentPage);

		String exceptionString;

		Test.startTest();

		try {
			controller = new ManualMergingCtrl();
			controller.clearField();
			controller.clearRecord();
			controller.moveField();
			controller.moveRecord();
		}
		catch (Exception exc) {
			exceptionString = exc.getMessage();
		}

		Test.stopTest();

		System.assertEquals(null, exceptionString);

		System.assertNotEquals(null, controller.cancel());
	}

	@isTest static void testActionComplete_Success() {
		prepare();

		PageReference currentPage = Page.ManualMerging;
		currentPage.getParameters().put(ManualMergingCtrl.ID_PARAM, [SELECT Id FROM Alert__c][0].Id);
		currentPage.getParameters().put(ManualMergingCtrl.RECORD_ID_PARAM, [SELECT Id FROM Lead][0].Id);

		Test.setCurrentPage(currentPage);

		String exceptionString;

		Test.startTest();

		try {
			controller = new ManualMergingCtrl();
			controller.moveRecord();
		}
		catch (Exception exc) {
			exceptionString = exc.getMessage();
		}

		Test.stopTest();

		System.assertEquals(null, exceptionString);

		System.assertNotEquals(null, controller.complete());
	}

	@isTest static void testActionGoHome_Success() {
		prepare();

		PageReference currentPage = Page.ManualMerging;
		currentPage.getParameters().put(ManualMergingCtrl.ID_PARAM, [SELECT Id FROM Alert__c][0].Id);
		currentPage.getParameters().put(ManualMergingCtrl.FIELD_PARAM, 'LastName');
		currentPage.getParameters().put(ManualMergingCtrl.VALUE_PARAM, [SELECT Id FROM Lead][0].Id);
		currentPage.getParameters().put(ManualMergingCtrl.RECORD_ID_PARAM, [SELECT Id FROM Lead][0].Id);

		Test.setCurrentPage(currentPage);

		String exceptionString;

		Test.startTest();

		try {
			controller = new ManualMergingCtrl();
			controller.clearField();
			controller.clearRecord();
			controller.moveField();
			controller.moveRecord();
		}
		catch (Exception exc) {
			exceptionString = exc.getMessage();
		}

		Test.stopTest();

		System.assertEquals(null, exceptionString);

		System.assertNotEquals(null, controller.goToHome());
	}

}
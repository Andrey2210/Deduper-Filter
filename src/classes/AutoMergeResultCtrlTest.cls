@isTest
public class AutoMergeResultCtrlTest {

	private static AutoMergeResultCtrl controller;

	private static void prepare() {
		Lead testLead = new Lead(
			LastName = 'testLead',
			FirstName = 'testLead',
			Company = 'testLead'
		);
		insert testLead;

		Filter__c filter = new Filter__c(
			SourceObjectType__c = 'Enquiries',
			TargetObjectType__c = 'Enquiries',
			Active__c = true,
			SearchAllRecords__c = true,
			MatchOnInsert__c = 'Display Matching Records',
			AutoMerge__c = false
		);
		insert filter;

		AutoMergeResult__c result = new AutoMergeResult__c(
			ResultId__c = testLead.Id,
			UserId__c = UserInfo.getUserId(),
			Filter__c = filter.Id
		);
		insert result;
	}

	@isTest static void testInit_Success() {
		prepare();

		Lead testLead = new Lead(
			LastName = 'testLead',
			FirstName = 'testLead',
			Company = 'testLead'
		);
		insert testLead;

		delete testLead;

		PageReference currentPage = Page.AutoMergeResult;
		currentPage.getParameters().put(AutoMergeResultCtrl.NEW_ID_URL_PARAM, testLead.Id);

		Test.setCurrentPage(currentPage);

		Test.startTest();

		controller = new AutoMergeResultCtrl();

		Test.stopTest();

		System.assertEquals(true, controller.wasMerged);
	}

	@isTest static void testInit_FailNoUrl() {
		prepare();

		PageReference currentPage = Page.AutoMergeResult;

		Test.setCurrentPage(currentPage);

		Test.startTest();

		controller = new AutoMergeResultCtrl();

		Test.stopTest();

		System.assertEquals(false, controller.wasMerged);
	}

	@isTest static void testInit_FailNoPrepare() {
		PageReference currentPage = Page.AutoMergeResult;

		Test.setCurrentPage(currentPage);

		Test.startTest();

		controller = new AutoMergeResultCtrl();

		Test.stopTest();

		System.assertEquals(false, controller.wasMerged);
	}

}
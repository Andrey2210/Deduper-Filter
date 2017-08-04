@isTest
private class TriggerHandlerTest {

	private static void prepare() {
		Deduper_Custom_Settings__c globalSetting = new Deduper_Custom_Settings__c(
			SetupOwnerId = UserInfo.getProfileId(),
			Fire_Triggers__c = true,
			Fire_Auto_Merge__c = true,
			Schedule_Delay__c = 5
		);
		insert globalSetting;

		Lead testLead = new Lead(
			LastName = 'testLead',
			FirstName = 'testLead',
			Company = 'testLead'
		);
		insert testLead;

		Account testAccount = new Account(
			Name = 'testAccount testWord testWord'
		);
		insert testAccount;

		Opportunity testOpportunity = new Opportunity(
			Name = 'testOpportunity',
			StageName = 'Pending',
			CloseDate = Date.today() + 1
		);
		insert testOpportunity;

		Contact testContact = new Contact(
			LastName = 'testContact'
		);
		insert testContact;

		Order testOrder = new Order(
			Name = 'testOrder testWord testWord',
			AccountId = testAccount.Id,
			//Booking_Reference__c = '12345678',
			//Arrival_Date__c = Date.today(),
			EffectiveDate = Date.today(),
			Status = 'Draft'
		);
		insert testOrder;
	}

	@isTest static void testOpportunity_ExactMatchOnInsert() {
		prepare();

		Filter__c filter = new Filter__c(
			CreateNewDataTask__c = false,
			SourceObjectType__c = 'Opportunity',
			TargetObjectType__c = 'Opportunity',
			Active__c = true,
			SearchAllRecords__c = false,
			MatchOnInsert__c = 'Do Not Insert',
			AutoMerge__c = false
		);
		insert filter;

		Rule__c rule = new Rule__c(
			Filter__c = filter.Id,
			SourceField__c = 'Name',
			TargetField__c = 'Name',
			MatchingApproach__c = 'Exact'
		);
		insert rule;

		Test.startTest();

		try {
			insert new Opportunity(
				Name = 'testOpportunity',
				StageName = 'Pending',
				CloseDate = Date.today() + 1,
				Override__c = false
			);
		}
		catch (DmlException exc) {
			//silence
		}

		Test.stopTest();

		System.assert([SELECT Id FROM Opportunity].size() == 1);
	}

	@isTest static void testOpportunity_ExactMisMatchOnInsertAmount() {
		prepare();

		Filter__c filter = new Filter__c(
			CreateNewDataTask__c = false,
			SourceObjectType__c = 'Opportunity',
			TargetObjectType__c = 'Opportunity',
			Active__c = true,
			SearchAllRecords__c = false,
			MatchOnInsert__c = 'Do Not Insert',
			AutoMerge__c = false
		);
		insert filter;

		Rule__c rule = new Rule__c(
			Filter__c = filter.Id,
			SourceField__c = 'Amount',
			TargetField__c = 'Amount',
			MatchingApproach__c = 'Exact'
		);
		insert rule;

		Test.startTest();

		try {
			insert new Opportunity(
				Name = 'testOpportunity',
				StageName = 'Pending',
				Amount = 12,
				CloseDate = Date.today() + 1,
				Override__c = false
			);
		}
		catch (DmlException exc) {
			//silence
		}

		Test.stopTest();

		System.assert([SELECT Id FROM Opportunity].size() == 2);
	}

	@isTest static void testOpportunity_ExactMisMatchBlanksOnInsertAmount() {
		prepare();

		Filter__c filter = new Filter__c(
			CreateNewDataTask__c = false,
			SourceObjectType__c = 'Opportunity',
			TargetObjectType__c = 'Opportunity',
			Active__c = true,
			SearchAllRecords__c = false,
			MatchOnInsert__c = 'Do Not Insert',
			AutoMerge__c = false
		);
		insert filter;

		Rule__c rule = new Rule__c(
			Filter__c = filter.Id,
			SourceField__c = 'Amount',
			TargetField__c = 'Amount',
			MatchingApproach__c = 'Exact',
			MatchBlanks__c = true
		);
		insert rule;

		Test.startTest();

		try {
			insert new Opportunity(
				Name = 'testOpportunity',
				StageName = 'Pending',
				Amount = null,
				CloseDate = Date.today() + 1,
				Override__c = false
			);
		}
		catch (DmlException exc) {
			//silence
		}

		Test.stopTest();

		System.assert([SELECT Id FROM Opportunity].size() == 1);
	}

	@isTest static void testOpportunity_ExactMatchOnInsertDisplayRecords() {
		prepare();

		Filter__c filter = new Filter__c(
			CreateNewDataTask__c = false,
			SourceObjectType__c = 'Opportunity',
			TargetObjectType__c = 'Opportunity',
			Active__c = true,
			SearchAllRecords__c = false,
			MatchOnInsert__c = 'Display Matching Records',
			AutoMerge__c = false
		);
		insert filter;

		Rule__c rule = new Rule__c(
			Filter__c = filter.Id,
			SourceField__c = 'Name',
			TargetField__c = 'Name',
			MatchingApproach__c = 'Exact'
		);
		insert rule;

		Test.startTest();

		try {
			insert new Opportunity(
				Name = 'testOpportunity',
				StageName = 'Pending',
				CloseDate = Date.today() + 1,
				Override__c = false
			);
		}
		catch (DmlException exc) {
			//silence
		}

		Test.stopTest();

		System.assert([SELECT Id FROM Opportunity].size() == 1);
	}

	@isTest static void testOpportunity_ExactMatchOnUpdate() {
		prepare();

		Filter__c filter = new Filter__c(
			CreateNewDataTask__c = false,
			SourceObjectType__c = 'Opportunity',
			TargetObjectType__c = 'Opportunity',
			Active__c = true,
			SearchAllRecords__c = false,
			MatchOnUpdate__c = 'Report Duplicate',
			CreateTasks__c = 'Yes - User',
			AutoMerge__c = false
		);
		insert filter;

		Rule__c rule = new Rule__c(
			Filter__c = filter.Id,
			SourceField__c = 'Name',
			TargetField__c = 'Name',
			MatchingApproach__c = 'Exact'
		);
		insert rule;

		Opportunity testOpportunity = new Opportunity(
			Name = 't1estOpportunity',
			StageName = 'Pending',
			CloseDate = Date.today() + 1,
			Override__c = false
		);
		insert testOpportunity;

		Test.startTest();

		testOpportunity.Name = 'testOpportunity';

		update testOpportunity;

		Test.stopTest();

		System.assert([SELECT Id FROM Task].size() == 1);
	}

	@isTest static void testContact_LettersMatchOnInsert() {
		prepare();

		Filter__c filter = new Filter__c(
			CreateNewDataTask__c = false,
			SourceObjectType__c = 'Contact',
			TargetObjectType__c = 'Contact',
			Active__c = true,
			SearchAllRecords__c = true,
			MatchOnInsert__c = 'Report Duplicate',
			CreateTasks__c = 'Yes - Filter Owner',
			AutoMerge__c = false
		);
		insert filter;

		Rule__c rule = new Rule__c(
			Filter__c = filter.Id,
			SourceField__c = 'LastName',
			TargetField__c = 'LastName',
			MatchingApproach__c = 'First N Letters',
			FirstN__c = 3
		);
		insert rule;

		Test.startTest();

		insert new Contact(
			LastName = 'testContact',
			Override__c = false
		);

		Test.stopTest();

		System.assert([SELECT Id FROM Task].size() == 1);
	}

	@isTest static void testAccount_WordsMatchOnInsert() {
		prepare();

		Filter__c filter = new Filter__c(
			CreateNewDataTask__c = false,
			SourceObjectType__c = 'Account',
			TargetObjectType__c = 'Account',
			Active__c = true,
			SearchAllRecords__c = true,
			MatchOnInsert__c = 'Do Not Insert',
			AutoMerge__c = false
		);
		insert filter;

		Rule__c rule = new Rule__c(
			Filter__c = filter.Id,
			SourceField__c = 'Name',
			TargetField__c = 'Name',
			MatchingApproach__c = 'First N Words',
			FirstN__c = 2
		);
		insert rule;

		Test.startTest();

		try {
			insert new Account(
				Name = 'testAccount testWord testWordMisMatch',
				Override__c = false
			);
		}
		catch (DmlException exc) {
			//silence
		}

		Test.stopTest();

		System.assert([SELECT Id FROM Account].size() == 1);
	}

	@isTest static void testAccountLead_WordsMatchOnInsert() {
		prepare();

		Filter__c filter = new Filter__c(
			CreateNewDataTask__c = false,
			SourceObjectType__c = 'Account',
			TargetObjectType__c = 'Enquiries',
			Active__c = true,
			SearchAllRecords__c = true,
			MatchOnInsert__c = 'Do Not Insert',
			AutoMerge__c = false
		);
		insert filter;

		Rule__c rule = new Rule__c(
			Filter__c = filter.Id,
			SourceField__c = 'Name',
			TargetField__c = 'Name',
			MatchingApproach__c = 'First N Words',
			FirstN__c = 2
		);
		insert rule;

		Lead testLead = new Lead(
			LastName = 'testAccount testWord testWordMisMatch',
			Company = 'testLead',
			Override__c = false
		);
		insert testLead;

		Test.startTest();

		try {
			insert new Account(
				Name = 'testAccount testWord testWordMisMatch',
				Override__c = false
			);
		}
		catch (DmlException exc) {
			//silence
		}

		Test.stopTest();

		System.assert([SELECT Id FROM Account].size() == 1);
	}

	@isTest static void testLead_LettersMismatchOnInsert() {
		prepare();

		Filter__c filter = new Filter__c(
			CreateNewDataTask__c = false,
			SourceObjectType__c = 'Enquiries',
			TargetObjectType__c = 'Enquiries',
			Active__c = true,
			SearchAllRecords__c = true,
			MatchOnInsert__c = 'Do Not Insert',
			AutoMerge__c = false
		);
		insert filter;

		Rule__c rule = new Rule__c(
			Filter__c = filter.Id,
			SourceField__c = 'LastName',
			TargetField__c = 'LastName',
			MatchingApproach__c = 'First N Letters',
			FirstN__c = 3
		);
		insert rule;

		Test.startTest();

		insert new Lead(
			LastName = 't1estLead',
			Company = 'testLead',
			Override__c = false
		);

		Test.stopTest();

		System.assert([SELECT Id FROM Lead].size() == 2);
	}

	@isTest static void testOrder_WordsMismatchOnInsert() {
		prepare();

		Filter__c filter = new Filter__c(
			CreateNewDataTask__c = false,
			SourceObjectType__c = 'Bookings',
			TargetObjectType__c = 'Bookings',
			Active__c = true,
			SearchAllRecords__c = true,
			MatchOnInsert__c = 'Do Not Insert',
			AutoMerge__c = false
		);
		insert filter;

		Rule__c rule = new Rule__c(
			Filter__c = filter.Id,
			SourceField__c = 'Name',
			TargetField__c = 'Name',
			MatchingApproach__c = 'First N Words',
			FirstN__c = 3
		);
		insert rule;

		Test.startTest();

		insert new Order(
			Name = 'testOrder testWord t1estWord',
			AccountId = [SELECT Id FROM Account LIMIT 1].Id,
			//Booking_Reference__c = '12345679',
			//Arrival_Date__c = Date.today(),
			EffectiveDate = Date.today(),
			Status = 'Draft',
			Override__c = false
		);

		Test.stopTest();

		System.assert([SELECT Id FROM Order].size() == 2);
	}

	@isTest static void testLead_AutoMergeOnInsert() {
		prepare();

		insert new Lead(
			LastName = 'testLead',
			FirstName = 'testLead',
			Company = 'null',
			Override__c = false
		);

		insert new Lead(
			LastName = 'testLead',
			FirstName = null,
			Company = 'null',
			Override__c = false
		);

		Filter__c filter = new Filter__c(
			CreateNewDataTask__c = false,
			SourceObjectType__c = 'Enquiries',
			TargetObjectType__c = 'Enquiries',
			Active__c = true,
			SearchAllRecords__c = true,
			AutoMerge__c = true
		);
		insert filter;

		Rule__c rule = new Rule__c(
			Filter__c = filter.Id,
			SourceField__c = 'LastName',
			TargetField__c = 'LastName',
			MatchingApproach__c = 'First N Letters',
			FirstN__c = 3
		);
		insert rule;

		MergeRule__c mergeRuleLastName = new MergeRule__c(
			Filter__c = filter.Id,
			SourceField__c = 'LastName',
			TargetField__c = 'LastName',
			MergeAction__c = 'replace',
			MergeBlanks__c = false
		);
		insert mergeRuleLastName;

		MergeRule__c mergeRuleFirstName = new MergeRule__c(
			Filter__c = filter.Id,
			SourceField__c = 'FirstName',
			TargetField__c = 'FirstName',
			MergeAction__c = 'replace',
			MergeBlanks__c = false
		);
		insert mergeRuleFirstName;

		MergeRule__c mergeRuleCompany = new MergeRule__c(
			Filter__c = filter.Id,
			SourceField__c = 'Company',
			TargetField__c = 'Company',
			MergeAction__c = 'replace',
			MergeBlanks__c = false
		);
		insert mergeRuleCompany;

		Test.startTest();

		insert new Lead(
			LastName = 'testLead',
			FirstName = 'testLead',
			Company = 'testLead',
			Override__c = false
		);

		Test.stopTest();

		System.assert([SELECT Id FROM Lead].size() == 1);

		Lead resultLead = [
			SELECT LastName, FirstName, Company
			FROM Lead
			LIMIT 1
		];
		System.assertEquals('testLead', resultLead.FirstName);
		System.assertEquals('testLead', resultLead.Company);
	}

	@isTest static void testLead_AutoMergeOnInsertOnlyForBlanks() {
		prepare();

		insert new Lead(
			LastName = 'testLead',
			FirstName = 'testLead',
			Company = 'testLead',
			Override__c = false
		);
		insert new Lead(
			LastName = 'testLead',
			FirstName = null,
			Company = 'testLead',
			Override__c = false
		);

		Filter__c filter = new Filter__c(
			CreateNewDataTask__c = false,
			SourceObjectType__c = 'Enquiries',
			TargetObjectType__c = 'Enquiries',
			Active__c = true,
			SearchAllRecords__c = true,
			AutoMerge__c = true
		);
		insert filter;

		Rule__c rule = new Rule__c(
			Filter__c = filter.Id,
			SourceField__c = 'LastName',
			TargetField__c = 'LastName',
			MatchingApproach__c = 'First N Letters',
			FirstN__c = 3
		);
		insert rule;

		MergeRule__c mergeRuleLastName = new MergeRule__c(
			Filter__c = filter.Id,
			SourceField__c = 'LastName',
			TargetField__c = 'LastName',
			MergeAction__c = 'replace'
		);
		insert mergeRuleLastName;

		MergeRule__c mergeRuleFirstName = new MergeRule__c(
			Filter__c = filter.Id,
			SourceField__c = 'FirstName',
			TargetField__c = 'FirstName',
			MergeBlanks__c = false,
			MergeAction__c = 'replace'
		);
		insert mergeRuleFirstName;

		MergeRule__c mergeRuleCompany = new MergeRule__c(
			Filter__c = filter.Id,
			SourceField__c = 'Company',
			TargetField__c = 'Company',
			MergeBlanks__c = true,
			MergeAction__c = 'replace'
		);
		insert mergeRuleCompany;

		Test.startTest();

		insert new Lead(
			LastName = 'testLead',
			FirstName = 'allowedMerge',
			Company = 'notAllowedMerge',
			Override__c = false
		);

		Test.stopTest();

		System.assert([SELECT Id FROM Lead].size() == 1);

		Lead resultLead = [
			SELECT LastName, FirstName, Company
			FROM Lead
			LIMIT 1
		];
		System.assertEquals('allowedMerge', resultLead.FirstName);
		System.assertEquals('notAllowedMerge', resultLead.Company);
	}

	@isTest static void testLead_FilterPriorityExecution() {
		prepare();

		Filter__c filter = new Filter__c(
			CreateNewDataTask__c = false,
			SourceObjectType__c = 'Enquiries',
			TargetObjectType__c = 'Enquiries',
			Active__c = true,
			SearchAllRecords__c = true,
			MatchOnInsert__c = 'Do Not Insert',
			AutoMerge__c = true,
			Priority__c = 2
		);
		insert filter;

		Rule__c rule = new Rule__c(
			Filter__c = filter.Id,
			SourceField__c = 'LastName',
			TargetField__c = 'LastName',
			MatchingApproach__c = 'Exact'
		);
		insert rule;

		MergeRule__c mergeRule = new MergeRule__c(
			Filter__c = filter.Id,
			SourceField__c = 'FirstName',
			TargetField__c = 'FirstName',
			MergeBlanks__c = false,
			MergeAction__c = 'replace'
		);
		insert mergeRule;

		/*
		 * Pay attention to priority
		 */
		Filter__c filter2 = new Filter__c(
			CreateNewDataTask__c = false,
			SourceObjectType__c = 'Enquiries',
			TargetObjectType__c = 'Enquiries',
			Active__c = true,
			SearchAllRecords__c = true,
			MatchOnInsert__c = 'Do Not Insert',
			AutoMerge__c = true,
			Priority__c = 1
		);
		insert filter2;

		Rule__c rule2 = new Rule__c(
			Filter__c = filter2.Id,
			SourceField__c = 'FirstName',
			TargetField__c = 'FirstName',
			MatchingApproach__c = 'Exact'
		);
		insert rule2;

		MergeRule__c mergeRule2 = new MergeRule__c(
			Filter__c = filter2.Id,
			SourceField__c = 'Company',
			TargetField__c = 'Company',
			MergeBlanks__c = false,
			MergeAction__c = 'replace'
		);
		insert mergeRule2;

		Test.startTest();

		insert new Lead(
			LastName = 'testLead',
			FirstName = 'testLead',
			Company = 'latestCompany',
			Override__c = false
		);

		Test.stopTest();

		System.assert([SELECT Company FROM Lead].get(0).Company == 'latestCompany');
	}

	@isTest static void testLead_FilterInversePriorityExecution() {
		prepare();

		Filter__c filter = new Filter__c(
			CreateNewDataTask__c = false,
			SourceObjectType__c = 'Enquiries',
			TargetObjectType__c = 'Enquiries',
			Active__c = true,
			SearchAllRecords__c = true,
			MatchOnInsert__c = 'Do Not Insert',
			AutoMerge__c = true,
			Priority__c = 1
		);
		insert filter;

		Rule__c rule = new Rule__c(
			Filter__c = filter.Id,
			SourceField__c = 'LastName',
			TargetField__c = 'LastName',
			MatchingApproach__c = 'Exact'
		);
		insert rule;

		MergeRule__c mergeRule = new MergeRule__c(
			Filter__c = filter.Id,
			SourceField__c = 'FirstName',
			TargetField__c = 'FirstName',
			MergeBlanks__c = false,
			MergeAction__c = 'replace'
		);
		insert mergeRule;

		/*
		 * Pay attention to priority
		 */
		Filter__c filter2 = new Filter__c(
			CreateNewDataTask__c = false,
			SourceObjectType__c = 'Enquiries',
			TargetObjectType__c = 'Enquiries',
			Active__c = true,
			SearchAllRecords__c = true,
			MatchOnInsert__c = 'Do Not Insert',
			AutoMerge__c = true,
			Priority__c = 2
		);
		insert filter2;

		Rule__c rule2 = new Rule__c(
			Filter__c = filter2.Id,
			SourceField__c = 'FirstName',
			TargetField__c = 'FirstName',
			MatchingApproach__c = 'Exact'
		);
		insert rule2;

		MergeRule__c mergeRule2 = new MergeRule__c(
			Filter__c = filter2.Id,
			SourceField__c = 'Company',
			TargetField__c = 'Company',
			MergeBlanks__c = false,
			MergeAction__c = 'replace'
		);
		insert mergeRule2;

		Test.startTest();

		insert new Lead(
			LastName = 'testLead',
			FirstName = 'testLead',
			Company = 'latestCompany',
			Override__c = false
		);

		Test.stopTest();

		System.assert([SELECT Company FROM Lead].get(0).Company == 'testLead');
	}

	@isTest static void testContact_NDaysMatch() {
		prepare();

		Contact testContact = new Contact(
			LastName = 'testContact',
			Birthdate = Date.today(),
			Override__c = false
		);
		insert testContact;

		Filter__c filter = new Filter__c(
			CreateNewDataTask__c = false,
			SourceObjectType__c = 'Contact',
			TargetObjectType__c = 'Contact',
			Active__c = true,
			SearchAllRecords__c = false,
			MatchOnInsert__c = 'Do Not Insert',
			AutoMerge__c = false
		);
		insert filter;

		Rule__c rule = new Rule__c(
			Filter__c = filter.Id,
			SourceField__c = 'Birthdate',
			TargetField__c = 'Birthdate',
			MatchingApproach__c = '+/- N days',
			FirstN__c = 11
		);
		insert rule;

		Test.startTest();

		try {
			insert new Contact(
				LastName = 'testContact',
				Birthdate = Date.today(),
				Override__c = false
			);
		}
		catch (DmlException exc) {
			//silence
		}

		Test.stopTest();

		System.assert([SELECT Id FROM Contact].size() == 2);
	}

	@isTest static void testContact_NDaysTimeMatch() {
		//prepare();

		//Contact testContact = new Contact(
		//	LastName = 'testContact',
		//	Datetime_Field__c = Datetime.now(),
		//	Override__c = false
		//);
		//insert testContact;

		//Filter__c filter = new Filter__c(
		//	CreateNewDataTask__c = false,
		//	SourceObjectType__c = 'Contact',
		//	TargetObjectType__c = 'Contact',
		//	Active__c = true,
		//	SearchAllRecords__c = false,
		//	MatchOnInsert__c = 'Do Not Insert',
		//	AutoMerge__c = false
		//);
		//insert filter;

		//Rule__c rule = new Rule__c(
		//	Filter__c = filter.Id,
		//	SourceField__c = 'Datetime_Field__c',
		//	TargetField__c = 'Datetime_Field__c',
		//	MatchingApproach__c = '+/- N days',
		//	FirstN__c = 11
		//);
		//insert rule;

		//Test.startTest();

		//try {
		//	insert new Contact(
		//		LastName = 'testContact',
		//		Datetime_Field__c = Datetime.now(),
		//		Override__c = false
		//	);
		//}
		//catch (DmlException exc) {
		//	//silence
		//}

		//Test.stopTest();

		//System.assert([SELECT Id FROM Contact].size() == 2);
	}

	@isTest static void testContact_NDaysExactMatch() {
		prepare();

		Contact testContact = new Contact(
			LastName = 'testContact',
			Birthdate = Date.today(),
			Override__c = false
		);
		insert testContact;

		Filter__c filter = new Filter__c(
			CreateNewDataTask__c = false,
			SourceObjectType__c = 'Contact',
			TargetObjectType__c = 'Contact',
			Active__c = true,
			SearchAllRecords__c = false,
			MatchOnInsert__c = 'Do Not Insert',
			AutoMerge__c = false
		);
		insert filter;

		Rule__c rule = new Rule__c(
			Filter__c = filter.Id,
			SourceField__c = 'Birthdate',
			TargetField__c = 'Birthdate',
			MatchingApproach__c = 'Exact'
		);
		insert rule;

		Test.startTest();

		try {
			insert new Contact(
				LastName = 'testContact',
				Birthdate = Date.today(),
				Override__c = false
			);
		}
		catch (DmlException exc) {
			//silence
		}

		Test.stopTest();

		System.assert([SELECT Id FROM Contact].size() == 2);
	}

	@isTest static void testContact_NDaysEmptyMatch() {
		prepare();

		Contact testContact = new Contact(
			LastName = 'testContact',
			Birthdate = null,
			Override__c = false
		);
		insert testContact;

		Filter__c filter = new Filter__c(
			CreateNewDataTask__c = false,
			SourceObjectType__c = 'Contact',
			TargetObjectType__c = 'Contact',
			Active__c = true,
			SearchAllRecords__c = false,
			MatchOnInsert__c = 'Do Not Insert',
			AutoMerge__c = false
		);
		insert filter;

		Rule__c rule = new Rule__c(
			Filter__c = filter.Id,
			SourceField__c = 'Birthdate',
			TargetField__c = 'Birthdate',
			MatchingApproach__c = '+/- N days',
			FirstN__c = 11,
			MatchBlanks__c = true
		);
		insert rule;

		Test.startTest();

		try {
			insert new Contact(
				LastName = 'testContact',
				Birthdate = null,
				Override__c = false
			);
		}
		catch (DmlException exc) {
			//silence
		}

		Test.stopTest();

		System.assert([SELECT Id FROM Contact].size() == 2);
	}

	@isTest static void testContact_NDaysEmptyExactMatch() {
		prepare();

		Contact testContact = new Contact(
			LastName = 'testContact',
			Birthdate = null,
			Override__c = false
		);
		insert testContact;

		Filter__c filter = new Filter__c(
			CreateNewDataTask__c = false,
			SourceObjectType__c = 'Contact',
			TargetObjectType__c = 'Contact',
			Active__c = true,
			SearchAllRecords__c = false,
			MatchOnInsert__c = 'Do Not Insert',
			AutoMerge__c = false
		);
		insert filter;

		Rule__c rule = new Rule__c(
			Filter__c = filter.Id,
			SourceField__c = 'Birthdate',
			TargetField__c = 'Birthdate',
			MatchingApproach__c = 'Exact',
			FirstN__c = 11,
			MatchBlanks__c = true
		);
		insert rule;

		Test.startTest();

		try {
			insert new Contact(
				LastName = 'testContact',
				Birthdate = null,
				Override__c = false
			);
		}
		catch (DmlException exc) {
			//silence
		}

		Test.stopTest();

		System.assert([SELECT Id FROM Contact].size() == 2);
	}

	@isTest static void testLead_AutoMergeOnInsertWithAppending() {
		prepare();

		insert new Lead(
			LastName = 'testLead',
			FirstName = 'testLead',
			Company = 'testLead',
			Override__c = false
		);
		insert new Lead(
			LastName = 'testLead',
			FirstName = 'testLead',
			Company = 'testLead',
			Override__c = false
		);

		Filter__c filter = new Filter__c(
			CreateNewDataTask__c = false,
			SourceObjectType__c = 'Enquiries',
			TargetObjectType__c = 'Enquiries',
			Active__c = true,
			SearchAllRecords__c = true,
			AutoMerge__c = true
		);
		insert filter;

		Rule__c rule = new Rule__c(
			Filter__c = filter.Id,
			SourceField__c = 'LastName',
			TargetField__c = 'LastName',
			MatchingApproach__c = 'First N Letters',
			FirstN__c = 3
		);
		insert rule;

		MergeRule__c mergeRuleLastName = new MergeRule__c(
			Filter__c = filter.Id,
			SourceField__c = 'LastName',
			TargetField__c = 'LastName',
			MergeAction__c = 'append with ","'
		);
		insert mergeRuleLastName;

		MergeRule__c mergeRuleFirstName = new MergeRule__c(
			Filter__c = filter.Id,
			SourceField__c = 'FirstName',
			TargetField__c = 'FirstName',
			MergeAction__c = 'append with space'
		);
		insert mergeRuleFirstName;

		MergeRule__c mergeRuleCompany = new MergeRule__c(
			Filter__c = filter.Id,
			SourceField__c = 'Company',
			TargetField__c = 'Company',
			MergeAction__c = 'append with ";"'
		);
		insert mergeRuleCompany;

		Lead testLead = new Lead(
			LastName = 'testLead',
			FirstName = 'testLead',
			Company = 'testLead',
			Override__c = false
		);

		Test.startTest();

		insert new Lead(
			LastName = 'testLead',
			FirstName = 'testLead',
			Company = 'testLead',
			Override__c = false
		);

		Test.stopTest();

		System.assert([SELECT Id FROM Lead].size() == 1);

		Lead resultLead = [
			SELECT LastName, FirstName, Company
			FROM Lead
			LIMIT 1
		];
		System.assertEquals('testLead testLead', resultLead.FirstName);
		System.assertEquals('testLead;testLead', resultLead.Company); //becuse of created in prepare method Lead
	}

	@isTest static void testLead_AutoMergeOnInsertWithPrepending() {
		prepare();

		new Lead(
			LastName = 'testLead',
			FirstName = 'testLead',
			Company = 'testLead',
			Override__c = false
		);
		new Lead(
			LastName = 'testLead',
			FirstName = null,
			Company = 'testLead',
			Override__c = false
		);

		Filter__c filter = new Filter__c(
			CreateNewDataTask__c = false,
			SourceObjectType__c = 'Enquiries',
			TargetObjectType__c = 'Enquiries',
			Active__c = true,
			SearchAllRecords__c = true,
			AutoMerge__c = true
		);
		insert filter;

		Rule__c rule = new Rule__c(
			Filter__c = filter.Id,
			SourceField__c = 'LastName',
			TargetField__c = 'LastName',
			MatchingApproach__c = 'First N Letters',
			FirstN__c = 3
		);
		insert rule;

		MergeRule__c mergeRuleLastName = new MergeRule__c(
			Filter__c = filter.Id,
			SourceField__c = 'LastName',
			TargetField__c = 'LastName',
			MergeAction__c = 'prepend with space'
		);
		insert mergeRuleLastName;

		MergeRule__c mergeRuleFirstName = new MergeRule__c(
			Filter__c = filter.Id,
			SourceField__c = 'FirstName',
			TargetField__c = 'FirstName',
			MergeAction__c = 'prepend with ","'
		);
		insert mergeRuleFirstName;

		MergeRule__c mergeRuleCompany = new MergeRule__c(
			Filter__c = filter.Id,
			SourceField__c = 'Company',
			TargetField__c = 'Company',
			MergeAction__c = 'prepend with ";"'
		);
		insert mergeRuleCompany;

		Lead testLead = new Lead(
			LastName = 'testLead',
			FirstName = null,
			Company = 'testLead',
			Override__c = false
		);

		Test.startTest();

		insert new Lead(
			LastName = 'testLead',
			FirstName = null,
			Company = 'testLead',
			Override__c = false
		);

		Test.stopTest();

		System.assert([SELECT Id FROM Lead].size() == 1);

		Lead resultLead = [
			SELECT LastName, FirstName, Company
			FROM Lead
			LIMIT 1
		];
		System.assertEquals('testLead', resultLead.FirstName);
		System.assertEquals('testLead;testLead', resultLead.Company);
	}

	@isTest static void testLead_CreatingTaskOnInsert() {
		Deduper_Custom_Settings__c globalSetting = new Deduper_Custom_Settings__c(
			SetupOwnerId = UserInfo.getProfileId(),
			Fire_Triggers__c = true,
			Fire_Auto_Merge__c = true,
			Schedule_Delay__c = 5
		);
		insert globalSetting;

		SObject testLeadAddMess = new Lead(
			LastName = 'testLeadMess',
			FirstName = null,
			Company = 'testLead',
			Override__c = false
		);
		testLeadAddMess.put('Additional_Message__c', 'testmessage');
		insert testLeadAddMess;

		Filter__c filter = new Filter__c(
			CreateNewDataTask__c = true,
			SourceObjectType__c = 'Enquiries',
			TargetObjectType__c = 'Enquiries',
			Active__c = true,
			SearchAllRecords__c = false,
			MatchOnInsert__c = 'Do Not Insert',
			AutoMerge__c = true
		);
		insert filter;

		Rule__c rule = new Rule__c(
			Filter__c = filter.Id,
			SourceField__c = 'LastName',
			TargetField__c = 'LastName',
			MatchingApproach__c = 'Exact'
		);
		insert rule;

		Test.startTest();

		SObject insertingLead = new Lead(
			LastName = 'testLeadMess',
			FirstName = null,
			Company = 'testLead',
			Override__c = false
		);
		insertingLead.put('Additional_Message__c', 'testmessage');
		insert insertingLead;

		Test.stopTest();

		// working but needs launching on packaging org
		/*System.assertEquals(
			'testmessage' + '\n(' + String.valueOf(Date.today().format()) + ') testmessage',
			[
				SELECT Additional_Message__c
				FROM Lead
			].get(0).Additional_Message__c
		);

		System.assert([SELECT Id FROM Task].size() == 1);*/

	}

	@isTest static void testOpportunity_CreatingTaskOnInsert() {
		Deduper_Custom_Settings__c globalSetting = new Deduper_Custom_Settings__c(
			SetupOwnerId = UserInfo.getProfileId(),
			Fire_Triggers__c = true,
			Fire_Auto_Merge__c = true,
			Schedule_Delay__c = 5
		);
		insert globalSetting;

		SObject testOppAddMess = new Opportunity(
			Name = 'testLeadMess',
			CloseDate = System.today(),
			StageName = 'Prospecting',
			Override__c = false
		);
		testOppAddMess.put('Additional_Message__c', 'testmessage');
		insert testOppAddMess;

		Filter__c filter = new Filter__c(
			CreateNewDataTask__c = true,
			SourceObjectType__c = 'Enquiries',
			TargetObjectType__c = 'Opportunity',
			Active__c = true,
			SearchAllRecords__c = false,
			MatchOnInsert__c = 'Do Not Insert',
			AutoMerge__c = true
		);
		insert filter;

		Rule__c rule = new Rule__c(
			Filter__c = filter.Id,
			SourceField__c = 'LastName',
			TargetField__c = 'Name',
			MatchingApproach__c = 'Exact'
		);
		insert rule;

		Test.startTest();

		try {
			SObject insertingLead =  new Lead(
				LastName = 'testLeadMess',
				FirstName = null,
				Company = 'testLead',
				Override__c = false
			);
			testOppAddMess.put('Additional_Message__c', 'testmessage');
			insert insertingLead;
		}
		catch (DmlException exc) {
			//silence
		}

		Test.stopTest();

		//needs launching on pack org
		/*System.assertEquals(
			'testmessage' + '\n(' + String.valueOf(Date.today().format()) + ') testmessage',
			[
				SELECT Additional_Message__c
				FROM Opportunity
			].get(0).Additional_Message__c
		);

		System.assert([SELECT Id FROM Task].size() == 1);*/
	}

	/*
	 * BatchHandler is testing below
	 */

	@isTest static void testBatchOpportunity_ExactMatchOnInsert() {
		prepare();

		Filter__c filter = new Filter__c(
			CreateNewDataTask__c = false,
			SourceObjectType__c = 'Opportunity',
			TargetObjectType__c = 'Opportunity',
			Active__c = true,
			SearchAllRecords__c = false,
			MatchOnInsert__c = 'Do Not Insert',
			AutoMerge__c = false
		);
		insert filter;

		Rule__c rule = new Rule__c(
			Filter__c = filter.Id,
			SourceField__c = 'Name',
			TargetField__c = 'Name',
			MatchingApproach__c = 'Exact'
		);
		insert rule;

		Test.startTest();

		try {
			insert new List<Opportunity> {
				new Opportunity(
					Name = 'testOpportunity',
					StageName = 'Pending',
					CloseDate = Date.today() + 1,
					Override__c = false
				),
				new Opportunity(
					Name = 'testOpportunity',
					StageName = 'Pending',
					CloseDate = Date.today() + 1,
					Override__c = false
				)
			};
		}
		catch (DmlException exc) {
			//silence
		}

		Test.stopTest();

		//System.assert([SELECT Id FROM Opportunity].size() == 1);
	}

	@isTest static void testBatchOpportunity_ExactMisMatchOnInsertAmount() {
		prepare();

		Filter__c filter = new Filter__c(
			CreateNewDataTask__c = false,
			SourceObjectType__c = 'Opportunity',
			TargetObjectType__c = 'Opportunity',
			Active__c = true,
			SearchAllRecords__c = false,
			MatchOnInsert__c = 'Do Not Insert',
			AutoMerge__c = false
		);
		insert filter;

		Rule__c rule = new Rule__c(
			Filter__c = filter.Id,
			SourceField__c = 'Amount',
			TargetField__c = 'Amount',
			MatchingApproach__c = 'Exact'
		);
		insert rule;

		Test.startTest();

		try {
			insert new List<Opportunity> {
				new Opportunity(
					Name = 'testOpportunity',
					StageName = 'Pending',
					Amount = 12,
					CloseDate = Date.today() + 1,
					Override__c = false
				),
				new Opportunity(
					Name = 'testOpportunity',
					StageName = 'Pending',
					Amount = 12,
					CloseDate = Date.today() + 1,
					Override__c = false
				)
			};
		}
		catch (DmlException exc) {
			//silence
		}

		Test.stopTest();

		System.assert([SELECT Id FROM Opportunity].size() == 3);
	}

	@isTest static void testBatchOpportunity_ExactMisMatchBlanksOnInsertAmount() {
		prepare();

		Filter__c filter = new Filter__c(
			CreateNewDataTask__c = false,
			SourceObjectType__c = 'Opportunity',
			TargetObjectType__c = 'Opportunity',
			Active__c = true,
			SearchAllRecords__c = false,
			MatchOnInsert__c = 'Do Not Insert',
			AutoMerge__c = false
		);
		insert filter;

		Rule__c rule = new Rule__c(
			Filter__c = filter.Id,
			SourceField__c = 'Amount',
			TargetField__c = 'Amount',
			MatchingApproach__c = 'Exact',
			MatchBlanks__c = true
		);
		insert rule;

		Test.startTest();

		try {
			insert new List<Opportunity> {
				new Opportunity(
					Name = 'testOpportunity',
					StageName = 'Pending',
					Amount = null,
					CloseDate = Date.today() + 1,
					Override__c = false
				),
				new Opportunity(
					Name = 'testOpportunity',
					StageName = 'Pending',
					Amount = null,
					CloseDate = Date.today() + 1,
					Override__c = false
				)
			};
		}
		catch (DmlException exc) {
			//silence
		}

		Test.stopTest();

		//System.assert([SELECT Id FROM Opportunity].size() == 1);
	}

	@isTest static void testBatchOpportunity_ExactMatchOnInsertDisplayRecords() {
		prepare();

		Filter__c filter = new Filter__c(
			CreateNewDataTask__c = false,
			SourceObjectType__c = 'Opportunity',
			TargetObjectType__c = 'Opportunity',
			Active__c = true,
			SearchAllRecords__c = false,
			MatchOnInsert__c = 'Display Matching Records',
			AutoMerge__c = false
		);
		insert filter;

		Rule__c rule = new Rule__c(
			Filter__c = filter.Id,
			SourceField__c = 'Name',
			TargetField__c = 'Name',
			MatchingApproach__c = 'Exact'
		);
		insert rule;

		Test.startTest();

		try {
			insert new List<Opportunity> {
				new Opportunity(
					Name = 'testOpportunity',
					StageName = 'Pending',
					CloseDate = Date.today() + 1,
					Override__c = false
				),
				new Opportunity(
					Name = 'testOpportunity',
					StageName = 'Pending',
					CloseDate = Date.today() + 1,
					Override__c = false
				)
			};
		}
		catch (DmlException exc) {
			//silence
		}

		Test.stopTest();

		//System.assert([SELECT Id FROM Opportunity].size() == 1);
	}

	@isTest static void testBatchOpportunity_ExactMatchOnUpdate() {
		prepare();

		Filter__c filter = new Filter__c(
			CreateNewDataTask__c = false,
			SourceObjectType__c = 'Opportunity',
			TargetObjectType__c = 'Opportunity',
			Active__c = true,
			SearchAllRecords__c = false,
			MatchOnUpdate__c = 'Report Duplicate',
			CreateTasks__c = 'Yes - User',
			AutoMerge__c = false
		);
		insert filter;

		Rule__c rule = new Rule__c(
			Filter__c = filter.Id,
			SourceField__c = 'Name',
			TargetField__c = 'Name',
			MatchingApproach__c = 'Exact'
		);
		insert rule;

		Opportunity testOpportunity = new Opportunity(
			Name = 't1estOpportunity',
			StageName = 'Pending',
			CloseDate = Date.today() + 1,
			Override__c = false
		);
		insert testOpportunity;

		Opportunity testOpportunitySec = new Opportunity(
			Name = 't2estOpportunity',
			StageName = 'Pending',
			CloseDate = Date.today() + 1,
			Override__c = false
		);
		insert testOpportunitySec;

		Test.startTest();

		testOpportunity.Name = 'testOpportunity';
		testOpportunitySec.Name = 'testOpportunity';

		update new List<Opportunity> {
			testOpportunity,
			testOpportunitySec
		};

		Test.stopTest();

		//System.assert([SELECT Id FROM Task].size() == 2);
	}

	@isTest static void testBatchContact_LettersMatchOnInsert() {
		prepare();

		Filter__c filter = new Filter__c(
			CreateNewDataTask__c = false,
			SourceObjectType__c = 'Contact',
			TargetObjectType__c = 'Contact',
			Active__c = true,
			SearchAllRecords__c = true,
			MatchOnInsert__c = 'Report Duplicate',
			CreateTasks__c = 'Yes - Filter Owner',
			AutoMerge__c = false
		);
		insert filter;

		Rule__c rule = new Rule__c(
			Filter__c = filter.Id,
			SourceField__c = 'LastName',
			TargetField__c = 'LastName',
			MatchingApproach__c = 'First N Letters',
			FirstN__c = 3
		);
		insert rule;

		Test.startTest();

		insert new List<Contact> {
			new Contact(
				LastName = 'testContact',
				Override__c = false
			),
			new Contact(
				LastName = 'testContact',
				Override__c = false
			)
		};

		Test.stopTest();

		//System.assert([SELECT Id FROM Task].size() == 2);
	}

	@isTest static void testBatchAccount_WordsMatchOnInsert() {
		prepare();

		Filter__c filter = new Filter__c(
			CreateNewDataTask__c = false,
			SourceObjectType__c = 'Account',
			TargetObjectType__c = 'Account',
			Active__c = true,
			SearchAllRecords__c = true,
			MatchOnInsert__c = 'Do Not Insert',
			AutoMerge__c = false
		);
		insert filter;

		Rule__c rule = new Rule__c(
			Filter__c = filter.Id,
			SourceField__c = 'Name',
			TargetField__c = 'Name',
			MatchingApproach__c = 'First N Words',
			FirstN__c = 2
		);
		insert rule;

		Test.startTest();

		try {
			insert new List<Account> {
				new Account(
					Name = 'testAccount testWord testWordMisMatch',
					Override__c = false
				),
				new Account(
					Name = 'testAccount testWord testWordMisMatch',
					Override__c = false
				)
			};
		}
		catch (DmlException exc) {
			//silence
		}

		Test.stopTest();

		//System.assert([SELECT Id FROM Account].size() == 1);
	}

	@isTest static void testBatchAccountLead_WordsMatchOnInsert() {
		prepare();

		Filter__c filter = new Filter__c(
			CreateNewDataTask__c = false,
			SourceObjectType__c = 'Account',
			TargetObjectType__c = 'Enquiries',
			Active__c = true,
			SearchAllRecords__c = true,
			MatchOnInsert__c = 'Do Not Insert',
			AutoMerge__c = false
		);
		insert filter;

		Rule__c rule = new Rule__c(
			Filter__c = filter.Id,
			SourceField__c = 'Name',
			TargetField__c = 'Name',
			MatchingApproach__c = 'First N Words',
			FirstN__c = 2
		);
		insert rule;

		Lead testLead = new Lead(
			LastName = 'testAccount testWord testWordMisMatch',
			Company = 'testLead'
		);
		insert testLead;

		Test.startTest();

		try {
			insert new List<Account> {
				new Account(
					Name = 'testAccount testWord testWordMisMatch',
					Override__c = false
				),
				new Account(
					Name = 'testAccount testWord testWordMisMatch',
					Override__c = false
				)
			};
		}
		catch (DmlException exc) {
			//silence
		}

		Test.stopTest();
		//System.assert([SELECT Id FROM Account].size() == 1);
	}

	@isTest static void testBatchLead_LettersMismatchOnInsert() {
		prepare();

		Filter__c filter = new Filter__c(
			CreateNewDataTask__c = false,
			SourceObjectType__c = 'Enquiries',
			TargetObjectType__c = 'Enquiries',
			Active__c = true,
			SearchAllRecords__c = true,
			MatchOnInsert__c = 'Do Not Insert',
			AutoMerge__c = false
		);
		insert filter;

		Rule__c rule = new Rule__c(
			Filter__c = filter.Id,
			SourceField__c = 'LastName',
			TargetField__c = 'LastName',
			MatchingApproach__c = 'First N Letters',
			FirstN__c = 3
		);
		insert rule;

		Test.startTest();

		insert new List<Lead> {
			new Lead(
				LastName = 't1estLead',
				Company = 'testLead',
				Override__c = false
			),
			new Lead(
				LastName = 't1estLead',
				Company = 'testLead',
				Override__c = false
			)
		};

		Test.stopTest();

		System.assert([SELECT Id FROM Lead].size() == 3);
	}

	@isTest static void testBatchOrder_WordsMismatchOnInsert() {
		prepare();

		Filter__c filter = new Filter__c(
			CreateNewDataTask__c = false,
			SourceObjectType__c = 'Bookings',
			TargetObjectType__c = 'Bookings',
			Active__c = true,
			SearchAllRecords__c = true,
			MatchOnInsert__c = 'Do Not Insert',
			AutoMerge__c = false
		);
		insert filter;

		Rule__c rule = new Rule__c(
			Filter__c = filter.Id,
			SourceField__c = 'Name',
			TargetField__c = 'Name',
			MatchingApproach__c = 'First N Words',
			FirstN__c = 3
		);
		insert rule;

		Test.startTest();

		insert new List<Order> {
			new Order(
				Name = 'testOrder testWord t1estWord',
				AccountId = [SELECT Id FROM Account LIMIT 1].Id,
				//Booking_Reference__c = '12345679',
				//Arrival_Date__c = Date.today(),
				EffectiveDate = Date.today(),
				Status = 'Draft',
				Override__c = false
			),
			new Order(
				Name = 'testOrder testWord t1estWord',
				AccountId = [SELECT Id FROM Account LIMIT 1].Id,
				//Booking_Reference__c = '12345679',
				//Arrival_Date__c = Date.today(),
				EffectiveDate = Date.today(),
				Status = 'Draft',
				Override__c = false
			)
		};

		Test.stopTest();

		System.assert([SELECT Id FROM Order].size() == 3);
	}

	@isTest static void testBatchLead_AutoMergeOnInsert() {
		prepare();

		insert new Lead(
			LastName = 'testLead',
			FirstName = 'testLead',
			Company = 'null',
			Override__c = false
		);

		insert new Lead(
			LastName = 'testLead',
			FirstName = null,
			Company = 'null',
			Override__c = false
		);

		Filter__c filter = new Filter__c(
			CreateNewDataTask__c = false,
			SourceObjectType__c = 'Enquiries',
			TargetObjectType__c = 'Enquiries',
			Active__c = true,
			SearchAllRecords__c = true,
			AutoMerge__c = true
		);
		insert filter;

		Rule__c rule = new Rule__c(
			Filter__c = filter.Id,
			SourceField__c = 'LastName',
			TargetField__c = 'LastName',
			MatchingApproach__c = 'First N Letters',
			FirstN__c = 3
		);
		insert rule;

		MergeRule__c mergeRuleLastName = new MergeRule__c(
			Filter__c = filter.Id,
			SourceField__c = 'LastName',
			TargetField__c = 'LastName',
			MergeAction__c = 'replace',
			MergeBlanks__c = false
		);
		insert mergeRuleLastName;

		MergeRule__c mergeRuleFirstName = new MergeRule__c(
			Filter__c = filter.Id,
			SourceField__c = 'FirstName',
			TargetField__c = 'FirstName',
			MergeAction__c = 'replace',
			MergeBlanks__c = false
		);
		insert mergeRuleFirstName;

		MergeRule__c mergeRuleCompany = new MergeRule__c(
			Filter__c = filter.Id,
			SourceField__c = 'Company',
			TargetField__c = 'Company',
			MergeAction__c = 'replace',
			MergeBlanks__c = false
		);
		insert mergeRuleCompany;

		Test.startTest();

		insert new List<Lead> {
			new Lead(
				LastName = 'testLead',
				FirstName = 'testLead',
				Company = 'testLead',
				Override__c = false
			),
			new Lead(
				LastName = 'testLead',
				FirstName = 'testLead',
				Company = 'testLead',
				Override__c = false
			)
		};

		Test.stopTest();

		/*System.assert([SELECT Id FROM Lead].size() == 1);

		Lead resultLead = [
			SELECT LastName, FirstName, Company
			FROM Lead
			LIMIT 1
		];
		System.assertEquals('testLead', resultLead.FirstName);
		System.assertEquals('testLead', resultLead.Company);*/
	}

	@isTest static void testBatchLead_AutoMergeOnInsertOnlyForBlanks() {
		prepare();

		insert new Lead(
			LastName = 'testLead',
			FirstName = 'testLead',
			Company = 'testLead',
			Override__c = false
		);
		insert new Lead(
			LastName = 'testLead',
			FirstName = null,
			Company = 'testLead',
			Override__c = false
		);

		Filter__c filter = new Filter__c(
			CreateNewDataTask__c = false,
			SourceObjectType__c = 'Enquiries',
			TargetObjectType__c = 'Enquiries',
			Active__c = true,
			SearchAllRecords__c = true,
			AutoMerge__c = true
		);
		insert filter;

		Rule__c rule = new Rule__c(
			Filter__c = filter.Id,
			SourceField__c = 'LastName',
			TargetField__c = 'LastName',
			MatchingApproach__c = 'First N Letters',
			FirstN__c = 3
		);
		insert rule;

		MergeRule__c mergeRuleLastName = new MergeRule__c(
			Filter__c = filter.Id,
			SourceField__c = 'LastName',
			TargetField__c = 'LastName',
			MergeAction__c = 'replace'
		);
		insert mergeRuleLastName;

		MergeRule__c mergeRuleFirstName = new MergeRule__c(
			Filter__c = filter.Id,
			SourceField__c = 'FirstName',
			TargetField__c = 'FirstName',
			MergeBlanks__c = false,
			MergeAction__c = 'replace'
		);
		insert mergeRuleFirstName;

		MergeRule__c mergeRuleCompany = new MergeRule__c(
			Filter__c = filter.Id,
			SourceField__c = 'Company',
			TargetField__c = 'Company',
			MergeBlanks__c = true,
			MergeAction__c = 'replace'
		);
		insert mergeRuleCompany;

		Test.startTest();

		insert new List<Lead> {
			new Lead(
				LastName = 'testLead',
				FirstName = 'allowedMerge',
				Company = 'notAllowedMerge',
				Override__c = false
			),
			new Lead(
				LastName = 'testLead',
				FirstName = 'allowedMerge',
				Company = 'notAllowedMerge',
				Override__c = false
			)
		};

		Test.stopTest();

		/*System.assert([SELECT Id FROM Lead].size() == 1);

		Lead resultLead = [
			SELECT LastName, FirstName, Company
			FROM Lead
			LIMIT 1
		];
		System.assertEquals('allowedMerge', resultLead.FirstName);
		System.assertEquals('notAllowedMerge', resultLead.Company);*/
	}

	@isTest static void testBatchLead_FilterPriorityExecution() {
		prepare();

		Filter__c filter = new Filter__c(
			CreateNewDataTask__c = false,
			SourceObjectType__c = 'Enquiries',
			TargetObjectType__c = 'Enquiries',
			Active__c = true,
			SearchAllRecords__c = true,
			MatchOnInsert__c = 'Do Not Insert',
			AutoMerge__c = true,
			Priority__c = 2
		);
		insert filter;

		Rule__c rule = new Rule__c(
			Filter__c = filter.Id,
			SourceField__c = 'LastName',
			TargetField__c = 'LastName',
			MatchingApproach__c = 'Exact'
		);
		insert rule;

		MergeRule__c mergeRule = new MergeRule__c(
			Filter__c = filter.Id,
			SourceField__c = 'FirstName',
			TargetField__c = 'FirstName',
			MergeBlanks__c = false,
			MergeAction__c = 'replace'
		);
		insert mergeRule;

		/*
		 * Pay attention to priority
		 */
		Filter__c filter2 = new Filter__c(
			CreateNewDataTask__c = false,
			SourceObjectType__c = 'Enquiries',
			TargetObjectType__c = 'Enquiries',
			Active__c = true,
			SearchAllRecords__c = true,
			MatchOnInsert__c = 'Do Not Insert',
			AutoMerge__c = true,
			Priority__c = 1
		);
		insert filter2;

		Rule__c rule2 = new Rule__c(
			Filter__c = filter2.Id,
			SourceField__c = 'FirstName',
			TargetField__c = 'FirstName',
			MatchingApproach__c = 'Exact'
		);
		insert rule2;

		MergeRule__c mergeRule2 = new MergeRule__c(
			Filter__c = filter2.Id,
			SourceField__c = 'Company',
			TargetField__c = 'Company',
			MergeBlanks__c = false,
			MergeAction__c = 'replace'
		);
		insert mergeRule2;

		Test.startTest();

		insert new List<Lead> {
			new Lead(
				LastName = 'testLead',
				FirstName = 'testLead',
				Company = 'latestCompany',
				Override__c = false
			),
			new Lead(
				LastName = 'testLead',
				FirstName = 'testLead',
				Company = 'latestCompany',
				Override__c = false
			)
		};

		Test.stopTest();

		//System.assert([SELECT Company FROM Lead].get(0).Company == 'latestCompany');
	}

	@isTest static void testBatchLead_FilterInversePriorityExecution() {
		prepare();

		Filter__c filter = new Filter__c(
			CreateNewDataTask__c = false,
			SourceObjectType__c = 'Enquiries',
			TargetObjectType__c = 'Enquiries',
			Active__c = true,
			SearchAllRecords__c = true,
			MatchOnInsert__c = 'Do Not Insert',
			AutoMerge__c = true,
			Priority__c = 1
		);
		insert filter;

		Rule__c rule = new Rule__c(
			Filter__c = filter.Id,
			SourceField__c = 'LastName',
			TargetField__c = 'LastName',
			MatchingApproach__c = 'Exact'
		);
		insert rule;

		MergeRule__c mergeRule = new MergeRule__c(
			Filter__c = filter.Id,
			SourceField__c = 'FirstName',
			TargetField__c = 'FirstName',
			MergeBlanks__c = false,
			MergeAction__c = 'replace'
		);
		insert mergeRule;

		/*
		 * Pay attention to priority
		 */
		Filter__c filter2 = new Filter__c(
			CreateNewDataTask__c = false,
			SourceObjectType__c = 'Enquiries',
			TargetObjectType__c = 'Enquiries',
			Active__c = true,
			SearchAllRecords__c = true,
			MatchOnInsert__c = 'Do Not Insert',
			AutoMerge__c = true,
			Priority__c = 2
		);
		insert filter2;

		Rule__c rule2 = new Rule__c(
			Filter__c = filter2.Id,
			SourceField__c = 'FirstName',
			TargetField__c = 'FirstName',
			MatchingApproach__c = 'Exact'
		);
		insert rule2;

		MergeRule__c mergeRule2 = new MergeRule__c(
			Filter__c = filter2.Id,
			SourceField__c = 'Company',
			TargetField__c = 'Company',
			MergeBlanks__c = false,
			MergeAction__c = 'replace'
		);
		insert mergeRule2;

		Test.startTest();

		insert new List<Lead> {
			new Lead(
				LastName = 'testLead',
				FirstName = 'testLead',
				Company = 'latestCompany',
				Override__c = false
			),
			new Lead(
				LastName = 'testLead',
				FirstName = 'testLead',
				Company = 'latestCompany',
				Override__c = false
			)
		};

		Test.stopTest();

		System.assert([SELECT Company FROM Lead].get(0).Company == 'testLead');
	}

	@isTest static void testBatchContact_NDaysMatch() {
		prepare();

		Contact testContact = new Contact(
			LastName = 'testContact',
			Birthdate = Date.today(),
			Override__c = false
		);
		insert testContact;

		Filter__c filter = new Filter__c(
			CreateNewDataTask__c = false,
			SourceObjectType__c = 'Contact',
			TargetObjectType__c = 'Contact',
			Active__c = true,
			SearchAllRecords__c = false,
			MatchOnInsert__c = 'Do Not Insert',
			AutoMerge__c = false
		);
		insert filter;

		Rule__c rule = new Rule__c(
			Filter__c = filter.Id,
			SourceField__c = 'Birthdate',
			TargetField__c = 'Birthdate',
			MatchingApproach__c = '+/- N days',
			FirstN__c = 11
		);
		insert rule;

		Test.startTest();

		try {
			insert new List<Contact> {
				new Contact(
					LastName = 'testContact',
					Birthdate = Date.today(),
					Override__c = false
				),
				new Contact(
					LastName = 'testContact',
					Birthdate = Date.today(),
					Override__c = false
				)
			};
		}
		catch (DmlException exc) {
			//silence
		}

		Test.stopTest();

		//System.assert([SELECT Id FROM Contact].size() == 2);
	}

	@isTest static void testBatchContact_NDaysTimeMatch() {
		//prepare();

		//Contact testContact = new Contact(
		//	LastName = 'testContact',
		//	Datetime_Field__c = Datetime.now(),
		//	Override__c = false
		//);
		//insert testContact;

		//Filter__c filter = new Filter__c(
		//	CreateNewDataTask__c = false,
		//	SourceObjectType__c = 'Contact',
		//	TargetObjectType__c = 'Contact',
		//	Active__c = true,
		//	SearchAllRecords__c = false,
		//	MatchOnInsert__c = 'Do Not Insert',
		//	AutoMerge__c = false
		//);
		//insert filter;

		//Rule__c rule = new Rule__c(
		//	Filter__c = filter.Id,
		//	SourceField__c = 'Datetime_Field__c',
		//	TargetField__c = 'Datetime_Field__c',
		//	MatchingApproach__c = '+/- N days',
		//	FirstN__c = 11
		//);
		//insert rule;

		//Test.startTest();

		//try {
		//	insert new List<Contact> {
		//		new Contact(
		//			LastName = 'testContact',
		//			Datetime_Field__c = Datetime.now(),
		//			Override__c = false
		//		),
		//		new Contact(
		//			LastName = 'testContact',
		//			Datetime_Field__c = Datetime.now(),
		//			Override__c = false
		//		)
		//	};
		//}
		//catch (DmlException exc) {
		//	//silence
		//}

		//Test.stopTest();

		//System.assert([SELECT Id FROM Contact].size() == 2);
	}

	@isTest static void testBatchContact_NDaysExactMatch() {
		prepare();

		Contact testContact = new Contact(
			LastName = 'testContact',
			Birthdate = Date.today(),
			Override__c = false
		);
		insert testContact;

		Filter__c filter = new Filter__c(
			CreateNewDataTask__c = false,
			SourceObjectType__c = 'Contact',
			TargetObjectType__c = 'Contact',
			Active__c = true,
			SearchAllRecords__c = false,
			MatchOnInsert__c = 'Do Not Insert',
			AutoMerge__c = false
		);
		insert filter;

		Rule__c rule = new Rule__c(
			Filter__c = filter.Id,
			SourceField__c = 'Birthdate',
			TargetField__c = 'Birthdate',
			MatchingApproach__c = 'Exact'
		);
		insert rule;

		Test.startTest();

		try {
			insert new List<Contact> {
				new Contact(
					LastName = 'testContact',
					Birthdate = Date.today(),
					Override__c = false
				),
				new Contact(
					LastName = 'testContact',
					Birthdate = Date.today(),
					Override__c = false
				)
			};
		}
		catch (DmlException exc) {
			//silence
		}

		Test.stopTest();

		//System.assert([SELECT Id FROM Contact].size() == 2);
	}

	@isTest static void testBatchContact_NDaysEmptyMatch() {
		prepare();

		Contact testContact = new Contact(
			LastName = 'testContact',
			Birthdate = null,
			Override__c = false
		);
		insert testContact;

		Filter__c filter = new Filter__c(
			CreateNewDataTask__c = false,
			SourceObjectType__c = 'Contact',
			TargetObjectType__c = 'Contact',
			Active__c = true,
			SearchAllRecords__c = false,
			MatchOnInsert__c = 'Do Not Insert',
			AutoMerge__c = false
		);
		insert filter;

		Rule__c rule = new Rule__c(
			Filter__c = filter.Id,
			SourceField__c = 'Birthdate',
			TargetField__c = 'Birthdate',
			MatchingApproach__c = '+/- N days',
			FirstN__c = 11,
			MatchBlanks__c = true
		);
		insert rule;

		Test.startTest();

		try {
			insert new List<Contact> {
				new Contact(
					LastName = 'testContact',
					Birthdate = null,
					Override__c = false
				),
				new Contact(
					LastName = 'testContact',
					Birthdate = null,
					Override__c = false
				)
			};
		}
		catch (DmlException exc) {
			//silence
		}

		Test.stopTest();

		//System.assert([SELECT Id FROM Contact].size() == 2);
	}

	@isTest static void testBatchContact_NDaysEmptyExactMatch() {
		prepare();

		Contact testContact = new Contact(
			LastName = 'testContact',
			Birthdate = null,
			Override__c = false
		);
		insert testContact;

		Filter__c filter = new Filter__c(
			CreateNewDataTask__c = false,
			SourceObjectType__c = 'Contact',
			TargetObjectType__c = 'Contact',
			Active__c = true,
			SearchAllRecords__c = false,
			MatchOnInsert__c = 'Do Not Insert',
			AutoMerge__c = false
		);
		insert filter;

		Rule__c rule = new Rule__c(
			Filter__c = filter.Id,
			SourceField__c = 'Birthdate',
			TargetField__c = 'Birthdate',
			MatchingApproach__c = 'Exact',
			FirstN__c = 11,
			MatchBlanks__c = true
		);
		insert rule;

		Test.startTest();

		try {
			insert new List<Contact> {
				new Contact(
					LastName = 'testContact',
					Birthdate = null,
					Override__c = false
				),
				new Contact(
					LastName = 'testContact',
					Birthdate = null,
					Override__c = false
				)
			};
		}
		catch (DmlException exc) {
			//silence
		}

		Test.stopTest();

		//System.assert([SELECT Id FROM Contact].size() == 2);
	}

	@isTest static void testBatchLead_AutoMergeOnInsertWithAppending() {
		prepare();

		insert new Lead(
			LastName = 'testLead',
			FirstName = 'testLead',
			Company = 'testLead',
			Override__c = false
		);
		insert new Lead(
			LastName = 'testLead',
			FirstName = 'testLead',
			Company = 'testLead',
			Override__c = false
		);

		Filter__c filter = new Filter__c(
			CreateNewDataTask__c = false,
			SourceObjectType__c = 'Enquiries',
			TargetObjectType__c = 'Enquiries',
			Active__c = true,
			SearchAllRecords__c = true,
			AutoMerge__c = true
		);
		insert filter;

		Rule__c rule = new Rule__c(
			Filter__c = filter.Id,
			SourceField__c = 'LastName',
			TargetField__c = 'LastName',
			MatchingApproach__c = 'First N Letters',
			FirstN__c = 3
		);
		insert rule;

		MergeRule__c mergeRuleLastName = new MergeRule__c(
			Filter__c = filter.Id,
			SourceField__c = 'LastName',
			TargetField__c = 'LastName',
			MergeAction__c = 'append with ","'
		);
		insert mergeRuleLastName;

		MergeRule__c mergeRuleFirstName = new MergeRule__c(
			Filter__c = filter.Id,
			SourceField__c = 'FirstName',
			TargetField__c = 'FirstName',
			MergeAction__c = 'append with space'
		);
		insert mergeRuleFirstName;

		MergeRule__c mergeRuleCompany = new MergeRule__c(
			Filter__c = filter.Id,
			SourceField__c = 'Company',
			TargetField__c = 'Company',
			MergeAction__c = 'append with ";"'
		);
		insert mergeRuleCompany;

		Lead testLead = new Lead(
			LastName = 'testLead',
			FirstName = 'testLead',
			Company = 'testLead',
			Override__c = false
		);

		Test.startTest();

		insert new List<Lead> {
			new Lead(
				LastName = 'testLead',
				FirstName = 'testLead',
				Company = 'testLead',
				Override__c = false
			),
			new Lead(
				LastName = 'testLead',
				FirstName = 'testLead',
				Company = 'testLead',
				Override__c = false
			)
		};

		Test.stopTest();

		//System.assert([SELECT Id FROM Lead].size() == 1);

		Lead resultLead = [
			SELECT LastName, FirstName, Company
			FROM Lead
			LIMIT 1
		];
		//System.assertEquals('testLead testLead', resultLead.FirstName);
		//System.assertEquals('testLead;testLead', resultLead.Company); //because of created in prepare method Lead
	}

	/*
	 * Version for Batching not Schedulable
	 */
	/*@isTest static void testBatchLead_AutoMergeOnInsertWithPrepending() {
		prepare();

		new Lead(
			LastName = 'testLead',
			FirstName = 'testLead',
			Company = 'testLead',
			Override__c = false
		);
		new Lead(
			LastName = 'testLead',
			FirstName = null,
			Company = 'testLead',
			Override__c = false
		);

		Filter__c filter = new Filter__c(
			CreateNewDataTask__c = false,
			SourceObjectType__c = 'Enquiries',
			TargetObjectType__c = 'Enquiries',
			Active__c = true,
			SearchAllRecords__c = true,
			AutoMerge__c = true
		);
		insert filter;

		Rule__c rule = new Rule__c(
			Filter__c = filter.Id,
			SourceField__c = 'LastName',
			TargetField__c = 'LastName',
			MatchingApproach__c = 'First N Letters',
			FirstN__c = 3
		);
		insert rule;

		MergeRule__c mergeRuleLastName = new MergeRule__c(
			Filter__c = filter.Id,
			SourceField__c = 'LastName',
			TargetField__c = 'LastName',
			MergeAction__c = 'prepend with space'
		);
		insert mergeRuleLastName;

		MergeRule__c mergeRuleFirstName = new MergeRule__c(
			Filter__c = filter.Id,
			SourceField__c = 'FirstName',
			TargetField__c = 'FirstName',
			MergeAction__c = 'prepend with ","'
		);
		insert mergeRuleFirstName;

		MergeRule__c mergeRuleCompany = new MergeRule__c(
			Filter__c = filter.Id,
			SourceField__c = 'Company',
			TargetField__c = 'Company',
			MergeAction__c = 'prepend with ";"'
		);
		insert mergeRuleCompany;

		Lead testLead = new Lead(
			LastName = 'testLead',
			FirstName = null,
			Company = 'testLead',
			Override__c = false
		);

		Test.startTest();

		List<Lead> leads = new List<Lead>();
		for (Integer i = 0; i < 150; i++) {
			leads.add(
				new Lead(
					LastName = 'testLead',
					FirstName = null,
					Company = 'testLead',
					Override__c = false
				)
			);
		}

		insert leads;

		//insert new List<Lead> {
		//	new Lead(
		//		LastName = 'testLead',
		//		FirstName = null,
		//		Company = 'testLead',
		//		Override__c = false
		//	),
		//	new Lead(
		//		LastName = 'testLead',
		//		FirstName = null,
		//		Company = 'testLead',
		//		Override__c = false
		//	)
		//};

		Test.stopTest();

		System.assert([SELECT Id FROM Lead].size() == 1);

		Lead resultLead = [
			SELECT LastName, FirstName, Company
			FROM Lead
			LIMIT 1
		];
		System.assertEquals('testLead', resultLead.FirstName);
		System.assertEquals('testLead;testLead', resultLead.Company);
	}*/

	@isTest static void testBatchLead_CreatingTaskOnInsert() {
		Deduper_Custom_Settings__c globalSetting = new Deduper_Custom_Settings__c(
			SetupOwnerId = UserInfo.getProfileId(),
			Fire_Triggers__c = true,
			Fire_Auto_Merge__c = true,
			Schedule_Delay__c = 5
		);
		insert globalSetting;

		SObject testLeadAddMess = new Lead(
			LastName = 'testLeadMess',
			FirstName = null,
			Company = 'testLead',
			Override__c = false
		);
		testLeadAddMess.put('Additional_Message__c', 'testmessage');
		insert testLeadAddMess;

		Filter__c filter = new Filter__c(
			CreateNewDataTask__c = true,
			SourceObjectType__c = 'Enquiries',
			TargetObjectType__c = 'Enquiries',
			Active__c = true,
			SearchAllRecords__c = false,
			MatchOnInsert__c = 'Do Not Insert',
			AutoMerge__c = true
		);
		insert filter;

		Rule__c rule = new Rule__c(
			Filter__c = filter.Id,
			SourceField__c = 'LastName',
			TargetField__c = 'LastName',
			MatchingApproach__c = 'Exact'
		);
		insert rule;

		Test.startTest();

		SObject insertingLead1 = new Lead(
			LastName = 'testLeadMess',
			FirstName = null,
			Company = 'testLead',
			Override__c = false
		);
		insertingLead1.put('Additional_Message__c', 'testmessage');

		SObject insertingLead2 = new Lead(
			LastName = 'testLeadMess',
			FirstName = null,
			Company = 'testLead',
			Override__c = false
		);
		insertingLead2.put('Additional_Message__c', 'testmessage');

		insert new List<SObject> {
			insertingLead1,
			insertingLead2
		};

		Test.stopTest();

		/*System.assertEquals(
			'testmessage' + '\n(' + String.valueOf(Date.today().format()) + ') testmessage',
			[
				SELECT Additional_Message__c
				FROM Lead
			].get(0).Additional_Message__c
		);

		System.assert([SELECT Id FROM Task].size() == 1);*/

	}

	@isTest static void testBatchOpportunity_CreatingTaskOnInsert() {
		Deduper_Custom_Settings__c globalSetting = new Deduper_Custom_Settings__c(
			SetupOwnerId = UserInfo.getProfileId(),
			Fire_Triggers__c = true,
			Fire_Auto_Merge__c = true,
			Schedule_Delay__c = 5
		);
		insert globalSetting;

		SObject testOppAddMess = new Opportunity(
			Name = 'testLeadMess',
			CloseDate = System.today(),
			StageName = 'Prospecting',
			Override__c = false
		);
		testOppAddMess.put('Additional_Message__c', 'testmessage');
		insert testOppAddMess;

		Filter__c filter = new Filter__c(
			CreateNewDataTask__c = true,
			SourceObjectType__c = 'Enquiries',
			TargetObjectType__c = 'Opportunity',
			Active__c = true,
			SearchAllRecords__c = false,
			MatchOnInsert__c = 'Do Not Insert',
			AutoMerge__c = true
		);
		insert filter;

		Rule__c rule = new Rule__c(
			Filter__c = filter.Id,
			SourceField__c = 'LastName',
			TargetField__c = 'Name',
			MatchingApproach__c = 'Exact'
		);
		insert rule;

		Test.startTest();

		SObject insertingLead1 = new Lead(
			LastName = 'testLeadMess',
			FirstName = null,
			Company = 'testLead',
			Override__c = false
		);
		insertingLead1.put('Additional_Message__c', 'testmessage');

		SObject insertingLead2 = new Lead(
			LastName = 'testLeadMess',
			FirstName = null,
			Company = 'testLead',
			Override__c = false
		);
		insertingLead2.put('Additional_Message__c', 'testmessage');

		insert new List<SObject> {
			insertingLead1,
			insertingLead2
		};

		Test.stopTest();

		/*System.assertEquals(
			'testmessage' + '\n(' + String.valueOf(Date.today().format()) + ') testmessage',
			[
				SELECT Additional_Message__c
				FROM Opportunity
			].get(0).Additional_Message__c
		);

		System.assert([SELECT Id FROM Task].size() == 1);*/
	}

}
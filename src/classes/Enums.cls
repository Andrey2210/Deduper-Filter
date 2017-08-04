public with sharing class Enums {

	public Enum FilterType {
		OPPORTUNITY, CONTACT, ACCOUNT, ENQUIRIES, BOOKINGS
	}
	public final static Map<String, FilterType> FILTER_TYPES_MAP_TO_FILTER = new Map<String, FilterType> {
		Schema.sObjectType.Opportunity.Name => FilterType.OPPORTUNITY,
		Schema.sObjectType.Contact.Name => FilterType.CONTACT,
		Schema.sObjectType.Account.Name => FilterType.ACCOUNT,
		Schema.sObjectType.Lead.Name => FilterType.ENQUIRIES,
		Schema.sObjectType.Order.Name => FilterType.BOOKINGS
	};
	public final static Map<String, String> FILTER_TYPES_MAP_TO_SCHEMA = new Map<String, String> {
		'Opportunity' => Schema.sObjectType.Opportunity.Name,
		'Contact' => Schema.sObjectType.Contact.Name,
		'Account' => Schema.sObjectType.Account.Name,
		'Enquiries' => Schema.sObjectType.Lead.Name,
		'Lead' => Schema.sObjectType.Lead.Name,
		'Bookings' => Schema.sObjectType.Order.Name,
		'Order' => Schema.sObjectType.Order.Name
	};

	public Enum CreateTasksType {
		NO_CREATING, USER_CREATING, USER_FILTER_OWNER
	}
	public final static Map<String, CreateTasksType> CREATE_TASKS_TYPES_MAP = new Map<String, CreateTasksType> {
		'No' => CreateTasksType.NO_CREATING,
		'Yes - User' => CreateTasksType.USER_CREATING,
		'Yes - Filter Owner' => CreateTasksType.USER_FILTER_OWNER
	};

	public Enum MatchOnInsertType {
		DO_NOTHING, DO_NOT_INSERT, DISPLAY_MATCHING, REPORT_DUPLICATE
	}
	public final static Map<String, MatchOnInsertType> MATCH_ON_INSERT_TYPES_MAP = new Map<String, MatchOnInsertType> {
		'Do Nothing' => MatchOnInsertType.DO_NOTHING,
		'Do Not Insert' => MatchOnInsertType.DO_NOT_INSERT,
		'Display Matching Records' => MatchOnInsertType.DISPLAY_MATCHING,
		'Report Duplicate' => MatchOnInsertType.REPORT_DUPLICATE
	};

	public Enum MatchOnUpdateType {
		DO_NOTHING, DO_NOT_UPDATE, DISPLAY_MATCHING, REPORT_DUPLICATE
	}
	public final static Map<String, MatchOnUpdateType> MATCH_ON_UPDATE_TYPES_MAP = new Map<String, MatchOnUpdateType> {
		'Do Nothing' => MatchOnUpdateType.DO_NOTHING,
		'Do Not Update' => MatchOnUpdateType.DO_NOT_UPDATE,
		//'Display Matching Records' => MatchOnUpdateType.DISPLAY_MATCHING, //— potentially needed
		'Report Duplicate' => MatchOnUpdateType.REPORT_DUPLICATE
	};

	public Enum MatchingApproach {
		EXACT, FIRST_N_LETTERS, FIRST_N_WORDS, CLEAN_NAME, N_DAYS
	}
	public final static Map<String, MatchingApproach> MATCHING_APPROACH = new Map<String, MatchingApproach> {
		'Exact' => MatchingApproach.EXACT,
		'First N Letters' => MatchingApproach.FIRST_N_LETTERS,
		'First N Words' => MatchingApproach.FIRST_N_WORDS,
		//'Clean Name' => MatchingApproach.CLEAN_NAME
		'+/- N days' => MatchingApproach.N_DAYS
	};

	public static final Map<String, String> OBJECT_MAPPING = new Map<String, String> {
		'00Q' => 'Lead',
		'001' => 'Account',
		'003' => 'Contact',
		'006' => 'Opportunity',
		'801' => 'Order'
	};

	public static final String ENQUIRY_TYPE = 'Enquiry';
	public static final Map<String, String> ACTIVITY_LEAD_FIELDS = new Map<String, String> {
		'Enquiry_Guest_Adults__c' => 'Guest_Adults__c',
		'Enquiry_Arrival_Date__c' => 'Guest_Arrival_Date__c',
		'Enquiry_Babies__c' => 'Guest_Babies__c',
		'Enquiry_Bedrooms__c' => 'Guest_Bedrooms__c',
		'Enquiry_Booking_Reference__c' => 'Guest_Booking_Reference__c',
		'Enquiry_Children__c' => 'Guest_Children__c',
		'Enquiry_Dates_Flexible__c' => 'Guest_Dates_Flexible__c',
		'Enquiry_Departure_Date__c' => 'Guest_Departure_Date__c',
		'Enquiry_Home__c' => 'Guest_Home__c',
		'Enquiry_Internal_Platform_Enquiry_Id__c' => 'Internal_Platform_Enquiry_Id__c',
		'Enquiry_Internal_Tracking_Convertro_Id__c' => 'Internal_Tracking_Convertro_Id__c',
		'Enquiry_Internal_Tracking_Session_Id__c' => 'Internal_Tracking_Session_Id__c',
		'Enquiry_Internal_Tracking_User_Id__c' => 'Internal_Tracking_User_Id__c',
		'Enquiry_Language__c' => 'Language__c',
		'Enquiry_Lead_Channel__c' => 'Lead_Channel__c',
		'Enquiry_Lead_Channel_Detailed__c' => 'Lead_Channel_Detailed__c',
		'Enquiry_Lead_Source_Detailed__c' => 'Lead_Source_Detailed__c',
		'Enquiry_Length_of_Stay__c' => 'Guest_Length_of_Stay__c',
		'Enquiry_Market__c' => 'Market__c',
		'Enquiry_Nightly_Budget__c' => 'Guest_Nightly_Budget__c',
		'Enquiry_Original_Currency__c' => 'Guest_Original_Currency__c',
		'Enquiry_Toddlers__c' => 'Guest_Toddlers__c',
		'Enquiry_Total_Guests__c' => 'Guest_Total_Guests__c',
		'Description' => 'Additional_Message__c'
	};

	public static final String ACT_HOME_FIELD = !Test.isRunningTest() ? 'Guest_Home__c' : 'Guest_Home__c';
	public static final String OPP_HOME_FIELD = !Test.isRunningTest() ? 'Homes_Mentioned__c' : 'Homes_Mentioned__c';
	public static final String ACT_MARKET_FIELD = !Test.isRunningTest() ? 'Market__c' : 'Market__c';
	public static final String ENQ_MESSAGE_FIELD = !Test.isRunningTest() ? 'Additional_Message__c' : 'Additional_Message__c';
	public static final String REQUIRED_DUP_CHECK_FIELD = !Test.isRunningTest() ? 'RequiresDupCheck__c' : 'RequiresDupCheck__c';

	public static final String ACT_HOME_FIELD_BATCH = 'Guest_Home__c';
	public static final String OPP_HOME_FIELD_BATCH = 'Homes_Mentioned__c';
	public static final String ACT_MARKET_FIELD_BATCH = 'Market__c';
	public static final String ENQ_MESSAGE_FIELD_BATCH = 'Additional_Message__c';
	public static final String OVERRIDE_FIELD = 'Override__c';

}
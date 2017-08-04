public with sharing class AutoMergeResultCtrl {

	private static final String FILTER_DETAILS_URL = 'apex/FilterDetails?Filter=';

	public static final String NEW_ID_URL_PARAM = 'newid';

	private List<AutoMergeResult__c> userMergeResults { private get; private set; }

	public Boolean wasMerged { get; private set; }
	public String redirectLink { get; private set; }
	public String infoMessage { get; private set; }

	public void init() {
		if (userMergeResults != null && !userMergeResults.isEmpty()) {
			delete [
				SELECT Id
				FROM AutoMergeResult__c
				WHERE UserId__c = :UserInfo.getUserId()
					AND Id != :userMergeResults[0].Id
			];
		}
	}

	public AutoMergeResultCtrl() {
		try {
			String parameter = ApexPages.currentPage().getParameters().get(NEW_ID_URL_PARAM);
			String objectType = Enums.OBJECT_MAPPING.get(parameter.left(3));

			if (parameter != null) {
				List<SObject> newRecordList = Database.query(
					Constants.QUERY_SELECT + Constants.SPACE_SYMBOL + Constants.FIELD_NAME_FOR_ID + Constants.SPACE_SYMBOL +
					Constants.QUERY_FROM + Constants.SPACE_SYMBOL +	objectType + Constants.SPACE_SYMBOL +
					Constants.QUERY_WHERE + Constants.SPACE_SYMBOL + Constants.FIELD_NAME_FOR_ID + Constants.SPACE_SYMBOL +
					Constants.EQUAL_SYMBOL + Constants.SPACE_SYMBOL + '\'' + parameter + '\''
				);

				if (!newRecordList.isEmpty()) {
					wasMerged = false;

					redirectLink = Url.getSalesforceBaseUrl().toExternalForm() + Constants.SLASH_SYMBOL + parameter;
				}
				else {
					userMergeResults = [
						SELECT ResultId__c, Filter__c, Filter__r.Name,
							Filter__r.TargetObjectType__c, Filter__r.SourceObjectType__c
						FROM AutoMergeResult__c
						WHERE UserId__c = :UserInfo.getUserId()
						ORDER BY LastModifiedDate DESC
					];

					if (!userMergeResults.isEmpty()) {
						List<SObject> mergedRecordList = Database.query(
							Constants.QUERY_SELECT + Constants.SPACE_SYMBOL + Constants.FIELD_NAME_FOR_NAME + Constants.SPACE_SYMBOL +
							Constants.QUERY_FROM + Constants.SPACE_SYMBOL +	Enums.OBJECT_MAPPING.get(String.valueOf(userMergeResults[0].ResultId__c).left(3)) + Constants.SPACE_SYMBOL +
							Constants.QUERY_WHERE + Constants.SPACE_SYMBOL + Constants.FIELD_NAME_FOR_ID + Constants.SPACE_SYMBOL +
							Constants.EQUAL_SYMBOL + Constants.SPACE_SYMBOL + '\'' + userMergeResults[0].ResultId__c + '\''
						);
						if (!mergedRecordList.isEmpty()) {
							wasMerged = true;
							redirectLink = Url.getSalesforceBaseUrl().toExternalForm() + Constants.SLASH_SYMBOL + mergedRecordList[0].get(Constants.FIELD_NAME_FOR_ID);

							infoMessage =  String.format(
								Label.AutoMergeResultInfo,
								new List<String>{
									(
										String.format(
											Constants.HTML_TAG_A,
											new List<String>{
												(Url.getSalesforceBaseUrl().toExternalForm()
													+ Constants.SLASH_SYMBOL + FILTER_DETAILS_URL + userMergeResults[0].Filter__c),
												userMergeResults[0].Filter__r.Name
											}
										)
									),
									(
										String.format(
											Constants.HTML_TAG_A,
											new List<String>{
												(Url.getSalesforceBaseUrl().toExternalForm()
													+ Constants.SLASH_SYMBOL + String.valueOf(userMergeResults[0].ResultId__c).left(3)),
												(
													Enums.OBJECT_MAPPING.get(
														String.valueOf(
															userMergeResults[0].ResultId__c
														).left(3)
													)
												)
											}
										)
									),
									(
										String.valueOf(
											mergedRecordList[0].get(
												Constants.FIELD_NAME_FOR_NAME
											)
										)
									)
								}
							);
						}
						else {
							wasMerged = false;
							redirectLink = Url.getSalesforceBaseUrl().toExternalForm() + Constants.SLASH_SYMBOL + parameter.left(3);
						}
					}
					else {
						wasMerged = false;
						redirectLink = Url.getSalesforceBaseUrl().toExternalForm() + Constants.SLASH_SYMBOL + parameter.left(3);
					}
				}
			}
		}
		catch (Exception exc) {
			wasMerged = false;
			redirectLink = Url.getSalesforceBaseUrl().toExternalForm() + Constants.SLASH_SYMBOL + Constants.HOME_URL;
		}
	}

}
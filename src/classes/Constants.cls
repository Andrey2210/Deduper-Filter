public with sharing class Constants {

	public static final Integer RECORD_ACCESS_SIZE = 200;
	public static final Integer RECORD_MERGE_SIZE = 50;

	public static final String QUERY_SELECT = 'SELECT';
	public static final String QUERY_FROM = 'FROM';
	public static final String QUERY_WHERE = 'WHERE';
	public static final String QUERY_LIMIT = 'LIMIT';
	public static final String QUERY_NOT = 'NOT';
	public static final String QUERY_IN = 'IN';
	public static final String QUERY_LIKE = 'LIKE';
	public static final String QUERY_USER_READ_ACCESS = 'UserRecordAccess.HasReadAccess';

	public static final String EMPTY_SYMBOL = '';
	public static final String SPACE_SYMBOL = ' ';
	public static final String COMMA_SYMBOL = ',';
	public static final String DOT_SYMBOL = '.';
	public static final String COLON_SYMBOL = ':';
	public static final String SEMICOLON_SYMBOL = ';';
	public static final String EQUAL_SYMBOL = '=';
	public static final String NEQUAL_SYMBOL = '!=';
	public static final String PLUS_SYMBOL = '+';
	public static final String SLASH_SYMBOL = '/';
	public static final String QUESTION_SYMBOL = '?';
	public static final String AMPERSAND_SYMBOL = '&';
	public static final String NEW_LINE_SYMBOL = '\n';
	public static final String LEFT_PAR = '(';
	public static final String RIGHT_PAR = ')';
	public static final String SQUOTE = '\'';
	public static final String PERCENT = '%';
	public static final String LBRAC = '<';
	public static final String RBRAC = '>';

	public static final String NULL_SMNT = 'null';
	public static final String TRUE_SMNT = 'true';

	public static final String FIELD_NAME_FOR_ID = 'Id';
	public static final String FIELD_NAME_FOR_NAME = 'Name';
	public static final String FIELD_NAME_FOR_OWNER_ID = 'OwnerId';
	public static final String FIELD_NAME_FOR_LAST_MODIFIED_DATE = 'LastModifiedDate';

	public static final String TASK_PRIORITY_NORMAL = 'Normal';
	public static final String TASK_STATUS_OPEN = 'Open';
	public static final String TASK_STATUS_NOT_STARTED = 'Not Started';

	public static final String HTML_TAG_BR = '<br/>';
	public static final String HTML_TAG_A = '<a target="_blank" href="{0}">{1}</a>';

	public static final String HOME_URL = 'home/home.jsp';
	public static final String EDIT_URL = '/e';

	public static final String AND_CONST = 'AND';
	public static final String OR_CONST = 'OR';

	/*
	 * Used in FilterDetailsController
	 */
	public static final String REPORT_DUPLICATE = 'Report Duplicate';
	public static final String FIRST_N = 'First N';
	public static final String FIRST_N_LETTERS = 'First N Letters';
	public static final String FIRST_N_WORDS = 'First N Words';
	public static final String N_DAYS = '+/- N days';
	public static final Integer MAX_FIRST_N_LETTERS = 20;
	public static final Integer MAX_FIRST_N_WORDS = 15;
	public static final Integer MAX_N_DAYS = 365;

	/*
	 *
	 */
	public static final String MERGE_ACT_APPEND = 'append';
	public static final String MERGE_ACT_PREPEND = 'prepend';
	public static final String MERGE_ACT_REPLACE = 'replace';

	public static final String MERGE_ACT_DATE = 'date';
	public static final String MERGE_ACT_SPACE = 'space';
	public static final String MERGE_ACT_LINE = 'line';
	public static final String MERGE_ACT_SEMICOL = SEMICOLON_SYMBOL;
	public static final String MERGE_ACT_COMMA = COMMA_SYMBOL;

}
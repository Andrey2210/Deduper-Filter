public with sharing class Utils {

    public final static String RECORD_TYPE_NAME = 'RecordTypeId';

    /*
     * Early version for simple queries
     */
    /*public static String generateQuery(Set<String> selectedFieldsSet, String objectName,
        Integer selectedLimit) {

        List<String> selectedFields = new List<String>(selectedFieldsSet);

        Map<String, Schema.RecordTypeInfo> availableRecordTypes = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByName();
        if (availableRecordTypes.keySet().size() > 1) {
            selectedFields.add(RECORD_TYPE_NAME);
        }

        String query = Constants.QUERY_SELECT;

        for (Integer i = 0; i < selectedFields.size(); i++) {
            query += Constants.SPACE_SYMBOL;
            query += selectedFields.get(i);

            if (i != (selectedFields.size() - 1)) {
                query += Constants.COMMA_SYMBOL;
            }
        }

        query += Constants.SPACE_SYMBOL;
        query += Constants.QUERY_FROM;
        query += Constants.SPACE_SYMBOL;
        query += objectName;

        query += Constants.SPACE_SYMBOL;
        query += Constants.QUERY_LIMIT;
        query += Constants.SPACE_SYMBOL;
        query += selectedLimit;

        return query;
    }*/

    public static String generateQuery(Set<String> selectedFieldsSet, String objectName,
        Integer selectedLimit, List<Rule__c> matchingRules, SObject sourceObject, Boolean ifAndLogic) {

        List<String> selectedFields = new List<String>(selectedFieldsSet);

        Map<String, Schema.RecordTypeInfo> availableRecordTypes = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByName();
        if (availableRecordTypes.keySet().size() > 1) {
            selectedFields.add(RECORD_TYPE_NAME);
        }

        String query = Constants.QUERY_SELECT;

        for (Integer i = 0; i < selectedFields.size(); i++) {
            query += Constants.SPACE_SYMBOL;
            query += selectedFields.get(i);

            if (i != (selectedFields.size() - 1)) {
                query += Constants.COMMA_SYMBOL;
            }
        }

        query += Constants.SPACE_SYMBOL;
        query += Constants.QUERY_FROM;
        query += Constants.SPACE_SYMBOL;
        query += objectName;

        query += Constants.SPACE_SYMBOL;
        query += Constants.QUERY_WHERE;

        query = addConditionsFromRules(query, matchingRules, sourceObject, ifAndLogic);

        query += Constants.SPACE_SYMBOL;
        query += Constants.QUERY_LIMIT;
        query += Constants.SPACE_SYMBOL;
        query += selectedLimit;

        return query;
    }

    private static String addConditionsFromRules(String query, List<Rule__c> matchingRules, SObject sourceObject, Boolean ifAndLogic) {
        String expressionLogic = ifAndLogic ? Constants.AND_CONST : Constants.OR_CONST;

        Boolean wasRuleAdded = false;
        for (Rule__c rule : matchingRules) {

            Enums.MatchingApproach ruleApproach = Enums.MATCHING_APPROACH.get(rule.MatchingApproach__c);
            String sourceField = rule.SourceField__c;
            String targetField = rule.TargetField__c;
            String iterField = String.valueOf(sourceObject.get(sourceField));
            if (iterField != null) {
                iterField = String.escapeSingleQuotes(iterField);
            }

            if (ruleApproach == null) {
                continue;
            }
            else if (!rule.MatchBlanks__c && (String.isEmpty(iterField))) {
                query = wasRuleAdded ? (query + expressionLogic + Constants.SPACE_SYMBOL) : (query + Constants.SPACE_SYMBOL);
                query += Constants.LEFT_PAR;

                query += targetField;
                query += Constants.NEQUAL_SYMBOL;
                query += Constants.NULL_SMNT;

                query += Constants.SPACE_SYMBOL;
                query += Constants.AND_CONST;
                query += Constants.SPACE_SYMBOL;

                query += targetField;
                query += Constants.EQUAL_SYMBOL;
                query += Constants.NULL_SMNT;

                query += Constants.RIGHT_PAR;

                wasRuleAdded = true;

                continue;
            }
            else if (rule.MatchBlanks__c && (String.isEmpty(iterField))) {
                if (sourceObject.getSObjectType().getDescribe().fields.getMap().get(sourceField).getDescribe().getType() == Schema.DisplayType.Date) {
                    query = wasRuleAdded ? (query + expressionLogic + Constants.SPACE_SYMBOL) : (query + Constants.SPACE_SYMBOL);
                    query += Constants.LEFT_PAR;

                    query += targetField;
                    query += Constants.EQUAL_SYMBOL;
                    query += Constants.NULL_SMNT;

                    query += Constants.RIGHT_PAR;

                    wasRuleAdded = true;
                }
                else if (sourceObject.getSObjectType().getDescribe().fields.getMap().get(sourceField).getDescribe().getType() == Schema.DisplayType.Datetime) {
                    query = wasRuleAdded ? (query + expressionLogic + Constants.SPACE_SYMBOL) : (query + Constants.SPACE_SYMBOL);
                    query += Constants.LEFT_PAR;

                    query += targetField;
                    query += Constants.EQUAL_SYMBOL;
                    query += Constants.NULL_SMNT;

                    query += Constants.RIGHT_PAR;

                    wasRuleAdded = true;
                }
                else if (sourceObject.getSObjectType().getDescribe().fields.getMap().get(sourceField).getDescribe().getType() == Schema.DisplayType.Boolean
                    || sourceObject.getSObjectType().getDescribe().fields.getMap().get(sourceField).getDescribe().getType() == Schema.DisplayType.Currency
                    || sourceObject.getSObjectType().getDescribe().fields.getMap().get(sourceField).getDescribe().getType() == Schema.DisplayType.Double
                    || sourceObject.getSObjectType().getDescribe().fields.getMap().get(sourceField).getDescribe().getType() == Schema.DisplayType.Integer
                    || sourceObject.getSObjectType().getDescribe().fields.getMap().get(sourceField).getDescribe().getType() == Schema.DisplayType.Percent) {
                
                    query = wasRuleAdded ? (query + expressionLogic + Constants.SPACE_SYMBOL) : (query + Constants.SPACE_SYMBOL);
                    query += Constants.LEFT_PAR;

                    query += targetField;
                    query += Constants.EQUAL_SYMBOL;
                    query += Constants.NULL_SMNT;

                    query += Constants.RIGHT_PAR;

                    wasRuleAdded = true;
                }
                else {
                    query = wasRuleAdded ? (query + expressionLogic + Constants.SPACE_SYMBOL) : (query + Constants.SPACE_SYMBOL);
                    query += Constants.LEFT_PAR;

                    query += targetField;
                    query += Constants.EQUAL_SYMBOL;
                    query += Constants.SQUOTE;
                    query += Constants.SQUOTE;

                    query += Constants.RIGHT_PAR;

                    wasRuleAdded = true;
                }
            }
            else if (ruleApproach == Enums.MatchingApproach.EXACT) {
                if (sourceObject.getSObjectType().getDescribe().fields.getMap().get(sourceField).getDescribe().getType() == Schema.DisplayType.Date) {
                    try {
                        query = wasRuleAdded ? (query + expressionLogic + Constants.SPACE_SYMBOL) : (query + Constants.SPACE_SYMBOL);
                        query += Constants.LEFT_PAR;

                        Date iterDate = (Date) sourceObject.get(sourceField);

                        query += targetField;
                        query += Constants.EQUAL_SYMBOL;
                        query += String.valueOf(iterDate);

                        query += Constants.RIGHT_PAR;
                        wasRuleAdded = true;
                    }
                    catch (Exception exc) {
                        //ssh...
                    }
                }
                else if (sourceObject.getSObjectType().getDescribe().fields.getMap().get(sourceField).getDescribe().getType() == Schema.DisplayType.Datetime) {
                    try {
                        query = wasRuleAdded ? (query + expressionLogic + Constants.SPACE_SYMBOL) : (query + Constants.SPACE_SYMBOL);
                        query += Constants.LEFT_PAR;

                        Datetime iterDatetime = (Datetime) sourceObject.get(sourceField);

                        query += targetField;
                        query += Constants.EQUAL_SYMBOL;
                        query += String.valueOf(iterDatetime).substring(0, 10);
                        query += 'T00:00:00Z';

                        query += Constants.RIGHT_PAR;
                        wasRuleAdded = true;
                    }
                    catch (Exception exc) {
                        //ssh...
                    }
                }
                else if (sourceObject.getSObjectType().getDescribe().fields.getMap().get(sourceField).getDescribe().getType() == Schema.DisplayType.Boolean
                    || sourceObject.getSObjectType().getDescribe().fields.getMap().get(sourceField).getDescribe().getType() == Schema.DisplayType.Currency
                    || sourceObject.getSObjectType().getDescribe().fields.getMap().get(sourceField).getDescribe().getType() == Schema.DisplayType.Double
                    || sourceObject.getSObjectType().getDescribe().fields.getMap().get(sourceField).getDescribe().getType() == Schema.DisplayType.Integer
                    || sourceObject.getSObjectType().getDescribe().fields.getMap().get(sourceField).getDescribe().getType() == Schema.DisplayType.Percent) {
                    
                    query = wasRuleAdded ? (query + expressionLogic + Constants.SPACE_SYMBOL) : (query + Constants.SPACE_SYMBOL);
                    query += Constants.LEFT_PAR;

                    query += targetField;
                    query += Constants.EQUAL_SYMBOL;
                    query += iterField;

                    query += Constants.RIGHT_PAR;

                    wasRuleAdded = true;
                }
                else {
                    query = wasRuleAdded ? (query + expressionLogic + Constants.SPACE_SYMBOL) : (query + Constants.SPACE_SYMBOL);
                    query += Constants.LEFT_PAR;

                    query += targetField;
                    query += Constants.EQUAL_SYMBOL;
                    query += Constants.SQUOTE;
                    query += iterField;
                    query += Constants.SQUOTE;

                    query += Constants.RIGHT_PAR;

                    wasRuleAdded = true;
                }
            }
            else if (ruleApproach == Enums.MatchingApproach.FIRST_N_LETTERS) {
                query = wasRuleAdded ? (query + expressionLogic + Constants.SPACE_SYMBOL) : (query + Constants.SPACE_SYMBOL);
                query += Constants.LEFT_PAR;

                Boolean fieldsLessLength = iterField.length() < Integer.valueOf(rule.FirstN__c);

                if (!fieldsLessLength) {
                    query += targetField;
                    query += Constants.SPACE_SYMBOL;
                    query += Constants.QUERY_LIKE;
                    query += Constants.SPACE_SYMBOL;
                    query += Constants.SQUOTE;
                    query += iterField.left(Integer.valueOf(rule.FirstN__c)) + Constants.PERCENT;
                    query += Constants.SQUOTE;

                    query += Constants.SPACE_SYMBOL;
                    query += Constants.OR_CONST;
                }

                Integer iterateFrom = fieldsLessLength ? iterField.length() : (Integer.valueOf(rule.FirstN__c) - 1);

                for (Integer i = iterateFrom; i > 0; i--) {
                    query += Constants.SPACE_SYMBOL;

                    query += targetField;
                    query += Constants.EQUAL_SYMBOL;
                    query += Constants.SQUOTE;
                    query += iterField.left(iterateFrom);
                    query += Constants.SQUOTE;
                    if (i != 1) {
                        query += Constants.SPACE_SYMBOL;
                        query += Constants.OR_CONST;
                    }
                }

                query += Constants.RIGHT_PAR;

                wasRuleAdded = true;
            }
            else if (ruleApproach == Enums.MatchingApproach.FIRST_N_WORDS) {
                query = wasRuleAdded ? (query + expressionLogic + Constants.SPACE_SYMBOL) : (query + Constants.SPACE_SYMBOL);
                query += Constants.LEFT_PAR;

                Boolean fieldsLessLength = iterField.split(Constants.SPACE_SYMBOL).size() < Integer.valueOf(rule.FirstN__c);

                if (!fieldsLessLength) {
                    query += targetField;
                    query += Constants.SPACE_SYMBOL;
                    query += Constants.QUERY_LIKE;
                    query += Constants.SPACE_SYMBOL;
                    query += Constants.SQUOTE;
                    for (Integer i = 0; i < Integer.valueOf(rule.FirstN__c); i++) {
                        query += iterField.split(Constants.SPACE_SYMBOL)[i];
                        if (i < Integer.valueOf(rule.FirstN__c) - 1) {
                            query += Constants.SPACE_SYMBOL;
                        }
                    }
                    query += Constants.PERCENT;
                    query += Constants.SQUOTE;

                    query += Constants.SPACE_SYMBOL;
                    query += Constants.OR_CONST;
                }

                Integer iterateFrom = fieldsLessLength ? iterField.split(Constants.SPACE_SYMBOL).size() : (Integer.valueOf(rule.FirstN__c) - 1);

                for (Integer i = iterateFrom; i > 0; i--) {
                    query += Constants.SPACE_SYMBOL;

                    query += targetField;
                    query += Constants.EQUAL_SYMBOL;
                    query += Constants.SQUOTE;
                    for (Integer j = 0; j < i; j++) {
                        query += iterField.split(Constants.SPACE_SYMBOL)[j];
                        if (j != i - 1) {
                            query += Constants.SPACE_SYMBOL;
                        }
                    }
                    query += Constants.SQUOTE;
                    if (i != 1) {
                        query += Constants.SPACE_SYMBOL;
                        query += Constants.OR_CONST;
                    }
                }

                query += Constants.RIGHT_PAR;

                wasRuleAdded = true;
            }
            else if (ruleApproach == Enums.MatchingApproach.N_DAYS) {
                try {
                    query = wasRuleAdded ? (query + expressionLogic + Constants.SPACE_SYMBOL) : (query + Constants.SPACE_SYMBOL);
                    query += Constants.LEFT_PAR;

                    if (sourceObject.getSObjectType().getDescribe().fields.getMap().get(sourceField).getDescribe().getType() == Schema.DisplayType.Date) {
                        Date iterDate = (Date) sourceObject.get(sourceField);
                        Date earlDate = iterDate.addDays(Integer.valueOf(rule.FirstN__c) * -1);
                        Date lateDate = iterDate.addDays(Integer.valueOf(rule.FirstN__c));

                        query += targetField;
                        query += Constants.LBRAC;
                        query += String.valueOf(lateDate);
                        query += Constants.SPACE_SYMBOL;
                        query += Constants.AND_CONST;
                        query += Constants.SPACE_SYMBOL;
                        query += targetField;
                        query += Constants.RBRAC;
                        query += String.valueOf(earlDate);
                    }
                    else if (sourceObject.getSObjectType().getDescribe().fields.getMap().get(sourceField).getDescribe().getType() == Schema.DisplayType.Datetime) {
                        Datetime iterDatetime = (Datetime) sourceObject.get(sourceField);
                        Datetime earlDate = iterDatetime.addDays(Integer.valueOf(rule.FirstN__c) * -1);
                        Datetime lateDate = iterDatetime.addDays(Integer.valueOf(rule.FirstN__c));

                        query += targetField;
                        query += Constants.LBRAC;
                        query += String.valueOf(lateDate).substring(0, 10);
                        query += 'T00:00:00Z';
                        query += Constants.SPACE_SYMBOL;
                        query += Constants.AND_CONST;
                        query += Constants.SPACE_SYMBOL;
                        query += targetField;
                        query += Constants.RBRAC;
                        query += String.valueOf(earlDate).substring(0, 10);
                        query += 'T00:00:00Z';
                    }

                    query += Constants.RIGHT_PAR;
                    wasRuleAdded = true;
                }
                catch (Exception exc) {
                    //ssh...
                }
            }
        }

        if (!wasRuleAdded) {
            query = query.left(query.length() - Constants.QUERY_WHERE.length());
        }

        return query;
    }

    public static SObject getNewObjectByType(String type) {
        String objectSchemeType = Enums.FILTER_TYPES_MAP_TO_SCHEMA.get(type);

        if (objectSchemeType == Schema.sObjectType.Opportunity.Name) {
            return new Opportunity();
        }
        else if (objectSchemeType == Schema.sObjectType.Contact.Name) {
            return new Contact();
        }
        else if (objectSchemeType == Schema.sObjectType.Account.Name) {
            return new Account();
        }
        else if (objectSchemeType == Schema.sObjectType.Lead.Name) {
            return new Lead();
        }
        else if (objectSchemeType == Schema.sObjectType.Order.Name) {
            return new Order();
        }
        else {
            return null;
        }
    }

    public static void sortByDateTime(List<SObject> listToSort, String fieldName){

        for(Integer i = listToSort.size()-1 ; i >= 0 ; i--){
            for(Integer j = 0 ; j < i ; j++){
                if((Datetime)listToSort[j].get(fieldName) > (Datetime)listToSort[j+1].get(fieldName)){
                    SObject tmp = listToSort[j];
                    listToSort[j] = listToSort[j+1];
                    listToSort[j+1] = tmp;
                }
            }
        }
    }

    public static String getSchedulableStringPlusMinutes(Integer minutes) {
            String day = string.valueOf(system.now().day());
            String month = string.valueOf(system.now().month());
            String hour = string.valueOf(system.now().hour());
            String minute = string.valueOf(system.now().minute() + minutes);
            String second = string.valueOf(system.now().second());
            String year = string.valueOf(system.now().year());

            return '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
    }

    public static void scheduleJob(String objectName, TriggerHandler.Events event) {
        String expectedName = objectName + 
            Constants.SPACE_SYMBOL + 
            event.name() +
            Constants.PERCENT;

        List<CronTrigger> cronTriggers = [
            SELECT CronJobDetail.Name
            FROM CronTrigger
            WHERE CronJobDetail.Name LIKE :expectedName
                AND State = 'WAITING'
        ];
        if (!cronTriggers.isEmpty()) {
            return;
        }
        
        try {
            Integer minutesValue;
            try {
                minutesValue = Integer.valueOf(Deduper_Custom_Settings__c.getInstance().Schedule_Delay__c);
            }
            catch (Exception exc) {
                minutesValue = 5;
            }

            DuplicatesHandlingSchedulable scheduledJob = new DuplicatesHandlingSchedulable(
                objectName, 
                event
            );
            String scheduledStr = Utils.getSchedulableStringPlusMinutes(
                minutesValue
            );
            System.schedule(
                objectName + 
                Constants.SPACE_SYMBOL + 
                event.name() + 
                Constants.SPACE_SYMBOL +
                Datetime.now().format(), 
                scheduledStr, scheduledJob
            );
        }
        catch (Exception exc) {
            //silence
        }
        finally {
            TriggerHandler.isScheduled = true;
        }
        
    }

}
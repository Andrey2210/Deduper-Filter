public with sharing class FilterDetailsController {

    public FilterDetailsController() {
        selectedMachingAproach = '';
        loadFilter();
    }

    private final static List<String> filterTypes = new List<String> {
        'Opportunity',
        'Contact',
        'Account',
        'Enquiries',
        'Bookings'
    };

    public List<SelectOption> optionsMatchOnInsert { get {
            return getPickListOptions(Filter__c.MatchOnInsert__c.getDescribe());
        }
        set;
    }

    public List<SelectOption> optionsMatchOnUpdate { get {
            return getPickListOptions(Filter__c.MatchOnUpdate__c.getDescribe());
        }
        set;
    }

    private List<SelectOption> getPickListOptions(Schema.DescribeFieldResult fieldResult) {
            List<SelectOption> options = new List<SelectOption>();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

           for( Schema.PicklistEntry f : ple)
           {
              options.add(new SelectOption(f.getLabel(), f.getValue()));
           }
           return options;
    }

    public List<SelectOption> targetObjectFields { get {
            List<SelectOption> result = new List<SelectOption>();
            Boolean targetFlag = true;
            result.addAll(getFields(targetFlag, selectedTargetObjectType,
                (!String.isEmpty(selectedSourceField)), currentMergeRule != null));
            return result;
        }
        set;
    }

    public List<SelectOption> sourceObjectFields { get {
            List<SelectOption> result = new List<SelectOption>();
            Boolean targetFlag = false;
            result.addAll(getFields(targetFlag, selectedSourceObjectType, false, currentMergeRule != null));
            return result;
        }
        set;
    }

    public final static Map<String, Set<String>> notAllowedFields = new Map<String, Set<String>>{
        'Opportunity' => new Set<String>{
             'ID',         
             'ISDELETED',
             'ISPRIVATE',
             'ISCLOSED',
             'ISWON',
             'FORECASTCATEGORY',
             'CURRENCYISOCODE',
             'HASOPPORTUNITYLINEITEMS',
             'PRICEBOOKID',
             'CREATEDDATE',
             'CREATEDBYID',
             'LASTMODIFIEDDATE',
             'LASTMODIFIEDBYID',
             'SYSTEMMODSTAMP',
             'LASTACTIVITYDATE',
             'FISCAL',
             'FISCALQUARTER',
             'FISCALYEAR',
             'LASTVIEWDATE',
             'LASTREFERENCEDATE',
             'SYNCQUOTEID'
        },
        'Contact' => new Set<String>{
            'ISDELETED',
            'CURRENCYISOCODE',
            'CREATEDDATE',
            'CREATEDBYID',
            'LASTMODIFIEDDATE',
            'LASTMODIFIEDBYID',
            'SYSTEMMODSTAMP',
            'LASTACTIVITYDATE',
            'SUFFIX'
        },
        'Account' => new Set<String>{
            'SUFFIX'
         },
        'Lead' => new Set<String>{
            'SUFFIX',
            'OWNERID',
            'CONVERTED',
            'ISUNREADBYOWNER',
            'ADDITIONAL MESSAGE'
         },
        'Order' => new Set<String>{
            'PROCEBOOKID'
        }

    };

    public static String customToStandart(String type) {
        String result = '';
        if(type == 'Opportunity')
            result = 'Opportunity';
        else if(type == 'Contact')
            result = 'Contact';
        else if(type == 'Account')
            result = 'Account';
        else if(type == 'Enquiries')
            result = 'Lead';
        else if(type == 'Bookings')
            result = 'Order';
        return result;
    }

    public static Map<String, Map<String, String>> objectFieldNamesDict { get {
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Map<String, String>> result = new Map<String, Map<String, String>>();
        List<String> types = new List<String>{
            'Opportunity','Contact','Account','Enquiries','Bookings'
        };
        for (String type : types) {
            String defType = FilterDetailsController.customToStandart(type);
            Map<String, Schema.SObjectType> gdesc = Schema.getGlobalDescribe();
            Sobject objectt = gdesc.get(defType).newSObject();
            Map<String, SObjectField> fields = objectt.getSObjectType().getDescribe().fields.getMap();
            result.put(type.toUpperCase(), new Map<String, String>());
            for(SObjectField f : fields.values()){
                if((f.getDescribe().isUpdateable() && f.getDescribe().isCreateable() || f.getDescribe().isCalculated()) &&
                   !notAllowedFields.get(defType).contains(f.getDescribe().getLabel()))
                    result.get(type.toUpperCase()).put(f.getDescribe().getName().toUpperCase(), f.getDescribe().getLabel());
            }
        }
        return result;
    }
       private set;
    }

    private List<SelectOption> getFields(Boolean targetFlag, String objType, Boolean matchType, Boolean mergeRule) {
            Schema.SObjectField sField;
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            List<SelectOption> result = new List<SelectOption>();
            String type = FilterDetailsController.customToStandart(objType);
            Map<String, Schema.SObjectType> gdesc = Schema.getGlobalDescribe();
            Sobject objectt = gdesc.get(type).newSObject();

            Map<String, Schema.SObjectField> fields = objectt.getSObjectType().getDescribe().fields.getMap();
            if (matchType) {
                SObject sourceObj = gdesc.get(FilterDetailsController.customToStandart(selectedSourceObjectType)).newSObject();
                Map<String, Schema.SObjectField> shemaSourceFields =
                    sourceObj.getSObjectType().getDescribe().fields.getMap();
                sField = shemaSourceFields.get(selectedSourceField);
            }
            for (Schema.SObjectField f : fields.values()) {
                Boolean isCalculated = f.getDescribe().isCalculated() && !mergeRule;
                Boolean isUpdateble = f.getDescribe().isUpdateable();
                Boolean isCreateable = f.getDescribe().isCreateable();
                Boolean isExternalId = f.getDescribe().isExternalId();
                Boolean isAllowed = notAllowedFields.get(type).contains(f.getDescribe().getLabel().toUpperCase());
                Schema.DisplayType fieldType = f.getDescribe().getType();
                List<Schema.SObjectType> refList;
                Boolean isTypeMatch = matchType ? matchType(sField, f) : true;
                if ((isUpdateble || isCreateable || isCalculated) && !isAllowed && isTypeMatch && !isExternalId) {
                    result.add(
                        new SelectOption(f.getDescribe().getName(),
                        f.getDescribe().getLabel()
                    ));
                }
            }
            return result;
    }
    Boolean matchFieldIsMultiPicklist { get; private set; }
    Boolean matchFieldIsTextArea { get; private set; }

    /*List<SelectOption> optionsFieldIsMultiPicklist { get {
            List<SelectOption> result = new List<SelectOption>();
            Schema.DescribeFieldResult mergeActions = MergeRule__c.MergeAction__c.getDescribe();
            List<Schema.PicklistEntry> mergeActionValues = mergeActions.getPicklistValues();
            for(Schema.PicklistEntry entry : mergeActionValues) {
                if(entry.getLabel().equals('replace') || entry.getLabel().equals('append'))
                    result.add(new SelectOption(entry.getValue(), entry.getLabel()));
            }
            return result;
        }
        set;
    }
    List<SelectOption> optionsFieldIsTextArea { get {
            List<SelectOption> result = new List<SelectOption>();
            Schema.DescribeFieldResult mergeActions = MergeRule__c.MergeAction__c.getDescribe();
            List<Schema.PicklistEntry> mergeActionValues = mergeActions.getPicklistValues();
            for(Schema.PicklistEntry entry : mergeActionValues) {
                if(!entry.getLabel().equals('replace') || !entry.getLabel().equals('append'))
                    result.add(new SelectOption(entry.getValue(), entry.getLabel()));
            }
            return result;
        }
        set;
    }*/
    public List<SelectOption> optionsMatchLogic { get {
            List<SelectOption> result = new List<SelectOption>();
            Schema.DescribeFieldResult matchLogic = Filter__c.MatchLogic__c.getDescribe();
            List<Schema.PicklistEntry> matchLogicValues = matchLogic.getPicklistValues();
            for(Schema.PicklistEntry entry : matchLogicValues) {
                    result.add(new SelectOption(entry.getValue(), entry.getLabel()));
            }
            return result;
        }
        set;
    }
    Boolean matchType(Schema.SObjectField source, Schema.SObjectField target) {
        if (source.getDescribe().isCalculated() && source.getDescribe().getType() == Schema.DisplayType.String) {
            if ((target.getDescribe().getType() == target.getDescribe().getType())
                ||(target.getDescribe().getType() == Schema.DisplayType.Email)
                ||(target.getDescribe().getType() == Schema.DisplayType.Phone)
                ||(target.getDescribe().getType() == Schema.DisplayType.Address)
                ||(target.getDescribe().getType() == Schema.DisplayType.String)) {
                
                return true;
            }            
        }
        if (target.getDescribe().isCalculated() && target.getDescribe().getType() == Schema.DisplayType.String) {
            if ((source.getDescribe().getType() == target.getDescribe().getType())
                ||(source.getDescribe().getType() == Schema.DisplayType.Email)
                ||(source.getDescribe().getType() == Schema.DisplayType.Phone)
                ||(source.getDescribe().getType() == Schema.DisplayType.Address)
                ||(source.getDescribe().getType() == Schema.DisplayType.String)) {
                
                return true;
            }            
        }
        return source.getDescribe().getType() == target.getDescribe().getType();
    }

    public List<SelectOption> optionsMachingAproach { get {
            List<SelectOption> result = new List<SelectOption>();
            Schema.DescribeFieldResult matchingApproach = Rule__c.MatchingApproach__c.getDescribe();
            List<Schema.PicklistEntry> matchingApproachValues = matchingApproach.getPicklistValues();
            for(Schema.PicklistEntry entry : matchingApproachValues) {
                if(selectedFieldType != Schema.DisplayType.Date &&
                   selectedFieldType != Schema.DisplayType.DateTime) {
                   
                   if (selectedFieldType == Schema.DisplayType.Boolean
                    || selectedFieldType == Schema.DisplayType.Currency
                    || selectedFieldType == Schema.DisplayType.Double
                    || selectedFieldType == Schema.DisplayType.Integer
                    || selectedFieldType == Schema.DisplayType.Percent) {
                   
                       if (!entry.getValue().equals('+/- N days')
                           && !entry.getValue().contains('First')) {
                           
                           result.add(new SelectOption(entry.getValue(), entry.getLabel()));
                       }
                   }
                   
                   else if(!entry.getValue().equals('+/- N days')) {
                       result.add(new SelectOption(entry.getValue(), entry.getLabel()));
                   }
                }
                else {
                    if(entry.getValue().equals('+/- N days') || entry.getValue().equals('Exact')) {
                        result.add(new SelectOption(entry.getValue(), entry.getLabel()));
                    }
                }

            }
            return result;
        }
        private set;
    }
    public List<SelectOption> optionsCreateTasks { get {
            List<SelectOption> result = new List<SelectOption>();
            Schema.DescribeFieldResult createTask = Filter__c.CreateTasks__c.getDescribe();
            List<Schema.PicklistEntry> createTaskValues = createTask.getPicklistValues();
            for(Schema.PicklistEntry entry : createTaskValues) {
                 result.add(new SelectOption(entry.getValue(), entry.getLabel()));
            }
            return result;
        }
        private set;
    }
    public List<SelectOption> optionsMergeAction { get {
            List<SelectOption> result = new List<SelectOption>();
            Schema.DescribeFieldResult mergeAction = MergeRule__c.MergeAction__c.getDescribe();
            List<Schema.PicklistEntry> mergeActionValues = mergeAction.getPicklistValues();
            for (Schema.PicklistEntry entry : mergeActionValues) {
                if (selectedFieldType == Schema.DisplayType.MultiPicklist) {

                    if (entry.getValue().equals('replace') || entry.getValue().equals('append')) {
                        result.add(new SelectOption(entry.getValue(), entry.getLabel()));
                    }
                }
                else if (selectedFieldType == Schema.DisplayType.TextArea) {

                    if (entry.getValue().startsWith('append with')
                        || entry.getValue().startsWith('prepend with')
                        || entry.getValue().equals('replace')) {

                        result.add(new SelectOption(entry.getValue(), entry.getLabel()));
                    }
                }
                else if (selectedFieldType == Schema.DisplayType.String) {
                    if ((entry.getValue().startsWith('append with') && !entry.getValue().contains('line'))
                        || (entry.getValue().startsWith('prepend with') && !entry.getValue().contains('line'))
                        || entry.getValue().equals('replace')) {

                        result.add(new SelectOption(entry.getValue(), entry.getLabel()));
                    }
                }
                else {
                    if (entry.getValue().equals('replace')) {
                        result.add(new SelectOption(entry.getValue(), entry.getLabel()));
                    }
                }
            }

            return result;
        }
        private set;
    }

    public Boolean isEditFirstN { get {
            if (selectedMachingAproach.startsWith(Constants.FIRST_N) ||
                selectedMachingAproach.startsWith(Constants.N_DAYS))
                return true;
            else
                return false;
        }
        private set;
    }

    public Boolean isEditMergeAction { get {
            Boolean result  = true;
            return result;
        }
        set;
    }

    public List<Rule__c> rules { get; set; }
    public List<MergeRule__c> mergeRules { get; set; }
    public Filter__c filter { get; set; }
    public String objectId { get; set; }
    public String selectedMachingAproach {get; set;}
    public String selectedSourceField { get; set {
            selectedSourceField = value;
            if(!String.isEmpty(selectedSourceField)) {
                Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                List<SelectOption> result = new List<SelectOption>();
                String type = FilterDetailsController.customToStandart(selectedSourceObjectType);
                Map<String, Schema.SObjectType> gdesc = Schema.getGlobalDescribe();
                Sobject objectt = gdesc.get(type).newSObject();

                Schema.SObjectField field = objectt.getSObjectType().getDescribe().fields.getMap().get(selectedSourceField);
                selectedFieldType  = field.getDescribe().getType();
            }
        }
    }
    public String selectedTargetField { get; set; }
    public String selectedSourceObjectType { get; set; }
    public String selectedTargetObjectType { get; set; }
    public Rule__c currentRule { get; set; }
    public MergeRule__c currentMergeRule { get; set; }
    public String selectedMatchOnInsert { get; set; }
    public String selectedMatchOnUpdate { get; set; }
    public String selectedCreateTasks { get; set; }
    public String selectedMatchLogic { get; set; }
    public String selectedMergeAction { get; set; }
    private Schema.DisplayType selectedFieldType;
    public Boolean isMatchOnConditionDisabled { get; set; }
    public Integer priority { get; set; }
    public Integer originalPriority { get; set; }
    public List<SelectOption> options = new List<SelectOption>();
    public Boolean isSourceObjectRecordTypeExists { get; set; }
    public Boolean isTargetObjectRecordTypeExists { get; set; }
    public Boolean createNewDataTask { get; set; }
    public Boolean isSourceLead { get; set; }
    public Boolean isTargetLead { get; set; }
    public String filterName { get; set; }
    public Set <String> originalValues { get; set; }
    public List <String> leftSelected{ get; set; }
    public List<String> rightSelected{ get; set; }
    public Set<String> leftValues = new Set<String>();
    public Set<String> rightValues = new Set<String>();
    public Integer statusesFlag { get; set; }
    public final static String FILTER_OPPORTUNITY = 'Opportunity';
    public final static String FILTER_CONTACT = 'Contact';
    public final static String FILTER_ACCOUNT = 'Account';
    public final static String FILTER_ENQUIRIES = 'Enquiries';
    public final static String FILTER_BOOKINGS = 'Bookings';
    public List<SelectOption> getItems() {
        return options;
    }

    private String FilterId {
        get {
            String pageFilterId = ApexPages.currentPage().getParameters().get('Filter');
            if (pageFilterId == '') {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning,
                                    Label.FilterDontExist));
            }
            return pageFilterId;
        }
        set;
    }

    public void establishPriority(String sourceObjectType, String targetObjectType){
        List <Filter__c> filters = new List <Filter__c>();
        options = new List<SelectOption>();
        filters = [
            SELECT Name
            FROM Filter__c
            WHERE SourceObjectType__c =:sourceObjectType
            AND  TargetObjectType__c =:targetObjectType
            LIMIT 50000];

        options.add(new SelectOption(String.valueOf(filter.Priority__c), String.valueOf(filter.Priority__c)));

        for (Integer i = 0; i < filters.size(); i++) {
            if (filter.Priority__c != (i+1)) {
                options.add(new SelectOption(String.valueOf(i+1), String.valueOf(i+1)));
            }
        }
        getItems();
    }

    public void loadFilter() {
        List<Filter__c> filterList = [
            SELECT Name, Active__c, CreateTasks__c, MatchOnInsert__c, MatchOnUpdate__c, AutoMerge__c, CreateNewDataTask__c,
            TargetObjectType__c, SourceObjectType__c, TargetObjectRecordType__c, SourceObjectRecordType__c, SearchAllRecords__c, MatchLogic__c, Priority__c, HandledStatus__c,
            (
                SELECT FirstN__c, MatchBlanks__c, MatchingApproach__c, SourceField__c, TargetField__c
                FROM Rules__r
                ORDER BY LastModifiedDate DESC
                LIMIT 50000
            )
            FROM Filter__c
            WHERE Id = :FilterId
            ORDER BY LastModifiedDate DESC
            LIMIT 1
        ];
        if (!filterList.isEmpty()) {
            filter = filterList.get(0);
            if (filter.SourceObjectType__c == 'Enquiries') {
                isSourceLead = true;
            }
            if (filter.TargetObjectType__c == 'Enquiries' || filter.TargetObjectType__c == 'Opportunity') {
                isTargetLead = true;
            }
            if (filter.SourceObjectrecordType__c!=null) {
                isSourceObjectRecordTypeExists = true;
            }
            if (filter.TargetObjectrecordType__c!=null) {
                isTargetObjectRecordTypeExists = true;
            }
            if (filter.AutoMerge__c == true) {
                isMatchOnConditionDisabled = true;
            } else {
                isMatchOnConditionDisabled = false;
            }
            if(filter.HandledStatus__c != null) {
                rightValues = new Set<String>(filter.HandledStatus__c.split(';'));
                leftValues = new Set<String>();
            }
            filterName = filter.Name;
            originalPriority = filter.Priority__c.intValue();
            selectedSourceObjectType = filter.SourceObjectType__c;
            selectedTargetObjectType = filter.TargetObjectType__c;
            selectedMatchOnInsert = filter.MatchOnInsert__c;
            selectedMatchOnUpdate = filter.MatchOnUpdate__c;
            selectedMatchLogic = filter.MatchLogic__c;
            establishPriority(selectedSourceObjectType, selectedTargetObjectType);
            createNewDataTask = filter.CreateNewDataTask__c;
            if (showTaskAction)
                selectedCreateTasks = filter.CreateTasks__c;
            else
                selectedCreateTasks = optionsCreateTasks.get(0).getLabel();
            rules = filter.Rules__r;
            mergeRules = [
                    SELECT SourceField__c,TargetField__c,MergeBlanks__c,MergeAction__c
                    FROM MergeRule__c
                    WHERE Filter__c = :FilterId
                    ORDER BY LastModifiedDate DESC
                    LIMIT 50000
            ];
        } else {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning,
                                 Label.FilterDontExist));
        }
        fillOriginalValues();
        statusesFlag = leftValues.size() + rightValues.size();
    }

    public void fillOriginalValues(){
        originalValues = new Set <String> ();
        leftValues = new Set<String>();
       
        if (selectedTargetObjectType == FILTER_ENQUIRIES) {
            Schema.DescribeFieldResult fieldResult = Schema.SObjectType.Lead.fields.Status;
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for(Schema.PicklistEntry f : ple) {
                if (!rightValues.contains(f.getValue())) {
                         originalValues.add(f.getValue());
                    }
            }
        }
        if (selectedTargetObjectType == FILTER_ACCOUNT) {
            try {
                Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap().get('Guest_Status__c').getDescribe();
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                for(Schema.PicklistEntry f : ple) {
                    if (!rightValues.contains(f.getValue())) {
                         originalValues.add(f.getValue());
                    }
                   
                }
                fieldResult = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap().get('Host_Status__c').getDescribe();
                ple = fieldResult.getPicklistValues();
                for(Schema.PicklistEntry f : ple) {
                   if (!rightValues.contains(f.getValue())) {
                         originalValues.add(f.getValue());
                    }
                }
            }
            catch (Exception exc) {
                //sshh...
            }
        }
        if (selectedTargetObjectType == FILTER_OPPORTUNITY) {
            Schema.DescribeFieldResult fieldResult = Opportunity.StageName.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for(Schema.PicklistEntry f : ple) {
               if (!rightValues.contains(f.getValue())) {
                         originalValues.add(f.getValue());
                    }
            }
        }
        if (selectedTargetObjectType == FILTER_BOOKINGS) {
            Schema.DescribeFieldResult fieldResult = Schema.SObjectType.Order.fields.Status;
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for(Schema.PicklistEntry f : ple) {
                if (!rightValues.contains(f.getValue())) {
                         originalValues.add(f.getValue());
                    }
            }
        }
        leftValues.addAll(originalValues);
    }

    public Boolean showTaskAction {
        get {
            if (selectedMatchOnUpdate == Constants.REPORT_DUPLICATE ||
               selectedMatchOnInsert == Constants.REPORT_DUPLICATE) {

                return true;
            }
            else {
                return false;
            }
        }
        private set;
    }

    public void saveFilter() {
        List <Filter__c> filtersByPriority = new List <Filter__c> ();
        List <Filter__c> tempList1 = new List <Filter__c> ();
        List <Filter__c> tempList2 = new List <Filter__c> ();
        List <Filter__c> tempList3 = new List <Filter__c> ();
        List <Filter__c> filtersToUpdate = new List <Filter__c> ();
        filtersByPriority = [
            SELECT Name, Priority__c
            FROM Filter__c
            WHERE SourceObjectType__c =:selectedSourceObjectType
            AND  TargetObjectType__c =:selectedTargetObjectType
            ORDER BY Priority__c ASC
            LIMIT 50000
        ];
        if (originalPriority > priority) {
            for (Integer i = 0; i < priority-1; i++) {
                tempList1.add(filtersByPriority[i]);
            }
            for (Integer i = priority-1; i < originalPriority - 1; i++) {
                Filter__c filt = filtersByPriority[i];
                filt.Priority__c = i+2;
                tempList2.add(filt);
            }
            for(Integer i = originalPriority; i < filtersByPriority.size(); i++){
                tempList3.add(filtersByPriority[i]);
            }
        }
        if (originalPriority < priority) {
            for (Integer i = 0; i < originalPriority-1; i++) {
                tempList1.add(filtersByPriority[i]);
            }
            for (Integer i = originalPriority; i < priority; i++) {
                Filter__c filt = filtersByPriority[i];
                filt.Priority__c = i;
                tempList2.add(filt);
            }
            for (Integer i = priority; i < filtersByPriority.size(); i++) {
                tempList3.add(filtersByPriority[i]);
            }
        }

        try {
                filter.Name = filterName;
                filter.SourceObjectType__c = selectedSourceObjectType;
                filter.TargetObjectType__c = selectedTargetObjectType;
                filter.MatchOnInsert__c = selectedMatchOnInsert;
                filter.MatchOnUpdate__c = selectedMatchOnUpdate;
                filter.MatchLogic__c = selectedMatchLogic;
                filter.Priority__c = priority;
                filter.CreateNewDataTask__c = createNewDataTask;
                filter.HandledStatus__c = String.join(new List <String>(rightValues), ';');
                if(showTaskAction)
                    filter.CreateTasks__c = selectedCreateTasks;
                else
                    filter.CreateTasks__c = optionsCreateTasks.get(0).getLabel();
                filtersToUpdate.add(filter);
            } catch (DmlException e) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning, e.getMessage()));
            }
        filtersToUpdate.addAll(tempList1);
        filtersToUpdate.addAll(tempList2);
        filtersToUpdate.addAll(tempList3);
        update filtersToUpdate;
        loadFilter();
    }

    public void saveRules() {
        try {
            if(!String.isEmpty(selectedSourceField) || !String.isEmpty(selectedTargetField)) {
                currentRule.SourceField__c = selectedSourceField;
                currentRule.TargetField__c = selectedTargetField;
                currentRule.MatchingApproach__c = selectedMachingAproach;
                if(!isEditFirstN)
                    currentRule.FirstN__c = 1;
                Integer firstNmax = 0;
                if (selectedMachingAproach == Constants.FIRST_N_LETTERS)
                    firstNmax = Constants.MAX_FIRST_N_LETTERS;
                else if (selectedMachingAproach == Constants.FIRST_N_WORDS)
                    firstNmax = Constants.MAX_FIRST_N_WORDS;
                else if (selectedMachingAproach == Constants.N_DAYS)
                    firstNmax = Constants.MAX_N_DAYS;
                if (isEditFirstN && (currentRule.FirstN__c == null || currentRule.FirstN__c <= 0 || currentRule.FirstN__c > firstNmax))
                {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning,
                        String.format(Label.SaveRuleFirstNError, new List<String>{selectedMachingAproach, '' + firstNmax})));
                    return;
                }
                upsert currentRule;
                Map<Id, Rule__c> tempoRules = new Map<Id, Rule__c>(rules);
                tempoRules.put(currentRule.Id, currentRule);
                rules = new List<Rule__c>(tempoRules.values());
                upsert rules;
                objectId = '';
                selectedSourceField = '';
                selectedTargetField = '';
                selectedMachingAproach = '';
                currentRule = null;
                loadFilter();
            } else {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning, Label.ErrorWhileSave));
            }
        } catch (DmlException e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning, e.getMessage()));
        }
    }

    public void addRule() {
        if (currentRule == null  && currentMergeRule == null) {
            currentRule = new Rule__c(
                Filter__c = filter.Id,
                FirstN__c = 1
            );
            objectId = currentRule.Id;
            selectedSourceField = getFields(false, selectedSourceObjectType, false, false).get(0).getValue();
            selectedTargetField = '';
            selectedMachingAproach = '';
            selectedSourceObjectType = filter.SourceObjectType__c;
            selectedTargetObjectType = filter.TargetObjectType__c;
            rules.add(currentRule);
        } else {
             ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning, Label.ErrorMesagePleaseSaveBeforeAddNew));
        }
    }

    public void deleteRule() {
        delete [
            SELECT Id
            FROM Rule__c
            WHERE Id = :objectId
        ];
        objectId = '';
        selectedSourceField = '';
        selectedTargetField = '';
        selectedMachingAproach = '';
        loadFilter();
    }

    public void editRule() {
        if (currentRule == null && currentMergeRule == null) {
            Map<Id, Rule__c> tempoRules = new Map<Id, Rule__c>(rules);
            currentRule = tempoRules.get(objectId);
            selectedSourceField = currentRule.SourceField__c;
            selectedTargetField = currentRule.TargetField__c;
            selectedMachingAproach = currentRule.MatchingApproach__c;
            if(!isEditFirstN)
                currentRule.FirstN__c = 1;
        }
        else {
            objectId = null;
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Warning, Label.ErrorMesagePleaseSaveBeforeAddNew));
        }
    }

    public void editMergeRule() {
        if (currentMergeRule == null && currentRule == null) {
            Map<Id, MergeRule__c> tempoRules = new Map<Id, MergeRule__c>(mergeRules);
            currentMergeRule = tempoRules.get(objectId);
            objectId = currentMergeRule.Id;
            selectedSourceField = currentMergeRule.SourceField__c;
            selectedTargetField = currentMergeRule.TargetField__c;
            selectedMergeAction = currentMergeRule.MergeAction__c;
            selectedMachingAproach = '';
        }
        else {
            objectId = null;
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Warning, Label.ErrorMesagePleaseSaveBeforeAddNew));
        }
    }

    public void cancelRule() {
        objectId = '';
        selectedSourceField = '';
        selectedTargetField = '';
        currentRule = null;
        loadFilter();
    }

    public void cancelMergeRule() {
        objectId = '';
        selectedSourceField = '';
        selectedTargetField = '';
        currentMergeRule = null;
        loadFilter();
    }

    public void deleteMergeRule() {
        delete [
            SELECT Id
            FROM MergeRule__c
            WHERE Id = :objectId
        ];
        objectId = '';
        loadFilter();
        selectedSourceField = '';
        selectedTargetField = '';
        currentMergeRule = null;
    }

    public void saveMergeRules() {
        try {
            currentMergeRule.SourceField__c = selectedSourceField;
            currentMergeRule.TargetField__c = selectedTargetField;
            currentMergeRule.MergeAction__c = selectedMergeAction;
            upsert currentMergeRule;
            Map<Id, MergeRule__c> tempoRules = new Map<Id, MergeRule__c>(mergeRules);
            tempoRules.put(currentMergeRule.Id, currentMergeRule);
            mergeRules = new List<MergeRule__c>(tempoRules.values());
            upsert mergeRules;
            objectId = '';
            selectedSourceField = '';
            selectedTargetField = '';
            currentMergeRule = null;
            selectedMergeAction = '';
            loadFilter();
        } catch (DmlException e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning, e.getMessage()));
        }
    }

    public void addMergeRule() {
        if (currentMergeRule == null && currentRule == null) {
            currentMergeRule = new MergeRule__c(
                Filter__c = filter.Id
            );
            mergeRules.add(currentMergeRule);
            objectId = currentMergeRule.Id;

            selectedSourceField = getFields(false, selectedSourceObjectType, false, true).get(0).getValue();
            selectedTargetField = '';
        } else {
             ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning, Label.ErrorMesagePleaseSaveBeforeAddNew));
        }
    }

    public void disableMatchOnCondition(){
        if (isMatchOnConditionDisabled == false) {
            isMatchOnConditionDisabled = true;
        } else {
            isMatchOnConditionDisabled = false;
        }
    }

     public PageReference selectclick(){
        rightSelected.clear();
        for(String s : leftSelected){
            leftValues.remove(s);
            rightValues.add(s);
        }
        return null;
    }

    public PageReference unselectclick(){
        leftSelected.clear();
        for(String s : rightSelected){
            rightValues.remove(s);
            leftValues.add(s);
        }
        return null;
    }

    public List<SelectOption> getunSelectedValues(){
        List<SelectOption> options = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(leftvalues);
        tempList.sort();
        for(string s : tempList)
            options.add(new SelectOption(s,s));
        return options;
    }

    public List<SelectOption> getSelectedValues(){
        List<SelectOption> options1 = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(rightvalues);
        tempList.sort();
        for(String s : tempList)
            options1.add(new SelectOption(s,s));
        return options1;
    }
}
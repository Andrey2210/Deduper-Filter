public with sharing class FiltersController {


    public Filter__c filter { get; set; }
    public String sourceObjectType { get; set; }
    public String targetObjectType { get; set; }
    public String sourceObjectRecordType { get; set; }
    public String targetObjectRecordType { get; set; }
    public String objectId { get; set; }
    public String selectedMatchOnInsert { get; set; }
    public String selectedMatchOnUpdate { get; set; }
    public String selectedCreateTasks { get; set; }
    public String selectedMatchLogic { get; set; }
    public Boolean isMatchOnConditionDisabled { get; set; }
    public List<SelectOption> filterSourceRecordTypes { get; set; }
    public List<SelectOption> filterTargetRecordTypes { get; set; }
    public Boolean autoMergeValue { get; set; }
    public Boolean isSourceLead { get; set; }
    public Boolean isTargetLead { get; set; }
    public Boolean createNewDataTask { get; set; }
    public Integer priority { get; set; }
    public String filterName { get; set; }
    public Set <String> originalValues { get; set; }
    public List <String> leftSelected{ get; set; }
    public List<String> rightSelected{ get; set; }
    public Set<String> leftValues = new Set<String>();
    public Set<String> rightValues = new Set<String>();
    public Integer statusesFlag { get; set; }

    public List<SelectOption> options = new List<SelectOption>();
     public List<SelectOption> getItems() {
        return options;
    }


    public static final String ENQUIRIES = 'Enquiries';
    public static final String LEAD = 'Lead';
    public static final String BOOKINGS = 'Bookings';
    public static final String ORDER = 'Order';
    public static final String ALL_RECORD_TYPES = 'All Record Types';

    public void establishPriority(String sourceObjectType, String targetObjectType){
        List <Filter__c> filters = new List <Filter__c>();
        options = new List<SelectOption>();
        filters = [
            SELECT Name, SourceObjectType__c , TargetObjectType__c, SourceObjectRecordType__c , TargetObjectRecordType__c
            FROM Filter__c
            WHERE SourceObjectType__c =:sourceObjectType
            AND  TargetObjectType__c =:targetObjectType
            LIMIT 50000];
        for (Integer i = 0; i <= filters.size(); i++) {
            options.add(new SelectOption(String.valueOf(i+1), String.valueOf(i+1)));
        }
        getItems();
    }

    public void fillFilterSourceRecordTypes(){
        String objName = sourceObjectType;
        if (sourceObjectType == ENQUIRIES) {
            objName = LEAD;
        }
        if (sourceObjectType == BOOKINGS) {
            objName = ORDER;
        }
        filterSourceRecordTypes = new List<SelectOption>();
        filterSourceRecordTypes.add(new SelectOption(ALL_RECORD_TYPES, ALL_RECORD_TYPES));
        Map<ID,Schema.RecordTypeInfo> rtMap = Schema.getGlobalDescribe().get(objName).getDescribe().getRecordTypeInfosById();
        List <RecordType> recTypes = new List <RecordType> ();
        List <Id> recTypeIds = new List <Id> (rtMap.keySet());
        recTypes = [
            SELECT Name
            FROM RecordType
            WHERE Id IN :recTypeIds
            LIMIT 50000
        ];
        for(RecordType rt : recTypes){
            filterSourceRecordTypes.add(new SelectOption(rt.Name, rt.Name));
        }
        sourceObjTypeAct();
        rerenderPriority();
    }

    public void fillFilterTargetRecordTypes(){
        String objName = targetObjectType;
        if (targetObjectType == ENQUIRIES) {
            objName = LEAD;
        }
        if (targetObjectType == BOOKINGS) {
            objName = ORDER;
        }
        filterTargetRecordTypes = new List<SelectOption>();
        filterTargetRecordTypes.add(new SelectOption(ALL_RECORD_TYPES, ALL_RECORD_TYPES));
        Map<ID,Schema.RecordTypeInfo> rtMap = Schema.getGlobalDescribe().get(objName).getDescribe().getRecordTypeInfosById();
        List <RecordType> recTypes = new List <RecordType> ();
        List <Id> recTypeIds = new List <Id> (rtMap.keySet());
        recTypes = [
            SELECT Name
            FROM RecordType
            WHERE Id IN :recTypeIds
            LIMIT 50000
        ];
        for(RecordType rt : recTypes){
            filterTargetRecordTypes.add(new SelectOption(rt.Name, rt.Name));
        }
        targetObjTypeAct();
        rerenderPriority();
        fillOriginalValues();
    }

    public Boolean showTaskAction { get {
                if(selectedMatchOnUpdate == 'Report Duplicate' ||
                   selectedMatchOnInsert == 'Report Duplicate') {
                    filter.AutoMerge__c = false;
                    return true;
                }
                else
                    return false;
            }
        private set;
    }

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

    public final static String FILTER_OPPORTUNITY = 'Opportunity';
    public final static String FILTER_CONTACT = 'Contact';
    public final static String FILTER_ACCOUNT = 'Account';
    public final static String FILTER_ENQUIRIES = 'Enquiries';
    public final static String FILTER_BOOKINGS = 'Bookings';

    public void fillOriginalValues(){
        originalValues = new Set <String> ();
        leftValues = new Set<String>();
        rightValues = new Set<String>();
        if (targetObjectType == FILTER_ENQUIRIES) {
            Schema.DescribeFieldResult fieldResult = Schema.SObjectType.Lead.fields.Status;
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for(Schema.PicklistEntry f : ple) {
                originalValues.add(f.getValue());
            }
        }
        if (targetObjectType == FILTER_ACCOUNT) {
            try {
                Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap().get('Guest_Status__c').getDescribe();
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                for(Schema.PicklistEntry f : ple) {
                    originalValues.add(f.getValue());
                }
                fieldResult = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap().get('Host_Status__c').getDescribe();
                ple = fieldResult.getPicklistValues();
                for(Schema.PicklistEntry f : ple) {
                    originalValues.add(f.getValue());
                }
            }
            catch (Exception exc) {
                //sshh...
            }
        }
        if (targetObjectType == FILTER_OPPORTUNITY) {
            Schema.DescribeFieldResult fieldResult = Opportunity.StageName.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for(Schema.PicklistEntry f : ple) {
                originalValues.add(f.getValue());
            }
        }
        if (targetObjectType == FILTER_BOOKINGS) {
            Schema.DescribeFieldResult fieldResult = Schema.SObjectType.Order.fields.Status;
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for(Schema.PicklistEntry f : ple) {
                originalValues.add(f.getValue());
            }
        }
        leftValues.addAll(originalValues);
    }


    public List<Filter__c> filters { get {
            return [
                SELECT Active__c, CreateTasks__c, MatchOnInsert__c, SourceObjectType__c, SourceObjectRecordType__c, TargetObjectType__c, TargetObjectRecordType__c,
                    MatchOnUpdate__c, AutoMerge__c, Type__c, Name,
                    SearchAllRecords__c, MatchLogic__c, Priority__c
                FROM Filter__c
                ORDER BY Name, Priority__c
                LIMIT 25
            ];
        }
        private set;
    }

    public List<SelectOption> filterTypes { get {
            List<SelectOption> listTypes = new List<SelectOption>();

            listTypes.add(new SelectOption(FILTER_OPPORTUNITY, FILTER_OPPORTUNITY));
            listTypes.add(new SelectOption(FILTER_CONTACT, FILTER_CONTACT));
            listTypes.add(new SelectOption(FILTER_ACCOUNT, FILTER_ACCOUNT));
            listTypes.add(new SelectOption(FILTER_ENQUIRIES, FILTER_ENQUIRIES));
            listTypes.add(new SelectOption(FILTER_BOOKINGS, FILTER_BOOKINGS));

            return listTypes;
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

    public void rerenderPriority() {
        establishPriority(sourceObjectType, targetObjectType);
    }

    public FiltersController() {
        leftSelected = new List<String>();
        rightSelected = new List<String>();
        autoMergeValue = false;
        isMatchOnConditionDisabled = false;
        isTargetLead = true;
        filterSourceRecordTypes = new List<SelectOption>();
        filterTargetRecordTypes = new List<SelectOption>();
        Map<ID,Schema.RecordTypeInfo> rtMap = Opportunity.sObjectType.getDescribe().getRecordTypeInfosById();
        List <RecordType> recTypes = new List <RecordType> ();
        List <Id> recTypeIds = new List <Id> (rtMap.keySet());
        recTypes = [
            SELECT Name
            FROM RecordType
            WHERE Id IN :recTypeIds
            LIMIT 50000
        ];
        filterSourceRecordTypes.add(new SelectOption(ALL_RECORD_TYPES, ALL_RECORD_TYPES));
        filterTargetRecordTypes.add(new SelectOption(ALL_RECORD_TYPES, ALL_RECORD_TYPES));
        for(RecordType rt : recTypes){
            filterSourceRecordTypes.add(new SelectOption(rt.Name, rt.Name));
            filterTargetRecordTypes.add(new SelectOption(rt.Name, rt.Name));
        }
        filter = new Filter__c();
        sourceObjectType = FILTER_OPPORTUNITY;
        targetObjectType = FILTER_OPPORTUNITY;
        establishPriority(sourceObjectType, targetObjectType);
        fillOriginalValues();
        statusesFlag = leftValues.size() + rightValues.size();
    }

    public void saveFilter() {
        List <Filter__c> filters = new List <Filter__c>();
        filters = [
            SELECT SourceObjectType__c, TargetObjectType__c
            FROM Filter__c
            WHERE SourceObjectType__c =:sourceObjectType
                AND TargetObjectType__c =:targetObjectType
            LIMIT 50000];
        try {
            filter.Name = filterName;
            filter.SourceObjectType__c = sourceObjectType;
            filter.TargetObjectType__c = targetObjectType;
            if (filterSourceRecordTypes.size() != 1 && sourceObjectRecordType != ALL_RECORD_TYPES) {
                filter.SourceObjectRecordType__c = sourceObjectRecordType;
            }
            if (filterTargetRecordTypes.size() != 1 && targetObjectRecordType != ALL_RECORD_TYPES) {
                filter.TargetObjectRecordType__c = targetObjectRecordType;
            }
            filter.MatchOnInsert__c = selectedMatchOnInsert;
            filter.MatchOnUpdate__c = selectedMatchOnUpdate;
            filter.CreateTasks__c = selectedCreateTasks;
            filter.MatchLogic__c = selectedMatchLogic;
            if (createNewDataTask != null) {
                filter.CreateNewDataTask__c = createNewDataTask;
            }
            else {
                filter.CreateNewDataTask__c = false;
            }
            List <Filter__c> filtersByPriority = new List <Filter__c> ();
            filtersByPriority = [
                SELECT Name, Priority__c, SourceObjectRecordType__c, TargetObjectRecordType__c, SourceObjectType__c, TargetObjectType__c
                FROM Filter__c
                WHERE SourceObjectType__c =:sourceObjectType
                    AND TargetObjectType__c =:targetObjectType
                ORDER BY Priority__c ASC
                LIMIT 50000
            ];
            List <Filter__c> filtersToUpdate = new List <Filter__c> ();
            if (filtersByPriority.size() != null) {
                for(Integer i = priority-1; i < filtersByPriority.size(); i++){
                    filtersByPriority[i].Priority__c++;
                    filtersToUpdate.add(filtersByPriority[i]);
                }
                update filtersToUpdate;
            }
            filter.Priority__c = priority;
            filter.AutoMerge__c = autoMergeValue;
            filter.HandledStatus__c = String.join(new List <String>(rightValues), ';');
            upsert filter;
            filter = new Filter__c();
            establishPriority(sourceObjectType, targetObjectType);
            filterName = '';
            selectedCreateTasks = '';
            selectedMatchOnInsert = '';
            selectedMatchOnUpdate = '';
            isMatchOnConditionDisabled = false;
            autoMergeValue = false;
            createNewDataTask = false;
        }
        catch(DmlException e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, e.getMessage()));
        }
    }
    public void deleteFilter(){
        List <Filter__c> filtersToUpdate = new List <Filter__c> ();
        Filter__c filter = [
            SELECT Id, SourceObjectType__c, TargetObjectType__c, SourceObjectRecordType__c, TargetObjectRecordType__c, Priority__c,
            (
                SELECT Id
                FROM Alerts__r
            )
            FROM Filter__c
            WHERE Id = :objectId
            LIMIT 1
        ];
        String sourceObjectType = filter.SourceObjectType__c;
        String targetObjectType = filter.TargetObjectType__c;
        List <Filter__c> filterss = [
            SELECT Id, Name, SourceObjectType__c, TargetObjectType__c, SourceObjectRecordType__c, TargetObjectRecordType__c, Priority__c
            FROM Filter__c
            WHERE SourceObjectType__c =:sourceObjectType
            AND  TargetObjectType__c =:targetObjectType
            ORDER BY Priority__c
            LIMIT 50000
        ];
        for (Integer i = filter.Priority__c.intValue(); i < filterss.size(); i++) {
            Filter__c filt = filterss[i];
            filt.Priority__c = i;
            filtersToUpdate.add(filt);
        }
        update filtersToUpdate;
        delete filter.Alerts__r;
        delete filter;
    }

    public void disableMatchOnCondition(){
        if (isMatchOnConditionDisabled == false) {
            isMatchOnConditionDisabled = true;
        } else {
            isMatchOnConditionDisabled = false;
        }
    }

    public void sourceObjTypeAct() {
        if (sourceObjectType == 'Enquiries') {
            isSourceLead = true;
        } else {
            isSourceLead = false;
        }
    }

    public void targetObjTypeAct() {
        if (targetObjectType == 'Enquiries' || targetObjectType == 'Opportunity') {
            isTargetLead = true;
        } else {
            isTargetLead = false;
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
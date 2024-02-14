public without sharing class BatchAccountMissingDataTask implements Database.Batchable<sObject> {
    
    static final Id TASK_GENERALTASK_RECORDTYPEID = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('General_Task').getRecordTypeId();

    public Database.QueryLocator start(Database.BatchableContext bc) {

        /* Queries Active Customer Accounts Where certain fields are null 
           according to custom metadata (AccountRequiredData__mdt)
        */
        String query;
        String selectClause = 'SELECT Id, Name, RecordType.Name, OwnerId, Owner.IsActive, RecordTypeId, Premise__c, ';
        String whereClause = 'WHERE Status__c=\'A\' AND Owner.IsActive=True AND (';     
        
        Map<String, AccountRequiredData__mdt> mapAccountFields = AccountRequiredData__mdt.getAll();
        Integer i = 1;
        for(String key : mapAccountFields.keySet()){
            Set<Id> recordTypeIds = getRecordTypeIds(mapAccountFields.get(key).Account_Record_Type_Values_to_Apply_to__c);
            Set<String> premiseSet = getPremiseValues(mapAccountFields.get(key).Premise_Values_to_Apply_to__c);
            String field = mapAccountFields.get(key).Field_API_Name__c;
            //select string formatting
            selectClause += field;
            if(i<mapAccountFields.size()){
                selectClause += ', ';
            }
            //where string formatting
            for(Id recTypeId: recordTypeIds){
                Integer j = 1;
                for(String p : premiseSet) {
                    if(p=='NULL'){
                        whereClause += '('+field+'=null AND RecordTypeId=\''+recTypeId+'\' AND Premise__c=null)';
                    }
                    else {
                        whereClause += '('+field+'=null AND RecordTypeId=\''+recTypeId+'\' AND Premise__c=\''+p+'\')';
                    }
                    if(j!=premiseSet.size()){
                        whereClause += ' OR ';
                    }
                    j++;
                }
            }
            if(i==mapAccountFields.size()){
                whereClause +=')';
            }
            else{
                whereClause +=' OR ';
            }
            i++;
        }
        query = selectClause + ' FROM Account ' + whereClause;
        system.debug(query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Account> accList) {
        
        /* Inserts or Updates a Task for specified Account fields 
           (AccountRequiredData__mdt) that are null.
        */
        
        List<Task> tasksForUpsert = new List<Task>();
        //get acctIds
        set<Id> acctIds = new Map<Id, Account>(accList).keySet();
        //query existing Tasks that are open
        Map<String, Task> mapOpenTasks = new Map<String, Task>();
        List <Task> listOpenTasks = [
            SELECT Id, OwnerId, WhatId, Field_With_Missing_Data__c, ActivityDate 
            FROM Task 
            WHERE Status = 'Open' 
            AND WhatId IN :acctIds 
            AND RecordTypeId = :TASK_GENERALTASK_RECORDTYPEID
            AND Field_With_Missing_Data__c != null
            ORDER BY WhatId
            ];
        for(Task t : listOpenTasks){
            //key => accountId + fieldName  (e.g. 0013K00000wFgWqQAKPrimary_POC__c)
            String key = t.WhatId + t.Field_With_Missing_Data__c;
            mapOpenTasks.put(key, t);
        }

        //get list of API names of Account fields from custom metadata to check if values are null
        List<String> accountFields = new List<String>();
        Map<String, Set<Id>> mapFieldToActRecordTypeId = new Map<String, Set<Id>>();
        Map<String, Set<String>> mapFieldToPremise = new Map<String, Set<String>>();
        Map<String, AccountRequiredData__mdt> mapAccountFields = AccountRequiredData__mdt.getAll();

        for(String key : mapAccountFields.keySet()){
            String field = mapAccountFields.get(key).Field_API_Name__c;
            Set<Id> recordTypeIds = getRecordTypeIds(mapAccountFields.get(key).Account_Record_Type_Values_to_Apply_to__c);
            Set<String> premiseSet = getPremiseValues(mapAccountFields.get(key).Premise_Values_to_Apply_to__c);
            mapFieldToActRecordTypeId.put(field, recordTypeIds);
            mapFieldToPremise.put(field, premiseSet);
            accountFields.add(field);
        }

        for(Account a : accList){
            for(string field : accountFields){
                Set<Id> recTypeIdSet= mapFieldToActRecordTypeId.get(field);
                Set<String> premiseSet = mapFieldToPremise.get(field);
                //Account conditions specific to each null field
                if(a.get(field) == null && recTypeIdSet.contains(a.recordTypeId) && 
                (premiseSet.contains(a.Premise__c) || (a.Premise__c == null && premiseSet.contains('NULL')))
                ){
                    String key = a.Id +field;
                    Task existingTask = mapOpenTasks.get(key);
                    if(existingTask != null){
                        //update Task;
                        existingTask.OwnerId = a.OwnerId;
                        existingTask.ActivityDate = System.today()+1;
                        tasksForUpsert.add(existingTask);
                    }
                    else {
                        //get field label
                        String fieldLabel = Schema.getGlobalDescribe()
                            .get('Account')
                            .getDescribe()
                            .fields.getMap()
                            .get(field)
                            .getDescribe()
                            .getLabel();
                        //create Task
                        Task newTask = new Task();
                        newTask.RecordTypeId = TASK_GENERALTASK_RECORDTYPEID;
                        newTask.Status = 'Open';
                        newTask.Subject = 'Please Enter a Value for '+a.Name+' Account Field: '+ fieldLabel;
                        newTask.OwnerId = a.OwnerId;
                        newTask.WhatId = a.Id;
                        newTask.Field_With_Missing_Data__c = field;
                        newTask.ActivityDate = System.today()+1;
                        tasksForUpsert.add(newTask);
                    }
                }
            }
        }
        if(tasksForUpsert.size()>0){
            try {
                upsert tasksForUpsert;
            } catch (Exception ex) {
                ErrorLog.insertErrorLog(ex.getMessage(), String.valueOf(ex.getLineNumber()), 'BatchAccountMissingDataTask', 'BatchAccountMissingDataTask.execute()');
            }
        }
    }
  
    public void finish(Database.BatchableContext bc) {
    
    }

    public static Set<Id> getRecordTypeIds(String accountRecordTypeString){
        Id actRecordTypeId;
        Set<Id> recordTypeIds = new Set<Id>();
        if(accountRecordTypeString.contains(',')){
            List<String> recordTypeByName = accountRecordTypeString.split(',');
            for(String t : recordTypeByName){
                actRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(t).getRecordTypeId();
                recordTypeIds.add(actRecordTypeId);
            }
        }
        else {
            actRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(accountRecordTypeString).getRecordTypeId();
            recordTypeIds.add(actRecordTypeId);
        }
        return recordTypeIds;
    }

    public static Set<String> getPremiseValues(String premiseString){
        Set<String> premiseSet = new Set<String>();
        if(premiseString.contains(',')){
            List<String> premiseList = premiseString.split(',');
            
            premiseSet.addAll(premiseList);
        }
        else {
            premiseSet.add(premiseString);
        }
        return premiseSet;
    }
}
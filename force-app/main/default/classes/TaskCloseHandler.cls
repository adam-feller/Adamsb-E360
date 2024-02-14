public with sharing class TaskCloseHandler {
    
    static final Id TASK_GENERALTASK_RECORDTYPEID = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('General_Task').getRecordTypeId();

    public static void closeAccountMissingDataTasks(List<Account> newAccounts, Map<Id, Account> oldAccountMap){
        
        /* If a null Account field (specified in AccountRequiredData__mdt) is populated
           close its related open Task
        */

        Map<String, AccountRequiredData__mdt> mapAccountFields = AccountRequiredData__mdt.getAll();
        Map<String, Task> mapTasks = new Map<String, Task>();
        List<Task> taskUpdateList = new List<Task>();
        List<String> fields = new List<String>();
        for(String key : mapAccountFields.keySet()){
            String field = mapAccountFields.get(key).Field_API_Name__c;
            fields.add(field);
        }
        //account field goes from null to populated, see if an open Task
        List<String> taskKeys = new List<String>();
        Set<Id> acctIds = new Set<Id>();
        Set<String> fieldsMissingData = new Set<String>();
        for(Account a : newAccounts){
            for(String field : fields){
                Account oldAccount = oldAccountMap.get(a.Id);
                if(a.get(field) != null && oldAccount.get(field) == null){
                    String key = a.Id+field;
                    taskKeys.add(key);
                    acctIds.add(a.Id);
                    fieldsMissingData.add(field);
                }
            }
        }
        
        if(taskKeys.size()>0){
            mapTasks = queryOpenTasks(fieldsMissingData, acctIds);
        }
        //Assign Task to Completed
        if(mapTasks.size()>0){
            for(String key : taskKeys){
                Task t = mapTasks.get(key);
                if(t !=null){
                    //if there is an existing open Task, Complete it
                    t.Status = 'Completed';
                    taskUpdateList.add(t);
                }
            }
        }
        //update Task
        if(taskUpdateList.size()>0){
            try {
                TaskDAO.updateTasks(taskUpdateList);
            } catch (Exception ex) {
                ErrorLog.insertErrorLog(ex.getMessage(), String.valueOf(ex.getLineNumber()), 'TaskCloseHandler', 'closeAccountMissingDataTasks');
            }
        }
    }

    public static Map<String, Task> queryOpenTasks(Set<String> fieldsMissingData, Set<Id> acctIds){
        Map<String, Task> mapTasks = new Map<String, Task>();
        List<Task> tasks= [
            SELECT Id, WhatId, Field_With_Missing_Data__c
            FROM Task
            WHERE WhatId IN :acctIds
            AND Status = 'Open'
            AND Field_With_Missing_Data__c IN :fieldsMissingData
            AND RecordTypeId = :TASK_GENERALTASK_RECORDTYPEID
            AND (ActivityDate = TODAY
            OR ActivityDate = Next_N_Days:2)
        ];
        for(Task t : tasks){
            String key = t.WhatId+t.Field_With_Missing_Data__c;
            mapTasks.put(key,t);
        }
        return mapTasks;
    }
}
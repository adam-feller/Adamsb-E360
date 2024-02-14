public without sharing class TaskTriggerHandler {
    public static void beforeInsertHandler(List<Task> newTasks) {
        newTaskLastCallResult(newTasks);
        completeTaskLastCallResult(newTasks);
    }

    public static void beforeUpdateHandler(List<Task> newTasks, Map<Id, Task> oldTaskMap) {
        newTaskLastCallResult(newTasks);
        completeTaskLastCallResult(newTasks);
    }

    public static void afterInsertHandler(List<Task> newTasks) {
        TaskTriggerHelper.storeVisitCheckin(newTasks);
    }

    public static void afterUpdateHandler(List<Task> newTasks, Map<Id, Task> oldTaskMap) {
        TaskTriggerHelper.storeVisitCheckOut(newTasks, oldTaskMap);
    }

    public static void newTaskLastCallResult(List<Task> newTasks){
        //when task is created or updated
        //get list of taskIds
        List<Id> whatIds = new List<Id>();
        for(Task t : newTasks){
            whatIds.add(t.WhatId);
        }

        //get list of related accounts
        List<Account> relAccounts = getAccounts(whatIds);
        for(Task t : newTasks){
            //if WhatId is not null
            if(t.WhatId != null){
                //check the account list for accounts related to the task
                for(Account acc : relAccounts){
                    //match up the whatId with the acc.Id
                    if(t.WhatId == acc.Id){
                        t.Account__c = t.WhatId;
                    }
                }
            }
        }
    }

    public static void completeTaskLastCallResult (List<Task> newTasks){
        //when a task is created or updated
        //get list of task Ids
        List<Id> whatIds = new List<Id>();
        for (Task t: newTasks){
            whatIds.add(t.WhatId);
        }
        //list of accounts for dml
        //List<Account> accountsToUpdate = new List<Account>();
        Map<Id,Account> accountsToUpdateMap = new Map<Id,Account>();
        
        //list of accounts related to tasks
        List<Account> relAccounts = getAccounts(whatIds);
        //if task has been marked Complete,
        for(Task t : newTasks){
            if(t.Status == 'Completed' && t.WhatId != null){
                //loop through accounts related to the task
                for(Account acc : relAccounts){
                    if(t.WhatId == acc.Id){
                        acc.Last_Call_Result__c = t.Call_Result__c;
                        acc.Date_of_Last_Call__c = Date.today();
                        acc.Bypass_Validation__c = datetime.now();
                        accountsToUpdateMap.put(acc.Id,acc);
                    }
                }
            }
        }
        update accountsToUpdateMap.values();
    }

    public static List<Account> getAccounts(List<Id> whatIds){
        List<Account> accs = [SELECT Id,
                                      Last_Call_Result__c
                               FROM Account
                               WHERE Id IN :whatIds];

        return accs;
    }
}
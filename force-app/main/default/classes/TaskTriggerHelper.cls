public without sharing class TaskTriggerHelper {

    public static void storeVisitCheckin(List<Task> newTasks){
        Map <Id, List<CVS_Store_Visit__c>> taskToStoreVisits = new Map <Id, List<CVS_Store_Visit__c>>();
        Set <Id> actIds = new Set <Id>();
        List <Task> taskList = new List <Task>();
        List <CVS_Store_Visit__c> storeVistList = new List <CVS_Store_Visit__c>();
        List <CVS_Store_Visit__c> storeVisitsToUpdate = new List <CVS_Store_Visit__c>();
        //determine if it is a Check In Task
        for(Task t : newTasks){
            if(t.Subject.startsWith('Check In @') && t.Status == 'Open' 
            && t.WhatId.getSObjectType().getDescribe().getName() == 'Account'){
                actIds.add(t.WhatId);
                taskList.add(t);
            }
        }
        if(taskList.size()>0){
            storeVistList = [
                SELECT Id, Account__c, Status__c, Scheduled_Arrival__c
                FROM  CVS_Store_Visit__c
                WHERE Account__C IN :actIds
                AND (Status__c != 'Cancelled' AND Status__c != 'Completed')
            ];
        }

        if(storeVistList.size()>0){
            for(Task t : taskList){
                for(CVS_Store_Visit__c sv : storeVistList){
                    Date svDate = sv.Scheduled_Arrival__c.date(); 
                    Date taskDate = t.CreatedDate.date();
                    //build map of Task to Store visits within the same day
                    if(t.WhatId == sv.Account__c && svDate == taskDate){
                        List <CVS_Store_Visit__c> getVisits = new List <CVS_Store_Visit__c>();
                        if(taskToStoreVisits.keySet().contains(t.Id)){
                            getVisits = taskToStoreVisits.get(t.Id);
                        }
                        getVisits.add(sv);
                        taskToStoreVisits.put(t.Id, getVisits);
                    }
                }
            }

            for(Task t : taskList){
                List <CVS_Store_Visit__c> getVisits = new List <CVS_Store_Visit__c>();
                if(taskToStoreVisits.keySet().contains(t.Id)){
                    getVisits = taskToStoreVisits.get(t.Id);
                }
                //finds the Store Visits within an Account with closest time to check in
                if(getVisits.size()>0){
                    String matchingStoreVisitId = '';
                    Long timeBetween;
                    for(CVS_Store_Visit__c sv: getVisits){
                        if(matchingStoreVisitId == ''){
                            matchingStoreVisitId = sv.Id;
                            timeBetween = math.abs(sv.Scheduled_Arrival__c.getTime() - t.CreatedDate.getTime());
                        }
                        else if(math.abs(sv.Scheduled_Arrival__c.getTime() - t.CreatedDate.getTime()) < timeBetween){
                            matchingStoreVisitId = sv.Id;
                            timeBetween = math.abs(sv.Scheduled_Arrival__c.getTime() - t.CreatedDate.getTime());
                        }
                    }
                    CVS_Store_Visit__c sv = new CVS_Store_Visit__c();
                    sv.Id = matchingStoreVisitId;
                    sv.taskId__c = t.Id;
                    sv.Actual_Arrival__c = t.CreatedDate;
                    storeVisitsToUpdate.add(sv);
                }
            }

            if(storeVisitsToUpdate.size()>0){
                update storeVisitsToUpdate;
            }
        }
    }

    public static void storeVisitCheckOut(List<Task> newTasks, Map<Id, Task> oldTaskMap){
        Set <Id> taskIds = new Set <Id>();
        Set <Id> actIds = new Set <Id>();
        List <Task> taskList = new List <Task>();
        Map <String, CVS_Store_Visit__c> taskIdToStoreVisit= new Map <String, CVS_Store_Visit__c>();
        List <CVS_Store_Visit__c> storeVisitsToUpdate = new List <CVS_Store_Visit__c>();

        for(Task t : newTasks){
            Task OldTask = oldTaskMap.get(t.Id);
            if(t.Subject.startsWith('Check In @') && t.Status == 'Completed' && oldTask.Status == 'Open'
            && t.WhatId.getSObjectType().getDescribe().getName() == 'Account'){
                taskList.add(t);
                taskIds.add(t.Id);
                actIds.add(t.WhatId);
            }
        }

        List <CVS_Store_Visit__c> storeVistList = [
            SELECT Id, Account__c, Status__c, Scheduled_Arrival__c, taskId__c, Actual_Departure__c
            FROM  CVS_Store_Visit__c
            WHERE taskId__c IN :taskIds
            AND Account__c IN :actIds
            AND (Status__c != 'Cancelled' AND Status__c != 'Completed')
        ];
        
        if(storeVistList.size()>0){
            for(CVS_Store_Visit__c sv : storeVistList){
                taskIdToStoreVisit.put(sv.taskId__c, sv);
            }

            for(Task t : taskList){
                CVS_Store_Visit__c svRecord = new CVS_Store_Visit__c();
                if(taskIdToStoreVisit.keySet().contains(t.Id)){
                    svRecord = taskIdToStoreVisit.get(t.Id);
                    svRecord.Actual_Departure__c = t.LastModifiedDate;
                    svRecord.What_are_your_goals_for_the_next_visit__c = t.What_are_your_goals_for_the_next_visit__c;
                    svRecord.What_else_did_you_accomplish__c = t.What_else_did_you_accomplish__c;
                    svRecord.What_is_the_purpose_of_the_visit__c = t.What_is_the_purpose_of_the_visit__c;
                    svRecord.Who_did_you_meet_with_today__c = t.Who_did_you_meet_with_today__c;
                    svRecord.Status__c = 'Completed';
                    storeVisitsToUpdate.add(svRecord);
                }
            }

            if(storeVisitsToUpdate.size()>0){
                update storeVisitsToUpdate;
            }
        }
    }
}
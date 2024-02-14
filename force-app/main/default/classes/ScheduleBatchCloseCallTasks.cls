public with sharing class ScheduleBatchCloseCallTasks implements Schedulable {

    public void execute(SchedulableContext sc) {
        BatchCloseCallTasks batchCloseCallTasks = new BatchCloseCallTasks();
        batchCloseCallTasks.callTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId();
        batchCloseCallTasks.today = System.today();
        batchCloseCallTasks.query = 'SELECT Id, OwnerId, WhatId, Account.Primary_Language_Preference__c, Account.Warehouse_Lookup__r.Default_Outbound_Call_Queue__c, recordTypeId' + 
                            ' FROM Task' + 
                            ' WHERE AccountId != null and recordTypeId = :callTaskRecordTypeId AND ActivityDate = :today and Status=\'Open\'';
        Database.executebatch(batchCloseCallTasks);
    }
}
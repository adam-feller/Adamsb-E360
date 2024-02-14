public class AccountMerchTaskAlertController {
    
    @AuraEnabled
    public static Integer getMerchTasksforToday(Id accountId) {
        String merchTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Merch Task').getRecordTypeId();
        Date currentDate = System.today();
    	List<Task> merchTasks = [SELECT Id FROM Task WHERE WhatId=:accountId AND RecordTypeId =:merchTaskRecordTypeId AND ActivityDate =:currentDate AND Status='Open'];    
        if (!merchTasks.isEmpty()) {
        	return merchTasks.size();
        } else {
            return 0;
        }
    }
    
}
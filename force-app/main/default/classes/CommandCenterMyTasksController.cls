public with sharing class CommandCenterMyTasksController {
    @AuraEnabled
    public static List<TaskWrapper> getTaskData(){
        Id userId = userInfo.getUserId();
        List<Display_Product__c> displayProductList = DisplayProductDAO.fetchDisplayProductByUserId(new Set<Id>{userId});
        List<Task> taskList = TaskDAO.getTasksByUserIdAndStatusForCM(new Set<Id>{userId}, 'Open');
        List<TaskWrapper> taskWrapperList = new List<TaskWrapper>();

        for (Task task : taskList){
            TaskWrapper taskWrapperObj = new TaskWrapper();
            taskWrapperObj.taskType = 'task';
            taskWrapperObj.Id = task.Id;
            taskWrapperObj.ActId = task.WhatId;
            taskWrapperObj.AccountName = task.Account__r.Name;
            taskWrapperObj.Priority = task.Priority;
            taskWrapperObj.Subject = task.Subject;
            taskWrapperObj.Description = task.Description;
            taskWrapperObj.ActivityDate = task.ActivityDate;
            taskWrapperObj.PriorityAbbreviated = task.Priority_Abbreviated__c;
            taskWrapperObj.DisplayProduct = task.Display_Product__c;
            taskWrapperObj.OwnerName = task.Owner.Name;
            taskWrapperObj.NoDisplayReasonCode = task.Display_Product__r.No_Display_Reason_Code__c;
            taskWrapperList.add(taskWrapperObj);
        }

        Set<Id> actsProccessed = new Set<Id>();
        for (Display_Product__c displayProduct : displayProductList){
            if (!actsProccessed.contains(displayProduct.Account__c)){
                //only add one DSOF record per Account
                actsProccessed.add(displayProduct.Account__c);
                
                TaskWrapper taskWrapperObj = new TaskWrapper();
                taskWrapperObj.ActId = displayProduct.Account__c;
                taskWrapperObj.AccountName = displayProduct.Account__r.Name;
                taskWrapperObj.Priority = 'High';
                taskWrapperObj.Id = displayProduct.Id;
                taskWrapperObj.Subject = 'DSOF';
                taskWrapperObj.taskType = 'dsof';
                taskWrapperObj.PriorityAbbreviated = 'H';
                taskWrapperObj.Description = 'Complete DSOF Survey';
                taskWrapperObj.ActivityDate = displayProduct.End_Date__c;
                taskWrapperList.add(taskWrapperObj);
            }
        }

        return taskWrapperList;
    }

    public class TaskWrapper{
        @AuraEnabled
        public String Priority;
        @AuraEnabled
        public String NoDisplayReasonCode;
        @AuraEnabled
        public String OwnerId;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public Id Id;
        @AuraEnabled
        public Id ActId;
        @AuraEnabled
        public String linkname;
        @AuraEnabled
        public String Subject;
        @AuraEnabled
        public String AccountName;
        @AuraEnabled
        public String Description;
        @AuraEnabled
        public Date ActivityDate;
        @AuraEnabled
        public String taskType;
        @AuraEnabled
        public String PriorityAbbreviated;
        @AuraEnabled
        public String DisplayProduct;
        @AuraEnabled
        public String OwnerName;
    }
}
public with sharing class DSOFController {

    @AuraEnabled
    public static List <Display_Product__c> fetchDisplayProductsNullZeroCases(String accountId, String productSelectValue) {
        List<User> user = UserDAO.getUser(UserInfo.getUserId());
        String userId = user[0].Id;
        Boolean fsrUser;
        List<Integer> SalesPointer = new List<Integer>();
        List<String> salesPointerString = new List<String>();
        
		List<AccountTeamMember> accountTeamMember = AccountTeamMemberDAO.getAccountTeamMembersByAccountIdsandUserIds(new Set<Id>{accountId}, new Set<Id>{userId});
       	if(accountTeamMember.size()> 0 && accountTeamMember[0].Sales_Pointer__c!= null){
	       salesPointerString = accountTeamMember[0].Sales_Pointer__c.split(';'); 
		}
		for(String s : salesPointerString){
       		if (s != null) {
        	    SalesPointer.add(Integer.ValueOf(s));
        	} 
       	}
       
       	for(AccountTeamMember act : accountTeamMember){
        	if(act.TeamMemberRole.contains('FSR') && act.UserId == user[0].Id){
            	fsrUser = true;
            }
        }
       
        String productSelect = productSelectValue;

        List<Display_Product__c> displayProductList = new List<Display_Product__c>();
        if(productSelect == '1' && fsrUser != true && SalesPointer.size() > 0) {
           return displayProductList = DisplayProductDAO.fetchDisplayProductNullZeroCasesCBS(new Set<Id>{accountId}, SalesPointer);
		} else if (SalesPointer.size() == 0 && productSelectValue == '1' && fsrUser != true) {
			return displayProductList = new List<Display_Product__c>();
		} else {
          return  displayProductList = DisplayProductDAO.fetchDisplayProductNullZeroCases(new Set<Id>{accountId});
        }
    }

    @AuraEnabled
    public static List <Display_Product__c> fetchDisplayProducts(String accountId) {
        List<Display_Product__c> displayProductList = DisplayProductDAO.fetchDisplayProduct(new Set<Id>{accountId});
        if (!displayProductList.isEmpty()) {
            return displayProductList;
        } else {
            return null;
        }
    }

    @AuraEnabled
    public static List<String> getNoReasonPickListValues() {
        List<String> pickListValuesList = new List<String>();
        Schema.DescribeFieldResult fieldResult = Display_Product__c.No_Display_Reason_Code__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListVal : ple) {
            pickListValuesList.add(pickListVal.getLabel());
        }
        return pickListValuesList;
    }

    @AuraEnabled
    public static List<String> getManagerRefusedPickListValues() {
        List<String> managerRefusedPickListValues = new List<String>();
        Schema.DescribeFieldResult managerField = Display_Product__c.Manager_Refused_Reason__c.getDescribe();
        List<Schema.PicklistEntry> managerFieldList = managerField.getPicklistValues();
        for (Schema.PicklistEntry pickListVal : managerFieldList) {
            managerRefusedPickListValues.add(pickListVal.getLabel());
        }
        return managerRefusedPickListValues; 
    }

    @AuraEnabled
    public static void createDisplayProduct(String accountId, String displayProductsRecords, String productSelectValue) {
        try {
            //Get all the Display Product values from the User Interface
            List<Display_Product__c> records = (List<Display_Product__c>)JSON.deserialize(displayProductsRecords, List<Display_Product__c>.class);
            
            //Create a map of all the Display Products for this Account
            Map<Id,Display_Product__c> displayProductMap;
            if (productSelectValue!=null) {
            	displayProductMap = new Map<Id,Display_Product__c>(fetchDisplayProductsNullZeroCases(accountId, productSelectValue));
            } else {
                displayProductMap = new Map<Id,Display_Product__c>(fetchDisplayProducts(accountId));
            }

            //Used to store newly created Gap tasks thate are created with the "General Task" record type
            List<Task> taskList = new List<Task>();
            Id generalTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('General_Task').getRecordTypeId();

            //Create a map of Open Gap Tasks so we can check if a Task already exists
            List<Task> openTaskList = TaskDAO.getTasksByIdAndStatus(new Set<Id>{accountId}, 'Open');
            List<Task> completeTask = new List<Task>();
            Map<Id,Task> openTaskByDisplayProductIdMap = new Map<Id,Task>();            
            for (Task openTask : openTaskList) {
                if (openTask.Display_Product__c != null) {
                    openTaskByDisplayProductIdMap.put(openTask.Display_Product__c,openTask);
                }
            }

            //Loop through all the updated records and determine if a Gap Task is needed
            if (!records.isEmpty()) {				
	            for (Display_Product__c displayProduct : records) {
    	            Display_Product__c display = displayProductMap.get(displayProduct.Id);
	                //If the user entered a 0 for case count, then we need to create a Gap Task if it doesn't already exist
	                if (displayProduct.Number_of_Cases__c == 0 && !openTaskByDisplayProductIdMap.keyset().contains(displayProduct.Id)) {
	                    Task task = new Task();
	                    task.OwnerId = display.Account__r.OwnerId;
	                    task.RecordTypeId = generalTaskRecordTypeId;
	                    task.WhatId = accountId;
	                    task.Status = 'Open';
	                    task.Display_Product__c = displayProduct.Id;
	                    task.ActivityDate = display.End_Date__c;
	                    task.description = display.Product__r.Name;
	                    task.Subject = display.Primary_Secondary__c + ' DSOF Gap ' + display.Product__r.Name;
	                    if (display.Primary_Secondary__c == 'Primary') {
	                        task.Priority = 'High';
	                    } else if (display.Primary_Secondary__c == 'Secondary') {
	                        task.Priority = 'Normal';
	                    }
	                    taskList.add(task);                    
	                }
	                //If the user entered a non-zero value for number of cases then we need to complete the Gap Task if one exists 
	                if (displayProduct.Number_of_Cases__c != 0 && openTaskByDisplayProductIdMap.keyset().contains(displayProduct.Id)) {
	                    Task completedTask = openTaskByDisplayProductIdMap.get(displayProduct.Id);
	                    completedTask.Status = 'Completed';
	                    completeTask.add(completedTask);
	                }
                    //Clear out any reasons for non-zero case counts                
                    if (displayProduct.Number_of_Cases__c != 0) {
                        displayProduct.No_Display_Reason_Code__c = null;
                        displayProduct.Manger_s_Name__c = null;
                        displayProduct.Manager_Refused_Reason__c = null;
                    }
                    //Clear out Manager Name and Manager Refused Reason if the reason code is not 'Manager Refused'
                    if (displayProduct.Number_of_Cases__c == 0 && displayProduct.No_Display_Reason_Code__c != 'Manager Refused') {
                        displayProduct.Manger_s_Name__c = null;
                        displayProduct.Manager_Refused_Reason__c = null;
                    }                    
                    //Update the Records
                    update records;
                }
            }

            //Insert any newly created Gap Tasks
            if (!taskList.isEmpty()) {
                insert tasklist;
            }

            //Update any completed Tasks
            if (!completeTask.isEmpty()) {
                update completeTask;
            }
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
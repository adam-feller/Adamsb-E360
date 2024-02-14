/**
 * Created by nicholas.vree on 12/10.
 */

global class BatchOutboundCallDistribution implements Database.Batchable<sObject> {

    public Id callTaskRecordTypeId;
    public Date today;
    public String query;
    public String empId;

    global Database.QueryLocator start( Database.BatchableContext BC ) {
        if (empId == null || empId == '') {
            //If there is no empId passed in from the flow then we get all Tasks for Today
        	query = 'SELECT Id, OwnerId, WhatId, Account.Primary_Language_Preference__c, Account.Do_Not_Call1__c, Account.Primary_Call_Window_Start__c,' + 
                				  ' Account.Primary_Call_Window_End__c, Account.Warehouse_Lookup__r.OrderCutoff__c, recordTypeId, Call_Result__c' + 
	                              ' FROM Task' + 
	                              ' WHERE AccountId != null AND Account.Status__c = \'A\' AND Account.Do_Not_Call1__c = false AND recordTypeId = :callTaskRecordTypeId AND' + 
                				  ' ActivityDate = :today AND Status = \'Open\'' +
	                              ' Order BY Account.Name';            
        } else {
            //If there is an empId passed in from the flow then we get just the Tasks that are assigned to that person
        	query = 'SELECT Id, OwnerId, WhatId, Account.Primary_Language_Preference__c, Account.Do_Not_Call1__c, Account.Primary_Call_Window_Start__c,' + 
                				  ' Account.Primary_Call_Window_End__c, Account.Warehouse_Lookup__r.OrderCutoff__c, recordTypeId, Call_Result__c' + 
	                              ' FROM Task' + 
	                              ' WHERE AccountId != null AND Account.Status__c = \'A\' AND Account.Do_Not_Call1__c = false AND recordTypeId = :callTaskRecordTypeId AND' + 
                				  ' ActivityDate = :today AND Status = \'Open\' AND OwnerId = \'' + empId + '\'' +
	                              ' Order BY Account.Name';
        }
        List<Task> tasks = Database.query(query);
        return Database.getQueryLocator(query);
    }

    global void execute( Database.BatchableContext BC, List<Task> taskList ) { 
        try{
            if (empId == null) {
            	OutboundCallRedistribution.redistributeOutboundCalls(taskList, null);
            } else {
                OutboundCallRedistribution.redistributeOutboundCalls(taskList, empId);
            }
        } catch(Exception ex){
            ErrorLog.insertErrorLog(ex.getMessage(), String.valueOf(ex.getLineNumber()), 'BatchOutboundCallDistribution', 'execute()');
        }
    }

    global void finish( Database.BatchableContext BC ) {
    }
}
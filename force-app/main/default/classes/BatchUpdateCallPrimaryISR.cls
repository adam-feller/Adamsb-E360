public class BatchUpdateCallPrimaryISR implements Database.Batchable<sObject> {
	public String query;
	public Map<Id, Account> accountMap;
    public Set<Id> accountIds;
    public Date today;
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug(query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Task> taskList) {
        try{
            //Get all the Future/Open Outbound Calls for the Warehouses that were updated
        	List<Task> updateTasks = new List<Task>();			
        	for (Task t : taskList) {
	            Id newOwner = accountMap.get(t.WhatId).Warehouse_Lookup__r.ISR_1__c;        
	            //Only update the Owner if needed
	            if (t.OwnerId <> newOwner) {
	                t.OwnerId = newOwner;
	            	updateTasks.add(t);
	        	}
	        }
        	if (updateTasks.size() > 0) {
        		update updateTasks;
        	}
        } catch(Exception ex){
            ErrorLog.insertErrorLog(ex.getMessage(), String.valueOf(ex.getLineNumber()), 'BatchUpdateCallPrimaryISR', 'BatchUpdateCallPrimaryISR.execute()');
        }
    }

    public void finish(Database.BatchableContext BC) {
        
    }
}
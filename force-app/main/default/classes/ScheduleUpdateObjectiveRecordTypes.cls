public with sharing class ScheduleUpdateObjectiveRecordTypes implements Database.Batchable<sObject>,Schedulable {
    
    //Schedulable
    public void execute(SchedulableContext SC) {
        ScheduleUpdateObjectiveRecordTypes job = new ScheduleUpdateObjectiveRecordTypes(); 
        Database.executeBatch(job, 200); 		
    }	
    
    //Batchable
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, RecordTypeId, Objective_Type__c FROM Objective_Account__c WHERE Objective__c != null AND Objective_Type__c != \'Deleted\' AND Objective_Type__c != \'Distribution\' AND Objective_Type__c != \'DSOF\' AND LastModifiedDate = LAST_N_DAYS:2');
    }   

    public void execute(Database.BatchableContext bc, List<Objective_Account__c> scope) {
        //Create a map of Objective Account Record Types for easy access
        Map<String, String> mapRecordTypes = new Map<String, String>();
        List<RecordType> rtypes = [SELECT Name, Id From RecordType WHERE sObjectType='Objective_Account__c' AND isActive=true];     
        for (RecordType rt: rtypes) {
        	mapRecordTypes.put(rt.Name, rt.Id);
        }
        Set<Id> objAccIds = new Set<Id>();
        List<Objective_Account__c> updateObjAccountsList = new List<Objective_Account__c>();
        List<Objective_Submission__c> updateObjSubmissionsList = new List<Objective_Submission__c>();
        //Find all Objective Accounts where the Record Type doesn't match the Objective
        for (Objective_Account__c oa : scope) {                        
            if (oa.RecordTypeId != mapRecordTypes.get(oa.Objective_Type__c)) {                
				oa.RecordTypeId = mapRecordTypes.get(oa.Objective_Type__c);
                updateObjAccountsList.add(oa);
                objAccIds.add(oa.Id);
            }
        } 
        if (updateObjAccountsList.size() > 0) {
        	update updateObjAccountsList;
        }
        
        if (objAccIds.size() > 0) {
        	//Now check for any Objective Submissions related to the Objective Accounts we just updated
        	updateObjSubmissionsList = [SELECT Id, Objective_Account__r.Objective_Type__c FROM Objective_Submission__c WHERE Objective_Account__c != null AND Objective_Account__c IN: objAccIds];
        	if (updateObjSubmissionsList.size() > 0) {            
	        	for (Objective_Submission__c os: updateObjSubmissionsList) {
                    if (Schema.SObjectType.Objective_Submission__c.getRecordTypeInfosByName().get(os.Objective_Account__r.Objective_Type__c) != null) {
                		Id objSubRecordTypeId =Schema.SObjectType.Objective_Submission__c.getRecordTypeInfosByName().get(os.Objective_Account__r.Objective_Type__c).getRecordTypeId();
                   		if (objSubRecordTypeId != null) {
			            	os.RecordTypeId = objSubRecordTypeId;
	                    }
                    }
		        }
		        update updateObjSubmissionsList;
            }
        }
    }
    
    public void finish(Database.BatchableContext bc) {
    }
    
}
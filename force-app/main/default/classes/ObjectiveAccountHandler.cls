public without sharing class ObjectiveAccountHandler {

    public static void updateObjectiveGoalObtainment(List<Objective_Account__c> objectiveAccounts, Map<Id, Objective_Account__c> objectiveAccountOldMap) {
        try{
            Set<Id> objectiveIds = new Set<Id>();
            Map<Id, Objective_Account__c> objectiveAccMap = new Map<Id, Objective_Account__c>();
            Map<Id, Objective_Account__c> objectiveAccOldMap = new Map<Id, Objective_Account__c>();
            for(Objective_Account__c objAccs : objectiveAccounts){
                if(objAccs.Status__c != objectiveAccountOldMap.get(objAccs.Id).Status__c){
                    objectiveIds.add(objAccs.Objective__c);
                    objectiveAccMap.put(objAccs.Objective__c, objAccs);
                    objectiveAccOldMap.put(objectiveAccountOldMap.get(objAccs.Id).Objective__c, objectiveAccountOldMap.get(objAccs.Id));
                }
            }

            List<Objective_Goal__c> objectiveGoalList = ObjectiveGoalDAO.getObjectiveGoalsByObjectiveIds(objectiveIds);
            List<Objective_Goal__c> objectiveGoalsToUpdate = new List<Objective_Goal__c>();
            for (Objective_Goal__c objGoalObj : objectiveGoalList) {
                if(objGoalObj.Team_Member_Actual__c == null){
                    objGoalObj.Team_Member_Actual__c = 0;
                }
                if (objectiveAccMap.containsKey(objGoalObj.Objective__c)) {
                    if(objectiveAccMap.get(objGoalObj.Objective__c).Account_Owner__c == objGoalObj.Goal_Assignee__c){
                        if((objectiveAccOldMap.get(objGoalObj.Objective__c).Status__c == 'Incomplete' && objectiveAccMap.get(objGoalObj.Objective__c).Status__c == 'Complete') ||
                           (objectiveAccOldMap.get(objGoalObj.Objective__c).Status__c == 'Incomplete' && objectiveAccMap.get(objGoalObj.Objective__c).Status__c == 'Pending Approval')){
                            objGoalObj.Team_Member_Actual__c += 1;
                        } else if(objectiveAccMap.get(objGoalObj.Objective__c).Status__c == 'Rejected'){
                            objGoalObj.Team_Member_Actual__c -= 1;
                        }
                        objectiveGoalsToUpdate.add(objGoalObj);
                    }
                }
            }

            if (!objectiveGoalsToUpdate.isEmpty()) {
                ObjectiveGoalDAO.updateObjectiveGoals(objectiveGoalsToUpdate);
            }
        } catch(Exception ex) {
            ErrorLog.insertErrorLog(ex.getMessage(), String.valueOf(ex.getLineNumber()), 'ObjectiveAccountHandler', 'updateObjectiveGoalObtainment');
        }
    }

    public static void reparentObjectiveSubmissionRecords(List<Objective_Account__c> objectiveAccounts) {
        try {
            if (!UserInfo.getUserName().contains('obarchive')) {   //Don't run this if we are archiving the records
            	Set<Id> objectiveAccountIds = new Set<Id>();
            	Set<Id> objectiveIds = new Set<Id>();
            	for(Objective_Account__c objAccs : objectiveAccounts){
	                objectiveAccountIds.add(objAccs.Id);
	                objectiveIds.add(objAccs.Objective__c);
	            }

	            Id deletedRecordTypeId = Schema.SObjectType.Objective_Account__c.getRecordTypeInfosByName().get('Deleted').getRecordTypeId();
	            List<Objective_Account__c> objectiveDeletedAccs = ObjectiveAccountDAO.getObjectiveAccountsByObjectiveAndRecordType(objectiveIds, deletedRecordTypeId);
	            Map<Id, Id> objectiveAccountDeletedMap = new Map<Id, Id>();
	            for(Objective_Account__c objAccs : objectiveDeletedAccs){
	                objectiveAccountDeletedMap.put(objAccs.Objective__c, objAccs.Id);
	            }

    	        List<Objective_Submission__c> objectiveSubmissionList = ObjectiveSubmissionDAO.getObjectiveSubmissions(objectiveAccountIds);
	            Set<Id> objectiveAccountDeletedIdsToCreate = new Set<Id>();
	            for(Objective_Submission__c objSubmissionObj : objectiveSubmissionList){
	                if(!objectiveAccountDeletedMap.containsKey(objSubmissionObj.Objective_Account__r.Objective__c)){
	                    objectiveAccountDeletedIdsToCreate.add(objSubmissionObj.Objective_Account__r.Objective__c);
	                }
	            }
	
	            List<Objective_Account__c> objectiveAccountsToInsert = new List<Objective_Account__c>();
	            for (Id objId : objectiveAccountDeletedIdsToCreate) {
	                Objective_Account__c tempDeletedObjectiveAccount = new Objective_Account__c();
	                tempDeletedObjectiveAccount.Objective__c = objId;
	                tempDeletedObjectiveAccount.RecordTypeId = deletedRecordTypeId;
	                tempDeletedObjectiveAccount.Status__c = 'Deleted';
	                objectiveAccountsToInsert.add(tempDeletedObjectiveAccount);
	            }
	
	            if (!objectiveAccountsToInsert.isEmpty()) {
	                List<Objective_Account__c> objectiveAccountsInserted = ObjectiveAccountDAO.insertObjectiveAccounts(objectiveAccountsToInsert);
	                for(Objective_Account__c objAccInserted : objectiveAccountsInserted){
	                    objectiveAccountDeletedMap.put(objAccInserted.Objective__c, objAccInserted.Id);
	                }
	            }
	
    	        for (Objective_Submission__c objSubmissionObj : objectiveSubmissionList) {
	                if (objectiveAccountDeletedMap.containsKey(objSubmissionObj.Objective_Account__r.Objective__c)) {
	                    objSubmissionObj.Account__c = objSubmissionObj.Objective_Account__r.Account__c;
	                    objSubmissionObj.Objective_Account__c = objectiveAccountDeletedMap.get(objSubmissionObj.Objective_Account__r.Objective__c);
	                }
    	        }

        	    if (!objectiveSubmissionList.isEmpty()) {
	                ObjectiveSubmissionDAO.updateObjectiveSubmissions(objectiveSubmissionList);
	            }
            }
        } catch(Exception ex) {
            ErrorLog.insertErrorLog(ex.getMessage(), String.valueOf(ex.getLineNumber()), 'ObjectiveAccountHandler', 'reparentObjectiveSubmissionRecords');
        }
    }

}
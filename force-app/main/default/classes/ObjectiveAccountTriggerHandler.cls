public without sharing class ObjectiveAccountTriggerHandler {

    public static void beforeDeleteHandler(List<Objective_Account__c> objectiveAccounts){
        ObjectiveAccountHandler.reparentObjectiveSubmissionRecords(objectiveAccounts);
    }

    public static void afterUpdateHandler(List<Objective_Account__c> objectiveAccounts, Map<Id, Objective_Account__c> objectiveAccountOldMap){
        ObjectiveAccountHandler.updateObjectiveGoalObtainment(objectiveAccounts, objectiveAccountOldMap);
    }
    
}
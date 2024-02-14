public without sharing class ObjectiveSubmissionDAO {

    public static List<Objective_Submission__c> getObjectiveSubmissions(Set<Id> objectiveAccountIds){
        return [SELECT Id, Objective_Account__r.Objective__c, Objective_Account__r.Account__c
                FROM Objective_Submission__c
                WHERE Objective_Account__c IN :objectiveAccountIds];
    }

    public static List<Objective_Submission__c> insertObjectiveSubmissions(List<Objective_Submission__c> objectiveSubmissionsToInsert){
        insert objectiveSubmissionsToInsert;
        return objectiveSubmissionsToInsert;
    }
    
    public static List<Objective_Submission__c> updateObjectiveSubmissions(List<Objective_Submission__c> objectiveSubmissionsToUpdate){
        update objectiveSubmissionsToUpdate;
        return objectiveSubmissionsToUpdate;
    }
}
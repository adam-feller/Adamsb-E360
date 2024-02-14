public without sharing class ObjectiveGoalDAO {

    public static List<Objective_Goal__c> getObjectiveGoalsByObjectiveIds(Set<Id> objectiveIds){
        return [SELECT Id, Goal_Assignee__c, Team_Member_Actual__c, Objective__c, Objective__r.Objective_Type__c 
                FROM Objective_Goal__c 
                WHERE Objective__c IN :objectiveIds];
    }

    public static List<Objective_Goal__c> insertObjectiveGoals(List<Objective_Goal__c> objectiveGoalsToInsert){
        insert objectiveGoalsToInsert;
        return objectiveGoalsToInsert;
    }

    public static List<Objective_Goal__c> updateObjectiveGoals(List<Objective_Goal__c> objectiveGoalsToUpdate){
        update objectiveGoalsToUpdate;
        return objectiveGoalsToUpdate;
    }
}
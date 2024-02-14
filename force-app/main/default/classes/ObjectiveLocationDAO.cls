public without sharing class ObjectiveLocationDAO {

    public static List<Objective_Location__c> getObjectiveLocationByObjectiveIdsNoDistributedCheck(Set<Id> objectiveIds) {
        return [SELECT Id, Name, Objective__c, BU__c, Warehouse__c, SalesOrg__c, Goal_Amount__c, Objective__r.Objective_Type__c
                FROM Objective_Location__c
                WHERE Objective__c IN :objectiveIds];
    }

    public static List<Objective_Location__c> getObjectiveLocationByObjectiveIds(Set<Id> objectiveIds) {
        return [SELECT Id, Name, Objective__c, BU__c, Warehouse__c, SalesOrg__c, Goal_Amount__c 
                FROM Objective_Location__c
                WHERE Objective__c IN :objectiveIds
                AND Objective__r.End_Date__c >= TODAY];
    }

    public static List<Objective_Location__c> getObjectiveLocationByObjectiveIdsAllTime(Set<Id> objectiveIds) {
        return [SELECT Id, Name, Objective__c, BU__c, Warehouse__c, SalesOrg__c, Goal_Amount__c 
                FROM Objective_Location__c
                WHERE Objective__c IN :objectiveIds];
    }

    public static List<Objective_Location__c> getObjectiveLocationByObjectiveIdsAndBU(Set<Id> objectiveIds, String bu) {
        return [SELECT Id, Name, Objective__c, BU__c, Warehouse__c, SalesOrg__c, Goal_Amount__c 
                FROM Objective_Location__c
                WHERE Objective__c IN :objectiveIds
                AND BU__c = :bu
                AND Objective__r.End_Date__c >= TODAY];
    }

    public static List<Objective_Location__c> getObjectiveLocationByObjectiveId(String objectiveId) {
        return [SELECT Id, BU__c
                FROM Objective_Location__c 
                WHERE Objective__c = :objectiveId];
    }

    public static List<Objective_Location__c> getObjectiveLocationByObjectiveIdIndivdual(String objectiveId) {
        return [SELECT Id
                FROM Objective_Location__c 
                WHERE Objective__c = :objectiveId
                AND BU__c = null
                AND (SalesOrg__c = '--None--'
                OR SalesOrg__c = null)
                AND Warehouse__c = null];
    }

    public static List<Objective_Location__c> getObjectiveLocationByObjectiveLocationIds(List<String> objectiveLocIds) {
        return [SELECT Id, Objective__c
                FROM Objective_Location__c 
                WHERE Id IN :objectiveLocIds];
    }

    public static List<Objective_Location__c> updateObjectiveLocations(List<Objective_Location__c> objectiveLocationsToUpdate) {
        update objectiveLocationsToUpdate;
        return objectiveLocationsToUpdate;
    }

    public static List<Objective_Location__c> insertObjectiveLocations(List<Objective_Location__c> objectiveLocationsToInsert) {
        insert objectiveLocationsToInsert;
        return objectiveLocationsToInsert;
    }

    public static List<Objective_Location__c> deleteObjectiveLocations(List<Objective_Location__c> objectiveLocationsToDelete) {
        delete objectiveLocationsToDelete;
        return objectiveLocationsToDelete;
    }
}
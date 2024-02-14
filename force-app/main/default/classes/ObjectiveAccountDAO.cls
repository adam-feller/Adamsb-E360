public without sharing class ObjectiveAccountDAO {

    public static List<Objective_Account__c> getObjectiveAccountsByAccountId(Set<Id> accountIds){
        return [SELECT Id, Objective__c, Objective_Name__c, Name, Associated_Products_Objective__c, Status__c, Start_Date__c, End_Date__c,
                RecordTypeId, Status_Abbreviated__c, Account__c, of_Opportunities__c, Manual_Account_Upload__c, Completed_Count__c, OwnerId,
                Account__r.VIP_Instance__c, Account__r.OwnerId, Objective__r.CBS_WCD_Pointers__c, Manual_Upload__c, Objective__r.Sub_Type__c
                FROM Objective_Account__c 
                WHERE Account__c IN :accountIds
                AND Start_Date__c <= Today
                AND End_Date__c >= Today
                AND RecordType.Name != 'Deleted'
                ORDER BY Objective_Name__c];
    }

    public static List<Objective_Account__c> getObjectiveAccountsByAccountIdCBS(Set<Id> accountIds, List<String> salesPointerString){
        string salesPointers = string.join(salesPointerString,';');
        return [SELECT Id, Objective__c, Objective_Name__c, Name, Associated_Products_Objective__c, Status__c, Start_Date__c, End_Date__c,
                RecordTypeId, Status_Abbreviated__c, Account__c, of_Opportunities__c, Manual_Account_Upload__c, Completed_Count__c, Manual_Upload__c,
                Objective__r.Sub_Type__c
                FROM Objective_Account__c 
                WHERE Account__c IN :accountIds
                AND Start_Date__c <= Today
                AND End_Date__c >= Today
                AND (Objective__r.CBS_WCD_Pointers__c INCLUDES (:salesPointers)
                OR Objective__r.CBS_WCD_Pointers__c IN :salesPointerString )
                AND RecordType.Name != 'Deleted'
                ORDER BY Objective_Name__c];
    }

    public static List<Objective_Account__c> getObjectiveAccountsByAccountAndStatusToday(Set<Id> accountIds, String status){
        return [SELECT Id, Objective__c, Objective_Name__c, Name, Associated_Products_Objective__c, Goal__c, Start_Date__c, End_Date__c, Manual_Upload__c 
                FROM Objective_Account__c
                WHERE Account__c IN :accountIds
                AND Status__c = :status
                AND LastModifiedDate = Today
                AND RecordType.Name != 'Deleted'];
    }

    public static List<Objective_Account__c> getObjectiveAccountsByObjective(Set<Id> objectiveIds){
        return [SELECT Id, Objective__c, Account__r.Id, OwnerId, Account__r.OwnerId, Account__c, Account__r.Name, Status__c, Manual_Account_Upload__c, 
                Completed_Count__c, Objective_Type__c, Manual_Upload__c
                FROM Objective_Account__c
                WHERE Objective__c IN :objectiveIds
                AND RecordType.Name != 'Deleted'];
    }

    public static List<Objective_Account__c> getObjectiveAccountsByObjectiveNotRejected(Set<Id> objectiveIds){
        return [SELECT Id, Objective__c, Account__r.Id, OwnerId, Account__r.OwnerId, Account__c, Account__r.Name, Status__c, Account__r.ParentId, Manual_Account_Upload__c, Manual_Upload__c
                FROM Objective_Account__c
                WHERE Objective__c IN :objectiveIds
                AND Status__c != 'Rejected'
                AND RecordType.Name != 'Deleted'];
    }

    public static List<Objective_Account__c> getObjectiveAccountsByAccountAndObjective(Set<Id> accountIds, Id objectiveId){
        return [SELECT Id, Objective__c, Objective_Name__c, Name, Associated_Products_Objective__c, Status__c, Start_Date__c, End_Date__c,
                RecordTypeId, Status_Abbreviated__c, OwnerId, Account__r.OwnerId, Account__c, Account__r.Id, Manual_Account_Upload__c, Manual_Upload__c
                FROM Objective_Account__c 
                WHERE Account__c IN :accountIds
                AND Objective__c = :objectiveId
                AND RecordType.Name != 'Deleted'];
    }

    public static List<Objective_Account__c> getObjectiveAccountsByObjectiveAndRecordType(Set<Id> objectiveIds, Id recordTypeId){
        return [SELECT Id, Objective__c, Status__c, RecordTypeId
                FROM Objective_Account__c 
                WHERE Objective__c IN :objectiveIds
                AND RecordTypeId = :recordTypeId];
    }

    public static List<Objective_Account__c> insertObjectiveAccounts(List<Objective_Account__c> objectiveAccountsToInsert){
        insert objectiveAccountsToInsert;
        return objectiveAccountsToInsert;
    }

    public static List<Objective_Account__c> updateObjectiveAccounts(List<Objective_Account__c> objectiveAccountsToUpdate){
        update objectiveAccountsToUpdate;
        return objectiveAccountsToUpdate;
    }

    public static List<Objective_Account__c> deleteObjectiveAccounts(List<Objective_Account__c> objectiveAccountsToDelete){
        delete objectiveAccountsToDelete;
        return objectiveAccountsToDelete;
    }
}
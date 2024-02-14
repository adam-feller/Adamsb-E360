public with sharing class AlertDAO {

    public static List<Alert__c> getAlerts(String recordId, String objectName, Boolean activeStatus){
        List<Alert__c> myAlerts = new List<Alert__c>();
        if(objectName == 'Account'){
            myAlerts = [SELECT Id, Name, Alert_Message__c, Start_Date__c, End_Date__c, Account_Alert__c, Order_Alert__c, Account__c, Requires_Action__c, Terms_Related_Alert__c, Account__r.Name
                FROM Alert__c 
                WHERE Account__c = :recordId AND Account_Alert__c = true AND Active__c = :activeStatus
                ORDER BY Requires_Action__c];
        } else {
            myAlerts = [SELECT Id, Name, Alert_Message__c, Start_Date__c, End_Date__c, Account_Alert__c, Order_Alert__c, Account__c, Requires_Action__c, Terms_Related_Alert__c, Account__r.Name
                FROM Alert__c 
                WHERE Account__c = :recordId AND Order_Alert__c = true AND Active__c = :activeStatus
                ORDER BY Requires_Action__c];
        }
        return myAlerts;
    }

    public static List<Alert__c> getAlertsByAccountId(String recordId){
        return [SELECT Id, Name, Requires_Action__c, Alert_Message__c, Start_Date__c, End_Date__c, Account_Alert__c, Order_Alert__c, Account__c, Active__c, Due_Date__c
                FROM Alert__c 
                WHERE 	Account__c = :recordId
                ORDER BY CreatedDate DESC];
    }

    public static List<Alert__c> getAlertsByAccountAndPlan(Set<Id> accountIds, String planId){
        return [SELECT Id, Account__c, Plan__c 
                FROM Alert__c 
                WHERE Plan__c = :planId 
                AND Account__c IN :accountIds];
    }
}
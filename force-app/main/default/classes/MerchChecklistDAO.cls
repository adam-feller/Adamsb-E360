public without sharing class MerchChecklistDAO {

    public static List<Merch_Checklist__c> getMerchChecklistsByAccountIds(Set<Id> accountId){
        Date today = System.today();
        return [SELECT Id, Name, Account__c, General_Comments__c, OwnerId, Requested_Completion_Date__c, Status__c,                
                Display_Approved_By__c, Title__c
                FROM Merch_Checklist__c 
                WHERE Account__r.Id IN :accountId AND Requested_Completion_Date__c <= :today
                ORDER BY NAME DESC];
    }
    
    public static Merch_Checklist__c getMerchChecklistById(Id merchId){
        return [SELECT Id, Name, Account__c, General_Comments__c, OwnerId, Requested_Completion_Date__c, Status__c,                
                Display_Approved_By__c, Title__c
                FROM Merch_Checklist__c 
                WHERE Id = :merchId
                LIMIT 1];
    }

    public static List<Merch_Checklist__c> updateMerchChecklists(List<Merch_Checklist__c> merchChecklistsToUpdate) {
        update merchChecklistsToUpdate;
        return merchChecklistsToUpdate;
    }
}
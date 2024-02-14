public with sharing class AccountContactRelationDAO {

    public static List<AccountContactRelation> getAccountContactRelation(Set<Id> contactIds){
        return [SELECT Id, AccountId, Account.ExternalId__c, ContactId, Contact.Email 
                FROM AccountContactRelation 
                WHERE ContactId IN :contactIds];
    }

    public static List<AccountContactRelation> updateAccountContactRelation(List<AccountContactRelation> accountContactRelationsToUpdate){
        update accountContactRelationsToUpdate;
        return accountContactRelationsToUpdate;
    }
}
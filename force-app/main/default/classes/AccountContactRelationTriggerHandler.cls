public without sharing class AccountContactRelationTriggerHandler {

    public static void processAccountContactRelationIntegration(List<AccountContactRelation> accountContactRelationList) {
        Set<Id> accountIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        for(AccountContactRelation acrObj : accountContactRelationList){
            accountIds.add(acrObj.AccountId);
            contactIds.add(acrObj.ContactId);
        }

        Map<Id, Account> accountMap = new map<Id, Account>([SELECT Id, ExternalId__c From Account WHERE Id IN :accountIds and ExternalId__c != null]);
        Map<Id, Contact> contactMap = new map<Id, Contact>([SELECT Id, Email From Contact WHERE Id IN :contactIds AND Email != null]);
        for(AccountContactRelation acrObj : accountContactRelationList){
            if (accountMap.containsKey(acrObj.AccountId) && contactMap.containsKey(acrObj.ContactId)){
                acrObj.ExternalId__c = accountMap.get(acrObj.AccountId).ExternalId__c + '*' + contactMap.get(acrObj.ContactId).Email;
            }
        }
    }

    public static void processAccountRollup(List<AccountContactRelation> acrList, Map<Id, AccountContactRelation> acrOldMap){
        Set<Id> contactIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();

        for(AccountContactRelation acr : acrList){
            //field change
            if(acrOldMap.size()>0){
                AccountContactRelation oldACR = acrOldMap.get(acr.Id);
                if(acr.IsActive != oldACR.IsActive){
                    contactIds.add(acr.ContactId);
                }
            }
            //record insert/delete
            else{
                contactIds.add(acr.ContactId);
            }
        }

        //get all related Accounts
        List<AccountContactRelation> allActs = [
            SELECT Id, AccountId
            FROM AccountContactRelation
            WHERE ContactId IN :contactIds
            ALL ROWS
        ];

        for(AccountContactRelation acr : allActs){
            accountIds.add(acr.AccountId);
        }
        if(contactIds.size()>0){
            ContactTriggerHandler.calculateRollups(accountIds);
        }
    }
}
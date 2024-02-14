public with sharing class VIPOrderEntryController {

    @AuraEnabled
    public static String getAccountCode(Id accountId){
        List<Account> accountList = AccountDAO.getAccountsByIds(new Set<Id>{accountId});

        if(!accountList.isEmpty()){
            return accountList[0].VIP_Account_Number__c;
        }
        return null;
    }
}
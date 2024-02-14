public without sharing class AccountTermTypeDAO {

    public static List<Account_Term_Type__mdt> getAccountTermTypeErrorCodes(){
        return [SELECT Id, BU__c, Term_Type__c, Prevent_Order__c
                FROM Account_Term_Type__mdt];
    }
}
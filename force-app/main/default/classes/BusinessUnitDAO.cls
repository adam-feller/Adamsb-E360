public without sharing class BusinessUnitDAO {

    public static List<Business_Unit__c> getBusinessUnits(String vipInstance){
        return [SELECT Id, Name, VIP_API_URL__c, VIP_API_User_Name__c, VIP_API_User_Password__c, VIPCookie__c
                FROM Business_Unit__c
                WHERE Name = :vipInstance];
    }
}
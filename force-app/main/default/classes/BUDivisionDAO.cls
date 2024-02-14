public with sharing class BUDivisionDAO {

    public static List<BU_Division__mdt> getBuDivisions(){
        return [SELECT Id, MasterLabel, Division__c, DeveloperName
                FROM BU_Division__mdt];
    }
}
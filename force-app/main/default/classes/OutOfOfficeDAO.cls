public without sharing class OutOfOfficeDAO {

    public static List<Out_Of_Office__c> getOutOfOffices(Date startDate, Date endDate){        
        List<Out_of_Office__c> oooList = [SELECT Who_Is_Out__c, Start_Date__c, End_Date__c 
                FROM Out_Of_Office__c
                WHERE Start_Date__c <= today AND End_Date__c >= today
                AND Who_Is_Out__c != null];
        return oooList;
    }
}
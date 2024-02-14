public with sharing class CallSchedulingFrequencyDAO {

    public static List<Call_Scheduling_Frequency__mdt> getCallSchedlingFrequency(){
        return [SELECT MasterLabel, Days_To_Advance__c, Preset_Start_Date__c, Frequency_Category__c 
                FROM Call_Scheduling_Frequency__mdt];
    }
}
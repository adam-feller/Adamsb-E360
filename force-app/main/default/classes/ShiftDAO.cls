public without sharing class ShiftDAO {
    
    public static List<Shift__c> getShifts(){
        return [SELECT Employee__c, Employee__r.Spanish_Bilingual__c, Start_Time__c, End_Time__c, Today_Shift_Start_Time__c, Today_Shift_End_Time__c, 
                (SELECT Start_Date__c, Start_Time__c, End_Date__c, End_Time__c FROM Shift_Changes__r WHERE Active__c = true ORDER BY CreatedDate DESC LIMIT 1)
                FROM Shift__c WHERE Employee__r.isActive = true];
    }
    
    public static List<Shift__c> getShiftsById(Set<Id> shiftIds){
        return [SELECT Employee__c, Employee__r.Spanish_Bilingual__c, Start_Time__c, End_Time__c, Today_Shift_Start_Time__c, Today_Shift_End_Time__c, 
                (SELECT Start_Date__c, Start_Time__c, End_Date__c, End_Time__c FROM Shift_Changes__r WHERE Active__c = true ORDER BY CreatedDate DESC LIMIT 1)
                FROM Shift__c WHERE Employee__r.isActive = true AND Id IN :shiftIds LIMIT 1];
    }
    
}
public without sharing class CallSurveyDAO {
    
    public static Call_Survey__c getCallSurveyById(Id callSurveyId) {
        return [SELECT Id, Inbound_Outbound__c FROM Call_Survey__c WHERE Id =:callSurveyId LIMIT 1];
    }
    
    public static List<Call_Survey__c> getCallSurveysBySideBySideId(Id sideBySideId) {
        return [SELECT Id, Account__r.Id, Account__r.Name, CreatedBy.Name, CreatedDate, Date_Completed__c, LastModifiedBy.Name, 
            Score__c, Status__c, Inbound_Outbound__c, Side_by_Side__c                                        
            FROM Call_Survey__c
            WHERE Side_by_Side__c = :sideBySideId ORDER BY CreatedDate DESC];
    }

    public static List<Call_Survey__c> getCallSurveysBySideBySideIdComplete(Id sideBySideId) {
        return [SELECT Id, Account__r.Id, Account__r.Name, CreatedBy.Name, CreatedDate, Date_Completed__c, LastModifiedBy.Name, 
            Score__c, Status__c, Inbound_Outbound__c, Side_by_Side__c                                        
            FROM Call_Survey__c
            WHERE Side_by_Side__c = :sideBySideId AND Status__c = 'Complete' ORDER BY CreatedDate DESC];
    }    

}
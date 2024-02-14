public with sharing class BestSurveyPausedInterview {
    @AuraEnabled
    public static FlowRecordRelation getInterviews(Id recordId) {
        FlowRecordRelation data = null;
        List<FlowRecordRelation> dataList = [ SELECT 
                    ParentId, Parent.InterviewLabel, Parent.PauseLabel, Parent.Guid,
                    Parent.CurrentElement, Parent.CreatedDate, Parent.Owner.Name 
                FROM FlowRecordRelation 
                WHERE RelatedRecordId = :recordId
                ORDER BY Parent.CreatedDate DESC 
                LIMIT 1];
        if(!dataList.isEmpty()){
            data = dataList[0];
        }
        return data;
    }

    @AuraEnabled
    public static void deleteIncompleteSurveys(Id recordId, DateTime interviewStart, Id currentUser, String resumedFlowGuid){
        system.debug('resumedFlowGuid: ' + resumedFlowGuid);
        List<Store_Survey__c> incompleteSurvey;
        if(resumedFlowGuid == null){
            incompleteSurvey = [SELECT Id 
                                FROM Store_Survey__c 
                                WHERE Retail_Store_Account__c = :recordId
                                AND Completed__c = false
                                AND LastModifiedDate > :interviewStart
                                AND CreatedById = :currentUser
                                LIMIT 1];
            system.debug('Incomplete Survey Results: ' + incompleteSurvey);
        }else{
            incompleteSurvey = [SELECT Id 
                                FROM Store_Survey__c 
                                WHERE Retail_Store_Account__c = :recordId
                                AND Completed__c = false
                                AND Related_Flow_Guid__c = :resumedFlowGuid
                                LIMIT 1];
            system.debug('Incomplete Survey Results: ' + incompleteSurvey);
        }
        if(!incompleteSurvey.isEmpty()){
                delete incompleteSurvey;
            }
    }

    @AuraEnabled
    public static void updateTaskAssignee(String assignedUser, Id recordId, String currentUser, DateTime interviewStart){
        Store_Survey__c survey = [SELECT Id, CreatedDate, CreatedById, Retail_Store_Account__c, TaskAssignee__c
                                        FROM Store_Survey__c
                                        WHERE Retail_Store_Account__c = :recordId
                                        AND CreatedDate > :interviewStart
                                        AND CreatedById = :currentUser
                                        LIMIT 1];
        
        survey.TaskAssignee__c = assignedUser;
        update survey;                               
    }
    
    @AuraEnabled(cacheable=true)
    public static user getUserInfo() {
        String userId = UserInfo.getUserId(); // current user
        return [SELECT ID, FirstName, LastName, Name, Title, Profile.Name,  Email From User WHERE ID =: userId LIMIT 1];
    }
}
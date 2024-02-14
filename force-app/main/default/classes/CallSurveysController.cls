public without sharing class CallSurveysController {
   
    @AuraEnabled
    public static List<SurveyWrapper> getCallSurveys(Id sideBySideId) {
        Side_by_Side__c sbs = [SELECT Id, ISR_CSR__r.Id, Performed_By__r.Id FROM Side_by_Side__c WHERE Id =:sideBySideId LIMIT 1];
        List<Call_Survey__c> callSurveys = new List<Call_Survey__c>();
        if (UserInfo.getUserId() == sbs.ISR_CSR__r.Id) {
            //Get only Completed Call Surveys for this Side By Side
            callSurveys = CallSurveyDAO.getCallSurveysBySideBySideIdComplete(sideBySideId);
        } else {
            //Get all of the Call Surveys for this Side By Side
            callSurveys = callSurveys = CallSurveyDAO.getCallSurveysBySideBySideId(sideBySideId);
        }
        
        //Get the Current User's Profile
        Id currentUserProfileId = UserInfo.getProfileId();
        Profile currentUserProfile = [SELECT Id, Name FROM Profile WHERE Id =: currentUserProfileId];


        List<SurveyWrapper> surveys = new List<SurveyWrapper>();
        for (Call_Survey__c cs : callSurveys) {
            SurveyWrapper s = new SurveyWrapper();
            s.id = cs.Id;
            s.account = cs.Account__r.Name;
            s.accountURL = '/' + cs.Account__r.Id;
            s.inbound = cs.Inbound_Outbound__c;
            s.createdBy = cs.CreatedBy.Name;
            s.createdDate = cs.CreatedDate;
            s.score = cs.Score__c/100;
            s.status = cs.Status__c;
            s.dateCompleted = cs.Date_Completed__c;
            if (cs.Status__c != 'Complete' && (UserInfo.getUserId() == sbs.Performed_By__r.Id || currentUserProfile.Name == 'System Administrator')) {
                s.buttonLabel = 'Resume';
                s.buttonIcon = 'action:new_note';
            } else {
                s.buttonLabel = 'View';
                s.buttonIcon = 'action:preview';
            }

            surveys.add(s);
        }
        return surveys;
    }

    public class SurveyWrapper {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String account;
        @AuraEnabled
        public String accountURL;        
        @AuraEnabled
        public String inbound;
        @AuraEnabled
        public String createdBy;
        @AuraEnabled
        public DateTime createdDate;
        @AuraEnabled
        public Decimal score;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public Date dateCompleted;
        @AuraEnabled
        public String buttonLabel;
        @AuraEnabled
        public String buttonIcon;
    }
    
}
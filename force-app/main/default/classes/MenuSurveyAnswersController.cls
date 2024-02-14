public class MenuSurveyAnswersController {

    public final static Id MENU_SURVEY_ANSWER_RECORDTYPEID = Schema.SObjectType.Survey_Answer__c.getRecordTypeInfosByDeveloperName().get('Menu_Survey_Answers').getRecordTypeId();
    public final static String QUESTION_2_ANSWER = 'What are the cocktails?';
    public final static String QUESTION_3_ANSWER = 'What are the well brands?';

    @AuraEnabled(cacheable=true)
    public static List<Survey_Answer__c> getSurveyQuestions(Id surveyId) {
        try {
            List<Survey_Answer__c> surveyAnswers = new List<Survey_Answer__c>();
            //Get all the Survey Questions
            List<Survey_Answer__c> answers = SurveyAnswersDAO.getAllSurveyAnswersBySurveyId(surveyId);
            //Loop through all the answers    
            for (Survey_Answer__c q : answers) {
                if(q.Question__c == QUESTION_2_ANSWER){
                    surveyAnswers.add(q);
                }
            }
            return surveyAnswers;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Survey_Answer__c> getSurveyWellQuestions(Id surveyId) {
        try {
            List<Survey_Answer__c> surveyAnswers = new List<Survey_Answer__c>();
            //Get all the Survey Questions
            List<Survey_Answer__c> answers = SurveyAnswersDAO.getAllSurveyAnswersBySurveyId(surveyId);
            //Loop through all the answers    
            for (Survey_Answer__c q : answers) {
                if(q.Question__c.contains(QUESTION_3_ANSWER)){
                    surveyAnswers.add(q);
                }
            }
            return surveyAnswers;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void insertSurveyAnswer(Integer questionNumber, String surveyId) {
        try {
            List<Survey_Answer__c> surveyAnswers = new List<Survey_Answer__c>();
            Survey_Answer__c s = new Survey_Answer__c();
            s.Survey__c = surveyId;
            s.Order__c = questionNumber;
            s.Question__c = QUESTION_2_ANSWER;
            s.Required__c = true;
            s.RecordTypeId = MENU_SURVEY_ANSWER_RECORDTYPEID;
            surveyAnswers.add(s);
    
            if (surveyAnswers.size() > 0) {
                SurveyAnswersDAO.insertSurveyAnswers(surveyAnswers);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static void deleteSurveyAnswer(String surveyAnswerId) {
        try {
            List<Survey_Answer__c> surveyAnswers = new List<Survey_Answer__c>();
            Survey_Answer__c s = new Survey_Answer__c(id = surveyAnswerId);
            surveyAnswers.add(s);
    
            if (surveyAnswers.size() > 0) {
                SurveyAnswersDAO.deleteSurveyAnswers(surveyAnswers);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static void setProductId(Id questionId, Id productId) {
        try {
            List<Survey_Answer__c> surveyAnswers = new List<Survey_Answer__c>();
            Survey_Answer__c s = new Survey_Answer__c();
            s.Id = questionId;
            s.Product__c = productId;
            surveyAnswers.add(s);
    
            if (surveyAnswers.size() > 0) {
                SurveyAnswersDAO.updateSurveyAnswers(surveyAnswers);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static void setCheckboxValue(Id questionId, Boolean checkBoxValue) {
        try{
            List<Survey_Answer__c> surveyAnswers = new List<Survey_Answer__c>();
            Survey_Answer__c s = new Survey_Answer__c();
            s.Id = questionId;
            s.Is_Reyes_Product__c = checkBoxValue;
            s.RadioButtonSet__c = true;
            
            if(checkBoxValue == false){
                s.Product__c = null;
            }
            else {
                s.Liquor_Type__c = null;
                s.Liquor_Brand__c = null;
            }
            surveyAnswers.add(s);
    
            if (surveyAnswers.size() > 0) {
                SurveyAnswersDAO.updateSurveyAnswers(surveyAnswers);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void setWellCheckboxValue(Id questionId, Boolean checkBoxValue) {
        try{
            List<Survey_Answer__c> surveyAnswers = new List<Survey_Answer__c>();
            Survey_Answer__c s = new Survey_Answer__c();
            s.Id = questionId;
            s.Is_Reyes_Product__c = checkBoxValue;
            s.RadioButtonSet__c = true;
            if(checkBoxValue == false){
                s.Product__c = null;
            }
            else {
                s.Well_Brand__c = null;
            }
            surveyAnswers.add(s);
    
            if (surveyAnswers.size() > 0) {
                SurveyAnswersDAO.updateSurveyAnswers(surveyAnswers);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static void setPicklistAnswer(Id questionId, String controllingAnswer, String dependentAnswer) {
        try{
            List<Survey_Answer__c> surveyAnswers = new List<Survey_Answer__c>();
            Survey_Answer__c s = new Survey_Answer__c();
            s.Id = questionId;
            s.Liquor_Type__c = controllingAnswer;
            s.Liquor_Brand__c = dependentAnswer;
            surveyAnswers.add(s);
    
            if (surveyAnswers.size() > 0) {
                SurveyAnswersDAO.updateSurveyAnswers(surveyAnswers);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
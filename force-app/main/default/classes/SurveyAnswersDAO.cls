public without sharing class SurveyAnswersDAO {
    
    public static List<Survey_Answer__c> getAllSurveyAnswersBySurveyId(Id surveyId) {
        return [SELECT Id, Is_Reyes_Product__c, Order__c, Question__c, Choices__c, Type__c, Required__c, 
        Answer__c, Hidden__c, Product__c, RadioButtonSet__c, Liquor_Brand__c, Liquor_Type__c, Well_Type__c, Well_Brand__c
                FROM Survey_Answer__c 
                WHERE Survey__c = :surveyId
                ORDER BY Order__c];
	}
    
    public static Survey_Answer__c getSurveyAnswerById(Id answerId) {
        return [SELECT Id, Survey__c, Question__c, Answer__c, Order__c, Hidden__c 
                FROM Survey_Answer__c 
                WHERE Id = :answerId LIMIT 1];
    }
    
    public static Survey_Answer__c getSurveyAnswerByQuestion(Id SurveyId, String question) {
        return [SELECT Id, Survey__c, Question__c, Answer__c, Order__c, Hidden__c 
                FROM Survey_Answer__c 
                WHERE Survey__c = :surveyId AND Question__c = :question LIMIT 1];
    }
    
    public static List<Survey_Answer__c> updateSurveyAnswers(List<Survey_Answer__c> surveyAnswersToUpdate) {
        update surveyAnswersToUpdate;
        return surveyAnswersToUpdate;
    }

    public static List<Survey_Answer__c> insertSurveyAnswers(List<Survey_Answer__c> surveyAnswersToInsert) {
        insert surveyAnswersToInsert;
        return surveyAnswersToInsert;
    }

    public static void deleteSurveyAnswers(List<Survey_Answer__c> surveyAnswersToDelete) {
        delete surveyAnswersToDelete;
    }
}
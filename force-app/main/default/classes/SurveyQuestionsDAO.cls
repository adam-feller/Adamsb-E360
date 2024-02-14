public without sharing class SurveyQuestionsDAO {
    
    public static List<Survey_Setup__mdt> getSurveySetupsByName(List<String> surveys) {
    	return [SELECT Id, Categories__c, MasterLabel FROM Survey_Setup__mdt WHERE MasterLabel IN :surveys];
    }
    
    public static Survey_Setup__mdt getSurveySetupByName(String surveyName) {
        return [SELECT Id, Categories__c, Allow_Survey_to_be_Turned_Off__c, Allow_Categories_to_be_Turned_Off__c, Show_Uncategorized_Questions__c 
				FROM Survey_Setup__mdt WHERE MasterLabel =: surveyName LIMIT 1];
    }
    
    public static List<Survey_Question__mdt> getCustomMetaDataSurveyQuestions(Set<Id> surveyIds) {
        return [SELECT Id, DeveloperName, Order__c, Category__c, Question__c, Choices__c, Type__c, Points__c, Required__c, Default_Hidden__c,
                Survey_Setup__r.MasterLabel
                FROM Survey_Question__mdt 
                WHERE Survey_Setup__c IN :surveyIds ORDER BY Category__c,Order__c];
    }
    
    public static List<Survey_Question__mdt> getCustomMetaDataSurveyQuestionsById(Id surveyId) {
        return [SELECT Id, DeveloperName, Order__c, Category__c, Question__c, Choices__c, Type__c, Points__c, Required__c, Default_Hidden__c,
                Survey_Setup__r.MasterLabel
                FROM Survey_Question__mdt 
                WHERE Survey_Setup__c = :surveyId];
    }
    
    public static List<Call_Survey_Question__c> getAllSurveyQuestionsByCallSurveyIdName(Id callSurveyID, String surveyName) {
        return [SELECT Id, Order__c, Category__c, Question__c, Choices__c, Type__c, Turned_On__c, Answer__c, Answer_Long__c 
                FROM Call_Survey_Question__c 
                WHERE Call_Survey__c = :callSurveyId AND Survey_Name__c = :surveyName ORDER BY Category__c,Order__c];
	}
    
    public static Call_Survey_Question__c getSurveyQuestionById(Id questionId) {
        return [SELECT Id, Call_Survey__c, Survey_Name__c, Category__c, Question__c, Answer__c, Answer_Long__c, Turned_On__c FROM Call_Survey_Question__c 
                WHERE Id = :questionId LIMIT 1];
    }
    
    public static List<Call_Survey_Question__c> getSurveyQuestionsBySurveyIdandCategory(Id callSurveyId, String surveyName, String surveyCategory) {
        return [SELECT Id FROM Call_Survey_Question__c 
                WHERE Call_Survey__c = :callSurveyId AND Survey_Name__c = :surveyName AND Category__c = :surveyCategory];
    }

    public static List<Call_Survey_Question__c> getSurveyQuestionsBySurveyId(Id callSurveyId, String surveyName) {
        return [SELECT Id FROM Call_Survey_Question__c 
                WHERE Call_Survey__c = :callSurveyId AND Survey_Name__c = :surveyName];
    }
    
    public static List<Call_Survey_Question__c> getCallSurveyCommentsByCallSurveyIds(Set<Id> callSurveyIds) {
        return [SELECT Id, Answer_Long__c, Survey_Name__c FROM Call_Survey_Question__c 
				WHERE Call_Survey__c IN :callSurveyIds AND Question__c LIKE '%Comments%' 
                ORDER BY Survey_Name__c,Order__c];
    }    

}
public class SurveyAnswersController {
 	
    @InvocableMethod(label='Create Survey Answers')
    public static void createSurveyAnswers(List<String> parameters) {
        List<String> params = parameters[0].split('\\|');
        
        //First get the Survey Setup
        Survey_Setup__mdt surveySetup = SurveyQuestionsDAO.getSurveySetupByName(params[1]);
    
        //Then get all the Custom Metadata Survey Questions
        List<Survey_Question__mdt> questions = SurveyQuestionsDAO.getCustomMetaDataSurveyQuestionsById(surveySetup.Id);        
        List<Survey_Answer__c> surveyAnswersToInsert = new List<Survey_Answer__c>();
        for (Survey_Question__mdt a : questions) {
            Survey_Answer__c newAnswer = new Survey_Answer__c();
            newAnswer.Survey__c = params[0];
            newAnswer.Type__c = a.Type__c;
            newAnswer.Required__c = a.Required__c;
            newAnswer.Question__c = a.Question__c;
            newAnswer.Order__c = a.Order__c;
            newAnswer.Choices__c = a.Choices__c;
            newAnswer.Hidden__c = a.Default_Hidden__c;
            surveyAnswersToInsert.add(newAnswer);
        }
        if (surveyAnswersToInsert.size() > 0) {
            SurveyAnswersDAO.insertSurveyAnswers(surveyAnswersToInsert);
        }
    }
        
    @AuraEnabled(cacheable=true)
    public static List<questionWrapper> getSurveyQuestions(Id surveyId) {
		//Returning this Wrapper to the User Interface
        List<questionWrapper> surveyQuestions = new List<questionWrapper>();   //return this wrapper of Survey Questions
        
        //Get all the Survey Questions
        List<Survey_Answer__c> answers = SurveyAnswersDAO.getAllSurveyAnswersBySurveyId(surveyId);

        //Loop through all the answers    
        for (Survey_Answer__c q : answers) {
            questionWrapper addQuestion = addQuestion(q);            
            surveyQuestions.add(addQuestion);
        }
        return surveyQuestions;
    }
    
    
    @AuraEnabled
    public static void setAnswer(Id questionId, String answer) {
        List<Survey_Answer__c> surveyAnswersToUpdate = new List<Survey_Answer__c>();
        Survey_Answer__c surveyAnswer = SurveyAnswersDAO.getSurveyAnswerById(questionId);
        surveyAnswer.Answer__c = answer;
        surveyAnswersToUpdate.add(surveyAnswer);        
        //Update the hidden Other Opportunities field if User selected 'Other'
        if (surveyAnswer.Question__c.contains('What opportunities')) {
            Survey_Answer__c otherSurveyAnswer = SurveyAnswersDAO.getSurveyAnswerByQuestion(surveyAnswer.Survey__c, 'Other Opportunities');
            if (surveyAnswer.Answer__c.contains('Other') && otherSurveyAnswer != null) {
            	//Unhide the Other text area
                otherSurveyAnswer.Hidden__c = false;
            } else {
            	//Hide the Other text area         	
	            otherSurveyAnswer.Hidden__c = true;
            }
            surveyAnswersToUpdate.add(otherSurveyAnswer);  
        }
        SurveyAnswersDAO.updateSurveyAnswers(surveyAnswersToUpdate);
    }
            
    public static questionWrapper addQuestion(Survey_Answer__c q) {
        questionWrapper addQuestion = new questionWrapper();
        addQuestion.q = q;
        if (q.Type__c == 'Picklist') {                        
	       addQuestion.isPicklist = true;                        
        }
        if (q.Type__c == 'Multi-Select Picklist') {                        
	       addQuestion.isMultiPicklist = true;
           List<String> mpanswers = new List<String>();
            if (q.Answer__c <> null) {
           		for (String answer : q.Answer__c.split(', ')) {  
					mpanswers.add(answer);               	
        		}        
            } else {
                mpanswers.add(q.Answer__c);
            }
	    	addQuestion.multipicklistchoices = mpanswers;            
        }        
        if (q.Type__c == 'Text Area') {            
    	    addQuestion.isTextArea = true;
        }
        if (q.Required__c == true) {
            addQuestion.displayLabel = q.Question__c + ' (required)';
        } else {
            addQuestion.displayLabel = q.Question__c;
        }

        if (q.Choices__c != null && q.Choices__c != '') {                        
        	List<PicklistOptions> choices = new List<PicklistOptions>();            
            for (String choice : q.Choices__c.split('\r\n')) {                            
            	PicklistOptions newChoice = new PicklistOptions();
                newChoice.label = choice;
                newChoice.value = choice;
                choices.add(newChoice);
        	}        
	    	addQuestion.choices = choices;
        }
        return addQuestion;
    }
    
    public class questionWrapper {
        @AuraEnabled
        public Survey_Answer__c q {get; set;}
        @AuraEnabled
        public String displayLabel {get; set;}
        @AuraEnabled
        public Boolean isPicklist {get; set;}
        @AuraEnabled
        public Boolean isMultiPicklist {get; set;}
        @AuraEnabled
        public Boolean isTextArea {get; set;}
        @AuraEnabled
        public List<PicklistOptions> choices {get; set;}
        @AuraEnabled
        public List<String> multipicklistchoices {get; set;}
    }

    public class PicklistOptions {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String value { get; set; }
    }
}
public without sharing class SurveyQuestionsController {

    @InvocableMethod(label='Create Call Survey Questions')
    public static void createSurveyQuestions(List<String> parameters) {       
        Id recordId = parameters[0];
        //Get the Call Survey so we know if this is Inbound or Outbound
        Call_Survey__c callSurvey = CallSurveyDAO.getCallSurveyById(recordId);

        List<String> surveys = new List<String>();
        if (callSurvey.Inbound_Outbound__c == 'Inbound Call') {
            surveys = new List<String>{'Inbound Call','Customer De-escalation','Etiquette','Sales','Technology','Supervisor Section'};
        } else {
            surveys = new List<String>{'Outbound Call','Customer De-escalation','Etiquette','Sales','Technology', 'Supervisor Section'};
        }
        //First get the Survey Setup
        List<Survey_Setup__mdt> surveySetups = SurveyQuestionsDAO.getSurveySetupsByName(surveys);
        Set<Id> surveyIds = new Set<Id>(); 
        for (Survey_Setup__mdt ss : surveySetups) {
            surveyIds.add(ss.Id);
        }
    
        //Then get all the Custom Metadata Survey Questions
        List<Survey_Question__mdt> questions = SurveyQuestionsDAO.getCustomMetaDataSurveyQuestions(surveyIds);        
        List<Call_Survey_Question__c> callSurveyQuestions = new List<Call_Survey_Question__c>();
        for (Survey_Question__mdt q : questions) {
            Call_Survey_Question__c newQuestion = new Call_Survey_Question__c();
            newQuestion.Call_Survey__c = recordId;
            newQuestion.Survey_Name__c = q.Survey_Setup__r.MasterLabel;
            newQuestion.Category__c = q.Category__c;
            newQuestion.Type__c = q.Type__c;
            newQuestion.Question__c = q.Question__c;
            newQuestion.Order__c = q.Order__c;
            newQuestion.Choices__c = q.Choices__c;
            newQuestion.Points__c = q.Points__c;
            newQuestion.Turned_On__c = true;
            callSurveyQuestions.add(newQuestion);
        }
        if (callSurveyQuestions.size() > 0) {
            insert callSurveyQuestions;
        }
    }
   
    @AuraEnabled(cacheable=true)
    public static List<wrapComments> getSurveyComments(Id sideBySideId) {  
        List<wrapComments> commentsList = new List<wrapComments>();
        List<Call_Survey__c> callSurveys = CallSurveyDAO.getCallSurveysBySideBySideIdComplete(sideBySideId);
        Set<Id> callSurveyIds = new Set<Id>();
        for (Call_Survey__c c : callSurveys) {
            callSurveyIds.add(c.Id);
        }
        List<Call_Survey_Question__c> questions = SurveyQuestionsDAO.getCallSurveyCommentsByCallSurveyIds(callSurveyIds);

        //Order we want the categories to show
        List<String> cats = new List<String>{'Inbound Call', 'Outbound Call', 'Customer De-escalation', 'Etiquette', 'Sales', 'Technology', 'Supervisor Section'}; 
        String oldCat = '';
        for (String cat : cats) {
            for (Call_Survey_Question__c q : questions) {
                if (q.Survey_Name__c == cat && q.Answer_Long__c <> null) {
                    wrapComments comments = new wrapComments();
                    comments.Id = q.Id;
                    comments.Category = q.Survey_Name__c;                    
                    if (q.Survey_Name__c <> oldCat) {
                        comments.isNewCategory = true;
                        oldCat = q.Survey_Name__c;
                    } else {
                        comments.isNewCategory = false;
                    }
                    comments.Comments = q.Answer_Long__c;
                    commentsList.add(comments);
                }
            }
        }
        return commentsList;
    }


    @AuraEnabled(cacheable=true)
    public static surveyWrapper getSurveyQuestions(String surveyName, Id callSurveyId) {
        //Returning this Wrapper to the User Interface
        surveyWrapper surveyDetails = new surveyWrapper();
        List<questionWrapper> surveyQuestions = new List<questionWrapper>();   //return this wrapper of Survey Questions
        
        //First get the Id and Categories of the Survey
        Survey_Setup__mdt surveySetup = SurveyQuestionsDAO.getSurveySetupByName(surveyName);
        surveyDetails.canTurnSurveyOff = surveySetup.Allow_Survey_to_be_Turned_Off__c;
        surveyDetails.canTurnCategoryOff = surveySetup.Allow_Categories_to_be_Turned_Off__c;

        List<String> cats = new List<String>();
        if (surveySetup.Categories__c != null) {
            cats = surveySetup.Categories__c.split('\r\n');
        }
    
        //Go through the Categories and build our wrapper of questions
        String oldCat = '';

        //Get all the Survey Questions
        List<Call_Survey_Question__c> questions = SurveyQuestionsDAO.getAllSurveyQuestionsByCallSurveyIdName(callSurveyId, surveyName);

        Boolean allQuestionsOff = true;  //Variable to check if all questions for this survey are off
        //Loop through all the Non Categorized questions that should be first
        if (surveySetup.Show_Uncategorized_Questions__c == 'Before Categories') {
            for (Call_Survey_Question__c q : questions) {
                if (q.Category__c == null || q.Category__c == '') {
                    questionWrapper addQuestion = addQuestion(q);                   
                    if (q.Turned_On__c == true) {
                        allQuestionsOff = false;
                    }
                    surveyQuestions.add(addQuestion);
                }
            }
        }        

        //Loop through all the questions that have categories
        for (String cat : cats) {            
            for (Call_Survey_Question__c q : questions) {
                if (q.Category__c == cat) {
                    questionWrapper addQuestion = addQuestion(q);
                    if (oldCat <> cat) {
                        addQuestion.isNewCategory = true;
                        oldCat = cat;
                    } else {
                        addQuestion.isNewCategory = false;
                    }      
                    if (q.Turned_On__c == true) {
                        allQuestionsOff = false;
                    }                             
                    surveyQuestions.add(addQuestion);
                }                
            }
        }
        
        //Loop through all the Non Categorized questions that should be last
        if (surveySetup.Show_Uncategorized_Questions__c == 'After Categories') {
            for (Call_Survey_Question__c q : questions) {
                if (q.Category__c == null || q.Category__c == '') {
                    questionWrapper addQuestion = addQuestion(q);
                    if (q.Turned_On__c == true) {
                        allQuestionsOff = false;
                    }                    
                    surveyQuestions.add(addQuestion);
                }
            }
        }
        surveyDetails.questions = surveyQuestions;
        surveyDetails.isSurveyOn = !allQuestionsOff;
        return surveyDetails;
    }
    
    public static questionWrapper addQuestion(Call_Survey_Question__c q) {
        questionWrapper addQuestion = new questionWrapper();
        addQuestion.q = q;
        if (q.Type__c == 'Checkbox') {
        	addQuestion.isCheckbox = true;
            if (q.Answer__c == 'true') {
            	addQuestion.isChecked = true;
            } else {                        
                addQuestion.isChecked = false;
            }
        }
        if (q.Type__c == 'Picklist') {                        
	       addQuestion.isPicklist = true;                        
        }  
        if (q.Type__c == 'Text Area') {
    	    addQuestion.isTextArea = true;
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

    @AuraEnabled
    public static void turnOnOffCategory(Id questionId, Boolean offon) {
        Call_Survey_Question__c question = SurveyQuestionsDAO.getSurveyQuestionById(questionId);    
        List<Call_Survey_Question__c> questions = SurveyQuestionsDAO.getSurveyQuestionsBySurveyIdandCategory(question.Call_Survey__c, question.Survey_Name__c, question.Category__c);
        for (Call_Survey_Question__c q : questions) {
            q.Turned_On__c = offon;
        }        
        update questions;
    }

    @AuraEnabled
    public static void turnOnOffSurvey(String surveyId, String surveyName, Boolean offon) {
        List<Call_Survey_Question__c> questions = SurveyQuestionsDAO.getSurveyQuestionsBySurveyId(surveyId, surveyName);
        for (Call_Survey_Question__c q : questions) {
            q.Turned_On__c = offon;
        }        
        update questions;
    }

    @AuraEnabled
    public static void setCheckboxAnswer(Id questionId, Boolean answer) {
        Call_Survey_Question__c question = [SELECT Id FROM Call_Survey_Question__c WHERE Id = :questionId LIMIT 1];
        if (answer) {
            question.Answer__c = 'true';
        } else {
            question.Answer__c = 'false';
        }
        update question;
    }

    @AuraEnabled
    public static void setAnswer(Id questionId, String answer) {        
        Call_Survey_Question__c question = SurveyQuestionsDAO.getSurveyQuestionById(questionId);
        question.Answer__c = answer;
        //Special scoring for the Supervisor Overall Rating
        if (question.Survey_Name__c == 'Supervisor Section' && question.Question__c == 'Overall Rating') {
            if (answer == 'Exceeds Expectations') {
                question.Points__c = 100;
            } else if (answer == 'Meets Expectations') {
                question.Points__c = 85;
            } else if (answer == 'Partially Meets Expectations') {
                question.Points__c = 50;            
            } else {
                question.Points__c = 0;
            }
        }        
        update question;
    }

    @AuraEnabled
    public static void setAnswerLong(Id questionId, String answer) {        
        Call_Survey_Question__c question = SurveyQuestionsDAO.getSurveyQuestionById(questionId);
        question.Answer_Long__c = answer;        
        update question;
    }

    public class surveyWrapper {
        @AuraEnabled
        public Boolean canTurnSurveyOff {get; set;}
        @AuraEnabled
        public Boolean isSurveyOn {get; set;}        
        @AuraEnabled
        public Boolean canTurnCategoryOff {get; set;}
        @AuraEnabled
        public List<questionWrapper> questions {get; set;}
    }
    public class questionWrapper {
        @AuraEnabled
        public Call_Survey_Question__c q {get; set;}
        @AuraEnabled
        public Boolean isNewCategory {get; set;}
        @AuraEnabled
        public Boolean isCheckbox {get; set;}
        @AuraEnabled
        public Boolean isChecked {get; set;}        
        @AuraEnabled
        public Boolean isPicklist {get; set;}
        @AuraEnabled
        public Boolean isTextArea {get; set;}
        @AuraEnabled
        public List<PicklistOptions> choices {get; set;}
    }

    public class PicklistOptions {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String value { get; set; }
    }

    public class wrapComments {
        @AuraEnabled
        public String Id {get; set;}
        @AuraEnabled
        public String Category {get; set;}
        @AuraEnabled
        public Boolean isNewCategory {get; set;}
        @AuraEnabled
        public String Comments {get; set;}
    }

}
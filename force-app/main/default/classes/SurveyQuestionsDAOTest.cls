@isTest
public class SurveyQuestionsDAOTest {
    @TestSetup
    private static void setup() {
        
        //Create new Survey
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        Survey__c testSurvey = new Survey__c(Account__c=testAccount.Id, Survey_Type__c='Non-Buy');
        insert testSurvey;
        //Create Survey Questions
        Survey__c survey = [SELECT Id FROM Survey__c LIMIT 1];
        //Pass the Survey Id and survey type as an Invocable parameter
        List<String> params = new List<String>();
        params.add(survey.Id + '|Non-Buy');
        SurveyAnswersController.createSurveyAnswers(params);
    }

    @isTest
    static void testgetAllSurveyAnswersBySurveyId () {
		//Get the Survey
		Survey__c survey = [SELECT Id FROM Survey__c LIMIT 1];

        Test.startTest();                
        List<Survey_Answer__c> answers = SurveyAnswersDAO.getAllSurveyAnswersBySurveyId(survey.Id);
        Test.stopTest();
		
    	//Verify Questions were created
        System.assertNotEquals(0, answers.size(), 'Should have returned survey answers');
    }  
    
    @isTest
    static void testGetSurveyAnswerById() {
		//Get the Survey Answer
        Survey_Answer__c surveyAnswer = [SELECT Id FROM Survey_Answer__c LIMIT 1];
        
        Test.startTest();                
        Survey_Answer__c answer = SurveyAnswersDAO.getSurveyAnswerById(surveyAnswer.Id);
        Test.stopTest();
		
        System.assertEquals(surveyAnswer.Id, answer.Id, 'Should have retrieved the questions');
    }
    
    @isTest
    static void testGetSurveyAnswerByQuestion() {  
        //Get the Survey Answer
        Survey_Answer__c surveyAnswer = [SELECT Id, Survey__c, Question__c FROM Survey_Answer__c LIMIT 1];

        Test.startTest();                
        Survey_Answer__c answer = SurveyAnswersDAO.getSurveyAnswerByQuestion(surveyAnswer.Survey__c, surveyAnswer.Question__c);
        Test.stopTest();

        System.assertEquals(answer.Id, surveyAnswer.Id, 'An incorrect record returned');
    }
    
    @isTest
    static void testUpdateSurveyAnswers() {  
        //Get the Survey Answers
        List<Survey_Answer__c> surveyAnswers = [SELECT Id FROM Survey_Answer__c];
        
        Test.startTest();
        List<Survey_Answer__c> returned = SurveyAnswersDAO.updateSurveyAnswers(surveyAnswers);
		Test.stopTest();
        System.assertEquals(surveyAnswers.size(), returned.size(), 'Should have updated question with same value');
    }

    @isTest
    static void testInsertSurveyAnswers() {  
        //Get the Survey
		Survey__c survey = [SELECT Id FROM Survey__c LIMIT 1];

        List<Survey_Answer__c> insertList = new List<Survey_Answer__c>();
        Survey_Answer__c sa1 = new Survey_Answer__c (survey__c = survey.Id, Order__c = 2, Question__c	= 'q1');
        insertList.add(sa1);
        Survey_Answer__c sa2 = new Survey_Answer__c (survey__c = survey.Id, Order__c = 3, Question__c	= 'q2');
        insertList.add(sa2);

        Test.startTest();
        List<Survey_Answer__c> returned = SurveyAnswersDAO.insertSurveyAnswers(insertList);
        Test.stopTest();
        System.assertEquals(returned.size(), insertList.size(), 'Should have updated question with same value');	
    }

    @isTest
    static void testDeleteSurveyAnswers() {  
        //Get the Survey Answers
        List<Survey_Answer__c> surveyAnswers = [SELECT Id FROM Survey_Answer__c];

		Test.startTest();
        SurveyAnswersDAO.deleteSurveyAnswers(surveyAnswers);
        Test.stopTest();

        surveyAnswers = [SELECT Id FROM Survey_Answer__c];
        System.assertEquals(0, surveyAnswers.size(), 'Should have no survey questions');	
    }
}
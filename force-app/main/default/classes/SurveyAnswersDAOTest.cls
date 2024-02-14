@isTest
public class SurveyAnswersDAOTest {

    @TestSetup
    private static void setup() {
        
        //Create new Survey
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        Survey__c testSurvey = new Survey__c(Account__c=testAccount.Id, Survey_Type__c='Menu');
        insert testSurvey;
        //Create Survey Questions
        Survey__c survey = [SELECT Id FROM Survey__c LIMIT 1];
        List<Survey_Answer__c> insertList = new List<Survey_Answer__c>();
        Survey_Answer__c sa1 = new Survey_Answer__c (survey__c= survey.Id, Order__c= 2, Question__c= 'What are the cocktails?');
        insertList.add(sa1);
        Survey_Answer__c sa2 = new Survey_Answer__c (survey__c= survey.Id, Order__c= 3, Question__c= 'What are the cocktails?');
        insertList.add(sa2);
        insert insertList;

    }
    @isTest
    static void testGetAllSurveyAnswersBySurveyId() {  
        //Get the Survey 
        Survey__c survey = [SELECT Id FROM Survey__c LIMIT 1];
        
        Test.startTest();
        List<Survey_Answer__c> returned = SurveyAnswersDAO.getAllSurveyAnswersBySurveyId(survey.Id);
        Test.stopTest();

        System.assertEquals(2, returned.size(), 'Incorrect number of answers returned');
    }

    @isTest
    static void testGetSurveyAnswerById() {  

        Survey_Answer__c surveyAnswer = [SELECT Id FROM Survey_Answer__c LIMIT 1];
        
        Test.startTest();
        Survey_Answer__c returned = SurveyAnswersDAO.getSurveyAnswerById(surveyAnswer.Id);
        Test.stopTest();

        System.assertEquals(surveyAnswer.Id, returned.Id, 'Incorrect survey answer returned');
    }

    @isTest
    static void testGetSurveyAnswerByQuestion() {  
        
        Survey__c survey = [SELECT Id FROM Survey__c LIMIT 1];
        
        Test.startTest();
        Survey_Answer__c returned = SurveyAnswersDAO.getSurveyAnswerByQuestion(survey.Id, 'What are the cocktails?');
        Test.stopTest();

        System.assertEquals('What are the cocktails?', returned.Question__c, 'Incorrect answer returned');
    }

    @isTest
    static void testUpdateSurveyAnswers() {  
        
        List <Survey_Answer__c> surveyAnswer = [SELECT Id FROM Survey_Answer__c];
        
        Test.startTest();
        List<Survey_Answer__c> returned = SurveyAnswersDAO.updateSurveyAnswers(surveyAnswer);
        Test.stopTest();

        System.assertEquals(2, returned.size(), 'Incorrect number of answers returned');
    }

    @isTest
    static void testInsertSurveyAnswers() {  
        Survey__c survey = [SELECT Id FROM Survey__c LIMIT 1];
        List <Survey_Answer__c> surveyAnswer = new List <Survey_Answer__c>();
        Survey_Answer__c sa = new Survey_Answer__c();
        sa.Survey__c = survey.Id;
        sa.Answer__c = 'answer Test';
        sa.Question__c = 'Question 1';
        surveyAnswer.add(sa);
        
        Test.startTest();
        List<Survey_Answer__c> returned = SurveyAnswersDAO.insertSurveyAnswers(surveyAnswer);
        Test.stopTest();

        System.assertEquals(1, returned.size(), 'Incorrect number of answers returned');
    }

    @isTest
    static void testDeleteSurveyAnswers() {  
        
        List <Survey_Answer__c> surveyAnswer = [SELECT Id FROM Survey_Answer__c];
        
        Test.startTest();
        SurveyAnswersDAO.deleteSurveyAnswers(surveyAnswer);
        Test.stopTest();
        List <Survey_Answer__c> returned = [SELECT Id FROM Survey_Answer__c WHERE Id = :surveyAnswer[0].Id];

        System.assertEquals(0, returned.size(), 'Incorrect number of answers returned');
    }
}
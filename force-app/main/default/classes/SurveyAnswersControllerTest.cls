@isTest
public class SurveyAnswersControllerTest {

    @TestSetup
    private static void setup() {
        //Create ISR and Field Sales Rep
        User testCS;
       	User testFS;
        System.runAs(new User(Id = UserInfo.getUserId())) {          	
        	Profile csProfile = [SELECT Id FROM Profile WHERE Name = 'Call Center'];
        	Profile fsProfile = [SELECT Id FROM Profile WHERE Name = 'Field Sales'];
        	UserRole isrRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'ISR'];           
        	testCS = TestFactory.createUser(csProfile.Id, isrRole.Id, 'testcs1@gmail.com', null);
        	testFS = TestFactory.createUser(fsProfile.Id, null, 'testfs1@gmail.com', null);
        }
        //Create new Survey
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        Survey__c testSurvey = new Survey__c(Account__c=testAccount.Id, Survey_Type__c='Non-Buy');
        insert testSurvey;
    }

    @isTest
    static void testCreateSurveyQuestions() {
		//Get the Survey
		Survey__c survey = [SELECT Id from Survey__c LIMIT 1];
        //Pass the Survey Id and survey type as an Invocable parameter
        List<String> params = new List<String>();
        params.add(survey.Id + '|Non-Buy');

        Test.startTest();                
            SurveyAnswersController.createSurveyAnswers(params);
        Test.stopTest();
		
    	//Verify Questions were created
    	List<Survey_Answer__c> answers = SurveyAnswersDAO.getAllSurveyAnswersBySurveyId(survey.Id);
        System.assertNotEquals(0, answers.size(), 'Should have created survey answers');
    }  
    
    @isTest
    static void testGetSurveyQuestions() {
		//Get the Survey
		Survey__c survey = [SELECT Id from Survey__c LIMIT 1];
        //Pass the Survey Id and survey type as an Invocable parameter
        List<String> params = new List<String>();
        params.add(survey.Id + '|Non-Buy');

        Test.startTest();                
            SurveyAnswersController.createSurveyAnswers(params);
        Test.stopTest();
		
    	//Get Survey Questions
    	List<SurveyAnswersController.questionWrapper> wrapper = SurveyAnswersController.getSurveyQuestions(survey.Id);
        System.assertNotEquals(0, wrapper.size(), 'Should have retrieved the questions');
    }
    
    @isTest
    static void testSetAnswerPicklist() {  
		//Get the Survey
		Survey__c survey = [SELECT Id from Survey__c LIMIT 1];
        //Pass the Survey Id and survey type as an Invocable parameter
        List<String> params = new List<String>();
        params.add(survey.Id + '|Non-Buy');
        
        Test.startTest();
            SurveyAnswersController.createSurveyAnswers(params);
        	Survey_Answer__c q = [SELECT Id FROM Survey_Answer__c WHERE Survey__c = :survey.Id AND Type__c = 'Picklist' LIMIT 1];
        	SurveyAnswersController.setAnswer(q.Id, 'Phone');
        Test.stopTest();
		
    	//Verify Question was updated set to checked
    	Survey_Answer__c a = SurveyAnswersDAO.getSurveyAnswerById(q.Id);
        System.assertEquals('Phone', a.Answer__c, 'Should have set this Picklist');
    }
    
    @isTest
    static void testSetAnswerMultiPicklist() {  
		//Get the Survey
		Survey__c survey = [SELECT Id from Survey__c LIMIT 1];
        //Pass the Survey Id and survey type as an Invocable parameter
        List<String> params = new List<String>();
        params.add(survey.Id + '|Non-Buy');
        
        Test.startTest();
            SurveyAnswersController.createSurveyAnswers(params);
        	Survey_Answer__c q = [SELECT Id FROM Survey_Answer__c WHERE Survey__c = :survey.Id AND Type__c = 'Multi-Select Picklist' LIMIT 1];
        	SurveyAnswersController.setAnswer(q.Id, 'Other');
        Test.stopTest();
		
    	//Verify Question was updated set to checked
    	Survey_Answer__c a = SurveyAnswersDAO.getSurveyAnswerById(q.Id);
        System.assertEquals('Other', a.Answer__c, 'Should have set this Multi-Select Picklist');        
    }
      
}
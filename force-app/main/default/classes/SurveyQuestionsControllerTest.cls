@isTest
public class SurveyQuestionsControllerTest {

    @TestSetup
    private static void setup() {
        //Create the Call Center Manager/ISR
        User testCCS;
       	User testCC;
        System.runAs(new User(Id = UserInfo.getUserId())) {          	
        	Profile ccsProfile = [SELECT Id FROM Profile WHERE Name = 'Call Center Supervisor'];
        	Profile ccProfile = [SELECT Id FROM Profile WHERE Name = 'Call Center'];
        	UserRole isrRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'ISR'];        
        	testCCS = TestFactory.createUser(ccsProfile.Id, isrRole.Id, 'testccs1@gmail.com', null);
        	testCC = TestFactory.createUser(ccProfile.Id, isrRole.Id, 'testcc1@gmail.com', null);
        }
        //Create the Side by Side with 2 Call Surveys        
        Side_by_Side__c testSideBySide = new Side_by_Side__c(Status__c='In Process', Performed_By__c=testCCS.Id, ISR_CSR__c=testCC.Id);
        insert testSideBySide;
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        Call_Survey__c cs1 = new Call_Survey__c(Inbound_Outbound__c='Inbound Call', Account__c=testAccount.Id, Side_by_Side__c=testSideBySide.Id, Status__c='In Process');
        insert cs1;
        Call_Survey__c cs2 = new Call_Survey__c(Inbound_Outbound__c='Inbound Call', Account__c=testAccount.Id, Side_by_Side__c=testSideBySide.Id, Status__c='Complete');
        insert cs2;
    }

    @isTest
    static void testCreateSurveyQuestions() {
		//Get a Call Survey
		Call_Survey__c cs = [SELECT Id from Call_Survey__c LIMIT 1];
        //Pass the Call Survey Id as an Invocable parameter
        List<String> params = new List<String>();
        params.add(cs.Id);

        Test.startTest();                
            SurveyQuestionsController.createSurveyQuestions(params);
        Test.stopTest();
		
    	//Verify Questions were created
    	List<Call_Survey_Question__c> questions = SurveyQuestionsDAO.getSurveyQuestionsBySurveyId(cs.Id, 'Inbound Call');
        System.assertNotEquals(0, questions.size(), 'Should have created survey questions');
    }

    @isTest
    static void testGetSurveyComments() {  
       	//Get a Call Survey
		Call_Survey__c cs = [SELECT Id, Side_by_Side__c FROM Call_Survey__c WHERE Status__c = 'Complete' LIMIT 1];
        //Pass the Call Survey Id as an Invocable parameter
        List<String> params = new List<String>();
        params.add(cs.Id);
        
        Test.startTest();
        	SurveyQuestionsController.createSurveyQuestions(params);
        	List<Call_Survey_Question__c> questions = SurveyQuestionsDAO.getAllSurveyQuestionsByCallSurveyIdName(cs.Id, 'Inbound Call');
        	for (Call_Survey_Question__c q : questions) {                
    			q.Answer_Long__c = 'test';
	        }
        	update questions;        	
        Test.stopTest();
		
    	//Verify Questions were created and get the comments		
    	List<SurveyQuestionsController.wrapComments> comments = SurveyQuestionsController.getSurveyComments(cs.Side_by_Side__c);
        System.assertNotEquals(0, comments.size(), 'Should have retrieved the comments');
    }
    
    @isTest
    static void testGetSurveyQuestions() {
       	//Get a Call Survey
		Call_Survey__c cs = [SELECT Id, Side_by_Side__c FROM Call_Survey__c WHERE Status__c = 'In Process' LIMIT 1];
        //Pass the Call Survey Id as an Invocable parameter
        List<String> params = new List<String>();
        params.add(cs.Id);
        
        Test.startTest();
        	SurveyQuestionsController.createSurveyQuestions(params);
        Test.stopTest();
		
    	//Get Survey Questions for Inbound Call
    	SurveyQuestionsController.surveyWrapper wrapper = SurveyQuestionsController.getSurveyQuestions('Inbound Call', cs.Id);
        System.assertNotEquals(0, wrapper.questions.size(), 'Should have retrieved the questions');
        //Get Survey Questions for Supervisor Section which has a picklist
        wrapper = SurveyQuestionsController.getSurveyQuestions('Supervisor Section', cs.Id);
        System.assertNotEquals(0, wrapper.questions.size(), 'Should have retrieved the questions');
    }

    @isTest
    static void testTurnOffCategory() {  
       	//Get a Call Survey
		Call_Survey__c cs = [SELECT Id, Side_by_Side__c FROM Call_Survey__c WHERE Status__c = 'In Process' LIMIT 1];
        //Pass the Call Survey Id as an Invocable parameter
        List<String> params = new List<String>();
        params.add(cs.Id);
        
        Test.startTest();
        	SurveyQuestionsController.createSurveyQuestions(params);
        	Call_Survey_Question__c q = [SELECT Id FROM Call_Survey_Question__c LIMIT 1];
        	SurveyQuestionsController.turnOnOffCategory(q.Id, false);
        Test.stopTest();
		
    	//Verify Question was updated to Turned Off
    	Call_Survey_Question__c ques = SurveyQuestionsDAO.getSurveyQuestionById(q.Id);
        System.assertEquals(false, ques.Turned_On__c, 'Should have turned this question off');
    }
    
    @isTest
    static void testTurnOffSurvey() {  
       	//Get a Call Survey
		Call_Survey__c cs = [SELECT Id, Side_by_Side__c FROM Call_Survey__c WHERE Status__c = 'In Process' LIMIT 1];
        //Pass the Call Survey Id as an Invocable parameter
        List<String> params = new List<String>();
        params.add(cs.Id);
        
        Test.startTest();
        	SurveyQuestionsController.createSurveyQuestions(params);
        	Call_Survey_Question__c q = [SELECT Id FROM Call_Survey_Question__c WHERE Survey_Name__c = 'Inbound Call' AND Type__c = 'Checkbox' LIMIT 1];
        	SurveyQuestionsController.turnOnOffSurvey(cs.Id, 'Inbound Call', false);
        Test.stopTest();
		
    	//Verify Question was updated to Turned Off
    	Call_Survey_Question__c ques = SurveyQuestionsDAO.getSurveyQuestionById(q.Id);
        System.assertEquals(false, ques.Turned_On__c, 'Should have turned this question off');
    }
    
    @isTest
    static void testSetCheckboxAnswer() {  
       	//Get a Call Survey
		Call_Survey__c cs = [SELECT Id, Side_by_Side__c FROM Call_Survey__c WHERE Status__c = 'In Process' LIMIT 1];
        //Pass the Call Survey Id as an Invocable parameter
        List<String> params = new List<String>();
        params.add(cs.Id);
        
        Test.startTest();
        	SurveyQuestionsController.createSurveyQuestions(params);
        	Call_Survey_Question__c q = [SELECT Id FROM Call_Survey_Question__c WHERE Survey_Name__c = 'Inbound Call' AND Type__c = 'Checkbox' LIMIT 1];
        	SurveyQuestionsController.setCheckboxAnswer(q.Id, true);
        Test.stopTest();
		
    	//Verify Question was updated set to checked
    	Call_Survey_Question__c ques = SurveyQuestionsDAO.getSurveyQuestionById(q.Id);
        System.assertEquals('true', ques.Answer__c, 'Should have turned this checkbox on');
    }
    
	@isTest
    static void testSetAnswer() {  
       	//Get a Call Survey
		Call_Survey__c cs = [SELECT Id, Side_by_Side__c FROM Call_Survey__c WHERE Status__c = 'In Process' LIMIT 1];
        //Pass the Call Survey Id as an Invocable parameter
        List<String> params = new List<String>();
        params.add(cs.Id);
        
        Test.startTest();
        	SurveyQuestionsController.createSurveyQuestions(params);
        	Call_Survey_Question__c q = [SELECT Id FROM Call_Survey_Question__c WHERE Survey_Name__c = 'Supervisor Section' AND Type__c = 'Picklist' LIMIT 1];
        	SurveyQuestionsController.setAnswer(q.Id, 'Exceeds Expectations');
        Test.stopTest();
		
    	//Verify Question was updated with the correct answer
    	Call_Survey_Question__c ques = SurveyQuestionsDAO.getSurveyQuestionById(q.Id);
        System.assertEquals('Exceeds Expectations', ques.Answer__c, 'Should have set the answer correctly');
    }
    
    @isTest
    static void testSetAnswerLong() {  
       	//Get a Call Survey
		Call_Survey__c cs = [SELECT Id, Side_by_Side__c FROM Call_Survey__c WHERE Status__c = 'In Process' LIMIT 1];
        //Pass the Call Survey Id as an Invocable parameter
        List<String> params = new List<String>();
        params.add(cs.Id);
        
        Test.startTest();
        	SurveyQuestionsController.createSurveyQuestions(params);
        	Call_Survey_Question__c q = [SELECT Id FROM Call_Survey_Question__c WHERE Survey_Name__c = 'Inbound Call' AND Type__c = 'Text Area' LIMIT 1];
        	SurveyQuestionsController.setAnswerLong(q.Id, 'Test');
        Test.stopTest();
		
    	//Verify Question was updated with the correct answer
    	Call_Survey_Question__c ques = SurveyQuestionsDAO.getSurveyQuestionById(q.Id);
        System.assertEquals('Test', ques.Answer_Long__c, 'Should have set the answer correctly');
    }    
  
}
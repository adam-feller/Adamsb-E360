@isTest
public class CallSurveysControllerTest {

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
    static void testGetCallSurveysAsSupervisor() {
        Side_by_Side__c testSideBySide = [SELECT Id FROM Side_by_Side__c LIMIT 1];
        User supv = [SELECT Id FROM User WHERE Email = 'testccs1@gmail.com'];

        Test.startTest();
        List<CallSurveysController.SurveyWrapper> callSurveys;
        System.runas(supv) {
           	callSurveys = CallSurveysController.getCallSurveys(testSideBySide.Id);
        }
        Test.stopTest();
		//Supervisors can see all In Process and Complete Call Surveys
        System.assertEquals(2, callSurveys.size(), 'Should return 2 call surveys');
    }

    @isTest
    static void testGetCallSurveysCompletedAsISR() {
		Side_by_Side__c testSideBySide = [SELECT Id FROM Side_by_Side__c LIMIT 1];
		User isr = [SELECT Id FROM User WHERE Email = 'testcc1@gmail.com'];
        
        Test.startTest();
        List<CallSurveysController.SurveyWrapper> callSurveys;
        System.runas(isr) {
           	callSurveys = CallSurveysController.getCallSurveys(testSideBySide.Id);
        }
        Test.stopTest();

        //ISRs can only see Complete surveys
        System.assertEquals(1, callSurveys.size(), 'Should return 1 call survey');
    }

}
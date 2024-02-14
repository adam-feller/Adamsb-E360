@isTest
public class BatchDeleteObjectiveSubmissionsTest {

   	@TestSetup
	private static void setup() {
   		Account testAccount = TestFactory.createAccount('Test Account', '202', 'PVA', 'PDVA-CHANTILLY', null, '12346');
        Objective__c testObjective = new Objective__c();
        testObjective.Name = 'Test Objective';
        testObjective.BU__c = 'PVA';
        testObjective.Objective_Type__c = 'Display';
        Date startDate = Date.Today().addDays(-25);
        Date endDate = Date.Today().addDays(-10);
       	testObjective.Start_Date__c = startDate;
        testObjective.End_Date__c = endDate;
        insert testObjective;
        Objective_Account__c testObjectiveAccount = TestFactory.createObjectiveAccount(testObjective.Id, 'Incomplete', testAccount.Id);
       
       	List<Objective_Submission__c> objectiveSubmissionList = new List<Objective_Submission__c>();
       	for(Integer i = 0; i < 100; i++) {
       		Objective_Submission__c testObjectiveSubmission = new Objective_Submission__c();
        	testObjectiveSubmission.Objective_Account__c = testObjectiveAccount.Id;
        	testObjectiveSubmission.Status__c = 'Open';
        	objectiveSubmissionList.add(testObjectiveSubmission);
       	}
       
       	Objective__c jb = [SELECT Days_Remaining__c FROM Objective__c WHERE Id = :testObjective.Id];
       	insert objectiveSubmissionList;
    }
    
    @isTest
    static void testBatchDeleteObjectiveSubmissionsList(){
        List<Objective_Submission__c> objectiveSubmissionsReturned = [SELECT Id
			FROM Objective_Submission__c 
			WHERE Status__c = 'Open'
            AND Objective_Account__r.Objective__r.Days_Remaining__c < -4];
  
        System.assertEquals(100, objectiveSubmissionsReturned.size(), 'There should be 100 Objective Submission records returned');	
        
        Test.startTest();
        	BatchDeleteObjectiveSubmissions obj = new BatchDeleteObjectiveSubmissions();
			Database.executeBatch(obj);
        Test.stopTest();
        
        List<Objective_Submission__c> objectiveSubmissionsReturnedAfter = [SELECT Id
			FROM Objective_Submission__c 
			WHERE Status__c = 'Open'
            AND Objective_Account__r.Objective__r.Days_Remaining__c < -4];

        System.assertEquals(0, objectiveSubmissionsReturnedAfter.size(), 'There should be no Objective Submission records returned');	
    }

}
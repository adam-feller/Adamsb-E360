@isTest
public class ObjectiveSubmissionDAOTest {

    @TestSetup
    private static void setup(){
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '12345');
        Objective__c testObjective = TestFactory.createObjective('Test Objective', 'PVA', 'Display');
        Objective_Account__c testObjAcc = TestFactory.createObjectiveAccount(testObjective.Id, 'Incomplete', testAccount.Id);
        TestFactory.createObjectiveSubmission(testObjAcc.Id);
    }

    static Account getAccount(){
        return [SELECT Id, Name, VIP_Account_Number__c, Beer_Company__c, Warehouse__c
                FROM Account
                LIMIT 1];
    }

    static Objective_Submission__c getObjectiveSubmission(){
        return [SELECT Id, Status__c
                FROM Objective_Submission__c
                LIMIT 1];
    }

    static Objective_Account__c getObjectiveAccount(){
        return [SELECT Id, Name, Status__c
                FROM Objective_Account__c
                LIMIT 1];
    }

    @isTest
    static void testGetObjectiveSubmissions(){
        Objective_Account__c testObjectiveAccount = getObjectiveAccount();

        Test.startTest();
            List<Objective_Submission__c> objectiveSubmissionList = ObjectiveSubmissionDAO.getObjectiveSubmissions(new Set<Id>{testObjectiveAccount.Id});
        Test.stopTest();

        System.assertEquals(1, objectiveSubmissionList.size(), 'objectiveSubmissionList should return 1 record');
    }

    @isTest
    static void testUpdateObjectiveSubmissions(){
        Objective_Submission__c testObjectiveSubmission = getObjectiveSubmission();
        testObjectiveSubmission.Status__c = 'Open';

        Test.startTest();
            List<Objective_Submission__c> objectiveSubmissionList = ObjectiveSubmissionDAO.updateObjectiveSubmissions(new List<Objective_Submission__c>{testObjectiveSubmission});
        Test.stopTest();

        List<Objective_Submission__c> objectiveSubmissionsReturned = [SELECT Id, Status__c
                                                            FROM Objective_Submission__c
                                                            WHERE Id = :testObjectiveSubmission.Id];

        System.assertEquals(1, objectiveSubmissionsReturned.size(), '1 objective submission record should be returned');
        System.assertEquals('Open', objectiveSubmissionsReturned[0].Status__c, 'Objective submission record status should be open');
    }

}
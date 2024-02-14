@isTest
public class RejectObjectiveSubmissionTest {

    @TestSetup
    private static void setup(){       
        //Create Account Data
        Account testAccount = TestFactory.createAccount('Test Account', '20135', 'HDI', 'HDI Warehouse', null, '2345');
        update testAccount;
        
        //Create Objective Data
        Objective__c testObjective = new Objective__c();
        testObjective.Name = 'Test Display';
        testObjective.BU__c = 'HDI';
        testObjective.Objective_Type__c = 'Display';
        testObjective.Start_Date__c = System.Today() - 1;
        testObjective.End_Date__c = System.Today() + 1;
        testObjective.Goal__c = 100;
        testObjective.Picture_Required__c = true;
        insert testObjective;
        
        Objective_Account__c testObjectiveAccount = new Objective_Account__c();
        testObjectiveAccount.Objective__c = testObjective.Id;
        testObjectiveAccount.recordTypeId = Schema.getGlobalDescribe().get('Objective_Account__c').getDescribe().getRecordTypeInfosByName().get('Display').getRecordTypeId();
        testObjectiveAccount.Status__c = 'Incomplete';
        testObjectiveAccount.Account__c = testAccount.Id;
        testObjectiveAccount.Pictured_Required__c = true;
        insert testObjectiveAccount;

        Objective_Submission__c testObjectiveSubmission = new Objective_Submission__c();
        testObjectiveSubmission.Objective_Account__c = testObjectiveAccount.Id;
        insert testObjectiveSubmission;
        
        //Lock the Objective Display
        Approval.lock(testObjectiveSubmission);
    }

    //Test Method
    static testMethod void testRejectObjectiveSubmission() {
        Objective_Submission__c testObjectiveSubmission = [SELECT Id FROM Objective_Submission__c LIMIT 1];
        List <RejectObjectiveSubmission.FlowInput> inputList = new List <RejectObjectiveSubmission.FlowInput>();
        RejectObjectiveSubmission.FlowInput flowInput = new RejectObjectiveSubmission.FlowInput();
        flowInput.recordIdToReject = testObjectiveSubmission.Id;
        inputList.add(flowInput);

        Test.startTest();
        RejectObjectiveSubmission.callObjectiveRejectProcess(inputList);
        Test.stopTest();
        
        //Assert that the Objective Display was Rejected/Retracted
        Objective_Submission__c verifyObjectiveSubmission = [SELECT Id, Status__c, Retracted__c FROM Objective_Submission__c LIMIT 1];
        System.assertEquals('Rejected', verifyObjectiveSubmission.Status__c);
        System.assertEquals(true, verifyObjectiveSubmission.Retracted__c);
    }
}
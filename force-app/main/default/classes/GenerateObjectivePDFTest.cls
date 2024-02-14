@IsTest
public class GenerateObjectivePDFTest {
 
    static testMethod void testGenerateObjectivePDF() {
		Account testAccount = TestFactory.createAccount('Test Account', '20135', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        testAccount.SalesOrg__c = 'PVA';
        update testAccount;
        Objective__c testObjective = TestFactory.createObjective('Test Objective', 'PVA', 'Display');
        Objective_Location__C testObjectiveLocation = new Objective_Location__c();
        testObjectiveLocation.Objective__c = testObjective.Id;
        insert testObjectiveLocation;
        Objective_Account__c testObjectiveAccount = new Objective_Account__c();
        testObjectiveAccount.Objective__c = testObjective.Id;
        testObjectiveAccount.Status__c = 'Incomplete';
        testObjectiveAccount.Account__c = testAccount.Id;
        testObjectiveAccount.Objective_Location__c = testObjectiveLocation.Id;
        insert testObjectiveAccount;
        Objective_Submission__c testObjectiveSubmission = new Objective_Submission__c();
        testObjectiveSubmission.Status__c = 'Approved';
        testObjectiveSubmission.Objective_Account__c = testObjectiveAccount.Id;
        insert testObjectiveSubmission;      
        
        List <GenerateObjectivePDF.FlowInputs> inputList = new List <GenerateObjectivePDF.FlowInputs>();
        GenerateObjectivePDF.FlowInputs flowInput = new GenerateObjectivePDF.FlowInputs();

		//Pass inputs        
        flowInput.objectiveIds = String.valueOf(testObjective.Id);
        flowInput.locations = testAccount.VIP_Instance__c + ' / ' + testAccount.SalesOrg__c + ' / ' + testAccount.Warehouse__c;
        flowInput.startdate = String.valueOf(System.Today()-1);
        flowInput.enddate = String.valueOf(System.Today()+1);
        flowInput.salesReps = String.valueOf(userInfo.getUserId());
        inputList.add(flowInput);

        Test.startTest();
       		GenerateObjectivePDF.createPDF(inputList);
        Test.stopTest();
        
        //Assertion - make sure file exists
        List<ContentDocumentLink> cdlList = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =:testObjective.Id];
        System.assertEquals(1, cdlList.size());
    }

}
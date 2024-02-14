@isTest
private class ObjectiveSubmissionPDFControllerTest {

    static testMethod void ObjectiveSubmissionPDFControllerTestMethod(){
        Account testAccount = TestFactory.createAccount('Test Account', '20135', 'PVA', 'PDVA-CHANTILLY', null, '2345');
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
        
        Test.StartTest(); 
        	PageReference pageRef = Page.ObjectiveSubmissionPDF; 
        	pageRef.getParameters().put('id', String.valueOf(testObjective.Id));
        	Test.setCurrentPage(pageRef);
        	ObjectiveSubmissionPDFController testObjectiveSubmissionPDF1 = new ObjectiveSubmissionPDFController();

	        pageRef.getParameters().put('id', String.valueOf(testObjectiveLocation.Id));
	        Test.setCurrentPage(pageRef);
	        ObjectiveSubmissionPDFController testObjectiveSubmissionPDF2 = new ObjectiveSubmissionPDFController();                	
        Test.StopTest();
        
        //Assertions
        List<Objective_Submission__c> getApprovedObjectiveSubmissions =[SELECT ID FROM Objective_Submission__c WHERE Objective_Account__c = :testObjectiveAccount.Id ];
        System.assertEquals(1, getApprovedObjectiveSubmissions.size(), '1 record should be returned');
    }

}
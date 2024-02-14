@isTest
private class ObjectivePDFControllerTest {

    static testMethod void ObjectivePDFControllerTestMethod(){
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
        
        Test.StartTest(); 
        	PageReference pageRef = Page.ObjectivePDF; 
        	pageRef.getParameters().put('ids', String.valueOf(testObjective.Id));
        	pageRef.getParameters().put('locations', testAccount.VIP_Instance__c + ' / ' + testAccount.SalesOrg__c + ' / ' + testAccount.Warehouse__c);
        	pageRef.getParameters().put('startdate', String.valueOf(System.Today()-1));
        	pageRef.getParameters().put('enddate', String.valueOf(System.Today()+1));
        	pageRef.getParameters().put('salesReps', String.valueOf(userInfo.getUserId()));
        	Test.setCurrentPage(pageRef);
        	ObjectivePDFController controller = new ObjectivePDFController();
        Test.StopTest();
        
        //Assertions
        List<Objective_Submission__c> getApprovedObjectiveSubmissions = [SELECT ID FROM Objective_Submission__c WHERE Objective_Account__c = :testObjectiveAccount.Id ];
        System.assertEquals(1, getApprovedObjectiveSubmissions.size(), '1 record should be returned');
    }

}
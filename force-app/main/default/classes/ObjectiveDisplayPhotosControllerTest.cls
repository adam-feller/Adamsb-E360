@IsTest
private class ObjectiveDisplayPhotosControllerTest {

    static testMethod void ObjectiveDisplayPhotosControllerTestMethod(){
        Account testAccount = TestFactory.createAccount('Test Account', '20135', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        Objective__c testObjective = TestFactory.createObjective('Test Objective', 'PVA', 'Display');
        Objective_Account__c testObjectiveAccount = new Objective_Account__c();
        testObjectiveAccount.Objective__c = testObjective.Id;
        testObjectiveAccount.Status__c = 'Incomplete';
        testObjectiveAccount.Account__c = testAccount.Id;
        insert testObjectiveAccount;
        Objective_Submission__c testObjectiveDisplay = new Objective_Submission__c();
        testObjectiveDisplay.Status__c = 'Submitted for Approval';
        testObjectiveDisplay.Objective_Account__c = testObjectiveAccount.Id;
        insert testObjectiveDisplay;
        
        Test.StartTest();     
        PageReference pageRef = Page.ObjectiveDisplayPhotos; 
        pageRef.getParameters().put('id', testObjectiveDisplay.Id);
        Test.setCurrentPage(pageRef);
        ObjectiveDisplayPhotosController testObjectiveDisplayCtrlr = new ObjectiveDisplayPhotosController();
        Objective_Submission__c objectiveDisplay = testObjectiveDisplayCtrlr.objDisplay;
        Test.StopTest();
        
        //Assertion - verify Objective Display found in controller matches what was passed in the url parameter
        System.assertEquals(testObjectiveDisplay.Id, objectiveDisplay.Id, 'Ids should match');
    }

}
@isTest
private class ObjectiveCloneTest {

    @TestSetup
    private static void setup() {
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        UserRole preSalesRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Admin'];
        UserRole salesManagerRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Admin'];
        User testSalesManager = TestFactory.createUser(systemAdminProfile.Id, salesManagerRole.Id, 'newtest3User@gmail.com', null);
        TestFactory.createUser(systemAdminProfile.Id, preSalesRole.Id, 'newtest2User@gmail.com', testSalesManager.Id);

        System.runAs(testSalesManager) {
            Account testAccount = TestFactory.createAccount('Test Parent Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '12345');
            Account testAccount2 = TestFactory.createAccount('Test Account', '202', 'PVA', 'PDVA-CHANTILLY', testAccount.Id, '12346');
            Objective__c testObjective = TestFactory.createObjective('Test Objective', 'PVA', 'Display');
            Product2 testProd = TestFactory.createProduct('Test Product', '12345', 'MillerCoors', '123*B');
            TestFactory.createObjectiveLocation(testObjective.Id, 'PVA', 'PDVA-CHANTILLY', 100);
            TestFactory.createObjectiveAccount(testObjective.Id, 'Incomplete', testAccount.Id);
            TestFactory.createObjectiveProduct(testObjective.Id, testProd.Id);
            testAccount.SalesOrg__c = 'PVA';
            update testAccount;
            testAccount2.SalesOrg__c = 'PVA';
            update testAccount2;
        }
    }

    static Objective__c getObjective() {
        return [SELECT Id, Name, RecordTypeId
                FROM Objective__c
                LIMIT 1];
    }

    static Objective_Location__c getObjectiveLocation() {
        return [SELECT Id, Objective__c
                FROM Objective_Location__c
                LIMIT 1];
    }

    @isTest
    static void testGetObjectiveRecord() {
        Objective__c testObj = getObjective();

        Test.startTest();
            Objective__c objectiveObj = ObjectiveClone.getObjectiveRecord(testObj.Id);
        Test.stopTest();

        System.assertNotEquals(null, objectiveObj, '1 objective record should be returned');
    }
    

    @isTest
    static void testCreateObjectives() {
        Objective__c testObj = getObjective();

        Test.startTest();
            ObjectiveClone.createObjectives(testObj, 'test Name', System.today(), System.today() + 7);
        Test.stopTest();

        List<Objective__c> objectives = [SELECT Id FROM Objective__c];
        System.assertEquals(2, objectives.size(), '2 objective records should be returned');
    }

 	@isTest
    static void testGetBatchJobStatus() {
        Objective__c testObj = getObjective();
		ObjectiveClone.ObjectiveErrorResponse objError = ObjectiveClone.createObjectives(testObj, 'test Name', System.today(), System.today() + 7);
        
        Test.startTest();
            AsyncApexJob jobInfo = ObjectiveClone.getBatchJobStatus(objError.batchId);
        Test.stopTest();

        System.assertNotEquals(null, jobInfo, 'Should be job information returned');
    }
}
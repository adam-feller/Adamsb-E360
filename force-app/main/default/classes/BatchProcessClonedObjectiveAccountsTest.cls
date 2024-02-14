@isTest
private class BatchProcessClonedObjectiveAccountsTest {

    @TestSetup
    private static void setup() {
        Account testAccount = TestFactory.createAccount('Test Account', '202', 'PVA', 'PDVA-CHANTILLY', null, '12346');
        Objective__c testObjective = TestFactory.createObjective('Test Objective', 'PVA', 'Display');
        TestFactory.createObjectiveAccount(testObjective.Id, 'Incomplete', testAccount.Id);
    }

    static Objective__c getObjective() {
        return [SELECT Id FROM Objective__c LIMIT 1];
    }

    @isTest
    static void testBatchProcessClonedObjectiveAccounts() {
        Objective__c testObjective = getObjective();
        Objective__c testObjective2 = TestFactory.createObjective('Test Objective', 'PVA', 'Display');

        Test.startTest();
            BatchProcessClonedObjectiveAccounts batchProcessClonedObjAcc = new BatchProcessClonedObjectiveAccounts();
            batchProcessClonedObjAcc.query = 'SELECT Id, Objective__c, Account__r.OwnerId, Account__c, Account__r.Name, Status__c, Manual_Upload__c ' +
                                             'FROM Objective_Account__c WHERE Objective__c = :clonedObjectiveId';
            batchProcessClonedObjAcc.newObjectiveId = testObjective2.Id;
            batchProcessClonedObjAcc.clonedObjectiveId = testObjective.Id;
            Id batchProcessId = Database.executeBatch(batchProcessClonedObjAcc);
        Test.stopTest();

        List<Objective_Account__c> objectiveAccounts = [SELECT Id FROM Objective_Account__c WHERE Objective__c = :testObjective2.Id];

        System.assertEquals(1, objectiveAccounts.size(), '1 Objective account should be created');
    }
}
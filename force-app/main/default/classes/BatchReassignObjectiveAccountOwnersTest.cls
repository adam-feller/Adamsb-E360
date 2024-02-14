@isTest
private class BatchReassignObjectiveAccountOwnersTest {

    @TestSetup
    private static void setup(){
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '12345');
        Objective__c testObjective = TestFactory.createObjective('Test Objective', 'PVA', 'Display');
        TestFactory.createObjectiveAccount(testObjective.Id, 'Incomplete', testAccount.Id);
    }

    static Objective_Account__c getObjectiveAccount(){
        return [SELECT Id, Name, OwnerId
                FROM Objective_Account__c
                LIMIT 1];
    }

    @isTest
    static void testBatchReassignObjectiveAccountOwners(){
        Objective_Account__c testObjAcc = getObjectiveAccount();

        Test.startTest();
            BatchReassignObjectiveAccountOwners batchReassignObjectiveAcc = new BatchReassignObjectiveAccountOwners();
            batchReassignObjectiveAcc.objectiveAccountsToUpdate = new List<Objective_Account__c>{testObjAcc};
            Database.executeBatch(batchReassignObjectiveAcc);
        Test.stopTest();

        List<Objective_Account__c> objectiveAccountReturned = [SELECT Id, OwnerId FROM Objective_Account__c];

        System.assertEquals(objectiveAccountReturned[0].OwnerId, UserInfo.getUserId(), 'The user ids should match');
    }
}
@isTest
private class BatchDeleteObjectiveAccountsTest {

    @TestSetup
    private static void setup(){
        Account testAccount = TestFactory.createAccount('Test Account', '202', 'PVA', 'PDVA-CHANTILLY', null, '12346');
        Objective__c testObjective = TestFactory.createObjective('Test Objective', 'PVA', 'Display');
        TestFactory.createObjectiveAccount(testObjective.Id, 'Incomplete', testAccount.Id);
    }

    static Objective__c getObjective(){
        return [SELECT Id
                FROM Objective__c
                LIMIT 1];
    }

    static Account getAccount(){
        return [SELECT Id
                FROM Account
                LIMIT 1];
    }

    @isTest
    static void testBatchProcessObjectiveLocationsDeleted(){
        Objective__c testObjective = getObjective();
        Account testAccount = getAccount();

        Test.startTest();
            BatchDeleteObjectiveAccounts batchDeleteObjAccRecords = new BatchDeleteObjectiveAccounts();
            batchDeleteObjAccRecords.query = 'SELECT Id, Objective__c, Account__r.OwnerId, Account__c, Account__r.Name, Status__c, Manual_Account_Upload__c, Completed_Count__c, Objective_Type__c' +
                                            ' FROM Objective_Account__c' +
                                            ' WHERE Objective__c = :objectiveId'; 
            batchDeleteObjAccRecords.objectiveId = testObjective.Id;
            batchDeleteObjAccRecords.selectedAccountIds = new Set<Id>();
            Id batchProcessId = Database.executeBatch(batchDeleteObjAccRecords);
        Test.stopTest();

        List<Objective_Account__c> objectiveAccounts = [SELECT Id FROM Objective_Account__c];

        System.assertEquals(objectiveAccounts.size(), 0, 'Objective account should be deleted');
    }

    @isTest
    static void testBatchProcessObjectiveLocationsFound(){
        Objective__c testObjective = getObjective();
        Account testAccount = getAccount();

        Test.startTest();
            BatchDeleteObjectiveAccounts batchDeleteObjAccRecords = new BatchDeleteObjectiveAccounts();
            batchDeleteObjAccRecords.query = 'SELECT Id, Objective__c, Account__r.OwnerId, Account__c, Account__r.Name, Status__c, Manual_Account_Upload__c, Completed_Count__c, Objective_Type__c' +
                                            ' FROM Objective_Account__c' +
                                            ' WHERE Objective__c = :objectiveId';
            batchDeleteObjAccRecords.objectiveId = testObjective.Id;
            batchDeleteObjAccRecords.selectedAccountIds = new Set<Id>{testAccount.Id};
            Id batchProcessId = Database.executeBatch(batchDeleteObjAccRecords);
        Test.stopTest();

        List<Objective_Account__c> objectiveAccounts = [SELECT Id FROM Objective_Account__c];

        System.assertEquals(objectiveAccounts.size(), 1, '1 objective account should be found and not deleted');
    }
}
@isTest
private class ObjectiveAccountDAOTest {

    @TestSetup
    private static void setup(){
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '12345');
        Objective__c testObjective = TestFactory.createObjective('Test Objective', 'PVA', 'Display');
        Id deletedRecordTypeId = Schema.SObjectType.Objective_Account__c.getRecordTypeInfosByName().get('Deleted').getRecordTypeId();
        TestFactory.createObjectiveAccountRecordTypeId(testObjective.Id, 'Incomplete', null, deletedRecordTypeId);
        TestFactory.createObjectiveAccount(testObjective.Id, 'Incomplete', testAccount.Id);
    }

    static Account getAccount(){
        return [SELECT Id, Name, VIP_Account_Number__c, Beer_Company__c, Warehouse__c
                FROM Account
                LIMIT 1];
    }

    static Objective__c getObjective(){
        return [SELECT Id, Name
                FROM Objective__c
                LIMIT 1];
    }

    static Objective_Account__c getObjectiveAccount(){
        return [SELECT Id, Name, Status__c
                FROM Objective_Account__c
                LIMIT 1];
    }

    @isTest
    static void testGetObjectiveAccountsByAccountId(){
        Account testAccount = getAccount();

        Test.startTest();
            List<Objective_Account__c> objectiveAccountList = ObjectiveAccountDAO.getObjectiveAccountsByAccountId(new Set<Id>{testAccount.Id});
        Test.stopTest();

        System.assertEquals(objectiveAccountList.size(), 1, 'objectiveAccountList should return 1 record');
    }
    
     @isTest
    static void getObjectiveAccountsByAccountIdCBS(){
        Account testAccount = getAccount();

        Test.startTest();
        List<Objective_Account__c> objectiveAccountList = ObjectiveAccountDAO.getObjectiveAccountsByAccountIdCBS(new Set<Id>{testAccount.Id}, new List<String>{'1'});
        Test.stopTest();

        System.assertEquals(objectiveAccountList.size(), 0, 'objectiveAccountList should return 0 record');
    }

    @isTest
    static void testGetObjectiveAccountsByAccountAndStatusToday(){
        Account testAccount = getAccount();

        Test.startTest();
            List<Objective_Account__c> objectiveAccountList = ObjectiveAccountDAO.getObjectiveAccountsByAccountAndStatusToday(new Set<Id>{testAccount.Id}, 'Incomplete');
        Test.stopTest();

        System.assertEquals(objectiveAccountList.size(), 1, 'objectiveAccountList should return 1 record');
    }

    @isTest
    static void testGetObjectiveAccountsByObjective(){
        Objective__c testObj = getObjective();

        Test.startTest();
            List<Objective_Account__c> objectiveAccountList = ObjectiveAccountDAO.getObjectiveAccountsByObjective(new Set<Id>{testObj.Id});
        Test.stopTest();

        System.assertEquals(objectiveAccountList.size(), 1, 'objectiveAccountList should return 1 record');
    }

    @isTest
    static void testGetObjectiveAccountsByObjectiveNotRejected(){
        Objective__c testObj = getObjective();

        Test.startTest();
            List<Objective_Account__c> objectiveAccountList = ObjectiveAccountDAO.getObjectiveAccountsByObjectiveNotRejected(new Set<Id>{testObj.Id});
        Test.stopTest();

        System.assertEquals(objectiveAccountList.size(), 1, 'objectiveAccountList should return 1 record');
    }

    @isTest
    static void testGetObjectiveAccountsByAccountAndObjective(){
        Objective__c testObj = getObjective();
        Account testAccount = getAccount();

        Test.startTest();
            List<Objective_Account__c> objectiveAccountList = ObjectiveAccountDAO.getObjectiveAccountsByAccountAndObjective(new Set<Id>{testAccount.Id}, testObj.Id);
        Test.stopTest();

        System.assertEquals(objectiveAccountList.size(), 1, 'objectiveAccountList should return 1 record');
    }

    @isTest
    static void testGetObjectiveAccountsByObjectiveAndRecordType(){
        Objective__c testObj = getObjective();
        Id deletedRecordTypeId = Schema.SObjectType.Objective_Account__c.getRecordTypeInfosByName().get('Deleted').getRecordTypeId();

        Test.startTest();
            List<Objective_Account__c> objectiveAccountList = ObjectiveAccountDAO.getObjectiveAccountsByObjectiveAndRecordType(new Set<Id>{testObj.Id}, deletedRecordTypeId);
        Test.stopTest();

        System.assertEquals(objectiveAccountList.size(), 1, 'objectiveAccountList should return 1 record');
    }

    @isTest
    static void testInsertObjectiveAccounts(){
        Objective__c testObjective = getObjective();
        Account testAccount = getAccount();

        Objective_Account__c testObjectiveAccount = new Objective_Account__c();
        testObjectiveAccount.Objective__c = testObjective.Id;
        testObjectiveAccount.Account__c = testAccount.Id;

        Test.startTest();
            List<Objective_Account__c> objectiveAccountList = ObjectiveAccountDAO.insertObjectiveAccounts(new List<Objective_Account__c>{testObjectiveAccount});
        Test.stopTest();

        List<Objective_Account__c> objectiveAccountsReturned = [SELECT Id
                                                            FROM Objective_Account__c
                                                            WHERE Id = :objectiveAccountList[0].Id];

        System.assertEquals(objectiveAccountsReturned.size(), 1, '1 objective account records should be returned');
    }

    @isTest
    static void testUpdateObjectiveAccounts(){
        Objective_Account__c testObjectiveAccount = getObjectiveAccount();
        testObjectiveAccount.Status__c = 'Rejected';

        Test.startTest();
            List<Objective_Account__c> objectiveAccountList = ObjectiveAccountDAO.updateObjectiveAccounts(new List<Objective_Account__c>{testObjectiveAccount});
        Test.stopTest();

        List<Objective_Account__c> objectiveAccountsReturned = [SELECT Id, Status__c
                                                            FROM Objective_Account__c
                                                            WHERE Id = :testObjectiveAccount.Id];

        System.assertEquals(objectiveAccountsReturned.size(), 1, '1 objective account record should be returned');
        System.assertEquals(objectiveAccountsReturned[0].Status__c, 'Rejected', 'Objective account record status should be rejected');
    }

    @isTest
    static void testDeleteObjectiveAccounts(){
        Objective_Account__c testObjectiveAccount = getObjectiveAccount();
        testObjectiveAccount.Status__c = 'Rejected';

        Test.startTest();
            List<Objective_Account__c> objectiveAccountList = ObjectiveAccountDAO.deleteObjectiveAccounts(new List<Objective_Account__c>{testObjectiveAccount});
        Test.stopTest();

        List<Objective_Account__c> objectiveAccountsReturned = [SELECT Id, Status__c 
                                                            FROM Objective_Account__c 
                                                            WHERE Id = :testObjectiveAccount.Id];

        System.assertEquals(objectiveAccountsReturned.size(), 0, '0 objective account records should be returned');
    }
}
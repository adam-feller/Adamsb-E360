@isTest
private class BatchUpdateObjectiveAccWithGoalTest {

    @TestSetup
    private static void setup(){
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        UserRole salesManagerRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Admin'];
        User testSalesManager = TestFactory.createUser(systemAdminProfile.Id, salesManagerRole.Id, 'newtest3User@gmail.com', null);

        System.runAs(testSalesManager){
            Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '12345');
            Objective__c testObjective = TestFactory.createObjective('Test Objective', 'PVA', 'Distribution');
            Objective_Location__c testObjLoc = TestFactory.createObjectiveLocation(testObjective.Id, 'PVA', 'PDVA-CHANTILLY', 100);
            TestFactory.createObjectiveAccount(testObjective.Id, 'Incomplete', testAccount.Id);
            TestFactory.createObjectiveGoal(testObjective.Id, testSalesManager.Id, testObjLoc.Id, 50);
        }
    }

    static Objective__c getObjective(){
        return [SELECT Id, Name
                FROM Objective__c
                LIMIT 1];
    }

    static Objective_Goal__c getObjectiveGoal(){
        return [SELECT Id
                FROM Objective_Goal__c
                LIMIT 1];
    }

    static User getUserbyUsername(String username){
        return [SELECT Id, Name, UserRoleId, Goal_Amount__c
                FROM User
                WHERE Username = :username
                LIMIT 1];
    }

    @isTest
    static void testBatchUpdateObjectiveAccWithGoalTest(){
        User testUser = getUserbyUsername('newtest3User@gmail.com');
        Objective_Goal__c testObjGoal = getObjectiveGoal();
        Objective__c testObj = getObjective();
        testObj.Status__c = 'Ready For Execution';
        testObj.Processed__c = false;
        update testObj;

        Test.startTest();
            BatchUpdateObjectiveAccWithGoal batchObjAccUpdateGoal = new BatchUpdateObjectiveAccWithGoal();
            batchObjAccUpdateGoal.query = 'SELECT Id, Objective__c, Account__c, Account__r.OwnerId' +
                                        ' FROM Objective_Account__c' + 
                                        ' WHERE Objective__c IN :objectiveIds';
            batchObjAccUpdateGoal.objGoalUserMap = new Map<Id, Map<Id, Id>>{testObj.Id => new Map<Id, Id>{testUser.Id => testObjGoal.Id}};
            batchObjAccUpdateGoal.objectiveIds = new Set<Id>{testObj.Id};
            Database.executeBatch(batchObjAccUpdateGoal);
        Test.stopTest();

        List<Objective__c> objectivesReturned = [SELECT Id, Processed__c FROM Objective__c];
        List<Objective_Account__c> objectiveAccountsReturned = [SELECT Id, Objective_Goal__c FROM Objective_Account__c];

        System.assertEquals(objectivesReturned.size(), 1, '1 objective should be returned');
        System.assertEquals(objectivesReturned[0].Processed__c, true, 'Processed field should be true');
        System.assertEquals(objectiveAccountsReturned.size(), 1, '1 objective account should be returned');
        System.assertEquals(objectiveAccountsReturned[0].Objective_Goal__c, testObjGoal.Id, 'Lookup field should be match objective goal id');
    }
}
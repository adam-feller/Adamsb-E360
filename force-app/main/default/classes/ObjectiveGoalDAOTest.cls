@isTest
private class ObjectiveGoalDAOTest {

    @TestSetup
    private static void setup(){
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        UserRole salesManagerRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Admin'];
        User testSalesManager = TestFactory.createUser(systemAdminProfile.Id, salesManagerRole.Id, 'newtest3User@gmail.com', null);

        System.runAs(testSalesManager){
            Objective__c testObjective = TestFactory.createObjective('Test Objective', 'PVA', 'Distribution');
            Objective_Location__c testObjLoc = TestFactory.createObjectiveLocation(testObjective.Id, 'PVA', 'PDVA-CHANTILLY', 100);
            TestFactory.createObjectiveGoal(testObjective.Id, testSalesManager.Id, testObjLoc.Id, 50);
        }
    }

    static Objective__c getObjective(){
        return [SELECT Id, Name
                FROM Objective__c
                LIMIT 1];
    }

    static Objective_Goal__c getObjectiveGoal(){
        return [SELECT Id, Name, Goal_Amount__c
                FROM Objective_Goal__c
                LIMIT 1];
    }

    static Objective_Location__c getObjectiveLocation(){
        return [SELECT Id
                FROM Objective_Location__c
                LIMIT 1];
    }

    @isTest
    static void testGetObjectiveGoalsByObjectiveIds(){
        Objective__c testObjective = getObjective();

        Test.startTest();
            List<Objective_Goal__c> objectiveGoalList = ObjectiveGoalDAO.getObjectiveGoalsByObjectiveIds(new Set<Id>{testObjective.Id});
        Test.stopTest();

        System.assertEquals(objectiveGoalList.size(), 1, 'objectiveGoalList should return 1 record');
    }

    @isTest
    static void testInsertObjectiveGoals(){
        Objective__c testObjective = getObjective();
        Objective_Location__c testObjectiveLocation = getObjectiveLocation();

        Objective_Goal__c testObjectiveGoal = new Objective_Goal__c();
        testObjectiveGoal.Objective__c = testObjective.Id;
        testObjectiveGoal.Goal_Assignee__c = UserInfo.getUserId();
        testObjectiveGoal.Objective_Location__c = testObjectiveLocation.Id;

        Test.startTest();
            List<Objective_Goal__c> objectiveGoalList = ObjectiveGoalDAO.insertObjectiveGoals(new List<Objective_Goal__c>{testObjectiveGoal});
        Test.stopTest();

        List<Objective_Goal__c> objectiveGoalsReturned = [SELECT Id
                                                        FROM Objective_Goal__c];

        System.assertEquals(objectiveGoalsReturned.size(), 2, '2 objective goal records should be returned');
    }

    @isTest
    static void testUpdateObjectiveGoals(){
        Objective_Goal__c testObjectiveGoal = getObjectiveGoal();
        testObjectiveGoal.Goal_Amount__c = 100;

        Test.startTest();
            List<Objective_Goal__c> objectiveGoalList = ObjectiveGoalDAO.updateObjectiveGoals(new List<Objective_Goal__c>{testObjectiveGoal});
        Test.stopTest();

        List<Objective_Goal__c> objectiveGoalsReturned = [SELECT Id, Goal_Amount__c
                                                        FROM Objective_Goal__c
                                                        WHERE Id = :testObjectiveGoal.Id];

        System.assertEquals(objectiveGoalsReturned.size(), 1, '1 objective goal record should be returned');
        System.assertEquals(objectiveGoalsReturned[0].Goal_Amount__c, 100, 'Goal amount should be 100');
    }
}
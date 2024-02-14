@isTest
private class ObjectiveAccountTriggerHandlerTest {
    
    @TestSetup
    private static void setup() {
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        UserRole preSalesRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Admin'];
        UserRole salesManagerRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Admin'];
        User testSalesManager = TestFactory.createUser(systemAdminProfile.Id, salesManagerRole.Id, 'newtest3User@gmail.com', null);
        TestFactory.createUser(systemAdminProfile.Id, preSalesRole.Id, 'newtest2User@gmail.com', testSalesManager.Id);

        System.runAs(testSalesManager){
            Account testAccount = TestFactory.createAccount('Test Parent Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '12345');
            Account testAccount2 = TestFactory.createAccount('Test Account', '202', 'PVA', 'PDVA-CHANTILLY', testAccount.Id, '12346');
            Objective__c testObjective = TestFactory.createObjective('Test Objective', 'PVA', 'Display');
            Product2 testProd = TestFactory.createProduct('Test Product', '12345', 'MillerCoors', '123*B');
            Objective_Location__c testObjLoc = TestFactory.createObjectiveLocation(testObjective.Id, 'PVA', 'PDVA-CHANTILLY', 100);
            TestFactory.createObjectiveAccount(testObjective.Id, 'Incomplete', testAccount2.Id);
            TestFactory.createObjectiveProduct(testObjective.Id, testProd.Id);
            TestFactory.createObjectiveGoal(testObjective.Id, testSalesManager.Id, testObjLoc.Id, 50);
        }
    }
	
    static Objective__c getObjective(){
        return [SELECT Id, Name, Picture_Required__c, Start_Date__c, End_Date__c, Objective_Type__c
                FROM Objective__c
                LIMIT 1];
    }

    static Objective_Location__c getObjectiveLocation(){
        return [SELECT Id, Objective__c
                FROM Objective_Location__c
                LIMIT 1];
    }

    static Objective_Account__c getObjectiveAccount(){
        return [SELECT Id, Objective__c, Status__c, Account_Owner__c
                FROM Objective_Account__c
                LIMIT 1];
    }

    static Objective_Product__c getObjectiveProduct(){
        return [SELECT Id, Objective__c, Product__c
                FROM Objective_Product__c
                LIMIT 1];
    }

    static Account getAccount(String Name){
        return [SELECT Id, Name, VIP_Account_Number__c, Beer_Company__c, Warehouse__c
                FROM Account
                WHERE Name = :name
                LIMIT 1];
    }

    @isTest
    static void testUpdateObjectiveGoalObtainment(){
        Objective_Account__c oldObjectiveAccount = getObjectiveAccount();
        Objective_Account__c testObjectiveAccount = getObjectiveAccount();
        testObjectiveAccount.Status__c = 'Complete';

        Test.startTest();
            ObjectiveAccountTriggerHandler.afterUpdateHandler(new List<Objective_Account__c>{testObjectiveAccount}, new Map<Id, Objective_Account__c>{oldObjectiveAccount.Id => oldObjectiveAccount});
        Test.stopTest();

        List<Objective_Goal__c> objGoalList = [SELECT Id, Team_Member_Actual__c FROM Objective_Goal__c];

        System.assertEquals(1, objGoalList.size(), '1 objective goal record should be returned');
        System.assertEquals(1, objGoalList[0].Team_Member_Actual__c, 'Team member actual goal should be 1');
    }

    @isTest
    static void testUpdateObjectiveGoalObtainmentRejected(){
        Objective_Account__c oldObjectiveAccount = getObjectiveAccount();
        Objective_Account__c testObjectiveAccount = getObjectiveAccount();
        testObjectiveAccount.Status__c = 'Rejected';

        Test.startTest();
            ObjectiveAccountTriggerHandler.afterUpdateHandler(new List<Objective_Account__c>{testObjectiveAccount}, new Map<Id, Objective_Account__c>{oldObjectiveAccount.Id => oldObjectiveAccount});
        Test.stopTest();

        List<Objective_Goal__c> objGoalList = [SELECT Id, Team_Member_Actual__c FROM Objective_Goal__c];

        System.assertEquals(1, objGoalList.size(), '1 objective goal record should be returned');
        System.assertEquals(-1, objGoalList[0].Team_Member_Actual__c, 'Team member actual goal should be -1');
    }

    @isTest
    static void testUpdateObjectiveGoalObtainmentVolume(){
        Objective__c testObj = getObjective();
        testObj.Objective_Type__c = 'Volume';
        update testObj;
        Objective_Account__c oldObjectiveAccount = getObjectiveAccount();
        Objective_Account__c testObjectiveAccount = getObjectiveAccount();
        testObjectiveAccount.Status__c = 'Complete';

        Test.startTest();
            ObjectiveAccountTriggerHandler.afterUpdateHandler(new List<Objective_Account__c>{testObjectiveAccount}, new Map<Id, Objective_Account__c>{oldObjectiveAccount.Id => oldObjectiveAccount});
        Test.stopTest();

        List<Objective_Goal__c> objGoalList = [SELECT Id, Team_Member_Actual__c FROM Objective_Goal__c];

        System.assertEquals(1, objGoalList.size(), '1 objective goal record should be returned');
        System.assertEquals(1, objGoalList[0].Team_Member_Actual__c, 'Team member actual goal should be 1');
    }
}
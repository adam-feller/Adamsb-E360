@isTest
private class ScheduleBatchUpdateObjAccWithGoalTest {

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

    public static String CRON_EXP = '0 0 0 15 3 ? 2099';

    @isTest
    static void testScheduleBatchUpdateObjAccWithGoalTest(){
        Objective__c testObj = getObjective();
        testObj.Status__c = 'Ready For Execution';
        testObj.Processed__c = false;
        update testObj;

        Test.startTest();
            String jobId = System.schedule('ScheduleApexClassTest',
                                           CRON_EXP, 
                                           new ScheduleBatchUpdateObjAccWithGoal());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                              FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(CRON_EXP, 
                                ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);
            System.assertEquals('2099-03-15 00:00:00', 
                                String.valueOf(ct.NextFireTime));
        Test.stopTest();
    }
}
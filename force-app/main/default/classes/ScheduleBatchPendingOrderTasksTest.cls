@isTest
public with sharing class ScheduleBatchPendingOrderTasksTest {
    
    public static String CRON_EXP = '0 0 0 15 3 ? 2099';

    @TestSetup
    static void setup(){
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        UserRole preSalesRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Admin'];
        UserRole adminUserRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Admin'];
    
        User testSalesManager = TestFactory.createUser(systemAdminProfile.Id, adminUserRole.Id, 'newtest3User@gmail.com', null);
        
        System.runAs(testSalesManager){
            Warehouse__c testWarehouse = TestFactory.createWarehouse('CBS - SWB', UserInfo.getUserId(), 'CBS', null, null, null, null, null);
            Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'CBS - SWB', null, '2345');
            Pricebook2 testStandardPricebook = TestFactory.createStandardPriceBook();
            Order testOrder = TestFactory.createOrder(testAccount.Id, testStandardPricebook.Id, System.today(),'Pending Draft');
        }  
    }
    

    @isTest
    static void testScheduleBatchPendingOrderTasks(){
        Test.startTest();
            String jobId = System.schedule('ScheduleApexClassTest',
                                           CRON_EXP, 
                                           new ScheduleBatchPendingOrderTasks());
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
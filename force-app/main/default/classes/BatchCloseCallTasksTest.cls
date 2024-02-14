@isTest
public with sharing class BatchCloseCallTasksTest {
    @TestSetup
    private static void setup(){

        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        UserRole preSalesRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Admin'];
        UserRole salesManagerRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Admin'];
        User testSalesManager = TestFactory.createUser(systemAdminProfile.Id, salesManagerRole.Id, 'newtest3User@gmail.com', null);

        System.runAs(testSalesManager){
            Warehouse__c testWarehouse = TestFactory.createWarehouse('CBS - SWB', testSalesManager.Id, 'CBS', null, null, null, null, null);
            testWarehouse.Default_Outbound_Call_Queue__c = 'CBS_SWB_Outbound_Call_Queue';
            update testWarehouse;

            Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'CBS - SWB', null, '2345');
            Account testAccountSpanish = TestFactory.createAccount('Test Account Spanish', '301', 'PVA', 'CBS - SWB', null, '2346');
            update testAccountSpanish;

            List<Task> tasksToInsert = new List<Task>();

            Task newTask1 = new Task();
            newTask1.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId();
            newTask1.OwnerId = testSalesManager.Id;
            newTask1.subject = testAccount.Name;
            newTask1.ActivityDate = System.today();
            newTask1.WhatId = testAccount.Id;
            tasksToInsert.add(newTask1);


            Task newTask2 = new Task();
            newTask2.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId();
            newTask2.OwnerId = testSalesManager.Id;
            newTask2.subject = testAccountSpanish.Name;
            newTask2.ActivityDate = System.today();
            newTask2.WhatId = testAccountSpanish.Id;
            tasksToInsert.add(newTask2);

            insert tasksToInsert;
        }
    }

    @isTest 
    public static void testTodaysTasksGetClosed(){

        Test.startTest();
            BatchCloseCallTasks BatchCloseCallTasks = new BatchCloseCallTasks();
            BatchCloseCallTasks.callTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId();
            BatchCloseCallTasks.today = System.today();
            BatchCloseCallTasks.query = 'SELECT Id, OwnerId, WhatId, Account.Primary_Language__c, Account.Warehouse_Lookup__r.Default_Outbound_Call_Queue__c, recordTypeId' + 
                                ' FROM Task' + 
                                ' WHERE AccountId != null and recordTypeId = :callTaskRecordTypeId AND ActivityDate = :today';
            Database.executeBatch(BatchCloseCallTasks);
        test.stopTest();

        List<Task> noOrderCapturedTasks = [SELECT Id, Subject, Status
                                            FROM Task
                                            WHERE Status = 'No Order Captured'];
        
        System.assertEquals(2, noOrderCapturedTasks.size(), 'All tasks created were closed');
    }
}
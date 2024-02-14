@isTest
private class TaskDAOTest {

    @TestSetup
    private static void setup(){
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '12345');
        Id genRecordTypeTask = Schema.SObjectType.Task.getRecordTypeInfosByName().get('General Task').getRecordTypeId();        
        TestFactory.createTaskByRecordType('Test Task', genRecordTypeTask, 'Open', testAccount.Id, System.today());
        Delivery_Date__c dd = TestFactory.createDeliveryDate(testAccount.Id, System.Today(), 'Active');
        Id callRecordTypeTask = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId();
        Task testCall = TestFactory.createTaskByRecordType('Test Task Call', callRecordTypeTask, 'Open', testAccount.Id, System.today());
        testCall.Delivery_Date__c = dd.Id;
        update testCall;
                
        //For Merch Checklists/Tasks
        Merch_Checklist__c mc = TestFactory.createMerchChecklist(testAccount.Id, System.Today());        
        Id merchRecordTypeTask = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Merch Task').getRecordTypeId();
        //Create 3 Tasks with different Statuses
        Task merchTask = TestFactory.createTaskByRecordType('Test Task', merchRecordTypeTask, 'Open', testAccount.Id, System.today());
        merchTask.Merch_Checklist__c = mc.Id;
        update merchTask;
        Task merchTask2 = TestFactory.createTaskByRecordType('Test Task', merchRecordTypeTask, 'Completed', testAccount.Id, System.today());
        merchTask2.Merch_Checklist__c = mc.Id;
        update merchTask2;        
        Task merchTask3 = TestFactory.createTaskByRecordType('Test Task', merchRecordTypeTask, 'In Progress', testAccount.Id, System.today());
        merchTask3.Merch_Checklist__c = mc.Id;
        update merchTask3;             
    }

    static Account getAccount() {
        return [SELECT Id, Name, VIP_Account_Number__c, Beer_Company__c, Warehouse__c
                FROM Account
                LIMIT 1];
    }

    static Task getTask(String subject) {
        return [SELECT Id, Subject, Description
                FROM Task
                WHERE Subject = :subject
                LIMIT 1];
    }

    
    static Delivery_Date__c getDeliveryDate(Date dd) {
        return [SELECT Id, Status__c
                FROM Delivery_Date__c
                WHERE Delivery_Date__c = :dd
                LIMIT 1];
    }
    
    @isTest
    static void testGetTasksByIdAndStatus(){
        Account testAccount = getAccount();

        Test.startTest();
        List<Task> taskList = TaskDAO.getTasksByIdAndStatus(new Set<Id>{testAccount.Id}, 'Open', false);
        taskList = TaskDAO.getTasksByIdAndStatus(new Set<Id>{testAccount.Id}, 'Open');
        Test.stopTest();

        System.assertEquals(3, taskList.size(), '3 records should be returned');
    }

    @isTest
    static void testGetTasksByIdAndStatusForCM() {
        Account testAccount = getAccount();

        Test.startTest();
        List<Task> taskList = TaskDAO.getTasksByIdAndStatusForCM(new Set<Id>{testAccount.Id}, 'Open', false);
        taskList = TaskDAO.getTasksByIdAndStatusForCM(new Set<Id>{testAccount.Id}, 'Open', true);
        Test.stopTest();

        System.assertEquals(2, taskList.size(), '2 records should be returned');
    }

    @isTest
    static void testGetTasksByIdAndStatusToday(){
        Account testAccount = getAccount();

        Test.startTest();
            List<Task> taskList = TaskDAO.getTasksByIdAndStatusToday(new Set<Id>{testAccount.Id}, 'Open');
        Test.stopTest();

        System.assertEquals(3, taskList.size(), '3 records should be returned');
    }

    @isTest
    static void testGetTasksByIdStatusRecordType(){
        Account testAccount = getAccount();
        Id callRecordTypeTask = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId();

        Test.startTest();
            List<Task> taskList = TaskDAO.getTasksByIdStatusRecordType(new Set<Id>{testAccount.Id}, 'Open', callRecordTypeTask);
        Test.stopTest();


        System.assertEquals(1, taskList.size(), '1 record should be returned');
    }
    
    
    @isTest
    static void testgetTasksByWarehouseActivityDateStatusRecordType() {
        Account testAccount = getAccount();
        Id callRecordTypeTask = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId();

        Test.startTest();
        List<Task> taskList = TaskDAO.getTasksByWarehouseActivityDateStatusRecordType( new set<String>{'PDVA-CHANTILLY'}, System.today(), 'Open', callRecordTypeTask);
        Test.stopTest();


        System.assertEquals(1, taskList.size(), '1 record should be returned');
    }
    
    
    @isTest
    static void testgetTasksByDeliveryIds1() {
        Account testAccount = getAccount();
        Delivery_Date__c testDD = getDeliveryDate(System.today());

        Test.startTest();
        List<Task> taskList = TaskDAO.getTasksByDeliveryIds(new List<Id>{testDD.Id});
        Test.stopTest();


        System.assertEquals(1, taskList.size(), '1 record should be returned');
    }
    
    @isTest
    static void testGetTasksByDeliveryIds2() {
        Account testAccount = getAccount();
        Delivery_Date__c testDD = getDeliveryDate(System.today());

        Test.startTest();
        List<Task> taskList = TaskDAO.getTasksByDeliveryIds(new set<Id>{testDD.Id});
        Test.stopTest();

        System.assertEquals(1, taskList.size(), '1 record should be returned');
    }    
    
    @isTest
    static void testGetMerchTasksByAccountIds() {
        Account testAccount = getAccount();

        Test.startTest();
        List<Task> taskList = TaskDAO.getMerchTasksByAccountIds(new set<Id>{testAccount.Id});
        Test.stopTest();

        System.assertEquals(0, taskList.size(), '0 records should be returned');
    }      
    
    @isTest
    static void testGetMerchTasksByMerchChecklistIds() {        
        Account testAccount = getAccount();
        Merch_Checklist__c testMC = [SELECT Id FROM Merch_Checklist__c WHERE Account__c =: testAccount.Id];

        Test.startTest();
        List<Task> taskList = TaskDAO.getMerchTasksByMerchChecklistIds(new set<Id>{testMC.Id});
        Test.stopTest();

        System.assertEquals(3, taskList.size(), '3 records should be returned');
    }  
    
    @isTest
    static void testInsertTasks(){
        Account testAccount = getAccount();
        Task testTask = new Task();
        testTask.Subject = 'Test Task2';
        testTask.WhatId = testAccount.Id;
        testTask.Description = 'testing task for account';
        testTask.Status = 'Open';

        Test.startTest();
            List<Task> testTaskList = TaskDAO.insertTasks(new List<Task>{testTask});
        Test.stopTest();

        List<Task> returnedTaskList = [SELECT Id FROM Task WHERE Subject = 'Test Task2'];

        System.assertEquals(1, returnedTaskList.size(), '1 record should be returned');
    }

    @isTest
    static void testUpdateTasks(){
        Task testTask = getTask('Test Task');
        testTask.Subject = 'Test Task3';

        Test.startTest();
            List<Task> testTaskList = TaskDAO.updateTasks(new List<Task>{testTask});
        Test.stopTest();

        List<Task> returnedTaskList = [SELECT Id FROM Task WHERE Subject = 'Test Task3'];

        System.assertEquals(1, returnedTaskList.size(), '1 record should be returned');
    }
    @isTest
    static void testGetTasksByUserIdAndStatusForCM(){
        Id userId = userInfo.getUserId();
        Test.startTest();
            List<Task> testTaskList = TaskDAO.getTasksByUserIdAndStatusForCM(new Set<Id>{userId}, 'Open');
        Test.stopTest();

        System.assertEquals(0, testTaskList.size(), '0 record should be returned');
    }

}
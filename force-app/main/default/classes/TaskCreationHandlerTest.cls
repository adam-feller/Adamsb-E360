@isTest
public with sharing class TaskCreationHandlerTest {
  
    @TestSetup
        static void setup(){
            Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
            UserRole preSalesRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Admin'];
            UserRole salesManagerRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Admin'];
            User testSalesManager = TestFactory.createUser(systemAdminProfile.Id, salesManagerRole.Id, 'newtest3User@gmail.com', null);

            System.runAs(testSalesManager){
                Warehouse__c testWarehouse = TestFactory.createWarehouse('CBS - SWB', testSalesManager.Id, 'CBS', null, null, null, null, null);
                Account testAccountWithoutFSR = TestFactory.createAccount('Non FSR Account', '201', 'PVA', 'CBS - SWB', null, '2345');

                Account testAccountWithFSR = new Account();
                testAccountWithFSR.Name = 'FSR Account';
                testAccountWithFSR.Account_Type__c = 'None';
                testAccountWithFSR.VIP_Account_Number__c = '7890';
                testAccountWithFSR.VIP_Instance__c = 'PVA';
                testAccountWithFSR.ExternalId__c = '72245';
                testAccountWithFSR.Chain__c = 'FOOD LION';
                testAccountWithFSR.Sell_Type__c = 'INSIDE SALES';
                testAccountWithFSR.Beer_Company__c = 'PVA';
                testAccountWithFSR.Warehouse__c = testWarehouse.Id;
                testAccountWithFSR.Store_Number__c = '123456';
                testAccountWithFSR.Territories__c = '10';
                testAccountWithFSR.Beer_Salesman_2_FSR__c = testSalesManager.Id;
                insert testAccountWithFSR;

                Pricebook2 testStandardPricebook = TestFactory.createStandardPriceBook();
                Contact testContact = TestFactory.createContact(testAccountWithFSR.Id, 'Test', 'Contact', 'test2@gmail.com');
                Order testOrder = TestFactory.createOrder(testAccountWithFSR.Id, testStandardPricebook.Id, System.today(), 'Pending Draft');
                testOrder.Order_Placed_By__c = testContact.Id;
                update testOrder;
            }
            
        }

    @isTest
    public static void testTaskOnInsertForNewlyAssignedFSR(){
        List<Task> taskList = [SELECT Id, Subject, AccountId, Owner.Email
                                FROM Task];

        System.assertEquals(1, taskList.size(), 'We should only see 1 because only one task has an FSR to assign a task to');
    }

    @isTest
    public static void testTaskOnUpdateForNewlyAssignedFS(){
        Account nonFSRAccount = [SELECT Id, Name, Beer_Salesman_2_FSR__c, Sell_Type__c
                                    FROM Account 
                                    WHERE Name = 'Non FSR Account' 
                                    LIMIT 1];

        User salesManager = [SELECT Id, Name, UserName
                                FROM User 
                                WHERE UserName = 'newtest3User@gmail.com'];

        nonFSRAccount.Beer_Salesman_2_FSR__c = salesManager.Id;
        nonFSRAccount.Sell_Type__c = 'NATIONAL ACCTS';

        update nonFSRAccount;

        List<Task> taskList = [SELECT Id, Subject, AccountId, Owner.Email
                                FROM Task
                                WHERE AccountId = :nonFSRAccount.Id];

        System.assertEquals(1, taskList.size(), 'We should see that 1 task was created after the account was updated with an FSR and proper Sell Type');
    }

    @isTest
    public static void testTaskCreationOnOrderErrorUpdate(){
        Test.enableChangeDataCapture();

        Account testAccountWithFSR = [SELECT Id, Name FROM Account WHERE Name = 'FSR Account' LIMIT 1];
        Pricebook2 testPriceBook = TestFactory.createPriceBook(testAccountWithFSR.Id, testAccountWithFSR.Name, true, 'Account Pricebook');
        Pricebook2 testStandardPriceBook = TestFactory.createStandardPriceBook();
        Product2 testProd = TestFactory.createProduct('Test Product', '12345', 'MillerCoors', '123*B');
        TestFactory.createPriceBookEntry(testStandardPriceBook.Id, testProd.Id, 12.99, false, true);
        PriceBookEntry testPriceBookEntry = TestFactory.createPriceBookEntry(testPriceBook.Id, testProd.Id, 12.99, false, true);
        Order testOrder = TestFactory.createOrder(testAccountWithFSR.Id, testPriceBook.Id, System.today(), 'Pending Draft');
        TestFactory.createOrderItem(testPriceBookEntry.Id, testOrder.Id, 1, 2, 11.99, testProd.Id);
        testOrder.Order_Errors__c = 'Error';
        testOrder.Status = 'Posting Error';
        update testOrder;

        // Call deliver to fire the trigger and deliver the test change event.
        Test.getEventBus().deliver();

        Test.startTest();
        Test.stopTest();

        List<Task> taskList = [SELECT Id, Subject FROM Task WHERE Order__c = :testOrder.Id];
        System.assertEquals(1, taskList.size(), 'We should have one newly created Task for the Order coming in with Errors');
    }

    @isTest
    public static void testCloseScheduledCallsBasedOnOrder(){
        String callTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId();
        
        Test.enableChangeDataCapture();

        Account testAccountWithFSR = [SELECT Id, Name FROM Account WHERE Name = 'FSR Account' LIMIT 1];
        PriceBook2 testStandardPricebook = [SELECT Id FROM Pricebook2 LIMIT 1];
        Task testCallTask = TestFactory.createTaskByRecordType(testAccountWithFSR.Name, callTaskRecordTypeId, 'Open', testAccountWithFSR.Id, System.today());

        Order testOrder = TestFactory.createOrder(testAccountWithFSR.Id, testStandardPricebook.Id, System.today(), 'Pending Draft');
        TestOrder.Delivery_Date__c = System.today()+5;    
        update TestOrder;

        Test.getEventBus().deliver();

        List<Task> taskList = [SELECT Id, Subject, Status FROM Task WHERE WhatId = :testAccountWithFSR.Id];
        System.assert(taskList.size()>1, 'The scheduled call Task should be closed');
    }

    @isTest
    public static void testCloseSubmittedOrderRelatedTasks(){
        Account testAccountWithFSR = [SELECT Id, Name FROM Account WHERE Name = 'FSR Account' LIMIT 1];
        Pricebook2 testPriceBook = TestFactory.createPriceBook(testAccountWithFSR.Id, testAccountWithFSR.Name, true, 'Account Pricebook');
        Pricebook2 testStandardPriceBook = TestFactory.createStandardPriceBook();
        Product2 testProd = TestFactory.createProduct('Test Product', '12345', 'MillerCoors', '123*B');
        TestFactory.createPriceBookEntry(testStandardPriceBook.Id, testProd.Id, 12.99, false, true);
        PriceBookEntry testPriceBookEntry = TestFactory.createPriceBookEntry(testPriceBook.Id, testProd.Id, 12.99, false, true);
        Order testOrder = TestFactory.createOrder(testAccountWithFSR.Id, testPriceBook.Id, System.today(), 'Pending Draft');
        Contact testContact = TestFactory.createContact(testAccountWithFSR.Id, 'Test2', 'Contact2', 'test3@gmail.com');
        TestFactory.createOrderItem(testPriceBookEntry.Id, testOrder.Id, 1, 2, 11.99, testProd.Id);

        Task tsk = TestFactory.createTask('Pending Order Task', null, 'Open', null);
        tsk.Order__c = testOrder.Id;

        Test.startTest();
        	update tsk;
        	testOrder.Status = 'Posted to VIP';
            testOrder.Order_Placed_By__c = testContact.Id;
        	update testOrder;
        Test.stopTest();

        List<Task> taskList = [SELECT Id, Subject, Status FROM Task WHERE Subject = 'Pending Order Task' AND Status = 'Completed'];

        System.assertEquals(1, taskList.size());

    }

    @isTest
    public static void testDeleteSubmittedOrderRelatedTasks(){
        Account testAccountWithFSR = [SELECT Id, Name FROM Account WHERE Name = 'FSR Account' LIMIT 1];
        Pricebook2 testPriceBook = TestFactory.createPriceBook(testAccountWithFSR.Id, testAccountWithFSR.Name, true, 'Account Pricebook');
        Pricebook2 testStandardPriceBook = TestFactory.createStandardPriceBook();
        Product2 testProd = TestFactory.createProduct('Test Product', '12345', 'MillerCoors', '123*B');
        TestFactory.createPriceBookEntry(testStandardPriceBook.Id, testProd.Id, 12.99, false, true);
        PriceBookEntry testPriceBookEntry = TestFactory.createPriceBookEntry(testPriceBook.Id, testProd.Id, 12.99, false, true);
        Order testOrder = TestFactory.createOrder(testAccountWithFSR.Id, testPriceBook.Id, System.today(), 'Pending Draft');
        TestFactory.createOrderItem(testPriceBookEntry.Id, testOrder.Id, 1, 2, 11.99, testProd.Id);

        Task tsk = TestFactory.createTask('Pending Order Task', null, 'Open', null);
        tsk.Order__c = testOrder.Id;
        update tsk;

        Test.startTest();
        delete testOrder;
        Test.stopTest();

        List<Task> taskList = [SELECT Id FROM Task WHERE Subject = 'Pending Order Task' AND Status = 'Completed'];

        System.assertEquals(1, taskList.size());
    }
}
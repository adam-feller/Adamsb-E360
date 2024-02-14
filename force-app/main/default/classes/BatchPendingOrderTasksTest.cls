@isTest
public with sharing class BatchPendingOrderTasksTest {

    @TestSetup
    private static void setup(){
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        UserRole preSalesRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Admin'];
        UserRole adminUserRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Admin'];

        User testSalesManager = TestFactory.createUser(systemAdminProfile.Id, adminUserRole.Id, 'newtest3User@gmail.com', null);
        User primaryISR = TestFactory.createUser(systemAdminProfile.Id, adminUserRole.Id, 'primaryISR@gmail.com', null);

        User integrationUser = TestFactory.createUser(systemAdminProfile.Id, adminUserRole.Id, 'alexander.velitsky@slalom.com', null);
        integrationUser.firstName = 'Integration';
        integrationUser.lastName = 'Service Account';
        Update integrationUser;
        
        System.runAs(testSalesManager){
            Warehouse__c testWarehouse = TestFactory.createWarehouse('CBS - SWB', UserInfo.getUserId(), 'CBS', null, null, null, null, null);
            testWarehouse.ISR_1__c = primaryISR.Id;
            update testWarehouse;
            Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'CBS - SWB', null, '2345');
            Pricebook2 testStandardPricebook = TestFactory.createStandardPriceBook();
        }
    }

    private static List<String> getPendingOrderStatusList(){
        List<String> pendingOrderStatusList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Order.Status.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            String pickListStringVal = (String)pickListVal.getValue();
            if(pickListStringVal.containsIgnoreCase('Pending')){
                pendingOrderStatusList.add(pickListVal.getLabel());
            }
        }

        return pendingOrderStatusList;
    }

    private static Account getTestAccount(){
        return [SELECT Id, Name
                FROM Account
                WHERE Name = 'Test Account'
                LIMIT 1];
    }

    private static Pricebook2 getTestStandardPricebook(){
        return [SELECT Id
                FROM Pricebook2
                WHERE IsStandard = TRUE
                LIMIT 1];
    }

    private static User getPrimaryISRUser(){
        return [SELECT Id
                FROM User
                WHERE Username = 'primaryISR@gmail.com'
                LIMIT 1];
    }

    private static User getIntegrationUser(){
        return [SELECT Id
                FROM User
                WHERE Name = 'Integration Service Account'
                LIMIT 1];
    }

    @isTest
    private static void testPendingOrderTasksInternalUserCreation(){

        List<String> pendingOrderStatusList = getPendingOrderStatusList();

        List<Order> ordList = [Select Id, createdDate, Status FROM order WHERE CreatedDate = TODAY AND status IN :pendingOrderStatusList];

        Test.startTest();
            Account testAccount = getTestAccount();
            PriceBook2 testStandardPriceBook = getTestStandardPricebook();

            Pricebook2 testPriceBook = TestFactory.createPriceBook(testAccount.Id, testAccount.Name, true, 'Account Pricebook');
            Product2 testProd = TestFactory.createProduct('Test Product', '12345', 'MillerCoors', '123*B');
            TestFactory.createPriceBookEntry(testStandardPriceBook.Id, testProd.Id, 12.99, false, true);
            PriceBookEntry testPriceBookEntry = TestFactory.createPriceBookEntry(testPriceBook.Id, testProd.Id, 12.99, false, true);
            Order testOrder = TestFactory.createOrder(testAccount.Id, testPriceBook.Id, System.today(),'Pending Draft');
            OrderItem oi = TestFactory.createOrderItem(testPriceBookEntry.Id, testOrder.Id, 1, 2, 11.99, testProd.Id);

            BatchPendingOrderTasks batchPendingOrderTasks = new BatchPendingOrderTasks();
            batchPendingOrderTasks.pendingOrderStatusList = pendingOrderStatusList;
            batchPendingOrderTasks.query =  'SELECT Id, OrderNumber, PoNumber, Delivery_Date__c, AccountId, Status, Account.ExternalId__c, CreatedDate, CreatedBy.Name, OwnerId' + 
                                            ' FROM Order' + 
                                            ' WHERE CreatedDate = TODAY' +
                                            ' AND Status =  \'Pending Draft\'';
            Database.executeBatch(batchPendingOrderTasks);
        Test.stopTest();

        List<Task> taskList = [SELECT Id, Subject 
                                FROM Task
                                WHERE Subject LIKE 'Order in Pending Status%'
								AND OwnerId = :getPrimaryISRUser().Id];

        System.assertEquals(1, taskList.size(), 'taskList size should equal 1');
    }

    @isTest
    private static void testPendingOrderTasksIntegrationCreation(){
        List<String> pendingOrderStatusList = getPendingOrderStatusList();

        Test.startTest();

            System.runAs(getIntegrationUser()){
                Account testAccount = getTestAccount();
                PriceBook2 testStandardPriceBook = getTestStandardPricebook();
    
                Pricebook2 testPriceBook = TestFactory.createPriceBook(testAccount.Id, testAccount.Name, true, 'Account Pricebook');
                Product2 testProd = TestFactory.createProduct('Test Product', '12345', 'MillerCoors', '123*B');
                TestFactory.createPriceBookEntry(testStandardPriceBook.Id, testProd.Id, 12.99, false, true);
                PriceBookEntry testPriceBookEntry = TestFactory.createPriceBookEntry(testPriceBook.Id, testProd.Id, 12.99, false, true);
                Order testOrder = TestFactory.createOrder(testAccount.Id, testPriceBook.Id, System.today(),'Pending Draft');
                OrderItem oi = TestFactory.createOrderItem(testPriceBookEntry.Id, testOrder.Id, 1, 2, 11.99, testProd.Id);

                BatchPendingOrderTasks batchPendingOrderTasks = new BatchPendingOrderTasks();
                batchPendingOrderTasks.pendingOrderStatusList = pendingOrderStatusList;
                batchPendingOrderTasks.query =  'SELECT Id, OrderNumber, PoNumber, Delivery_Date__c, AccountId, Status, Account.ExternalId__c, CreatedDate, CreatedBy.Name, OwnerId' + 
                                                ' FROM Order' + 
                                                ' WHERE CreatedDate = TODAY' +
                                                ' AND Status =  \'Pending Draft\'';
                Database.executeBatch(batchPendingOrderTasks);
            Test.stopTest();
    
        List<Task> taskList = [SELECT Id, Subject 
                                FROM Task
                                WHERE Subject LIKE 'Order in Pending Status%'
                                AND OwnerId = :getPrimaryISRUser().Id];

        System.assertEquals(1, taskList.size(), 'taskList size should equal 1');
        }
    }

    @isTest
    private static void testDeletionOfOrdersWithoutOrderItems(){

        List<String> pendingOrderStatusList = getPendingOrderStatusList();

        Test.startTest();
            Account testAccount = getTestAccount();
            PriceBook2 testStandardPriceBook = getTestStandardPricebook();

            Pricebook2 testPriceBook = TestFactory.createPriceBook(testAccount.Id, testAccount.Name, true, 'Account Pricebook');
            Product2 testProd = TestFactory.createProduct('Test Product', '12345', 'MillerCoors', '123*B');
            TestFactory.createPriceBookEntry(testStandardPriceBook.Id, testProd.Id, 12.99, false, true);
            PriceBookEntry testPriceBookEntry = TestFactory.createPriceBookEntry(testPriceBook.Id, testProd.Id, 12.99, false, true);
            Order testOrder = TestFactory.createOrder(testAccount.Id, testPriceBook.Id, System.today(),'Pending Draft');

            BatchPendingOrderTasks batchPendingOrderTasks = new BatchPendingOrderTasks();
            batchPendingOrderTasks.pendingOrderStatusList = pendingOrderStatusList;
            batchPendingOrderTasks.query =  'SELECT Id, OrderNumber, PoNumber, Delivery_Date__c, AccountId, Status, Account.ExternalId__c, CreatedDate, CreatedBy.Name, OwnerId' + 
                                            ' FROM Order' + 
                                            ' WHERE CreatedDate = TODAY' +
                                            ' AND Status =  \'Pending Draft\'';
            Database.executeBatch(batchPendingOrderTasks);
        Test.stopTest();

        List<Order> orderList = [SELECT Id
                                FROM Order
                                ];

        System.assertEquals(0, orderList.size(), 'orderList size should equal 0');
    }

}
@isTest
private class CallScheduleHandlerTest {

    @TestSetup
    private static void setup(){
         Profile p = [SELECT Id FROM Profile WHERE Name='Call Center'];
         User isr = new User(Alias='isruser', Email='isr@testorg.com', 
						EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
						LocaleSidKey='en_US', ProfileId=p.Id, 
						TimeZoneSidKey='America/Los_Angeles', UserName='isr@testorg.com');
		insert isr;        
        Warehouse__c testWarehouse = TestFactory.createWarehouse('PDVA-CHANTILLY', null, null, null, null, null, null, null);
        testWarehouse.ISR_1__c = isr.Id;
        update testWarehouse;
        
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        testAccount.Sell_Type__c = 'INSIDE SALES';
        update testAccount;

        Id callRecordTypeTask = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId();
        TestFactory.createTaskByRecordType('Test Account', callRecordTypeTask, 'Open', testAccount.Id, System.today());
        TestFactory.createTaskByRecordType('Test Account', callRecordTypeTask, 'Open', testAccount.Id, System.today().addDays(7));
        TestFactory.createTaskByRecordType('Test Account', callRecordTypeTask, 'Open', testAccount.Id, System.today().addDays(14));
    }

    static Account getAccount(String Name){
        return [SELECT Id, Name, VIP_Account_Number__c, Beer_Company__c, Warehouse__c, Territories__c, Sell_Type__c, Requested_Delivery_Days__c, Delivery_Frequency_Type__c,
                Batch_Call_Date_Created__c, Warehouse_Lookup__r.ISR_1__c, OwnerId
                FROM Account
                WHERE Name = :name
                LIMIT 1];
    }

    @isTest
    static void testCheckForUpdatedCallScheduleDeliveryDayWeekly(){
        Account testAccount = getAccount('Test Account');
        Account testAccount2 = getAccount('Test Account');
        testAccount.Requested_Delivery_Days__c = 'Monday';
        testAccount.Delivery_Frequency_Type__c = 'Weekly';
        testAccount.Batch_Call_Date_Created__c = System.today().toStartOfWeek();
        testAccount.Batch_Call_Date_Ended__c = System.today().toStartOfWeek().addDays(84);
        testAccount.Status__c = 'A';
        update testAccount;

        Test.startTest();
            CallScheduleHandler.checkForUpdatedCallScheduleDeliveryDay(new List<Account>{testAccount2}, new Map<Id, Account>{testAccount.Id => testAccount});
        Test.stopTest();

        List<Task> tasksInserted = [SELECT Id FROM TASK WHERE Status = 'Open'];
        List<Task> tasksUpdated = [SELECT Id FROM TASK WHERE Status = 'Cancelled'];

        //Assertions
        System.assertNotEquals(tasksInserted.size(), 0, 'Task records should be created');
        System.assertEquals(tasksUpdated.size(), 3, '3 Task records should be updated to a Cancelled status');
    }

    @isTest
    static void testCheckForUpdatedCallScheduleDeliveryDayA(){
        Account testAccount = getAccount('Test Account');
        Account testAccount2 = getAccount('Test Account');
        testAccount.Requested_Delivery_Days__c = 'Monday';
        testAccount.Delivery_Frequency_Type__c = 'A';
        testAccount.Batch_Call_Date_Created__c = System.today().toStartOfWeek();
        testAccount.Batch_Call_Date_Ended__c = System.today().toStartOfWeek().addDays(84);
        testAccount.Status__c = 'A';
        update testAccount;

        Test.startTest();
            CallScheduleHandler.checkForUpdatedCallScheduleDeliveryDay(new List<Account>{testAccount2}, new Map<Id, Account>{testAccount.Id => testAccount});
        Test.stopTest();

        List<Task> tasksInserted = [SELECT Id FROM TASK WHERE Status = 'Open'];
        List<Task> tasksUpdated = [SELECT Id FROM TASK WHERE Status = 'Cancelled'];

        //Assertions
        System.assertNotEquals(tasksInserted.size(), 0, 'Task records should be created');
        System.assertEquals(tasksUpdated.size(), 3, '3 Task records should be updated to a Cancelled status');
    }

    @isTest
    static void testCheckForUpdatedCallScheduleDeliveryDayB(){
        Account testAccount = getAccount('Test Account');
        Account testAccount2 = getAccount('Test Account');
        testAccount.Requested_Delivery_Days__c = 'Monday';
        testAccount.Delivery_Frequency_Type__c = 'B';
        testAccount.Batch_Call_Date_Created__c = System.today().toStartOfWeek();
        testAccount.Batch_Call_Date_Ended__c = System.today().toStartOfWeek().addDays(84);
        testAccount.Status__c = 'A';
        update testAccount;

        Test.startTest();
            CallScheduleHandler.checkForUpdatedCallScheduleDeliveryDay(new List<Account>{testAccount2}, new Map<Id, Account>{testAccount.Id => testAccount});
        Test.stopTest();

        List<Task> tasksInserted = [SELECT Id FROM TASK WHERE Status = 'Open'];
        List<Task> tasksUpdated = [SELECT Id FROM TASK WHERE Status = 'Cancelled'];

        //Assertions
        System.assertNotEquals(tasksInserted.size(), 0, 'Task records should be created');
        System.assertEquals(tasksUpdated.size(), 3, '3 Task records should be updated to a Cancelled status');
    }

    @isTest
    static void testCheckForUpdatedCallScheduleDeliveryDay1(){
        Account testAccount = getAccount('Test Account');
        Account testAccount2 = getAccount('Test Account');
        testAccount.Requested_Delivery_Days__c = 'Tuesday';
        testAccount.Delivery_Frequency_Type__c = '1';
        testAccount.Batch_Call_Date_Created__c = System.today().toStartOfWeek();
        testAccount.Batch_Call_Date_Ended__c = System.today().toStartOfWeek().addDays(84);
        testAccount.Status__c = 'A';
        update testAccount;

        Test.startTest();
            CallScheduleHandler.checkForUpdatedCallScheduleDeliveryDay(new List<Account>{testAccount2}, new Map<Id, Account>{testAccount.Id => testAccount});
        Test.stopTest();

        List<Task> tasksInserted = [SELECT Id FROM TASK WHERE Status = 'Open'];
        List<Task> tasksUpdated = [SELECT Id FROM TASK WHERE Status = 'Cancelled'];

        //Assertions
        System.assertNotEquals(tasksInserted.size(), 0, 'Task records should be created');
        System.assertEquals(tasksUpdated.size(), 3, '3 Task records should be updated to a Cancelled status');
    }

    @isTest
    static void testCheckForUpdatedCallScheduleDeliveryDay2(){
        Account testAccount = getAccount('Test Account');
        Account testAccount2 = getAccount('Test Account');
        testAccount.Requested_Delivery_Days__c = 'Wednesday';
        testAccount.Delivery_Frequency_Type__c = '2';
        testAccount.Batch_Call_Date_Created__c = System.today().toStartOfWeek();
        testAccount.Batch_Call_Date_Ended__c = System.today().toStartOfWeek().addDays(84);
        testAccount.Status__c = 'A';
        update testAccount;

        Test.startTest();
            CallScheduleHandler.checkForUpdatedCallScheduleDeliveryDay(new List<Account>{testAccount2}, new Map<Id, Account>{testAccount.Id => testAccount});
        Test.stopTest();

        List<Task> tasksInserted = [SELECT Id FROM TASK WHERE Status = 'Open'];
        List<Task> tasksUpdated = [SELECT Id FROM TASK WHERE Status = 'Cancelled'];

        //Assertions
        System.assertNotEquals(tasksInserted.size(), 0, 'Task records should be created');
        System.assertEquals(tasksUpdated.size(), 3, '3 Task records should be updated to a Cancelled status');
    }

    @isTest
    static void testCheckForUpdatedCallScheduleDeliveryDay3(){
        Account testAccount = getAccount('Test Account');
        Account testAccount2 = getAccount('Test Account');
        testAccount.Requested_Delivery_Days__c = 'Thursday';
        testAccount.Delivery_Frequency_Type__c = '3';
        testAccount.Batch_Call_Date_Created__c = System.today().toStartOfWeek();
        testAccount.Batch_Call_Date_Ended__c = System.today().toStartOfWeek().addDays(84);
        testAccount.Status__c = 'A';
        update testAccount;

        Test.startTest();
            CallScheduleHandler.checkForUpdatedCallScheduleDeliveryDay(new List<Account>{testAccount2}, new Map<Id, Account>{testAccount.Id => testAccount});
        Test.stopTest();

        List<Task> tasksInserted = [SELECT Id FROM TASK WHERE Status = 'Open'];
        List<Task> tasksUpdated = [SELECT Id FROM TASK WHERE Status = 'Cancelled'];

        //Assertions
        System.assertNotEquals(tasksInserted.size(), 0, 'Task records should be created');
        System.assertEquals(tasksUpdated.size(), 3, '3 Task records should be updated to a Cancelled status');
    }

    @isTest
    static void testCheckForUpdatedCallScheduleDeliveryDay4(){
        Account testAccount = getAccount('Test Account');
        Account testAccount2 = getAccount('Test Account');
        testAccount.Requested_Delivery_Days__c = 'Friday';
        testAccount.Delivery_Frequency_Type__c = '4';
        testAccount.Batch_Call_Date_Created__c = System.today().toStartOfWeek();
        testAccount.Batch_Call_Date_Ended__c = System.today().toStartOfWeek().addDays(84);
        testAccount.Status__c = 'A';
        update testAccount;

        Test.startTest();
            CallScheduleHandler.checkForUpdatedCallScheduleDeliveryDay(new List<Account>{testAccount2}, new Map<Id, Account>{testAccount.Id => testAccount});
        Test.stopTest();

        List<Task> tasksInserted = [SELECT Id FROM TASK WHERE Status = 'Open'];
        List<Task> tasksUpdated = [SELECT Id FROM TASK WHERE Status = 'Cancelled'];

        //Assertions
        System.assertNotEquals(tasksInserted.size(), 0, 'Task records should be created');
        System.assertEquals(tasksUpdated.size(), 3, '3 Task records should be updated to a Cancelled status');
    }
    
    @isTest
    static void testCancelCallsAndDeleteDeliveryDayForIorOAccounts(){
        Account testAccount = getAccount('Test Account');
        Account testAccount2 = getAccount('Test Account');
        testAccount.Requested_Delivery_Days__c = 'Friday';
        testAccount.Delivery_Frequency_Type__c = '4';
        testAccount.Status__c = 'I';
        testAccount.Batch_Call_Date_Created__c = System.today().toStartOfWeek();
        testAccount.Batch_Call_Date_Ended__c = System.today().toStartOfWeek().addDays(84);
        update testAccount;

        Test.startTest();
            CallScheduleHandler.cancelCallsAndDeleteDeliveryDayForIorOAccounts(new List<Account>{testAccount2}, new Map<Id, Account>{testAccount.Id => testAccount});
        Test.stopTest();

        List<Task> tasksInserted = [SELECT Id FROM TASK WHERE Status = 'Open'];
        List<Task> tasksUpdated = [SELECT Id FROM TASK WHERE Status = 'Cancelled'];

        //Assertions
        System.assertEquals(tasksInserted.size(), 0, '0 Task records should be created');
        System.assertEquals(tasksUpdated.size(), 3, '3 Task records should be updated to a Cancelled status');
    }

    @isTest
    static void testCheckForUpdatedInsertCallScheduleDeliveryDayWeekly(){
        Account testAccount = new Account();
        testAccount.Name = 'Test Account 3';
        testAccount.Account_Type__c = 'None';
        testAccount.VIP_Account_Number__c = '20100';
        testAccount.VIP_Instance__c = 'PVA';
        testAccount.ExternalId__c = '72245';
        testAccount.Chain__c = 'FOOD LION';
        testAccount.Warehouse__c = 'PDVA-CHANTILLY';
        testAccount.Store_Number__c = '20100';
        testAccount.Territories__c = '10';
        testAccount.Requested_Delivery_Days__c = 'Monday';
        testAccount.Delivery_Frequency_Type__c = 'Weekly';
        testAccount.Batch_Call_Date_Created__c = System.today().toStartOfWeek();
        testAccount.Batch_Call_Date_Ended__c = System.today().toStartOfWeek().addDays(84);
        testAccount.Status__c = 'A';
        testAccount.Sell_Type__c = 'Presell';
        insert testAccount;

        Test.startTest();
            CallScheduleHandler.checkForUpdatedCallScheduleDeliveryDay(new List<Account>{testAccount}, null);
        Test.stopTest();

        List<Delivery_Date__c> deliveryDatesInserted = [SELECT Id FROM Delivery_Date__c];

        //Assertion
        System.assertNotEquals(deliveryDatesInserted.size(), 0, 'Delivery Dates should be created');
    }

    @isTest
    static void testcheckForUpdatedSellType(){
		Account testAccount = getAccount('Test Account');
        Account testAccount2 = getAccount('Test Account');
        testAccount.Requested_Delivery_Days__c = 'Friday';
        testAccount.Delivery_Frequency_Type__c = '4';
        testAccount.Sell_Type__c = 'Presell';
        testAccount.Status__c = 'A';
        testAccount.Batch_Call_Date_Created__c = System.today().toStartOfWeek();
        testAccount.Batch_Call_Date_Ended__c = System.today().toStartOfWeek().addDays(84);
        update testAccount;

        Test.startTest();
            CallScheduleHandler.checkForUpdatedSellType(new List<Account>{testAccount2}, new Map<Id, Account>{testAccount.Id => testAccount});
        Test.stopTest();

        List<Task> tasksInserted = [SELECT Id FROM TASK WHERE Status = 'Open'];
        List<Task> tasksUpdated = [SELECT Id FROM TASK WHERE Status = 'Cancelled'];

        //Assertions
        System.assertEquals(tasksInserted.size(), 0, '0 Task records should be created');
        System.assertEquals(tasksUpdated.size(), 3, '3 Task records should be updated to a Cancelled status');
    }

    @isTest
    static void testcheckForUpdatedSellTypeInsideSales(){
        Account testAccount = getAccount('Test Account');
        Account testAccount2 = getAccount('Test Account');
        testAccount.Requested_Delivery_Days__c = 'Friday';
        testAccount.Delivery_Frequency_Type__c = '4';
        testAccount.Sell_Type__c = 'NATIONAL ACCTS';
        testAccount.Status__c = 'A';
        testAccount.Batch_Call_Date_Created__c = System.today().toStartOfWeek();
        testAccount.Batch_Call_Date_Ended__c = System.today().toStartOfWeek().addDays(84);
        update testAccount;
        testAccount2.Requested_Delivery_Days__c = 'Friday';
        testAccount2.Delivery_Frequency_Type__c = '4';
        testAccount2.Status__c = 'A';
        update testAccount2;

        Test.startTest();
            CallScheduleHandler.checkForUpdatedSellType(new List<Account>{testAccount2}, new Map<Id, Account>{testAccount.Id => testAccount});
        Test.stopTest();

        List<Task> tasksInserted = [SELECT Id FROM TASK WHERE Status = 'Open'];
        List<Task> tasksUpdated = [SELECT Id FROM TASK WHERE Status = 'Cancelled'];

        //Assertion
        System.assertNotEquals(tasksInserted.size(), 0, 'Task records should be created');
    }
}
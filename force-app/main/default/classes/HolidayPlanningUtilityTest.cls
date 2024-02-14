@isTest
public with sharing class HolidayPlanningUtilityTest {
    @TestSetup
    private static void setup(){

        List<Account> accountsToInsert = new List<Account>();
        List<Delivery_Date__c> deliveryDatesToInsert = new List<Delivery_Date__c>();
        List<Task> tasksToInsert = new List<Task>();

        Id retailRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retail Store').getRecordTypeId();
        Id callRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId();


        Warehouse__c testWarehouse = TestFactory.createWarehouse('PDC Warehouse', null, 'PDC' , null, null, null, null, null);
        Warehouse__c testWarehouse2 = TestFactory.createWarehouse('HJC - Charleston', null, 'HJC' , null, null, null, null, null);
        Warehouse__c testWarehouse3 = TestFactory.createWarehouse('Golden Valley', null, 'GVL' , null, null, null, null, null);

        Account testAccount1 = new Account();
        testAccount1.Name = 'Test Account 1';
        testAccount1.Account_Type__c = 'None';
        testAccount1.VIP_Account_Number__c = '101';
        testAccount1.VIP_Instance__c = 'PDC';
        testAccount1.ExternalId__c = '72245';
        testAccount1.Chain__c = 'FOOD LION';
        testAccount1.Beer_Company__c = 'PDC';
        testAccount1.Warehouse__c = 'PDC Warehouse';
        testAccount1.Store_Number__c = '12345';
        testAccount1.recordTypeId = retailRecordTypeId;
        testAccount1.Territories__c = '10';
        accountsToInsert.add(testAccount1);


        Account testAccount2 = new Account();
        testAccount2.Name = 'Test Account 2';
        testAccount2.Account_Type__c = 'None';
        testAccount2.VIP_Account_Number__c = '201';
        testAccount2.VIP_Instance__c = 'HJC';
        testAccount2.ExternalId__c = '72245';
        testAccount2.Chain__c = 'FOOD LION';
        testAccount2.Beer_Company__c = 'PDC';
        testAccount2.Warehouse__c = 'HJC - Charleston';
        testAccount2.Store_Number__c = '12345';
        testAccount2.recordTypeId = retailRecordTypeId;
        testAccount2.Territories__c = '10';
        accountsToInsert.add(testAccount2);

        Account testAccount3 = new Account();
        testAccount3.Name = 'Test Account 3';
        testAccount3.Account_Type__c = 'None';
        testAccount3.VIP_Account_Number__c = '301';
        testAccount3.VIP_Instance__c = 'GVL';
        testAccount3.ExternalId__c = '72245';
        testAccount3.Chain__c = 'FOOD LION';
        testAccount3.Beer_Company__c = 'PDC';
        testAccount3.Warehouse__c = 'Golden Valley';
        testAccount3.Store_Number__c = '12345';
        testAccount3.recordTypeId = retailRecordTypeId;
        testAccount3.Territories__c = '10';
        accountsToInsert.add(testAccount3);

        insert accountsToInsert;


        Delivery_Date__c testDeliveryDate1 = new Delivery_Date__c();
        testDeliveryDate1.Account__c = testAccount1.Id;
        testDeliveryDate1.Delivery_Date__c = Date.newInstance(2021, 03, 22);
        deliveryDatesToInsert.add(testDeliveryDate1);

        Delivery_Date__c testDeliveryDate2 = new Delivery_Date__c();
        testDeliveryDate2.Account__c = testAccount1.Id;
        testDeliveryDate2.Delivery_Date__c = Date.newInstance(2021, 03, 23);
        deliveryDatesToInsert.add(testDeliveryDate2);

        Delivery_Date__c testDeliveryDate3 = new Delivery_Date__c();
        testDeliveryDate3.Account__c = testAccount1.Id;
        testDeliveryDate3.Delivery_Date__c = Date.newInstance(2021, 03, 24);
        deliveryDatesToInsert.add(testDeliveryDate3);

        Delivery_Date__c testDeliveryDate4 = new Delivery_Date__c();
        testDeliveryDate4.Account__c = testAccount2.Id;
        testDeliveryDate4.Delivery_Date__c = Date.newInstance(2021, 03, 22);
        deliveryDatesToInsert.add(testDeliveryDate4);

        Delivery_Date__c testDeliveryDate5 = new Delivery_Date__c();
        testDeliveryDate5.Account__c = testAccount2.Id;
        testDeliveryDate5.Delivery_Date__c = Date.newInstance(2021, 03, 23);
        deliveryDatesToInsert.add(testDeliveryDate5);

        Delivery_Date__c testDeliveryDate6 = new Delivery_Date__c();
        testDeliveryDate6.Account__c = testAccount2.Id;
        testDeliveryDate6.Delivery_Date__c = Date.newInstance(2021, 03, 24);
        deliveryDatesToInsert.add(testDeliveryDate6);

        Delivery_Date__c testDeliveryDate7 = new Delivery_Date__c();
        testDeliveryDate7.Account__c = testAccount3.Id;
        testDeliveryDate7.Delivery_Date__c = Date.newInstance(2021, 03, 22);
        deliveryDatesToInsert.add(testDeliveryDate7);

        Delivery_Date__c testDeliveryDate8 = new Delivery_Date__c();
        testDeliveryDate8.Account__c = testAccount3.Id;
        testDeliveryDate8.Delivery_Date__c = Date.newInstance(2021, 03, 23);
        deliveryDatesToInsert.add(testDeliveryDate8);

        Delivery_Date__c testDeliveryDate9 = new Delivery_Date__c();
        testDeliveryDate9.Account__c = testAccount3.Id;
        testDeliveryDate9.Delivery_Date__c = Date.newInstance(2021, 03, 24);
        deliveryDatesToInsert.add(testDeliveryDate9);

        insert deliveryDatesToInsert;

        Task testTask1 = new Task();
        testTask1.RecordTypeId = callRecordTypeId;
        testTask1.Subject = 'Outbound Call - ' + testAccount1.Name;
        testTask1.WhatId = testAccount1.Id;
        testTask1.Account__c = testAccount1.Id;
        testTask1.ActivityDate = Date.newInstance(2021, 03, 21);
        tasksToInsert.add(testTask1);

        Task testTask2 = new Task();
        testTask2.RecordTypeId = callRecordTypeId;
        testTask2.Subject = 'Outbound Call - ' + testAccount1.Name;
        testTask2.WhatId = testAccount1.Id;
        testTask2.Account__c = testAccount1.Id;
        testTask2.ActivityDate = Date.newInstance(2021, 03, 22);
        tasksToInsert.add(testTask2);

        Task testTask3 = new Task();
        testTask3.RecordTypeId = callRecordTypeId;
        testTask3.Subject = 'Outbound Call - ' + testAccount1.Name;
        testTask3.WhatId = testAccount1.Id;
        testTask3.Account__c = testAccount1.Id;
        testTask3.ActivityDate = Date.newInstance(2021, 03, 23);
        tasksToInsert.add(testTask3);

        Task testTask4 = new Task();
        testTask4.RecordTypeId = callRecordTypeId;
        testTask4.Subject = 'Outbound Call - ' + testAccount2.Name;
        testTask4.WhatId = testAccount2.Id;
        testTask4.Account__c = testAccount2.Id;
        testTask4.ActivityDate = Date.newInstance(2021, 03, 21);
        tasksToInsert.add(testTask4);

        Task testTask5 = new Task();
        testTask5.RecordTypeId = callRecordTypeId;
        testTask5.Subject = 'Outbound Call - ' + testAccount2.Name;
        testTask5.WhatId = testAccount2.Id;
        testTask5.Account__c = testAccount2.Id;
        testTask5.ActivityDate = Date.newInstance(2021, 03, 22);
        tasksToInsert.add(testTask5);

        Task testTask6 = new Task();
        testTask6.RecordTypeId = callRecordTypeId;
        testTask6.Subject = 'Outbound Call - ' + testAccount2.Name;
        testTask6.WhatId = testAccount2.Id;
        testTask6.Account__c = testAccount2.Id;
        testTask6.ActivityDate = Date.newInstance(2021, 03, 23);
        tasksToInsert.add(testTask6);

        Task testTask7 = new Task();
        testTask7.RecordTypeId = callRecordTypeId;
        testTask7.Subject = 'Outbound Call - ' + testAccount3.Name;
        testTask7.WhatId = testAccount3.Id;
        testTask7.Account__c = testAccount3.Id;
        testTask7.ActivityDate = Date.newInstance(2021, 03, 21);
        tasksToInsert.add(testTask7);

        Task testTask8 = new Task();
        testTask8.RecordTypeId = callRecordTypeId;
        testTask8.Subject = 'Outbound Call - ' + testAccount3.Name;
        testTask8.WhatId = testAccount3.Id;
        testTask8.Account__c = testAccount3.Id;
        testTask8.ActivityDate = Date.newInstance(2021, 03, 22);
        tasksToInsert.add(testTask8);

        Task testTask9 = new Task();
        testTask9.RecordTypeId = callRecordTypeId;
        testTask9.Subject = 'Outbound Call - ' + testAccount3.Name;
        testTask9.WhatId = testAccount3.Id;
        testTask9.Account__c = testAccount3.Id;
        testTask9.ActivityDate = Date.newInstance(2021, 03, 23);
        tasksToInsert.add(testTask9);

        insert tasksToInsert;


    }

    @isTest
    private static void testCreateDeliveryDateResultsString(){


        List<Delivery_Date__c> deliveryDateList = [Select Id, Account__r.Warehouse__c, Warehouse__c, Delivery_Date__c FROM Delivery_Date__c];


        String deliveryDateResults = HolidayPlanningUtility.createDeliveryDateResultsString('Delivery Date Results', deliveryDateList);

        System.assertNotEquals(null, deliveryDateList);

    }

    @isTest
    private static void createCallTaskResultsString(){


        List<Task> taskList = [Select Id, Warehouse__c, Account__r.Warehouse__c, Account.Warehouse__c, ActivityDate FROM Task];


        String taskResults = HolidayPlanningUtility.createCallTaskResultsString('Call Task Results', taskList);

        System.assertNotEquals(null, taskResults);

    }

}
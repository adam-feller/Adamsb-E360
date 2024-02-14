@IsTest
public class WarehouseTriggerHandlerTest {

    @TestSetup
    private static void setup(){
        Profile callCenterProfile = [SELECT Id FROM Profile WHERE Name = 'Call Center'];        
        UserRole ISRRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'ISR'];
        User testUser1 = TestFactory.createUser(callCenterProfile.Id, ISRRole.Id, 'newtest1User@gmail.com', null);
        User testUser2 = TestFactory.createUser(callCenterProfile.Id, ISRRole.Id, 'newtest2User@gmail.com', null);
    }

    @isTest
    static void testWarehouseISRChange(){
		Id callTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId();
        Id retailRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retail Store').getRecordTypeId();
        User testUser1 = [SELECT Id FROM User WHERE username = 'newtest1User@gmail.com'];
        User testUser2 = [SELECT Id FROM User WHERE username = 'newtest2User@gmail.com'];
        Warehouse__c testWarehouse = TestFactory.createWarehouse('Test Warehouse', testUser1.Id, 'Test' , null, null, null, null, null);

        Account testAccount = new Account();
        testAccount.Name = 'Test Account 1';
        testAccount.Account_Type__c = 'None';
        testAccount.VIP_Account_Number__c = '201';
        testAccount.VIP_Instance__c = 'Test';
        testAccount.ExternalId__c = '72245';
        testAccount.Warehouse__c = 'Test Warehouse';
        testAccount.Store_Number__c = '12345';
        testAccount.recordTypeId = retailRecordTypeId;
        insert testAccount;

      	//Create a Call Task
      	Task newTask = new Task();
		newTask.Subject = 'Outbound Call';
        newTask.WhatId = testAccount.Id;
        newTask.OwnerId = testUser1.Id;
        newTask.ActivityDate = System.today() + 1;
        newTask.Description = 'Test Outbound Call';
        newTask.RecordTypeId = callTaskRecordTypeId;
		insert newTask;
        
        //Change the ISR on the Account
        Test.startTest();
        testWarehouse.ISR_1__c = testUser2.Id;
        update testWarehouse;
        Test.stopTest();
        
        //Assertions
        Task checkTask = [SELECT OwnerId FROM Task WHERE Subject = 'Outbound Call'];
        System.assertEquals(testUser2.Id, checkTask.OwnerId);
    }

}
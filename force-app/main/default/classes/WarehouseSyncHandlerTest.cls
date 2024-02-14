@IsTest
public with sharing class WarehouseSyncHandlerTest {

    @TestSetup
    private static void setup(){
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        UserRole preSalesRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Admin'];
        UserRole salesManagerRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Admin'];
        User testSalesManager = TestFactory.createUser(systemAdminProfile.Id, salesManagerRole.Id, 'newtest3User@gmail.com', null);
        User testSalesManager2 = TestFactory.createUser(systemAdminProfile.Id, salesManagerRole.Id, 'newtest4User@gmail.com', null);
        TestFactory.createUser(systemAdminProfile.Id, preSalesRole.Id, 'newtest2User@gmail.com', testSalesManager.Id);
    }

    @isTest
    static void testWarehouseLookupForNewAccount(){

        Id retailRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retail Store').getRecordTypeId();
        User testSalesManager = [SELECT Id FROM User WHERE username = 'newtest3User@gmail.com'];
        Warehouse__c testWarehouse = TestFactory.createWarehouse('PDC Warehouse', testSalesManager.Id, 'PDC' , null, null, null, null, null);

        Account testAccount = new Account();
        testAccount.Name = 'Test Account 1';
        testAccount.Account_Type__c = 'None';
        testAccount.VIP_Account_Number__c = '201';
        testAccount.VIP_Instance__c = 'PDC';
        testAccount.ExternalId__c = '72245';
        testAccount.Chain__c = 'FOOD LION';
        testAccount.Beer_Company__c = 'PDC';
        testAccount.Warehouse__c = 'PDC Warehouse';
        testAccount.Store_Number__c = '12345';
        testAccount.recordTypeId = retailRecordTypeId;
        testAccount.Territories__c = '10';
        insert testAccount;

        List<Account> accountDetails = AccountDAO.getAccountsByIds(new Set<Id>{testAccount.Id});


        System.assertEquals(testWarehouse.id, accountDetails[0].Warehouse_Lookup__c, 'the account should have the PDC Warehouse in the lookup'  );
    }

    @isTest
    static void testWarehouseLookupForChangedWarehouseAccount(){

        Id retailRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retail Store').getRecordTypeId();

        User testSalesManager = [SELECT Id FROM User WHERE username = 'newtest3User@gmail.com'];
        User testSalesManager2 = [SELECT Id FROM User WHERE username = 'newtest4User@gmail.com'];
       
        Warehouse__c testWarehouse1 = TestFactory.createWarehouse('PDC Warehouse', testSalesManager.Id, 'PDC' , null, null, null, null, null);
        Warehouse__c testWarehouse2 = TestFactory.createWarehouse('Huntington Beach Warehouse', testSalesManager2.Id, 'Huntington Beach ' , null, null, null, null, null);


        Account testAccount = new Account();
        testAccount.Name = 'Test Account 1';
        testAccount.Account_Type__c = 'None';
        testAccount.VIP_Account_Number__c = '201';
        testAccount.VIP_Instance__c = 'PDC';
        testAccount.ExternalId__c = '72245';
        testAccount.Chain__c = 'FOOD LION';
        testAccount.Beer_Company__c = 'PDC';
        testAccount.Warehouse__c = 'PDC Warehouse';
        testAccount.Store_Number__c = '12345';
        testAccount.recordTypeId = retailRecordTypeId;
        testAccount.Territories__c = '10';
        insert testAccount;

        testAccount.Warehouse__c = 'Huntington Beach Warehouse';
        update testAccount;

        List<Account> accountDetails = AccountDAO.getAccountsByIds(new Set<Id>{testAccount.Id});


        System.assertEquals(testWarehouse2.id, accountDetails[0].Warehouse_Lookup__c, 'the account should have the Huntington Beach Warehouse in the lookup' );
    }

	@isTest
    static void testWarehouseLookupForNewAccountNegative(){

        Id retailRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retail Store').getRecordTypeId();
        User testSalesManager = [SELECT Id FROM User WHERE username = 'newtest3User@gmail.com'];
        Warehouse__c testWarehouse = TestFactory.createWarehouse('PDC Warehouse', testSalesManager.Id, 'PDC' , null, null, null, null, null);

        Account testAccount = new Account();
        testAccount.Name = 'Test Account 1';
        testAccount.Account_Type__c = 'None';
        testAccount.VIP_Account_Number__c = '201';
        testAccount.VIP_Instance__c = 'PDC';
        testAccount.ExternalId__c = '72245';
        testAccount.Chain__c = 'FOOD LION';
        testAccount.Beer_Company__c = 'PDC';
        testAccount.Warehouse__c = 'PDC Warehousexx';   //Intentionaly misspelling Warehouse
        testAccount.Store_Number__c = '12345';
        testAccount.recordTypeId = retailRecordTypeId;
        testAccount.Territories__c = '10';
        insert testAccount;

        List<Account> accountDetails = AccountDAO.getAccountsByIds(new Set<Id>{testAccount.Id});


        System.assertEquals(null, accountDetails[0].Warehouse_Lookup__c, 'the account should not have the warehouse in the lookup'  );
    }
    
}
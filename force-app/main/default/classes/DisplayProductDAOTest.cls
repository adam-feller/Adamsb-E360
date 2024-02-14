@isTest
private class DisplayProductDAOTest {

    @TestSetup
    private static void setup(){
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        UserRole adminRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Admin'];
        User testSalesManager = TestFactory.createUser(systemAdminProfile.Id, adminRole.Id, 'newtest3User@gmail.com', null);
        TestFactory.createUser(systemAdminProfile.Id, adminRole.Id, 'newtest2User@gmail.com', testSalesManager.Id);

        System.runAs(testSalesManager){
            Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '12345');
            Product2 testProd = TestFactory.createProduct('Test Product', '12345', 'MillerCoors', '123*B');
        }
    }

    static Product2 getProduct(){
        return [SELECT Id, Name
                FROM Product2
                LIMIT 1];
    }

    static Account getAccount(String Name){
        return [SELECT Id, Name, VIP_Account_Number__c, Beer_Company__c, Warehouse__c
                FROM Account
                WHERE Name = :name
                LIMIT 1];
    }

    @isTest
    static void testFetchDisplayProduct(){
        Id processedDisplayProductRecordTypeId = Schema.SObjectType.Display_Product__c.getRecordTypeInfosByName().get('Processed').getRecordTypeId();
        Account testAccount = getAccount('Test Account');
        Product2 testProd = getProduct();
        Display_Product__c testDisplayProd = new Display_Product__c();
        testDisplayProd.RecordTypeId = processedDisplayProductRecordTypeId;
        testDisplayProd.Account__c = testAccount.Id;
        testDisplayProd.Product__c = testProd.Id;
        testDisplayProd.Start_Date__c = System.today() - 1;
        testDisplayProd.End_Date__c = System.today() + 1;
        insert testDisplayProd;

        Test.startTest();
            List<Display_Product__c> displayProductList = DisplayProductDAO.fetchDisplayProduct(new Set<Id>{testAccount.Id});
        Test.stopTest();

        System.assertEquals(displayProductList.size(), 1, '1 display product should be returned');
    }

    @isTest
    static void testFetchDisplayProductNullZeroCases(){
        Id processedDisplayProductRecordTypeId = Schema.SObjectType.Display_Product__c.getRecordTypeInfosByName().get('Processed').getRecordTypeId();
        Account testAccount = getAccount('Test Account');
        Product2 testProd = getProduct();
        Display_Product__c testDisplayProd = new Display_Product__c();
        testDisplayProd.RecordTypeId = processedDisplayProductRecordTypeId;
        testDisplayProd.Account__c = testAccount.Id;
        testDisplayProd.Product__c = testProd.Id;
        testDisplayProd.Start_Date__c = System.today() - 1;
        testDisplayProd.End_Date__c = System.today() + 1;
        insert testDisplayProd;

        Test.startTest();
            List<Display_Product__c> displayProductList = DisplayProductDAO.fetchDisplayProductNullZeroCases(new Set<Id>{testAccount.Id});
        Test.stopTest();

        System.assertEquals(displayProductList.size(), 1, '1 display product should be returned');
    }

    @isTest
    static void testGetBatchDisplayProducts(){
        Id batchDisplayProductRecordTypeId = Schema.SObjectType.Display_Product__c.getRecordTypeInfosByName().get('Batch').getRecordTypeId();
        Account testAccount = getAccount('Test Account');
        Product2 testProd = getProduct();
        Display_Product__c testDisplayProd = new Display_Product__c();
        testDisplayProd.RecordTypeId = batchDisplayProductRecordTypeId;
        testDisplayProd.Account__c = testAccount.Id;
        testDisplayProd.Product__c = testProd.Id;
        testDisplayProd.Start_Date__c = System.today() - 1;
        testDisplayProd.End_Date__c = System.today() + 1;
        insert testDisplayProd;

        Test.startTest();
            List<Display_Product__c> displayProductList = DisplayProductDAO.getBatchDisplayProducts(batchDisplayProductRecordTypeId);
        Test.stopTest();

        System.assertEquals(displayProductList.size(), 1, '1 display product should be returned');
    }

    @isTest
    static void testInsertDisplayProducts(){
        Account testAccount = getAccount('Test Account');
        Product2 testProd = getProduct();
        Display_Product__c testDisplayProd = new Display_Product__c();
        testDisplayProd.Account__c = testAccount.Id;
        testDisplayProd.Product__c = testProd.Id;

        Test.startTest();
            List<Display_Product__c> displayProductList = DisplayProductDAO.insertDisplayProducts(new List<Display_Product__c>{testDisplayProd});
        Test.stopTest();

        List<Display_Product__c> displayProductsReturned = [SELECT Id FROM Display_Product__c];

        System.assertEquals(displayProductsReturned.size(), 1, '1 display product should be returned');
    }

    @isTest
    static void testUpdateDisplayProducts(){
        Account testAccount = getAccount('Test Account');
        Product2 testProd = getProduct();
        Display_Product__c testDisplayProd = new Display_Product__c();
        testDisplayProd.Account__c = testAccount.Id;
        testDisplayProd.Product__c = testProd.Id;
        insert testDisplayProd;

        Test.startTest();
            List<Display_Product__c> displayProductList = DisplayProductDAO.updateDisplayProducts(new List<Display_Product__c>{testDisplayProd});
        Test.stopTest();

        List<Display_Product__c> displayProductsReturned = [SELECT Id FROM Display_Product__c];

        System.assertEquals(displayProductsReturned.size(), 1, '1 display product should be returned');
    }
    
    @isTest
    static void testDeleteProducts(){
        Account testAccount = getAccount('Test Account');
        Product2 testProd = getProduct();
        Display_Product__c testDisplayProd = new Display_Product__c();
        testDisplayProd.Account__c = testAccount.Id;
        testDisplayProd.Product__c = testProd.Id;
        insert testDisplayProd;

        Test.startTest();
            List<Display_Product__c> displayProductList = DisplayProductDAO.deleteDisplayProducts(new List<Display_Product__c>{testDisplayProd});
        Test.stopTest();

        List<Display_Product__c> displayProductsReturned = [SELECT Id FROM Display_Product__c];

        System.assertEquals(displayProductsReturned.size(), 0, '0 display product should be returned');
    }
    @isTest
    static void testFetchDisplayProductByUserId(){
        Id userId = userInfo.getUserId();
        Test.startTest();
            List<Display_Product__c> displayProductList = DisplayProductDAO.fetchDisplayProductByUserId(new Set<Id>{userId});
        Test.stopTest();

        System.assertEquals(displayProductList.size(), 0, '0 display product should be returned');
    }
    @isTest
    static void testFetchDisplayProductByProductNullZeroCasesCBS(){
        Id actId = [SELECT Id FROM Account LIMIT 1].Id;
        Test.startTest();
            List<Display_Product__c> displayProductList = DisplayProductDAO.fetchDisplayProductNullZeroCasesCBS(new Set<Id>{actId},new List<Integer> {1});
        Test.stopTest();

        System.assertEquals(displayProductList.size(), 0, '0 display product should be returned');
    }

}
@isTest
private class ScheduleBatchDisProdDSOFCreationTest {

    @TestSetup
    private static void setup(){
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        Product2 testProduct = TestFactory.createProduct('Test Product', '12345', 'MillerCoors', '123*B');
        Id batchDisplayProductRecordTypeId = Schema.SObjectType.Display_Product__c.getRecordTypeInfosByName().get('Batch').getRecordTypeId();
        TestFactory.createDisplayProduct(System.today() - 1, System.today() + 1, testAccount.Id, testProduct.Id, batchDisplayProductRecordTypeId);
        DSOF_Filters__c dsofFilters = new DSOF_Filters__c();
		dsofFilters.Name = 'DSOF Filters';
		dsofFilters.Account_Status__c = 'O,I';
        dsofFilters.Displayable_Status__c = 'Non-Displayable';
		insert dsofFilters;
        Product2 testBrandProduct = new Product2(Name = 'Test Brand', Brand_External_Id__c = '123*B', RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Brand').getRecordTypeId());
        insert testBrandProduct;
        Product2 testSubBrandProduct = new Product2(Name = 'Test Subbrand', Subbrand_External_Id__c	 = '123*B', RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Subbrand').getRecordTypeId());
        insert testSubBrandProduct;
    }

    static Display_Product__c getDisplayProduct(){
        return [SELECT Id, Name, Account__c, Product__c, Start_Date__c, End_Date__c, RecordTypeId, Product_Brand_Id__c, Chain__c, BU__c
                FROM Display_Product__c
                LIMIT 1];
    }

    static Account getAccount(String Name){
        return [SELECT Id, Name, VIP_Account_Number__c, Beer_Company__c, Warehouse__c, Territories__c
                FROM Account
                WHERE Name = :name
                LIMIT 1];
    }

    static Product2 getProduct(){
        return [SELECT Id, Name, SKU__c
                FROM Product2
                LIMIT 1];
    }
    
    static Product2 getBrandProduct(String Name){
        return [SELECT Id, Name, Brand_External_Id__c
                FROM Product2
                WHERE Name = :name
                LIMIT 1];
    }

    static Product2 getsubBrandProduct(String Name){
        return [SELECT Id, Name, Brand_External_Id__c
                FROM Product2
                WHERE Name = :name
                LIMIT 1];
    }

    public static String CRON_EXP = '0 0 0 15 3 ? 2099';

    @isTest
    static void testScheduleBatchDisplayProductDSOFCreation(){
        Product2 testProduct = getProduct();
        Product2 testBrand = getBrandProduct('Test Brand');
        Product2 testSubbrand = getsubBrandProduct('Test Subbrand');
        Account brewerAccount = getAccount('Test Account');
        testProduct.Brand_External_Id__c = 'DX*B';
        testProduct.Subbrand_External_Id__c = 'DX*B';
        testProduct.BrewerId__c = brewerAccount.Id;
        testProduct.BrandId__c = testBrand.Id;
        testProduct.Subbrandid__c = testSubbrand.Id;
        update testProduct;
        Display_Product__c testDisplayProduct = getDisplayProduct();
        testDisplayProduct.Product_Brand_Id__c = 'DX*B';
        testDisplayProduct.Chain__c = 'FOOD LION';
        testDisplayProduct.BU__c = 'PVA';
        testDisplayProduct.Sales_Org__c = 'PVA';
        update testDisplayProduct;
        Account testAccount = getAccount('Test Account');
        testAccount.SalesOrg__c = 'PVA';
        update testAccount;
        

        Test.startTest();
            String jobId = System.schedule('ScheduleApexClassTest',
                                           CRON_EXP, 
                                           new ScheduleBatchDisplayProductDSOFCreation());
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
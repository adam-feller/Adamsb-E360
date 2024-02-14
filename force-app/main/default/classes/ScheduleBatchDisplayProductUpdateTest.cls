@isTest
private class ScheduleBatchDisplayProductUpdateTest {

    @TestSetup
    private static void setup(){
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        Product2 testProduct = TestFactory.createProduct('Test Product', '12345', 'MillerCoors', '123*B');
        Id batchDisplayProductRecordTypeId = Schema.SObjectType.Display_Product__c.getRecordTypeInfosByName().get('Batch').getRecordTypeId();
        TestFactory.createDisplayProduct(System.today() - 1, System.today() + 1, testAccount.Id, testProduct.Id, batchDisplayProductRecordTypeId);
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
        return [SELECT Id, Name, SKU__c, Subbrand_External_Id__c
                FROM Product2
                LIMIT 1];
    }

    public static String CRON_EXP = '0 0 0 15 3 ? 2099';

    @isTest
    static void testScheduleBatchDisplayProductDSOFUpdate(){
        Account testAccount = getAccount('Test Account');
        Product2 testProduct = getProduct();
        testProduct.Brand_External_Id__c = 'DX*B';
        testProduct.Subbrand_External_Id__c = 'DX*B';
        update testProduct;
        Display_Product__c testDisplayProduct = getDisplayProduct();
        testDisplayProduct.Product_Brand_Id__c = 'DX*B';
        testDisplayProduct.Chain__c = 'FOOD LION';
        testDisplayProduct.BU__c = 'PVA';
        testDisplayProduct.Processed__c = true;
        testDisplayProduct.Batch_Processed_DateTime__c = System.today() + 1;
        update testDisplayProduct;
        
        Id processedDisplayProductRecordTypeId = Schema.SObjectType.Display_Product__c.getRecordTypeInfosByName().get('Processed').getRecordTypeId();
        TestFactory.createDisplayProduct(System.today() - 1, System.today() + 1, testAccount.Id, testProduct.Id, processedDisplayProductRecordTypeId);

        Test.startTest();
            String jobId = System.schedule('ScheduleApexClassTest',
                                           CRON_EXP, 
                                           new ScheduleBatchDisplayProductUpdate());
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
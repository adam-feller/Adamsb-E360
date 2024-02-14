@isTest
private class BatchDisplayProductUpdateTest {

    @TestSetup
    private static void setup(){
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        Product2 testProduct = TestFactory.createProduct('Test Product', '12345', 'MillerCoors', '123*B');
        Id batchDisplayProductRecordTypeId = Schema.SObjectType.Display_Product__c.getRecordTypeInfosByName().get('Batch').getRecordTypeId();
        TestFactory.createDisplayProduct(System.today() - 1, System.today() + 1, testAccount.Id, testProduct.Id, batchDisplayProductRecordTypeId);
    }

    static Display_Product__c getDisplayProduct(){
        return [SELECT Id, Name, Account__c, Product__c, Start_Date__c, End_Date__c, RecordTypeId, Product_Brand_Id__c, Chain__c, BU__c,
                Ad_Price__c, Family_Brand_Pack__c, Parent_Display_Product__c, Percentage__c, Primary_Secondary__c
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

    @isTest
    static void testScheduleBatchDisplayProductDSOFCreation(){
        Account testAccount = getAccount('Test Account');
        Product2 testProduct = getProduct();
        testProduct.Brand_External_Id__c = 'DX*B';
        update testProduct;
        Display_Product__c testDisplayProduct = getDisplayProduct();
        testDisplayProduct.Product_Brand_Id__c = 'DX*B';
        testDisplayProduct.Chain__c = 'FOOD LION';
        testDisplayProduct.BU__c = 'PVA';
        testDisplayProduct.Processed__c = true;
        testDisplayProduct.Batch_Processed_DateTime__c = System.today() + 1;

        update testDisplayProduct;
        Id processedDisplayProductRecordTypeId = Schema.SObjectType.Display_Product__c.getRecordTypeInfosByName().get('Processed').getRecordTypeId();
        Display_Product__c testDisProd = TestFactory.createDisplayProduct(System.today() - 1, System.today() + 1, testAccount.Id, testProduct.Id, processedDisplayProductRecordTypeId);
        testDisProd.Parent_Display_Product__c = testDisplayProduct.Id;
        update testDisProd;
        

        Test.startTest();
            BatchDisplayProductUpdate batchDisplayProductUpdate = new BatchDisplayProductUpdate();
            batchDisplayProductUpdate.query = 'SELECT Id, Ad_Price__c, End_Date__c, Start_Date__c, Parent_Display_Product__c, Family_Brand_Pack__c,' +
                                    ' Percentage__c, Primary_Secondary__c' +
                                    ' FROM Display_Product__c' + 
                                    ' WHERE Parent_Display_Product__c IN :existingParentDisplayProductIds';
            batchDisplayProductUpdate.updateDisplayProductMap = new Map<String, Display_Product__c>{testDisplayProduct.Id => testDisplayProduct};
            batchDisplayProductUpdate.existingParentDisplayProductIds = new Set<Id>{testDisplayProduct.Id};
            batchDisplayProductUpdate.productMap = new Map<String, Id>{'DX*B' => testProduct.Id};
            batchDisplayProductUpdate.productTerritoriesMap = new Map<String, Set<String>>{'DX*B' => new Set<String>{'10'}};
            Database.executebatch(batchDisplayProductUpdate);
        Test.stopTest();

        Id processedDisplayProductRecordId = Schema.SObjectType.Display_Product__c.getRecordTypeInfosByName().get('Processed').getRecordTypeId();
        List<Display_Product__c> displayproductsCreated = [SELECT Id FROM Display_Product__c WHERE RecordTypeId = :processedDisplayProductRecordId];

        System.assertEquals(displayproductsCreated.size(), 1, '1 display product record should be created');
    }
    
     @isTest
    static void testScheduleBatchDisplayProductDSOFCreationTerritories(){
        Account testAccount = getAccount('Test Account');
        Product2 testProduct = getProduct();
        testProduct.Brand_External_Id__c = 'DX*B';
        update testProduct;
        Display_Product__c testDisplayProduct = getDisplayProduct();
        testDisplayProduct.Product_Brand_Id__c = 'DX*B';
        testDisplayProduct.Chain__c = 'FOOD LION';
        testDisplayProduct.BU__c = 'PVA';
        testDisplayProduct.Processed__c = true;
        testDisplayProduct.Batch_Processed_DateTime__c = System.today() + 1;
        
        Territory_Matching__c terrMatchingCustomSetting = new Territory_Matching__c();
        terrMatchingCustomSetting.Territory_Matching__c = true;
        insert terrMatchingCustomSetting;

        update testDisplayProduct;
        Id processedDisplayProductRecordTypeId = Schema.SObjectType.Display_Product__c.getRecordTypeInfosByName().get('Processed').getRecordTypeId();
        Display_Product__c testDisProd = TestFactory.createDisplayProduct(System.today() - 1, System.today() + 1, testAccount.Id, testProduct.Id, processedDisplayProductRecordTypeId);
        testDisProd.Parent_Display_Product__c = testDisplayProduct.Id;
        update testDisProd;
        

        Test.startTest();
            BatchDisplayProductUpdate batchDisplayProductUpdate = new BatchDisplayProductUpdate();
            batchDisplayProductUpdate.query = 'SELECT Id, Ad_Price__c, End_Date__c, Start_Date__c, Parent_Display_Product__c, Family_Brand_Pack__c,' +
                                    ' Percentage__c, Primary_Secondary__c' +
                                    ' FROM Display_Product__c' + 
                                    ' WHERE Parent_Display_Product__c IN :existingParentDisplayProductIds';
            batchDisplayProductUpdate.updateDisplayProductMap = new Map<String, Display_Product__c>{testDisplayProduct.Id => testDisplayProduct};
            batchDisplayProductUpdate.existingParentDisplayProductIds = new Set<Id>{testDisplayProduct.Id};
            batchDisplayProductUpdate.productMap = new Map<String, Id>{'DX*B' => testProduct.Id};
            batchDisplayProductUpdate.productTerritoriesMap = new Map<String, Set<String>>{'DX*B' => new Set<String>{'10'}};
            Database.executebatch(batchDisplayProductUpdate);
        Test.stopTest();

        Id processedDisplayProductRecordId = Schema.SObjectType.Display_Product__c.getRecordTypeInfosByName().get('Processed').getRecordTypeId();
        List<Display_Product__c> displayproductsCreated = [SELECT Id FROM Display_Product__c WHERE RecordTypeId = :processedDisplayProductRecordId];

        System.assertEquals(displayproductsCreated.size(), 1, '1 display product record should be created');
    }
}
@isTest
private class BatchDisplayProductDSOFCreationTest {

    @TestSetup
    private static void setup(){
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        Product2 testProduct = TestFactory.createProduct('Test Product', '12345', 'MillerCoors', '123*B');
        Id batchDisplayProductRecordTypeId = Schema.SObjectType.Display_Product__c.getRecordTypeInfosByName().get('Batch').getRecordTypeId();
        TestFactory.createDisplayProduct(System.today() - 1, System.today() + 1, testAccount.Id, testProduct.Id, batchDisplayProductRecordTypeId);
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
        return [SELECT Id, Name, SalesOrg__c, VIP_Account_Number__c, Beer_Company__c, Warehouse__c, Territories__c
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

    @isTest
    static void testScheduleBatchDisplayProductDSOFCreation(){
        Product2 testProduct = getProduct();
        Product2 testBrand = getBrandProduct('Test Brand');
        Product2 testSubbrand = getsubBrandProduct('Test Subbrand');
        Account brewerAccount = getAccount('Test Account');
        testProduct.Brand_External_Id__c = 'DX*B';
        testProduct.BrewerId__c = brewerAccount.Id;
        testProduct.BrandId__c = testBrand.Id;
        testProduct.Subbrandid__c = testSubbrand.Id;
        update testProduct;
        testSubbrand.BrandId__c = testBrand.Id;
        update testSubbrand;
        Display_Product__c testDisplayProduct = getDisplayProduct();
        testDisplayProduct.Product_Brand_Id__c = 'DX*B';
        testDisplayProduct.Chain__c = 'FOOD LION';
        testDisplayProduct.BU__c = 'PVA';
        testDisplayProduct.Sales_Org__c = 'PVA';
        update testDisplayProduct;
        Account testAccount = getAccount('Test Account');
        testAccount.SalesOrg__c = 'PVA';
        update testAccount;
        Territory_Matching__c terrMatchingCustomSetting = new Territory_Matching__c();
        terrMatchingCustomSetting.Territory_Matching__c = false;
        insert terrMatchingCustomSetting;

        Test.startTest();
            BatchDisplayProductDSOFCreation batchDisplayproducts = new BatchDisplayProductDSOFCreation();
            batchDisplayproducts.query = 'SELECT Id, Name, Beer_Company__c, Warehouse__c, VIP_Account_Number__c, VIP_Instance__c, Visit_Completed__c, Chain_Independent__c,' +
                                        ' ExternalId__c, VIP_Composite_Key__c, OwnerId, Territories__c, Chain__c, SalesOrg__c' +
                                        ' FROM Account' + 
                                        ' WHERE VIP_Instance__c IN :accountBus' +
                                        ' AND Chain__c IN :accountChains';
            batchDisplayproducts.uploadedDisplayProducts = new List<Display_Product__c>{testDisplayProduct};
            batchDisplayproducts.displayProductMapBU = new Map<String, List<Display_Product__c>>{'PVAFOOD LION' => new List<Display_Product__c>{testDisplayProduct}};
            batchDisplayproducts.displayProductMapSalesOrg = new Map<String, List<Display_Product__c>>{'PVAFOOD LION' => new List<Display_Product__c>{testDisplayProduct}};
            batchDisplayproducts.accountChains = new Set<String>{'FOOD LION'};
            batchDisplayproducts.accountBus = new Set<String>{'PVA'};
            batchDisplayproducts.productMap = new Map<String, Id>{'DX*B' => testProduct.Id};
            batchDisplayproducts.brandMap = new Map<String, Id>{'DX*B' => testBrand.Id};
            batchDisplayproducts.subBrandMap = new Map<String, Id>{'DX*B' => testSubbrand.Id};
            batchDisplayproducts.brewerMap = new Map<String, Id>{'DX*B' => testProduct.BrewerId__c};
            batchDisplayproducts.productTerritoriesMap = new Map<String, Set<String>>{'DX*B' => new Set<String>{'10'}};
            Database.executebatch(batchDisplayproducts);
        Test.stopTest();

        Id processedDisplayProductRecordId = Schema.SObjectType.Display_Product__c.getRecordTypeInfosByName().get('Processed').getRecordTypeId();
        List<Display_Product__c> displayproductsCreated = [SELECT Id FROM Display_Product__c WHERE RecordTypeId = :processedDisplayProductRecordId];

        System.assertEquals(displayproductsCreated.size(), 2, '2 display product records should be created');
    }

    @isTest
    static void testScheduleBatchDisplayProductDSOFCreationTerritoryMatching(){
        Product2 testProduct = getProduct();
        Product2 testBrand = getBrandProduct('Test Brand');
        Product2 testSubbrand = getsubBrandProduct('Test Subbrand');
        Account brewerAccount = getAccount('Test Account');
        testProduct.Brand_External_Id__c = 'DX*B';
        testProduct.Brand_External_Id__c = 'DX*B';
        testProduct.BrewerId__c = brewerAccount.Id;
        testProduct.BrandId__c = testBrand.Id;
        testProduct.Subbrandid__c = testSubbrand.Id;
        update testProduct;
        testSubbrand.BrandId__c = testBrand.Id;
        update testSubbrand;
        Display_Product__c testDisplayProduct = getDisplayProduct();
        testDisplayProduct.Product_Brand_Id__c = 'DX*B';
        testDisplayProduct.Chain__c = 'FOOD LION';
        testDisplayProduct.BU__c = 'PVA';
        update testDisplayProduct;
        Territory_Matching__c terrMatchingCustomSetting = new Territory_Matching__c();
        terrMatchingCustomSetting.Territory_Matching__c = true;
        insert terrMatchingCustomSetting;

        Test.startTest();
            BatchDisplayProductDSOFCreation batchDisplayproducts = new BatchDisplayProductDSOFCreation();
            batchDisplayproducts.query = 'SELECT Id, Name, Beer_Company__c, Warehouse__c, VIP_Account_Number__c, VIP_Instance__c, Visit_Completed__c, Chain_Independent__c,' +
                                        ' ExternalId__c, VIP_Composite_Key__c, OwnerId, Territories__c, Chain__c, SalesOrg__c' +
                                        ' FROM Account' + 
                                        ' WHERE VIP_Instance__c IN :accountBus' +
                                        ' AND Chain__c IN :accountChains';
            batchDisplayproducts.uploadedDisplayProducts = new List<Display_Product__c>{testDisplayProduct};
            batchDisplayproducts.displayProductMapBU = new Map<String, List<Display_Product__c>>{'PVAFOOD LION' => new List<Display_Product__c>{testDisplayProduct}};
            batchDisplayproducts.displayProductMapSalesOrg = new Map<String, List<Display_Product__c>>{'PVAFOOD LION' => new List<Display_Product__c>{testDisplayProduct}};
            batchDisplayproducts.accountChains = new Set<String>{'FOOD LION'};
            batchDisplayproducts.accountBus = new Set<String>{'PVA'};
            batchDisplayproducts.productMap = new Map<String, Id>{'DX*B' => testProduct.Id};
            batchDisplayproducts.productMap = new Map<String, Id>{'DX*B' => testProduct.Id};
            batchDisplayproducts.brandMap = new Map<String, Id>{'DX*B' => testBrand.Id};
            batchDisplayproducts.subBrandMap = new Map<String, Id>{'DX*B' => testSubbrand.Id};
            batchDisplayproducts.brewerMap = new Map<String, Id>{'DX*B' => testProduct.BrewerId__c};
            batchDisplayproducts.productTerritoriesMap = new Map<String, Set<String>>{'DX*B' => new Set<String>{'10'}};
            Database.executebatch(batchDisplayproducts);
        Test.stopTest();

        Id processedDisplayProductRecordId = Schema.SObjectType.Display_Product__c.getRecordTypeInfosByName().get('Processed').getRecordTypeId();
        List<Display_Product__c> displayproductsCreated = [SELECT Id FROM Display_Product__c WHERE RecordTypeId = :processedDisplayProductRecordId];

        System.assertEquals(displayproductsCreated.size(), 1, '1 display product record should be created');
    }
}
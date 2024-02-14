@isTest
private class ProductDAOTest {

    @TestSetup
    private static void setup() {
        TestFactory.createProduct('Test Product', '12345', 'MillerCoors', '123*B');
    }

    static Product2 getProduct() {
        return [SELECT Id, Name FROM Product2 LIMIT 1];
    }

    @isTest
    static void testGetProductByBrandNames(){
        Test.startTest();
            List<Product2> productList = ProductDAO.getProductByBrandNames(new List<String>{'MillerCoors'});
        Test.stopTest();

        System.assertEquals(1, productList.size(), 'productList should return 1 record');
    }

    @isTest
    static void testGetProductByIds(){
        Product2 testProduct = getProduct();

        Test.startTest();
            List<Product2> productList = ProductDAO.getProductByIds(new Set<String>{testProduct.Id});
        Test.stopTest();

        System.assertEquals(1, productList.size(), 'productList should return 1 record');
    }

    @isTest
    static void testGetProductByExternalIds(){
        Product2 testProduct = getProduct();

        Test.startTest();
            List<Product2> productList = ProductDAO.getProductByExternalIds(new Set<String>{'123*B'});
        Test.stopTest();

        System.assertEquals(1, productList.size(), 'productList should return 1 record');
    }
    
    @isTest
    static void getProductByExternalIdsCBS() {
        Product2 testProduct = getProduct();

        Test.startTest();
        List<Product2> productList = ProductDAO.getProductByExternalIdsCBS(new Set<String>{'123*B'}, new List<Integer>{1});
        Test.stopTest();

        System.assertEquals(0, productList.size(), 'productList should return 0 record');
    }

    @isTest
    static void testGetProductByIdSubBrandBrand(){
        Id skuProductRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('SKU').getRecordTypeId();
        Product2 testProduct = getProduct();
        testProduct.RecordTypeId = skuProductRecordTypeId;
        update testProduct;

        Test.startTest();
            List<Product2> productList = ProductDAO.getProductByIdSubBrandBrand(new Set<String>{testProduct.Id}, null, null, skuProductRecordTypeId);
        Test.stopTest();

        System.assertEquals(1, productList.size(), 'productList should return 1 record');
    }
    
    
    @isTest
    static void getProductBySubBrandExternalIdsCBS() {
        Id skuProductRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('SKU').getRecordTypeId();
        Product2 testProduct = getProduct();
        testProduct.RecordTypeId = skuProductRecordTypeId;
        update testProduct;

        Test.startTest();
            List<Product2> productList = ProductDAO.getProductBySubBrandExternalIdsCBS(new Set<String>{'123*B'}, new List<Integer>{1});
        Test.stopTest();

        System.assertEquals(0, productList.size(), 'productList should return 0 record');
    }

    @isTest
    static void testGetProductByBrandExternalIds() {
        Product2 testProduct = getProduct();
        testProduct.Brand_External_Id__c = '123*B';
        update testProduct;

        Test.startTest();
            List<Product2> productList = ProductDAO.getProductByBrandExternalIds(new Set<String>{'123*B'});
        Test.stopTest();

        System.assertEquals(1, productList.size(), 'productList should return 1 record');
    }
    
    @isTest
    static void getProductByBrandExternalIdsCBS() {
        Product2 testProduct = getProduct();
        testProduct.Brand_External_Id__c = '123*B';
        update testProduct;

        Test.startTest();
            List<Product2> productList = ProductDAO.getProductByBrandExternalIdsCBS(new Set<String>{'123*B'}, new List<Integer>{1});
        Test.stopTest();

        System.assertEquals(0, productList.size(), 'productList should return 0 record');
    }

    @isTest
    static void testGetProductBySubBrandExternalIds() {
        Product2 testProduct = getProduct();
        testProduct.Subbrand_External_Id__c = '1234*B';
        update testProduct;

        Test.startTest();
            List<Product2> productList = ProductDAO.getProductBySubBrandExternalIds(new Set<String>{'1234*B'});
        Test.stopTest();

        System.assertEquals(1, productList.size(), 'productList should return 1 record');
    }
    
    @isTest
    static void getBrandByBrandExternalIds() {
        Id brandProductRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Brand').getRecordTypeId();
        Product2 testProduct = getProduct();
        testProduct.Brand_External_Id__c = '1234*B';
        testProduct.RecordTypeId = brandProductRecordTypeId;
        update testProduct;
        

        Test.startTest();
            List<Product2> productList = ProductDAO.getBrandByBrandExternalIds(new Set<String>{'1234*B'}, brandProductRecordTypeId);
        Test.stopTest();

        System.assertEquals(1, productList.size(), 'productList should return 1 record');
    }
    
    @isTest
    static void getAllActiveSKUProducts() {    

        Test.startTest();
            List<Product2> productList = ProductDAO.getAllActiveSKUProducts();
        Test.stopTest();

        System.assertEquals(1, productList.size(), 'productList should return 1 record');
    }
}
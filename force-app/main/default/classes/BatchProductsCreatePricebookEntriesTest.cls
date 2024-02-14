@isTest
private class BatchProductsCreatePricebookEntriesTest {
    
@TestSetup
    private static void setup(){
        TestFactory.createProduct('Test Product Batch', '12345999', 'MillerCoorsTest', '123*B999');
    }
    
    static Product2 getProduct(){
        return [SELECT Id, Name
                FROM Product2
                LIMIT 1];
    }
    
    static testMethod void BatchProductPBE(){
        Product2 testProduct = getProduct();
        testProduct.IsActive = true;
        update testProduct;
        
        Test.startTest();
        BatchProductsCreatePricebookEntries ba= new BatchProductsCreatePricebookEntries();
        Id jobid= Database.executeBatch(ba,5);
        Test.stopTest();
        List<PricebookEntry> pricebookEntryList = PriceBookEntryDAO.getStandardPriceBookEntryByProduct(testProduct.Id);
        
        System.assertEquals(pricebookEntryList.size(), 1, 'pricebookEntryList should return 1 record');
    }
}
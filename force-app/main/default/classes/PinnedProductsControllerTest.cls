@isTest
private class PinnedProductsControllerTest {

    @TestSetup
    private static void setup() {
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2346');
        Pricebook2 testPriceBook = TestFactory.createPriceBook(testAccount.Id, testAccount.Name, true, 'Account Pricebook');
        Pricebook2 testStandardPriceBook = TestFactory.createStandardPriceBook();
        Product2 testProd = TestFactory.createProduct('Test Product', '12345', 'MillerCoors', '123*B');
        Product2 testProd2 = TestFactory.createProduct('Test Product2', '12346', 'Coors', '124*B');        
        Order testOrder = TestFactory.createOrder(testAccount.Id, testPriceBook.Id, System.today(), 'Pending Draft');
    }

    static Order getOrder() {
        return [SELECT Id, Name, Status, Pricebook2Id, AccountId
                FROM Order
                LIMIT 1];
    }

    static Product2 getProductByName(String name) {
        return [SELECT Id, QuantityUnitOfMeasure
                FROM Product2
                WHERE Name = :name
                LIMIT 1];
    }
    
    static Account getAccount() {
        return [SELECT Id, Name, Chain_Independent__c, ExternalId__c, VIP_Instance__c, VIP_Account_Number__c, Require_PO__c,
                Status__c, LicenseExpirationDate__c, Territories__c
                FROM Account
                LIMIT 1];
    }
    
    @isTest
    static void testCreatePinnedProduct() {
        Account testAccount = getAccount();
        Product2 testProduct = getProductByName('Test Product');        

        Test.startTest();   
            OrderEntryController.AccountPricebookProducts testPriceBookEntries = PinnedProductsController.createPinnedProduct(null, testAccount.Id, testProduct.Id, 'test', System.today(), 'feedback', null);
        Test.stopTest();

        System.assertEquals('test', testPriceBookEntries.pinnedNotes, 'Should have found the pinned notes value');
    }
    
    @isTest
    static void testCreatePinnedProductByOrder() {
        Order testOrder = getOrder();
        Product2 testProduct = getProductByName('Test Product'); 

        Test.startTest();   
            OrderEntryController.AccountPricebookProducts testPriceBookEntries = PinnedProductsController.createPinnedProduct(testOrder.Id, null, testProduct.Id, 'test', System.today(), 'feedback', null);
        Test.stopTest();

        System.assertEquals('test', testPriceBookEntries.pinnedNotes, 'Should have found the pinned notes value');
    }
    
    @isTest
    static void testCreatePinnedProductAlreadyExists() {
        Account testAccount = getAccount();
        Product2 testProduct = getProductByName('Test Product');
        Product_Feedback__c pinnedProduct = new Product_Feedback__c(Account__c = testAccount.Id, Product__c = testProduct.Id, Expiration_Date__c = System.today() + 30, Type__c = 'Pinned', Notes__c = 'test');
		insert pinnedProduct;
        
        Test.startTest();   
            OrderEntryController.AccountPricebookProducts testPriceBookEntries = PinnedProductsController.createPinnedProduct(null, testAccount.Id, testProduct.Id, 'test', System.today()+30, 'feedback', null);
        Test.stopTest();

        System.assertEquals('test', testPriceBookEntries.pinnedNotes, 'Should have found the pinned notes value');
    }
    
    @isTest
    static void testUpdatePinnedProduct() {
        Account testAccount = getAccount();
        Product2 testProduct = getProductByName('Test Product');
        Product_Feedback__c pinnedProduct = new Product_Feedback__c(Account__c = testAccount.Id, Product__c = testProduct.Id, Expiration_Date__c = System.today()+30, Type__c = 'Pinned', Notes__c = 'test');
		insert pinnedProduct;
        
        Test.startTest();   
            OrderEntryController.AccountPricebookProducts testPriceBookEntries = PinnedProductsController.createPinnedProduct(null, testAccount.Id, testProduct.Id, 'test2', System.today()+30, 'feedback', pinnedProduct.Id);
        Test.stopTest();

        System.assertEquals('test2', testPriceBookEntries.pinnedNotes, 'Should have found the updated pinned notes value');
    }

    @isTest
    static void testGetPinnedProducts() {
        Account testAccount = getAccount();        
        Product2 testProduct = getProductByName('Test Product2');
		Product_Feedback__c pinnedProduct = new Product_Feedback__c(Account__c = testAccount.Id, Product__c = testProduct.Id, Expiration_Date__c = System.today()+30, Type__c = 'Pinned', Notes__c = 'test');        
        insert pinnedProduct;

        Test.startTest();
            List<Product_Feedback__c> testProductFeedback = PinnedProductsController.getPinnedProducts(testAccount.Id);
        Test.stopTest();

        System.assertEquals(1, testProductFeedback.size(), '1 record should be returned');
    }

    @isTest
    static void testUpdatePinnedProductToHidden() {
        Account testAccount = getAccount();
        Product2 testProduct = getProductByName('Test Product2');
		Product_Feedback__c pinnedProduct = new Product_Feedback__c(Account__c = testAccount.Id, Product__c = testProduct.Id, Expiration_Date__c = System.today()+30, Type__c = 'Pinned', Notes__c = 'test');        
        insert pinnedProduct;
       
        Test.startTest();
            List<Product_Feedback__c> testPinnedProduct = PinnedProductsController.updatePinnedProductToHidden(new List<String>{testProduct.Id}, testAccount.Id, null, 'feedback');
        Test.stopTest();

        System.assertEquals(true, testPinnedProduct[0].IsHidden__c, 'IsHidden__c should be true');
    }

	@isTest
    static void testUpdatePinnedProductToHiddenByOrder() {
        Account testAccount = getAccount();
        Order testOrder = getOrder();
        Product2 testProduct = getProductByName('Test Product2');
		Product_Feedback__c pinnedProduct = new Product_Feedback__c(Account__c = testAccount.Id, Product__c = testProduct.Id, Expiration_Date__c = System.today()+30, Type__c = 'Pinned', Notes__c = 'test');        
        insert pinnedProduct;
       
        Test.startTest();
            List<Product_Feedback__c> testPinnedProduct = PinnedProductsController.updatePinnedProductToHidden(new List<String>{testProduct.Id}, null, testOrder.Id, 'feedback');
        Test.stopTest();

        System.assertEquals(true, testPinnedProduct[0].IsHidden__c, 'IsHidden__c should be true');
    }
}
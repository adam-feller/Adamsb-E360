@isTest
private class PriceBookEntryDAOTest {

    @TestSetup
    private static void setup(){
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2346');
        Pricebook2 testPriceBook = TestFactory.createPriceBook(testAccount.Id, testAccount.Name, true, 'Account Pricebook');
        Pricebook2 testStandardPriceBook = TestFactory.createStandardPriceBook();
        Product2 testProd = TestFactory.createProduct('Test Product', '12345', 'MillerCoors', '123*B');
        Product2 testProd2 = TestFactory.createProduct('Test Product 2', '12345', 'MillerCoors', '124*B');
        TestFactory.createPriceBookEntry(testStandardPriceBook.Id, testProd.Id, 12.99, false, true);
        TestFactory.createPriceBookEntry(testStandardPriceBook.Id, testProd2.Id, 12.99, false, true);
        PriceBookEntry testPriceBookEntry = TestFactory.createPriceBookEntry(testPriceBook.Id, testProd.Id, 12.99, false, true);
        testPriceBookEntry.Expiration_Date__c = System.today() + 7;
        update testPriceBookEntry;
    }

    static Product2 getProduct(String name){
        return [SELECT Id, Name
                FROM Product2
                WHERE Name = :name
                LIMIT 1];
    }

    static PriceBook2 getPriceBook(){
        return [SELECT Id, Name
                FROM PriceBook2
                WHERE IsStandard = false
                LIMIT 1];
    }

    static PriceBookEntry getPriceBookEntry(){
        return [SELECT Id, Name, Pinned_Notes__c
                FROM PriceBookEntry
                LIMIT 1];
    }

    @isTest
    static void testGetStandardPriceBookEntryByProduct(){
        Product2 testProd = getProduct('Test Product');

        Test.startTest();
            List<PricebookEntry> pricebookEntryList = PriceBookEntryDAO.getStandardPriceBookEntryByProduct(testProd.Id);
        Test.stopTest();

        System.assertEquals(pricebookEntryList.size(), 1, 'pricebookEntryList should return 1 record');
    }

    @isTest
    static void testGetPriceBookEntryByProductAndId(){
        Product2 testProd = getProduct('Test Product');
        PriceBook2 testPriceBook = getPriceBook();

        Test.startTest();
            List<PricebookEntry> pricebookEntryList = PriceBookEntryDAO.getPriceBookEntryByProductAndId(testProd.Id, testPriceBook.Id);
        Test.stopTest();

        System.assertEquals(pricebookEntryList.size(), 1, 'pricebookEntryList should return 1 record');
    }

    @isTest
    static void testGetPriceBookEntryByPriceBookAndProduct(){
        Product2 testProd = getProduct('Test Product');
        PriceBook2 testPriceBook = getPriceBook();

        Test.startTest();
            List<PricebookEntry> pricebookEntryList = PriceBookEntryDAO.getPriceBookEntryByPriceBookAndProduct(testPriceBook.Id, testProd.Id);
        Test.stopTest();

        System.assertEquals(pricebookEntryList.size(), 1, 'pricebookEntryList should return 1 record');
    }

    @isTest
    static void testGetPriceBookEntryByPriceBookAndExpirationDateHidden(){
        PriceBook2 testPriceBook = getPriceBook();

        Test.startTest();
            List<PricebookEntry> pricebookEntryList = PriceBookEntryDAO.getPriceBookEntryByPriceBookAndExpirationDateHidden(testPriceBook.Id, false, System.today());
        Test.stopTest();

        System.assertEquals(pricebookEntryList.size(), 1, 'pricebookEntryList should return 1 record');
    }

    @isTest
    static void testInsertPriceBookEntries(){
        Product2 testProd = getProduct('Test Product 2');
        PriceBook2 testPriceBook = getPriceBook();
        PricebookEntry testPriceBookEntry = new PricebookEntry();
        testPriceBookEntry.Pricebook2Id = testPriceBook.Id;
        testPriceBookEntry.Product2Id = testProd.Id;
        testPriceBookEntry.UnitPrice = 12.99;
        testPriceBookEntry.UseStandardPrice = false;
        testPriceBookEntry.IsActive = true;

        Test.startTest();
            List<PricebookEntry> pricebookEntryList = PriceBookEntryDAO.insertPriceBookEntries(new List<PricebookEntry>{testPriceBookEntry});
        Test.stopTest();

        System.assertEquals(pricebookEntryList.size(), 1, 'pricebookEntryList should return 1 record');
    }

    @isTest
    static void testUpdatePriceBookEntries(){
        PricebookEntry testPricebookEntry = getPriceBookEntry();
        testPricebookEntry.Pinned_Notes__c = 'test notes';

        Test.startTest();
            List<PricebookEntry> pricebookEntryList = PriceBookEntryDAO.updatePriceBookEntries(new List<PricebookEntry>{testPriceBookEntry});
        Test.stopTest();

        System.assertEquals(pricebookEntryList[0].Pinned_Notes__c, 'test notes', 'Notes should be test notes');
    }
}
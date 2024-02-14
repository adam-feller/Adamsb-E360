@isTest
private class PriceBookDAOTest {

    @TestSetup
    private static void setup(){
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2346');
        Pricebook2 testPriceBook = TestFactory.createPriceBook(testAccount.Id, testAccount.Name, true, 'Account Pricebook');
        Pricebook2 testStandardPriceBook = TestFactory.createStandardPriceBook();
    }

    static Account getAccount(){
        return [SELECT Id, Name
                FROM Account
                LIMIT 1];
    }

    @isTest
    static void testGetPriceBookByAccountIds(){
        Account testAccount = getAccount();

        Test.startTest();
            List<Pricebook2> pricebookList = PriceBookDAO.getPriceBookByAccountIds(new Set<Id>{testAccount.Id});
        Test.stopTest();

        System.assertEquals(pricebookList.size(), 1, 'pricebookList should return 1 record');
    }

    @isTest
    static void testGetStandardPriceBook(){
        Test.startTest();
            List<Pricebook2> pricebookList = PriceBookDAO.getStandardPriceBook();
        Test.stopTest();

        System.assertEquals(pricebookList.size(), 1, 'pricebookList should return 1 record');
    }

    @isTest
    static void testInsertPriceBooks(){
        Account testAccount = getAccount();
        Pricebook2 testPriceBook = new Pricebook2();
        testPriceBook.Name = 'Test Pricebook';
        testPriceBook.Description = 'Test';
        testPriceBook.IsActive = true;
        testPriceBook.AccountId__c = testAccount.Id;

        Test.startTest();
            List<Pricebook2> pricebookList = PriceBookDAO.insertPriceBooks(new List<Pricebook2>{testPriceBook});
        Test.stopTest();

        System.assertEquals(pricebookList.size(), 1, 'pricebookList should return 1 record');
    }
}
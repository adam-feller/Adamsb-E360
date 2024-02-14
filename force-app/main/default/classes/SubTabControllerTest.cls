@isTest
private class SubTabControllerTest {

    @TestSetup
    private static void setup(){
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2346');
        Pricebook2 testPriceBook = TestFactory.createPriceBook(testAccount.Id, testAccount.Name, true, 'Account Pricebook');
        TestFactory.createOrder(testAccount.Id, testPriceBook.Id, System.today(), 'Pending Draft');
    }

    static Order getOrder(){
        return [SELECT Id, Name, EffectiveDate
                FROM Order
                LIMIT 1];
    }

    static Account getAccount(){
        return [SELECT Id, Name
                FROM Account
                LIMIT 1];
    }

    @isTest
    static void testInsertOrder(){
        Account testAccount = getAccount();

        Test.startTest();
            Order orderObj = SubTabController.insertOrder(testAccount.Id);
        Test.stopTest();

        System.assertEquals(orderObj.Status, 'Pending Draft', 'Status should be pending draft');
    }

    @isTest
    static void testGetAccountInfo(){
        Order testOrder = getOrder();

        Test.startTest();
            Order orderObj = SubTabController.getAccountInfo(testOrder.Id);
        Test.stopTest();

        System.assertEquals(orderObj.Status, 'Pending Draft', 'Status should be pending draft');
    }
}
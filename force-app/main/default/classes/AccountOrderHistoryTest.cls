@isTest
public class AccountOrderHistoryTest {
	
    @isTest
    static void testAccountOrderHistory(){
        Test.enableChangeDataCapture();
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2346');
        Pricebook2 testPriceBook = TestFactory.createPriceBook(testAccount.Id, testAccount.Name, true, 'Account Pricebook');
        Pricebook2 testStandardPriceBook = TestFactory.createStandardPriceBook();
        Product2 testProd = TestFactory.createProduct('Test Product', '12345', 'MillerCoors', '123*B');
        Product2 testProd2 = TestFactory.createProduct('Test Product2', '23456', 'MillerCoorsLite', '123*A');
        Product2 testProd3 = TestFactory.createProduct('Test Product3', '34567', 'MillerDraft', '144*A');
		TestFactory.createPriceBookEntry(Test.getStandardPricebookId(), testProd.Id, 12.99, false, true);
        TestFactory.createPriceBookEntry(Test.getStandardPricebookId(), testProd2.Id, 11.99, false, true);
        TestFactory.createPriceBookEntry(Test.getStandardPricebookId(), testProd3.Id, 13.99, false, true);        
        PriceBookEntry testPriceBookEntry = TestFactory.createPriceBookEntry(testPriceBook.Id, testProd.Id, 12.99, false, true);
        PriceBookEntry testPriceBookEntry2 = TestFactory.createPriceBookEntry(testPriceBook.Id, testProd2.Id, 10.99, false, true);
        PriceBookEntry testPriceBookEntry3 = TestFactory.createPriceBookEntry(testPriceBook.Id, testProd3.Id, 13.99, false, true);        
        Order testOrder = TestFactory.createOrderBeerline(testAccount.Id, testPriceBook.Id, System.today(), 'Invoice', 'B2B');
        testOrder.Invoice_Date__c = System.today() - 49;
        update testOrder;
        Order testOrder2 = TestFactory.createOrderBeerline(testAccount.Id, testPriceBook.Id, System.today(), 'Invoice', 'B2B');
        testOrder2.Invoice_Date__c = System.today() - 42;
        update testOrder2;
        Order testOrder3 = TestFactory.createOrderBeerline(testAccount.Id, testPriceBook.Id, System.today(), 'Invoice', 'B2B');
        testOrder3.Invoice_Date__c = System.today() - 35;
        update testOrder3;  
        Order testOrder4 = TestFactory.createOrderBeerline(testAccount.Id, testPriceBook.Id, System.today(), 'Invoice', 'B2B');
        testOrder4.Invoice_Date__c = System.today() - 28;
        update testOrder4;  
        Order testOrder5 = TestFactory.createOrderBeerline(testAccount.Id, testPriceBook.Id, System.today(), 'Invoice', 'B2B');
        testOrder5.Invoice_Date__c = System.today() - 14;
        update testOrder5;
        Order testOrder6 = TestFactory.createOrderBeerline(testAccount.Id, testPriceBook.Id, System.today(), 'Invoice', 'B2B');
        testOrder6.Invoice_Date__c = System.today() - 7;
        update testOrder6;
        Order testOrder7 = TestFactory.createOrderBeerline(testAccount.Id, testPriceBook.Id, System.today(), 'Invoice', 'B2B');
        testOrder7.Invoice_Date__c = System.today();
        update testOrder7;  
        TestFactory.createOrderItem(testPriceBookEntry.Id, testOrder.Id, 1, 2, 11.99, testProd.Id);
        TestFactory.createOrderItem(testPriceBookEntry2.Id, testOrder.Id, 1, 2, 10.99, testProd2.Id);        
		TestFactory.createOrderItem(testPriceBookEntry.Id, testOrder2.Id, 2, 2, 11.99, testProd.Id);        
        TestFactory.createOrderItem(testPriceBookEntry3.Id, testOrder3.Id, 2, 2, 13.99, testProd3.Id);        
		TestFactory.createOrderItem(testPriceBookEntry.Id, testOrder4.Id, 1, 2, 11.99, testProd.Id);
        TestFactory.createOrderItem(testPriceBookEntry2.Id, testOrder5.Id, 1, 2, 10.99, testProd2.Id);        
		TestFactory.createOrderItem(testPriceBookEntry.Id, testOrder5.Id, 2, 2, 11.99, testProd.Id);        
        TestFactory.createOrderItem(testPriceBookEntry3.Id, testOrder6.Id, 2, 2, 13.99, testProd3.Id);                
        TestFactory.createOrderItem(testPriceBookEntry3.Id, testOrder7.Id, 2, 2, 13.99, testProd3.Id);

        Test.startTest();
        //Get the Delivery Dates
        List<Date> returnDates = AccountOrderHistory.getInvoiceDates(testAccount.Id);
        //Get the Order Items
        List<AccountOrderHistory.OrderItemWrapper> returnOrders = AccountOrderHistory.getOrderItems(testAccount.Id);
        Test.stopTest();
        
        //Assert that returnDates has 3 (we added orders with 6 different invoice dates)
        System.assertEquals(6, returnDates.size());
        //Assert that returnOrders has 3 (we added orders with 3 different products)
        System.assertEquals(3, returnOrders.size());
    }
}
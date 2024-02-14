@isTest
private class OrderDAOTest {

    @TestSetup
    private static void setup() {
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2346');
        Pricebook2 testPriceBook = TestFactory.createPriceBook(testAccount.Id, testAccount.Name, true, 'Account Pricebook');
        Pricebook2 testStandardPriceBook = TestFactory.createStandardPriceBook();
        Product2 testProd = TestFactory.createProduct('Test Product', '12345', 'MillerCoors', '123*B');
        TestFactory.createPriceBookEntry(testStandardPriceBook.Id, testProd.Id, 12.99, false, true);
        Id invoiceOrderRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Invoice').getRecordTypeId();
        Order testOrderInvoice = TestFactory.createOrderRecordType(testAccount.Id, testPriceBook.Id, System.today(), 'Pending Draft', invoiceOrderRecordTypeId);
        PriceBookEntry testPriceBookEntry = TestFactory.createPriceBookEntryInvoice(testPriceBook.Id, testProd.Id, 12.99, false, true, null);        
        Order testOrder = TestFactory.createOrder(testAccount.Id, testPriceBook.Id, System.today(), 'Pending Draft');
        TestFactory.createOrderItem(testPriceBookEntry.Id, testOrder.Id, 1, 2, 11.99, testProd.Id);
    }

    static Order getOrder(Id recordTypeId) {
        return [SELECT Id, Name, AccountId, Status, Delivery_Date__c, Unscheduled_Reason_Code__c
                FROM Order
                WHERE RecordTypeId = :recordTypeId
                LIMIT 1];
    }

    static Account getAccount() {
        return [SELECT Id, Name
                FROM Account
                LIMIT 1];
    }

    static PriceBook2 getPriceBook() {
        return [SELECT Id, Name
                FROM PriceBook2
                LIMIT 1];
    }

    @isTest
    static void testGetOrderDetailsbyId() {
        Id orderRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Order').getRecordTypeId();
        Order testOrder = getOrder(orderRecordTypeId);

        Test.startTest();
            List<Order> orderList = OrderDAO.getOrderDetailsbyId(testOrder.Id);
        Test.stopTest();

        System.assertEquals(1, orderList.size(), 'orderList should return 1 record');
    }

    @isTest
    static void testGetOrderDetailsbyIdSet(){
        Id orderRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Order').getRecordTypeId();
        Set<String> testOrderSet = new Set<String>();
        testOrderSet.add(getOrder(orderRecordTypeId).Id);

        Test.startTest();
            List<Order> orderList = OrderDAO.getOrderDetailsbyId(testOrderSet);
        Test.stopTest();

        System.assertEquals(1, orderList.size(), 'orderList should return 1 record');
    }

    @isTest
    static void testGetOrderDetailsbyIds(){
        Id orderRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Order').getRecordTypeId();

        Test.startTest();
            List<Order> orderList = OrderDAO.getOrderDetailsbyIds(new Set<Id>{getOrder(orderRecordTypeId).Id});
        Test.stopTest();

        System.assertEquals(orderList.size(), 1, 'orderList should return 1 record');
    }

    @isTest
    static void testGetInvoiceOrderDetailsbyAccountDateRange(){
        Id invoiceOrderRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Invoice').getRecordTypeId();
        Account testAccount = getAccount();

        Test.startTest();
            List<Order> orderList = OrderDAO.getInvoiceOrderDetailsbyAccountDateRange(new Set<Id>{testAccount.Id}, 6, System.today(), invoiceOrderRecordTypeId);
        Test.stopTest();

        System.assertEquals(1, orderList.size(), 'orderList should return 1 record');
    }

    @isTest
    static void testGetInvoiceOrderDetailsbyAccount() {
        Id invoiceOrderRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Invoice').getRecordTypeId();
        Account testAccount = getAccount();

        Test.startTest();
            List<Order> orderList = OrderDAO.getInvoiceOrderDetailsbyAccount(new Set<Id>{testAccount.Id}, 6, invoiceOrderRecordTypeId);
        Test.stopTest();

        System.assertEquals(1, orderList.size(), 'orderList should return 1 record');
    }

    @isTest
    static void testGetPriorOrdersUnscheduledReasonCodesbyId() {        
		Id orderRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Order').getRecordTypeId();
        Order testOrder = getOrder(orderRecordTypeId);
        testOrder.Status = 'Posted to VIP';
        testOrder.Off_Day__c = true;
        testOrder.Unscheduled_Reason_Code__c = 'RBD Out of Stock';
        update testOrder;
        
        Test.startTest();
            List<Order> orderList = OrderDAO.getPriorOrdersUnscheduledReasonCodesbyId(testOrder.AccountId);            
        Test.stopTest();

        System.assertEquals(1, orderList.size(), 'orderList should return 1 record');
    }
    
    @isTest
    static void testInsertOrders(){
        Account testAccount = getAccount();
        PriceBook2 testPriceBook = getPriceBook();
        Order testOrder = new Order();
        testOrder.AccountId = testAccount.Id;
        testOrder.EffectiveDate = System.today();
        testOrder.Status = 'Pending Draft';
        testOrder.Pricebook2Id = testPriceBook.Id;

        Test.startTest();
            List<Order> orderList = OrderDAO.insertOrders(new List<Order>{testOrder});
        Test.stopTest();

        System.assertEquals(1, orderList.size(), 'orderList should return 1 record');
    }

    @isTest
    static void testUpdateOrders(){
        Id orderRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Order').getRecordTypeId();
        Order testOrder = getOrder(orderRecordTypeId);
        testOrder.EffectiveDate = System.today() + 1;

        Test.startTest();
            List<Order> orderList = OrderDAO.updateOrders(new List<Order>{testOrder});
        Test.stopTest();

        List<Order> ordersReturned = [SELECT Id, EffectiveDate FROM Order WHERE Id = :orderList[0].Id];

        System.assertEquals(1, ordersReturned.size(), 'ordersReturned should return 1 record');
        System.assertEquals(System.today() + 1, ordersReturned[0].EffectiveDate, 'EffectiveDate should be today + 1');
    }

    @isTest
    static void testDeleteOrders(){
        Id orderRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Order').getRecordTypeId();
        Order testOrder = getOrder(orderRecordTypeId);

        Test.startTest();
            List<Order> orderList = OrderDAO.deleteOrders(new List<Order>{testOrder});
        Test.stopTest();

        List<Order> ordersReturned = [SELECT Id, EffectiveDate FROM Order WHERE Id = :testOrder.Id];

        System.assertEquals(0, ordersReturned.size(), '0 orders should be returned');
    }
}
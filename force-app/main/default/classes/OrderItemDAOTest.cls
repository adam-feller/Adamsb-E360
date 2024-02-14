@isTest
private class OrderItemDAOTest {

    @TestSetup
    private static void setup(){
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2346');
        Pricebook2 testPriceBook = TestFactory.createPriceBook(testAccount.Id, testAccount.Name, true, 'Account Pricebook');
        Pricebook2 testStandardPriceBook = TestFactory.createStandardPriceBook();
        Product2 testProd = TestFactory.createProduct('Test Product', '12345', 'MillerCoors', '123*B');
        TestFactory.createPriceBookEntry(testStandardPriceBook.Id, testProd.Id, 12.99, false, true);
        PriceBookEntry testPriceBookEntry = TestFactory.createPriceBookEntry(testPriceBook.Id, testProd.Id, 12.99, false, true);
        Order testOrder = TestFactory.createOrder(testAccount.Id, testPriceBook.Id, System.today(), 'Pending Draft');
        TestFactory.createOrderItem(testPriceBookEntry.Id, testOrder.Id, 1, 2, 11.99, testProd.Id);
    }

    static Order getOrder(){
        return [SELECT Id, Name
                FROM Order
                LIMIT 1];
    }

    static Product2 getProduct(){
        return [SELECT Id, Name
                FROM Product2
                LIMIT 1];
    }

    static PriceBook2 getPriceBook(){
        return [SELECT Id, Name
                FROM PriceBook2
                WHERE IsStandard = false
                LIMIT 1];
    }

    static PriceBookEntry getPriceBookEntry(String priceBookId){
        return [SELECT Id, Name
                FROM PriceBookEntry
                WHERE pricebook2Id = :priceBookId
                LIMIT 1];
    }

    static OrderItem getOrderItem(){
        return [SELECT Id, Quantity_Order__c
                FROM OrderItem
                LIMIT 1];
    }

    @isTest
    static void testGetOrderItemByOrderId(){
        Order testOrder = getOrder();

        Test.startTest();
            List<OrderItem> orderItemList = OrderItemDAO.getOrderItemByOrderId(testOrder.Id);
        Test.stopTest();

        System.assertEquals(orderItemList.size(), 1, 'orderList should return 1 record');
    }

    @isTest
    static void testGetOrderItemByOrderIds(){
        Order testOrder = getOrder();

        Test.startTest();
            List<OrderItem> orderItemList = OrderItemDAO.getOrderItemByOrderIds(new Set<Id>{testOrder.Id});
        Test.stopTest();

        System.assertEquals(orderItemList.size(), 1, 'orderList should return 1 record');
    }

    @isTest
    static void testGetOrderItemByIdsStringSet(){
        OrderItem testOrderItem = getOrderItem();

        Test.startTest();
            List<OrderItem> orderItemList = OrderItemDAO.getOrderItemByIds(new Set<String>{testOrderItem.Id});
        Test.stopTest();

        System.assertEquals(orderItemList.size(), 1, 'orderList should return 1 record');
    }

    @isTest
    static void testInsertOrderItems(){
        Order testOrder = getOrder();
        PriceBook2 testPriceBook = getPriceBook();
        PriceBookEntry testPriceBookEntry = getPriceBookEntry(testPriceBook.Id);
        Product2 testProd = getProduct();
        OrderItem orderItemObj = new OrderItem();
        orderItemObj.PricebookEntryId = testPriceBookEntry.Id;
        orderItemObj.OrderId = testOrder.Id;
        orderItemObj.Quantity_Order__c = 1;
        orderItemObj.Inventory__c = 2;
        orderItemObj.UnitPrice = 11.99;
        orderItemObj.Product2Id = testProd.Id;
        orderItemObj.Quantity = 1;

        Test.startTest();
            List<OrderItem> orderItemList = OrderItemDAO.insertOrderItems(new List<OrderItem>{orderItemObj});
        Test.stopTest();

        System.assertEquals(orderItemList.size(), 1, 'orderItemList should return 1 record');
    }

    @isTest
    static void testUpdateOrderItems(){
        OrderItem testOrderItem = getOrderItem();
        testOrderItem.Quantity_Order__c = 2;

        Test.startTest();
            List<OrderItem> orderItemList = OrderItemDAO.updateOrderItems(new List<OrderItem>{testOrderItem});
        Test.stopTest();

        List<OrderItem> orderItemsReturned = [SELECT Id, Quantity_Order__c FROM OrderItem WHERE Id = :orderItemList[0].Id];

        System.assertEquals(orderItemsReturned.size(), 1, 'orderItemsReturned should return 1 record');
        System.assertEquals(orderItemsReturned[0].Quantity_Order__c, 2, 'Quantity Order should be 2');
    }

    @isTest
    static void testUpsertOrderItems(){
        OrderItem testOrderItem = getOrderItem();
        testOrderItem.Quantity_Order__c = 3;

        Test.startTest();
            List<OrderItem> orderItemList = OrderItemDAO.upsertOrderItems(new List<OrderItem>{testOrderItem});
        Test.stopTest();

        List<OrderItem> orderItemsReturned = [SELECT Id, Quantity_Order__c FROM OrderItem WHERE Id = :orderItemList[0].Id];

        System.assertEquals(orderItemsReturned.size(), 1, 'orderItemsReturned should return 1 record');
        System.assertEquals(orderItemsReturned[0].Quantity_Order__c, 3, 'Quantity Order should be 3');
    }

    @isTest
    static void testDeleteOrderItems(){
        OrderItem testOrderItem = getOrderItem();
        testOrderItem.Quantity_Order__c = 2;

        Test.startTest();
            List<OrderItem> orderItemList = OrderItemDAO.deleteOrderItems(new List<OrderItem>{testOrderItem});
        Test.stopTest();

        List<OrderItem> orderItemsReturned = [SELECT Id, Quantity_Order__c FROM OrderItem];

        System.assertEquals(orderItemsReturned.size(), 0, '0 records should be returned');
    }
}
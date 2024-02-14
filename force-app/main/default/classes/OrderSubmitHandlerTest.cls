@isTest
private class OrderSubmitHandlerTest {

    @TestSetup
    private static void setup(){
        TestFactory.createMulesoftUtilitySetting('Price Inventory', 'http://api-dev.reyesholdings.com/sfdc-price-inventory/price-inventory', null, null, null, null, '123', '123');
        TestFactory.createMulesoftUtilitySetting('Account ARDetails', 'http://api-dev.reyesholdings.com/sfdc-order/order', null, null, null, null, '123', '123');
        TestFactory.createMulesoftUtilitySetting('Order Validate', 'http://api-dev.reyesholdings.com/sfdc-order/order', null, null, null, null, '123', '123');
    }

    @isTest
    static void testSubmitBeerlineOrder201(){
        Test.enableChangeDataCapture();
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2346');
        Contact testContact = TestFactory.createContact(testAccount.Id, 'Test', 'Contact', 'test2@gmail.com');
        Pricebook2 testPriceBook = TestFactory.createPriceBook(testAccount.Id, testAccount.Name, true, 'Account Pricebook');
        Pricebook2 testStandardPriceBook = TestFactory.createStandardPriceBook();
        Product2 testProd = TestFactory.createProduct('Test Product', '12345', 'MillerCoors', '123*B');
        TestFactory.createPriceBookEntry(testStandardPriceBook.Id, testProd.Id, 12.99, false, true);
        PriceBookEntry testPriceBookEntry = TestFactory.createPriceBookEntry(testPriceBook.Id, testProd.Id, 12.99, false, true);
        Order testOrder = TestFactory.createOrderBeerline(testAccount.Id, testPriceBook.Id, System.today(), 'Pending Draft', 'B2B');
        testOrder.Order_Placed_By__c = testContact.Id;
        update testOrder;
        TestFactory.createOrderItem(testPriceBookEntry.Id, testOrder.Id, 1, 2, 11.99, testProd.Id);

        HttpResponse res = new HttpResponse();
        res.setBody('{"OrderID": "134565432"}');
        res.setStatusCode(201);

        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));

        Test.getEventBus().deliver();

        Test.startTest();
        Test.stopTest();

        List<Order> orderList = [SELECT Id, OrderSourceCode__c, Status FROM Order];
        System.assertEquals(orderList[0].OrderSourceCode__c, 'Web', 'Order source should be web');
        System.assertEquals(orderList[0].Status, 'Posted to VIP', 'Status should be Posted to VIP');
    }

    @isTest
    static void testSubmitBeerlineOrderNot200(){
        Test.enableChangeDataCapture();
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2346');
        Pricebook2 testPriceBook = TestFactory.createPriceBook(testAccount.Id, testAccount.Name, true, 'Account Pricebook');
        Pricebook2 testStandardPriceBook = TestFactory.createStandardPriceBook();
        Product2 testProd = TestFactory.createProduct('Test Product', '12345', 'MillerCoors', '123*B');
        TestFactory.createPriceBookEntry(testStandardPriceBook.Id, testProd.Id, 12.99, false, true);
        PriceBookEntry testPriceBookEntry = TestFactory.createPriceBookEntry(testPriceBook.Id, testProd.Id, 12.99, false, true);
        Contact testContact = TestFactory.createContact(testAccount.Id, 'Test', 'Contact', 'test2@gmail.com');
        Order testOrder = TestFactory.createOrderBeerline(testAccount.Id, testPriceBook.Id, System.today(), 'Pending Draft', 'B2B');
        testOrder.Order_Placed_By__c = testContact.Id;
        update testOrder;
        TestFactory.createOrderItem(testPriceBookEntry.Id, testOrder.Id, 1, 2, 11.99, testProd.Id);

        HttpResponse res = new HttpResponse();
        res.setBody('{  "statusCode": "409",  "message": "VIP_VALIDATION_FAILED",  "detailErrorMessage": "198 : Unexpected error occurred.",  "lineItemErrors": [      ]}');
        res.setStatusCode(409);

        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));

        Test.getEventBus().deliver();

        Test.startTest();
        Test.stopTest();

        List<Order> orderList = [SELECT Id, OrderSourceCode__c, Status FROM Order];
        System.assertEquals(orderList[0].OrderSourceCode__c, 'Web', 'Order source should be web');
        System.assertEquals(orderList[0].Status, 'Posting Error', 'Status should be Posting Error');
    }

    @isTest
    static void testSetFutureOrderDetails(){
        Test.enableChangeDataCapture();
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2346');
        Contact testContact = TestFactory.createContact(testAccount.Id, 'Test', 'Contact', 'test2@gmail.com');
        Pricebook2 testPriceBook = TestFactory.createPriceBook(testAccount.Id, testAccount.Name, true, 'Account Pricebook');
        Pricebook2 testStandardPriceBook = TestFactory.createStandardPriceBook();
        Product2 testProd = TestFactory.createProduct('Test Product', '12345', 'MillerCoors', '123*B');
        TestFactory.createPriceBookEntry(testStandardPriceBook.Id, testProd.Id, 12.99, false, true);
        PriceBookEntry testPriceBookEntry = TestFactory.createPriceBookEntry(testPriceBook.Id, testProd.Id, 12.99, false, true);
        Order testOrder = TestFactory.createOrderBeerline(testAccount.Id, testPriceBook.Id, System.today(), 'Pending - Future Order', 'B2B');
        testOrder.Order_Placed_By__c = testContact.Id;
        update testOrder;
        TestFactory.createOrderItem(testPriceBookEntry.Id, testOrder.Id, 1, 2, 11.99, testProd.Id);

        HttpResponse res = new HttpResponse();
        res.setBody('{"OrderID": "134565432"}');
        res.setStatusCode(201);

        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));

        Test.getEventBus().deliver();

        Test.startTest();
        Test.stopTest();

        List<Order> orderList = [SELECT Id, OrderSourceCode__c, Status FROM Order];
        System.assertEquals(orderList[0].OrderSourceCode__c, 'Web', 'Order source should be web');
        System.assertEquals(orderList[0].Status, 'Pending - Future Order', 'Status should be Pending - Future Order');
    }
}
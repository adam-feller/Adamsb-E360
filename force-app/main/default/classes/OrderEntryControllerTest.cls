@isTest
private class OrderEntryControllerTest {

    @TestSetup
    private static void setup() {
		Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2346');
        Contact testContact = TestFactory.createContact(testAccount.Id, 'Test', 'Contact', 'test2@gmail.com');
        Pricebook2 testPriceBook = TestFactory.createPriceBook(testAccount.Id, testAccount.Name, true, 'Account Pricebook');
        Pricebook2 testStandardPriceBook = TestFactory.createStandardPriceBook();
        Product2 testProd = TestFactory.createProduct('Test Product', '12345', 'MillerCoors', '123*B');
        testProd.QuantityUnitOfMeasure = 'CB';
        update testProd;
        Product2 testProd2 = TestFactory.createProduct('Test Product2', '12346', 'Coors', '124*B');
        testProd2.QuantityUnitOfMeasure = 'CB';
        update testProd2;
        TestFactory.createPriceBookEntry(testStandardPriceBook.Id, testProd.Id, 12.99, false, true);
        TestFactory.createPriceBookEntry(testStandardPriceBook.Id, testProd2.Id, 11.99, false, true);
        Product_Feedback__c pinnedProduct1 = new Product_Feedback__c(Account__c = testAccount.Id, Product__c = testProd.Id, Expiration_Date__c = System.today() + 30, Type__c = 'Pinned', Notes__c = 'test');
		insert pinnedProduct1;
        Product_Feedback__c pinnedProduct2 = new Product_Feedback__c(Account__c = testAccount.Id, Product__c = testProd2.Id, Expiration_Date__c = System.today() + 30, Type__c = 'Pinned', Notes__c = 'test');
		insert pinnedProduct2;
        Id invoiceOrderRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Invoice').getRecordTypeId();
        Order testOrderInvoice = TestFactory.createOrderRecordType(testAccount.Id, testPriceBook.Id, System.today(), 'Pending Draft', invoiceOrderRecordTypeId);
        testOrderInvoice.Order_Origin__c = 'Text To Order';
        update testOrderInvoice;
        PriceBookEntry testPriceBookEntry = TestFactory.createPriceBookEntryInvoice(testPriceBook.Id, testProd.Id, 12.99, false, true, null);
        TestFactory.createOrderItem(testPriceBookEntry.Id, testOrderInvoice.Id, 1, 2, 11.99, testProd.Id);
        Order testOrder = TestFactory.createOrder(testAccount.Id, testPriceBook.Id, System.today(), 'Pending Draft');
        testOrder.Order_Placed_By__c = testContact.Id;
        testOrder.Order_Origin__c = 'Text To Order';
        update testOrder;
        TestFactory.createOrderItem(testPriceBookEntry.Id, testOrder.Id, 1, 2, 11.99, testProd.Id);
        TestFactory.createWarehouse('CBS - SWB', null, 'CBS', null, null, null, null, null);
        TestFactory.createMulesoftUtilitySetting('Price Inventory', 'http://rh-sfdc-price-inventory-xapi-dev.us-e2.cloudhub.io/api/price-inventory', null, null, null, null, '123', '123');
        TestFactory.createMulesoftUtilitySetting('Suggested Sell', 'http://rh-suggested-sell-xapi.us-e2.cloudhub.io/api/suggested-sell', '/', null, null, null, '123', '123');
        TestFactory.createMulesoftUtilitySetting('Mandates', 'http://rh-mandate-gap-xapi.us-e2.cloudhub.io/api/mandateGap?', 'sourceId=', 'customerId=', null, null, '123', '123');
        TestFactory.createMulesoftUtilitySetting('Order Validate', 'http://api-dev.reyesholdings.com/sfdc-order/order', null, null, null, null, '123', '123');
        TestFactory.createMulesoftUtilitySetting('Account Validate', 'http://rh-validate-account-xapi-dev.us-e2.cloudhub.io/api/validate-account', null, null, null, null, '123', '123');
        TestFactory.createMulesoftUtilitySetting('Account ARDetails', 'http://api-dev.reyesholdings.com/sfdc-order/order/validate', null, null, null, null, '123', '123');
        TestFactory.createReyesOrgSetting(6, 90);
        TestFactory.createBusinessUnit('PVA', 'http://rbdtest:8804', 'pvacrm@reyesholdings.com', 'p850085', 'B13KI');
    }

    static Order getOrder() {
        return [SELECT Id, Name, Status, Pricebook2Id, AccountId, Unscheduled_Reason_Code__c
                FROM Order
                LIMIT 1];
    }

    static Product2 getProductByName(String name) {
        return [SELECT Id, QuantityUnitOfMeasure
                FROM Product2
                WHERE Name = :name
                LIMIT 1];
    }

    static OrderItem getOrderItem() {
        return [SELECT Id, Type__c, Product2Id, Product2.SKU_External_Id__c, Quantity_Order__c, UOM__c, Order_UOM__c, IsUnitQuantity__c
                FROM OrderItem
                LIMIT 1];
    }

    static Account getAccount() {
        return [SELECT Id, Name, Chain_Independent__c, ExternalId__c, VIP_Instance__c, VIP_Account_Number__c, Require_PO__c,
                Status__c, LicenseExpirationDate__c, Territories__c,Controllable__c
                FROM Account
                LIMIT 1];
    }

    static Contact getContact() {
        return [SELECT Id, Name
                FROM Contact
                LIMIT 1];
    }

    static PriceBookEntry getPriceBookEntry() {
        return [SELECT Id, Name, Pricebook2Id, IsHidden__c, Expiration_Date__c
                FROM PriceBookEntry
                LIMIT 1];
    }

    static PriceBook2 getPriceBook() {
        return [SELECT Id, Name
                FROM PriceBook2
                WHERE IsStandard = true
                LIMIT 1];
    }

    static PriceBook2 getPriceBookNotStandard() {
        return [SELECT Id, Name, Type__c
                FROM PriceBook2
                WHERE IsStandard = false
                LIMIT 1];
    }

    static Warehouse__c getWarehouse() {
        return [SELECT Id, Name
                FROM Warehouse__c
                LIMIT 1];
    }

    static Business_Unit__c getBusinessUnit() {
        return [SELECT Id, Name, VIP_API_URL__c, VIP_API_User_Name__c, VIP_API_User_Password__c, VIPCookie__c
                FROM Business_Unit__c
                LIMIT 1];
    }

    @isTest
    static void testGetOrderSummaryDetails() {
        Order testOrder = getOrder();
        Account testAccount = getAccount();
        testAccount.Requested_Delivery_Days__c = 'Tuesday';
        testAccount.Delivery_Frequency_Type__c = 'Weekly';
        update testAccount;

        Test.startTest();
            OrderEntryController.OrderSummaryDetail orderSummary = OrderEntryController.getOrderSummaryDetails(testOrder.Id);
        Test.stopTest();

        System.assertEquals('Pending Draft', orderSummary.orderStatus, 'Order Status should be pending draft');
    }

    @isTest
    static void testGetWarehouseThreshold() {
        Order testOrder = getOrder();
        Warehouse__c testWarehouse = getWarehouse();
        testWarehouse.LayerPalletThreshold__c = 25;
        update testWarehouse;
        Account testAccount = getAccount();
        testAccount.Warehouse_Lookup__c = testWarehouse.Id;
        update testAccount;

        Test.startTest();
            OrderEntryController.WarehouseOrderDetail warehouseObj = OrderEntryController.getWarehouseThreshold(testOrder.Id);
        Test.stopTest();

        System.assertEquals(25, warehouseObj.warehouseObj.LayerPalletThreshold__c, 'Warehouse threshold should be 25');
    }

    @isTest
    static void testUpdateOrderDetailsPending() {
        Order testOrder = getOrder();
        Account testAccount = getAccount();
        testAccount.Requested_Delivery_Days__c = 'Tuesday';
        testAccount.Delivery_Frequency_Type__c = 'Weekly';
        update testAccount;

        Test.startTest();
            OrderEntryController.OrderResponseDetail orderResponseDetail = OrderEntryController.updateOrderDetails(testOrder.Id, '12345', System.today(), System.today() + 7, 'Pending Draft', null, 'Test', true, 'Text To Order','', 0.0, 0.0, 0.0);
        Test.stopTest();

        System.assertEquals(new List<String>(), orderResponseDetail.orderErrorMsg, 'orderErrorMsg should be an empty string');
    }

    @isTest
    static void testUpdateOrderDetailsVIP() {
        Order testOrder = getOrder();
        Account testAccount = getAccount();
        testAccount.Requested_Delivery_Days__c = 'Tuesday';
        testAccount.Delivery_Frequency_Type__c = 'Weekly';
        testAccount.Status__c = 'A';
        update testAccount;

        HttpResponse res = new HttpResponse();
        res.setBody('{"AccountRecords":[{"AccountNumber":"41824","PassFailFlag":"1","ErrorCode":"102","ErrorCodeDescription":"Account 41824 not found"}]}');
        res.setStatusCode(201);

        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));

        Test.startTest();
            OrderEntryController.OrderResponseDetail orderResponseDetail = OrderEntryController.updateOrderDetails(testOrder.Id, '12345', System.today(), System.today() + 7, 'Posted to VIP', null, 'Test', true, 'Text To Order','', 0.0, 0.0, 0.0);
        Test.stopTest();

        System.assertEquals(new List<String>(), orderResponseDetail.orderErrorMsg, 'orderErrorMsg should be an empty string');
    }

    @isTest
    static void testUpdateOrderDetailsVIPPassValidate() {
        Order testOrder = getOrder();
        Account testAccount = getAccount();
        testAccount.Requested_Delivery_Days__c = 'Tuesday';
        testAccount.Delivery_Frequency_Type__c = 'Weekly';
        testAccount.Status__c = 'A';
        update testAccount;

        HttpResponse res = new HttpResponse();
        res.setBody('{"AccountRecords":[{"AccountNumber":"41824","PassFailFlag":"0","ErrorCode":"","ErrorCodeDescription":""}]}');
        res.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));

        Test.startTest();
            OrderEntryController.OrderResponseDetail orderResponseDetail = OrderEntryController.updateOrderDetails(testOrder.Id, '12345', System.today(), System.today() + 7, 'Posted to VIP', null, 'Test', false, 'Text To Order', '', 0.0, 0.0, 0.0);
        Test.stopTest();

        System.assertEquals(new List<String>(), orderResponseDetail.orderErrorMsg, 'orderErrorMsg should be an empty string');
    }

    @isTest
    static void testUpdateOrderDetailsVIPValidateFail() {
        Order testOrder = getOrder();
        Account testAccount = getAccount();
        testAccount.Requested_Delivery_Days__c = 'Tuesday';
        testAccount.Delivery_Frequency_Type__c = 'Weekly';
        testAccount.Status__c = 'A';
        update testAccount;

        HttpResponse res = new HttpResponse();
        res.setBody('{"AccountRecords":[{"AccountNumber":"41824","PassFailFlag":"1","ErrorCode":"102","ErrorCodeDescription":"Account 41824 not found"}]}');
        res.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));

        Test.startTest();
            OrderEntryController.OrderResponseDetail orderResponseDetail = OrderEntryController.updateOrderDetails(testOrder.Id, '12345', System.today(), System.today() + 7, 'Posted to VIP', null, 'Test', false, 'Text To Order','', '', 0.0, 0.0, 0.0);
        Test.stopTest();

        System.assertEquals(new List<String>(), orderResponseDetail.orderErrorMsg, 'orderErrorMsg should be an empty string');
    }

    @isTest
    static void testUpdateOrderContact() {
        Order testOrder = getOrder();
        contact testContact = getContact();

        Test.startTest();
            Order orderObj = OrderEntryController.updateOrderContact(testOrder.Id, testContact.Id);
        Test.stopTest();

        System.assertEquals(testContact.Id, orderObj.Contact__c, 'Contact__c should match testContact.Id');
    }

    @isTest
    static void testGetPricingDetailForNewProduct() {
        Order testOrder = getOrder();

        HttpResponse res = new HttpResponse();
        res.setBody('{  "WarehouseInventoryResponse": {    "AccountNumber": "55264",    "ItemRecords": [      {        "ItemCode": "12345",        "AvailableQty": 0,        "RemainingAllocationQty": 0,        "AvailableCTCQty": 0,        "CasesPerTier": 8,        "RoundToNextTier": false      }    ]  },  "ItemPriceResponse": {    "AccountNumber": "55264",    "AnticipatedDeliveryDate": "20201209",    "ItemPriceRecords": [      {        "ItemCode": "12345",        "CasePrice": 36.85,        "UnitPrice": 1.54,        "CaseDeposit": 0,        "UnitDeposit": 0,        "CasePostOff": 0,        "UnitPostOff": 0,        "CaseCRV": 0,        "UnitCRV": 0,        "SSP": 0,        "MinCasePrice": 0,        "MinUnitPrice": 0,        "BlockPriceOverride": false,        "InvoiceType": "B",        "ARType": null,        "Taxes": [          {            "TaxID": "TAX01"          },          {            "TaxID": "TAX05"          }        ]      }    ],    "ItemDealRecords": null,    "DealDetailRecords": null,    "DealBreakRecords": null  }}');
        res.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));

        Test.startTest();
            List<OrderEntryController.AccountPricebookProducts> accountProducts = OrderEntryController.getPricingDetailForNewProduct(testOrder.Id, '12345');
        Test.stopTest();

        System.assertEquals(1, accountProducts.size(), '1 accountProduct should be returned');
    }

    @isTest
    static void testGetSuggestedSellAndMandateProductsSuggested() {
        Order testOrder = getOrder();
        Account testAccount = getAccount();

        HttpResponse res = new HttpResponse();
        res.setBody('[{"snapShotDatetime": "2021-01-26T07:30:43.28","openGapInd": "FALSE", "productExternalId": "12345","customerExternalId": "72245","displaySequence": 1}]');
        res.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));

        Test.startTest();
            List<OrderEntryController.AccountPricebookProducts> accountProducts = OrderEntryController.getSuggestedSellAndMandateProducts(testOrder, testAccount);
        Test.stopTest();

        System.assertNotEquals(null, accountProducts, 'accountProducts should not be null');
    }

    @isTest
    static void testHandleSuggestedSellData() {
        Order testOrder = getOrder();
        Account testAccount = getAccount();

        HttpResponse res = new HttpResponse();
        res.setBody('[{"snapShotDatetime": "2021-01-26T07:30:43.28","openGapInd": "FALSE", "productExternalId": "12345","customerExternalId": "72245","displaySequence": 1}]');
        res.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));

        Test.startTest();
            List<OrderEntryController.AccountPricebookProducts> accountProducts = OrderEntryUtility.handleSuggestedSellData(res, testAccount.Id, testOrder.Id);
        Test.stopTest();

        System.assertNotEquals(null, accountProducts, 'accountProducts should not be null');
    }

    @isTest
    static void testGetSuggestedSellAndMandateProductsMandate() {
        Order testOrder = getOrder();
        Account testAccount = getAccount();

        HttpResponse res = new HttpResponse();
        String body = '[{"salesforceMandateId": "a002g000002HjNvAAK","mandateMetInd": "FALSE","openGapInd": "TRUE","mandateType": "None","startDate": "2019-12-31","endDate": "2020-12-31","sourceId": "GBX","customer": {"id": "ZE446", "desc": "APPLEBEE\'S - YUBA CITY" }, "salesOrg": { "id": "GB4", "desc": "GOLDEN BRANDS - CHICO" }, "salesManager": { "id": "4092", "desc": "THORNTON/CHICO" }, "warehouseInfo": { "id": "CHICO", "desc": "CHICO" }, "product1": { "id": "38902", "desc": "C24 12OZ 6P", "upc": "87692006787", "subBrand": { "id": "ABCDEFGHIJKLM", "desc": "TRULY WILD BRY" }, "brand": { "id": "A0O", "desc": "TRULY" }, "container": "Can", "invoiceDate": "2020-05-22", "invoiceNumber": "755917", "soldInd": "TRUE" }, "product2": { "id": "38902", "desc": "C24 12OZ 6P", "upc": "87692006787", "subBrand": { "id": "JWS", "desc": "TRULY WILD BRY" }, "brand": { "id": "A0O", "desc": "TRULY" }, "container": "Can", "invoiceDate": "2020-05-22", "invoiceNumber": "755917", "soldInd": "TRUE" }, "product3": { "id": "38902", "desc": "C24 12OZ 6P", "upc": "87692006787", "subBrand": { "id": "JWS", "desc": "TRULY WILD BRY" }, "brand": { "id": "A0O", "desc": "TRULY" }, "container": "Can", "invoiceDate": "2020-05-22", "invoiceNumber": "755917", "soldInd": "TRUE" } }]';
        res.setBody(body);
        res.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));

        Test.startTest();
            List<OrderEntryController.AccountPricebookProducts> accountProducts = OrderEntryController.getSuggestedSellAndMandateProducts(testOrder, testAccount);
        Test.stopTest();

        System.assertNotEquals(null, accountProducts, 'accountProducts should not be null');
    }

    @isTest
    static void testHandleMandateData(){
        Order testOrder = getOrder();
        Account testAccount = getAccount();

        HttpResponse res = new HttpResponse();
        String body = '[{"salesforceMandateId": "a002g000002HjNvAAK","mandateMetInd": "FALSE","openGapInd": "TRUE","mandateType": "None","startDate": "2019-12-31","endDate": "2020-12-31","sourceId": "GBX","customer": {"id": "ZE446", "desc": "APPLEBEE\'S - YUBA CITY" }, "salesOrg": { "id": "GB4", "desc": "GOLDEN BRANDS - CHICO" }, "salesManager": { "id": "4092", "desc": "THORNTON/CHICO" }, "warehouseInfo": { "id": "CHICO", "desc": "CHICO" }, "product1": { "id": "38902", "desc": "C24 12OZ 6P", "upc": "87692006787", "subBrand": { "id": "ABCDEFGHIJKLM", "desc": "TRULY WILD BRY" }, "brand": { "id": "A0O", "desc": "TRULY" }, "container": "Can", "invoiceDate": "2020-05-22", "invoiceNumber": "755917", "soldInd": "TRUE" }, "product2": { "id": "38902", "desc": "C24 12OZ 6P", "upc": "87692006787", "subBrand": { "id": "JWS", "desc": "TRULY WILD BRY" }, "brand": { "id": "A0O", "desc": "TRULY" }, "container": "Can", "invoiceDate": "2020-05-22", "invoiceNumber": "755917", "soldInd": "TRUE" }, "product3": { "id": "38902", "desc": "C24 12OZ 6P", "upc": "87692006787", "subBrand": { "id": "JWS", "desc": "TRULY WILD BRY" }, "brand": { "id": "A0O", "desc": "TRULY" }, "container": "Can", "invoiceDate": "2020-05-22", "invoiceNumber": "755917", "soldInd": "TRUE" } }]';
        res.setBody(body);
        res.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));

        Test.startTest();
            List<OrderEntryController.AccountPricebookProducts> accountProducts = OrderEntryUtility.handleMandateData(res, testOrder.Id, '10');
        Test.stopTest();

        System.assertNotEquals(null, accountProducts, 'accountProducts should not be null');
    }

    @isTest
    static void testGetProductsForAccount() {
        Order testOrder = getOrder();

        HttpResponse res = new HttpResponse();
        res.setBody('{  "WarehouseInventoryResponse": {    "AccountNumber": "55264",    "ItemRecords": [      {        "ItemCode": "12345",        "AvailableQty": 0,        "RemainingAllocationQty": 0,        "AvailableCTCQty": 0,        "CasesPerTier": 8,        "RoundToNextTier": false      }    ]  },  "ItemPriceResponse": {    "AccountNumber": "55264",    "AnticipatedDeliveryDate": "20201209",    "ItemPriceRecords": [      {        "ItemCode": "12345",        "CasePrice": 36.85,        "UnitPrice": 1.54,        "CaseDeposit": 0,        "UnitDeposit": 0,        "CasePostOff": 0,        "UnitPostOff": 0,        "CaseCRV": 0,        "UnitCRV": 0,        "SSP": 0,        "MinCasePrice": 0,        "MinUnitPrice": 0,        "BlockPriceOverride": false,        "InvoiceType": "B",        "ARType": null,        "Taxes": [          {            "TaxID": "TAX01"          },          {            "TaxID": "TAX05"          }        ]      }    ],    "ItemDealRecords": null,    "DealDetailRecords": null,    "DealBreakRecords": null  }}');
        res.setStatusCode(400);

        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));

        Test.startTest();
            OrderEntryController.AccountProductsResponse accountProducts = OrderEntryController.getProductsForAccount(testOrder.Id, false);
        Test.stopTest();

        System.assertNotEquals(null, accountProducts, 'accountProducts should not be null');
    }

    @isTest
    static void testCreateAccountPricebookProduct() {
        Order testOrder = getOrder();
        OrderItem testOrderItem = getOrderItem();

        Test.startTest();
            OrderEntryController.AccountPricebookProducts accountProducts = OrderEntryController.createAccountPricebookProduct(false, true, true, false, false, testOrderItem.Id, testOrder.Id,
                                                                                                testOrderItem.Product2Id, 'Miller Lite 12 oz Can', 'can', 'Case of Beer', 1, '12 oz Can', 10, 8, 64, '12345', false, false, 12.99, 1.00,
                                                                                                13.99, 'Pending Draft', 1, null, null, null, null, 'Stout', 'Spring','StoryText');
        Test.stopTest();

        System.assertEquals(testOrderItem.Product2Id, accountProducts.id, 'Id should be the same as productId');
    }
    
    @isTest
    static void testGetProductSearchResults() {
        Order testOrder = getOrder();

        Test.startTest();
            List<Product2> productList = OrderEntryController.getProductSearchResults('Test Product', testOrder.Id);
        Test.stopTest();

        System.assertEquals(2, productList.size(), 'Should return 2 records');
    }

    @isTest
    static void testGetAccountPricebookProducts() {
        Order testOrder = getOrder();

        Test.startTest();
            List<OrderEntryController.AccountPricebookProducts> accountProducts = OrderEntryController.getAccountPricebookProducts(testOrder);
        Test.stopTest();

        System.assertEquals(1, accountProducts.size(), '1 record should be returned');
    }

    @isTest
    static void testGetDefaultProducts() {
        Order testOrder = getOrder();
        Account testAccount = getAccount();
        testAccount.Requested_Delivery_Days__c = 'Tuesday';
        testAccount.Delivery_Frequency_Type__c = 'Weekly';
        update testAccount;
        OrderItem orderItemObj = getOrderItem();
        orderItemObj.Invoice__c = true;
        update orderItemObj;

        Test.startTest();
            OrderEntryController.InvoiceProductDetails invoiceProductDetailObj = OrderEntryController.getDefaultProducts(testOrder, testAccount);
        Test.stopTest();

        System.assertEquals(1, invoiceProductDetailObj.accountProducts.size(), '1 record should be returned');
    }

    @isTest
    static void testUpdateDefaultProductToHidden() {
        Order testOrder = getOrder();
        Account testAccount = getAccount();
        testAccount.Requested_Delivery_Days__c = 'Tuesday';
        testAccount.Delivery_Frequency_Type__c = 'Weekly';
        update testAccount;
        OrderItem orderItemObj = getOrderItem();
        orderItemObj.Invoice__c = true;
        update orderItemObj;
        Product2 testProduct = getProductByName('Test Product');

        Test.startTest();
            List<OrderItem> orderItemList = OrderEntryController.updateDefaultProductToHidden(new List<String>{testProduct.Id}, testOrder.Id);
        Test.stopTest();

        System.assertEquals(1, orderItemList.size(), '1 record should be returned');
    }

    @isTest
    static void testDeleteOrder() {
        Order testOrder = getOrder();
        Account testAccount = getAccount();

        Test.startTest();
            Id accountId = OrderEntryController.deleteOrder(testOrder.Id);
        Test.stopTest();

        List<Order> ordersReturned = [SELECT Id FROM Order WHERE Id = :testOrder.Id];

        System.assertEquals(testAccount.Id, accountId, 'AccountIds should be the same');
        System.assertEquals(0, ordersReturned.size(), '0 orders should be returned');
    }

    @isTest
    static void testGetUnscheduledFalse() {
        Account testAccount = getAccount();
        testAccount.Requested_Delivery_Days__c = System.now().format('EEEE');
        testAccount.Delivery_Frequency_Type__c = 'Weekly';
        update testAccount;        
        Order testOrder = getOrder();
        
        Test.startTest();
            Boolean isUnscheduled = OrderEntryController.getUnscheduled(testOrder.Id);
        Test.stopTest();

        System.assertEquals(false, isUnscheduled, 'False should be returned for Off Day/Off Frequency');
    }
    
    @isTest
    static void testGetUnscheduledTrue() {
        Account testAccount = getAccount();
        System.debug((System.now()+1).format('EEEE'));
        testAccount.Requested_Delivery_Days__c = (System.now()+1).format('EEEE');
        testAccount.Delivery_Frequency_Type__c = 'Weekly';
        update testAccount;        
		Order testOrder = getOrder();
        OrderEntryController.updateOrderDetails(testOrder.Id, null, System.today(), null, null, null, null, null, null, null, null, null, null);
		
        Test.startTest();
            Boolean isUnscheduled = OrderEntryController.getUnscheduled(testOrder.Id);
        Test.stopTest();

        System.assertEquals(true, isUnscheduled, 'True should be returned for Off Day/Off Frequency');
    }
    
    @isTest
    static void testGetPriorOrderUnscheduledReasons() {
		Account testAccount = getAccount();
		Order testOrder = getOrder();
        PriceBook2 testPriceBook = getPriceBook();
        PriceBookEntry testPriceBookEntry = getPriceBookEntry();        
        Product2 testProduct = getProductByName('Test Product');
        Order testOrder2 = TestFactory.createOrder(testAccount.Id, testPriceBook.Id, System.today()-2, 'Pending Draft');
		TestFactory.createOrderItem(testPriceBookEntry.Id, testOrder2.Id, 1, 2, 11.99, testProduct.Id);      
        testOrder2.Unscheduled_Reason_Code__c = 'RBD Out of Stock';
        testOrder2.Off_Day__c = true;
        testOrder2.Status = 'Posted to VIP';
        update testOrder2;

        Test.startTest();
            List<String> priorUnscheduled = OrderEntryController.getPriorOrderUnscheduledReasons(testOrder.Id);
        Test.stopTest();

        System.assertEquals(1, priorUnscheduled.size(), '1 Prior unscheduled Order should be found');
    }  
    
    @isTest
    static void testSetUnscheduled() {
        Order testOrder = getOrder();

        Test.startTest();
            OrderEntryController.setUnscheduled(testOrder.Id, 'RBD Out of Stock', null);        
        Test.stopTest();

        Order compareOrder = getOrder();        
        System.assertEquals('RBD Out of Stock', compareOrder.Unscheduled_Reason_Code__c, 'Off Day/Off Frequency should be updated to RBD Out of Stock');
    }
    
    @isTest
    static void testValidateOrderNoOrderItems() {
        Order testOrder = getOrder();
        Account testAccount = getAccount();

        Test.startTest();
            List<String> errorMsgList = OrderEntryController.validateOrder(new List<OrderItem>(), System.today(), testAccount, null, 'Text To Order','');
        Test.stopTest();

        System.assertEquals(1, errorMsgList.size(), '1 error msg should be returned');
    }

    @isTest
    static void testValidateOrderOrderItemsErrors() {
        Order testOrder = getOrder();
        OrderItem testOrderItem = getOrderItem();
        testOrderItem.Quantity_Order__c = 2;
        testOrderItem.Inventory__c = 1;
        Account testAccount = getAccount();
        testAccount.Require_PO__c = true;
        testAccount.Status__c = 'O';
        testAccount.LicenseExpirationDate__c = System.today() - 2;
        update testAccount;

        Test.startTest();
            List<String> errorMsgList = OrderEntryController.validateOrder(new List<OrderItem>{testOrderItem}, null, testAccount, null, 'Text To Order','');
        Test.stopTest();

        System.assertEquals(4, errorMsgList.size(), '4 error msgs should be returned');
    }

    @isTest
    static void testGetAccountPricebookProductsPostedToVIPSuggested() {
        Order testOrder = getOrder();
        testOrder.Status = 'Posted To VIP';
        update testOrder;
        OrderItem testOrderItem = getOrderItem();
        testOrderItem.Suggested__c = true;
        update testOrderItem;

        Test.startTest();
            List<OrderEntryController.AccountPricebookProducts> testAccountProducts = OrderEntryController.getAccountPricebookProducts(testOrder);
        Test.stopTest();

        System.assertEquals(1, testAccountProducts.size(), 'Should be 1 product returned');
    }

    @isTest
    static void testGetAccountPricebookProductsPostedToVIPMandate() {
        Order testOrder = getOrder();
        testOrder.Status = 'Posted To VIP';
        update testOrder;
        OrderItem testOrderItem = getOrderItem();
        testOrderItem.Mandate__c = true;
        update testOrderItem;

        Test.startTest();
            List<OrderEntryController.AccountPricebookProducts> testAccountProducts = OrderEntryController.getAccountPricebookProducts(testOrder);
        Test.stopTest();

        System.assertEquals(1, testAccountProducts.size(), 'Should be 1 product returned');
    }

    @isTest
    static void testGetAccountPricebookProductsPostedToVIPInvoice() {
        Order testOrder = getOrder();
        testOrder.Status = 'Posted To VIP';
        update testOrder;
        OrderItem testOrderItem = getOrderItem();
        testOrderItem.Invoice__c = true;
        update testOrderItem;

        Test.startTest();
            List<OrderEntryController.AccountPricebookProducts> testAccountProducts = OrderEntryController.getAccountPricebookProducts(testOrder);
        Test.stopTest();

        System.assertEquals(1, testAccountProducts.size(), 'Should be 1 product returned');
    }

    @isTest
    static void testGetAccountPricebookProductsPostedToVIPPinned() {
        Order testOrder = getOrder();
        testOrder.Status = 'Posted To VIP';
        update testOrder;
        OrderItem testOrderItem = getOrderItem();
        testOrderItem.Pinned__c = true;
        update testOrderItem;

        Test.startTest();
            List<OrderEntryController.AccountPricebookProducts> testAccountProducts = OrderEntryController.getAccountPricebookProducts(testOrder);
        Test.stopTest();

        System.assertEquals(1, testAccountProducts.size(), 'Should be 1 product returned');
    }

    @isTest
    static void testGetAccountPricebookProductsPostedToVIPNone() {
        Order testOrder = getOrder();
        testOrder.Status = 'Posted To VIP';
        update testOrder;
        OrderItem testOrderItem = getOrderItem();

        Test.startTest();
            List<OrderEntryController.AccountPricebookProducts> testAccountProducts = OrderEntryController.getAccountPricebookProducts(testOrder);
        Test.stopTest();

        System.assertEquals(1, testAccountProducts.size(), 'Should be 1 product returned');
    }

    @isTest
    static void testGetPricingDetailForProduct(){
        Order testOrder = getOrder();
        OrderEntryController.AccountPricebookProducts accountPricebookProductObj = new OrderEntryController.AccountPricebookProducts();
        accountPricebookProductObj.item = '12345';
        String accountPricebookObjString = JSON.serialize(accountPricebookProductObj);

        HttpResponse res = new HttpResponse();
        res.setBody('{  "WarehouseInventoryResponse": {    "AccountNumber": "55264",    "ItemRecords": [      {        "ItemCode": "12345",        "AvailableQty": 0,        "RemainingAllocationQty": 0,        "AvailableCTCQty": 0,        "CasesPerTier": 8,        "RoundToNextTier": false      }    ]  },  "ItemPriceResponse": {    "AccountNumber": "55264",    "AnticipatedDeliveryDate": "20201209",    "ItemPriceRecords": [      {        "ItemCode": "12345",        "CasePrice": 36.85,        "UnitPrice": 1.54,        "CaseDeposit": 0,        "UnitDeposit": 0,        "CasePostOff": 0,        "UnitPostOff": 0,        "CaseCRV": 0,        "UnitCRV": 0,        "SSP": 0,        "MinCasePrice": 0,        "MinUnitPrice": 0,        "BlockPriceOverride": false,        "InvoiceType": "B",        "ARType": null,        "Taxes": [          {            "TaxID": "TAX01"          },          {            "TaxID": "TAX05"          }        ]      }    ],    "ItemDealRecords": null,    "DealDetailRecords": null,    "DealBreakRecords": null  }}');
        res.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));

        Test.startTest();
            List<OrderEntryController.AccountPricebookProducts> accountProducts = OrderEntryController.getPricingDetailForProduct(testOrder.Id, accountPricebookObjString);
        Test.stopTest();

        System.assertEquals(1, accountProducts.size(), '1 accountProduct should be returned');
    }

    @isTest
    static void testGetPinnedProducts() {
        Order testOrder = getOrder();
        Product2 testProduct = getProductByName('Test Product2');
        Pricebook2 testPricebook = getPriceBookNotStandard();
        testPricebook.Type__c = 'Pinned';
        update testPricebook;
        PricebookEntry testPriceBookEntry = new PricebookEntry();
        testPriceBookEntry.Pricebook2Id = testPricebook.Id;
        testPriceBookEntry.Expiration_Date__c = System.today() + 5;
        testPriceBookEntry.Product2Id = testProduct.Id;
        testPriceBookEntry.UnitPrice = 11.99;
        testPriceBookEntry.UseStandardPrice = false;
        testPriceBookEntry.IsActive = true;
        insert testPriceBookEntry;
        OrderItem testOrderItem = getOrderItem();
        testOrderItem.Pinned__c = true;
        update testOrderItem;

        Test.startTest();
            List<OrderEntryController.AccountPricebookProducts> testPinnedProducts = OrderEntryController.getPinnedProducts(testOrder.Id);
        Test.stopTest();

        System.assertEquals(2, testPinnedProducts.size(), '2 records should be returned');
    }

    @isTest
    static void testInsertUpdateOrderItemRecordsInsertSuggested() {
        Account testAccount = getAccount();
        PriceBook2 testPriceBook = getPriceBook();
        Order testOrder = TestFactory.createOrder(testAccount.Id, testPriceBook.Id, System.today(), 'Pending Draft');
        Product2 testProd = TestFactory.createProduct('Test Product3', '12347', 'Coors2', '125*B');
        TestFactory.createPriceBookEntry(testPriceBook.Id, testProd.Id, 13.99, false, true);
        String productsToUpdateInsert = '[{"caseCRV":0,"caseDeposit":0,"casePostOff":0,"casePrice":29.4,"defaultProd":true,"exPrice":29.4,"iconAltText":"Hot In The Area","iconClass":"suggested","iconDesc":"Suggested Item","iconName":"utility:trending","id":"' + testProd.Id + '","invoiceProd":false,"item":"10158","ItemRecords":[{"dealBreakRecords":[{"amount":2.8,"performanceAmount":0,"quantity":90}],"dealDescription":"CORONA LSE BTL GM21","dealId":"CR24PLGM21","dealType":"A","individualFlag":"N","performanceFlag":"N"}],"name":"CORONA B24 12OZ LSE","newProd":false,"orderId":"' + testOrder.Id + '","pinnedProd":false,"pkg":"B24 12OZ LSE","pkgType":"Bottle","qty":"1","qtyAvail":24652,"showRecordIcon":true,"stock":true,"unitCRV":0,"unitDeposit":0,"unitDiscount":0,"unitPostOff":0,"unitPrice":1.23,"key":"' + testProd.Id + '1","checked":false}]';

        Test.startTest();
            List<OrderItem> testOrderItems = OrderEntryController.insertUpdateOrderItemRecords(testOrder.Id, productsToUpdateInsert, new List<String>{testProd.Id});
        Test.stopTest();

        System.assertEquals(1, testOrderItems.size(), '1 record should be returned');
    }

    @isTest
    static void testInsertUpdateOrderItemRecordsInsertMandate() {
        Account testAccount = getAccount();
        PriceBook2 testPriceBook = getPriceBook();
        Order testOrder = TestFactory.createOrder(testAccount.Id, testPriceBook.Id, System.today(), 'Pending Draft');
        Product2 testProd = TestFactory.createProduct('Test Product3', '12347', 'Coors2', '125*B');
        TestFactory.createPriceBookEntry(testPriceBook.Id, testProd.Id, 13.99, false, true);
        String productsToUpdateInsert = '[{"caseCRV":0,"caseDeposit":0,"casePostOff":0,"casePrice":29.4,"defaultProd":true,"exPrice":29.4,"iconAltText":"Mandate Gap","iconClass":"manadate","iconDesc":"mandate","iconName":"utility:mandate","id":"' + testProd.Id + '","invoiceProd":false,"item":"10158","ItemRecords":[{"dealBreakRecords":[{"amount":2.8,"performanceAmount":0,"quantity":90}],"dealDescription":"CORONA LSE BTL GM21","dealId":"CR24PLGM21","dealType":"A","individualFlag":"N","performanceFlag":"N"}],"name":"CORONA B24 12OZ LSE","newProd":false,"orderId":"' + testOrder.Id + '","pinnedProd":false,"pkg":"B24 12OZ LSE","pkgType":"Bottle","qty":"1","qtyAvail":24652,"showRecordIcon":true,"stock":true,"unitCRV":0,"unitDeposit":0,"unitDiscount":0,"unitPostOff":0,"unitPrice":1.23,"key":"' + testProd.Id + '1","checked":false,"requestedQty":1}]';

        Test.startTest();
            List<OrderItem> testOrderItems = OrderEntryController.insertUpdateOrderItemRecords(testOrder.Id, productsToUpdateInsert, new List<String>{testProd.Id});
        Test.stopTest();

        System.assertEquals(1, testOrderItems.size(), '1 record should be returned');
    }

    @isTest
    static void testInsertUpdateOrderItemRecordsInsertInvoice() {
        Account testAccount = getAccount();
        PriceBook2 testPriceBook = getPriceBook();
        Order testOrder = TestFactory.createOrder(testAccount.Id, testPriceBook.Id, System.today(), 'Pending Draft');
        Product2 testProd = TestFactory.createProduct('Test Product3', '12347', 'Coors2', '125*B');
        TestFactory.createPriceBookEntry(testPriceBook.Id, testProd.Id, 13.99, false, true);
        String productsToUpdateInsert = '[{"caseCRV":0,"caseDeposit":0,"casePostOff":0,"casePrice":29.4,"defaultProd":true,"exPrice":29.4,"iconAltText":"Invoice","iconClass":"invoice","iconDesc":"invoice","id":"' + testProd.Id + '","invoiceProd":true,"item":"10158","ItemRecords":[{"dealBreakRecords":[{"amount":2.8,"performanceAmount":0,"quantity":90}],"dealDescription":"CORONA LSE BTL GM21","dealId":"CR24PLGM21","dealType":"A","individualFlag":"N","performanceFlag":"N"}],"name":"CORONA B24 12OZ LSE","newProd":false,"orderId":"' + testOrder.Id + '","pinnedProd":false,"pkg":"B24 12OZ LSE","pkgType":"Bottle","qty":"1","qtyAvail":24652,"showRecordIcon":true,"stock":true,"unitCRV":0,"unitDeposit":0,"unitDiscount":0,"unitPostOff":0,"unitPrice":1.23,"key":"' + testProd.Id + '1","checked":false,"requestedQty":1}]';

        Test.startTest();
            List<OrderItem> testOrderItems = OrderEntryController.insertUpdateOrderItemRecords(testOrder.Id, productsToUpdateInsert, new List<String>{testProd.Id});
        Test.stopTest();

        System.assertEquals(1, testOrderItems.size(), '1 record should be returned');
    }


    @isTest
    static void testInsertUpdateOrderItemRecordsInsertPinned() {
        Account testAccount = getAccount();
        PriceBook2 testPriceBook = getPriceBook();
        Order testOrder = TestFactory.createOrder(testAccount.Id, testPriceBook.Id, System.today(), 'Pending Draft');
        Product2 testProd = TestFactory.createProduct('Test Product3', '12347', 'Coors2', '125*B');
        TestFactory.createPriceBookEntry(testPriceBook.Id, testProd.Id, 13.99, false, true);
        String productsToUpdateInsert = '[{"caseCRV":0,"caseDeposit":0,"casePostOff":0,"casePrice":29.4,"defaultProd":true,"exPrice":29.4,"iconAltText":"Pinned","iconClass":"pinned","iconDesc":"pinned","id":"' + testProd.Id + '","invoiceProd":false,"item":"10158","ItemRecords":[{"dealBreakRecords":[{"amount":2.8,"performanceAmount":0,"quantity":90}],"dealDescription":"CORONA LSE BTL GM21","dealId":"CR24PLGM21","dealType":"A","individualFlag":"N","performanceFlag":"N"}],"name":"CORONA B24 12OZ LSE","newProd":false,"orderId":"' + testOrder.Id + '","pinnedProd":false,"pkg":"B24 12OZ LSE","pkgType":"Bottle","qty":"1","qtyAvail":24652,"showRecordIcon":true,"stock":true,"unitCRV":0,"unitDeposit":0,"unitDiscount":0,"unitPostOff":0,"unitPrice":1.23,"key":"' + testProd.Id + '1","checked":false,"requestedQty":1}]';

        Test.startTest();
            List<OrderItem> testOrderItems = OrderEntryController.insertUpdateOrderItemRecords(testOrder.Id, productsToUpdateInsert, new List<String>{testProd.Id});
        Test.stopTest();

        System.assertEquals(1, testOrderItems.size(), '1 record should be returned');
    }

    @isTest
    static void testInsertUpdateOrderItemRecordsDelete() {
        Order testOrder = getOrder();
        Product2 testProduct = getProductByName('Test Product');
        OrderItem testOrderItem = getOrderItem();
        String productsToUpdateInsert = '[{"orderItemId": "' + testOrderItem.Id + '", "caseCRV":0,"caseDeposit":0,"casePostOff":0,"casePrice":29.4,"defaultProd":true,"exPrice":29.4,"iconAltText":"Hot In The Area","iconClass":"suggested","iconDesc":"Suggested Item","iconName":"utility:trending","id":"01t6g000003eRY1AAM","invoiceProd":false,"item":"10158","ItemRecords":[{"dealBreakRecords":[{"amount":2.8,"performanceAmount":0,"quantity":90}],"dealDescription":"CORONA LSE BTL GM21","dealId":"CR24PLGM21","dealType":"A","individualFlag":"N","performanceFlag":"N"}],"name":"CORONA B24 12OZ LSE","newProd":false,"orderId":"801q00000014j6EAAQ","pinnedProd":false,"pkg":"B24 12OZ LSE","pkgType":"Bottle","qty":"0","qtyAvail":24652,"showRecordIcon":true,"stock":true,"unitCRV":0,"unitDeposit":0,"unitDiscount":0,"unitPostOff":0,"unitPrice":1.23,"key":"01t6g000003eRY1AAM1","checked":false}]';

        Test.startTest();
            List<OrderItem> testOrderItems = OrderEntryController.insertUpdateOrderItemRecords(testOrder.Id, productsToUpdateInsert, new List<String>{testProduct.Id});
        Test.stopTest();

        System.assertEquals(0, testOrderItems.size(), '0 records should be returned');
    }

    @isTest
    static void testInsertUpdateOrderItemRecordsUpdate() {
        Order testOrder = getOrder();
        Product2 testProduct = getProductByName('Test Product');
        OrderItem testOrderItem = getOrderItem();
        String productsToUpdateInsert = '[{"orderItemId": "' + testOrderItem.Id + '", "caseCRV":0,"caseDeposit":0,"casePostOff":0,"casePrice":29.4,"defaultProd":true,"exPrice":29.4,"iconAltText":"Hot In The Area","iconClass":"suggested","iconDesc":"Suggested Item","iconName":"utility:trending","id":"01t6g000003eRY1AAM","invoiceProd":false,"item":"10158","ItemRecords":[{"dealBreakRecords":[{"amount":2.8,"performanceAmount":0,"quantity":90}],"dealDescription":"CORONA LSE BTL GM21","dealId":"CR24PLGM21","dealType":"A","individualFlag":"N","performanceFlag":"N"}],"name":"CORONA B24 12OZ LSE","newProd":false,"orderId":"801q00000014j6EAAQ","pinnedProd":false,"pkg":"B24 12OZ LSE","pkgType":"Bottle","qty":"2","qtyAvail":24652,"showRecordIcon":true,"stock":true,"unitCRV":0,"unitDeposit":0,"unitDiscount":0,"unitPostOff":0,"unitPrice":1.23,"key":"01t6g000003eRY1AAM1","checked":false}]';

        Test.startTest();
            List<OrderItem> testOrderItems = OrderEntryController.insertUpdateOrderItemRecords(testOrder.Id, productsToUpdateInsert, new List<String>{testProduct.Id});
        Test.stopTest();

        System.assertEquals(1, testOrderItems.size(), '1 record should be returned');
    }
    
    @isTest
    static void testDeleteOrderItem() {
        OrderItem testOrderItem = getOrderItem();

        Test.startTest();
            List<OrderItem> deleteOrderItem = OrderEntryController.deleteOrderItem(new List<String>{testOrderItem.Id});
        Test.stopTest();

        System.assertEquals(1, deleteOrderItem.size(), 'Should return 1 record');
    }

    @isTest
    static void testUpdatePriceBookEntry() {
        Order testOrder = getOrder();
        Product2 testProduct = getProductByName('Test Product2');
        Pricebook2 testPricebook = getPriceBookNotStandard();
        testPricebook.Type__c = 'Pinned';
        update testPricebook;
        PricebookEntry testPriceBookEntry = new PricebookEntry();
        testPriceBookEntry.Pricebook2Id = testPricebook.Id;
        testPriceBookEntry.Expiration_Date__c = System.today() + 5;
        testPriceBookEntry.Product2Id = testProduct.Id;
        testPriceBookEntry.UnitPrice = 11.99;
        testPriceBookEntry.UseStandardPrice = false;
        testPriceBookEntry.IsActive = true;
        insert testPriceBookEntry;
        OrderItem testOrderItem = getOrderItem();
        testOrderItem.Pinned__c = true;
        update testOrderItem;

        Test.startTest();
            PriceBookEntry testPricebookEntryObj = OrderEntryController.updatePriceBookEntry(testPriceBookEntry.Id, 'TestNotes', System.today() + 5);
        Test.stopTest();

        System.assertEquals('TestNotes', testPricebookEntryObj.Pinned_Notes__c, 'Should return TestNotes');
    }
}
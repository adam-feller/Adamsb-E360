@isTest
private class OrderEntryUtilityTest {

    @TestSetup
    private static void setup(){
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2346');
        Contact testContact = TestFactory.createContact(testAccount.Id, 'Test', 'Contact', 'test2@gmail.com');
        Pricebook2 testPriceBook = TestFactory.createPriceBook(testAccount.Id, testAccount.Name, true, 'Account Pricebook');
        Pricebook2 testStandardPriceBook = TestFactory.createStandardPriceBook();
        Product2 testProd = TestFactory.createProduct('Test Product', '12345', 'MillerCoors', '123*B');
        Product2 testProd2 = TestFactory.createProduct('Test Product2', '12346', 'MillerCoors', '124*B');
        Product2 testProd3 = TestFactory.createProduct('Test Product3', '12347', 'MillerCoors', '125*B');
        Product2 testProd4 = TestFactory.createProduct('Test Product4', '12348', 'MillerCoors', '126*B');
        testProd4.QuantityUnitOfMeasure = 'BW';
        update testProd4;
        TestFactory.createPriceBookEntry(testStandardPriceBook.Id, testProd.Id, 12.99, false, true);
        TestFactory.createPriceBookEntry(testStandardPriceBook.Id, testProd3.Id, 12.99, false, true);
        PriceBookEntry testPriceBookEntry = TestFactory.createPriceBookEntryInvoice(testPriceBook.Id, testProd.Id, 12.99, false, true, null);
        Order testOrder = TestFactory.createOrder(testAccount.Id, testPriceBook.Id, System.today(), 'Pending Draft');
        testOrder.Order_Placed_By__c = testContact.Id;
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

    static Account getAccount(String Name){
        return [SELECT Id, Name, VIP_Account_Number__c, Beer_Company__c, Warehouse__c, Territories__c, Sell_Type__c, Requested_Delivery_Days__c, Delivery_Frequency_Type__c,
                Batch_Call_Date_Created__c, Warehouse_Lookup__r.ISR_1__c, OwnerId
                FROM Account
                WHERE Name = :name
                LIMIT 1];
    }

    static Product2 getProductByName(String name){
        return [SELECT Id, QuantityUnitOfMeasure,Units_per_Case__c
                FROM Product2
                WHERE Name = :name
                LIMIT 1];
    }

    static PriceBookEntry getPriceBookEntry(String productId){
        return [SELECT Id, Name, Pricebook2Id, IsHidden__c, Expiration_Date__c
                FROM PriceBookEntry
                WHERE Product2Id = :productId
                LIMIT 1];
    }

    static Order getOrder(){
        return [SELECT Id, Name, Status, Pricebook2Id, AccountId
                FROM Order
                LIMIT 1];
    }

    static OrderItem getOrderItem(){
        return [SELECT Id, Type__c, Product2Id, Product2.SKU_External_Id__c, product2.Units_per_Case__c, Quantity_Order__c, UOM__c, Order_UOM__c, IsUnitQuantity__c
                FROM OrderItem
                LIMIT 1];
    }

    
    @isTest
    static void testHandleSuggestedSellData(){
        Order testOrder = getOrder();
        Account testAccount = getAccount('Test Account');

        HttpResponse res = new HttpResponse();
        res.setBody('[{"snapShotDatetime": "2021-01-26T07:30:43.28","openGapInd": "FALSE", "productExternalId": "123*B","customerExternalId": "72245","displaySequence": 1}]');
        res.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));

        Test.startTest();
            List<OrderEntryController.AccountPricebookProducts> accountProducts = OrderEntryUtility.handleSuggestedSellData(res, testAccount.Id, testOrder.Id);
        Test.stopTest();

        System.assertNotEquals(accountProducts, null, 'accountProducts should not be null');
    }

    @isTest
    static void testHandleSuggestedSellDataOrderItem(){
        Order testOrder = getOrder();
        Product2 testProd = getProductByName('Test Product3');
        PriceBookEntry testPriceBookEntry = TestFactory.createPriceBookEntryInvoice(testOrder.PriceBook2Id, testProd.Id, 12.99, false, true, null);
        OrderItem testOrderItem = TestFactory.createOrderItem(testPriceBookEntry.Id, testOrder.Id, 1, 2, 11.99, testProd.Id);
        testOrderItem.Suggested__c = true;
        update testOrderItem;
        Account testAccount = getAccount('Test Account');

        HttpResponse res = new HttpResponse();
        res.setBody('[{"snapShotDatetime": "2021-01-26T07:30:43.28","openGapInd": "FALSE", "productExternalId": "123*B","customerExternalId": "72245","displaySequence": 1}]');
        res.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));

        Test.startTest();
            List<OrderEntryController.AccountPricebookProducts> accountProducts = OrderEntryUtility.handleSuggestedSellData(res, testAccount.Id, testOrder.Id);
        Test.stopTest();

        System.assertNotEquals(accountProducts, null, 'accountProducts should not be null');
    }

    @isTest
    static void testHandleMandateData(){
        Order testOrder = getOrder();
        Account testAccount = getAccount('Test Account');
        String todaysDate = String.valueOf(System.today());
        String nextWeek = String.valueOf(System.today() + 7);

        HttpResponse res = new HttpResponse();
        String body = '[{"salesforceMandateId": "a002g000002HjNvAAK","mandateMetInd": "FALSE","openGapInd": "TRUE","mandateType": "None","startDate": "' + todaysDate + '","endDate": "' + nextWeek + '","sourceId": "GBX","customer": {"id": "ZE446", "desc": "APPLEBEE\'S - YUBA CITY" }, "salesOrg": { "id": "GB4", "desc": "GOLDEN BRANDS - CHICO" }, "salesManager": { "id": "4092", "desc": "THORNTON/CHICO" }, "warehouseInfo": { "id": "CHICO", "desc": "CHICO" }, "product1": { "id": "123*B", "desc": "C24 12OZ 6P", "upc": "87692006787", "subBrand": { "id": "ABCDEFGHIJKLM", "desc": "TRULY WILD BRY" }, "brand": { "id": "A0O", "desc": "TRULY" }, "container": "Can", "invoiceDate": "2020-05-22", "invoiceNumber": "755917", "soldInd": "TRUE" }, "product2": { "id": "124*B", "desc": "C24 12OZ 6P", "upc": "87692006787", "subBrand": { "id": "JWS", "desc": "TRULY WILD BRY" }, "brand": { "id": "A0O", "desc": "TRULY" }, "container": "Can", "invoiceDate": "2020-05-22", "invoiceNumber": "755917", "soldInd": "TRUE" }, "product3": { "id": "125*B", "desc": "C24 12OZ 6P", "upc": "87692006787", "subBrand": { "id": "JWS", "desc": "TRULY WILD BRY" }, "brand": { "id": "A0O", "desc": "TRULY" }, "container": "Can", "invoiceDate": "2020-05-22", "invoiceNumber": "755917", "soldInd": "TRUE" }, "product4": { "id": "126*B", "desc": "C24 12OZ 6P", "upc": "87692006787", "subBrand": { "id": "JWS", "desc": "TRULY WILD BRY" }, "brand": { "id": "A0O", "desc": "TRULY" }, "container": "Can", "invoiceDate": "2020-05-22", "invoiceNumber": "755917", "soldInd": "TRUE" } }]';
        res.setBody(body);
        res.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));

        Test.startTest();
            List<OrderEntryController.AccountPricebookProducts> accountProducts = OrderEntryUtility.handleMandateData(res, testOrder.Id, '10');
        Test.stopTest();

        System.assertNotEquals(accountProducts, null, 'accountProducts should not be null');
    }

    @isTest
    static void testHandleMandateDataOrderItem(){
        Order testOrder = getOrder();
        Account testAccount = getAccount('Test Account');
        Product2 testProd = getProductByName('Test Product3');
        PriceBookEntry testPriceBookEntry = TestFactory.createPriceBookEntryInvoice(testOrder.PriceBook2Id, testProd.Id, 12.99, false, true, null);
        OrderItem testOrderItem = TestFactory.createOrderItem(testPriceBookEntry.Id, testOrder.Id, 1, 2, 11.99, testProd.Id);
        testOrderItem.Mandate__c = true;
        update testOrderItem;
        String todaysDate = String.valueOf(System.today());
        String nextWeek = String.valueOf(System.today() + 7);

        HttpResponse res = new HttpResponse();
        String body = '[{"salesforceMandateId": "a002g000002HjNvAAK","mandateMetInd": "FALSE","openGapInd": "TRUE","mandateType": "None","startDate": "' + todaysDate + '","endDate": "' + nextWeek + '","sourceId": "GBX","customer": {"id": "ZE446", "desc": "APPLEBEE\'S - YUBA CITY" }, "salesOrg": { "id": "GB4", "desc": "GOLDEN BRANDS - CHICO" }, "salesManager": { "id": "4092", "desc": "THORNTON/CHICO" }, "warehouseInfo": { "id": "CHICO", "desc": "CHICO" }, "product1": { "id": "123*B", "desc": "C24 12OZ 6P", "upc": "87692006787", "subBrand": { "id": "ABCDEFGHIJKLM", "desc": "TRULY WILD BRY" }, "brand": { "id": "A0O", "desc": "TRULY" }, "container": "Can", "invoiceDate": "2020-05-22", "invoiceNumber": "755917", "soldInd": "TRUE" }, "product2": { "id": "124*B", "desc": "C24 12OZ 6P", "upc": "87692006787", "subBrand": { "id": "JWS", "desc": "TRULY WILD BRY" }, "brand": { "id": "A0O", "desc": "TRULY" }, "container": "Can", "invoiceDate": "2020-05-22", "invoiceNumber": "755917", "soldInd": "TRUE" }, "product3": { "id": "125*B", "desc": "C24 12OZ 6P", "upc": "87692006787", "subBrand": { "id": "JWS", "desc": "TRULY WILD BRY" }, "brand": { "id": "A0O", "desc": "TRULY" }, "container": "Can", "invoiceDate": "2020-05-22", "invoiceNumber": "755917", "soldInd": "TRUE" }, "product4": { "id": "126*B", "desc": "C24 12OZ 6P", "upc": "87692006787", "subBrand": { "id": "JWS", "desc": "TRULY WILD BRY" }, "brand": { "id": "A0O", "desc": "TRULY" }, "container": "Can", "invoiceDate": "2020-05-22", "invoiceNumber": "755917", "soldInd": "TRUE" } }]';
        res.setBody(body);
        res.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));

        Test.startTest();
            List<OrderEntryController.AccountPricebookProducts> accountProducts = OrderEntryUtility.handleMandateData(res, testOrder.Id, '10');
        Test.stopTest();

        System.assertNotEquals(accountProducts, null, 'accountProducts should not be null');
    }

    @isTest
    static void testPriceInventoryDetails(){
        OrderEntryController.AccountPricebookProducts testAccountPricebookProduct = new OrderEntryController.AccountPricebookProducts();
        testAccountPricebookProduct.item = '123*B';
        HttpResponse res = new HttpResponse();
        res.setBody('{  "WarehouseInventoryResponse": {    "AccountNumber": "55264",    "ItemRecords": [      {        "ItemCode": "12345",        "AvailableQty": 0,        "RemainingAllocationQty": 0,        "AvailableCTCQty": 0,        "CasesPerTier": 8,        "RoundToNextTier": false      }    ]  },  "ItemPriceResponse": {    "AccountNumber": "55264",    "AnticipatedDeliveryDate": "20201209",    "ItemPriceRecords": [      {        "ItemCode": "12345",        "CasePrice": 36.85,        "UnitPrice": 1.54,        "CaseDeposit": 0,        "UnitDeposit": 0,        "CasePostOff": 0,        "UnitPostOff": 0,        "CaseCRV": 0,        "UnitCRV": 0,        "SSP": 0,        "MinCasePrice": 0,        "MinUnitPrice": 0,        "BlockPriceOverride": false,        "InvoiceType": "B",        "ARType": null,        "Taxes": [          {            "TaxID": "TAX01"          },          {            "TaxID": "TAX05"          }        ]      }    ],    "ItemDealRecords": null,    "DealDetailRecords": null,    "DealBreakRecords": null  }}');
        res.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));

        Test.startTest();
            List<OrderEntryController.AccountPricebookProducts> accountProducts = OrderEntryUtility.priceInventoryDetails('55264', 'FGC', System.today(), new List<OrderEntryController.AccountPricebookProducts>{testAccountPricebookProduct});
        Test.stopTest();

        System.assertEquals(accountProducts.size(), 1, '1 accountProduct should be returned');
    }

    @isTest
    static void testGetPriceInventoryLineItems(){
        Test.startTest();
            List<OrderEntryUtility.PriceInventoryLineItems> priceInventoryLineItemList = OrderEntryUtility.getPriceInventoryLineItems(new Set<String>{'12345'});
        Test.stopTest();

        System.assertEquals(priceInventoryLineItemList.size(), 1, '1 record should be returned');
    }

    @isTest
    static void testHandlePriceInventoryData(){
        OrderEntryController.AccountPricebookProducts testAccountPricebookProduct = new OrderEntryController.AccountPricebookProducts();
        testAccountPricebookProduct.item = '12345';
        HttpResponse res = new HttpResponse();
        res.setBody('{ "WarehouseInventoryResponse": { "AccountNumber": "55264", "ItemRecords": [ { "ItemCode": "012345", "AvailableQty": 0, "RemainingAllocationQty": 0, "AvailableCTCQty": 0, "CasesPerTier": 8, "RoundToNextTier": false } ] }, "ItemPriceResponse": { "AccountNumber": "55264", "AnticipatedDeliveryDate": "20201209", "ItemPriceRecords": [ { "ItemCode": "012345", "CasePrice": 36.85, "UnitPrice": 1.54, "CaseDeposit": 0, "UnitDeposit": 0, "CasePostOff": 0, "UnitPostOff": 0, "CaseCRV": 0, "UnitCRV": 0, "SSP": 0, "MinCasePrice": 0, "MinUnitPrice": 0, "BlockPriceOverride": false, "InvoiceType": "B", "ARType": null, "Taxes": [ { "TaxID": "TAX01" }, { "TaxID": "TAX05" } ] } ], "ItemDealRecords": [ { "ItemCode": "012345", "DealID": "CR24PLGM21", "Level": 2, "ShowIndicator": true } ], "DealDetailRecords": [ { "DealID": "CR24PLGM21", "Level": 2, "DealDescription": "CORONA LSE BTL GM21", "DealType": "A", "IndividualFlag": "N", "PerformanceFlag": "N", "PerformancePromptOncePerOrder": null, "UnitDeal": "N" } ], "DealBreakRecords": [ { "DealID": "CR24PLGM21", "Level": 2, "ItemCode": "000000", "Quantity": 90, "Amount": 2.80, "PerformanceAmount": 0.00 } ]}}');
        res.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));

        Test.startTest();
            List<OrderEntryController.AccountPricebookProducts> accountProducts = OrderEntryUtility.handlePriceInventoryData(res, new List<OrderEntryController.AccountPricebookProducts>{testAccountPricebookProduct}, new Set<String>{'12345'});
        Test.stopTest();

        System.assertEquals(accountProducts.size(), 1, '1 accountProduct should be returned');
    }
    
    @isTest
    static void testHandlePriceInventoryDataBottle() {   //Test a product that has Bottle for Unit of Measure 
        OrderEntryController.AccountPricebookProducts testAccountPricebookProduct = new OrderEntryController.AccountPricebookProducts();
        testAccountPricebookProduct.item = '126*B';
        HttpResponse res = new HttpResponse();
        res.setBody('{ "WarehouseInventoryResponse": { "AccountNumber": "55264", "ItemRecords": [ { "ItemCode": "126*B", "AvailableQty": 0, "RemainingAllocationQty": 0, "AvailableCTCQty": 0, "CasesPerTier": 8, "RoundToNextTier": false } ] }, "ItemPriceResponse": { "AccountNumber": "55264", "AnticipatedDeliveryDate": "20201209", "ItemPriceRecords": [ { "ItemCode": "126*B", "CasePrice": 36.85, "UnitPrice": 1.54, "CaseDeposit": 0, "UnitDeposit": 0, "CasePostOff": 0, "UnitPostOff": 0, "CaseCRV": 0, "UnitCRV": 0, "SSP": 0, "MinCasePrice": 0, "MinUnitPrice": 0, "BlockPriceOverride": false, "InvoiceType": "B", "ARType": null, "Taxes": [ { "TaxID": "TAX01" }, { "TaxID": "TAX05" } ] } ], "ItemDealRecords": [ { "ItemCode": "126*B", "DealID": "CR24PLGM21", "Level": 2, "ShowIndicator": true } ], "DealDetailRecords": [ { "DealID": "CR24PLGM21", "Level": 2, "DealDescription": "CORONA LSE BTL GM21", "DealType": "A", "IndividualFlag": "N", "PerformanceFlag": "N", "PerformancePromptOncePerOrder": null, "UnitDeal": "N" } ], "DealBreakRecords": [ { "DealID": "CR24PLGM21", "Level": 2, "ItemCode": "000000", "Quantity": 90, "Amount": 2.80, "PerformanceAmount": 0.00 } ]}}');
        res.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));

        Test.startTest();
            List<OrderEntryController.AccountPricebookProducts> accountProducts = OrderEntryUtility.handlePriceInventoryData(res, new List<OrderEntryController.AccountPricebookProducts>{testAccountPricebookProduct}, new Set<String>{'126*B'});
        Test.stopTest();

        System.assertEquals(1, accountProducts.size(), '1 accountProduct should be returned');
    }


    @isTest
    static void testIsNull(){
        Test.startTest();
            Boolean isNull = OrderEntryUtility.isNull(null);
        Test.stopTest();

        System.assertEquals(isNull, true, 'isNull should be true');
    }

    @isTest
    static void testIsNotNull(){
        Test.startTest();
            Boolean isNull = OrderEntryUtility.isNull(12.99);
        Test.stopTest();

        System.assertEquals(isNull, false, 'isNull should be false');
    }

    @isTest
    static void testSubmitOrderValidateDetails(){
        Order testOrder = getOrder();
        OrderItem testOrderItem = getOrderItem();

        HttpResponse res = new HttpResponse();
        res.setBody('{"OrderID": "134565432"}');
        res.setStatusCode(201);

        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));

        Test.startTest(); 
            HttpResponse orderValidateResponse = OrderEntryUtility.submitOrderValidateDetails('03245', 'CO', '12345', 'FGC', '380', System.today(), testOrder.Id, 'Pending Draft', 'Web', new List<OrderItem>{testOrderItem});
        Test.stopTest();

        System.assertEquals(orderValidateResponse.getStatusCode(), 201, 'Status Code should be 201');
    }

    @isTest
    static void testGetOrderLineItemDetails(){
        OrderItem testOrderItem = getOrderItem();

        Test.startTest();
            List<OrderEntryUtility.OrderLineItem> orderItemList = OrderEntryUtility.getOrderLineItemDetails(new List<OrderItem>{testOrderItem});
        Test.stopTest();

        System.assertEquals(orderItemList.size(), 1, '1 record should be returned');
    }

    @isTest
    static void testAccountValidateDetails(){
        HttpResponse res = new HttpResponse();
        res.setBody('{"AccountRecords":[{"AccountNumber":"41824","PassFailFlag":"1","ErrorCode":"102","ErrorCodeDescription":"Account 41824 not found"}]}');
        res.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));

        Test.startTest();
            HttpResponse accountValidateResponse = OrderEntryUtility.accountValidateDetails('41824', 'FGC');
        Test.stopTest();

        System.assertEquals(accountValidateResponse.getStatusCode(), 200, 'Status Code should be 200');
    }


    @isTest
    static void testGetAccountARDetails(){
        OrderItem testOrderItem = getOrderItem();

        HttpResponse res = new HttpResponse();
        res.setBody('{  "AccountNumber": "55264",  "AnticipatedDeliveryDate": "20210226",  "PassFailFlag": " ",  "ErrorCode": "000",  "ErrorCodeDescription": "",  "TotalSales": 4590.00,  "TotalDeposit": 0.00,  "TotalDiscount": 525.00,  "TotalCRV": null,  "DeliveryCharge": 5.50,  "SalesTax": 128.26,  "TotalCredits": 0.00,  "OverShort": 0.00,  "TotalNetPrice": 4198.76,  "DetailRecords": [    {      "LineNumber": 0,      "ItemCode": "010290",      "Quantity": 150,      "UOM": "CB",      "PassFailFlag": " ",      "ErrorCode": "000",      "ErrorCodeDescription": "",      "AvailableQuantity": 154,      "UnitPrice": 30.60,      "UnitDiscount": 3.50,      "UnitDeposit": 0.00,      "UnitCRV": null,      "ExtendedPrice": 4065.00,      "TaxItemRecords": null    }  ]}');
        res.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));

        Test.startTest();
            OrderEntryUtility.AccountARDetails accountARDetailsObj = OrderEntryUtility.getAccountARDetails('55264', 'FGC', System.today(), new List<OrderItem>{testOrderItem});
        Test.stopTest();

        System.assertEquals(accountARDetailsObj.TotalSales, 4590.00, 'Total Sales should be 4590.00');
    }
    

    @isTest
    static void testGetBusinessUnitDetails(){
        Test.startTest();
            OrderEntryUtility.BusinessUnitVIPDetails testBusinessUnitObj = OrderEntryUtility.getBusinessUnitDetails('PVA');
        Test.stopTest();

        System.assertNotEquals(testBusinessUnitObj, null, 'Should not be null');
    }

    @isTest
    static void testGetBusinessUnitDetailsNull(){
        Test.startTest();
            OrderEntryUtility.BusinessUnitVIPDetails testBusinessUnitObj = OrderEntryUtility.getBusinessUnitDetails('HJL');
        Test.stopTest();

        System.assertEquals(testBusinessUnitObj, null, 'Should be null');
    }

    @isTest
    static void testAddOrderSummaryDetails(){
        Order testOrder = getOrder();
        OrderEntryUtility.AccountARDetails arDetailsObj = new OrderEntryUtility.AccountARDetails();
        arDetailsObj.TotalDeposit = 0;
        arDetailsObj.TotalCRV = 0;
        arDetailsObj.TotalDiscount = 0;
        arDetailsObj.SalesTax = 0;
        arDetailsObj.DeliveryCharge = 0;
        arDetailsObj.OverShort = 0;
        arDetailsObj.TotalCredits = 0;
        arDetailsObj.TotalSales = 10;
        arDetailsObj.TotalNetPrice = 10;
        String arDetailsString = JSON.serialize(arDetailsObj);

        Test.startTest();
            Order orderObj = OrderEntryUtility.addOrderSummaryDetails(arDetailsString, testOrder);
        Test.stopTest();

        System.assertEquals(orderObj.Total_Net_Price__c, 10, 'Total Net Price should be 10');
    }

}
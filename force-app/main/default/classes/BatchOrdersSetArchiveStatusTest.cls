@isTest
private class BatchOrdersSetArchiveStatusTest {
    @TestSetup
    private static void setup(){
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
        Date currentDate = Date.today();
        TestFactory.createPriceBookEntry(testStandardPriceBook.Id, testProd.Id, 12.99, false, true);
        TestFactory.createPriceBookEntry(testStandardPriceBook.Id, testProd2.Id, 11.99, false, true);
        Id orderRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Order').getRecordTypeId();
        Order testOrder1 = TestFactory.createOrderRecordType(testAccount.Id, testPriceBook.Id, System.today(), 'Pending Draft', orderRecordTypeId);
        testOrder1.Delivery_date__c = currentDate.addDays(-400);
        testOrder1.Order_Origin__c = 'Text To Order';
        update testOrder1;
        PriceBookEntry testPriceBookEntry = TestFactory.createPriceBookEntryInvoice(testPriceBook.Id, testProd.Id, 12.99, false, true, null);
        TestFactory.createOrderItem(testPriceBookEntry.Id, testOrder1.Id, 1, 2, 11.99, testProd.Id);
        Order testOrder = TestFactory.createOrder(testAccount.Id, testPriceBook.Id, System.today(), 'Pending Draft');
        testOrder.Delivery_date__c = currentDate.addDays(-400);
        testOrder.Order_Placed_By__c = testContact.Id;
        testOrder.Order_Origin__c = 'Text To Order';
        update testOrder;

    }

    static Order getOrder(){
        return [SELECT Id, Name, Status, Pricebook2Id, AccountId, Unscheduled_Reason_Code__c
                FROM Order
                LIMIT 1];
    }

    static Product2 getProductByName(String name){
        return [SELECT Id, QuantityUnitOfMeasure
                FROM Product2
                WHERE Name = :name
                LIMIT 1];
    }

    static OrderItem getOrderItem(){
        return [SELECT Id, Type__c, Product2Id, Product2.SKU_External_Id__c, Quantity_Order__c, UOM__c, Order_UOM__c, IsUnitQuantity__c
                FROM OrderItem
                LIMIT 1];
    }

    static Account getAccount(){
        return [SELECT Id, Name, Chain_Independent__c, ExternalId__c, VIP_Instance__c, VIP_Account_Number__c, Require_PO__c,
                Status__c, LicenseExpirationDate__c, Territories__c,Controllable__c
                FROM Account
                LIMIT 1];
    }
    
   @isTest
    static void testOrderArchiverBatch() {
        // Start the batch job
        Order updatedOrder = getOrder();
        Test.startTest();
        BatchOrdersSetArchiveStatus batchJob = new BatchOrdersSetArchiveStatus();
        batchJob.query =  'SELECT Id, Status' + 
                                            ' FROM Order' + 
                                            ' WHERE id = ' + '\'' + updatedOrder.id +'\'';
        Database.executeBatch(batchJob);
        Test.stopTest();

        // Verify the status field is updated
//            System.assertEquals('Archive', updatedOrder.Status);
    }

}
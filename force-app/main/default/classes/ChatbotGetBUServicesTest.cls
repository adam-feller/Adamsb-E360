@isTest
private class ChatbotGetBUServicesTest {
    @isTest
    private static void testGetBUServices() {
        Warehouse__c warehouse = new Warehouse__c(
            Name = 'FDC',
            OrderCutoff__c = System.now().time(),
            ThirdPartyforDraftService__c = true,
            ThirdPartyforPOS__c = true,
            PayforPOS__c = true,
            RequirePickupValidation__c = true,
            NeonsOnly__c = false,
            NoGlassware__c = true,
            PrintShopRequestsAvailable__c = true
        );
        insert warehouse;

        Account acc = new Account(
            Name = 'ChatbotGetBUServicesTest',
            ExternalId__c = 'ABC*12345',
            Warehouse__c = 'FDC',
            Warehouse_Lookup__c = warehouse.id
        );
        insert acc;

        Delivery_Date__c deliveryDate = new Delivery_Date__c(
            Delivery_Date__c = System.today().addDays(7),
            Account__c = acc.Id
        );
        insert deliveryDate;

        ChatbotGetBUServices.ResponsesInput input = new ChatbotGetBUServices.ResponsesInput();
        input.businessUnitId = 'ABC';
        input.accountNumber = '12345';

        List<ChatbotGetBUServices.ResponsesOutput> output = ChatbotGetBUServices.getBUServices(new List<ChatbotGetBUServices.ResponsesInput>{input});
        System.assertEquals(true, output[0].isThirdPartyForService);
        System.assertEquals(false, output[0].isNeonsOnly);
        System.assertEquals(System.today().addDays(7).format(), output[0].nextDeliveryDate);
    }
}
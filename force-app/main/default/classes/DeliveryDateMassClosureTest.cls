@isTest
private class DeliveryDateMassClosureTest {

    @TestSetup
    private static void setup(){
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        testAccount.Premise__c = 'On Premise';
        testAccount.Sell_Type__c = 'NATIONAL ACCTS';
        testAccount.Delivery_Frequency_Type__c = 'Weekly';
        update testAccount;
        TestFactory.createDeliveryDate(testAccount.Id, System.today(), 'Active');
    }

    @isTest
    public static void testMassCloseDeliveryDates(){
        List<DeliveryDateMassClosure.MassClosureInputs> inputs = new List<DeliveryDateMassClosure.MassClosureInputs>{new DeliveryDateMassClosure.MassClosureInputs()} ;
        inputs[0].warehouses = 'PDVA-CHANTILLY';
        inputs[0].deliveryDates = new List<Date>{System.today()};
        inputs[0].selectCities = false;
        inputs[0].summaryOnly = false;
        inputs[0].frequencies = 'Weekly';
        inputs[0].sellTypes = 'NATIONAL ACCTS';
        inputs[0].premises = 'On Premise';
        inputs[0].cities = new List<String>();

        
        Test.startTest();
            DeliveryDateMassClosure.massClose(inputs);
        Test.stopTest();
        
        List<Delivery_Date__c> deliveryDateList = [SELECT Id FROM Delivery_Date__c WHERE Status__c = 'Cancelled'];

        System.assertEquals(1, deliveryDateList.size());
    }
}
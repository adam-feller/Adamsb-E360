@isTest
private class BatchHolidayPlanningReversionDDTest {

    @TestSetup
    private static void setup(){
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        TestFactory.createDeliveryDate(testAccount.Id, System.today(), 'Active');
    }

    @isTest
    static void testBatchHolidayPlanningReversionDD(){
        Test.startTest();
            BatchHolidayPlanningReversionDD batchHPRD = new BatchHolidayPlanningReversionDD();
            batchHPRD.warehouses = 'PDVA-CHANTILLY;Other Warehouse';
            batchHPRD.planName = 'Test';
            batchHPRD.userEmail = 'test@gmail.com';
            batchHPRD.query = 'SELECT Id, Delivery_Date__c, Original_Delivery_Date__c, Account__r.Warehouse__c, Status__c' +
                            ' FROM Delivery_Date__c';
            database.executeBatch(batchHPRD, 200);
        Test.stopTest();

        List<Delivery_Date__c> deliveryDates = [SELECT Id, Status__c, Original_Delivery_Date__c FROM Delivery_Date__c];

        System.assertEquals(deliveryDates[0].Original_Delivery_Date__c, System.today(), 'Original Delivery Date should be Today');
    }
}
@isTest
private class BatchHolidayPlanningMassDelivCloseTest {

    @TestSetup
    private static void setup(){
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        testAccount.Delivery_Frequency_Type__c = 'Weekly';
        testAccount.Premise__c = 'On Premise';
        update testAccount;
        TestFactory.createDeliveryDate(testAccount.Id, System.today(), 'Active');
    }

    @isTest
    static void testBatchHolidayPlanningMassDeliveryClosure(){
        Test.startTest();
            BatchHolidayPlanningMassDeliveryClosure batchHPMC = new BatchHolidayPlanningMassDeliveryClosure();
            batchHPMC.originalDates = new List<Date>{System.today()};
            batchHPMC.warehouses = 'PDVA-CHANTILLY;TEST WAREHOUSE';
            batchHPMC.frequencies = 'A;Weekly';
            batchHPMC.citiesList = new List<String>();
            batchHPMC.sellTypes = 'INSIDE SALES;NATIONAL ACCTS';
            batchHPMC.premises = 'On Premise;Off Premise';
            batchHPMC.userEmail = 'test@gmail.com';
            batchHPMC.query = 'SELECT Id, Account__r.Warehouse__c, Delivery_Date__c, Status__c' +
                            ' FROM Delivery_Date__c';
            database.executeBatch(batchHPMC, 200);
        Test.stopTest();

        List<Delivery_Date__c> deliveryDates = [SELECT Id, Status__c FROM Delivery_Date__c];

        System.assertEquals(deliveryDates[0].Status__c, 'Cancelled', 'Status should be cancelled');
    }
}
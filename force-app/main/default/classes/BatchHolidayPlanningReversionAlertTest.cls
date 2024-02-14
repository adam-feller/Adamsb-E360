@isTest
private class BatchHolidayPlanningReversionAlertTest {

    @TestSetup
    private static void setup(){
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        TestFactory.createAlert('Test', System.today(), System.today() + 5, 'Test Alert', 'Account', testAccount.Id);
    }

    @isTest
    static void testBatchHolidayPlanningReversionAlertTest(){
        Test.startTest();
            BatchHolidayPlanningReversionAlert batchHPRA = new BatchHolidayPlanningReversionAlert();
            batchHPRA.query = 'SELECT Id, Account__r.Warehouse__c FROM Alert__c WHERE Account__r.Warehouse__c IN :warehouseList';
        	batchHPRA.warehouses = 'PDVA-CHANTILLY;Other Warehouse';
            database.executeBatch(batchHPRA, 200);
        Test.stopTest();

        List<Alert__c> alertList = [SELECT Id FROM Alert__c];

        System.assertEquals(alertList.size(), 0, '0 alerts should be returned');
    }
}
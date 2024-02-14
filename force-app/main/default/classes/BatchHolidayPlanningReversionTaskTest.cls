@isTest
private class BatchHolidayPlanningReversionTaskTest {

    @TestSetup
    private static void setup(){
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        Id callRecordType = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId();
        TestFactory.createTaskByRecordType('Test', callRecordType, 'Open', testAccount.Id, System.today());
    }

    @isTest
    static void testBatchHolidayPlanningReversionTask(){
        Test.startTest();
            BatchHolidayPlanningReversionTask batchHPRT = new BatchHolidayPlanningReversionTask();
            batchHPRT.warehouses = 'PDVA-CHANTILLY;Other Warehouse';
            batchHPRT.planName = 'Test';
            batchHPRT.userEmail = 'test@gmail.com';
            batchHPRT.query = 'SELECT Id, ActivityDate, Original_Call_Date__c, Account__r.Warehouse__c, Status FROM Task';
            database.executeBatch(batchHPRT, 200);
        Test.stopTest();

        List<Task> taskList = [SELECT Id, ActivityDate FROM Task];

        System.assertEquals(taskList[0].ActivityDate, System.today(), 'Original Delivery Date should be Today');
    }
}
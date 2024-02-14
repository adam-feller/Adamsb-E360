@isTest
private class SyncHolidayPlansTest {

    @TestSetup
    private static void setup(){
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        testAccount.Premise__c = 'On Premise';
        testAccount.Sell_Type__c = 'NATIONAL ACCTS';
        testAccount.Delivery_Frequency_Type__c = 'Weekly';
        update testAccount;
        TestFactory.createDeliveryDate(testAccount.Id, System.today(), 'Active');
        Id callRecordType = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId();
        TestFactory.createTaskByRecordType('Test', callRecordType, 'Open', testAccount.Id, System.today());
        TestFactory.createAlert('Test', System.today(), System.today() + 5, 'Test Alert', 'Account', testAccount.Id);
        TestFactory.createPlan('Test Plan', System.today(), null, String.valueOf(System.today()), '100',
                                null, 'Chicago', '2', 'On Premise', 'Presell', 'PDVA-CHANTILLY');
        TestFactory.createPlan('Test Plan 2', System.today() + 1, String.valueOf(System.today() + 1), null, null,
                                '100', 'Chicago', '3', 'Off Premise', 'Presell', 'PDVA-CHANTILLY');
    }

    @isTest
    public static void testSyncHolidayPlans(){
        Test.startTest();
            SyncHolidayPlans.syncHolidayPlans();
        Test.stopTest();

        List<Task> taskList = [SELECT Id, ActivityDate FROM Task];

        System.assertEquals(taskList[0].ActivityDate, System.today(), 'Original Delivery Date should be Today');
    }
}
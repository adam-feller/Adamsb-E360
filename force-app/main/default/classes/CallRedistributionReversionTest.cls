@isTest
private class CallRedistributionReversionTest {

    @TestSetup
    private static void setup(){
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        testAccount.Premise__c = 'On Premise';
        testAccount.Sell_Type__c = 'NATIONAL ACCTS';
        testAccount.Delivery_Frequency_Type__c = 'Weekly';
        update testAccount;
        TestFactory.createPlan('Test Plan', System.today(), null, String.valueOf(System.today()), '100',
                                null, null, 'Weekly', 'On Premise', 'NATIONAL ACCTS', 'PDVA-CHANTILLY');
        TestFactory.createDeliveryDate(testAccount.Id, System.today(), 'Active');
        Id callRecordType = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId();
        TestFactory.createTaskByRecordType('Test', callRecordType, 'Open', testAccount.Id, System.today());
        TestFactory.createAlert('Test', System.today(), System.today() + 5, 'Test Alert', 'Account', testAccount.Id);
    }

    static Plan__c getPlan(){
        return [SELECT Id
                FROM Plan__c
                LIMIT 1];
    }

    @isTest
    public static void testCallRedistributionReversion(){
        Plan__c testPlan = getPlan();
        List<CallRedistributionReversion.ReversionInputs> inputs = new List<CallRedistributionReversion.ReversionInputs>{new CallRedistributionReversion.ReversionInputs()} ;
        inputs[0].warehouses = 'PDVA-CHANTILLY';
        inputs[0].summaryOnly = false;
        inputs[0].planId = testPlan.Id;
        inputs[0].planName = 'NATIONAL ACCTS';

        Test.startTest();
            CallRedistributionReversion.revertPlan(inputs);
        Test.stopTest();

        List<Task> taskList = [SELECT Id, ActivityDate FROM Task];

        System.assertEquals(taskList[0].ActivityDate, System.today(), 'Original Delivery Date should be Today');
    }
}
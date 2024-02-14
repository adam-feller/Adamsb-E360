@isTest
private class BatchCallScheduleTest {

    @TestSetup
    private static void setup(){

        Id retailRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retail Store').getRecordTypeId();

        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        testAccount.Status__c = 'A';
        testAccount.RecordTypeId = retailRecordTypeId;
        testAccount.Sell_Type__c = 'INSIDE SALES';
        update testAccount;

    }

    static Account getAccount(String Name){
        return [SELECT Id, Name, VIP_Account_Number__c, Beer_Company__c, Warehouse__c, Territories__c
                FROM Account
                WHERE Name = :name
                LIMIT 1];
    }

    @isTest
    static void testScheduleBatchCallSchedule(){
        Account testAccount = getAccount('Test Account');
        testAccount.Requested_Delivery_Days__c = 'Monday';

        testAccount.Delivery_Frequency_Type__c = 'A';

        update testAccount;

        Test.startTest();
            BatchCallSchedule batchCallSchedule = new BatchCallSchedule();

            batchCallSchedule.query = 'SELECT Id, Name, Sell_Type__c, Requested_Delivery_Days__c, Delivery_Frequency_Type__c, Batch_Call_Date_Created__c, Warehouse_Lookup__r.ISR_1__c, OwnerId' +
                                    ' FROM Account';

            Database.executebatch(batchCallSchedule);
        Test.stopTest();
        
        List<Delivery_Date__c> deliveryDateInserted = [SELECT Id FROM Delivery_Date__c];
        List<Task> tasksInserted = [SELECT Id, ActivityDate, Delivery_Date__r.Delivery_Date__c FROM Task];

        System.assertNotEquals(deliveryDateInserted.size(), 0, 'Delivery Date records should be created');
        System.assertNotEquals(tasksInserted.size(), 0, 'Task records should be created');

    }
}
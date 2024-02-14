public class ScheduleBatchCallSchedule implements Schedulable{

    public void execute(SchedulableContext sc) {
        BatchCallSchedule batchCallSchedule = new BatchCallSchedule();
        Id retailAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retail Store').getRecordTypeId();
        batchCallSchedule.retailAccountRecordTypeId = retailAccountRecordTypeId;

        batchCallSchedule.query = 'SELECT Id, Name, Sell_Type__c, Requested_Delivery_Days__c, Delivery_Frequency_Type__c, Call_Days__c, Batch_Call_Date_Created__c, Warehouse_Lookup__r.ISR_1__c, OwnerId' +
                                 ' FROM Account' +
                                 ' WHERE RecordTypeId = :retailAccountRecordTypeId' +
                                 ' AND Status__c = \'A\'';

        Database.executebatch(batchCallSchedule);
    }
}
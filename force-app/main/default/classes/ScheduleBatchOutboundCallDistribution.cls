public class ScheduleBatchOutboundCallDistribution implements Schedulable{
    //***************************************************************************************
    // This is used to schedule the the Batch job to redistribute calls for the day (3:00 AM)
    // **************************************************************************************
    public void execute(SchedulableContext sc) {
        BatchOutboundCallDistribution batchCallDistribution = new BatchOutboundCallDistribution();
        //Parameters we are passing into the Batch job
        batchCallDistribution.callTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId();
        batchCallDistribution.today = System.today();
		batchCallDistribution.empId = null;   //The scheduled job will always pass null here because it is going to redistribute all calls
        //Call the batch job to process the Tasks
        Database.executebatch(batchCallDistribution, 10000);
    }
}
public class oooRedistribute {
    //*********************************************************************************
    // This is called from the "Redistribute Calls for Today" Flow which is invoked 
    // from the "Redistribute Outbound Calls" button on the Tasks listview
    // ********************************************************************************      
    public class FlowInputs {
        @InvocableVariable public String EmployeeToRedistribute;
    }
    
    @InvocableMethod
    public static void oooRedistributeCalls(List<FlowInputs> request){
        String empId = request[0].EmployeeToRedistribute;
        BatchOutboundCallDistribution batchCallDistribution = new BatchOutboundCallDistribution();
        //Parameters we are passing into the Batch job
        batchCallDistribution.callTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId();
        batchCallDistribution.today = System.today();
        batchCallDistribution.empId = empId;    //This will have a value if a User was selected in the flow, otherwise it will be null to redistribute all calls
        //Call the batch job to process the Tasks
        Database.executebatch(batchCallDistribution, 600);
    }
}
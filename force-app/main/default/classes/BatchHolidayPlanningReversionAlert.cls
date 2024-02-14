global class BatchHolidayPlanningReversionAlert implements Database.Batchable<sObject>,  Database.Stateful{

    public String planId;
    public String warehouses;
    public String query;

    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute

        //Split the warehouses and frequencies
        List<String> warehouseList = new List<String>();

        if(!String.isBlank(warehouses)){
                warehouseList = warehouses.split(';');
            }
    
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Alert__c> alertsToDelete) {
        List<Database.DeleteResult> alertDeleteResult = database.delete(alertsToDelete,false);
    }   
    
    global void finish(Database.BatchableContext BC) {

  }
}
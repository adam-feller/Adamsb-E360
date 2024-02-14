public class BatchOrdersSetArchiveStatus implements Database.Batchable<sObject> {
    public String query;
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Query for orders that need to be archived
        String query = 'SELECT Id, Status FROM Order WHERE Delivery_Date__c < LAST_N_DAYS:365 AND Status != \'Archive\' AND RecordType.Name = \'Order\' LIMIT 100000';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        List<Order> ordersToUpdate = new List<Order>();
        
        // Update the status of orders to "Archive"
        for (sObject record : scope) {
            Order orderrec = (Order)record;
            orderrec.Status = 'Archive';
            ordersToUpdate.add(orderrec);
        }
        
        // Update the orders in the database
        if (!ordersToUpdate.isEmpty()) {
            Database.update(ordersToUpdate, false);
        }
    }

    public void finish(Database.BatchableContext bc) {
        
    }
}
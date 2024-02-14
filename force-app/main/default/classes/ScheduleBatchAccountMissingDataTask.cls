public without sharing class ScheduleBatchAccountMissingDataTask implements Schedulable {
        
    public void execute(SchedulableContext sc) {
       
        BatchAccountMissingDataTask batchTaskCreation = new BatchAccountMissingDataTask();
        Database.executebatch(batchTaskCreation, 200);  
    }
}
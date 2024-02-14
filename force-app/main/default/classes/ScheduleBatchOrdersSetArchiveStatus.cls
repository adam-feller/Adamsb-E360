public without sharing class ScheduleBatchOrdersSetArchiveStatus implements Schedulable {
        
    public void execute(SchedulableContext sc) {
       
        BatchOrdersSetArchiveStatus batchorderArchive = new BatchOrdersSetArchiveStatus();
        Database.executebatch(batchorderArchive, 200);  
    }
}
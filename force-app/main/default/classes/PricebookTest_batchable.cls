public with sharing class PricebookTest_batchable implements Database.Batchable<sObject> {
    
    public PricebookTest_batchable(){
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([
            SELECT Id
        FROM PricebookEntry_Stage__c]);
    }

    public void execute(Database.BatchableContext BC, List<PricebookEntry_Stage__c> PESList){

    }
    
    public void finish(Database.BatchableContext BC){
       
    }

    public static void executeOnce(){

        List<AsyncApexJob> runningJobs = [
            SELECT ApexClass.Name, CompletedDate,ExtendedStatus,Id, JobItemsProcessed,JobType, Status 
            FROM AsyncApexJob 
            WHERE ApexClass.Name = 'PricebookTest_batchable'
            AND Status IN ('Queued', 'Preparing','Processing')
            AND JobType = 'BatchApex'
            LIMIT 1
        ];
        if (runningJobs.size() == 0){
            system.debug('Starting job');
            executeNow();
        } else {
            system.debug('already running job');
        }
    }

    public static void executeNow(){
        database.executeBatch(new PricebookTest_batchable(), 2000);
    }
}
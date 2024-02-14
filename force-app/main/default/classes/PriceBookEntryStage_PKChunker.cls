public with sharing class PriceBookEntryStage_PKChunker  implements Database.Batchable<sObject>, Schedulable {
    private Integer CHUNK_SIZE;
    public PriceBookEntryStage_PKChunker(){
        CHUNK_SIZE = 2000;
    }

    public PriceBookEntryStage_PKChunker(Integer size){
        CHUNK_SIZE = size;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        delete [SELECT ID FROM PK_CHUNK__c LIMIT 10000];
        return Database.getQueryLocator([
            SELECT Id
        FROM PricebookEntry_Stage__c ORDER BY ID ASC]);
    }

    public void execute(Database.BatchableContext BC, List<PricebookEntry_Stage__c> PESList){
        List<PK_CHUNK__c>  pkChunkList = new List<PK_CHUNK__c>();
        Integer startIndex = 0;
        Integer endIndex = CHUNK_SIZE-1;
        if(PESList.size() > 0){
            while (endIndex < PESList.size()){
                pkChunkList.add(new PK_CHUNK__c(
                    start_id__c	= PESList[startIndex].id,
                    end_id__c = PESList[endIndex].id,
                    Chunk_step__c = CHUNK_SIZE
                ));
                startIndex+=CHUNK_SIZE;
                endIndex+=CHUNK_SIZE;
                if (startIndex < PESList.size() && endIndex >=PESList.size() ) endIndex =PESList.size()-1;
            }
        }
        insert pkChunkList;
    }
    
    public void finish(Database.BatchableContext BC){
        PriceBookEntryStage_PKChunkBalancer chunkBalancer = new PriceBookEntryStage_PKChunkBalancer(10);
        // Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        DateTime now  = DateTime.now();
        DateTime nextRunTime = now.addMinutes(2);
        String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + 
            nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + 
            nextRunTime.month() + ' ? ' + nextRunTime.year(); 
        system.DEBUG(cronString);
        String jobID = System.schedule('Chunk Balancer - '+cronString, cronString, chunkBalancer);
    }

    public static void executeOnce(){

        List<AsyncApexJob> runningJobs = [
            SELECT ApexClass.Name, CompletedDate,ExtendedStatus,Id, JobItemsProcessed,JobType, Status 
            FROM AsyncApexJob 
            WHERE ApexClass.Name = 'PriceBookEntryStage_PKChunker'
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

    public void execute(SchedulableContext sc) {
        PriceBookEntryStage_PKChunker.executeNow();
     }

    public static void executeNow(){
        database.executeBatch(new PriceBookEntryStage_PKChunker(200), 2000);
    }
}
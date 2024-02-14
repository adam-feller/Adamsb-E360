global class PriceBookEntryStage_PKChunkBalancer  implements Schedulable {
    private Integer JOB_NUMBER;
    public PriceBookEntryStage_PKChunkBalancer(){
        JOB_NUMBER = 20;
    }

    public PriceBookEntryStage_PKChunkBalancer(Integer jobNumber){
        JOB_NUMBER = (jobNumber < 50) ? jobnumber : 50;
    }
    
    global void execute(SchedulableContext SC){ 
        createJobs(JOB_NUMBER);
    }

    private static void createJobs(Integer JobNumber){
        List<PK_CHUNK__c> chunkList= [SELECT id, start_id__c, end_id__c FROM PK_CHUNK__c ORDER BY id ASC];
        Integer i=0;
        Integer Step = chunkList.size()/JobNumber +1;   

        while (i < chunkList.size()){  
            String startId = chunkList[i].id;
            Integer endChunk = (i+step < chunkList.size()) ? i+step-1 : chunkList.size()-1;
            String endId = chunkList[endChunk].id ;
            i+=step;
            System.enqueueJob(new PriceBookEntryStage_ChunkProcessor(startId,endid));
            System.debug('Starting new job, start id = '+startId+', endid='+endid);
        }
    }

    public static void rebuildNow(Integer jobNumber){
        AsyncApexJob[] aList = [SELECT id FROM AsyncApexJob WHERE ApexClass.Name = 'PriceBookEntryStage_ChunkProcessor' AND Status IN ('Queued','Processing')];
        for(AsyncApexJob aJob : aList){
            system.abortJob(ajob.id);
        }
        createJobs(jobNumber);
    }
}
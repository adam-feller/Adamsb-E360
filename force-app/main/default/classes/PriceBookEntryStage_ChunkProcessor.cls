global without sharing class PriceBookEntryStage_ChunkProcessor implements Queueable{
    private String START_ID;
    private String END_ID;
    private integer RETRY_NUMBER;
    private integer RETRY_LIMIT = 3;
    

    public PriceBookEntryStage_ChunkProcessor(String startID, String endID) {
        START_ID = startId;
        END_ID = endId;
        RETRY_NUMBER = 0;
    }
    
    public PriceBookEntryStage_ChunkProcessor(Integer retryNumberInput, String startID, String endID) {
        START_ID = startId;
        END_ID = endId;
        RETRY_NUMBER = retryNumberInput;
    }

    global void execute(queueableContext QC){
        PK_CHUNK__c[] chunk = [SELECT id, start_id__c, end_id__c 
            FROM PK_CHUNK__c 
            WHERE id>= :START_ID  AND  id<=:END_ID 
            ORDER BY ID LIMIT 1];
        SYSTem.debug('Start id and end id');
        SYSTem.debug(START_ID);
        SYSTem.debug(END_ID);
        if (chunk.size() > 0  ){
            PricebookEntry_Stage__c[] PESList = [
                SELECT Id, CE_QTY__c, Discount_Amount__c, Expiration_Date__c, Extended_price_amt__c,
                External_Id__c, Flagged__c, Invoice_Line_Number__c, Invoice_External_Id__c, LastProcessedTime__c,
                Order_Date__c, Order_Method__c, Out_of_Stock_unit_Qty__c, Product_External_Id__c,
                Quantity_sold__c, Unit_Cost_Amount__c, Unit_Price_Amount__c, Unit_qty__c,
                VIP_Instance__c, WAREHOUSE_DIM_ID__c, SALES_ORG_DIM_ID__c, ErrorMessage__c
            FROM PricebookEntry_Stage__c  
            WHERE ID >= :chunk[0].start_id__c AND ID <= :chunk[0].end_id__c
            ORDER BY  Product_External_Id__c
            LIMIT 2000];

            for (PricebookEntry_Stage__c peStage: PESList){
                peStage.ErrorMessage__c = null;
            }

            if (InvoiceStagingHandler.isSavingInvoicesAsPricebookEntriesEnabled()) {
                List <Pricebook2> priceBooksToInsert = new List <Pricebook2>();
                List <PricebookEntry> priceBooksEntriesToInsert = new List <PricebookEntry>();
                //Create Pricebooks
                //Map<String,PricebookEntry_Stage__c> toInsert = new Map<String,PricebookEntry_Stage__c>();
                for (PricebookEntry_Stage__c peStage: PESList){
                        peStage.ErrorMessage__c = null;
                        Pricebook2 pb = new Pricebook2(
                            External_Id__c = peStage.External_Id__c,
                            isActive = true,
                            Name = peStage.External_Id__c,
                            Type__c = 'Invoice' 
                        );
                        priceBooksToInsert.add(pb);
                }
                processUpsertResult(PESList, database.upsert (priceBooksToInsert, Pricebook2.External_Id__c.getDescribe().getSObjectField(), false));
                Map<String,ID> pbeMap= new Map<String,ID>();
                for (Pricebook2 pbe : priceBooksToInsert){
                    pbeMap.put(pbe.External_Id__c, pbe.Id);
                }
                for (PricebookEntry_Stage__c peStage: PESList){
                        priceBooksEntriesToInsert.add(InvoiceStagingHandler.createPricebookEntry(peStage,pbeMap));
                }
                processUpsertResult(PESList, database.upsert (priceBooksEntriesToInsert,PricebookEntry.External_Id__c.getDescribe().getSObjectField(), false));
            }

            if (InvoiceStagingHandler.isSavingInvoicesAsOrdersEnabled()){
                List <OrderItem> orderItemsToInsert = new List <OrderItem>();
                for (PricebookEntry_Stage__c peStage: PESList){
                    orderItemsToInsert.add(InvoiceStagingHandler.createOrderItem(peStage));
                }
                processUpsertResult(PESList, database.upsert (orderItemsToInsert,orderitem.External_Id__c.getDescribe().getSObjectField(), false));
            }
            PricebookEntry_Stage__c[] PESUpdateList = new List<PricebookEntry_Stage__c>();
            PricebookEntry_Stage__c[] PESDeleteList = new List<PricebookEntry_Stage__c>();
            for (PricebookEntry_Stage__c iter: PESList){
                if (String.isEmpty(iter.ErrorMessage__c) ) PESDeleteList.add(iter);
                else PESUpdateList.add(iter);
            }
            system.debug('Errors size: '+PESUpdateList.size());
            system.debug('OK size: '+PESDeleteList.size());
            delete  PESDeleteList;
            update  PESUpdateList;
            if (PESUpdateList.size() > 0 && RETRY_NUMBER < RETRY_NUMBER){
                system.enqueueJob(new PriceBookEntryStage_ChunkProcessor(RETRY_NUMBER +1, START_ID, END_ID));
            } else {
                database.delete(chunk,false);
                system.enqueueJob(new PriceBookEntryStage_ChunkProcessor(START_ID, END_ID));
            }
        } else {
            //DONE
        } 
    }


    private static void processUpsertResult(PricebookEntry_Stage__c[] peStageRecords, Database.UpsertResult[] saveResults){
        for (Integer i = 0; i < peStageRecords.size(); i++){
            if (!saveResults[i].isSuccess()){
                if (saveResults[i].getErrors() != null && peStageRecords[i].ErrorMessage__c == null){
                    Database.Error err = saveResults[i].getErrors()[0];
                    peStageRecords[i].ErrorMessage__c = err?.getStatusCode() + ': '+ err?.getFields()+', '+ err?.getMessage();
                } else {
                    peStageRecords[i].ErrorMessage__c = 'Unknown error';
                }
            }
        }
    }
}
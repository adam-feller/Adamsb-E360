global without sharing class StandardPricebookHandler implements Queueable{
    private Set<id> productIds;
    //Returns a map of Product Ids mapped to correct StandardPriceBookEntries
    public static Map<id,id> checkOrFillStandardPricebookEntry(Set<id> productIds){
        return null;
    }
    public static Map<id,id> checkOrFillStandardPricebookoEntry(Set<id> productIds){
        Map<id,id> productToPriceBookMap = new Map<id,id>();
        List<PricebookEntry> peList 
            = PriceBookEntryDAO.getStandardPriceBookEntriesByProductIds(productIds);
        //and add them to the map
        for (PricebookEntry pe: peList){
            productToPriceBookMap.put(pe.Product2Id,pe.id);
        }
        Map<String, PricebookEntry> peCreateMap = new Map<String, PricebookEntry>();
        //if there is no entry, create it
        for (Id prodId : productIds){
            if(!productToPriceBookMap.containsKey(prodId)){
                peCreateMap.put(
                    PricebookDAO.getStdPriceBookId()+'_'+prodId,
                    new PricebookEntry(
                        IsActive = true,
                        Pricebook2Id = PricebookDAO.getStdPriceBookId(),
                        Product2Id = prodId,
                        UnitPrice = 0.0,
                        External_Id__c = PricebookDAO.getStdPriceBookId()+'_'+prodId
                    )
                );
            }
        }
        //upsert it. Upserting instead of inserting allows to 
        //avoid rare situations when a few new products orders 
        //are created at the very same time, resulting in duplicate entries causing the error
        upsert peCreateMap.values() External_Id__c;
        //and also add it to the map
        for(PricebookEntry pe: peCreateMap.values()){
            productToPriceBookMap.put(pe.Product2Id,pe.id);
        }
        return productToPriceBookMap;
    }

    public static void checkOrFillStandardPricebookEntryAsync(Set<id> productIds){
        system.enqueueJob(new StandardPricebookHandler(productIds));
    }

    public StandardPricebookHandler(Set<id> prodIds){
        productIds = prodIds;
    }

    global void execute(queueableContext QC){
        checkOrFillStandardPricebookoEntry(productIds);
    }
    
}
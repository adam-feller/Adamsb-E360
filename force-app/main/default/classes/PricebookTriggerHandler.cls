public without sharing class PricebookTriggerHandler {
    public static void upsertPriceBooks(List<Invoice__c> invoice) {
        List<String> externalId = new List<String>();
        List<PriceBook2> priceBook2 = new List<PriceBook2>();
        
        for(Invoice__c invoices : invoice) {
            externalId.add(invoices.External_Id__c);
        }

        List<PriceBook2> existingpriceBook2 = [Select ID, External_Id__c, AccountId__c, Type__c, isActive FROM PriceBook2 WHERE External_Id__c IN : externalId];
        if(existingpriceBook2.size() >0){
        for(PriceBook2 pb2 : existingpriceBook2){
            if(externalId.contains(pb2.External_Id__c)){
            for(Invoice__c invoices : invoice) {
                if(pb2.External_Id__c == invoices.External_Id__c){
                pb2.External_Id__c = invoices.External_Id__c;
                pb2.AccountId__c = invoices.AccountId__c; 
                pb2.isActive = true;
                pb2.Name = invoices.Name; 
                pb2.Type__c = 'Invoice';
                pb2.Id = pb2.Id;
            }
            }
        }
            priceBook2.add(pb2);
        }
        } else {
            for(Invoice__c invoices : invoice) {
                priceBook2.add(new PriceBook2(External_Id__c = invoices.External_Id__c, AccountId__c = invoices.AccountId__c, 
                isActive = true, Name = invoices.Name, Type__c = 'Invoice'));
            }
        }
        try{
            upsert priceBook2;
        }catch (DmlException e) {
            System.debug(e.getMessage());
        }
       
        
    }
}
public without sharing class PriceBookEntryDAO {
    public static List<PricebookEntry> getStandardPriceBookEntryByProduct(Id productId){
        return [SELECT Id 
                FROM PricebookEntry 
                WHERE product2Id = :productId AND
                isActive = true AND
                pricebook2Id = :PriceBookDAO.getStdPriceBookId()];
    }

    public static List<PricebookEntry> getStandardPriceBookEntriesByProductIds(Set<ID> productIds){
        return [SELECT Id,Product2Id 
                FROM PricebookEntry 
                WHERE product2Id IN :productIds AND
                isActive = true AND
                pricebook2Id = :PriceBookDAO.getStdPriceBookId()];
    }

    public static List<PricebookEntry> getPriceBookEntryByProductAndId(Id productId, Id priceBookId){
        return [SELECT Id 
                FROM PricebookEntry 
                WHERE product2Id = :productId AND
                isActive = true AND
                pricebook2Id = :priceBookId];
    }

    public static List<PricebookEntry> getPriceBookEntryByInvoiceAndType(Set<Id> invoiceIds, Boolean hidden){
        return [SELECT id, Invoice__r.Name, Invoice__c, Product2Id, Product2.SKU_External_Id__c, Invoice__r.Invoice_Date__c,
                Quantity_sold__c, IsHidden__c
                FROM PricebookEntry 
                WHERE Invoice__c IN :invoiceIds 
                AND isHidden__c = :hidden
                ORDER BY Invoice__r.Invoice_Date__c DESC];
    }

    public static List<PricebookEntry> getPriceBookEntryByInvoiceAndTypeAndProductId(Set<String> invoiceIds, String productId, Boolean hidden){
        return [SELECT id, Invoice__r.Name, Invoice__c, Product2Id, Product2.SKU_External_Id__c, Invoice__r.Invoice_Date__c,
                Quantity_sold__c, IsHidden__c
                FROM PricebookEntry 
                WHERE Invoice__c IN :invoiceIds 
                AND isHidden__c = :hidden
                AND Product2Id = :productId
                ORDER BY Invoice__r.Invoice_Date__c];
    }

    public static List<PricebookEntry> getPriceBookEntryByPriceBookAndProduct(Id priceBookId, Id productId){
        return [SELECT Id, Pinned_Notes__c, Product2Id, Product2.SKU_External_Id__c, Expiration_Date__c, Product2.Name,
                Product2.SKU_Package_Type__c, Product2.Pkg_Name__c, Product2.Cases_per_layer__c, Product2.Cases_per_pallet__c,
                Product2.Price__c, Product2.Case_equivalent__c, CreatedBy.Name, Product2.Sub_Style__c, Product2.Seasonal__c, Product2.Draft_Or_Package__c
                FROM PricebookEntry
                WHERE Pricebook2Id = :priceBookId
                AND Product2Id = :productId];
    }

    public static List<PricebookEntry> getPriceBookEntryByPriceBookAndExpirationDateHidden(Id priceBookId, Boolean hidden, Date expirationDate){
        return [SELECT Id, Pinned_Notes__c, Product2Id, Product2.SKU_External_Id__c, Expiration_Date__c, Product2.Name,
                Product2.SKU_Package_Type__c, Product2.Pkg_Name__c, Product2.Cases_per_layer__c, Product2.Cases_per_pallet__c,
                Product2.Price__c, Product2.Case_equivalent__c, CreatedBy.Name, Product2.Sub_Style__c, Product2.Seasonal__c, Product2.Draft_Or_Package__c
                FROM PricebookEntry
                WHERE Pricebook2Id = :priceBookId
                AND IsHidden__c = :hidden
                AND Expiration_Date__c > :expirationDate];
    }

    public static List<PricebookEntry> insertPriceBookEntries(List<PricebookEntry> priceBookEntriesToInsert){
        insert priceBookEntriesToInsert;
        return priceBookEntriesToInsert;
    }

    public static List<PricebookEntry> updatePriceBookEntries(List<PricebookEntry> priceBookEntriesToUpdate){
        update priceBookEntriesToUpdate;
        return priceBookEntriesToUpdate;
    }
}
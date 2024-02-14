public without sharing class ProductFeedbackDAO {
    
    public static List<Product_Feedback__c> getPinnedProductsByAccountandExpirationDate(Id accountId, Date expirationDate) {
        return [SELECT Id, Notes__c, Feedback__c, Product__c, Product__r.Id, Product__r.SKU_External_Id__c, Expiration_Date__c, Product__r.Name,
                Product__r.SKU_Package_Type__c, Product__r.Pkg_Name__c, Product__r.Cases_per_layer__c, Product__r.Cases_per_pallet__c, Product__r.IsActive, 
                Product__r.Price__c, Product__r.Case_equivalent__c, CreatedBy.Name, Product__r.Sub_Style__c, Product__r.Seasonal__c, Product__r.Draft_Or_Package__c, Product__r.QuantityUnitOfMeasure
                FROM Product_Feedback__c
                WHERE Account__c = :accountId
                AND Type__c = 'Pinned'
                AND IsHidden__c = false
                AND Expiration_Date__c > :expirationDate];
    }

    public static List<Product_Feedback__c> getPinnedProductsByProductIdsandExpirationDate(Set<Id> prodIds, Date expirationDate) {
        return [SELECT Id, Notes__c, Feedback__c, Product__c, Product__r.Id, Product__r.SKU_External_Id__c, Expiration_Date__c, Product__r.Name, Account__r.Id, 
                Product__r.SKU_Package_Type__c, Product__r.Pkg_Name__c, Product__r.Cases_per_layer__c, Product__r.Cases_per_pallet__c, Product__r.IsActive, 
                Product__r.Price__c, Product__r.Case_equivalent__c, CreatedBy.Name, Product__r.Sub_Style__c, Product__r.Seasonal__c, Product__r.Draft_Or_Package__c, Product__r.QuantityUnitOfMeasure
                FROM Product_Feedback__c
                WHERE Product__c IN :prodIds
                AND Type__c = 'Pinned'
                AND IsHidden__c = false
                AND Expiration_Date__c > :expirationDate];
    }

    public static Product_Feedback__c getProductFeedbackByAccountandProduct(Id accountId, Id productId) {
        return [SELECT Id, Notes__c, Feedback__c, Product__c, Product__r.Id, Product__r.SKU_External_Id__c, Expiration_Date__c, Product__r.Name,
                Product__r.SKU_Package_Type__c, Product__r.Pkg_Name__c, Product__r.Cases_per_layer__c, Product__r.Cases_per_pallet__c, Product__r.IsActive, 
                Product__r.Price__c, Product__r.Case_equivalent__c, CreatedBy.Name, Product__r.Sub_Style__c, Product__r.Seasonal__c, Product__r.Draft_Or_Package__c, Product__r.QuantityUnitOfMeasure
                FROM Product_Feedback__c
                WHERE Product__c = :productId
                AND Account__c = :accountId 
                AND isHidden__c = false
                LIMIT 1];
    }

    public static Product_Feedback__c getProductFeedbackById(Id existingId) {
        return [SELECT Id, Notes__c, Feedback__c, Product__c, Product__r.Id, Product__r.SKU_External_Id__c, Expiration_Date__c, Product__r.Name,
                Product__r.SKU_Package_Type__c, Product__r.Pkg_Name__c, Product__r.Cases_per_layer__c, Product__r.Cases_per_pallet__c, Product__r.IsActive, 
                Product__r.Price__c, Product__r.Case_equivalent__c, CreatedBy.Name, Product__r.Sub_Style__c, Product__r.Seasonal__c, Product__r.Draft_Or_Package__c, Product__r.QuantityUnitOfMeasure
                FROM Product_Feedback__c
                WHERE Id = :existingId 
                LIMIT 1];
    }

    public static Product_Feedback__c createProductFeedback(Id accountId, Id productId, String notes, Date expirationDate, String feedback, String typ) {
        Product_Feedback__c newProductFeedback = new Product_Feedback__c();
        newProductFeedback.Product__c = productId;
        newProductFeedback.Account__c = accountId;
        newProductFeedback.Notes__c = notes;
        newProductFeedback.Expiration_Date__c = expirationDate;
        newProductFeedback.Feedback__c = feedback;
        newProductFeedback.Type__c = typ;
        ProductFeedbackDAO.insertProductFeedback(new List<Product_Feedback__c>{newProductFeedback});
        return newProductFeedback;    
    }

    public static List<Product_Feedback__c> insertProductFeedback(List<Product_Feedback__c> productFeedbackToInsert) {
        insert productFeedbackToInsert;
        return productFeedbackToInsert;
    }

    public static List<Product_Feedback__c> updateProductFeedback(List<Product_Feedback__c> productFeedbackToUpdate) {
        update productFeedbackToUpdate;
        return productFeedbackToUpdate;
    }
    
}
public without sharing class PinnedProductsController {

    @AuraEnabled(cacheable = true)
    public static List<Product_Feedback__c> getPinnedProducts(String accountId) {
        List<Product_Feedback__c> pinnedProductLineItems = ProductFeedbackDAO.getPinnedProductsByAccountandExpirationDate(accountId, System.Today());
        return pinnedProductLineItems;
    }

    @AuraEnabled
    public static OrderEntryController.AccountPricebookProducts createPinnedProduct(String orderId, String accountId, String productId, String pinnedNotes, Date expirationDate, String feedback, String existingId) { 
        if (accountId == null) {
            //Get the order
            List<Order> orderList = OrderDAO.getOrderDetailsbyId(orderId);
            if (orderList.size() > 0) {
                accountId = orderList[0].accountId;
            }
        }        
        Product_Feedback__c newPinnedProduct;
        if (existingId != null && existingId != '') {
            newPinnedProduct = ProductFeedbackDAO.getProductFeedbackById(existingId); 
            newPinnedProduct.Notes__c = pinnedNotes;
            newPinnedProduct.Expiration_Date__c = expirationDate;
            newPinnedProduct.Feedback__c = feedback;
            ProductFeedbackDAO.updateProductFeedback(new List<Product_Feedback__c>{newPinnedProduct});
        } else {         
            try {
                newPinnedProduct = ProductFeedbackDAO.getProductFeedbackByAccountandProduct(accountId, productId);
                newPinnedProduct.Notes__c = pinnedNotes;
                newPinnedProduct.Expiration_Date__c = expirationDate;
                newPinnedProduct.Feedback__c = feedback;
                ProductFeedbackDAO.updateProductFeedback(new List<Product_Feedback__c>{newPinnedProduct});
            } catch (Exception e) {
                System.debug(e.getMessage());
                newPinnedProduct = ProductFeedbackDAO.createProductFeedback(accountId, productId, pinnedNotes, expirationDate, feedback, 'Pinned');                
            }
        }
        
        Product_FeedBack__c newPinnedProductObj = ProductFeedbackDAO.getProductFeedbackById(newPinnedProduct.Id);
        OrderEntryController.AccountPricebookProducts tempAccountPricebookProduct =  OrderEntryController.createAccountPricebookProduct(false, false, false, false, true, null, orderId, newPinnedProductObj.Product__r.Id, newPinnedProductObj.Product__r.Name, newPinnedProductObj.Product__r.Draft_Or_Package__c, newPinnedProductObj.Product__r.QuantityUnitOfMeasure, 0,
                                                            newPinnedProductObj.Product__r.Pkg_Name__c, 0, newPinnedProductObj.Product__r.Cases_per_layer__c, newPinnedProductObj.Product__r.Cases_per_pallet__c, newPinnedProductObj.Product__r.SKU_External_Id__c, false, true, 
                                                            0.00, 0.00, 0.00, null, newPinnedProductObj.Product__r.Case_equivalent__c, newPinnedProductObj.Notes__c, newPinnedProductObj.Expiration_Date__c,
                                                            newPinnedProductObj.Feedback__c, newPinnedProductObj.CreatedBy.Name, newPinnedProductObj.Product__r.Sub_Style__c, newPinnedProductObj.Product__r.Seasonal__c, null);
        return tempAccountPricebookProduct;        
    }

    @AuraEnabled
    public static List<Product_Feedback__c> updatePinnedProductToHidden(List<String> prodIds, String accountId, String orderId, String feedback) {
        if (accountId == null) {
            //Get the order
            List<Order> orderList = OrderDAO.getOrderDetailsbyId(orderId);
            if (orderList.size() > 0) {
                accountId = orderList[0].accountId;
            }
        }
        List<Product_Feedback__c> pinnedProductLineItems = ProductFeedbackDAO.getPinnedProductsByAccountandExpirationDate(accountId, System.today());
        List<Product_Feedback__c> productFeedbackToUpdate = new List<Product_Feedback__c>();
        
        for(Product_Feedback__c pinnedItemObj : pinnedProductLineItems) {
            if(prodIds.contains(pinnedItemObj.Product__r.Id)) {                
                pinnedItemObj.IsHidden__c = true;
                pinnedItemObj.Feedback__c = feedback;
                productFeedbackToUpdate.add(pinnedItemObj);
            }
        }

        if(!productFeedbackToUpdate.isEmpty()){
            ProductFeedbackDAO.updateProductFeedback(productFeedbackToUpdate);
        }
        return productFeedbackToUpdate;
    }
}
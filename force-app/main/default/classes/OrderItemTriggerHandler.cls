public without sharing class OrderItemTriggerHandler {
    
    public static void fillStandardPricebookForOrder(List<Order> newItems) {
    	for (Order ord : newItems){
            if(ord.Pricebook2Id  == null ){
                ord.Pricebook2Id  = PricebookDAO.getStdPriceBookId();
            }
        }
    }
    
    public static void fillStandardPricebook(List<OrderItem> newItems) {
        Set<Id> productSet = new Set<Id>();
        //find product orders with no pricebook set. get the products ids
        for (OrderItem oi : newItems){
            if(oi.UnitPrice == null ){
                oi.UnitPrice = 0.0;
            }
            if(String.IsEmpty(oi.PricebookEntryId)){
                productSet.add(oi.Product2Id);
            }
        }
        Map<id,id> productToPriceBookMap = StandardPricebookHandler.checkOrFillStandardPricebookoEntry(productSet);
        for (OrderItem oi : newItems){
            if(String.IsEmpty(oi.PricebookEntryId)){
                oi.PricebookEntryId = productToPriceBookMap.get(oi.Product2Id);
            }
        }
    }
    
    public static void updatePinnedProducts(List<OrderItem> newItems) {
        Map<Id, Product_Feedback__c> updatePinnedProds = new Map<Id, Product_Feedback__c>();  //Using a map to make sure we don't add duplicates
        Set<String> orderItemIds = new Set<String>();
        for (OrderItem oi : newItems) {
            orderItemIds.add(oi.Id);
        }
        //Requery Order Items to get the fields we need
        List<OrderItem> orderItems = OrderItemDAO.getOrderItemByIds(orderItemIds);
        Set<Id> prodIds = new Set<Id>();
        for (OrderItem oi : orderItems) {
        	prodIds.add(oi.Product2Id);
        }
        List<Product_Feedback__c> pinnedProds = ProductFeedbackDAO.getPinnedProductsByProductIdsandExpirationDate(prodIds, System.today());
        if (pinnedProds.size() > 0) {
	        for (OrderItem oi : orderItems) {
    	        for (Product_Feedback__c pf : pinnedProds) {
        	        if (oi.Order.Status == 'Invoice' && oi.Product2Id == pf.Product__r.Id && oi.Order.AccountId == pf.Account__r.Id) {
                    	pf.Feedback__c = 'Product was Sold In on ' +  Datetime.now().format('MM-dd-yyyy');
                        pf.isHidden__c = true;  //Should no longer show on Account
                        updatePinnedProds.put(pf.Id, pf);                        
                    }
                }
            }           
        }
        if (updatePinnedProds.size() > 0) {
            ProductFeedbackDAO.updateProductFeedback(updatePinnedProds.values());   //Update the pinned products
        }
    }
    
}
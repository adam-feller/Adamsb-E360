public without sharing class ProductTriggerHandler {
    public static void beforeInsertHandler(List<Product2> newProducts) {
        copyBeerlineDescriptionIntoName(newProducts);
    }

    public static void beforeUpdateHandler(List<Product2> newProducts, Map<Id, Product2> oldProductsMap) {
        copyBeerlineDescriptionIntoName(newProducts);
    }
    
    public static void afterInsertHandler(List<Product2> newProducts) {
    	//nothing yet
    }

    public static void afterUpdateHandler(List<Product2> newProducts, Map<Id, Product2> oldProductsMap) {
        Set<Id> inactivatedProductIds = new Set<Id>();
        for(Product2 pr : newProducts) {
            //If Product was inactivated
            if (pr.IsActive == false) {
				if (pr.IsActive != oldProductsMap.get(pr.Id).IsActive) {
	         		inactivatedProductIds.add(pr.Id);
	            }
            }
        }
        
        if (inactivatedProductIds.size() > 0) {
            updatePinnedProducts(inactivatedProductIds);
        }
    }
    
    //product2.Description is only populated by Integration when coming from Beerline.
    //That is a user-friendly names enables ISR to use and see the same names clients see on the beerline side.
    private static void copyBeerlineDescriptionIntoName(List<Product2> newProducts) {
        for (Product2 pr: newProducts) {
            if(!String.isBlank(pr.Description) && !String.isBlank(pr.Pkg_name__c)) {
                pr.Name = pr.Description +' '+pr.Pkg_name__c;
                pr.Name = pr.Name.left(254);
            }
        }
    }

    //This code checks if product already exists in Std Pricebook and adds it there if it is not.
    private static void fillStandardPricebook(List<Product2> newProducts){
        Set<Id> productIds = new Set<Id>();
        for (Product2 pr: newProducts){
            productIds.add(pr.id);
        }
        StandardPricebookHandler.checkOrFillStandardPricebookoEntry(productIds);
    }
    
	//If a product is moved to Inactive, this code hides any active Pinned Products
	@future   
    private static void updatePinnedProducts(Set<Id> inactivatedProductIds) {
        //First get all active Pinned Products with those Ids
        List<Product_Feedback__c> pinnedProducts = ProductFeedBackDAO.getPinnedProductsByProductIdsandExpirationDate(inactivatedProductIds, System.today());
        for (Product_Feedback__c prod : pinnedProducts) {
            prod.IsHidden__c = true;
            prod.Feedback__c = 'Product was Inactivated on ' + Datetime.now().format('MM-dd-yyyy');
        }
        update pinnedProducts;
    }
}
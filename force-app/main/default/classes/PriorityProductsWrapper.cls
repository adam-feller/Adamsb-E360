public with sharing class PriorityProductsWrapper {

    public String customerExternalId;
	public List<PriorityProducts> priorityProducts;

	public class PriorityProducts {
		public String priorityType;
		public Integer productExternalId;
		public String productContainerType;
		public String productBrandId;
		public String productSubbrandId;
		public String mandateLevel;
		public String productInvoiceDate;
		public Integer productWarehouseAvailableQty;
		public Double productOnHandQty;
		public Double suggestionSource;
		public String suggestionStory;
		public Double suggestionScore;
		public String suggestionDatetime;
	}

	
	public static  PriorityProductsWrapper parse(String json) {
		return (PriorityProductsWrapper) System.JSON.deserialize(json, PriorityProductsWrapper.class);
	}
    
}
public with sharing class LiveOrdersFromVIPController {


    static   String liveOrderResponse;
    @AuraEnabled
    public   static String getLiveOrders(String accNum,String businessUnit){
        System.debug('accNum  **** '+accNum);
        System.debug('businessUnit '+businessUnit);
        //making changes to invoke post request
        HttpResponse liveDetailsResponse = null;
        try{
           // Callout to fetch Live Orders
            liveDetailsResponse = MulesoftUtility.mulesoftCallout('LiveOrder',accNum, businessUnit, null, null); 
            System.debug(liveDetailsResponse);
            

            if(liveDetailsResponse.getStatusCode() == 200){
                System.debug('Response body = '+ liveDetailsResponse.getBody());
                //If the response status code is 200, parse the response and return
                return parseResponse(liveDetailsResponse.getBody());
                
            }else{
                //If the status code is not 200, insert a Error Log
                Error_Log__c log = ErrorLog.returnErrorLog('liveorder'+accnum, '', 'liveorderRequests'+accnum, 'liveOrderCustomerRequests acctNum is '+accnum);
                log.Error_Response__c = liveDetailsResponse.getStatusCode() + ':' + liveDetailsResponse.getStatus() + ':' + liveDetailsResponse.getBody();
                insert log;
                return '';
                
            }
        }Catch(Exception ex){
            System.debug('HEre exception');
            System.debug(ex);
            System.debug(String.valueOf(ex.getLineNumber()) + ' : ' + ex.getMessage());
            //If there is any exception, Insert Error Log
            ErrorLog.insertErrorLog(ex.getMessage()+accnum, String.valueOf(ex.getLineNumber()), 'liveorder'+accnum, 'liveorder.getliveOrders()'+accnum);
            return '';
        }
        
        
        
    }
    
    private static String parseResponse(String response){

        Set<String> productCodeList = new Set<String>();
        liveOrderJSON liveOrders = parse(response);
        System.debug(liveOrders);
        //If the response has orders
        if(liveOrders.Orders != null){
			//Iterate over the Orders            
            for(Orders orders : liveOrders.Orders){
                // System.debug(orders);
                // For Each line item find the Item code which is product SKU Code
                if(orders.lineitems != null && orders.lineitems.size() > 0){
                for(LineItems li: orders.lineitems ){
                    // System.debug(li.ItemCode);
                    //productCodeList.add((li.ItemCode).substring(1,6));
                    productCodeList.add((li.ItemCode).replaceFirst('^0+', ''));
                }
                }
            }
            
            //Fetch all the products related to Product Code.
            List<Product2> prodList = [Select id,name,SKU_External_Id__c from product2 where 
                                       SKU_External_Id__c in: productCodeList];
            
            Map<String,PRoduct2> productMap = new Map<String,Product2>();
            //Preparing Map of SKU, Product
            for(PRoduct2 prod: prodList){
                productMap.put(prod.SKU_External_Id__c,prod);
            }
            
            for(Orders o : liveOrders.Orders){
                // System.debug(o);
                if(o.lineitems != null && o.lineitems.size() > 0){
                    for(LineItems li: o.lineitems ){
                        // System.debug(li.ItemCode);
                        // Find the Equivalent product from SKU to diplay the product name and preparing Link to navigate
//                        if(productMap.get((li.ItemCode).substring(1,8)) != null){
                        if(productMap.get((li.ItemCode).replaceFirst('^0+', '')) != null){
                            // System.debug('prodfound');
                            Product2 prod = productMap.get((li.ItemCode).replaceFirst('^0+', ''));
                            li.ProductName = prod.Name;
                            li.ProductId = '/'+prod.Id;                 
                        }
                    }
                }
            }
        }
        return JSON.serialize(liveOrders);
    }
    
    static liveOrderJSON parse(String json) {
        return (liveOrderJSON) System.JSON.deserialize(json, liveOrderJSON.class);
    }
    
    /* Wrapper Class for the JSON String response */
    class liveOrderJSON{
        String SM;
        List<Orders> Orders;
    }

    class Orders {
        public String ServerOrderID;	//522621
		public String StatusCode;	//Accepted
		public String StatusDesc;	//Accepted
		public String SourceDesc;	//iOS/PDA (PALMEDIT)
		public boolean IsEditable;
		public String AccountNumber;	//52262
		public Integer DeliveryDate;	//20221118
		public String InvoiceType;	//B
		public String ARType;	//B
		public String PurchaseOrder;	//444
		public Double TotalPrice;	//334.2
		public Integer OrderDate;	//20221109
        List<LineItems> LineItems;
    }
    
    class LineItems {
        Integer LineNumber;
        Integer Type;
        String ItemCode;
        Decimal Quantity;
        Boolean IsUnitQuantity;
        String SourceDesc;
        String OriginalOrderID;
        String LastUpdatedTimestamp;
        String LastUpdatedUser;
        Boolean PerformanceDiscount;
        Double Price;
        Double Discount;
        Double PostOff;
        Double ExtendedPrice;
        Double Deposit;
        String ProductName;
        String ProductId;
    }
}
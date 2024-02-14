public class AccountOrderHistory {
    
     @AuraEnabled(cacheable=true)
     public static List<Date> getInvoiceDates(String accId) {
        Date compareDate = system.today()-42;  //Only orders in the past 6 weeks
        Set<Date> setDates = new Set<Date>();  //Using a set so we get unique Invoice Dates
        List<Order> orders = [SELECT Id, Invoice_Date__c, (SELECT Id FROM OrderItems) 
                        FROM Order WHERE AccountId = :accId
	                    AND Status = 'Invoice' AND Invoice_Date__c >= :compareDate 
						ORDER BY Invoice_Date__c DESC];
                         
        for (Order order : orders) {
            //Only want to add the Invoice Date if it is not blank 
            //and there are Order Items for this order
            if (order.Invoice_Date__c <> null && order.OrderItems.size()!=0) {
        		setDates.add(order.Invoice_Date__c);
            }
        }
        List<Date> invoiceDates = new List<Date>(setDates);
        List<Date> returnInvoiceDates = new List<Date>();
        if (invoiceDates.size() > 6) {    //Only going to display up to 6 invoice dates
            for (Integer i = 0; i < 6; i++) {
                returnInvoiceDates.add(invoiceDates[i]);
            }
        } else {
            returnInvoiceDates = invoiceDates;
        }
    	return returnInvoiceDates;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<OrderItemWrapper> getOrderItems(String accId) {
        Date compareDate = system.today()-42;  //Only orders in the past 6 weeks
        List<Date> invoiceDates = getInvoiceDates(accId);
        List<OrderItemWrapper> orderItems = new List<OrderItemWrapper>();
        List<Order> orders = [SELECT Id, OrderNumber, Invoice_Date__c, 
	                     (SELECT Id, Product2.Name, Product2.Brand_Name__c, 
						 OrderItemNumber, Quantity_Order__c FROM OrderItems
						 ORDER BY Product2.Name ASC) 
	                     FROM Order WHERE AccountId = :accId 
                         AND Status = 'Invoice' AND Invoice_Date__c >= :compareDate 
                         ORDER BY Invoice_Date__c DESC];

        //Loop through the Order/Order Items
		for (Order order : orders) {
	   		for (OrderItem item : order.OrderItems) {
                Integer cnt = 0;
                Boolean found = false;
                for (OrderItemWrapper wrapper : orderItems) {
                    if (wrapper.name == item.Product2.Name) {
                        //This product is already in the wrapper
                        //Need to add the Quantity to the correct Delivery Date
                        found = true;
                        break;
                    }
                    cnt += 1;
                }
            	if (found) {
                    //Replace the quantity on the correct delivery date
         			for (Integer i = 1; i <= invoiceDates.size(); i++) {
                    	if (order.Invoice_Date__c == invoiceDates[i-1]) {
                        	if (i == 1) {
                            	orderItems[cnt].qty1 = orderItems[cnt].qty1 + item.Quantity_Order__c;
                            } else if (i == 2) {
                            	orderItems[cnt].qty2 = orderItems[cnt].qty2 + item.Quantity_Order__c;
                            } else if (i == 3) {
                            	orderItems[cnt].qty3 = orderItems[cnt].qty3 + item.Quantity_Order__c;
                            } else if (i == 4) {
                            	orderItems[cnt].qty4 = orderItems[cnt].qty4 + item.Quantity_Order__c;
                            } else if (i == 5) {
                            	orderItems[cnt].qty5 = orderItems[cnt].qty5 + item.Quantity_Order__c;
                            } else if (i == 6) {
                            	orderItems[cnt].qty6 = orderItems[cnt].qty6 + item.Quantity_Order__c;
                            }                        		
                        }			                   
                    }
                } else {
                	//This is a new product so we are going to add
					OrderItemWrapper orderItemWrapper = new OrderItemWrapper();
	           		orderItemWrapper.name = item.Product2.Name;
	           		orderItemWrapper.item = item.OrderItemNumber;
	        		orderItemWrapper.brand = item.Product2.Brand_Name__c;
                	for (Integer i = 1; i <= invoiceDates.size(); i++) {
                    	if (order.Invoice_Date__c == invoiceDates[i-1]) {
                        	if (i == 1) {
                            	orderItemWrapper.qty1 = item.Quantity_Order__c;
                            } else if (i == 2) {
                            	orderItemWrapper.qty2 = item.Quantity_Order__c;
                            } else if (i == 3) {
                            	orderItemWrapper.qty3 = item.Quantity_Order__c;
                            } else if (i == 4) {
                            	orderItemWrapper.qty4 = item.Quantity_Order__c;
                            } else if (i == 5) {
                            	orderItemWrapper.qty5 = item.Quantity_Order__c;
                            } else if (i == 6) {
                            	orderItemWrapper.qty6 = item.Quantity_Order__c;
                            }                        		
                       } else {
                       	    if (i == 1) {
                            	orderItemWrapper.qty1 = 0;
                            } else if (i == 2) {
                                orderItemWrapper.qty2 = 0;
                            } else if (i == 3) {
                                orderItemWrapper.qty3 = 0;
                            } else if (i == 4) {
                                orderItemWrapper.qty4 = 0;
                            } else if (i == 5) {
                                orderItemWrapper.qty5 = 0;
                            } else if (i == 6) {
                                orderItemWrapper.qty6 = 0;
                            }                        	
                        }	       				                   
                    }
                    orderItems.add(orderItemWrapper); 
                }
            }
		}
    	return orderItems;
    }

	public Class OrderItemWrapper {
		@AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String item {get;set;}
		@AuraEnabled
        public String brand {get;set;}
        @AuraEnabled
        public Double qty1 {get;set;}
        @AuraEnabled
        public Double qty2 {get;set;}
        @AuraEnabled
        public Double qty3 {get;set;}
        @AuraEnabled
        public Double qty4 {get;set;}
        @AuraEnabled
        public Double qty5 {get;set;}
        @AuraEnabled
        public Double qty6 {get;set;}
	}
}
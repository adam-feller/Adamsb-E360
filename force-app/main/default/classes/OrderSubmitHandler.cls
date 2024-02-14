public with sharing class OrderSubmitHandler {

    public static void submitBeerlineOrder(List<OrderChangeEvent> orderChangeEvents){
        try{
            Set<Id> orderIds = new Set<Id>();
            for(OrderChangeEvent event : orderChangeEvents){
                EventBus.ChangeEventHeader header = event.ChangeEventHeader;
                Set<String> setIds = new Set<String>(header.recordIds);
                orderIds.addAll(new Set<Id>((List<Id>)new List<String>(setIds)));
            }

            Map<Id, Order> idToOrderMap = new Map<Id,Order>(OrderDAO.getOrderDetailsbyIds(orderIds));
            List<Order> ordersToUpdate = new List<Order>();
            for (OrderChangeEvent event : orderChangeEvents) {
                EventBus.ChangeEventHeader header = event.ChangeEventHeader;
                if (event.Status == 'Pending Draft') {
                    for (String recordId : header.recordIds) {
                        Order currentOrder = idToOrderMap.get(recordId);
                        if(currentOrder.OrderSourceCode__c == 'B2B'){
                            submitOrderDetails(currentOrder.PoNumber, currentOrder.VIPActionCode__c, currentOrder.Account.VIP_Account_Number__c, currentOrder.Account.VIP_Instance__c, currentOrder.Sales_Route_Number__c, currentOrder.Delivery_Date__c, currentOrder.VIP_Order_NUmber__c, currentOrder.Status, currentOrder.OrderSourceCode__c, currentOrder.Id);
                        }
                    }
                } else if(event.Status == 'Pending - Future Order'){
                    for (String recordId : header.recordIds) {
                        Order currentOrder = idToOrderMap.get(recordId);
                        if(currentOrder.OrderSourceCode__c == 'B2B'){
                            setFutureOrderDetails(currentOrder.Account.VIP_Account_Number__c, currentOrder.Account.VIP_Instance__c, currentOrder.Delivery_Date__c, currentOrder.Status, currentOrder.Id);
                        }
                    }
                }
            }
        }catch(Exception ex){
            ErrorLog.insertErrorLog(ex.getMessage(), String.valueOf(ex.getLineNumber()), 'OrderSubmitHandler', 'submitBeerlineOrder');
        }
    }

    @future(callout=true)
    public static void submitOrderDetails(String poNumber, String vipActionCode, String accountNumber, String vipInstance, String salesManagerRoute, Date deliveryDate, String orderNumber, String orderStatus, String orderSource, Id orderId){
        try{
            
            // BSSP-1416 Keg count and case cout for beerline
            Integer kegCount = 0;
			Integer caseCount = 0;
            
            List<Order> ordersToUpdate = new List<Order>();
            List<OrderItem> orderItemsReturned = OrderItemDAO.getOrderItemByOrderId(orderId);
            Set<String> productIds = new Set<String>();
            List<OrderEntryController.AccountPricebookProducts> productItemCodesList = new List<OrderEntryController.AccountPricebookProducts>();
            for(OrderItem orderItemObj : orderItemsReturned){
                OrderEntryController.AccountPricebookProducts tempAccountPricebookProduct = new OrderEntryController.AccountPricebookProducts();
                tempAccountPricebookProduct.item = orderItemObj.Product2.SKU_External_Id__c;
                productItemCodesList.add(tempAccountPricebookProduct);
                productIds.add(orderItemObj.Product2Id);
            }

            Map<Id, Product2> productInfoMap = new Map<Id, Product2>(ProductDAO.getProductByIds(productIds));
            Map<String, OrderEntryController.AccountPricebookProducts> priceInventoryDetailMap = new Map<String, OrderEntryController.AccountPricebookProducts>();
            List<OrderEntryController.AccountPricebookProducts> priceInventoryProductDetailsList = OrderEntryUtility.priceInventoryDetails(accountNumber, vipInstance, deliveryDate, productItemCodesList);
            for(OrderEntryController.AccountPricebookProducts priceInventoryDetailObj : priceInventoryProductDetailsList){
                priceInventoryDetailMap.put(priceInventoryDetailObj.item, priceInventoryDetailObj);
            }

            List<OrderItem> orderItemsToUpdate = new List<OrderItem>();
            for(OrderItem orderItemObj : orderItemsReturned){
                if(priceInventoryDetailMap.containsKey(orderItemObj.Product2.SKU_External_Id__c)){
                    orderItemObj.UnitPrice = priceInventoryDetailMap.get(orderItemObj.Product2.SKU_External_Id__c).exPrice;
                    orderItemObj.Inventory__c = priceInventoryDetailMap.get(orderItemObj.Product2.SKU_External_Id__c).qtyAvail;
                    orderItemObj.Unit_Discount__c = priceInventoryDetailMap.get(orderItemObj.Product2.SKU_External_Id__c).unitDiscount;
                }
                if(productInfoMap.containsKey(orderItemObj.Product2Id)){
                    if(productInfoMap.get(orderItemObj.Product2Id).QuantityUnitOfMeasure != null){
                        orderItemObj.UOM__c = productInfoMap.get(orderItemObj.Product2Id).QuantityUnitOfMeasure;
                    } else {
                        orderItemObj.UOM__c = 'unit';
                    }
                }
                orderItemsToUpdate.add(orderItemObj);
                
                //BSSP-1416 Keg count and case cout for beerline
                
                if (orderItemObj.Product2.Draft_Or_Package__c != null) {
                    if (orderItemObj.Product2.Draft_Or_Package__c.contains('Draft')) {
                        kegCount += integer.valueOf(orderItemObj.Quantity_Order__c);
                    } else {
                        caseCount += integer.valueOf(orderItemObj.Quantity_Order__c);
                           }
                } else {
                    caseCount += integer.valueOf(orderItemObj.Quantity_Order__c);
                     }
                
                // BSSP-1416 case count logic ends here
            }

            OrderEntryUtility.AccountARDetails accountARDetailsObj = OrderEntryUtility.getAccountARDetails(accountNumber, vipInstance, deliveryDate, orderItemsReturned);

            HttpResponse orderValidateResponse = OrderEntryUtility.submitOrderValidateDetails(poNumber, vipActionCode, accountNumber, vipInstance, salesManagerRoute, deliveryDate, orderNumber, orderStatus, orderSource, orderItemsReturned);
            Order tempOrder = new Order();
            tempOrder.Id = orderId;
            if(orderValidateResponse.getStatusCode() != 201){
                tempOrder.Order_Errors__c = orderValidateResponse.getBody();
                tempOrder.Status = 'Posting Error';
                
            } else {
                tempOrder.Status = 'Posted to VIP';
            }
            
            //BSSP-1416 Keg count and case cout for beerline
            tempOrder.Case_Count__c = caseCount;
			tempOrder.Keg_Count__c = kegCount;
            
            tempOrder.OrderSourceCode__c = 'Web';
            if(accountARDetailsObj != null){
                if(accountARDetailsObj.apiResponseCode == '200'){
                    tempOrder = OrderEntryUtility.addOrderSummaryDetails(JSON.serialize(accountARDetailsObj), tempOrder);
                }
            }
            ordersToUpdate.add(tempOrder);
            if(!orderItemsToUpdate.isEmpty()){
                OrderItemDAO.updateOrderItems(orderItemsToUpdate);
            }
            OrderDAO.updateOrders(ordersToUpdate);
        } catch(Exception ex){
            ErrorLog.insertErrorLog(ex.getMessage(), String.valueOf(ex.getLineNumber()), 'OrderSubmitHandler', 'submitOrderDetails');
        }
    }

    @future(callout=true) 
    public static void setFutureOrderDetails(String accountNumber, String vipInstance, Date deliveryDate, String orderStatus, Id orderId){
        try{
            // BSSP-1843 Keg count and case cout for beerline
            Integer kegCount = 0;
			Integer caseCount = 0;
            
            List<Order> ordersToUpdate = new List<Order>();
            List<OrderItem> orderItemsReturned = OrderItemDAO.getOrderItemByOrderId(orderId);
            Set<String> productIds = new Set<String>();
            List<OrderEntryController.AccountPricebookProducts> productItemCodesList = new List<OrderEntryController.AccountPricebookProducts>();
            for(OrderItem orderItemObj : orderItemsReturned){
                OrderEntryController.AccountPricebookProducts tempAccountPricebookProduct = new OrderEntryController.AccountPricebookProducts();
                tempAccountPricebookProduct.item = orderItemObj.Product2.SKU_External_Id__c;
                productItemCodesList.add(tempAccountPricebookProduct);
                productIds.add(orderItemObj.Product2Id);
            }

            Map<Id, Product2> productInfoMap = new Map<Id, Product2>(ProductDAO.getProductByIds(productIds));
            Map<String, OrderEntryController.AccountPricebookProducts> priceInventoryDetailMap = new Map<String, OrderEntryController.AccountPricebookProducts>();
            List<OrderEntryController.AccountPricebookProducts> priceInventoryProductDetailsList = OrderEntryUtility.priceInventoryDetails(accountNumber, vipInstance, deliveryDate, productItemCodesList);
            for(OrderEntryController.AccountPricebookProducts priceInventoryDetailObj : priceInventoryProductDetailsList){
                priceInventoryDetailMap.put(priceInventoryDetailObj.item, priceInventoryDetailObj);
            }

            List<OrderItem> orderItemsToUpdate = new List<OrderItem>();
            for(OrderItem orderItemObj : orderItemsReturned){
                if(priceInventoryDetailMap.containsKey(orderItemObj.Product2.SKU_External_Id__c)){
                    orderItemObj.UnitPrice = priceInventoryDetailMap.get(orderItemObj.Product2.SKU_External_Id__c).exPrice;
                    orderItemObj.Inventory__c = priceInventoryDetailMap.get(orderItemObj.Product2.SKU_External_Id__c).qtyAvail;
                    orderItemObj.Unit_Discount__c = priceInventoryDetailMap.get(orderItemObj.Product2.SKU_External_Id__c).unitDiscount;
                }
                if(productInfoMap.containsKey(orderItemObj.Product2Id)){
                    if(productInfoMap.get(orderItemObj.Product2Id).QuantityUnitOfMeasure != null){
                        orderItemObj.UOM__c = productInfoMap.get(orderItemObj.Product2Id).QuantityUnitOfMeasure;
                    } else {
                        orderItemObj.UOM__c = 'unit';
                    }
                }
                orderItemsToUpdate.add(orderItemObj);
                
                //BSSP-1843 Keg count and case cout for beerline
                
                if (orderItemObj.Product2.Draft_Or_Package__c != null) {
                    if (orderItemObj.Product2.Draft_Or_Package__c.contains('Draft')) {
                        kegCount += integer.valueOf(orderItemObj.Quantity_Order__c);
                    } else {
                        caseCount += integer.valueOf(orderItemObj.Quantity_Order__c);
                           }
                } else {
                    caseCount += integer.valueOf(orderItemObj.Quantity_Order__c);
                     }
                
                
            }

            OrderEntryUtility.AccountARDetails accountARDetailsObj = OrderEntryUtility.getAccountARDetails(accountNumber, vipInstance, deliveryDate, orderItemsReturned);

            Order tempOrder = new Order();
            tempOrder.Id = orderId;
            tempOrder.OrderSourceCode__c = 'Web';
            
            //BSSP-1843 Keg count and case cout for beerline
            tempOrder.Case_Count__c = caseCount;
			tempOrder.Keg_Count__c = kegCount;
            
            
            if(accountARDetailsObj != null){
                if(accountARDetailsObj.apiResponseCode == '200'){
                    tempOrder = OrderEntryUtility.addOrderSummaryDetails(JSON.serialize(accountARDetailsObj), tempOrder);
                }
            }
            ordersToUpdate.add(tempOrder);
            if(!orderItemsToUpdate.isEmpty()){
                OrderItemDAO.updateOrderItems(orderItemsToUpdate);
            }
            OrderDAO.updateOrders(ordersToUpdate);
        } catch(Exception ex){
            ErrorLog.insertErrorLog(ex.getMessage(), String.valueOf(ex.getLineNumber()), 'OrderSubmitHandler', 'setFutureOrderDetails');
        }
    }
}
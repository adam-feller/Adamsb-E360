public without sharing class OrderEntryUtility {

    public static List<OrderEntryController.AccountPricebookProducts> handleSuggestedSellData(HTTPResponse suggestedSellResponse, String accountId, String orderId) {
        List<CriticalMinuteController.SuggestedSellDetails> suggestedSellDetailsList = (List<CriticalMinuteController.SuggestedSellDetails>)JSON.deserialize(suggestedSellResponse.getBody(), List<CriticalMinuteController.SuggestedSellDetails>.class);
        String type;
        Set<String> productExternalIds = new Set<String>();
        List<CriticalMinuteController.SuggestedSellDetails> filteredSuggestedSellDetailsList = new List<CriticalMinuteController.SuggestedSellDetails>();
        for (CriticalMinuteController.SuggestedSellDetails suggestedObj : suggestedSellDetailsList) {
            if (suggestedObj.snapshotDatetime != null){ 
                productExternalIds.add(suggestedObj.productExternalId);
                filteredSuggestedSellDetailsList.add(suggestedObj);
            }
        }

        List<OrderEntryController.AccountPricebookProducts> accountProducts = new List<OrderEntryController.AccountPricebookProducts>();
        List<Product2> suggestedProductExternalList = ProductDAO.getProductByExternalIds(productExternalIds);
        Map<String, Product2> productDetailsMap = new Map<String, Product2>();
        for (Product2 prodObj : suggestedProductExternalList) {
            productDetailsMap.put(prodObj.SKU_External_Id__c, prodObj);
        }

        List<OrderItem> orderItemsReturned = OrderItemDAO.getOrderItemByOrderId(orderId);
        Set<Id> existingOrderItemSet = new Set<Id>();
        for (OrderItem orderItemObj : orderItemsReturned) {
            existingOrderItemSet.add(orderItemObj.Product2Id);
            if (orderItemObj.Suggested__c) {
                accountProducts.add(OrderEntryController.createAccountPricebookProduct(false, orderItemObj.Suggested__c, orderItemObj.Suggested_Icon__c, orderItemObj.Mandate__c, false, orderItemObj.Id, orderItemObj.OrderId,
                                                            orderItemObj.Product2Id, orderItemObj.Product2.Name, orderItemObj.Product2.Draft_Or_Package__c, orderItemObj.Product2.QuantityUnitOfMeasure, orderItemObj.Quantity_Order__c,
                                                            orderItemObj.Product2.Pkg_Name__c, orderItemObj.Inventory__c, orderItemObj.Product2.Cases_per_layer__c, orderItemObj.Product2.Cases_per_pallet__c,
                                                            orderItemObj.Product2.SKU_External_Id__c, false, false, 0.00, 0.00, 0.00, null,
                                                            orderItemObj.Product2.Case_equivalent__c, null, null, null, null, orderItemObj.Product2.Sub_Style__c, orderItemObj.Product2.Seasonal__c, orderItemObj.Suggested_Sell_Story_Text__c ));                
            }
        }

        for (CriticalMinuteController.SuggestedSellDetails suggestedObj : filteredSuggestedSellDetailsList) {
            if (productDetailsMap.containskey(suggestedObj.productExternalId)) {
                if (!existingOrderItemSet.contains(productDetailsMap.get(suggestedObj.productExternalId).Id)) {
                    Date productSuggestedDate = Date.valueOf(suggestedObj.snapshotDatetime);
                    String source = suggestedObj.Source;
                    Boolean suggestedIcon = false;
                    if (source == '1') {
                        type = 'Suggested Sell';
                        suggestedIcon = true;
                    } else {
                        type = 'Hot In The Area';
                        suggestedIcon = false;
                    }
                    accountProducts.add(OrderEntryController.createAccountPricebookProduct(false, true, suggestedIcon, false, false, null, orderId, productDetailsMap.get(suggestedObj.productExternalId).Id, productDetailsMap.get(suggestedObj.productExternalId).Name, productDetailsMap.get(suggestedObj.productExternalId).Draft_Or_Package__c, productDetailsMap.get(suggestedObj.productExternalId).QuantityUnitOfMeasure, 0,
                                                                    productDetailsMap.get(suggestedObj.productExternalId).Pkg_Name__c, 0, productDetailsMap.get(suggestedObj.productExternalId).Cases_per_layer__c, productDetailsMap.get(suggestedObj.productExternalId).Cases_per_pallet__c,
                                                                    productDetailsMap.get(suggestedObj.productExternalId).SKU_External_Id__c, false, true, 0.00, 0.00, 0.00, null,
                                                                    productDetailsMap.get(suggestedObj.productExternalId).Case_equivalent__c, null, null, null, null, productDetailsMap.get(suggestedObj.productExternalId).Sub_Style__c, productDetailsMap.get(suggestedObj.productExternalId).Seasonal__c, suggestedObj.story ) );                    
                }
            }
        }

        accountProducts.sort();
        return accountProducts;
    }

    //handle priority list data
    public static List<OrderEntryController.AccountPricebookProducts> handlePriorityListData(HTTPResponse priorityListResponse, String accountId, String orderId) {
       // List<CriticalMinuteController.SuggestedSellDetails> suggestedSellDetailsList = (List<CriticalMinuteController.SuggestedSellDetails>)JSON.deserialize(suggestedSellResponse.getBody(), List<CriticalMinuteController.SuggestedSellDetails>.class);
       List<Account> accountList = AccountDAO.getAccountsByIds(new Set<Id>{accountId});
       List<CriticalMinuteController.PriorityListDisplayDetails> priorityListDisplayList = CriticalMinuteController.handlePriorityListData(priorityListResponse,accountList[0],'1',accountId);
       String type;
        Set<String> productExternalIds = new Set<String>();
       // List<CriticalMinuteController.SuggestedSellDetails> filteredSuggestedSellDetailsList = new List<CriticalMinuteController.SuggestedSellDetails>();
       List<CriticalMinuteController.PriorityListDisplayDetails> filteredSuggestedSellDetailsList = new List<CriticalMinuteController.PriorityListDisplayDetails>();
        
       
       for (CriticalMinuteController.PriorityListDisplayDetails suggestedObj : priorityListDisplayList) {
            //if (suggestedObj.snapshotDatetime != null){ 
                productExternalIds.add(suggestedObj.product1.itemNumber);
                filteredSuggestedSellDetailsList.add(suggestedObj);
            //}
        }

        List<OrderEntryController.AccountPricebookProducts> accountProducts = new List<OrderEntryController.AccountPricebookProducts>();
        List<Product2> suggestedProductExternalList = ProductDAO.getProductByExternalIds(productExternalIds);
        Map<String, Product2> productDetailsMap = new Map<String, Product2>();
        for (Product2 prodObj : suggestedProductExternalList) {
            productDetailsMap.put(prodObj.SKU_External_Id__c, prodObj);
        }

        List<OrderItem> orderItemsReturned = OrderItemDAO.getOrderItemByOrderId(orderId);
        Set<Id> existingOrderItemSet = new Set<Id>();
        for (OrderItem orderItemObj : orderItemsReturned) {
            existingOrderItemSet.add(orderItemObj.Product2Id);
            if (orderItemObj.Suggested__c) {
                accountProducts.add(OrderEntryController.createAccountPricebookProduct(false, orderItemObj.Suggested__c, orderItemObj.Suggested_Icon__c, orderItemObj.Mandate__c, false, orderItemObj.Id, orderItemObj.OrderId,
                                                            orderItemObj.Product2Id, orderItemObj.Product2.Name, orderItemObj.Product2.Draft_Or_Package__c, orderItemObj.Product2.QuantityUnitOfMeasure, orderItemObj.Quantity_Order__c,
                                                            orderItemObj.Product2.Pkg_Name__c, orderItemObj.Inventory__c, orderItemObj.Product2.Cases_per_layer__c, orderItemObj.Product2.Cases_per_pallet__c,
                                                            orderItemObj.Product2.SKU_External_Id__c, false, false, 0.00, 0.00, 0.00, null,
                                                            orderItemObj.Product2.Case_equivalent__c, null, null, null, null, orderItemObj.Product2.Sub_Style__c, orderItemObj.Product2.Seasonal__c, orderItemObj.Suggested_Sell_Story_Text__c ));                
            }
        }

        for (CriticalMinuteController.PriorityListDisplayDetails suggestedObj : filteredSuggestedSellDetailsList) {
            if (productDetailsMap.containskey(suggestedObj.product1.itemNumber)) {
                if (!existingOrderItemSet.contains(productDetailsMap.get(suggestedObj.product1.itemNumber).Id)) {
                   // Date productSuggestedDate = Date.valueOf(suggestedObj.snapshotDatetime);
                    String source = String.valueof(suggestedObj.suggestionScore);
                    Boolean suggestedIcon = false;
                    if (source == '1') {
                        type = 'Suggested Sell';
                        suggestedIcon = true;
                    } else {
                        type = 'Hot In The Area';
                        suggestedIcon = false;
                    }
                    accountProducts.add(OrderEntryController.createAccountPricebookProduct(false, true, suggestedIcon, false, false, null, orderId, productDetailsMap.get(suggestedObj.product1.itemNumber).Id, productDetailsMap.get(suggestedObj.product1.itemNumber).Name, productDetailsMap.get(suggestedObj.product1.itemNumber).Draft_Or_Package__c, productDetailsMap.get(suggestedObj.product1.itemNumber).QuantityUnitOfMeasure, 0,
                                                                    productDetailsMap.get(suggestedObj.product1.itemNumber).Pkg_Name__c, 0, productDetailsMap.get(suggestedObj.product1.itemNumber).Cases_per_layer__c, productDetailsMap.get(suggestedObj.product1.itemNumber).Cases_per_pallet__c,
                                                                    productDetailsMap.get(suggestedObj.product1.itemNumber).SKU_External_Id__c, false, true, 0.00, 0.00, 0.00, null,
                                                                    productDetailsMap.get(suggestedObj.product1.itemNumber).Case_equivalent__c, null, null, null, null, productDetailsMap.get(suggestedObj.product1.itemNumber).Sub_Style__c, productDetailsMap.get(suggestedObj.product1.itemNumber).Seasonal__c, suggestedObj.suggestionStory ) );                    
                }
            }
        }

        accountProducts.sort();
        return accountProducts;
    }


    public static List<OrderEntryController.AccountPricebookProducts> handleMandateData(HTTPResponse mandateResponse, String orderId, String accountTerr) {
        String mandateResponseBody = mandateResponse.getBody().replace('"desc":', '"desc_x":');
        List<CriticalMinuteController.MandateDetails> mandateDetailsList = (List<CriticalMinuteController.MandateDetails>)JSON.deserialize(mandateResponseBody, List<CriticalMinuteController.MandateDetails>.class);
        Date todaysDate = Date.today();
        List<CriticalMinuteController.MandateDetails> filteredMandateDetailsList = new List<CriticalMinuteController.MandateDetails>();
        Set<String> mandateProductExternalIds = new Set<String>();
        Set<String> mandateBrandExternalIds = new Set<String>();
        List<OrderEntryController.AccountPricebookProducts> accountProducts = new List<OrderEntryController.AccountPricebookProducts>();
        for(CriticalMinuteController.MandateDetails mandateObj : mandateDetailsList){
            if(mandateObj.openGapInd == 'TRUE'){
                if(todaysDate >= mandateObj.startDate && todaysDate <= mandateObj.endDate){
                    Boolean addMandate = false;
                    if(mandateObj.product1 != null){
                        if(mandateObj.product1.id != '0'){
                            addMandate = true;
                            mandateProductExternalIds.add(mandateObj.product1.id);
                        }
                    }
                    if(mandateObj.product2 != null){
                        if(mandateObj.product2.id != '0'){
                            addMandate = true;
                            mandateProductExternalIds.add(mandateObj.product2.id);
                        }
                    }
                    if(mandateObj.product3 != null){
                        if(mandateObj.product3.id != '0'){
                            addMandate = true;
                            mandateProductExternalIds.add(mandateObj.product3.id);
                        }
                    }
                    if(mandateObj.product4 != null){
                        if(mandateObj.product4.id != '0'){
                            addMandate = true;
                            mandateProductExternalIds.add(mandateObj.product4.id);
                        }
                    }

                    if(addMandate){
                        filteredMandateDetailsList.add(mandateObj);
                    }
                }
            }
        }

        List<Product2> mandateProductExternalList = ProductDAO.getProductByExternalIds(mandateProductExternalIds);
        Map<String, Product2> mandateProductDetailsMap = new Map<String, Product2>();
        if(accountTerr != null){
            List<String> accountTerritories = accountTerr.split(',');
            for(Product2 mandateProdObj : mandateProductExternalList){
                Boolean skuTerritoryMatch = false;
                if (mandateProdObj.Territories__c != null){
                    List<String> productTerritories = mandateProdObj.Territories__c.split(',');
                    for (String territory : productTerritories){
                        if (accountTerritories.contains(territory)){
                            skuTerritoryMatch = true;
                            break;
                        }
                    }
                    if (skuTerritoryMatch && mandateProdObj.isActive == true){
                        mandateProductDetailsMap.put(mandateProdObj.SKU_External_Id__c, mandateProdObj);
                    }
                }
            }
        }

        List<OrderItem> orderItemsReturned = OrderItemDAO.getOrderItemByOrderId(orderId);
        Set<Id> existingOrderItemSet = new Set<Id>();
        for(OrderItem orderItemObj : orderItemsReturned){
            existingOrderItemSet.add(orderItemObj.Product2Id);
            if(orderItemObj.Mandate__c) {
                accountProducts.add(OrderEntryController.createAccountPricebookProduct(false, orderItemObj.Suggested__c, orderItemObj.Suggested_Icon__c, orderItemObj.Mandate__c, false, orderItemObj.Id, orderItemObj.OrderId,
                                                            orderItemObj.Product2Id, orderItemObj.Product2.Name, orderItemObj.Product2.Draft_Or_Package__c, orderItemObj.Product2.QuantityUnitOfMeasure, orderItemObj.Quantity_Order__c,
                                                            orderItemObj.Product2.Pkg_Name__c, orderItemObj.Inventory__c, orderItemObj.Product2.Cases_per_layer__c, orderItemObj.Product2.Cases_per_pallet__c,
                                                            orderItemObj.Product2.SKU_External_Id__c, false, false, 0.00, 0.00, 0.00, null,
                                                            orderItemObj.Product2.Case_equivalent__c, null, null, null, null, orderItemObj.Product2.Sub_Style__c, orderItemObj.Product2.Seasonal__c, orderItemObj.Suggested_Sell_Story_Text__c)); 
            }
        }

        List<CriticalMinuteController.MandateDisplayDetails> mandateDisplayDetailsList = new List<CriticalMinuteController.MandateDisplayDetails>();
        Set<String> productExternalIdsFound = new Set<String>();
        for(CriticalMinuteController.MandateDetails filteredMandateObj : filteredMandateDetailsList){
            CriticalMinuteController.MandateDisplayDetails mandateDisplayDetailsObj = new CriticalMinuteController.MandateDisplayDetails();
            Set<String> containerTypes = new Set<String>();
            List<Date> invoiceDates = new List<Date>();
            if(filteredMandateObj.product1 != null){
                if(filteredMandateObj.product1.id != '0'){
                    if(mandateProductDetailsMap.containskey(filteredMandateObj.product1.id)){
                        if(!existingOrderItemSet.contains(mandateProductDetailsMap.get(filteredMandateObj.product1.id).Id)){
                            if(!productExternalIdsFound.contains(filteredMandateObj.product1.id)){
                                productExternalIdsFound.add(filteredMandateObj.product1.id);
                                accountProducts.add(OrderEntryController.createAccountPricebookProduct(false, false, false, true, false, null, orderId, mandateProductDetailsMap.get(filteredMandateObj.product1.id).Id, mandateProductDetailsMap.get(filteredMandateObj.product1.id).Name, mandateProductDetailsMap.get(filteredMandateObj.product1.id).Draft_Or_Package__c, mandateProductDetailsMap.get(filteredMandateObj.product1.id).QuantityUnitOfMeasure, 0,
                                                                                mandateProductDetailsMap.get(filteredMandateObj.product1.id).Pkg_Name__c, 0, mandateProductDetailsMap.get(filteredMandateObj.product1.id).Cases_per_layer__c, mandateProductDetailsMap.get(filteredMandateObj.product1.id).Cases_per_pallet__c,
                                                                                mandateProductDetailsMap.get(filteredMandateObj.product1.id).SKU_External_Id__c, false, true, 0.00, 0.00, 0.00, null,
                                                                                mandateProductDetailsMap.get(filteredMandateObj.product1.id).Case_equivalent__c, null, null, null, null, mandateProductDetailsMap.get(filteredMandateObj.product1.id).Sub_Style__c, mandateProductDetailsMap.get(filteredMandateObj.product1.id).Seasonal__c, null));

                            }
                        }
                    }
                }
            }
            if(filteredMandateObj.product2 != null){
                if(filteredMandateObj.product2.id != '0'){
                    if(mandateProductDetailsMap.containskey(filteredMandateObj.product2.id)){
                        if(!existingOrderItemSet.contains(mandateProductDetailsMap.get(filteredMandateObj.product2.id).Id)){
                            if(!productExternalIdsFound.contains(filteredMandateObj.product2.id)){
                                productExternalIdsFound.add(filteredMandateObj.product2.id);
                                accountProducts.add(OrderEntryController.createAccountPricebookProduct(false, false, false, true, false, null, orderId, mandateProductDetailsMap.get(filteredMandateObj.product2.id).Id, mandateProductDetailsMap.get(filteredMandateObj.product2.id).Name, mandateProductDetailsMap.get(filteredMandateObj.product2.id).Draft_Or_Package__c, mandateProductDetailsMap.get(filteredMandateObj.product2.id).QuantityUnitOfMeasure, 0,
                                                                            mandateProductDetailsMap.get(filteredMandateObj.product2.id).Pkg_Name__c, 0, mandateProductDetailsMap.get(filteredMandateObj.product2.id).Cases_per_layer__c, mandateProductDetailsMap.get(filteredMandateObj.product2.id).Cases_per_pallet__c,
                                                                            mandateProductDetailsMap.get(filteredMandateObj.product2.id).SKU_External_Id__c, false, true, 0.00, 0.00, 0.00, null,
                                                                            mandateProductDetailsMap.get(filteredMandateObj.product2.id).Case_equivalent__c, null, null, null, null, mandateProductDetailsMap.get(filteredMandateObj.product2.id).Sub_Style__c, mandateProductDetailsMap.get(filteredMandateObj.product2.id).Seasonal__c, null));
 
                            }
                        }
                    }
                }
            }
            if(filteredMandateObj.product3 != null){
                if(filteredMandateObj.product3.id != '0'){
                    if(mandateProductDetailsMap.containskey(filteredMandateObj.product3.id)){
                        if(!existingOrderItemSet.contains(mandateProductDetailsMap.get(filteredMandateObj.product3.id).Id)){
                            if(!productExternalIdsFound.contains(filteredMandateObj.product3.id)){
                                productExternalIdsFound.add(filteredMandateObj.product3.id);
                                accountProducts.add(OrderEntryController.createAccountPricebookProduct(false, false, false, true, false, null, orderId, mandateProductDetailsMap.get(filteredMandateObj.product3.id).Id, mandateProductDetailsMap.get(filteredMandateObj.product3.id).Name, mandateProductDetailsMap.get(filteredMandateObj.product3.id).Draft_Or_Package__c, mandateProductDetailsMap.get(filteredMandateObj.product3.id).QuantityUnitOfMeasure, 0,
                                                                            mandateProductDetailsMap.get(filteredMandateObj.product3.id).Pkg_Name__c, 0, mandateProductDetailsMap.get(filteredMandateObj.product3.id).Cases_per_layer__c, mandateProductDetailsMap.get(filteredMandateObj.product3.id).Cases_per_pallet__c,
                                                                            mandateProductDetailsMap.get(filteredMandateObj.product3.id).SKU_External_Id__c, false, true, 0.00, 0.00, 0.00, null,
                                                                            mandateProductDetailsMap.get(filteredMandateObj.product3.id).Case_equivalent__c, null, null, null, null, mandateProductDetailsMap.get(filteredMandateObj.product3.id).Sub_Style__c, mandateProductDetailsMap.get(filteredMandateObj.product3.id).Seasonal__c, null));  
                            }
                        }
                    }
                }
            }
            if(filteredMandateObj.product4 != null){
                if(filteredMandateObj.product4.id != '0'){
                    if(mandateProductDetailsMap.containskey(filteredMandateObj.product4.id)){
                        if(!existingOrderItemSet.contains(mandateProductDetailsMap.get(filteredMandateObj.product4.id).Id)){
                            if(!productExternalIdsFound.contains(filteredMandateObj.product4.id)){
                                productExternalIdsFound.add(filteredMandateObj.product4.id);
                                accountProducts.add(OrderEntryController.createAccountPricebookProduct(false, false, false, true, false, null, orderId, mandateProductDetailsMap.get(filteredMandateObj.product4.id).Id, mandateProductDetailsMap.get(filteredMandateObj.product4.id).Name, mandateProductDetailsMap.get(filteredMandateObj.product4.id).Draft_Or_Package__c, mandateProductDetailsMap.get(filteredMandateObj.product4.id).QuantityUnitOfMeasure, 0,
                                                                            mandateProductDetailsMap.get(filteredMandateObj.product4.id).Pkg_Name__c, 0, mandateProductDetailsMap.get(filteredMandateObj.product4.id).Cases_per_layer__c, mandateProductDetailsMap.get(filteredMandateObj.product4.id).Cases_per_pallet__c,
                                                                            mandateProductDetailsMap.get(filteredMandateObj.product4.id).SKU_External_Id__c, false, true, 0.00, 0.00, 0.00, null,
                                                                            mandateProductDetailsMap.get(filteredMandateObj.product4.id).Case_equivalent__c, null, null, null, null, mandateProductDetailsMap.get(filteredMandateObj.product4.id).Sub_Style__c, mandateProductDetailsMap.get(filteredMandateObj.product4.id).Seasonal__c, null)); 
                            }
                        }
                    }
                }
            }
        }

        accountProducts.sort();
        return accountProducts;
    }

    public static BusinessUnitVIPDetails getBusinessUnitDetails(String vipInstance){
        List<Business_Unit__c> businessUnitList = BusinessUnitDAO.getBusinessUnits(vipInstance);

        if(!businessUnitList.isEmpty()){
            BusinessUnitVIPDetails buinessunitVIPDetailsObj = new BusinessUnitVIPDetails();
            buinessunitVIPDetailsObj.url = businessUnitList[0].VIP_API_URL__c;
            buinessunitVIPDetailsObj.username = businessUnitList[0].VIP_API_User_Name__c;
            buinessunitVIPDetailsObj.password = businessUnitList[0].VIP_API_User_Password__c;
            buinessunitVIPDetailsObj.cookie = businessUnitList[0].VIPCookie__c;
            return buinessunitVIPDetailsObj;
        } else {
            return null;
        }
    }

    public static AccountARDetails getAccountARDetails(String accountNumber, String vipInstance, Date deliveryDate, List<OrderItem> orderItems){
        AccountARDetails accountARDetailsObj = new AccountARDetails();
        AccountARDetailsRequest accountARDetailsRequestObj = new AccountARDetailsRequest();
        accountARDetailsRequestObj.AccountNumber = accountNumber;
        accountARDetailsRequestObj.moeCredentials = getBusinessUnitDetails(vipInstance);
        if(deliveryDate == null){
            String orderDeliveryDate = String.valueOf(System.today());
            accountARDetailsRequestObj.AnticipatedDeliveryDate = String.valueOf(orderDeliveryDate.replaceAll('-', ''));
        } else {
            String orderDeliveryDate = String.valueOf(deliveryDate);
            accountARDetailsRequestObj.AnticipatedDeliveryDate = String.valueOf(orderDeliveryDate.replaceAll('-', ''));
        }
        accountARDetailsRequestObj.DetailRecords = getOrderLineItemDetails(orderItems);
        String accountARDetailsRequestBody = JSON.serialize(accountARDetailsRequestObj);
        HttpResponse accountARDetailsResponse = MulesoftUtility.mulesoftCallout('Account ARDetails', vipInstance, null, null, accountARDetailsRequestBody);

        if(accountARDetailsResponse.getStatusCode() == 200){
            accountARDetailsObj = (AccountARDetails)JSON.deserialize(accountARDetailsResponse.getBody(), AccountARDetails.class);
        }
        accountARDetailsObj.apiResponseCode = String.valueOf(accountARDetailsResponse.getStatusCode());
        return accountARDetailsObj;
    }

    public static Order addOrderSummaryDetails(String arDetails, Order orderObj){
        AccountARDetails arDetailObj = (AccountARDetails)JSON.deserialize(arDetails, AccountARDetails.class);
        orderObj.Delivery_Charge__c = isNull(arDetailObj.DeliveryCharge) ? 0.00 : arDetailObj.DeliveryCharge;
        orderObj.Gross_Sales__c = arDetailObj.TotalSales;
        orderObj.Sales_Tax__c = arDetailObj.SalesTax;
        orderObj.Service_Charge__c = arDetailObj.OverShort;
        if(arDetailObj.TotalDeposit != null && arDetailObj.TotalDiscount != null && arDetailObj.TotalCRV != null && arDetailObj.TotalSales != null){
            orderObj.Subtotal__c = arDetailObj.TotalSales - (arDetailObj.TotalDeposit + arDetailObj.TotalDiscount + arDetailObj.TotalCRV);
        } else {
            orderObj.Subtotal__c = arDetailObj.TotalSales;
        }
        orderObj.Total_Credits__c = arDetailObj.TotalCredits;
        orderObj.Total_CRV__c = arDetailObj.TotalCRV;
        orderObj.Total_Deposit__c = arDetailObj.TotalDeposit;
        orderObj.Total_Discount__c = arDetailObj.TotalDiscount;
        orderObj.Total_Net_Price__c = arDetailObj.TotalNetPrice;
        return orderObj;
    }

    public static HttpResponse accountValidateDetails(String accountNumber, String vipInstance){
        ValidateAccountRequest validateAccountRequestObj = new ValidateAccountRequest();
        accountNumber = accountNumber;
        validateAccountRequestObj.validateAccountRequest = getAccountRecordsForRequest(new Set<String>{accountNumber});
        String accountValidateRequestBody = JSON.serialize(validateAccountRequestObj);
        HttpResponse accountValidateResponse = MulesoftUtility.mulesoftCallout('Account Validate', vipInstance, null, null, accountValidateRequestBody);
        return accountValidateResponse;
    }

    @TestVisible
    private static AccountRequest getAccountRecordsForRequest(Set<String> accountNumbers){
        AccountRequest accountRequestObj = new AccountRequest();
        accountRequestObj.AccountRecords = getAccountRecordList(accountNumbers);
        return accountRequestObj;
    }

    @TestVisible
    private static List<AccountRequestInfo> getAccountRecordList(Set<String> accountNumbers){
        List<AccountRequestInfo> accountRequestInfoList = new List<AccountRequestInfo>();
        for(String accountNum : accountNumbers){
            AccountRequestInfo tempAccountRequestInfo = new AccountRequestInfo();
            tempAccountRequestInfo.AccountNumber = accountNum;
            accountRequestInfoList.add(tempAccountRequestInfo);
        }
        return accountRequestInfoList;
    }

    public static List<OrderEntryController.AccountPricebookProducts> priceInventoryDetails(String accountNumber, String vipInstance, Date deliveryDate, List<OrderEntryController.AccountPricebookProducts> accountProducts) {
        Set<String> productExternalIds = new Set<String>();
        for(OrderEntryController.AccountPricebookProducts accountPricebookObj : accountProducts) {
            productExternalIds.add(accountPricebookObj.item);
        }

        PriceInventoryDetails priceInventoryDetailsObj = new PriceInventoryDetails();
        priceInventoryDetailsObj.AccountNumber = accountNumber;
        priceInventoryDetailsObj.moeCredentials = getBusinessUnitDetails(vipInstance);
        if(deliveryDate == null){
            //priceInventoryDetailsObj.AnticipatedDeliveryDate = String.valueOf(System.today());
            priceInventoryDetailsObj.AnticipatedDeliveryDate = convertToDateFormatNumber(System.today());
        } else {
            //priceInventoryDetailsObj.AnticipatedDeliveryDate = String.valueOf(deliveryDate);
            priceInventoryDetailsObj.AnticipatedDeliveryDate = convertToDateFormatNumber(deliveryDate);
        }
        priceInventoryDetailsObj.OutputDealInfo = 'Y';
        priceInventoryDetailsObj.OutputTaxInfo = 'N';
        priceInventoryDetailsObj.ItemRecords = getPriceInventoryLineItems(productExternalIds);
        String priceInventoryDetailsBody = JSON.serialize(priceInventoryDetailsObj);

        HttpResponse priceInventoryResponse = MulesoftUtility.mulesoftCallout('Price Inventory', null, null, null, priceInventoryDetailsBody);
        if (priceInventoryResponse.getStatusCode() == 200) {
            accountProducts = handlePriceInventoryData(priceInventoryResponse, accountProducts, productExternalIds);
        }

        return accountProducts;
    }

    @TestVisible
    private static List<PriceInventoryLineItems> getPriceInventoryLineItems(Set<String> productExternalIds){
        List<PriceInventoryLineItems> priceInventoryLineItemList = new List<PriceInventoryLineItems>();
        for(String prodExternalId : productExternalIds){
            PriceInventoryLineItems priceInventoryLineItemObj = new PriceInventoryLineItems();
            priceInventoryLineItemObj.ItemCode = prodExternalId;
            priceInventoryLineItemList.add(priceInventoryLineItemObj);
        }
        return priceInventoryLineItemList;
    }

    @TestVisible
    private static List<OrderEntryController.AccountPricebookProducts> handlePriceInventoryData(HTTPResponse priceInventoryResponse, List<OrderEntryController.AccountPricebookProducts> accountPricebookProductList, Set<String> productExternalIds){
        PriceInventoryResponse priceInventoryResponseObj = (PriceInventoryResponse)JSON.deserialize(priceInventoryResponse.getBody(), PriceInventoryResponse.class);
        ItemPriceResponse itemPriceResponseObj = priceInventoryResponseObj.ItemPriceResponse;
        Map<String, AccountPricebookProductInfoDetails> accountPriceBookDetailsMap = new Map<String, AccountPricebookProductInfoDetails>();
        WarehouseInventoryResponse warehouseInvResponse = priceInventoryResponseObj.WarehouseInventoryResponse;
        if(warehouseInvResponse.ItemRecords != null){
            for(ItemRecords itemRecordObj : warehouseInvResponse.ItemRecords){
                AccountPricebookProductInfoDetails testAccountPricebookObj = new AccountPricebookProductInfoDetails();
                if(accountPriceBookDetailsMap.containsKey(itemRecordObj.ItemCode)){
                    testAccountPricebookObj = accountPriceBookDetailsMap.get(itemRecordObj.ItemCode);
                }
                testAccountPricebookObj.availQty = itemRecordObj.AvailableQty;
                accountPriceBookDetailsMap.put(itemRecordObj.ItemCode, testAccountPricebookObj);
            }
        }
        //Create a map of Products by productExternalIds (used to get the QuantityUnitofMeasure and Units_per_Case__c)
        List<Product2> prods = ProductDAO.getProductByExternalIds(productExternalIds);
        Map<String, Product2> prodMap = new Map<String, Product2>();
        for (Product2 prod : prods) {            
            prodMap.put(prod.SKU_External_Id__c, prod);
        }
        //Loop through the results from the Price API
        if(itemPriceResponseObj.ItemPriceRecords != null){
            for(ItemPriceRecords itemPriceObj : itemPriceResponseObj.ItemPriceRecords){
                AccountPricebookProductInfoDetails testAccountPricebookObj = new AccountPricebookProductInfoDetails();
                if(accountPriceBookDetailsMap.containsKey(itemPriceObj.ItemCode)){
                    testAccountPricebookObj = accountPriceBookDetailsMap.get(itemPriceObj.ItemCode);
                }
                testAccountPricebookObj.itemCode = itemPriceObj.ItemCode;
                testAccountPricebookObj.itemPrice = itemPriceObj.CasePrice;                
                //For Products that have a QuantityUnitofMeasure of 'BW' we want to use the unitPrice, otherwise we use the casePrice
                if (prodMap.containsKey(itemPriceObj.ItemCode) && prodMap.get(itemPriceObj.ItemCode).QuantityUnitofMeasure == 'BW') {
                    testAccountPricebookObj.itemPrice = itemPriceObj.UnitPrice;
                }
                //Get the Units per Case from the Product
                if (prodMap.containsKey(itemPriceObj.ItemCode)) {
                    testAccountPricebookObj.unitsPerCase = prodMap.get(itemPriceObj.ItemCode).Units_per_Case__c;
                }
                testAccountPricebookObj.casePrice = itemPriceObj.CasePrice;
                testAccountPricebookObj.unitPrice = itemPriceObj.UnitPrice;             
                testAccountPricebookObj.caseDeposit = itemPriceObj.CaseDeposit;
                testAccountPricebookObj.unitDeposit = itemPriceObj.UnitDeposit;
                testAccountPricebookObj.casePostOff = itemPriceObj.CasePostOff;
                testAccountPricebookObj.unitPostOff = itemPriceObj.UnitPostOff;
                testAccountPricebookObj.caseCRV = itemPriceObj.CaseCRV;
                testAccountPricebookObj.unitCRV = itemPriceObj.UnitCRV;
                Set<String> dealIds = new Set<String>();
                if(itemPriceResponseObj.ItemDealRecords != null){
                    for(ItemDealRecords itemDealObj : itemPriceResponseObj.ItemDealRecords){
                        if(itemPriceObj.ItemCode == itemDealObj.ItemCode){
                            dealIds.add(itemDealObj.DealID);
                        }
                    }
                }
                List<DealRecords> dealRecordsList = new List<DealRecords>();
                if(itemPriceResponseObj.DealDetailRecords != null){
                    for(DealDetailRecords dealDetailsObj : itemPriceResponseObj.DealDetailRecords){
                        if(dealIds.contains(dealDetailsObj.DealID)){
                            DealRecords tempDealRecords = new DealRecords();
                            tempDealRecords.dealId = dealDetailsObj.DealID;
                            tempDealRecords.dealDescription = dealDetailsObj.DealDescription;
                            tempDealRecords.dealType = dealDetailsObj.DealType;
                            tempDealRecords.individualFlag = dealDetailsObj.IndividualFlag;
                            tempDealRecords.performanceFlag = dealDetailsObj.PerformanceFlag;
                            List<DealBreakRecordInfo> dealBreakRecordsList = new List<DealBreakRecordInfo>();
                            for(DealBreakRecords dealBreakDetailsObj : itemPriceResponseObj.DealBreakRecords){
                                if(dealIds.contains(dealBreakDetailsObj.DealID)){
                                    if(itemPriceObj.ItemCode == dealBreakDetailsObj.ItemCode || dealBreakDetailsObj.ItemCode == '000000'){
                                        DealBreakRecordInfo tempDealBreakRecordsInfo = new DealBreakRecordInfo();
                                        tempDealBreakRecordsInfo.quantity = dealBreakDetailsObj.Quantity;
                                        tempDealBreakRecordsInfo.amount = dealBreakDetailsObj.Amount;
                                        tempDealBreakRecordsInfo.performanceAmount = dealBreakDetailsObj.PerformanceAmount;
                                        dealBreakRecordsList.add(tempDealBreakRecordsInfo);
                                    }
                                }
                            }
                            tempDealRecords.dealBreakRecords =  dealBreakRecordsList;
                            dealRecordsList.add(tempDealRecords);
                        }
                    }
                }
                testAccountPricebookObj.ItemRecords = dealRecordsList;
                accountPriceBookDetailsMap.put(itemPriceObj.ItemCode, testAccountPricebookObj);
            }
        }

        for(OrderEntryController.AccountPricebookProducts accountPricebookProdObj : accountPricebookProductList) {
            if(accountPriceBookDetailsMap.containsKey(accountPricebookProdObj.item.leftPad(6, '0'))) {
                accountPricebookProdObj.qtyAvail = accountPriceBookDetailsMap.get(accountPricebookProdObj.item.leftPad(6, '0')).availQty;
                if(accountPricebookProdObj.qtyAvail > 0){
                    accountPricebookProdObj.stock = true;
                } else {
                    accountPricebookProdObj.stock = false;
                }
                accountPricebookProdObj.itemPrice = isNull(accountPriceBookDetailsMap.get(accountPricebookProdObj.item.leftPad(6, '0')).itemPrice) ? 0.00 : accountPriceBookDetailsMap.get(accountPricebookProdObj.item.leftPad(6, '0')).itemPrice;
                accountPricebookProdObj.unitPrice = isNull(accountPriceBookDetailsMap.get(accountPricebookProdObj.item.leftPad(6, '0')).unitPrice) ? 0.00 : accountPriceBookDetailsMap.get(accountPricebookProdObj.item.leftPad(6, '0')).unitPrice;
                List<DealRecords> dealRecordsForItem = accountPriceBookDetailsMap.get(accountPricebookProdObj.item.leftPad(6, '0')).ItemRecords;
                Decimal unitDiscount = 0.00;
                if(dealRecordsForItem != null){
                    if(!dealRecordsForItem.isEmpty()){
                        if(!dealRecordsForItem[0].dealBreakRecords.isEmpty()){
                            if(dealRecordsForItem[0].dealBreakRecords[0].quantity == 1){
                                if(dealRecordsForItem[0].dealBreakRecords[0].amount != null){
                                    unitDiscount = dealRecordsForItem[0].dealBreakRecords[0].amount;
                                }
                            }
                        }
                    }
                }
                accountPricebookProdObj.unitDiscount = unitDiscount;
                if(accountPriceBookDetailsMap.get(accountPricebookProdObj.item.leftPad(6, '0')).itemPrice != null && accountPriceBookDetailsMap.get(accountPricebookProdObj.item.leftPad(6, '0')).unitDeposit != null){
                    accountPricebookProdObj.exPrice = accountPriceBookDetailsMap.get(accountPricebookProdObj.item.leftPad(6, '0')).itemPrice + accountPriceBookDetailsMap.get(accountPricebookProdObj.item.leftPad(6, '0')).unitDeposit - unitDiscount;
                } else {
                    if(accountPriceBookDetailsMap.get(accountPricebookProdObj.item.leftPad(6, '0')).itemPrice != null){
                        accountPricebookProdObj.exPrice = accountPriceBookDetailsMap.get(accountPricebookProdObj.item.leftPad(6, '0')).itemPrice - unitDiscount;
                    } else {
                        accountPricebookProdObj.exPrice = 0.00;
                    }
                }
                accountPricebookProdObj.itemPrice = isNull(accountPriceBookDetailsMap.get(accountPricebookProdObj.item.leftPad(6, '0')).itemPrice) ? 0.00 : accountPriceBookDetailsMap.get(accountPricebookProdObj.item.leftPad(6, '0')).itemPrice;
                accountPricebookProdObj.casePrice = isNull(accountPriceBookDetailsMap.get(accountPricebookProdObj.item.leftPad(6, '0')).casePrice) ? 0.00 : accountPriceBookDetailsMap.get(accountPricebookProdObj.item.leftPad(6, '0')).casePrice;
                accountPricebookProdObj.caseDeposit = isNull(accountPriceBookDetailsMap.get(accountPricebookProdObj.item.leftPad(6, '0')).caseDeposit) ? 0.00 : accountPriceBookDetailsMap.get(accountPricebookProdObj.item.leftPad(6, '0')).caseDeposit;
                accountPricebookProdObj.unitDeposit = isNull(accountPriceBookDetailsMap.get(accountPricebookProdObj.item.leftPad(6, '0')).unitDeposit) ? 0.00 : accountPriceBookDetailsMap.get(accountPricebookProdObj.item.leftPad(6, '0')).unitDeposit;
                accountPricebookProdObj.casePostOff = isNull(accountPriceBookDetailsMap.get(accountPricebookProdObj.item.leftPad(6, '0')).casePostOff) ? 0.00 : accountPriceBookDetailsMap.get(accountPricebookProdObj.item.leftPad(6, '0')).casePostOff;
                accountPricebookProdObj.unitPostOff = isNull(accountPriceBookDetailsMap.get(accountPricebookProdObj.item.leftPad(6, '0')).unitPostOff) ? 0.00 : accountPriceBookDetailsMap.get(accountPricebookProdObj.item.leftPad(6, '0')).unitPostOff;
                accountPricebookProdObj.caseCRV = isNull(accountPriceBookDetailsMap.get(accountPricebookProdObj.item.leftPad(6, '0')).caseCRV) ? 0.00 : accountPriceBookDetailsMap.get(accountPricebookProdObj.item.leftPad(6, '0')).caseCRV;
                accountPricebookProdObj.unitCRV = isNull(accountPriceBookDetailsMap.get(accountPricebookProdObj.item.leftPad(6, '0')).unitCRV) ? 0.00 : accountPriceBookDetailsMap.get(accountPricebookProdObj.item.leftPad(6, '0')).unitCRV;
                accountPricebookProdObj.unitsPerCase = isNull(accountPriceBookDetailsMap.get(accountPricebookProdObj.item.leftPad(6, '0')).unitsPerCase) ? 0 : accountPriceBookDetailsMap.get(accountPricebookProdObj.item.leftPad(6, '0')).unitsPerCase;
                accountPricebookProdObj.ItemRecords = accountPriceBookDetailsMap.get(accountPricebookProdObj.item.leftPad(6, '0')).ItemRecords;
            }
        }

        return accountPricebookProductList;
    }

    @TestVisible
    private static Boolean isNull(Decimal value){
        if(value == null){
            return true;
        }
        return false;
    }

    public static HttpResponse submitOrderValidateDetails(String poNumber, String orderActionCode, String accountNumber, String vipInstance, String salesManagerRoute, Date deliveryDate, String orderId, String orderStatus, String orderSource, List<OrderItem> orderItems){
        SubmitOrderDetails submitOrderDetailsObj = new SubmitOrderDetails();
        submitOrderDetailsObj.Salesman = salesManagerRoute;
        submitOrderDetailsObj.AccountId = accountNumber;
        // ---> REMOVING MOE CALL ---> submitOrderDetailsObj.MoeCredentials = getBusinessUnitDetails(vipInstance);
        submitOrderDetailsObj.BusinessUnitId = vipInstance;
        submitOrderDetailsObj.OrderId = orderId;
        submitOrderDetailsObj.OrderStatus = orderStatus;
        // ---> Adding order source for BSSP-2425 --->  
        submitOrderDetailsObj.OrderSource = orderSource;
        submitOrderDetailsObj.DeliveryDate = String.valueOf(deliveryDate);
        if(poNumber != null && poNumber != ''){
            submitOrderDetailsObj.PurchaseOrderNumber = poNumber;
            submitOrderDetailsObj.OrderActionCode = 'SP';
        } else {
            submitOrderDetailsObj.PurchaseOrderNumber = '';
            if(orderActionCode != null){
                submitOrderDetailsObj.OrderActionCode = orderActionCode;
            } else {
                submitOrderDetailsObj.OrderActionCode = '';
            }
        }
        submitOrderDetailsObj.EPiPurchaseOrderId = '';
        submitOrderDetailsObj.ContactEmail = '';
        submitOrderDetailsObj.LineItems = getOrderLineItemDetails(orderItems);
        String orderValidateBody = JSON.serialize(submitOrderDetailsObj);
        HttpResponse orderValidateResponse = MulesoftUtility.mulesoftCallout('Order Validate', vipInstance, null, null, orderValidateBody);
        return orderValidateResponse;
    }

    @TestVisible
    private static List<OrderLineItem> getOrderLineItemDetails(List<OrderItem> orderItems){
        List<OrderLineItem> orderLineItemList = new List<OrderLineItem>();
        Integer orderItemIndex = 1;
        for(OrderItem orderItemObj : orderItems){
            if(Integer.valueOf(orderItemObj.Quantity_Order__c) > 0){
                OrderLineItem orderLineItemObj = new OrderLineItem();
                orderLineItemObj.LineNumber = orderItemIndex;
                orderLineItemObj.LineType = orderItemObj.Type__c;
                orderLineItemObj.ItemCode = orderItemObj.Product2.SKU_External_Id__c;
                orderLineItemObj.Quantity = Integer.valueOf(orderItemObj.Quantity_Order__c);
                if(orderItemObj.Order_UOM__c != null){
                    orderLineItemObj.OrderUOM = orderItemObj.Order_UOM__c;
                } else if(orderItemObj.UOM__c != null){
                    orderLineItemObj.OrderUOM = orderItemObj.UOM__c;
                } else {
                    orderLineItemObj.OrderUOM = '';
                }
                orderLineItemObj.IsUnitQuantity = orderItemObj.IsUnitQuantity__c;
                orderLineItemList.add(orderLineItemObj);
                orderItemIndex++;
            }
        }
        return orderLineItemList;
    }

    public class SubmitOrderDetails {
        public String AccountId;
        //public BusinessUnitVIPDetails MoeCredentials;
        public String BusinessUnitId;
        public String Salesman;
        public String OrderId;
        public String OrderStatus;
        public String OrderSource;
        public String DeliveryDate;
        public String PurchaseOrderNumber;
        public String OrderActionCode;
        public String EPiPurchaseOrderId;
        public String ContactEmail;
        public List<OrderLineItem> LineItems;
    }

    public class ValidateAccountRequest {
//        public BusinessUnitVIPDetails moeCredentials;
        public AccountRequest validateAccountRequest;
    }

    public class AccountRequest {
        public List<AccountRequestInfo> AccountRecords;
    }

    public class AccountRequestInfo {
        public String AccountNumber;
    }

    public class AccountARDetails {
        @AuraEnabled public Decimal TotalSales;
        @AuraEnabled public Decimal TotalDeposit;
        @AuraEnabled public Decimal TotalDiscount;
        @AuraEnabled public Decimal TotalCRV;
        @AuraEnabled public Decimal DeliveryCharge;
        @AuraEnabled public Decimal SalesTax;
        @AuraEnabled public Decimal TotalCredits;
        @AuraEnabled public Decimal OverShort;
        @AuraEnabled public Decimal TotalNetPrice;
        @AuraEnabled public String apiResponseCode;
    }

    public class AccountARDetailsRequest {
        public String AccountNumber;
        public BusinessUnitVIPDetails moeCredentials;
        public String AnticipatedDeliveryDate;
        public List<OrderLineItem> DetailRecords;
    }

    public class BusinessUnitVIPDetails {
        public String url;
        public String username;
        public String password;
        public String cookie;
    }

    public class OrderLineItem {
        public Integer LineNumber;
        public String LineType;
        public String ItemCode;
        public Integer Quantity;
        public String OrderUOM;
        public Boolean IsUnitQuantity;
    }

    public class AccountPricebookProductInfoDetails {
        public String itemCode;
        public Integer availQty;
        public Decimal itemPrice;
        public Decimal casePrice;
        public Decimal unitPrice;
        public Decimal caseDeposit;
        public Decimal unitDeposit;
        public Decimal casePostOff;
        public Decimal unitPostOff;
        public Decimal caseCRV;
        public Decimal unitCRV;
        public Decimal unitsPerCase;
        @AuraEnabled public List<DealRecords> ItemRecords;
    }

    public class DealRecords {
        @AuraEnabled public String dealId;
        @AuraEnabled public String dealDescription;
        @AuraEnabled public String dealType;
        @AuraEnabled public String individualFlag;
        @AuraEnabled public String performanceFlag;
        @AuraEnabled public List<DealBreakRecordInfo> dealBreakRecords;
    }

    public class DealBreakRecordInfo {
        @AuraEnabled public Integer quantity;
        @AuraEnabled public Decimal amount;
        @AuraEnabled public Decimal performanceAmount;
    }

    public class PriceInventoryDetails {
        public String AccountNumber;
        public BusinessUnitVIPDetails moeCredentials;
        public Integer AnticipatedDeliveryDate;
        public String OutputDealInfo;
        public String OutputTaxInfo;
        public List<PriceInventoryLineItems> ItemRecords;
    }

    public class PriceInventoryLineItems {
        public String ItemCode;
    }

    public class PriceInventoryResponse {
        public WarehouseInventoryResponse WarehouseInventoryResponse;
        public ItemPriceResponse ItemPriceResponse;
    }

    public class WarehouseInventoryResponse {
        public String AccountNumber;
        public List<ItemRecords> ItemRecords;
    }

    public class ItemRecords {
        public String ItemCode;
        public Integer AvailableQty;
        public Integer RemainingAllocationQty;
        public Integer AvailableCTCQty;
        public Integer CasesPerTier;
        public boolean RoundToNextTier;
    }

    public class ItemPriceResponse {
        public String AccountNumber;
        public String AnticipatedDeliveryDate;
        public List<ItemPriceRecords> ItemPriceRecords;
        public List<ItemDealRecords> ItemDealRecords;
        public List<DealDetailRecords> DealDetailRecords;
        public List<DealBreakRecords> DealBreakRecords;
    }

    public class ItemPriceRecords {
        public String ItemCode;
        public Decimal CasePrice;
        public Decimal UnitPrice;
        public Decimal CaseDeposit;
        public Decimal UnitDeposit;
        public Decimal CasePostOff;
        public Decimal UnitPostOff;
        public Decimal CaseCRV;
        public Decimal UnitCRV;
        public Decimal SSP;
        public Decimal MinCasePrice;
        public Decimal MinUnitPrice;
        public boolean BlockPriceOverride;
        public String InvoiceType;
        public String ARType;
    }

    public class ItemDealRecords {
        public String ItemCode;
        public String DealID;
        public Integer Level;
        public boolean ShowIndicator;
    }

    public class DealDetailRecords {
        public String DealID;
        public Integer Level;
        public String DealDescription;
        public String DealType;
        public String IndividualFlag;
        public String PerformanceFlag;
        public String PerformancePromptOncePerOrder;
        public String UnitDeal;
    }

    public class DealBreakRecords {
        public String DealID;
        public Integer Level;
        public String ItemCode;
        public Integer Quantity;
        public Decimal Amount;
        public Decimal PerformanceAmount;
    }
    
    public static Integer convertToDateFormatNumber(Date d){ //YYYYMMDD
        if(d!= null){
            String month = String.valueOf(d.month()).leftPad(2,'0');
            String day =  String.valueOf(d.day()).leftPad(2,'0');
            String datestr = d.year() + month + day;
            return Integer.valueof(datestr.trim());
        }
        return 0;
    }
}
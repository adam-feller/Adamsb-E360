public without sharing class OrderEntryController {

    @AuraEnabled
    public static OrderSummaryDetail getOrderSummaryDetails(String orderId) {
        OrderSummaryDetail orderSummaryDetailObj = new OrderSummaryDetail();
        List<SelectDetails> statusList = new List<SelectDetails>();
        
        Schema.DescribeFieldResult statusFieldResult = Order.Status.getDescribe();
        List<Schema.PicklistEntry> statusFieldList = statusFieldResult.getPicklistValues();
        for( Schema.PicklistEntry statusVal : statusFieldList){
            SelectDetails selectOptionObj = new SelectDetails();
            selectOptionObj.label = statusVal.getLabel();
            selectOptionObj.value = statusVal.getValue();
            statusList.add(selectOptionObj);
        }

        //for Order Origin
        List<SelectDetails> originList = new List<SelectDetails>();
        Schema.DescribeFieldResult originFieldResult = Order.Order_Origin__c.getDescribe();
        List<Schema.PicklistEntry> originFieldList = originFieldResult.getPicklistValues();
        for( Schema.PicklistEntry originVal : originFieldList){
            SelectDetails selectOriginOptionObj = new SelectDetails();
            selectOriginOptionObj.label = originVal.getLabel();
            selectOriginOptionObj.value = originVal.getValue();
            originList.add(selectOriginOptionObj);
        }

        //for third party order type field
        List<SelectDetails> thirdPartyOrderTypeList = new List<SelectDetails>();
        Schema.DescribeFieldResult thirdPartyOrderTypeFieldResult = Order.Third_Party_Order_Type__c.getDescribe();
        List<Schema.PicklistEntry> thirdPartyOrderTypeFieldList = thirdPartyOrderTypeFieldResult.getPicklistValues();
        for( Schema.PicklistEntry thirdPartyOrderTypeVal : thirdPartyOrderTypeFieldList){
            SelectDetails selectThirdPartyTypeOptionObj = new SelectDetails();
            selectThirdPartyTypeOptionObj.label = thirdPartyOrderTypeVal.getLabel();
            selectThirdPartyTypeOptionObj.value = thirdPartyOrderTypeVal.getValue();
            thirdPartyOrderTypeList.add(selectThirdPartyTypeOptionObj);
        }


        List<Order> orderObj = OrderDAO.getOrderDetailsbyId(orderId);
        List<Account> accountObj = AccountDAO.getAccountsByIds(new Set<Id>{orderObj[0].AccountId});
        Map<String, Integer> dayOfTheWeekMap = DateScheduleUtility.dayOfTheWeekMap;
        List<Call_Scheduling_Frequency__mdt> callScheduleFrequency = CallSchedulingFrequencyDAO.getCallSchedlingFrequency();

        Map<String, Call_Scheduling_Frequency__mdt> callScheduleFrequencyMap = new Map<String, Call_Scheduling_Frequency__mdt>();
        for(Call_Scheduling_Frequency__mdt callSchedule : callScheduleFrequency){
            callScheduleFrequencyMap.put(callSchedule.MasterLabel, callSchedule);
        }

        Date todaysDate = System.today() + 1;
        List<Delivery_Date__c> deliveryDates = DeliveryDateDAO.getDeliveryDatesAccountDateStatus(new Set<Id>{orderObj[0].AccountId}, todaysDate, 'Active');
        Date deliveryDate;
        if(!deliveryDates.isEmpty()){
            deliveryDate = deliveryDates[0].Delivery_Date__c;
        }

        orderSummaryDetailObj.poNumber = orderObj[0].PoNumber;
        orderSummaryDetailObj.statusOptions = statusList;
        // Origin, 3rd party order type
        orderSummaryDetailObj.originOptions = originList;
        orderSummaryDetailObj.thirdPartyOrderTypeOptions = thirdPartyOrderTypeList;
        if(orderObj[0].Delivery_Date__c != null){
            orderSummaryDetailObj.deliveryDate = orderObj[0].Delivery_Date__c;
        } else {
            orderSummaryDetailObj.deliveryDate = deliveryDate;
        }
        orderSummaryDetailObj.nextFrequencyDeliveryDate = deliveryDate;
        orderSummaryDetailObj.orderName = orderObj[0].OrderNumber;
        orderSummaryDetailObj.orderStatus = orderObj[0].Status;
        orderSummaryDetailObj.requirePO = accountObj[0].Require_PO__c;
        orderSummaryDetailObj.accStatus = accountObj[0].Status__c;
        orderSummaryDetailObj.agentName = orderObj[0].CreatedBy.Name;
        orderSummaryDetailObj.offDay = orderObj[0].Off_Day__c;
        orderSummaryDetailObj.offFrequency = orderObj[0].Off_Frequency__c;
        orderSummaryDetailObj.orderErrors = orderObj[0].Order_Errors__c;
        orderSummaryDetailObj.accountId = accountObj[0].Id;
        orderSummaryDetailObj.orderDetails = orderObj[0].Order_Details__c;
        orderSummaryDetailObj.orderOrigin = orderObj[0].Order_Origin__c;
        orderSummaryDetailObj.thirdPartyOrderType = orderObj[0].Third_Party_Order_Type__c;
        orderSummaryDetailObj.fsrOrder = orderObj[0].FSR_Consultant_Order__c;
        orderSummaryDetailObj.gpGoal = accountObj[0].Customer_GP_Goal__c;
        
        if (orderObj[0].Contact__c != null) {
            orderSummaryDetailObj.contactName = orderObj[0].Contact__r.Name;
            orderSummaryDetailObj.contactId = orderObj[0].Contact__c;
        } else {
            if (accountObj[0].Primary_POC__c != null) {
                orderSummaryDetailObj.contactName = accountObj[0].Primary_POC__r.Name;
                orderSummaryDetailObj.contactId = accountObj[0].Primary_POC__c;
            }
        }

        Boolean updateOrder = false;
        Order tempOrder = new Order();
        tempOrder.Id = orderObj[0].Id;
        if(orderObj[0].Delivery_Date__c == null){
            tempOrder.Delivery_Date__c = deliveryDate;
            updateOrder = true;
        }
        if(orderObj[0].Contact__c == null || orderObj[0].Order_Placed_By__c == null){
            if(orderSummaryDetailObj.contactId != null){
                tempOrder.Contact__c = orderSummaryDetailObj.contactId;
                tempOrder.Order_Placed_By__c = orderSummaryDetailObj.contactId;
                updateOrder = true;
            }
        }

        if(updateOrder){
            OrderDAO.updateOrders(new List<Order>{tempOrder});
        }
        return orderSummaryDetailObj;
    }

    @AuraEnabled
    public static WarehouseOrderDetail getWarehouseThreshold(String orderId) {
        WarehouseOrderDetail warehouseOrderDetailObj = new WarehouseOrderDetail();
        List<Order> orderObj = OrderDAO.getOrderDetailsbyId(orderId);
        List<Account> accountObj = AccountDAO.getAccountsByIds(new Set<Id>{orderObj[0].AccountId});
        if(accountObj[0].Warehouse_Lookup__c != null){
            List<Warehouse__c> warehouseObj = WarehouseDAO.getWarehousesByIds(new Set<Id>{accountObj[0].Warehouse_Lookup__c});
            warehouseOrderDetailObj.warehouseObj = warehouseObj[0];
            warehouseOrderDetailObj.deliveryDate = orderObj[0].Delivery_Date__c;
            List<Account_Term_Type__mdt> accountTermTypes = AccountTermTypeDAO.getAccountTermTypeErrorCodes();
            Boolean disableSubmit = false;
            for(Account_Term_Type__mdt accountTermTypeObj : accountTermTypes){
                if(accountTermTypeObj.BU__c == accountObj[0].VIP_Instance__c){
                    if(accountTermTypeObj.Term_Type__c == accountObj[0].Terms__c){
                        if(accountTermTypeObj.Prevent_Order__c){
                            disableSubmit = true;
                        }
                    }
                }
            }
            warehouseOrderDetailObj.disableSubmitOrder = disableSubmit;
            return warehouseOrderDetailObj;
        } else {
            return null;
        }
    }
    
    @AuraEnabled
    public static Boolean getUnscheduled(String orderId) {
        List<Order> orderObj = OrderDAO.getOrderDetailsbyId(orderId);
        if(orderObj[0].Off_Day__c || orderObj[0].Off_Frequency__c) {
            return true;
        } else {
            return false;
        }
    }

    @AuraEnabled
    public static List<String> getPriorOrderUnscheduledReasons(String orderId) {
        List<Order> orderObj = OrderDAO.getOrderDetailsbyId(orderId);
        List<Order> priorOrders = OrderDAO.getPriorOrdersUnscheduledReasonCodesbyId(orderObj[0].AccountId);
        List<String> priorReasonCodes = new List<String>();
        for (Order o : priorOrders) {
            String reasonCode = o.Unscheduled_Reason_Code__c;
            if (reasonCode == null) {
                reasonCode = 'Unknown Reason';   //This is for old records that had Off Day/Off Frequency checked but there was no Reason code at the time
            }
            if (o.Missed_Delivery_Reason_Code__c != null) {
            	priorReasonCodes.add(o.Delivery_Date__c.format() + ' - ' + reasonCode + ' (' + o.Missed_Delivery_Reason_Code__c + ')');
            } else {
                priorReasonCodes.add(o.Delivery_Date__c.format() + ' - ' + reasonCode);
            }
        }
        return priorReasonCodes;
    }    
    
    @AuraEnabled
    public static void setUnscheduled(String orderId, String unscheduledCode, String missedDeliveryCode) {
        List<Order> orderObj = OrderDAO.getOrderDetailsbyId(orderId);
        orderObj[0].Unscheduled_Reason_Code__c = unscheduledCode;
        orderObj[0].Missed_Delivery_Reason_Code__c = missedDeliveryCode;
        OrderDAO.updateOrders(new List<Order>{orderObj[0]});
    }
    
    
    @TestVisible
    private static List<String> validateOrder(List<OrderItem> orderItemsReturned, Date deliveryDate, Account accountObj, String poNum, String orderOrigin, String thirdPartyOrderType){
        List<String> errorMessageList = new List<String>();
        Boolean qtyMissing = false;
        for(OrderItem orderItemObj : orderItemsReturned){
            if(orderItemObj.Quantity_Order__c == 0){
                qtyMissing = true;
            }
        }

        if(orderItemsReturned.isEmpty() || qtyMissing){
            String orderItemErrorMsg = Label.Error_Please_add_at_least_one_product_with_a_quantity_greater_than_zero;
            errorMessageList.add(orderItemErrorMsg);
        }

        if(deliveryDate == null || deliveryDate < System.today()){
            String deliveryDateErrorMsg = Label.Error_Orders_must_have_a_delivery_date_equal_to_or_greater_than_today;
            errorMessageList.add(deliveryDateErrorMsg);
        }

        if(accountObj.Require_PO__c){
            if(poNum == null){
                String poErrorMsg = Label.Error_Please_provide_a_PO_customer_requires_a_purchase_order;
                errorMessageList.add(poErrorMsg);
            }
        }

        if(accountObj.Status__c != 'A'){
            String activeErrorMsg = Label.Error_Orders_cannot_be_placed_for_customers_that_are_inactive;
            errorMessageList.add(activeErrorMsg);
        }

        if(accountObj.LicenseExpirationDate__c < System.today()){
            String licenseErrorMsg = Label.Error_Orders_cannot_be_placed_for_customers_with_expired_licenses;
            errorMessageList.add(licenseErrorMsg);
        }

        // BSSP 1350 - 3rd Party Order required
        if(orderOrigin == '3rd Party Order' && (thirdPartyOrderType == '' || thirdPartyOrderType == null)){
            String thirdpartyrequiredmessage = Label.Error_Orders_Required_3rd_Party_Order_Type;
            errorMessageList.add(thirdpartyrequiredmessage);
        }

        if(String.isBlank(orderOrigin) && userDAO.getUser(userinfo.getUserID())[0].Profile.Name <> 'Integration' && userDAO.getUser(userinfo.getUserID())[0].Profile.Name <> 'System Administrator'){
            String orderoriginrequiredmessage = Label.Order_Error_Order_Origin_Required;
            errorMessageList.add(orderoriginrequiredmessage);
        }

        return errorMessageList;
    }

    @AuraEnabled
    public static OrderResponseDetail updateOrderDetails(String orderId, String poNum, Date deliveryDate, Date nextFrequencyDeliveryDate, String status, String arDetails, String orderDetails, Boolean fsrOrder, String orderOrigin, String thirdPartyOrderType, Decimal caseEquiv, Decimal caseCount, Decimal kegCount) {
        List<Order> orderObjReturned = OrderDAO.getOrderDetailsbyId(orderId);
        List<OrderItem> orderItemsReturned = OrderItemDAO.getOrderItemByOrderId(orderId);
        List<Account> accountObj = AccountDAO.getAccountsByIds(new Set<Id>{orderObjReturned[0].AccountId});
        OrderResponseDetail orderResponseObj = new OrderResponseDetail();
        Boolean error = false;
        Order orderObj = new Order();
        Boolean runSubmitOrderWebService = false;
        List<String> errorMessageList = new List<String>();
        if(poNum == null){
            poNum = orderObjReturned[0].PoNumber;
        }
        if(status == 'Posted to VIP'){
            if(orderItemsReturned.isEmpty()){
                error = true;
            }

            errorMessageList = validateOrder(orderItemsReturned, deliveryDate, accountObj[0], poNum, orderObjReturned[0].Order_Origin__c, orderObjReturned[0].Third_Party_Order_Type__c);

            if(!error && errorMessageList.isEmpty()){
                Date today = System.today();
                Integer daysBetweenTodayAndDeliveryDate = today.daysBetween(deliveryDate);
                if(daysBetweenTodayAndDeliveryDate > 7){
                    status = 'Pending - Future Order';
                } else {
                    runSubmitOrderWebService = true;
                }
            }
        }

        Map<String, Integer> dayOfTheWeekMap = DateScheduleUtility.dayOfTheWeekMap;
        Map<Integer, String> dayOfTheWeekForNumMap = DateScheduleUtility.dayOfTheWeekForNumMap;
        List<String> requestedDeliveryDays = new List<String>();
        if(accountObj[0].Requested_Delivery_Days__c != null){
            requestedDeliveryDays = accountObj[0].Requested_Delivery_Days__c.split(';');
        }
        String deliveryFrequency = accountObj[0].Delivery_Frequency_Type__c;
        if(deliveryDate != null){
            String deliveryDateDayOfWeek = dayOfTheWeekForNumMap.get(DateScheduleUtility.dayOfWeekNumber(deliveryDate));
            if(!requestedDeliveryDays.contains(deliveryDateDayOfWeek)){
                orderObj.Off_Day__c = true;
            } else {
                orderObj.Off_Day__c = false;
            }

            List<Call_Scheduling_Frequency__mdt> callScheduleFrequency = CallSchedulingFrequencyDAO.getCallSchedlingFrequency();

            Map<String, Call_Scheduling_Frequency__mdt> callScheduleFrequencyMap = new Map<String, Call_Scheduling_Frequency__mdt>();
            for(Call_Scheduling_Frequency__mdt callSchedule : callScheduleFrequency){
                callScheduleFrequencyMap.put(callSchedule.MasterLabel, callSchedule);
            }

            Date todaysDate = System.today();
            Date todaysDateWeek = System.today().toStartOfWeek();
            Date startOfCycle = Date.newInstance(2020, 1, 1).toStartOfWeek();
            Integer daysBetween = startOfCycle.daysBetween(todaysDateWeek);
            Integer numberOfWeek = daysBetween/7;
            Integer fourWeekCycle = numberOfWeek/4;
            Integer daysToAddForCycle = fourWeekCycle * 4 * 7;
            Date startDate = startOfCycle.addDays(daysToAddForCycle);
            Date endDate = startDate.addDays(126).toStartOfWeek();

            if(callScheduleFrequencyMap.containsKey(deliveryFrequency)){
                startDate = startDate.addDays(Integer.valueOf(callScheduleFrequencyMap.get(deliveryFrequency).Preset_Start_Date__c));
            }

            List<Date> frequencyDates = new List<Date>();
            Date deliveryDateStartOfWeek = deliveryDate.toStartOfWeek();
            if(deliveryFrequency != null && requestedDeliveryDays != null){
                do{
                    if(callScheduleFrequencyMap.containsKey(deliveryFrequency)){
                        if(startDate >= todaysDateWeek){
                            for(String deliveryDay : requestedDeliveryDays){
                                Date tempDate = startDate.addDays(Math.mod(7-DateScheduleUtility.dayOfWeekNumber(startDate)+dayOfTheWeekMap.get(deliveryDay),7));
                                if(deliveryDay == 'Monday' && DateScheduleUtility.frequenciesToCheck.contains(deliveryFrequency)){
                                    tempDate = tempDate.addDays(Constants.ONE_WEEK_DAYS);
                                }
                                if(tempDate >= System.today()){
                                    frequencyDates.add(tempDate);
                                }
                            }
                        }
                        startDate = startDate.addDays(Integer.valueOf(callScheduleFrequencyMap.get(deliveryFrequency).Days_To_Advance__c));
                    } else {
                        break;
                    }
                } while(startDate < endDate);
            }

            Boolean offFrequency = true;
            for(Date dateObj : frequencyDates){
                if(dateObj.toStartOfWeek() == deliveryDateStartOfWeek){
                    offFrequency = false;
                }
            }
            orderObj.Off_Frequency__c = offFrequency;
        }

        Boolean validationError = false;
        if(runSubmitOrderWebService && errorMessageList.isEmpty()){
            HttpResponse accountValidateResponse = OrderEntryUtility.accountValidateDetails(accountObj[0].VIP_Account_Number__c, accountObj[0].VIP_Instance__c);
            if(accountValidateResponse.getStatusCode() == 200){  
                ValidateAccountResponse validateAccountResponseObj = (ValidateAccountResponse)JSON.deserialize(accountValidateResponse.getBody(), ValidateAccountResponse.class);
                if(validateAccountResponseObj.AccountRecords != null){
                    if(validateAccountResponseObj.AccountRecords[0].PassFailFlag == '0'){
                        HttpResponse orderValidateResponse = OrderEntryUtility.submitOrderValidateDetails(poNum, orderObjReturned[0].VIPActionCode__c, accountObj[0].VIP_Account_Number__c, accountObj[0].VIP_Instance__c, orderObjReturned[0].Sales_Route_Number__c, deliveryDate, orderObjReturned[0].VIP_Order_Number__c, status, orderObjReturned[0].OrderSourceCode__c, orderItemsReturned);
                        if(orderValidateResponse.getStatusCode() != 201){
                            orderObj.Order_Errors__c = orderValidateResponse.getBody();
                            orderResponseObj.accountValidateError = false;
                            validationError = true;
                        } else {
                            orderObj.Order_Errors__c = null;
                        }
                    } else {
                        validationError = true;
                        orderResponseObj.accountValidateError = true;
                        orderObj.Order_Errors__c = accountValidateResponse.getBody();
                    }
                }
            } else {
                validationError = true;
                orderResponseObj.accountValidateError = false;
                orderObj.Order_Errors__c = accountValidateResponse.getBody();
            }
        }

        if(!error && errorMessageList.isEmpty()){
            orderObj.Id = orderId;
			// BSSP-1356 changes below
            if(caseEquiv != null){
                orderObj.Case_Equivalent__c = caseEquiv;
            }
            if(caseCount != null){
                orderObj.Case_Count__c = caseCount;
            }
  			if(kegCount != null){	
                orderObj.Keg_Count__c = kegCount;	
            }
            // BSSP-1356 changes above            
            if(poNum != null){
                orderObj.PoNumber = poNum;
            }
            if(deliveryDate != null){
                orderObj.Delivery_Date__c = deliveryDate;
            }
            if(status != null){
                if(validationError){
                    orderObj.Status = 'Posting Error';
                } else {
                    orderObj.Status = status;
                }
            }
            if(orderDetails != null){
                orderObj.Order_Details__c = orderDetails;
            }

            if(orderOrigin != null){
                orderObj.Order_Origin__c = orderOrigin;
            }

            if(thirdPartyOrderType != null){
                orderObj.Third_Party_Order_Type__c = thirdPartyOrderType;
            }

            if(arDetails != null){
                orderObj = OrderEntryUtility.addOrderSummaryDetails(arDetails, orderObj);
            }
            if (fsrOrder != null){
                orderObj.FSR_Consultant_Order__c = fsrOrder;
            }

            OrderDAO.updateOrders(new List<Order>{orderObj});
            orderResponseObj.orderObj = orderObj;
            orderResponseObj.orderErrorMsg = errorMessageList;
        } else {
            orderResponseObj.orderObj = orderObjReturned[0];
            orderResponseObj.orderErrorMsg = errorMessageList;
        }

        return orderResponseObj;
    }

    @AuraEnabled
    public static Order updateOrderContact(String orderId, String contactId){
        Order orderObj = new Order();
        orderObj.Id = orderId;
        orderObj.Contact__c = contactId;
        orderObj.Order_Placed_By__c = contactId;
        return OrderDAO.updateOrders(new List<Order>{orderObj})[0];
    }

    @AuraEnabled
    public static List<AccountPricebookProducts> getPricingDetailForNewProduct(String orderId, String productExternalId) {
        List<Order> orderObjReturned = OrderDAO.getOrderDetailsbyId(orderId);
        List<Account> accountObj = AccountDAO.getAccountsByIds(new Set<Id>{orderObjReturned[0].AccountId});
        AccountPricebookProducts tempAccountPricebookProduct = new AccountPricebookProducts();
        tempAccountPricebookProduct.item = productExternalId;
        return OrderEntryUtility.priceInventoryDetails(accountObj[0].VIP_Account_Number__c, accountObj[0].VIP_Instance__c, orderObjReturned[0].Delivery_Date__c, new List<AccountPricebookProducts>{tempAccountPricebookProduct});
    }

    @AuraEnabled
    public static AccountProductsResponse getProductsForAccount(String orderId, Boolean refresh){
        try{
            AccountProductsResponse accountProductsReponseObj = new AccountProductsResponse();
            List<AccountPricebookProducts> accountProducts = new List<AccountPricebookProducts>();
            List<Order> orderInfo = OrderDAO.getOrderDetailsbyId(orderId);
            List<OrderItem> orderItemsReturned = OrderItemDAO.getOrderItemByOrderId(orderId);
            if(!orderInfo.isEmpty()){
                List<Account> accountObj = AccountDAO.getAccountsByIds(new Set<Id>{orderInfo[0].AccountId});
                InvoiceProductDetails invoiceProductDetailsObj = new InvoiceProductDetails();
                List<AccountPricebookProducts> suggestedMandateProducts = new List<AccountPricebookProducts>();
                List<AccountPricebookProducts> createdAndDefaultProducts = getAccountPricebookProducts(orderInfo[0]);
                Map<String, AccountPricebookProducts> pinnedProductMap = new Map<String, AccountPricebookProducts>();
                invoiceProductDetailsObj = getDefaultProducts(orderInfo[0], accountObj[0]);
                if (!refresh) {
                    suggestedMandateProducts = getSuggestedSellAndMandateProducts(orderInfo[0], accountObj[0]);
                    accountProducts.addAll(suggestedMandateProducts);
                }
                createdAndDefaultProducts.addALL(invoiceProductDetailsObj.accountProducts);
                createdAndDefaultProducts.addALL(getPinnedProducts(orderId));
                createdAndDefaultProducts.sort();
                accountProducts.addAll(createdAndDefaultProducts);
                Set<String> priceBookEntryIdsForFlag = new Set<String>();
                for (AccountPricebookProducts accountPricebookProdObj : accountProducts) {
                    if(accountPricebookProdObj.pinnedProd){
                        pinnedProductMap.put(accountPricebookProdObj.id, accountPricebookProdObj);
                    }
                    if (invoiceProductDetailsObj.invoiceDateMap.containsKey(accountPricebookProdObj.id)) {
                        Integer invoiceDateCount = 1;
                        List<InvoiceProductDateDetails> invoiceProductDetailsDates = invoiceProductDetailsObj.invoiceDateMap.get(accountPricebookProdObj.id);

                        List<InvoiceProductDateDetails> orderedInvoiceProductDates = new List<InvoiceProductDateDetails>();
                        for(InvoiceProductDateDetails invoiceProductObj : invoiceProductDetailsDates){
                            if(invoiceProductObj.qtyOrdered > 0){
                                orderedInvoiceProductDates.add(invoiceProductObj);
                            }
                        }

                        if(!orderedInvoiceProductDates.isEmpty()){
                            InvoiceProductDateDetails invoiceProductDetailsFinalDate = orderedInvoiceProductDates[0];
                            Integer daysBetweenInvoiceAndToday = invoiceProductDetailsFinalDate.invoiceDate.daysBetween(System.today());
                            if(daysBetweenInvoiceAndToday >= invoiceProductDetailsObj.flaggedProductFrequency.Num_Of_Days__c){
                                accountPricebookProdObj.flaggedProduct = true;
                                priceBookEntryIdsForFlag.add(invoiceProductDetailsFinalDate.priceBookEntryId);
                            }
                        }

                        for(InvoiceProductDateDetails invoiceDetailObj : invoiceProductDetailsObj.invoiceDateMap.get(accountPricebookProdObj.id)){
                            if(invoiceDateCount == 1){
                                accountPricebookProdObj.invoiceDate1Display = true;
                                accountPricebookProdObj.invoiceDate1Qty = invoiceDetailObj.qtyOrdered;
                            }
                            if(invoiceDateCount == 2){
                                accountPricebookProdObj.invoiceDate2Display = true;
                                accountPricebookProdObj.invoiceDate2Qty = invoiceDetailObj.qtyOrdered;
                            }
                            if(invoiceDateCount == 3){
                                accountPricebookProdObj.invoiceDate3Display = true;
                                accountPricebookProdObj.invoiceDate3Qty = invoiceDetailObj.qtyOrdered;
                            }
                            if(invoiceDateCount == 4){
                                accountPricebookProdObj.invoiceDate4Display = true;
                                accountPricebookProdObj.invoiceDate4Qty = invoiceDetailObj.qtyOrdered;
                            }
                            if(invoiceDateCount == 5){
                                accountPricebookProdObj.invoiceDate5Display = true;
                                accountPricebookProdObj.invoiceDate5Qty = invoiceDetailObj.qtyOrdered;
                            }
                            if(invoiceDateCount == 6){
                                accountPricebookProdObj.invoiceDate6Display = true;
                                accountPricebookProdObj.invoiceDate6Qty = invoiceDetailObj.qtyOrdered;
                            }
                            invoiceDateCount++;
                        }
                    } else {
                        Integer invoiceDateCount = 1;
                        for(String invoiceDate : invoiceProductDetailsObj.invoiceDates){
                            if(invoiceDateCount == 1){
                                accountPricebookProdObj.invoiceDate1Display = true;
                                accountPricebookProdObj.invoiceDate1Qty = 0;
                            }
                            if(invoiceDateCount == 2){
                                accountPricebookProdObj.invoiceDate2Display = true;
                                accountPricebookProdObj.invoiceDate2Qty = 0;
                            }
                            if(invoiceDateCount == 3){
                                accountPricebookProdObj.invoiceDate3Display = true;
                                accountPricebookProdObj.invoiceDate3Qty = 0;
                            }
                            if(invoiceDateCount == 4){
                                accountPricebookProdObj.invoiceDate4Display = true;
                                accountPricebookProdObj.invoiceDate4Qty = 0;
                            }
                            if(invoiceDateCount == 5){
                                accountPricebookProdObj.invoiceDate5Display = true;
                                accountPricebookProdObj.invoiceDate5Qty = 0;
                            }
                            if(invoiceDateCount == 6){
                                accountPricebookProdObj.invoiceDate6Display = true;
                                accountPricebookProdObj.invoiceDate6Qty = 0;
                            }
                            invoiceDateCount++;
                        }
                    }
                }

                if(!accountProducts.isEmpty()){
                    accountProducts = OrderEntryUtility.priceInventoryDetails(accountObj[0].VIP_Account_Number__c, accountObj[0].VIP_Instance__c, orderInfo[0].Delivery_Date__c, accountProducts);
                    accountProducts = checkProductStatusAndTerritory(accountProducts, accountObj[0].Territories__c);
                }

                accountProductsReponseObj.accountARDetailsObj = OrderEntryUtility.getAccountARDetails(accountObj[0].VIP_Account_Number__c, accountObj[0].VIP_Instance__c, orderInfo[0].Delivery_Date__c, orderItemsReturned);

                accountProductsReponseObj.invoiceDates = invoiceProductDetailsObj.invoiceDates;
                accountProductsReponseObj.invoiceDateMap = invoiceProductDetailsObj.invoiceDateMap;
                accountProductsReponseObj.accountProducts = accountProducts;
                accountProductsReponseObj.pinnedProductMap = pinnedProductMap;

                if(!Test.isRunningTest()){
                    if(accountProductsReponseObj.accountARDetailsObj != null){
                        if(accountProductsReponseObj.accountARDetailsObj.apiResponseCode != '200'){
                            ErrorLog.insertErrorLog(accountProductsReponseObj.accountARDetailsObj.apiResponseCode, accountProductsReponseObj.accountARDetailsObj.apiResponseCode, 'OrderEntryController', 'accountARDetails');
                        }
                    }
                }
            }
            return accountProductsReponseObj;
        } catch(Exception ex) {
            ErrorLog.insertErrorLog(ex.getMessage(), String.valueOf(ex.getLineNumber()), 'OrderEntryController', 'getProductsForAccount');
            return null;
        }
    }

    @TestVisible
    private static List<AccountPricebookProducts> checkProductStatusAndTerritory(List<AccountPricebookProducts> accountProducts, String accountTerritories){
        List<AccountPricebookProducts> accountTerritoryReturnedProducts = new List<AccountPricebookProducts>();
        Set<String> productIdSet = new Set<String>();
        for(AccountPricebookProducts prodObj : accountProducts){
            productIdSet.add(prodObj.id);
        }
        Map<Id, Product2> productInfoMap = new Map<Id, Product2>(ProductDAO.getProductByIds(productIdSet));
        if(accountTerritories != null){
            List<String> accountTerr = accountTerritories.split(',');
            for(AccountPricebookProducts prodObj : accountProducts){
                if(productInfoMap.containsKey(prodObj.id)){
                    String inactiveHoverText = '';
                    if(productInfoMap.get(prodObj.id).Territories__c != null){
                        List<String> productTerritories = productInfoMap.get(prodObj.id).Territories__c.split(',');
                        Boolean terrMatch = false;
                        for(String productTerr : productTerritories){
                            if(accountTerr.contains(productTerr)){
                                terrMatch = true;
                            }
                        }
                        if(!terrMatch){
                            inactiveHoverText += Label.Text_Out_Of_Territory + ' ';
                        }
                    }
                    if(!productInfoMap.get(prodObj.id).isActive){
                        inactiveHoverText += Label.Text_Inactive_Product;
                    }
                    prodObj.hoverInactiveText = inactiveHoverText;
                }
            }
        }

        return accountProducts;
    }

    @AuraEnabled
    public static Id deleteOrder(String orderId){
        List<Order> orderInfo = OrderDAO.getOrderDetailsbyId(orderId);
        Id accountId = orderInfo[0].AccountId;
        Order orderToDelete = new Order();
        orderToDelete.Id = orderId;
        OrderDAO.deleteOrders(new List<Order>{orderToDelete});

        List<OrderItem> orderItemsToDelete = OrderItemDAO.getOrderItemByOrderId(orderId);
        if(!orderItemsToDelete.isEmpty()){
            OrderItemDAO.deleteOrderItems(orderItemsToDelete);
        }
        return accountId;
    }

    @TestVisible
    private static List<AccountPricebookProducts> getAccountPricebookProducts(Order orderInfo){
        List<AccountPricebookProducts> accountProducts = new List<AccountPricebookProducts>();
        List<AccountPricebookProducts> suggestedProducts = new List<AccountPricebookProducts>();
        List<AccountPricebookProducts> mandateProducts = new List<AccountPricebookProducts>();
        List<AccountPricebookProducts> defaultProducts = new List<AccountPricebookProducts>();
        List<AccountPricebookProducts> pinnedProducts = new List<AccountPricebookProducts>();
        List<AccountPricebookProducts> otherProducts = new List<AccountPricebookProducts>();
        List<OrderItem> orderItemsReturned = OrderItemDAO.getOrderItemByOrderId(orderInfo.Id);
        for(OrderItem orderItemObj : orderItemsReturned) {
            if(orderInfo.Status == 'Posted To VIP') {
                if(orderItemObj.Suggested__c) {
                    suggestedProducts.add(createAccountPricebookProduct(false,orderItemObj.Suggested__c, orderItemObj.Suggested_Icon__c, orderItemObj.Mandate__c, orderItemObj.Pinned__c, orderItemObj.Id, orderItemObj.OrderId,
                                                                orderItemObj.Product2Id, orderItemObj.Product2.Name, orderItemObj.Product2.Draft_Or_Package__c, orderItemObj.Product2.QuantityUnitOfMeasure, orderItemObj.Quantity_Order__c,
                                                                orderItemObj.Product2.Pkg_Name__c, orderItemObj.Inventory__c, orderItemObj.Product2.Cases_per_layer__c, orderItemObj.Product2.Cases_per_pallet__c,
                                                                orderItemObj.Product2.SKU_External_Id__c, false, false, 0.00, 0.00, 0.00, orderInfo.Status,
                                                                orderItemObj.Product2.Case_equivalent__c, null, null, null, null, orderItemObj.Product2.Sub_Style__c, orderItemObj.Product2.Seasonal__c, orderItemObj.Suggested_Sell_Story_Text__c));
                }
                if(orderItemObj.Mandate__c){
                    mandateProducts.add(createAccountPricebookProduct(false,orderItemObj.Suggested__c, orderItemObj.Suggested_Icon__c, orderItemObj.Mandate__c, orderItemObj.Pinned__c, orderItemObj.Id, orderItemObj.OrderId,
                                                                orderItemObj.Product2Id, orderItemObj.Product2.Name, orderItemObj.Product2.Draft_Or_Package__c, orderItemObj.Product2.QuantityUnitOfMeasure, orderItemObj.Quantity_Order__c,
                                                                orderItemObj.Product2.Pkg_Name__c, orderItemObj.Inventory__c, orderItemObj.Product2.Cases_per_layer__c, orderItemObj.Product2.Cases_per_pallet__c,
                                                                orderItemObj.Product2.SKU_External_Id__c, false, false, 0.00, 0.00, 0.00, orderInfo.Status,
                                                                orderItemObj.Product2.Case_equivalent__c, null, null, null, null, orderItemObj.Product2.Sub_Style__c, orderItemObj.Product2.Seasonal__c, orderItemObj.Suggested_Sell_Story_Text__c));
                }
                if(orderItemObj.Invoice__c){
                    defaultProducts.add(createAccountPricebookProduct(orderItemObj.Invoice__c,orderItemObj.Suggested__c, orderItemObj.Suggested_Icon__c, orderItemObj.Mandate__c, orderItemObj.Pinned__c, orderItemObj.Id, orderItemObj.OrderId,
                                                                orderItemObj.Product2Id, orderItemObj.Product2.Name, orderItemObj.Product2.Draft_Or_Package__c, orderItemObj.Product2.QuantityUnitOfMeasure, orderItemObj.Quantity_Order__c,
                                                                orderItemObj.Product2.Pkg_Name__c, orderItemObj.Inventory__c, orderItemObj.Product2.Cases_per_layer__c, orderItemObj.Product2.Cases_per_pallet__c,
                                                                orderItemObj.Product2.SKU_External_Id__c, false, false, 0.00, 0.00, 0.00, orderInfo.Status,
                                                                orderItemObj.Product2.Case_equivalent__c, null, null, null, null, orderItemObj.Product2.Sub_Style__c, orderItemObj.Product2.Seasonal__c, orderItemObj.Suggested_Sell_Story_Text__c));
                }
                if(orderItemObj.Pinned__c){
                    pinnedProducts.add(createAccountPricebookProduct(orderItemObj.Invoice__c,orderItemObj.Suggested__c, orderItemObj.Suggested_Icon__c, orderItemObj.Mandate__c, orderItemObj.Pinned__c, orderItemObj.Id, orderItemObj.OrderId,
                                                                orderItemObj.Product2Id, orderItemObj.Product2.Name, orderItemObj.Product2.Draft_Or_Package__c, orderItemObj.Product2.QuantityUnitOfMeasure, orderItemObj.Quantity_Order__c,
                                                                orderItemObj.Product2.Pkg_Name__c, orderItemObj.Inventory__c, orderItemObj.Product2.Cases_per_layer__c, orderItemObj.Product2.Cases_per_pallet__c,
                                                                orderItemObj.Product2.SKU_External_Id__c, false, false, 0.00, 0.00, 0.00, orderInfo.Status,
                                                                orderItemObj.Product2.Case_equivalent__c, orderItemObj.Pinned_Notes__c, orderItemObj.Expiration_Date__c,orderItemObj.Feedback__c, orderItemObj.CreatedBy.Name, orderItemObj.Product2.Sub_Style__c, orderItemObj.Product2.Seasonal__c, orderItemObj.Suggested_Sell_Story_Text__c));
                }
                if(!orderItemObj.Suggested__c && !orderItemObj.Mandate__c && !orderItemObj.Invoice__c && !orderItemObj.Pinned__c){
                    otherProducts.add(createAccountPricebookProduct(orderItemObj.Invoice__c, orderItemObj.Suggested__c, orderItemObj.Suggested_Icon__c, orderItemObj.Mandate__c, orderItemObj.Pinned__c, orderItemObj.Id, orderItemObj.OrderId,
                                                                orderItemObj.Product2Id, orderItemObj.Product2.Name, orderItemObj.Product2.Draft_Or_Package__c, orderItemObj.Product2.QuantityUnitOfMeasure, orderItemObj.Quantity_Order__c,
                                                                orderItemObj.Product2.Pkg_Name__c, orderItemObj.Inventory__c, orderItemObj.Product2.Cases_per_layer__c, orderItemObj.Product2.Cases_per_pallet__c,
                                                                orderItemObj.Product2.SKU_External_Id__c, false, false, 0.00, 0.00, 0.00, orderInfo.Status,
                                                                orderItemObj.Product2.Case_equivalent__c, null, null, null, null, orderItemObj.Product2.Sub_Style__c, orderItemObj.Product2.Seasonal__c, orderItemObj.Suggested_Sell_Story_Text__c));
                }
            } else {
                otherProducts.add(createAccountPricebookProduct(orderItemObj.Invoice__c, orderItemObj.Suggested__c, orderItemObj.Suggested_Icon__c, orderItemObj.Mandate__c, orderItemObj.Pinned__c, orderItemObj.Id, orderItemObj.OrderId,
                                                                orderItemObj.Product2Id, orderItemObj.Product2.Name, orderItemObj.Product2.Draft_Or_Package__c, orderItemObj.Product2.QuantityUnitOfMeasure, orderItemObj.Quantity_Order__c,
                                                                orderItemObj.Product2.Pkg_Name__c, orderItemObj.Inventory__c, orderItemObj.Product2.Cases_per_layer__c, orderItemObj.Product2.Cases_per_pallet__c,
                                                                orderItemObj.Product2.SKU_External_Id__c, false, false, 0.00, 0.00, 0.00, orderInfo.Status,
                                                                orderItemObj.Product2.Case_equivalent__c, orderItemObj.Pinned_Notes__c, orderItemObj.Expiration_Date__c, orderItemObj.Feedback__c, orderItemObj.CreatedBy.Name, orderItemObj.Product2.Sub_Style__c, orderItemObj.Product2.Seasonal__c, orderItemObj.Suggested_Sell_Story_Text__c));
            }
        }
        suggestedProducts.sort();
        mandateProducts.sort();
        defaultProducts.sort();
        otherProducts.addALL(defaultProducts);
        otherProducts.addALL(pinnedProducts);
        otherProducts.sort();

        accountProducts.addAll(suggestedProducts);
        accountProducts.addAll(mandateProducts);
        accountProducts.addAll(otherProducts);

        return accountProducts;
    }

    public static PriceBookEntry updatePriceBookEntry(String priceBookEntryId, String notes, Date expirationDate){
        PriceBookEntry newPinnedProduct = new PriceBookEntry();
        newPinnedProduct.Id = priceBookEntryId;
        newPinnedProduct.Pinned_Notes__c = notes;
        newPinnedProduct.Expiration_Date__c = expirationDate;
        newPinnedProduct.IsHidden__c = false;
        PriceBookEntryDAO.updatePriceBookEntries(new List<PriceBookEntry>{newPinnedProduct});
        return newPinnedProduct;
    }
    
    @AuraEnabled
    public static List<AccountPricebookProducts> getPricingDetailForProduct(String orderId, String accountPricebookObject) {        
        List<Order> orderObjReturned = OrderDAO.getOrderDetailsbyId(orderId);
        List<Account> accountObj = AccountDAO.getAccountsByIds(new Set<Id>{orderObjReturned[0].AccountId});        
        AccountPricebookProducts accountPricebookProductObj = (AccountPricebookProducts)JSON.deserialize(accountPricebookObject, AccountPricebookProducts.class);
        return OrderEntryUtility.priceInventoryDetails(accountObj[0].VIP_Account_Number__c, accountObj[0].VIP_Instance__c, orderObjReturned[0].Delivery_Date__c, new List<AccountPricebookProducts>{accountPricebookProductObj});
    }

    @AuraEnabled
    public static List<AccountPricebookProducts> getPinnedProducts(String orderId){
        List<AccountPricebookProducts> accountProducts = new List<AccountPricebookProducts>();
        List<Order> orderInfo = OrderDAO.getOrderDetailsbyId(orderId);
        List<Product_Feedback__c> existingPinnedProducts = ProductFeedbackDAO.getPinnedProductsByAccountandExpirationDate(orderInfo[0].AccountId, System.today());
        if(!existingPinnedProducts.isEmpty()){
            List<OrderItem> orderItemsReturned = OrderItemDAO.getOrderItemByOrderId(orderId);
            Set<String> existingOrderItemSet = new Set<String>();
            for(OrderItem orderItemObj : orderItemsReturned){
                if(orderItemObj.Pinned__c) {
                    existingOrderItemSet.add(orderItemObj.Product2Id);
                    accountProducts.add(createAccountPricebookProduct(orderItemObj.Invoice__c,orderItemObj.Suggested__c, orderItemObj.Suggested_Icon__c, orderItemObj.Mandate__c, orderItemObj.Pinned__c, orderItemObj.Id, orderItemObj.OrderId,
                                                                orderItemObj.Product2Id, orderItemObj.Product2.Name, orderItemObj.Product2.Draft_Or_Package__c, orderItemObj.Product2.QuantityUnitOfMeasure, orderItemObj.Quantity_Order__c,
                                                                orderItemObj.Product2.Pkg_Name__c, orderItemObj.Inventory__c, orderItemObj.Product2.Cases_per_layer__c, orderItemObj.Product2.Cases_per_pallet__c,
                                                                orderItemObj.Product2.SKU_External_Id__c, false, false, 0.00, 0.00, 0.00, null,
                                                                orderItemObj.Product2.Case_equivalent__c, orderItemObj.Pinned_Notes__c, orderItemObj.Expiration_Date__c, orderItemObj.Feedback__c, orderItemObj.CreatedBy.Name,
                                                                orderItemObj.Product2.Sub_Style__c, orderItemObj.Product2.Seasonal__c,orderItemObj.Suggested_Sell_Story_Text__c));
                }
            }

            for(Product_Feedback__c pinnedProduct : existingPinnedProducts) {    
                if(!existingOrderItemSet.contains(pinnedProduct.Product__r.Id)) {
                    accountProducts.add(createAccountPricebookProduct(false, false, false, false, true, null, orderId, pinnedProduct.Product__r.Id, pinnedProduct.Product__r.Name, pinnedProduct.Product__r.Draft_Or_Package__c, pinnedProduct.Product__r.QuantityUnitOfMeasure, 0,
                                    pinnedProduct.Product__r.Pkg_Name__c, 0, pinnedProduct.Product__r.Cases_per_layer__c, pinnedProduct.Product__r.Cases_per_pallet__c, pinnedProduct.Product__r.SKU_External_Id__c, false, true, 
                                    0.00, 0.00, 0.00, null, pinnedProduct.Product__r.Case_equivalent__c, pinnedProduct.Notes__c, pinnedProduct.Expiration_Date__c, pinnedProduct.Feedback__c, 
                                    pinnedProduct.CreatedBy.Name, pinnedProduct.Product__r.Sub_Style__c, pinnedProduct.Product__r.Seasonal__c, null));
                }
            }
        }
        return accountProducts;
    }

    @AuraEnabled
    public static InvoiceProductDetails getDefaultProducts(Order orderInfo, Account accountObj){
        InvoiceProductDetails invoiceProductDetailsObj = new InvoiceProductDetails();
        List<AccountPricebookProducts> accountProducts = new List<AccountPricebookProducts>();
        String deliveryFrequency = accountObj.Delivery_Frequency_Type__c;
        List<Order> orderInvoices = new List<Order>();
        Id invoiceOrderRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Invoice').getRecordTypeId();
        Reyes_Org_Setting__c reyesOrgCustomSetting = Reyes_Org_Setting__c.getInstance();
        Integer minNumOfOrders = Integer.valueOf(reyesOrgCustomSetting.Min_Order_History_Qty__c);
        if(deliveryFrequency == 'Weekly'){
            orderInvoices = OrderDAO.getInvoiceOrderDetailsbyAccount(new Set<Id>{orderInfo.AccountId}, minNumOfOrders, invoiceOrderRecordTypeId);
        } else {
            Date invoiceDateLimit = System.today().addDays(-Integer.valueOf(reyesOrgCustomSetting.Min_Order_history_days__c));
            orderInvoices = OrderDAO.getInvoiceOrderDetailsbyAccountDateRange(new Set<Id>{orderInfo.AccountId}, minNumOfOrders, invoiceDateLimit, invoiceOrderRecordTypeId);
        }

        List<Call_Scheduling_Frequency__mdt> callScheduleFrequency = CallSchedulingFrequencyDAO.getCallSchedlingFrequency();
        Map<String, Call_Scheduling_Frequency__mdt> callScheduleFrequencyMap = new Map<String, Call_Scheduling_Frequency__mdt>();
        for(Call_Scheduling_Frequency__mdt callSchedule : callScheduleFrequency){
            callScheduleFrequencyMap.put(callSchedule.MasterLabel, callSchedule);
        }

        String frequencyCategory;
        List<Flagged_Product_Frequency__mdt> flaggedProductFrequency = new List<Flagged_Product_Frequency__mdt>();
        if(deliveryFrequency != null){
            if(callScheduleFrequencyMap.containsKey(deliveryFrequency)){
                frequencyCategory = callScheduleFrequencyMap.get(deliveryFrequency).Frequency_Category__c;
                flaggedProductFrequency = FlaggedProductFrequencyDAO.getFlaggedProductFrequencyByCategory(frequencyCategory);
            }
        }

        Set<Id> orderInvoiceIds = new Set<Id>();
        for(Order orderInvoiceObj : orderInvoices){
            orderInvoiceIds.add(orderInvoiceObj.Id);
        }

        List<OrderItem> orderInvoiceLineItems = OrderItemDAO.getOrderItemsByInvoice(orderInvoiceIds, false);
        Set<String> productExternalIds = new Set<String>();
        for(OrderItem orderItemObj : orderInvoiceLineItems){
            productExternalIds.add(orderItemObj.Product2.SKU_External_Id__c);
        }

        List<Product2> defaultProductsList = ProductDAO.getProductByExternalIds(productExternalIds);
        Map<String, Product2> defaultProductDetailsMap = new Map<String, Product2>();
        for(Product2 prodObj : defaultProductsList){
            defaultProductDetailsMap.put(prodObj.SKU_External_Id__c, prodObj);
        }

        List<String> invoiceDates = new List<String>();
        Map<String, List<InvoiceProductDateDetails>> invoiceDateMap = new Map<String, List<InvoiceProductDateDetails>>();
        Map<String, List<String>> dateProductInvoiceMap = new Map<String, List<String>>();

        List<OrderItem> orderItemsReturned = OrderItemDAO.getOrderItemByOrderId(orderInfo.Id);
        Set<String> existingOrderItemSet = new Set<String>();
        for(OrderItem orderItemObj : orderItemsReturned){
            existingOrderItemSet.add(orderItemObj.Product2.SKU_External_Id__c);
            if(orderItemObj.Invoice__c){
                accountProducts.add(createAccountPricebookProduct(true, orderItemObj.Suggested__c, orderItemObj.Suggested_Icon__c, orderItemObj.Mandate__c, false, orderItemObj.Id, orderItemObj.OrderId,
                                                            orderItemObj.Product2Id, orderItemObj.Product2.Name, orderItemObj.Product2.Draft_Or_Package__c, orderItemObj.Product2.QuantityUnitOfMeasure, orderItemObj.Quantity_Order__c,
                                                            orderItemObj.Product2.Pkg_Name__c, orderItemObj.Inventory__c, orderItemObj.Product2.Cases_per_layer__c, orderItemObj.Product2.Cases_per_pallet__c,
                                                            orderItemObj.Product2.SKU_External_Id__c, false, false, 0.00, 0.00, 0.00, null,
                                                            orderItemObj.Product2.Case_equivalent__c, null, null, null, null, orderItemObj.Product2.Sub_Style__c, orderItemObj.Product2.Seasonal__c, orderItemObj.Suggested_Sell_Story_Text__c));
            }
        }

        Set<String> prodExternalIds = new Set<String>();
        Map<String, Date> prodDateMap = new Map<String, Date>();
        for(OrderItem orderItemObj : orderInvoiceLineItems){
            List<InvoiceProductDateDetails> invoiceProductDateList = new List<InvoiceProductDateDetails>();
            if(invoiceDateMap.containsKey(defaultProductDetailsMap.get(orderItemObj.Product2.SKU_External_Id__c).Id)){
                invoiceProductDateList = invoiceDateMap.get(defaultProductDetailsMap.get(orderItemObj.Product2.SKU_External_Id__c).Id);
            }
            Boolean invoiceDateExists = false;
            for(InvoiceProductDateDetails invoiceProductObj : invoiceProductDateList){
                if(invoiceProductObj.invoiceDate == orderItemObj.Order.Invoice_Date__c){
                    invoiceDateExists = true;
                }
            }
            if(!invoiceDateExists){
                InvoiceProductDateDetails invoiceProductDateDetailsObj = new InvoiceProductDateDetails();
                invoiceProductDateDetailsObj.invoiceDate = orderItemObj.Order.Invoice_Date__c;
                invoiceProductDateDetailsObj.invoiceDateString = orderItemObj.Order.Invoice_Date__c.month() + '/' + orderItemObj.Order.Invoice_Date__c.day();
                invoiceProductDateDetailsObj.qtyOrdered = orderItemObj.Quantity_Order__c;
                invoiceProductDateDetailsObj.priceBookEntryId = orderItemObj.Id;
                invoiceProductDateList.add(invoiceProductDateDetailsObj);
            }
            invoiceDateMap.put(defaultProductDetailsMap.get(orderItemObj.Product2.SKU_External_Id__c).Id, invoiceProductDateList);

            if(!invoiceDates.contains(orderItemObj.Order.Invoice_Date__c.month() + '/' + orderItemObj.Order.Invoice_Date__c.day())){
                invoiceDates.add(orderItemObj.Order.Invoice_Date__c.month() + '/' + orderItemObj.Order.Invoice_Date__c.day());
            }

            prodDateMap.put(orderItemObj.Order.Invoice_Date__c.month() + '/' + orderItemObj.Order.Invoice_Date__c.day(), orderItemObj.Order.Invoice_Date__c);
            prodExternalIds.add(orderItemObj.Product2.SKU_External_Id__c);
        }

        for(String externalId : prodExternalIds){
            if(!existingOrderItemSet.contains(externalId)){
                accountProducts.add(createAccountPricebookProduct(true, false, false, false, false, null, orderInfo.Id, defaultProductDetailsMap.get(externalId).Id, defaultProductDetailsMap.get(externalId).Name, defaultProductDetailsMap.get(externalId).Draft_Or_Package__c, defaultProductDetailsMap.get(externalId).QuantityUnitOfMeasure, 0,
                                                                    defaultProductDetailsMap.get(externalId).Pkg_Name__c, 0, defaultProductDetailsMap.get(externalId).Cases_per_layer__c, defaultProductDetailsMap.get(externalId).Cases_per_pallet__c,
                                                                    defaultProductDetailsMap.get(externalId).SKU_External_Id__c, false, true, 0.00, 0.00, 0.00, null,
                                                                    defaultProductDetailsMap.get(externalId).Case_equivalent__c, null, null, null, null, defaultProductDetailsMap.get(externalId).Sub_Style__c, defaultProductDetailsMap.get(externalId).Seasonal__c, null));
            }
        }
        accountProducts.sort();

        for(String prodId : invoiceDateMap.keySet()){
            List<InvoiceProductDateDetails> tempProductDateList = invoiceDateMap.get(prodId);
            List<String> prodDates = new List<String>();
            for(InvoiceProductDateDetails invoiceProdDateObj : tempProductDateList){
                prodDates.add(invoiceProdDateObj.invoiceDateString);
            }
            for(String day : invoiceDates){
                if(!prodDates.contains(day)){
                    InvoiceProductDateDetails invoiceProductDateDetailsObj = new InvoiceProductDateDetails();
                    if(prodDateMap.containsKey(day)){
                        invoiceProductDateDetailsObj.invoiceDate = prodDateMap.get(day);
                    }
                    invoiceProductDateDetailsObj.invoiceDateString = day;
                    invoiceProductDateDetailsObj.qtyOrdered = 0;
                    tempProductDateList.add(invoiceProductDateDetailsObj);
                }
            }
            tempProductDateList.sort();
            invoiceDateMap.put(prodId, tempProductDateList);
        }

        invoiceProductDetailsObj.accountProducts = accountProducts;
        invoiceProductDetailsObj.invoiceDates = invoiceDates;
        invoiceProductDetailsObj.invoiceDateMap = invoiceDateMap;
        if(!flaggedProductFrequency.isEmpty()){
            invoiceProductDetailsObj.flaggedProductFrequency = flaggedProductFrequency[0];
        }
        return invoiceProductDetailsObj;
    }

    @AuraEnabled
    public static List<OrderItem> updateDefaultProductToHidden(List<String> prodIds, String orderId){
        List<Order> orderInfo = OrderDAO.getOrderDetailsbyId(orderId);
        List<Account> accountObj = AccountDAO.getAccountsByIds(new Set<Id>{orderInfo[0].AccountId});
        String deliveryFrequency = accountObj[0].Delivery_Frequency_Type__c;
        List<Order> orderInvoices = new List<Order>();
        Id invoiceOrderRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Invoice').getRecordTypeId();
        Reyes_Org_Setting__c reyesOrgCustomSetting = Reyes_Org_Setting__c.getInstance();
        Integer minNumOfOrders = Integer.valueOf(reyesOrgCustomSetting.Min_Order_History_Qty__c);
        if(deliveryFrequency == 'Weekly'){
            orderInvoices = OrderDAO.getInvoiceOrderDetailsbyAccount(new Set<Id>{orderInfo[0].AccountId}, minNumOfOrders, invoiceOrderRecordTypeId);
        } else {
            Date invoiceDateLimit = System.today().addDays(-Integer.valueOf(reyesOrgCustomSetting.Min_Order_history_days__c));
            orderInvoices = OrderDAO.getInvoiceOrderDetailsbyAccountDateRange(new Set<Id>{orderInfo[0].AccountId}, minNumOfOrders, invoiceDateLimit, invoiceOrderRecordTypeId);
        }

        Set<Id> orderInvoiceIds = new Set<Id>();
        for(Order orderInvoiceObj : orderInvoices){
            orderInvoiceIds.add(orderInvoiceObj.Id);
        }

        List<OrderItem> orderInvoiceLineItems = OrderItemDAO.getOrderItemsByInvoice(orderInvoiceIds, false);
        List<OrderItem> orderItemsToUpdate = new List<OrderItem>();
        for(OrderItem orderLineItemObj : orderInvoiceLineItems){
            if(prodIds.contains(orderLineItemObj.Product2id)){
                OrderItem tempOrderItemObj = new OrderItem();
                tempOrderItemObj.Id = orderLineItemObj.Id;
                tempOrderItemObj.IsHidden__c = true;
                orderItemsToUpdate.add(tempOrderItemObj);
            }
        }

        if(!orderItemsToUpdate.isEmpty()){
            OrderItemDAO.updateOrderItems(orderItemsToUpdate);
        }
        return orderItemsToUpdate;
    }

    public static AccountPricebookProducts createAccountPricebookProduct(Boolean invoiceProd, Boolean suggested, Boolean suggestedIcon, Boolean mandate, Boolean pinned, String orderItemId, String orderId,
                                                                        String productId, String productName, String pkgType, String quantityUOM, Decimal qty, String pkg, Decimal qtyAvail,
                                                                        Decimal layer, Decimal pallet, String itemNum, Boolean newProd, Boolean defaultProd, Decimal unitPrice, Decimal unitDiscount,
                                                                        Decimal exPrice, String status, Decimal caseEquiv, String pinnedNotes, Date expirationDate, String feedback, String createdBy, 
                                                                        String subStyle, String seasonal, String storyText) {
		AccountPricebookProducts accountPriceProdObj = new AccountPricebookProducts();
        if(suggested){
            if(suggestedIcon){
                accountPriceProdObj.iconName = 'utility:favorite';
                accountPriceProdObj.iconAltText = 'Suggested';
            } else {
                accountPriceProdObj.iconName = 'utility:trending';
                accountPriceProdObj.iconAltText = 'Hot In The Area';
            }
            accountPriceProdObj.iconClass = 'suggested';
            accountPriceProdObj.iconDesc = 'Suggested Item';
            accountPriceProdObj.showRecordIcon = true;
        }
        if(mandate){
            accountPriceProdObj.iconName = 'utility:clock';
            accountPriceProdObj.iconAltText = 'Mandate Gap';
            accountPriceProdObj.iconDesc = 'Mandate/Core Product Gap';
            accountPriceProdObj.iconClass = 'mandate';
            accountPriceProdObj.showRecordIcon = true;
        }
        if(invoiceProd){
            accountPriceProdObj.iconAltText = 'Invoice';
            accountPriceProdObj.iconClass = 'invoice';
        }
        if(pinned){
            accountPriceProdObj.iconAltText = 'Pinned';
            accountPriceProdObj.iconClass = 'pinned';
        }
        accountPriceProdObj.orderItemId = orderItemId;
        accountPriceProdObj.orderId = orderId;
        accountPriceProdObj.id = productId;
        accountPriceProdObj.orderStatus = status;
        accountPriceProdObj.name = productName;
        accountPriceProdObj.pkgType = pkgType;   //Draft_Or_Package__c from Product2
        accountPriceProdObj.quantityUOM = quantityUOM;	//QuantityUnitOfMeasure from Product2
		if (quantityUOM == 'HK' || quantityUOM == 'QK') {
			accountPriceProdObj.isKeg = true;
			accountPriceProdObj.isCase = false;
            accountPriceProdObj.isBottle = false;
        } else if (quantityUOM == 'CB' || quantityUOM == 'CW' || quantityUOM == 'CS') {
            accountPriceProdObj.isCase = true;
            accountPriceProdObj.isKeg = false;
            accountPriceProdObj.isBottle = false;
        } else if (quantityUOM == 'BW') {
            accountPriceProdObj.isBottle = true;
            accountPriceProdObj.isKeg = false;
            accountPriceProdObj.isCase = false;
        }
        accountPriceProdObj.qty = qty;
        if(orderItemId != null){
            accountPriceProdObj.origQty = qty;
        }
        accountPriceProdObj.pkg = pkg;   //Pkg_Name__c from Product2
        accountPriceProdObj.qtyAvail = qtyAvail;
        accountPriceProdObj.layer = layer;   //Cases_per_layer__c from Product2
        accountPriceProdObj.pallet = pallet;
        accountPriceProdObj.caseEquiv = caseEquiv;
        accountPriceProdObj.item = itemNum;
        accountPriceProdObj.newProd = newProd;
        accountPriceProdObj.defaultProd = defaultProd;
        accountPriceProdObj.invoiceProd = invoiceProd;
        accountPriceProdObj.pinnedProd = pinned;
        if(qtyAvail > 0){
            accountPriceProdObj.stock = true;
        } else {
            accountPriceProdObj.stock = false;
        }
        if(qty > qtyAvail){
            accountPriceProdObj.showInvRedText = true;
        } else {
            accountPriceProdObj.showInvRedText = false;
        }
        accountPriceProdObj.casePrice = unitPrice;
        accountPriceProdObj.unitPrice = unitPrice;
        accountPriceProdObj.unitDiscount = unitDiscount;
        accountPriceProdObj.exPrice = exPrice;
        accountPriceProdObj.pinnedNotes = pinnedNotes;
        accountPriceProdObj.expirationDate = expirationDate;
        accountPriceProdObj.feedback = feedback;
        accountPriceProdObj.createdBy = createdBy;
        String subStyleSeasonal = '';
        if(subStyle != null){
            subStyleSeasonal += subStyle;
        }
        if(seasonal != null){
            subStyleSeasonal += ' ' + seasonal;
        }
        accountPriceProdObj.hoverText = subStyleSeasonal;

        //BSSP-1046 suggested sell story text
        accountPriceProdObj.suggestedSellStoryText = storyText;

        return accountPriceProdObj;
    }

    @AuraEnabled
    public static List<AccountPricebookProducts> getSuggestedSellAndMandateProducts(Order orderInfo, Account accountObj){
        List<AccountPricebookProducts> accountProducts = new List<AccountPricebookProducts>();
        List<AccountPricebookProducts> mandateProducts = new List<AccountPricebookProducts>();

        // Pradeep per funnel project only fetching priority list for controllable accounts & no longer fetching suggested sell information

        if(orderInfo.Status != 'Posted To VIP' ){
         if( accountObj.VIP_Instance__c != null 
                && accountObj.VIP_Account_Number__c != null && accountObj.Controllable__c == 'Controllable'){
            if(accountObj.Chain_Independent__c == 'Independent'){
                //TODO: Pradeep currently uses externailID value but for priority list we are using VIP_Instance__c 
                //replacing externalId with VIP_Instance__c
                if(accountObj.ExternalId__c != null){
                     //make a call with new priorityList API
            
                    String param1= accountObj.ExternalId__c +'/priority-product';
                    HttpResponse priorityListResponse = MulesoftUtility.mulesoftCallout('priorityList', param1, accountObj.VIP_Account_Number__c.leftPad(5, '0'), null, null);
                   
                    if (priorityListResponse.getStatusCode() == 200) {
                        accountProducts.addAll(OrderEntryUtility.handlePriorityListData(priorityListResponse, accountObj.Id, orderInfo.Id));
                     }
                   /* HttpResponse suggestedSellResponse = MulesoftUtility.mulesoftCallout('Suggested Sell', accountObj.ExternalId__c, null, null, null);
                    if (suggestedSellResponse.getStatusCode() == 200) {
                       accountProducts.addAll(OrderEntryUtility.handleSuggestedSellData(suggestedSellResponse, accountObj.Id, orderInfo.Id));
                    }*/
                }
            }
        }else if(accountObj.VIP_Instance__c != null && accountObj.VIP_Account_Number__c != null && accountObj.Controllable__c != 'Controllable'){
                HttpResponse mandateResponse = MulesoftUtility.mulesoftCallout('Mandates', accountObj.VIP_Instance__c, accountObj.VIP_Account_Number__c.leftPad(5, '0'), null, null);
                if (mandateResponse.getStatusCode() == 200) {
                    mandateProducts.addAll(OrderEntryUtility.handleMandateData(mandateResponse, orderInfo.Id, accountObj.Territories__c));
                }
                accountProducts.addAll(mandateProducts);
            }
        }
        //accountProducts.addAll(mandateProducts);

        return accountProducts;
    }

 	@AuraEnabled
    public static List<Product2> getProductSearchResults(String searchKey, String recordId) {
        List<Product2> productsForTerritory = new List<Product2>();
        List<Product2> productList = Database.query('SELECT Id, Name, Price__c, Territories__c, Pkg_Name__c, QuantityUnitOfMeasure, Cases_per_layer__c, Cases_per_pallet__c, Case_equivalent__c, SKU_External_Id__c, SKU_Package_Type__c FROM Product2 WHERE (Name LIKE' + ' \'%'+String.escapeSingleQuotes(searchKey)+'%\'' + ' OR SKU_Package_Type__c LIKE' + ' \'%'+String.escapeSingleQuotes(searchKey)+'%\'' + ' OR SKU_External_Id__c = ' + '\'' + String.escapeSingleQuotes(searchKey) +'\'' + ' OR Seasonal__c = ' + '\'' + String.escapeSingleQuotes(searchKey) +'\'' + ' OR Sub_Style__c = ' + '\'' + String.escapeSingleQuotes(searchKey) + '\'' +') ' + 'AND RecordType.Name = \'SKU\' AND IsActive=true ORDER BY Name');
        List<Order> orderObj = OrderDAO.getOrderDetailsbyId(recordId);
        Id accountId;
        if (!orderObj.isEmpty()) {
            accountId = orderObj[0].AccountId;
        } else {
            accountId = recordId;
        }
        List<Account> accountObj = AccountDAO.getAccountsByIds(new Set<Id>{accountId});
        if (accountObj[0].Territories__c != null) {
            List<String> accountTerr = accountObj[0].Territories__c.split(',');
            for (Product2 prodObj : productList) {
                if (prodObj.Territories__c != null) {
                    List<String> productTerritories = prodObj.Territories__c.split(',');
                    for (String productTerr : productTerritories) {
                        if (accountTerr.contains(productTerr)) {
                            productsForTerritory.add(prodObj);
                            break;
                        }
                    }
                }
            }
        }
        return productsForTerritory;
    }
    
    @AuraEnabled
    public static List<OrderItem> deleteOrderItem(List<String> orderItemIds){
        List<OrderItem> orderItemsToDelete = new List<OrderItem>();
        for(String orderItemId : orderItemIds){
        OrderItem tempOrderItem = new OrderItem();
        tempOrderItem.Id = orderItemId;
        orderItemsToDelete.add(tempOrderItem);
        }

        if(!orderItemsToDelete.isEmpty()){
            OrderItemDAO.deleteOrderItems(orderItemsToDelete);
        }
        return orderItemsToDelete;
    }

    @AuraEnabled
    public static List<OrderItem> insertUpdateOrderItemRecords(String orderId, String productsToUpdateInsert, List<String> productIds) {
        try {
            List<Order> orderObj = OrderDAO.getOrderDetailsbyId(orderId);
            List<Account> accountObj = AccountDAO.getAccountsByIds(new Set<Id>{orderObj[0].AccountId});
            String deliveryFrequency = accountObj[0].Delivery_Frequency_Type__c;
            List<Order> orderInvoices = new List<Order>();
            Id invoiceOrderRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Invoice').getRecordTypeId();
            Reyes_Org_Setting__c reyesOrgCustomSetting = Reyes_Org_Setting__c.getInstance();
            Integer minNumOfOrders = Integer.valueOf(reyesOrgCustomSetting.Min_Order_History_Qty__c);
            if (deliveryFrequency == 'Weekly') {
                orderInvoices = OrderDAO.getInvoiceOrderDetailsbyAccount(new Set<Id>{orderObj[0].AccountId}, minNumOfOrders, invoiceOrderRecordTypeId);
            } else {
                Date invoiceDateLimit = System.today().addDays(-Integer.valueOf(reyesOrgCustomSetting.Min_Order_history_days__c));
                orderInvoices = OrderDAO.getInvoiceOrderDetailsbyAccountDateRange(new Set<Id>{orderObj[0].AccountId}, minNumOfOrders, invoiceDateLimit, invoiceOrderRecordTypeId);
            }

            Set<Id> orderInvoiceIds = new Set<Id>();
            for (Order orderInvoiceObj : orderInvoices) {
                orderInvoiceIds.add(orderInvoiceObj.Id);
            }

            List<OrderItem> orderInvoiceLineItems = OrderItemDAO.getOrderItemsByInvoice(orderInvoiceIds, true);
            Map<Id, OrderItem> orderItemInvoiceMap = new Map<Id, OrderItem>();
            for (OrderItem orderItemInvoiceObj : orderInvoiceLineItems) {
                orderItemInvoiceMap.put(orderItemInvoiceObj.Product2Id, orderItemInvoiceObj);
            }
            
            List<AccountPricebookProducts> accountPricebookProductsListToInsertUpdate = (List<AccountPricebookProducts>)JSON.deserialize(productsToUpdateInsert, List<AccountPricebookProducts>.class);
            Set<String> productIdSet = new Set<String>(productIds);            
            Map<Id, Product2> productInfoMap = new Map<Id, Product2>(ProductDAO.getProductByIds(productIdSet));
            
            //Add the matching CW products for any BW products to the product Map
            Set<String> addProducts = new Set<String>();
            //Iterate through the map 
            for (Id key : productInfoMap.keySet()) {
    			Product2 prod = productInfoMap.get(key);
                if (prod.SKU_External_Id__c.contains('BW')) {
                    addProducts.add(prod.SKU_External_Id__c.replace('BW','CW'));
                }
            }            
            if (addProducts.size() > 0) {
                List<Product2> addProductList = ProductDAO.getProductByExternalIds(addProducts);
                for (Product2 addProduct : addProductList) {
                    productInfoMap.put(addProduct.Id, addProduct);
                }
                
            }          
            
            List<OrderItem> orderItemsToUpsert = new List<OrderItem>();
            List<OrderItem> orderItemsToDelete = new List<OrderItem>();
            List<OrderItem> orderItemInvoicesToUpdate = new List<OrderItem>();
            List<AccountPricebookProducts> pinnedProducts = getPinnedProducts(orderId);
            Map<Id, AccountPricebookProducts> pinnedProductMap = new Map<Id, AccountPricebookProducts>();
            for (AccountPricebookProducts pinnedProductObj : pinnedProducts) {
                pinnedProductMap.put(pinnedProductObj.id, pinnedProductObj);
            }
            //Create a map of existing line items
            Set<String> existingLineItems = new Set<String>();
            for (AccountPricebookProducts existingLineItem : accountPricebookProductsListToInsertUpdate) {
                existingLineItems.add(existingLineItem.item);
            }
            
			//Check if there are Bottles (BW products) that have a quantity that should be converted to cases
            List<AccountPriceBookProducts> tempAddPriceBookProductsList = new List<AccountPriceBookProducts>();
            Map<String, Integer> updateQuantityMap = new Map<String, Integer>();
            for (AccountPricebookProducts accountPricebookObj : accountPricebookProductsListToInsertUpdate) {
                //If the quantity of the BW item is greater than the units per case
                if (accountPricebookObj.item.contains('BW') && Integer.valueOf(accountPricebookObj.qty) >= productInfoMap.get(accountPricebookObj.id).Units_per_Case__c) {
                   	Integer numberOfCases = Integer.valueOf(accountPricebookObj.qty / Integer.valueOf(productInfoMap.get(accountPricebookObj.id).Units_per_Case__c));
                    //Reset the Quantity of the BW Item to the Remainder of Bottles
                    accountPricebookObj.qty = math.mod(Integer.valueOf(accountPricebookObj.qty), Integer.valueOf(productInfoMap.get(accountPricebookObj.id).Units_per_Case__c));
                    //See if the Matching CW has already been added to the Order
                    if (!existingLineItems.contains(accountPricebookObj.item.replace('BW','CW'))) {
                    	//Add the Matching CW Item and update the Id, OrderId and Quantity
                    	List<AccountPriceBookProducts> tempAddPricebookProducts = getPricingDetailForNewProduct(accountPricebookObj.orderId, accountPricebookObj.item.replace('BW','CW'));
                        if (tempAddPricebookProducts.size() > 0) {                    		
	  						for (Id key : productInfoMap.keySet()) {
	    						Product2 prod = productInfoMap.get(key);
	                			if (prod.SKU_External_Id__c == tempAddPriceBookProducts[0].item) {
	                    			tempAddPriceBookProducts[0].id = prod.Id;
	                			}
	            			}                    		
	                        tempAddPriceBookProducts[0].orderId = accountPricebookObj.orderId;
	                    	tempAddPriceBookProducts[0].qty = numberOfCases;      
	                    	tempAddPriceBookProductsList.add(tempAddPriceBookProducts[0]);
	                    }                        
                    } else {
                        updateQuantityMap.put(accountPricebookObj.item.replace('BW','CW'), numberOfCases);
                    }
                }
            }
            if (tempAddPriceBookProductsList.size() > 0) {
                accountPricebookProductsListToInsertUpdate.addAll(tempAddPriceBookProductsList);
            }            
            
            for (AccountPricebookProducts accountPricebookObj : accountPricebookProductsListToInsertUpdate) {
                if (accountPricebookObj.qty == 0) {
                    //Delete
                    if (accountPricebookObj.orderItemId != null) {
                    	OrderItem tempOrderItem = new OrderItem();
                    	tempOrderItem.Id = accountPricebookObj.orderItemId;
                    	orderItemsToDelete.add(tempOrderItem);
                    }
                } else if (accountPricebookObj.orderItemId != null) {
                    //Update
                    OrderItem tempOrderItem = new OrderItem();
                    tempOrderItem.Id = accountPricebookObj.orderItemId;
                    tempOrderItem.Quantity_Order__c = Integer.valueOf(accountPricebookObj.qty);
                    tempOrderItem.Quantity = Integer.valueOf(accountPricebookObj.qty);
                    if (accountPricebookObj.requestedQty != null) {
                        tempOrderItem.Requested_Quantity__c = accountPricebookObj.requestedQty;
                    }
					if (updateQuantityMap.containsKey(accountPricebookObj.item)) {
                        tempOrderItem.Quantity_Order__c += updateQuantityMap.get(accountPricebookObj.item);
                        tempOrderItem.Quantity += updateQuantityMap.get(accountPricebookObj.item);               
                    }
                    orderItemsToUpsert.add(tempOrderItem);
                } else {
                    //Add
                    OrderItem newOrderItem = new OrderItem();
                    newOrderItem.OrderId = accountPricebookObj.orderId;
                    newOrderItem.Quantity_Order__c = accountPricebookObj.qty;
                    newOrderItem.Quantity = accountPricebookObj.qty;
                    newOrderItem.Inventory__c = accountPricebookObj.qtyAvail;
                    newOrderItem.UnitPrice = accountPricebookObj.exPrice;
                    newOrderItem.Product2Id = accountPricebookObj.id;
                    newOrderItem.Unit_Discount__c = accountPricebookObj.unitDiscount;
                    if (accountPricebookObj.requestedQty != null) {
                        newOrderItem.Requested_Quantity__c = accountPricebookObj.requestedQty;
                    }                    
                    if (productInfoMap.get(accountPricebookObj.id).QuantityUnitOfMeasure != null) {
                        newOrderItem.Order_UOM__c = productInfoMap.get(accountPricebookObj.id).QuantityUnitOfMeasure;
                        newOrderItem.UOM__c = productInfoMap.get(accountPricebookObj.id).QuantityUnitOfMeasure;
                    } else {
                        newOrderItem.Order_UOM__c = 'unit';
                        newOrderItem.UOM__c = 'unit';
                    }
                    //BSSP-1046 suggested sell story text user story
                    newOrderItem.Suggested_Sell_Story_Text__c = accountPricebookObj.suggestedSellStoryText;
                    
                    if (accountPricebookObj.iconAltText == 'Suggested' || accountPricebookObj.iconAltText == 'Hot In The Area') {
                        newOrderItem.Suggested__c = true;
                        if (accountPricebookObj.iconAltText == 'Suggested') {
                            newOrderItem.Suggested_Icon__c = true;
                        } else {
                            newOrderItem.Suggested_Icon__c = false;
                        }
                    } else if (accountPricebookObj.iconAltText == 'Mandate Gap') {
                        newOrderItem.Mandate__c = true;
                    } else if (accountPricebookObj.iconAltText == 'Invoice') {
                        newOrderItem.Invoice__c = true;
                    } else if (accountPricebookObj.iconAltText == 'Pinned') {
                        newOrderItem.Pinned__c = true;
                        if (pinnedProductMap.containsKey(accountPricebookObj.id)) {
                            newOrderItem.Pinned_Notes__c = pinnedProductMap.get(accountPricebookObj.id).pinnedNotes;
                            newOrderItem.Expiration_Date__c = pinnedProductMap.get(accountPricebookObj.id).expirationDate;
                        }
                    } else {
                        if (orderItemInvoiceMap.containsKey(accountPricebookObj.id)) {
                            newOrderItem.Invoice__c = true;
                            OrderItem tempOrderItemObj = new OrderItem();
                            tempOrderItemObj.Id = orderItemInvoiceMap.get(accountPricebookObj.id).Id;
                            tempOrderItemObj.IsHidden__c = false;
                            orderItemInvoicesToUpdate.add(tempOrderItemObj);
                        }
                    }
                    orderItemsToUpsert.add(newOrderItem);
                }
            }

            if (!orderItemInvoicesToUpdate.isEmpty()) {
                orderItemsToUpsert.addALL(orderItemInvoicesToUpdate);
            }

            if (!orderItemsToUpsert.isEmpty()) {
                OrderItemDAO.upsertOrderItems(orderItemsToUpsert);
            }

            if (!orderItemsToDelete.isEmpty()) {
                OrderItemDAO.deleteOrderItems(orderItemsToDelete);
            }
            return orderItemsToUpsert;
        } catch(Exception ex){
            ErrorLog.insertErrorLog(ex.getMessage(), String.valueOf(ex.getLineNumber()), 'OrderEntryController', 'insertUpdateOrderItemRecords');
            return null;
        }
    }

    //pradeep getting account controllable value
    @AuraEnabled(cacheable=true)
    public static boolean isControllableAcct(String acctId){
        boolean controllableAcct = false;
        try {
            Account acct = [Select id, Controllable__c from account where id =:acctId];
            if(acct.Controllable__c == 'Controllable'){
                controllableAcct = true;
            }

        } catch (Exception e) {
            //throw new AuraHandledException(e.getMessage());
        }
        return controllableAcct;
    }

    public class InvoiceProductDetails {
        @AuraEnabled public List<AccountPricebookProducts> accountProducts;
        @AuraEnabled public List<String> invoiceDates;
        @AuraEnabled public Map<String, List<InvoiceProductDateDetails>> invoiceDateMap;
        @AuraEnabled public Flagged_Product_Frequency__mdt flaggedProductFrequency;
    }

    public class InvoiceProductDateDetails implements Comparable{
        @AuraEnabled public Date invoiceDate;
        @AuraEnabled public String invoiceDateString;
        @AuraEnabled public String priceBookEntryId;
        @AuraEnabled public Decimal qtyOrdered;

        public Integer compareTo(Object compareTo) {
            InvoiceProductDateDetails invoiceProductDateDetailsWrapper = (InvoiceProductDateDetails)compareTo;
            if (invoiceDate == invoiceProductDateDetailsWrapper.invoiceDate) return 0;
            if (invoiceDate < invoiceProductDateDetailsWrapper.invoiceDate) return 1;
            return -1;
        }
    }

    public class WarehouseOrderDetail {
        @AuraEnabled public Warehouse__c warehouseObj;
        @AuraEnabled public Date deliveryDate;
        @AuraEnabled public Boolean disableSubmitOrder;
    }

    public class ValidateAccountResponse {
       public List<AccountValidateResponseDetails> AccountRecords;
    }

    public class AccountValidateResponseDetails {
        public String AccountNumber;
        public String PassFailFlag;
        public String ErrorCode;
        public String ErrorCodeDescription;
    }

    public class OrderResponseDetail {
        @AuraEnabled public Order orderObj;
        @AuraEnabled public List<String> orderErrorMsg;
        @AuraEnabled public Boolean accountValidateError;
    }

    public class AccountProductsResponse {
        @AuraEnabled public OrderEntryUtility.AccountARDetails accountARDetailsObj;
        @AuraEnabled public List<String> invoiceDates;
        @AuraEnabled public Map<String, List<InvoiceProductDateDetails>> invoiceDateMap;
        @AuraEnabled public List<AccountPricebookProducts> accountProducts;
        @AuraEnabled public Map<String, AccountPricebookProducts> pinnedProductMap;
    }

    public class AccountPricebookProducts implements Comparable {
        @AuraEnabled public String orderItemId;
        @AuraEnabled public String orderId;
        @AuraEnabled public String index;
        @AuraEnabled public String key;
        @AuraEnabled public String id;
        @AuraEnabled public String orderStatus;
        @AuraEnabled public String name;
        @AuraEnabled public String iconClass;
        @AuraEnabled public String iconAltText;
        @AuraEnabled public String iconDesc;
        @AuraEnabled public Boolean checked;
        @AuraEnabled public Boolean defaultProd;
        @AuraEnabled public Boolean newProd;
        @AuraEnabled public Boolean invoiceProd;
        @AuraEnabled public Boolean showRecordIcon;
        @AuraEnabled public Decimal qty;
        @AuraEnabled public Integer requestedQty;
        @AuraEnabled public Decimal origQty;
        @AuraEnabled public String pkg;
        @AuraEnabled public String iconName;
        @AuraEnabled public String pkgType;
        @AuraEnabled public String quantityUOM;
        @AuraEnabled public Boolean isCase;
        @AuraEnabled public Boolean isKeg;
        @AuraEnabled public Boolean isBottle;
        @AuraEnabled public Boolean showInvRedText;
        @AuraEnabled public Decimal qtyAvail;
        @AuraEnabled public Decimal itemPrice;
        @AuraEnabled public Decimal casePrice;        
        @AuraEnabled public Decimal caseDeposit;
        @AuraEnabled public Decimal unitDeposit;
        @AuraEnabled public Decimal casePostOff;
        @AuraEnabled public Decimal unitPostOff;
        @AuraEnabled public Decimal caseCRV;
        @AuraEnabled public Decimal unitCRV;
        @AuraEnabled public Decimal caseEquiv;
        @AuraEnabled public Decimal unitsPerCase;
        @AuraEnabled public List<OrderEntryUtility.DealRecords> ItemRecords;
        @AuraEnabled public Decimal invoiceDate1Qty;
        @AuraEnabled public Boolean invoiceDate1Display;
        @AuraEnabled public Decimal invoiceDate2Qty;
        @AuraEnabled public Boolean invoiceDate2Display;
        @AuraEnabled public Decimal invoiceDate3Qty;
        @AuraEnabled public Boolean invoiceDate3Display;
        @AuraEnabled public Decimal invoiceDate4Qty;
        @AuraEnabled public Boolean invoiceDate4Display;
        @AuraEnabled public Decimal invoiceDate5Qty;
        @AuraEnabled public Boolean invoiceDate5Display;
        @AuraEnabled public Decimal invoiceDate6Qty;
        @AuraEnabled public Boolean invoiceDate6Display;
        @AuraEnabled public Decimal layer;
        @AuraEnabled public Decimal pallet;
        @AuraEnabled public Boolean hidden;
        @AuraEnabled public String pricebookEntryId;
        @AuraEnabled public Boolean palletThreshold;
        @AuraEnabled public Boolean layerThreshold;
        @AuraEnabled public String item;
        @AuraEnabled public Boolean stock;
        @AuraEnabled public Decimal unitPrice;
        @AuraEnabled public Decimal unitDiscount;
        @AuraEnabled public Decimal exPrice;
        @AuraEnabled public Boolean flaggedProduct;
        @AuraEnabled public String pinnedNotes;
        @AuraEnabled public Date expirationDate;
        @AuraEnabled public String feedback;
        @AuraEnabled public String createdBy;
        @AuraEnabled public String hoverText;
        @AuraEnabled public String hoverInactiveText;
        @AuraEnabled public Boolean pinnedProd;

        //added SuggestedSellStory BSSP-1046
        @AuraEnabled public String suggestedSellStoryText;

        public Integer compareTo(Object compareTo) {
            AccountPricebookProducts accountPricebookProdWrapper = (AccountPricebookProducts)compareTo;
            if (name == accountPricebookProdWrapper.name) return 0;
            if (name > accountPricebookProdWrapper.name) return 1;
            return -1;
        }
    }

    public class SelectDetails {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
    }

    public class OrderSummaryDetail {
        @AuraEnabled public List<SelectDetails> statusOptions;
        @AuraEnabled public Date deliveryDate;
        @AuraEnabled public Date nextFrequencyDeliveryDate;
        @AuraEnabled public String poNumber;
        @AuraEnabled public String orderName;
        @AuraEnabled public String orderStatus;
        @AuraEnabled public String accStatus;
        @AuraEnabled public Boolean requirePO;
        @AuraEnabled public Boolean offFrequency;
        @AuraEnabled public Boolean offDay;
        @AuraEnabled public String agentName;
        @AuraEnabled public String contactName;
        @AuraEnabled public String contactId;
        @AuraEnabled public String accountId;
        @AuraEnabled public String orderErrors;
        @AuraEnabled public String orderDetails;
        @AuraEnabled public Boolean fsrOrder;
        @AuraEnabled public String orderOrigin;
        @AuraEnabled public List<SelectDetails> originOptions;
        @AuraEnabled public String thirdPartyOrderType;
        @AuraEnabled public List<SelectDetails> thirdPartyOrderTypeOptions;
        @AuraEnabled public Decimal gpGoal;
    }
}
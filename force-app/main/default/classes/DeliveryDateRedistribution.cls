global class DeliveryDateRedistribution {

    @InvocableMethod
    public static void redistributeDeliveryDateAndCallDatesPerWarehouse(List<DeliveryDateRedistributionInputs> inputs){
       //Grabbing Initial Values
        Id callTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId();
        List<User> activeUser = UserDAO.getUser(UserInfo.getUserId());
        String userEmail = activeUser[0].Email;
        Date originalDate = inputs[0].originalDate;
        Boolean selectCities = inputs[0].selectCities;
        Boolean summaryOnly = inputs[0].summaryOnly;
        Boolean rescheduleCallsAlso = inputs[0].rescheduleCallsAlso;
        String rescheduleReason = inputs[0].rescheduleReason;
        List<Date> deliveryRescheduleDates = inputs[0].deliveryRescheduleDates;
        List<Date> callRescheduleDates = inputs[0].callRescheduleDates;
        List<Integer> rescheduledPercentages = inputs[0].reschedulePercentages;
        String warehouses = inputs[0].warehouse;
        String frequencies = inputs[0].frequencies;
        String sellTypes = inputs[0].sellTypes;
        String premises = inputs[0].premises;
        List<String> citiesList = inputs[0].cities;
        String planName = inputs[0].planName;
        String query;

        if(selectCities){
            query = 'SELECT Id, Account__c, Delivery_Date__c, Account__r.Warehouse__c' +
                    ' FROM Delivery_Date__c' +
                    ' WHERE Account__r.Warehouse__c IN :warehouseList' +
                    ' AND Account__r.Delivery_Frequency_Type__c IN :frequencyList' +
                    ' AND Account__r.Sell_Type__c IN :sellTypeList' +
                    ' AND Account__r.Premise__c IN :premiseList' +
                    ' AND Account__r.BillingCity IN :citiesList' +
                    ' AND Delivery_Date__c = :originalDate' ;
         }else{
            query = 'SELECT Id, Account__c, Delivery_Date__c, Account__r.Warehouse__c' +
                    ' FROM Delivery_Date__c' +
                    ' WHERE Account__r.Warehouse__c IN :warehouseList' +
                    ' AND Account__r.Delivery_Frequency_Type__c IN :frequencyList' +
                    ' AND Account__r.Sell_Type__c IN :sellTypeList' +
                    ' AND Account__r.Premise__c IN :premiseList' +
                    ' AND Delivery_Date__c = :originalDate' + 
                    ' ORDER BY Account__r.Name' ;
        }

        //Create the plan
        Plan__c newPlan = new Plan__c();
        newPlan.Name = planName;
        newPlan.Original_Delivery_Date__c = originalDate;
        newPlan.Reschedule_Reason__c = rescheduleReason;
        newPlan.Call_Dates__c = String.valueOf(callRescheduleDates);
        newPlan.Delivery_Dates__c = String.valueOf(deliveryRescheduleDates);
        newPlan.Delivery_Percentages__c = String.valueOf(rescheduledPercentages);
        newPlan.Delivery_Frequencies__c = frequencies;
        newPlan.Premise_Types__c = premises;
        newPlan.Sell_Types__c = sellTypes;
        newPlan.Warehouses__c = warehouses;
        if(citiesList != null){
            newPlan.Cities_Selected__c = String.valueOf(citiesList);
        }
        PlanDAO.insertPlans(new List<Plan__c>{newPlan});

        BatchHolidayPlanningDeliveryDate hPDeliveryDateBatch = new BatchHolidayPlanningDeliveryDate();
        hPDeliveryDateBatch.originalDate = originalDate;
        hPDeliveryDateBatch.selectCities = selectCities;
        hPDeliveryDateBatch.summaryOnly = summaryOnly;
        hPDeliveryDateBatch.rescheduleReason = rescheduleReason;
        hPDeliveryDateBatch.rescheduleCallsAlso = rescheduleCallsAlso;
        hPDeliveryDateBatch.deliveryRescheduleDates = deliveryRescheduleDates;
        hPDeliveryDateBatch.callRescheduleDates = callRescheduleDates;
        hPDeliveryDateBatch.rescheduledPercentages = rescheduledPercentages;
        hPDeliveryDateBatch.warehouses = warehouses;
        hPDeliveryDateBatch.frequencies = frequencies;
        hPDeliveryDateBatch.sellTypes = sellTypes;
        hPDeliveryDateBatch.premises = premises;
        hPDeliveryDateBatch.citiesList = citiesList;
        hPDeliveryDateBatch.planId = newPlan.Id;
        hPDeliveryDateBatch.planName = newPlan.Name;
        hPDeliveryDateBatch.userEmail = userEmail;
        hPDeliveryDateBatch.query = query;
        Database.executeBatch(hPDeliveryDateBatch, 2000);
    }

   global class DeliveryDateRedistributionInputs{

        @InvocableVariable
        global String rescheduleReason;

        @InvocableVariable
        global Boolean selectCities;

        @InvocableVariable
        global Boolean summaryOnly;

        @InvocableVariable 
        global String frequencies;

        @InvocableVariable
        global List<String> cities;

        @InvocableVariable
        global String warehouse;

        @InvocableVariable
        global Date originalDate;

        @InvocableVariable
        global List<Date> deliveryRescheduleDates;

        @InvocableVariable
        global List<Date> callRescheduleDates;

        @InvocableVariable 
        global List<Integer> reschedulePercentages;

        @InvocableVariable
        global Boolean rescheduleCallsAlso;

        @InvocableVariable
        global String planName;

        @InvocableVariable
        global String sellTypes;

        @InvocableVariable
        global String premises;
   }
}
global class CallRedistribution {

    @InvocableMethod
    public static void redistributeCallsPerWarehouse(List<CallRedistributionInputs> inputs){
        //Grabbing Initial Values
        Id callTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId();
        List<User> activeUser = UserDAO.getUser(UserInfo.getUserId());
        String userEmail = activeUser[0].Email;
        Date originalDate = inputs[0].originalDate;
        Boolean selectCities = inputs[0].selectCities;
        String rescheduleReason = inputs[0].rescheduleReason;
        List<Date> rescheduledDates = inputs[0].rescheduleDates;
        List<Integer> rescheduledPercentages = inputs[0].reschedulePercentages;
        String planName = inputs[0].planName;
        String warehouses = inputs[0].warehouses;
        String frequencies = inputs[0].frequencies;
        String sellTypes = inputs[0].sellTypes;
        String premises = inputs[0].premises;
        List<String> citiesList = inputs[0].cities;
        String query;

        Plan__c newPlan = new Plan__c();
        newPlan.Name = planName;
        newPlan.Original_Delivery_Date__c = originalDate;
        newPlan.Reschedule_Reason__c = rescheduleReason;
        newPlan.Call_Dates__c = String.valueOf(rescheduledDates);
        newPlan.Call_Percentages__c = String.valueOf(rescheduledPercentages);
        newPlan.Delivery_Frequencies__c = frequencies;
        newPlan.Premise_Types__c = premises;
        newPlan.Sell_Types__c = sellTypes;
        newPlan.Warehouses__c = warehouses;
        if(citiesList != null){
            newPlan.Cities_Selected__c = String.valueOf(citiesList);
        }
        PlanDAO.insertPlans(new List<Plan__c>{newPlan});

        //Grabbing the tasks
        if(selectCities){
            query = 'SELECT Id, Subject, Description, ActivityDate, Account__c, Account__r.Warehouse__c, Warehouse__c, Delivery_Date__c, Delivery_date__r.Delivery_Date__c, Priority, WhatId' +
                        ' FROM Task ' +
                        ' WHERE Account__r.Warehouse__c IN :warehouseList ' +
                        ' AND Account__r.Delivery_Frequency_Type__c IN :frequencyList' +
                        ' AND Account__r.Sell_Type__c IN :sellTypeList' +
                        ' AND Account__r.Premise__c IN :premiseList' +
                        ' AND ActivityDate = :originalDate' + 
                        ' AND Status = \'Open\'' +
                        ' AND Account__r.BillingCity IN :citiesList' +
                        ' AND RecordTypeId = :callTaskRecordTypeId' +
                        ' ORDER BY Account__r.Name' ;
       }else{
            query = 'SELECT Id, Subject, Description, ActivityDate, Account__c, Account__r.Warehouse__c, Warehouse__c, Delivery_Date__c, Delivery_date__r.Delivery_Date__c, Priority, WhatId ' +
                        ' FROM Task ' +
                        ' WHERE Account__r.Warehouse__c IN :warehouseList ' +
                        ' AND Account__r.Delivery_Frequency_Type__c IN :frequencyList' +
                        ' AND Account__r.Sell_Type__c IN :sellTypeList' +
                        ' AND Account__r.Premise__c IN :premiseList' +
                        ' AND ActivityDate = :originalDate' + 
                        ' AND Status = \'Open\'' +
                        ' AND RecordTypeId = :callTaskRecordTypeId' +
                        ' ORDER BY Account__r.Name' ;
        }

        BatchHolidayPlanningTask batchHPT = new BatchHolidayPlanningTask();
        batchHPT.originalDate = originalDate;
        batchHPT.citiesList = citiesList;
        batchHPT.rescheduleReason = rescheduleReason;
        batchHPT.callRescheduleDates = rescheduledDates;
        batchHPT.rescheduledPercentages = rescheduledPercentages;
        batchHPT.warehouses = warehouses;
        batchHPT.frequencies = frequencies;
        batchHPT.sellTypes = sellTypes;
        batchHPT.premises = premises;
        batchHPT.userEmail = userEmail;
        batchHPT.planId = newPlan.Id;
        batchHPT.planName = planName;
        batchHPT.query = query;
        database.executeBatch(batchHPT, 2000);
    }

    global class CallRedistributionInputs{

        @InvocableVariable
        global String rescheduleReason;

        @InvocableVariable
        global Boolean summaryOnly;

        @InvocableVariable
        global Boolean selectCities;

        @InvocableVariable 
        global String frequencies;

        @InvocableVariable
        global List<String> cities;
        
        @InvocableVariable
        global String warehouses;

        @InvocableVariable
        global Date originalDate;

        @InvocableVariable
        global List<Date> rescheduleDates;

        @InvocableVariable 
        global List<Integer> reschedulePercentages;

        @InvocableVariable
        global String planName;

        @InvocableVariable
        global String sellTypes;

        @InvocableVariable
        global String premises;
    }
}
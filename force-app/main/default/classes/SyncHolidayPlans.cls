global class SyncHolidayPlans {

    @InvocableMethod
    public static void syncHolidayPlans(){
        List<User> activeUser = UserDAO.getUser(UserInfo.getUserId());
        String userEmail = activeUser[0].Email;

        Date todaysDate = System.today();
        List<Plan__c> activePlanList = PlanDAO.getPlansForFilterDate(todaysDate);

        for(Plan__c planObj : activePlanList){
            if(planObj.Delivery_Dates__c != null){
                String deliveryDateQuery = 'SELECT Id, Account__c, Delivery_Date__c, Account__r.Warehouse__c' +
                    ' FROM Delivery_Date__c' +
                    ' WHERE Account__r.Warehouse__c IN :warehouseList' +
                    ' AND Account__r.Delivery_Frequency_Type__c IN :frequencyList' +
                    ' AND Account__r.Sell_Type__c IN :sellTypeList' +
                    ' AND Account__r.Premise__c IN :premiseList' +
                    ' AND Delivery_Date__c = :originalDate';
                BatchHolidayPlanningDeliveryDate hPDeliveryDateBatch = new BatchHolidayPlanningDeliveryDate();
                hPDeliveryDateBatch.originalDate = planObj.Original_Delivery_Date__c;
                hPDeliveryDateBatch.rescheduleReason = 'Holiday';
                hPDeliveryDateBatch.rescheduleCallsAlso = true;
                if(planObj.Delivery_Dates__c != null){
                    String deliveryDatesField = planObj.Delivery_Dates__c.remove('(').remove(')');
                    List<String> deliveryDatesSplit = deliveryDatesField.split(',');
                    List<Date> deliveryDates = new List<Date>();
                    for(String delivDate : deliveryDatesSplit){
                        delivDate = delivDate.trim();
                        if(delivDate != 'null'){
                            deliveryDates.add(Date.valueOf(delivDate));
                        }
                    }
                    hPDeliveryDateBatch.deliveryRescheduleDates = deliveryDates;
                }
                if(planObj.Call_Dates__c != null){
                    String callDatesField = planObj.Call_Dates__c.remove('(').remove(')');
                    List<String> callDatesSplit = callDatesField.split(',');
                    List<Date> callDates = new List<Date>();
                    for(String callDate : callDatesSplit){
                        callDate = callDate.trim();
                        if(callDate != 'null'){
                            callDates.add(Date.valueOf(callDate));
                        }
                    }
                    hPDeliveryDateBatch.callRescheduleDates = callDates;
                }
                if(planObj.Delivery_Percentages__c != null){
                    String deliveryPercentField = planObj.Delivery_Percentages__c.remove('(').remove(')');
                    List<String> deliveryPrecentagesSplit = deliveryPercentField.split(',');
                    List<Integer> deliveryPrecentages = new List<Integer>();
                    for(String delivPercent : deliveryPrecentagesSplit){
                        delivPercent = delivPercent.trim();
                        if(delivPercent != 'null'){
                            deliveryPrecentages.add(Integer.valueOf(delivPercent));
                        }
                    }
                    hPDeliveryDateBatch.rescheduledPercentages = deliveryPrecentages;
                }
                hPDeliveryDateBatch.warehouses = planObj.Warehouses__c;
                hPDeliveryDateBatch.frequencies = planObj.Delivery_Frequencies__c;
                hPDeliveryDateBatch.sellTypes = planObj.Sell_Types__c;
                hPDeliveryDateBatch.premises = planObj.Premise_Types__c;
                if(planObj.cities_Selected__c != null){
                    String citiesField = planObj.cities_Selected__c.remove('(').remove(')');
                    List<String> citiesList = citiesField.split(',');
                    List<String> citiesCleanList = new List<String>();
                    if(!citiesList.isEmpty()){
                        for(String city : citiesList){
                            city = city.trim();
                            if(city != 'null'){
                                citiesCleanList.add(city);
                            }
                        }
                        hPDeliveryDateBatch.citiesList = citiesCleanList;
                        deliveryDateQuery += ' AND Account__r.BillingCity IN :citiesList';
                    }
                }
                deliveryDateQuery += ' ORDER BY Account__r.Name';
                hPDeliveryDateBatch.planId = planObj.Id;
                hPDeliveryDateBatch.planName = planObj.Name;
                hPDeliveryDateBatch.userEmail = userEmail;
                hPDeliveryDateBatch.query = deliveryDateQuery;
                Database.executeBatch(hPDeliveryDateBatch, 2000);
            } else {
                if(planObj.Call_Dates__c != null){
                    String callQuery = 'SELECT Id, Subject, Description, ActivityDate, Account__c, Account__r.Warehouse__c, Warehouse__c, Delivery_Date__c, Delivery_date__r.Delivery_Date__c, Priority, WhatId ' +
                        ' FROM Task ' +
                        ' WHERE Account__r.Warehouse__c IN :warehouseList ' +
                        ' AND Account__r.Delivery_Frequency_Type__c IN :frequencyList' +
                        ' AND Account__r.Sell_Type__c IN :sellTypeList' +
                        ' AND Account__r.Premise__c IN :premiseList' +
                        ' AND ActivityDate = :originalDate' + 
                        ' AND Status = \'Open\'' +
                        ' AND RecordTypeId = :callTaskRecordTypeId';
                    BatchHolidayPlanningTask batchHPT = new BatchHolidayPlanningTask();
                    batchHPT.originalDate = planObj.Original_Delivery_Date__c;
                    if(planObj.cities_Selected__c != null){
                        String citiesField = planObj.cities_Selected__c.remove('(').remove(')');
                        List<String> citiesList = citiesField.split(',');
                        List<String> citiesCleanList = new List<String>();
                        if(!citiesList.isEmpty()){
                            for(String city : citiesList){
                                city = city.trim();
                                if(city != 'null'){
                                    citiesCleanList.add(city);
                                }
                            }
                            batchHPT.citiesList = citiesCleanList;
                            callQuery += ' AND Account__r.BillingCity IN :citiesList';
                        }
                    }
                    callQuery += ' ORDER BY Account__r.Name';
                    batchHPT.rescheduleReason = 'Holiday';
                    String callDatesField = planObj.Call_Dates__c.remove('(').remove(')');
                    List<String> callDatesSplit = callDatesField.split(',');
                    List<Date> callDates = new List<Date>();
                    for(String callDate : callDatesSplit){
                        callDate = callDate.trim();
                        if(callDate != 'null'){
                            callDates.add(Date.valueOf(callDate));
                        }
                    }
                    batchHPT.callRescheduleDates = callDates;
                    if(planObj.Call_Percentages__c != null){
                        String callPercentField = planObj.Call_Percentages__c.remove('(').remove(')');
                        List<String> callPrecentagesSplit = callPercentField.split(',');
                        List<Integer> callPrecentages = new List<Integer>();
                        for(String callPercent : callPrecentagesSplit){
                            callPercent = callPercent.trim();
                            if(callPercent != 'null'){
                                callPrecentages.add(Integer.valueOf(callPercent));
                            }
                        }
                        batchHPT.rescheduledPercentages = callPrecentages;
                    }
                    batchHPT.warehouses = planObj.Warehouses__c;
                    batchHPT.frequencies = planObj.Delivery_Frequencies__c;
                    batchHPT.sellTypes = planObj.Sell_Types__c;
                    batchHPT.premises = planObj.Premise_Types__c;
                    batchHPT.userEmail = userEmail;
                    batchHPT.planId = planObj.Id;
                    batchHPT.planName = planObj.Name;
                    batchHPT.query = callQuery;
                    database.executeBatch(batchHPT, 2000);
                }
            }
        }
    }
}
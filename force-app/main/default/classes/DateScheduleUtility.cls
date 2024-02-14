public class DateScheduleUtility {

    public static Map<String, Integer> dayOfTheWeekMap = new Map<String, Integer>{'Sunday'=>0,
                                                                            'Monday'=>1,
                                                                            'Tuesday'=>2,
                                                                            'Wednesday'=>3,
                                                                            'Thursday'=>4,
                                                                            'Friday'=>5,
                                                                            'Saturday'=>6};
    public static Map<Integer, String> dayOfTheWeekForNumMap = new Map<Integer, String>{0=>'Sunday',
                                                                            1=>'Monday',
                                                                            2=>'Tuesday',
                                                                            3=> 'Wednesday',
                                                                            4=>'Thursday',
                                                                            5=>'Friday',
                                                                            6=> 'Saturday'};
    public static Set<String> frequenciesToCheck = new Set<String>{'A', 'B', '1', '2', '3', '4'};

    public static List<Delivery_Date__c> returnListOfDeliveryDates(List<String> requestedDeliveryDays, Date startDate, Account accObj, Map<String, Integer> dayOfTheWeekMap, Map<Id, List<Delivery_Date__c>> accountIdToDDSet, String deliveryFrequency, 
                                                                Set<Date> presellCancelledDates) {
        List<Delivery_Date__c> deliveryDatesToBeInserted = new List<Delivery_Date__c>();
        for(String deliveryDay : requestedDeliveryDays){
            Date tempDate = startDate.addDays(Math.mod(Constants.ONE_WEEK_DAYS-dayOfWeekNumber(startDate)+dayOfTheWeekMap.get(deliveryDay),Constants.ONE_WEEK_DAYS));
            if(deliveryDay == 'Monday' && frequenciesToCheck.contains(deliveryFrequency)){
                tempDate = tempDate.addDays(Constants.ONE_WEEK_DAYS);
            }
            if(tempDate >= System.today()){
                if(accountIdToDDSet.containsKey(accObj.Id)){
                    Boolean insertDeliveryDate = true;
                    for(Delivery_Date__c dateObj : accountIdToDDSet.get(accObj.Id)){
                        if(tempDate == dateObj.Delivery_Date__c || tempDate == dateObj.Original_Delivery_Date__c){
                            insertDeliveryDate = false;
                        }
                    }
                    if(insertDeliveryDate){
                        deliveryDatesToBeInserted.add(createDeliveryDate(accObj, tempDate, 'Active'));
                    }
                }else{
                    if(!presellCancelledDates.isEmpty()){
                        if(presellCancelledDates.contains(tempDate)){
                            deliveryDatesToBeInserted.add(createDeliveryDate(accObj, tempDate, 'Cancelled'));
                        } else {
                            deliveryDatesToBeInserted.add(createDeliveryDate(accObj, tempDate, 'Active'));
                        }
                    } else {
                        deliveryDatesToBeInserted.add(createDeliveryDate(accObj, tempDate, 'Active'));
                    }
                }
            }
        }
        return deliveryDatesToBeInserted;
    }

    public static List<Task> returnListOfTasks(List<String> requestedDeliveryDays, Date startDate, Account accObj, Map<String, Integer> dayOfTheWeekMap, Map<String, Delivery_Date__c> accountDateStringToDeliveryDateMap, Map<Id, List<Delivery_Date__c>> accountIdToDDSet, String deliveryFrequency) {
        List<Task> tasksToBeInserted = new List<Task>();
        String callDays = accObj.Call_Days__c;
        for(String deliveryDay : requestedDeliveryDays){
            Date tempDate = startDate.addDays(Math.mod(Constants.ONE_WEEK_DAYS-dayOfWeekNumber(startDate)+dayOfTheWeekMap.get(deliveryDay),Constants.ONE_WEEK_DAYS));
            if(deliveryDay == 'Monday' && frequenciesToCheck.contains(deliveryFrequency)){
                tempDate = tempDate.addDays(Constants.ONE_WEEK_DAYS);
            }
            if(tempDate >= System.today()){
                Delivery_Date__c deliveryDateObj = accountDateStringToDeliveryDateMap.get(accObj.Id + String.valueOf(tempDate));
                if(deliveryDateObj != null){
                    if(accountIdToDDSet.containsKey(accObj.Id)){
                        Boolean insertDeliveryDate = true;
                        for(Delivery_Date__c dateObj : accountIdToDDSet.get(accObj.Id)){
                            if(tempDate == dateObj.Delivery_Date__c || tempDate == dateObj.Original_Delivery_Date__c){
                                insertDeliveryDate = false;
                            }
                        }
                        if(insertDeliveryDate){
                            if (callDays == null) {
                                //If Call Days are not populated on the Account, then continue to set Call Day to one day prior
                                if(deliveryDay == 'Monday'){
                                    tasksToBeInserted.add(createTask(accObj, tempDate - Constants.CALL_OFFSET_THREE_DAYS, deliveryDateObj));
                                } else {
                                    tasksToBeInserted.add(createTask(accObj, tempDate - Constants.CALL_OFFSET_ONE_DAY, deliveryDateObj));
                                }
                            } else {
                                //Base Call Tasks on the Call Days
                                tasksToBeInserted.add(createTask(accObj, tempDate - getDaysOffset(callDays, deliveryDay), deliveryDateObj));                                        
                            }
                        }
                    }else{
                        if (callDays == null) {
                            //If Call Days are not populated on the Account, then continue to set Call Day to one day prior
                            if(deliveryDay == 'Monday'){
                                tasksToBeInserted.add(createTask(accObj, tempDate - Constants.CALL_OFFSET_THREE_DAYS, deliveryDateObj));
                            } else {
                                tasksToBeInserted.add(createTask(accObj, tempDate - Constants.CALL_OFFSET_ONE_DAY, deliveryDateObj));
                            }
                        } else {
                            //Base Call Tasks on the Call Days                               
                            tasksToBeInserted.add(createTask(accObj, tempDate - getDaysOffset(callDays, deliveryDay), deliveryDateObj));             
                        }
                    }
                }
            }
        }

        return tasksToBeInserted;
    }

    public static List<Task> returnListOfTasksBasedOnTask(List<String> requestedDeliveryDays, Date startDate, Account accObj, Map<String, Integer> dayOfTheWeekMap, Map<String, Delivery_Date__c> accountDateStringToDeliveryDateMap, Map<Id, List<Task>> accountIdToTaskSet, String deliveryFrequency) {
        List<Task> tasksToBeInserted = new List<Task>();
        String callDays = accObj.Call_Days__c;
        for(String deliveryDay : requestedDeliveryDays){
            Date tempDate = startDate.addDays(Math.mod(Constants.ONE_WEEK_DAYS-dayOfWeekNumber(startDate)+dayOfTheWeekMap.get(deliveryDay),Constants.ONE_WEEK_DAYS));
            if(deliveryDay == 'Monday' && frequenciesToCheck.contains(deliveryFrequency)){
                tempDate = tempDate.addDays(Constants.ONE_WEEK_DAYS);
            }
            if(tempDate >= System.today()){
                Delivery_Date__c deliveryDateObj = accountDateStringToDeliveryDateMap.get(accObj.Id + String.valueOf(tempDate));
                if(deliveryDateObj != null){
                    if(accountIdToTaskSet.containsKey(accObj.Id)){
                        Boolean insertTask = true;
                        for(Task taskObj : accountIdToTaskSet.get(accObj.Id)){
                            if (callDays == null) {
                                if(deliveryDay == 'Monday'){
                                    if((tempDate - Constants.CALL_OFFSET_THREE_DAYS) == taskObj.ActivityDate){
                                        insertTask = false;
                                        break;
                                    }
                                } else {
                                    if((tempDate - Constants.CALL_OFFSET_ONE_DAY) == taskObj.ActivityDate){
                                        insertTask = false;
                                        break;
                                    }
                                }
                            } else {
                                if((tempDate - getDaysOffset(callDays, deliveryDay)) == taskObj.ActivityDate){
                                    insertTask = false;
                                    break;
                                }
                            }
                        }
                        if(insertTask){
                            if (callDays == null) {
                                if(deliveryDay == 'Monday'){
                                    tasksToBeInserted.add(createTask(accObj, tempDate - Constants.CALL_OFFSET_THREE_DAYS, deliveryDateObj));
                                } else {
                                    tasksToBeInserted.add(createTask(accObj, tempDate - Constants.CALL_OFFSET_ONE_DAY, deliveryDateObj));
                                }
                            } else {
                                //Base Call Tasks on the Call Days                                                            
                                tasksToBeInserted.add(createTask(accObj, tempDate - getDaysOffset(callDays, deliveryDay), deliveryDateObj));   
                            }
                        }
                    }else{
                        if (callDays == null) {
                            if(deliveryDay == 'Monday'){
                                tasksToBeInserted.add(createTask(accObj, tempDate - Constants.CALL_OFFSET_THREE_DAYS, deliveryDateObj));
                            } else {
                                tasksToBeInserted.add(createTask(accObj, tempDate - Constants.CALL_OFFSET_ONE_DAY, deliveryDateObj));
                            }
                        } else {
                            //Base Call Tasks on the Call Days                                                            
                            tasksToBeInserted.add(createTask(accObj, tempDate - getDaysOffset(callDays, deliveryDay), deliveryDateObj));
                        }
                    }
                }
            }
        }

        return tasksToBeInserted;
    }

    public static Integer getDaysOffset(String callDays, String tempDayOfWeek) {
        Integer daysOffset = 0;
        for (Integer i = 0; i < 7; i++) {
            if (tempDayOfWeek == 'Sunday') {
                tempDayOfWeek = 'Saturday';
            } else {
               tempDayOfWeek = dayOfTheWeekForNumMap.get(dayOfTheWeekMap.get(tempDayOfWeek)-1);
            }
            daysOffset += 1;
            if (callDays.contains(tempDayOfWeek)) {
                break;
            }
        }
        return daysOffset;                        
    }

    public static Integer dayOfWeekNumber(Date dateObj) {
        return Math.mod(Date.newInstance(1900, 1, 7).daysBetween(dateObj),Constants.ONE_WEEK_DAYS);
    }

    public static Delivery_Date__c createDeliveryDate(Account accObj, Date deliveryDate, String status){
        Delivery_Date__c newDeliveryDate = new Delivery_Date__c();
        newDeliveryDate.Account__c = accObj.id;
        newDeliveryDate.Original_Delivery_Date__c = deliveryDate;
        newDeliveryDate.Delivery_Date__c = deliveryDate;
        newDeliveryDate.Status__c = status;
        return newDeliveryDate;
    }

    public static Task createTask(Account accObj, Date callDate, Delivery_Date__c deliveryDateObj){
        Task newTask = new Task();
        newTask.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId();
        if(accObj.Warehouse_Lookup__r.ISR_1__c != null){
            newTask.OwnerId = accObj.Warehouse_Lookup__r.ISR_1__c;
        } else {
            newTask.OwnerId = accObj.OwnerId;
        }
        newTask.subject = 'Outbound Call - ' + accObj.Name;
        newTask.ActivityDate = callDate;
        newTask.Original_Call_Date__c = callDate;
        newTask.WhatId = accObj.Id;
        newTask.Account__c = accObj.Id;
        newTask.Delivery_Date__c = deliveryDateObj.Id;
        return newTask;
    }

    public static Date AddBusinessDays(Date startDate, Integer businessDaysToAdd ) {
        //Add or decrease business days
        Date finalDate = startDate;
        Integer direction = businessDaysToAdd < 0 ? -1 : 1;
        while(businessDaysToAdd != 0)
        {
            finalDate = finalDate.addDays(direction);
            if (!IsWeekend(finalDate))
            {
                businessDaysToAdd -= direction;
            }
        }
        return finalDate;
    }

    public static Boolean IsWeekend(Date myDate) {
        String myDateString = Datetime.newInstance(myDate.year(), myDate.month(),myDate.day()).format('EEE');
        return 'Sat'.equals(myDateString) || 'Sun'.equals(myDateString);
    }

    public static Set<Date> returnDateSetFromString(String dates) {
        String datesField = dates.remove('(').remove(')');
        List<String> datesFieldSplit = datesField.split(',');
        Set<Date> dateSet = new Set<Date>();
        for(String dateString : datesFieldSplit){
            dateString = dateString.trim();
            if(dateString != 'null'){
                dateSet.add(Date.valueOf(dateString));
            }
        }
        return dateSet;
    }

    public static CallScheduleStartEndWrapper getCallScheduleStartAndEndDates(Date todaysDate){
        Date todaysDateWeek = todaysDate.toStartOfWeek();
        Date startOfCycle = Date.newInstance(2020, 1, 1).toStartOfWeek();
        Integer daysBetween = startOfCycle.daysBetween(todaysDateWeek);
        Integer numberOfWeek = daysBetween/Constants.WEEK_INTEGER; 
        Integer fourWeekCycle = numberOfWeek/Constants.FOUR_WEEK_CYCLE; 
        Integer daysToAddForCycle = fourWeekCycle * Constants.FOUR_WEEK_CYCLE * Constants.WEEK_INTEGER; 
        Date startDate = startOfCycle.addDays(daysToAddForCycle); 
        Date endDate = startDate.addDays(Constants.TWELVE_WEEKS_DAYS).toStartOfWeek(); 
        Date accountBatchStartDate = startDate;
        Date tempEndDate = endDate;
        Integer numOfDaysBetween = startDate.daysBetween(todaysDateWeek);
        Decimal weeksBetween = Decimal.valueOf(numOfDaysBetween)/Constants.WEEK_INTEGER;
        if(weeksBetween > 0 && weeksBetween <= 1){
            tempEndDate = tempEndDate.addDays(Constants.ONE_WEEK_DAYS);
        } else if(weeksBetween > 1 && weeksBetween <= 2){
            tempEndDate = tempEndDate.addDays(Constants.TWO_WEEK_DAYS);
        } else if(weeksBetween > 2 && weeksBetween <= 3){
            tempEndDate = tempEndDate.addDays(Constants.THREE_WEEK_DAYS);
        } else if(weeksBetween > 3 && weeksBetween <= 4){
            tempEndDate = tempEndDate.addDays(Constants.FOUR_WEEK_DAYS);
        }

        CallScheduleStartEndWrapper callScheduleStartEndWrapperObj = new CallScheduleStartEndWrapper();
        callScheduleStartEndWrapperObj.startDate = startDate;
        callScheduleStartEndWrapperObj.endDate = tempEndDate;
        callScheduleStartEndWrapperObj.todaysDateWeek = todaysDateWeek;
        return callScheduleStartEndWrapperObj;
    }

    public class CallScheduleStartEndWrapper {
        public Date startDate;
        public Date endDate;
        public Date todaysDateWeek;
    }
}
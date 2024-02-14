public class BatchCallSchedule implements Database.Batchable<sObject>{

    public String query;
    public String retailAccountRecordTypeId;

    public BatchCallSchedule(){
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Account> accountList){
        try{
            Map<String, Integer> dayOfTheWeekMap = DateScheduleUtility.dayOfTheWeekMap;
            //Gets the Call Scheduling Frequency Map from the Custom Metadata
            List<Call_Scheduling_Frequency__mdt> callScheduleFrequency = CallSchedulingFrequencyDAO.getCallSchedlingFrequency();

            Map<String, Call_Scheduling_Frequency__mdt> callScheduleFrequencyMap = new Map<String, Call_Scheduling_Frequency__mdt>();
            for(Call_Scheduling_Frequency__mdt callSchedule : callScheduleFrequency){
                callScheduleFrequencyMap.put(callSchedule.MasterLabel, callSchedule);
            }

            Map<String,Delivery_Date__c> accountDateStringToDeliveryDateMap = new Map<String,Delivery_Date__c>();
            DateScheduleUtility.CallScheduleStartEndWrapper callScheduleStartEndDateWrapperObj = DateScheduleUtility.getCallScheduleStartAndEndDates(System.today());

            //Get a set of Account Ids
            Set<Id> accountIds = new Set<Id>();
            for(Account acc : accountList){
                accountIds.add(acc.Id);
            }

            //*************************************************'
            // CREATE DELIVERY DATES
            //*************************************************'
            //Get a list of All Delivery Dates for all Accounts greater than today
            List<Delivery_Date__c> deliveryDateList = DeliveryDateDAO.getDeliveryDatesAccountDate(accountIds, System.today());

            //Create a Map of all the Accounts and it's Delivery Dates
            Map<Id, List<Delivery_Date__c>> accountIdToDDSet = new Map<Id, List<Delivery_Date__c>>();
            for(Delivery_Date__c dd : deliveryDateList){
                if(accountIdToDDSet.containsKey(dd.Account__c)){
                    accountIdToDDSet.get(dd.Account__c).add(dd);
                }else{
                    List<Delivery_Date__c> deliveryDates = new List<Delivery_Date__c>();
                    deliveryDates.add(dd);
                    accountIdToDDSet.put(dd.Account__c, deliveryDates);
                }
            }

            List<Delivery_Date__c> deliveryDatesToInsert = new List<Delivery_Date__c>();
            List<Task> tasksToInsert = new List<Task>();
            //First we're going to cycle through and created Delivery Dates
            for(Account accObj : accountList){
                //Here we check if Delivery Dates need to be created
                if(accObj.Requested_Delivery_Days__c != null && accObj.Delivery_Frequency_Type__c != null){
                    Set<Date> presellCancelledDates = new Set<date>();
                    Date tempStartDate = callScheduleStartEndDateWrapperObj.startDate;
                    List<String> requestedDeliveryDays = accObj.Requested_Delivery_Days__c.split(';');
                    String deliveryFrequency = accObj.Delivery_Frequency_Type__c;
                    if(callScheduleFrequencyMap.containsKey(deliveryFrequency)){
                        tempStartDate = tempStartDate.addDays(Integer.valueOf(callScheduleFrequencyMap.get(deliveryFrequency).Preset_Start_Date__c));
                    }

                    do{
                        if(callScheduleFrequencyMap.containsKey(deliveryFrequency)){
                            if(tempStartDate >= callScheduleStartEndDateWrapperObj.todaysDateWeek){
                                deliveryDatesToInsert.addAll(DateScheduleUtility.returnListOfDeliveryDates(requestedDeliveryDays, tempStartDate, accObj, dayOfTheWeekMap, accountIdToDDSet, deliveryFrequency, presellCancelledDates));
                            }
                            tempStartDate = tempStartDate.addDays(Integer.valueOf(callScheduleFrequencyMap.get(deliveryFrequency).Days_To_Advance__c));
                        } else {
                            break;
                        }
                    } while(tempStartDate < callScheduleStartEndDateWrapperObj.endDate);
                }
            }

            //Insert the Delivery Dates
            DeliveryDateDAO.insertDeliveryDates(deliveryDatesToInsert);

            
            //*************************************************'
            // CALL TASK CREATION
            //*************************************************'
            //Create a map of the Delivery Dates so they can be referenced in the upcoming Call Task Creation
            for(Delivery_Date__c delivDay : deliveryDatesToInsert){
                accountDateStringToDeliveryDateMap.put(delivDay.Account__c + String.valueOf(delivDay.Delivery_Date__c), delivDay);
            }

            //Create the Call Tasks
            for(Account accObj : accountList){
                if(accObj.Requested_Delivery_Days__c != null && accObj.Delivery_Frequency_Type__c != null){
                    if(accobj.Sell_Type__c == 'INSIDE SALES' || accobj.Sell_Type__c == 'NATIONAL ACCTS'){
                        Date tempStartDate = callScheduleStartEndDateWrapperObj.startDate;
                        List<String> requestedDeliveryDays = accObj.Requested_Delivery_Days__c.split(';');
                        String deliveryFrequency = accObj.Delivery_Frequency_Type__c;
                        if(callScheduleFrequencyMap.containsKey(deliveryFrequency)){
                            tempStartDate = tempStartDate.addDays(Integer.valueOf(callScheduleFrequencyMap.get(deliveryFrequency).Preset_Start_Date__c));
                        }

                        do{
                            if(callScheduleFrequencyMap.containsKey(deliveryFrequency)){
                                if(tempStartDate >= callScheduleStartEndDateWrapperObj.todaysDateWeek){
                                    tasksToInsert.addAll(DateScheduleUtility.returnListOfTasks(requestedDeliveryDays, tempStartDate, accObj, dayOfTheWeekMap, accountDateStringToDeliveryDateMap, accountIdToDDSet, deliveryFrequency));
                                }
                                tempStartDate = tempStartDate.addDays(Integer.valueOf(callScheduleFrequencyMap.get(deliveryFrequency).Days_To_Advance__c));
                            } else {
                                break;
                            }
                        } while(tempStartDate < callScheduleStartEndDateWrapperObj.endDate);
                    }
                }
            }

            if(!tasksToInsert.isEmpty()){
                TaskDAO.insertTasks(tasksToInsert);
            }
        } catch(Exception ex){
            ErrorLog.insertErrorLog(ex.getMessage(), String.valueOf(ex.getLineNumber()), 'BatchCallSchedule', 'BatchCallSchedule.execute()');
        }
    }

    public void finish(Database.BatchableContext BC){
    }
}
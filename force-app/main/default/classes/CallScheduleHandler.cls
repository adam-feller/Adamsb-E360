public with sharing class CallScheduleHandler {

    public static void checkForUpdatedCallScheduleDeliveryDay(List<Account> changedAccounts, Map<Id, Account> oldAccounts) {
        try{
            Set<Id> accountIds = new Set<Id>();
            //Get the Ids of Accounts that had relevant Changes

            for(Account accountObj : changedAccounts){
                if(accountObj.Requested_Delivery_Days__c != null && accountObj.Delivery_Frequency_Type__c != null && accountObj.Status__c == 'A'){
                    if(oldAccounts != null){
                        if((accountObj.Requested_Delivery_Days__c != oldAccounts.get(accountObj.Id).Requested_Delivery_Days__c) || 
                        (accountObj.Delivery_Frequency_Type__c != oldAccounts.get(accountObj.Id).Delivery_Frequency_Type__c) ||
                        (accountObj.Call_Days__c != oldAccounts.get(accountObj.Id).Call_Days__c) ||
                        (accountObj.Status__c != oldAccounts.get(accountObj.Id).Status__c)){
                            accountIds.add(accountObj.Id);
                        }
                    } else{
                        accountIds.add(accountObj.Id);
                    }
                }
            }

            //For those relevantly changed accounts, delete delivery dates and cancel tasks & create new delivery dates and tasks --with respect to today forward
            if(!accountIds.isEmpty()){

                //Get tthe eseential base info - Account Info, Call Frequency metadata, cycle start and end dates
                List<Account> validAccountsToUpdate = AccountDAO.getAccountsByIds(accountIds);

                Map<String, Integer> dayOfTheWeekMap = DateScheduleUtility.dayOfTheWeekMap;
                List<Call_Scheduling_Frequency__mdt> callScheduleFrequency = CallSchedulingFrequencyDAO.getCallSchedlingFrequency();
                Map<String, Call_Scheduling_Frequency__mdt> callScheduleFrequencyMap = new Map<String, Call_Scheduling_Frequency__mdt>();
                for(Call_Scheduling_Frequency__mdt callSchedule : callScheduleFrequency){
                    callScheduleFrequencyMap.put(callSchedule.MasterLabel, callSchedule);
                }

                DateScheduleUtility.CallScheduleStartEndWrapper callScheduleStartEndDateWrapperObj = DateScheduleUtility.getCallScheduleStartAndEndDates(System.today());

                //Get the delivery dates for the relevant accounts
                List<Delivery_Date__c> deliveryDatesForAccount = DeliveryDateDAO.getDeliveryDatesByAccountIds(accountIds);

                //Put those delivery dates in a map by account
                Map<Id, List<Delivery_Date__c>> deliveryDatesAccountMap = new Map<Id, List<Delivery_Date__c>>();
                for(Delivery_Date__c delivDate : deliveryDatesForAccount){
                    if(deliveryDatesAccountMap.containsKey(delivDate.Account__c)){
                        deliveryDatesAccountMap.get(delivDate.Account__c).add(delivDate);
                    }else{
                        List<Delivery_Date__c> deliveryDateList = new List<Delivery_Date__c>();
                        deliveryDateList.add(delivDate);
                        deliveryDatesAccountMap.put(delivDate.Account__c, deliveryDateList);
                    }
                }

                //Get the call tasks for relevant accounts
                List<Task> callTasksForAccount = TaskDAO.getTasksByIdStatusRecordType(accountIds, 'Open', Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId());
                Map<Id, List<Task>> taskCallAccountMap = new Map<Id, List<Task>>();
                
                //Put those tasks in a map by account
                for(Task taskObj : callTasksForAccount){
                    if(taskCallAccountMap.containsKey(taskObj.WhatId)){
                        taskCallAccountMap.get(taskObj.WhatId).add(taskObj);
                    }else{
                        List<Task> taskList = new List<Task>();
                        taskList.add(taskObj);
                        taskCallAccountMap.put(taskObj.WhatId, taskList);
                    }
                }

                //We need a Map of the Set of Delivery Dates (original) which we'll use to ensure we don't create delivery dates already created (fail-safe)
                Map<Id, List<Delivery_Date__c>> accountIdToDDSet = new Map<Id, List<Delivery_Date__c>>();

                //Here we initialize the lists of Delivery Dates and Tasks that will potentially change
                List<Delivery_Date__c> deliveryDatesToDelete = new List<Delivery_Date__c>();
                List<Delivery_Date__c> deliveryDatesToInsert = new List<Delivery_Date__c>();
                List<Task> tasksToInsert = new List<Task>();
                List<Task> tasksToUpdate = new List<Task>(); //i.e. to cancel

                //Now we finally enter our for loop through accoutns to assign the Delivery Dates and Tasks to the above lists

                for(Account accObj : validAccountsToUpdate){
                    List<String> requestedDeliveryDays = accObj.Requested_Delivery_Days__c.split(';');
                    String deliveryFrequency = accObj.Delivery_Frequency_Type__c;
                    Set<Date> presellCancelledDates = new Set<Date>();
                    if(accObj.Presell_Cancelled_Dates__c != null){
                        presellCancelledDates = DateScheduleUtility.returnDateSetFromString(accObj.Presell_Cancelled_Dates__c);
                    }
                    Set<Date> presellInsertedDates = new Set<Date>();
                    if(accObj.Presell_Inserted_Dates__c != null){
                        presellInsertedDates = DateScheduleUtility.returnDateSetFromString(accObj.Presell_Inserted_Dates__c);
                    }
                    //Go through the respective accounts delivery dates and identify Delivery Dates into the future that need to be deleted
                    if(deliveryDatesAccountMap.containsKey(accObj.Id)){
                        for(Delivery_Date__c delivDay : deliveryDatesAccountMap.get(accObj.Id)){
                            if(delivDay.Delivery_Date__c >= System.today()){
                                deliveryDatesToDelete.add(delivDay);
                            }
                        }
                    }

                    //Go through the respective accounts call tasks and identify the call tasks into the future that need to be cancelled 
                    if(taskCallAccountMap.containsKey(accObj.Id)){
                        for(Task taskObj : taskCallAccountMap.get(accObj.Id)){
                            if(taskObj.ActivityDate >= System.today()){
                                taskObj.Status = 'Cancelled';
                                tasksToUpdate.add(taskObj);
                            }
                        }
                    }

                    //Now we set temp star as we're going to recreate the new delivery dates and call tasks according to the new delivery parameters
                    Date tempStartDate = callScheduleStartEndDateWrapperObj.startDate;

                    //Here according to the new delivery frequency, we offset the start date from the beginning of the nearest A week
                    if(callScheduleFrequencyMap.containsKey(deliveryFrequency)){
                        tempStartDate = tempStartDate.addDays(Integer.valueOf(callScheduleFrequencyMap.get(deliveryFrequency).Preset_Start_Date__c));
                    }

                    List<Delivery_Date__c> deliveryDatesProcessed = new List<Delivery_Date__c>();
                    //Now we cycle through the through and add delivery dates for each cycle of the frequency
                    do{
                        if(callScheduleFrequencyMap.containsKey(deliveryFrequency)){
                            if(tempStartDate >= callScheduleStartEndDateWrapperObj.todaysDateWeek){
                                deliveryDatesProcessed.addAll(DateScheduleUtility.returnListOfDeliveryDates(requestedDeliveryDays, tempStartDate, accObj, dayOfTheWeekMap, accountIdToDDSet, deliveryFrequency, presellCancelledDates));
                            }
                            tempStartDate = tempStartDate.addDays(Integer.valueOf(callScheduleFrequencyMap.get(deliveryFrequency).Days_To_Advance__c));
                        } else {
                            break;
                        }
                    } while(tempStartDate < callScheduleStartEndDateWrapperObj.endDate);

                    if(!presellInsertedDates.isEmpty()){
                        List<Date> deliveryDateToInsert = new List<Date>();
                        for(Delivery_Date__c delivDate : deliveryDatesProcessed){
                            if(presellInsertedDates.contains(delivDate.Delivery_Date__c)){
                                delivDate.Status__c = 'Active';
                                presellInsertedDates.remove(delivDate.Delivery_Date__c);
                            }
                        }

                        if(!presellInsertedDates.isEmpty()){
                            for(Date presellDates : presellInsertedDates){
                                if(presellDates >= System.today()){
                                    deliveryDatesProcessed.add(DateScheduleUtility.createDeliveryDate(accObj, presellDates, 'Active'));
                                }
                            }
                        }
                    }

                    deliveryDatesToInsert.addAll(deliveryDatesProcessed);
                }

                if(!deliveryDatesToDelete.isEmpty()){
                    DeliveryDateDAO.deleteDeliveryDates(deliveryDatesToDelete); 
                }

                 //Insert those delivery dates (we need to do it now, as we need the Id to be referenced in the upcoming creation of corresponding call tasks)
                if(!deliveryDatesToInsert.isEmpty()){
                    DeliveryDateDAO.insertDeliveryDates(deliveryDatesToInsert);
                }

                //To keep track of those delivery dates, we create an map using a an account+deliverydate key (Note: it's be more correct to use Original_Delievery_Date__c here instead, since Delivery_Date__c field can be moved)
                Map<String,Delivery_Date__c> accountDateStringToDeliveryDateMap = new Map<String,Delivery_Date__c>();

                for(Delivery_Date__c delivDay : deliveryDatesToInsert){
                    accountDateStringToDeliveryDateMap.put(delivDay.Account__c + String.valueOf(delivDay.Delivery_Date__c), delivDay);
                }

                for(Account accObj : validAccountsToUpdate){
                    List<String> requestedDeliveryDays = accObj.Requested_Delivery_Days__c.split(';');
                    String deliveryFrequency = accObj.Delivery_Frequency_Type__c;

                    //Resetting those the temp start
                    Date tempStartDate = callScheduleStartEndDateWrapperObj.startDate;

                    //As before for delivery dates, Offsetting the tempStartDate according to the delivery frequency - this time to create Tasks
                    if(callScheduleFrequencyMap.containsKey(deliveryFrequency)){
                        tempStartDate = tempStartDate.addDays(Integer.valueOf(callScheduleFrequencyMap.get(deliveryFrequency).Preset_Start_Date__c));
                    }

                    do{
                        if(callScheduleFrequencyMap.containsKey(deliveryFrequency)){
                            if(tempStartDate >= callScheduleStartEndDateWrapperObj.todaysDateWeek && (accobj.Sell_Type__c == 'INSIDE SALES' || accobj.Sell_Type__c == 'NATIONAL ACCTS') ){
                                tasksToInsert.addAll(DateScheduleUtility.returnListOfTasks(requestedDeliveryDays, tempStartDate , accObj, dayOfTheWeekMap, accountDateStringToDeliveryDateMap, accountIdToDDSet, deliveryFrequency));
                            }
                            tempStartDate = tempStartDate.addDays(Integer.valueOf(callScheduleFrequencyMap.get(deliveryFrequency).Days_To_Advance__c));
                        } else {
                            break;
                        }
                    } while(tempStartDate < callScheduleStartEndDateWrapperObj.endDate);
                }

                if(!tasksToInsert.isEmpty()){
                    TaskDAO.insertTasks(tasksToInsert);
                }

                if(!tasksToupdate.isEmpty()){
                    TaskDAO.updateTasks(tasksToUpdate);
                }
            }
        } catch(Exception ex){
            ErrorLog.insertErrorLog(ex.getMessage(), String.valueOf(ex.getLineNumber()), 'CallScheduleHandler', 'CallScheduleHandler.checkForUpdatedCallScheduleDeliveryDay()');
        }
    }

    public static void cancelCallsAndDeleteDeliveryDayForIorOAccounts(List<Account> changedAccounts, Map<Id, Account> oldAccounts) {
        try{
            Set<Id> accountIds = new Set<Id>();
            for(Account accountObj : changedAccounts){
                if(accountObj.Requested_Delivery_Days__c != null && accountObj.Delivery_Frequency_Type__c != null && (accountObj.Status__c == 'I' || accountObj.Status__c == 'O')){
                    if(accountObj.Status__c != oldAccounts.get(accountObj.Id).Status__c){
                        accountIds.add(accountObj.Id);
                    }
                }
            }

            if(!accountIds.isEmpty()){
                List<Account> validAccountsToUpdate = AccountDAO.getAccountsByIds(accountIds);
                List<Delivery_Date__c> deliveryDatesForAccount = DeliveryDateDAO.getDeliveryDatesByAccountIds(accountIds);

                Map<Id, List<Delivery_Date__c>> deliveryDatesAccountMap = new Map<Id, List<Delivery_Date__c>>();
                for(Delivery_Date__c delivDate : deliveryDatesForAccount){
                    if(deliveryDatesAccountMap.containsKey(delivDate.Account__c)){
                        deliveryDatesAccountMap.get(delivDate.Account__c).add(delivDate);
                    }else{
                        List<Delivery_Date__c> deliveryDateList = new List<Delivery_Date__c>();
                        deliveryDateList.add(delivDate);
                        deliveryDatesAccountMap.put(delivDate.Account__c, deliveryDateList);
                    }
                }

                List<Task> callTasksForAccount = TaskDAO.getTasksByIdStatusRecordType(accountIds, 'Open', Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId());
                Map<Id, List<Task>> taskCallAccountMap = new Map<Id, List<Task>>();

                for(Task taskObj : callTasksForAccount){
                    if(taskCallAccountMap.containsKey(taskObj.WhatId)){
                        taskCallAccountMap.get(taskObj.WhatId).add(taskObj);
                    }else{
                        List<Task> taskList = new List<Task>();
                        taskList.add(taskObj);
                        taskCallAccountMap.put(taskObj.WhatId, taskList);
                    }
                }

                List<Delivery_Date__c> deliveryDatesToDelete = new List<Delivery_Date__c>();
                List<Task> tasksToUpdate = new List<Task>();

                for(Account accObj : validAccountsToUpdate){
                    if(deliveryDatesAccountMap.containsKey(accObj.Id)){
                        for(Delivery_Date__c delivDay : deliveryDatesAccountMap.get(accObj.Id)){
                            if(delivDay.Delivery_Date__c >= System.today()){
                                deliveryDatesToDelete.add(delivDay);
                            }
                        }
                    }

                    if(taskCallAccountMap.containsKey(accObj.Id)){
                        for(Task taskObj : taskCallAccountMap.get(accObj.Id)){
                            if(taskObj.ActivityDate >= System.today()){
                                taskObj.Status = 'Cancelled';
                                tasksToUpdate.add(taskObj);
                            }
                        }
                    }
                }

                if(!deliveryDatesToDelete.isEmpty()){
                    DeliveryDateDAO.deleteDeliveryDates(deliveryDatesToDelete);
                }

                if(!tasksToupdate.isEmpty()){
                    TaskDAO.updateTasks(tasksToUpdate);
                }
            }
        } catch(Exception ex){
            ErrorLog.insertErrorLog(ex.getMessage(), String.valueOf(ex.getLineNumber()), 'CallScheduleHandler', 'cancellCallsAndDeleteDeliveryDayForIorOAccounts()');
        }
    }

    public static void checkForUpdatedSellType(List<Account> changedAccounts, Map<Id, Account> oldAccounts) {
        try{
            Set<Id> accountIds = new Set<Id>();
            //Get the Ids of Accounts that had relevant Changes

            for(Account accountObj : changedAccounts){
                if(accountObj.Requested_Delivery_Days__c != null && accountObj.Delivery_Frequency_Type__c != null && accountObj.Sell_Type__c != null && accountObj.Status__c == 'A'){
                    if((accountObj.Sell_Type__c != oldAccounts.get(accountObj.Id).Sell_Type__c)){
                        if((accountObj.Requested_Delivery_Days__c == oldAccounts.get(accountObj.Id).Requested_Delivery_Days__c) && 
                        (accountObj.Delivery_Frequency_Type__c == oldAccounts.get(accountObj.Id).Delivery_Frequency_Type__c) &&
                        (accountObj.Status__c == oldAccounts.get(accountObj.Id).Status__c)){
                            accountIds.add(accountObj.Id);
                        }
                    }
                }
            }

            //For those relevantly changed accounts, cancel tasks & create new tasks --with respect to today forward
            if(!accountIds.isEmpty()){

                //Get tthe eseential base info - Account Info, Call Frequency metadata, cycle start and end dates
                List<Account> validAccountsToUpdate = AccountDAO.getAccountsByIds(accountIds);

                Map<String, Integer> dayOfTheWeekMap = DateScheduleUtility.dayOfTheWeekMap;
                List<Call_Scheduling_Frequency__mdt> callScheduleFrequency = CallSchedulingFrequencyDAO.getCallSchedlingFrequency();
                Map<String, Call_Scheduling_Frequency__mdt> callScheduleFrequencyMap = new Map<String, Call_Scheduling_Frequency__mdt>();
                for(Call_Scheduling_Frequency__mdt callSchedule : callScheduleFrequency){
                    callScheduleFrequencyMap.put(callSchedule.MasterLabel, callSchedule);
                }

                DateScheduleUtility.CallScheduleStartEndWrapper callScheduleStartEndDateWrapperObj = DateScheduleUtility.getCallScheduleStartAndEndDates(System.today());

                //Get the delivery dates for the relevant accounts
                List<Delivery_Date__c> deliveryDatesForAccount = DeliveryDateDAO.getDeliveryDatesByAccountIds(accountIds);

                //To keep track of those delivery dates, we create an map using a an account+deliverydate key (Note: it's be more correct to use Original_Delievery_Date__c here instead, since Delivery_Date__c field can be moved)
                Map<String,Delivery_Date__c> accountDateStringToDeliveryDateMap = new Map<String,Delivery_Date__c>();
                for(Delivery_Date__c delivDay : deliveryDatesForAccount){
                    accountDateStringToDeliveryDateMap.put(delivDay.Account__c + String.valueOf(delivDay.Delivery_Date__c), delivDay);
                }

                //Get the call tasks for relevant accounts
                List<Task> callTasksForAccount = TaskDAO.getTasksByIdStatusRecordType(accountIds, 'Open', Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId());
                Map<Id, List<Task>> taskCallAccountMap = new Map<Id, List<Task>>();

                //Put those tasks in a map by account
                for(Task taskObj : callTasksForAccount){
                    if(taskCallAccountMap.containsKey(taskObj.WhatId)){
                        taskCallAccountMap.get(taskObj.WhatId).add(taskObj);
                    }else{
                        List<Task> taskList = new List<Task>();
                        taskList.add(taskObj);
                        taskCallAccountMap.put(taskObj.WhatId, taskList);
                    }
                }

                List<Task> tasksToInsert = new List<Task>();
                List<Task> tasksToUpdate = new List<Task>(); //i.e. to cancel
                for(Account accObj : validAccountsToUpdate){
                    List<String> requestedDeliveryDays = accObj.Requested_Delivery_Days__c.split(';');
                    String deliveryFrequency = accObj.Delivery_Frequency_Type__c;

                    if(accobj.Sell_Type__c != 'INSIDE SALES' && accobj.Sell_Type__c != 'NATIONAL ACCTS'){
                        if(taskCallAccountMap.containsKey(accObj.Id)){
                            for(Task taskObj : taskCallAccountMap.get(accObj.Id)){
                                if(taskObj.ActivityDate >= System.today()){
                                    taskObj.Status = 'Cancelled';
                                    tasksToUpdate.add(taskObj);
                                }
                            }
                        }
                    }

                    if(accobj.Sell_Type__c == 'INSIDE SALES' || accobj.Sell_Type__c == 'NATIONAL ACCTS'){
                        //Resetting those the temp start
                        Date tempStartDate = callScheduleStartEndDateWrapperObj.startDate;

                        //As before for delivery dates, Offsetting the tempStartDate according to the delivery frequency - this time to create Tasks
                        if(callScheduleFrequencyMap.containsKey(deliveryFrequency)){
                            tempStartDate = tempStartDate.addDays(Integer.valueOf(callScheduleFrequencyMap.get(deliveryFrequency).Preset_Start_Date__c));
                        }

                        do{
                            if(callScheduleFrequencyMap.containsKey(deliveryFrequency)){
                                if(tempStartDate >= callScheduleStartEndDateWrapperObj.todaysDateWeek){
                                    tasksToInsert.addAll(DateScheduleUtility.returnListOfTasksBasedOnTask(requestedDeliveryDays, tempStartDate , accObj, dayOfTheWeekMap, accountDateStringToDeliveryDateMap, taskCallAccountMap, deliveryFrequency));
                                }
                                tempStartDate = tempStartDate.addDays(Integer.valueOf(callScheduleFrequencyMap.get(deliveryFrequency).Days_To_Advance__c));
                            } else {
                                break;
                            }
                        } while(tempStartDate < callScheduleStartEndDateWrapperObj.endDate);
                    }
                }

                if(!tasksToInsert.isEmpty()){
                    TaskDAO.insertTasks(tasksToInsert);
                }

                if(!tasksToupdate.isEmpty()){
                    TaskDAO.updateTasks(tasksToUpdate);
                }
            }
        } catch(Exception ex){
            ErrorLog.insertErrorLog(ex.getMessage(), String.valueOf(ex.getLineNumber()), 'CallScheduleHandler', 'CallScheduleHandler.checkForUpdatedSellType()');
        }
    }    
}
global class BatchHolidayPlanningDeliveryDate implements Database.Batchable<sObject>,  Database.Stateful{

    public Id callTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId(); 
    public Date originalDate;
    public Boolean selectCities;
    public Boolean summaryOnly;
    public Boolean rescheduleCallsAlso;
    public String rescheduleReason;
    public List<Date> deliveryRescheduleDates = new List<Date>();
    public List<Date> callRescheduleDates = new List<Date>();
    public List<Integer> rescheduledPercentages =  new List<Integer>();
    public String warehouses;
    public String frequencies;
    public String sellTypes;
    public String premises;
    public String userEmail;
    public List<String> citiesList = new List<String>();
    public String planId;
    public String planName;
    public String query;
    public Map<Date,Date> deliveryRescheduleDateToTaskRescheduleDate = new Map<Date,Date>();
    public Map<Id, Date> deliveryIdToDeliveryDate = new Map<Id,Date>();
    public List<Delivery_Date__c> deliveryDatesCombined= new List<Delivery_Date__c>();
    public List<Task> tasksCombined = new List<Task>();
    List<Database.SaveResult> allDeliveryDateSaveResults = new List<Database.SaveResult>();
    List<Database.SaveResult> allTaskSaveResults = new List<Database.SaveResult>();

    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        //Split the warehouses and frequencies
        List<String> warehouseList = new List<String>();
        List<String> frequencyList =  new List<String>();
        List<String> sellTypeList =  new List<String>();
        List<String> premiseList =  new List<String>();

        if(!String.isBlank(warehouses)){
            warehouseList = warehouses.split(';');
        }

        if(!String.isBlank(frequencies)){
            frequencyList = frequencies.split(';');
        }

        if(!String.isBlank(sellTypes)){
            sellTypeList = sellTypes.split(';');
        }

        if(!String.isBlank(premises)){
            premiseList = premises.split(';');
        }

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Delivery_Date__c> deliveryDatesList) {
        List<Delivery_Date__c> deliveryDatesToRedistribute = deliveryDatesList;
        List<Task> tasksToRedistribute = new List<Task>();
        List<Alert__c> alertsToInsert = new List<Alert__c>();
        //Trimming rescheduled Dates and Percentages Lists (null possible from flow)
        List<Date> deliveryRescheduledDatesTrimmed = new List<Date>();
        List<Date> callRescheduleDatesTrimmed = new List<Date>();
        List<Integer> rescheduledPercentagesTrimmed = new List<Integer>();
        Set<Id> accountIds = new Set<Id>();

        for(Date resDate : deliveryRescheduleDates){
            if(resDate != null){
                deliveryRescheduledDatesTrimmed.add(resDate);
            }
        }

        for(Date resDate : callRescheduleDates){
            if(resDate != null){
                callRescheduleDatesTrimmed.add(resDate);
            }
        }

        if(callRescheduleDatesTrimmed.isEmpty()){
            rescheduleCallsAlso = false;
        }

        for(Integer resPercentage : rescheduledPercentages){
            if(resPercentage != null){
                rescheduledPercentagesTrimmed.add(resPercentage);
            }
        }

        for(Delivery_Date__c delivDateObj : deliveryDatesToRedistribute){
            accountIds.add(delivDateObj.Account__c);
        }

        //Placing Calls in Map by Warehouse
        Map<String, List<Delivery_Date__c>> WarehouseToDeliveryDateListMap = new Map<String, List<Delivery_Date__c>>();
        for(Delivery_Date__c delivDate : deliveryDatesToRedistribute){
            if (WarehouseToDeliveryDateListMap.containsKey(delivDate.Account__r.Warehouse__c.trim())){
                WarehouseToDeliveryDateListMap.get(delivDate.Account__r.Warehouse__c.trim()).add(delivDate);
            } else{
                WarehouseToDeliveryDateListMap.put(delivDate.Account__r.Warehouse__c.trim(), new List<Delivery_Date__c>{delivDate});
            }
        }

        Date todaysDate = System.today();
        List<Delivery_Date__c> deliveryDatesExisting = DeliveryDateDAO.getDeliveryDatesAccountDate(accountIds, todaysDate);

        Map<Id, List<Delivery_Date__c>> deliveryDateMap = new Map<Id, List<Delivery_Date__c>>();
        for(Delivery_Date__c delivDateObj : deliveryDatesExisting){
            List<Delivery_Date__c> delivDateList = new List<Delivery_Date__c>();
            if(deliveryDateMap.containsKey(delivDateObj.Account__c)){
                delivDateList = deliveryDateMap.get(delivDateObj.Account__c);
            }
            delivDateList.add(delivDateObj);
            deliveryDateMap.put(delivDateObj.Account__c, delivDateList);
        }


        //Create range list
        for(String warehouse : WarehouseToDeliveryDateListMap.keySet()){
            List<Delivery_Date__c> currentDeliveryDateList = WarehouseToDeliveryDateListMap.get(warehouse);
            Integer deliveryDates = currentDeliveryDateList.size();

            List<Decimal> changePoints = new List<Decimal>{};
            Decimal Total = 0;
            for(Integer i = 0; i<deliveryRescheduledDatesTrimmed.size()-1; i++){
                Decimal changePoint = ((deliveryDates*(rescheduledPercentagesTrimmed[i]*.01))).round(System.RoundingMode.HALF_EVEN);
                Total = Total + changePoint;
                changePoints.add(changePoint);
            }
            //In case there are rounding issues, the last date receives the remainder.
            changePoints.add(deliveryDates-total);
            
            //Going through the tasks and redistributing by corresponding dates
            Integer deliveryDateCount = 0;
            for(Integer k=0; k< changePoints.size(); k++){
                for(Integer j=0; j < changePoints[k]; j++){
                    currentDeliveryDateList[deliveryDateCount].Delivery_Date__c = deliveryRescheduledDatesTrimmed[k];
                    currentDeliveryDateList[deliveryDateCount].Plan__c = planId;
                    currentDeliveryDateList[deliveryDateCount].Reschedule_Reason__c = rescheduleReason;
                    deliveryDateCount=deliveryDateCount+1;
                }
            }
        }

        //Grabbing a list of all the updated Delivery Date and placing in List and Map
        List<Id> successfullyMovedDeliveryIds = new List<Id>();
        List<Delivery_Date__c> existingDeliveryDatesToUpdate = new List<Delivery_Date__c>();
        Map<Id, Date> deliveryIdAlertDateForCancelled = new Map<Id,Date>();
        for(Delivery_Date__c delivDate : deliveryDatesToRedistribute){
            if(deliveryDateMap.containsKey(delivDate.Account__c)){
                Boolean dateExists = false;
                Delivery_Date__c existingDeliveryDay = new Delivery_Date__c();
                Date newDate;
                for(Delivery_Date__c delivDateObj : deliveryDateMap.get(delivDate.Account__c)){
                    if(delivDate.Delivery_Date__c == delivDateObj.Delivery_Date__c){
                        dateExists = true;
                        existingDeliveryDay = delivDateObj;

                        newDate = delivDate.Delivery_Date__c;
                        delivDate.Delivery_Date__c = originalDate;
                        delivDate.Status__c = 'Cancelled';
                        break;
                    }
                }
                if(dateExists){
                    existingDeliveryDatesToUpdate.add(delivDate);
                    deliveryIdAlertDateForCancelled.put(delivDate.Id, newDate);
                    deliveryIdToDeliveryDate.put(delivDate.Id, delivDate.Delivery_Date__c);
                    deliveryIdToDeliveryDate.put(existingDeliveryDay.Id, existingDeliveryDay.Delivery_Date__c);
                } else {
                    deliveryIdToDeliveryDate.put(delivDate.Id, delivDate.Delivery_Date__c);
                }
            } else {
                deliveryIdToDeliveryDate.put(delivDate.Id, delivDate.Delivery_Date__c);
            }
        }

        Map<Id, Delivery_Date__c> existingDeliveryDatesToUpdateMap = new Map<Id, Delivery_Date__c>();
        if(!existingDeliveryDatesToUpdate.isEmpty()){
            for(Delivery_Date__c existingdelivDateObj : existingDeliveryDatesToUpdate){
                existingDeliveryDatesToUpdateMap.put(existingdelivDateObj.Id, existingdelivDateObj);
            }
        }

        //Committing the updates
        if(deliveryDatesToRedistribute.size()>0){
            List<Database.SaveResult> ddSaveResult = database.update(deliveryDatesToRedistribute,false);
            allDeliveryDateSaveResults.addAll(ddSaveResult);

            //We would only want to move the calls where the Delivery Date was moved
            for(Database.SaveResult deliveryDateSR : allDeliveryDateSaveResults){
                if(deliveryDateSR.isSuccess()){
                    successfullyMovedDeliveryIds.add(deliveryDateSR.getId());
                }
            }
        }

        //Next, if they also reschedule corresponding calls, get the corresponding call tasks 
        //and set the activity date according to the respective delivery dates entered call date
        if(rescheduleCallsAlso){

            //Get the tasks which reference the Delivery Dates
            tasksToRedistribute = TaskDAO.getTasksByDeliveryIds(successfullyMovedDeliveryIds);

            //Build a map converting delivery date to call date
            for(Integer i = 0; i<deliveryRescheduledDatesTrimmed.size(); i++){
                deliveryRescheduleDateToTaskRescheduleDate.put(deliveryRescheduledDatesTrimmed[i], callRescheduleDatesTrimmed[i]);
            }

            //Cycle through the tasks, updating the corresponding activity date
            for(Task tsk : tasksToRedistribute){
                if(existingDeliveryDatesToUpdateMap.containsKey(tsk.Delivery_Date__c)){
                    tsk.Status = 'Cancelled';
                    tsk.Reschedule_Reason__c = rescheduleReason;
                    tsk.Plan__c = planId;
                } else {
                    //add logic for cancelling task if delivery date already exists and add plan to that task for revert
                    tsk.ActivityDate = deliveryRescheduleDateToTaskRescheduleDate.get(deliveryIdToDeliveryDate.get(tsk.Delivery_Date__c));
                    tsk.Reschedule_Reason__c = rescheduleReason;
                    tsk.Plan__c = planId;
                }
            }
        }

        List<Alert__c> existingAlerts = AlertDAO.getAlertsByAccountAndPlan(accountIds, planId);
        Map<Id, String> alertPlanMap = new Map<Id, String>();
        for(Alert__c alertObj : existingAlerts){
            alertPlanMap.put(alertObj.Account__c, planId);
        }

        //Create Alerts for the changes
        for(Delivery_Date__c dd: deliveryDatesToRedistribute){
            if(!alertPlanMap.containsKey(dd.Account__c)){
            Alert__c newAlert = new Alert__c();
            if(!deliveryIdAlertDateForCancelled.containsKey(dd.Id)){
                newAlert.Start_Date__c = dd.Delivery_Date__c.addDays(-40);
                newAlert.End_Date__c = dd.Delivery_Date__c;
            } else {
                newAlert.Start_Date__c = deliveryIdAlertDateForCancelled.get(dd.Id).addDays(-40);
                newAlert.End_Date__c = deliveryIdAlertDateForCancelled.get(dd.Id);
            }
            newAlert.Account__c = dd.Account__c;
            newAlert.Account_Alert__c = true;
            newAlert.Alert_Message__c = 'This customer is impacted by the upcoming holiday. Please communicate holiday schedule.';
            newAlert.Plan__c = planId;
            alertsToInsert.add(newAlert);
        }
        }

        if(tasksToRedistribute.size()>0){
            List<Database.SaveResult> taskSaveResult = database.update(tasksToRedistribute,false);
            allTaskSaveResults.addAll(taskSaveResult);
        }

        if(alertsToInsert.size()>0){
            List<Database.SaveResult> alertServeResult = database.insert(alertsToInsert, false);
        }

        deliveryDatesCombined.addAll(deliveryDatesToRedistribute);
        tasksCombined.addAll(tasksToRedistribute);
    }

    global void finish(Database.BatchableContext BC) {
        Set<id> successfulTaskIdSet = new Set<Id>();
        Set<id> successfulDeliveryDateIdsSet = new Set<Id>();
        List<Task> successfulTaskMoves = new List<Task>();
        List<Delivery_Date__c> successfulDeliveryDateMoves = new List<Delivery_Date__c>(); 

        for(Database.SaveResult deliveryDateSR : allDeliveryDateSaveResults){
            if(deliveryDateSR.isSuccess()){
                successfulDeliveryDateIdsSet.add(deliveryDateSR.getId());
            }
        }

        for(Database.SaveResult taskSR : allTaskSaveResults){
            if(taskSR.isSuccess()){
                successfulTaskIdSet.add(taskSR.getId());
            }
        }

        for(Delivery_Date__c dd : deliveryDatesCombined){
            if(successfulDeliveryDateIdsSet.contains(dd.Id)){
                successfulDeliveryDateMoves.add(dd);
            }
        }

        for(Task tsk: tasksCombined){
            if(successfulTaskIdSet.contains(tsk.Id)){
                successfulTaskMoves.add(tsk);
            }
        }

        String deliveryDateBreakdown = HolidayPlanningUtility.createDeliveryDateResultsString('Delivery Date Results', successfulDeliveryDateMoves);
        String taskBreakdown = HolidayPlanningUtility.createCallTaskResultsString('Task Results', successfulTaskMoves);

        List<Messaging.EmailFileAttachment> fileAttachments = new List<Messaging.EmailFileAttachment>();

        List<String> taskErrorStrings = CSVImportExport.createErrorStrings(allTaskSaveResults);

        if(taskErrorStrings.size()>0){
            String taskStringsJoined = String.join(taskErrorStrings,'\n');
            Messaging.EmailFileAttachment taskErrorsAttachment = new Messaging.EmailFileAttachment();
            Blob taskErrorsBlob = Blob.valueOf(taskStringsJoined);
            taskErrorsAttachment.setFileName('taskUpdateErrors.csv');
            taskErrorsAttachment.setBody(taskErrorsBlob);
            fileAttachments.add(taskErrorsAttachment);
        }

        List<String> deliveryDateErrorStrings = CSVImportExport.createErrorStrings(allDeliveryDateSaveResults);

        if(DeliveryDateErrorStrings.size()>0){
            String deliveryDateStringsJoined = String.join(deliveryDateErrorStrings,'\n');
            Messaging.EmailFileAttachment deliveryDateErrorsAttachment = new Messaging.EmailFileAttachment();
            Blob deliveryDateErrorsBlob = Blob.valueOf(deliveryDateStringsJoined);
            deliveryDateErrorsAttachment.setFileName('DeliveryDateUpdateErrors.csv');
            deliveryDateErrorsAttachment.setBody(deliveryDateErrorsBlob);
            fileAttachments.add(deliveryDateErrorsAttachment);
        }

        Integer deliveryDatesCombinedCount = deliveryDatesCombined.size();
        Integer tasksCombinedCount = tasksCombined.size();

        Integer successfulDeliveryDateMovesCount = successfulDeliveryDateMoves.size();
        Integer successfulTaskMovesCount = successfulTaskMoves.size();

        String emailSubject = ' Holiday Planning Results Plan: ' + planName;
        String emailBody = '<b><u>' + planName + ' Results</u></b> \n\n';
        if(deliveryDatesCombinedCount > 0){
            emailBody += '<p> <b>' + successfulDeliveryDateMovesCount + ' out of ' + deliveryDatesCombinedCount + '</b> Delivery Dates were successfully moved. </p>';
        }
        if(tasksCombinedCount > 0){
            emailBody += '<p> <b>' + successfulTaskMovesCount + ' out of ' + tasksCombinedCount + '</b> Calls were successfully moved. </p>';
        }
        emailBody += deliveryDateBreakdown;
        emailBody += taskBreakdown;
        if(deliveryDateErrorStrings.size()>0){
            emailBody += '<p>' + deliveryDateErrorStrings.size() + ' Delivery Dates could not be updated due to technical errors.  Please see the corresponding attachment for more details. </p>';
        }
        if(taskErrorStrings.size()>0){
            emailBody +='<p>' +  taskErrorStrings.size() + ' Call Tasks could not be updated due to technical errors.  Please see the corresponding attachment for more details. </p>';
        }
        
        //Send the Email
        HolidayPlanningUtility.sendHolidayPlanningEmail(userEmail, emailSubject, emailBody, fileAttachments);        
    }
}
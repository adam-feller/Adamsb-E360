global class BatchHolidayPlanningTask implements Database.Batchable<sObject>,  Database.Stateful{

    public Id callTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId(); 
    public Date originalDate;
    public Boolean selectCities;
    public String rescheduleReason;
    public List<Date> callRescheduleDates = new List<Date>();
    public List<Integer> rescheduledPercentages =  new List<Integer>();
    public String warehouses;
    public String frequencies;
    public String userEmail;
    public String sellTypes;
    public String premises;
    public List<String> citiesList = new List<String>();
    public String planId;
    public String planName;
    public String query;
    public List<Task> tasksCombined = new List<Task>();
    List<Database.SaveResult> allTaskSaveResults = new List<Database.SaveResult>();

    global Database.QueryLocator start(Database.BatchableContext BC) {
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

    global void execute(Database.BatchableContext BC, List<Task> tasksList) {
        List<Task> tasksToRedistribute = tasksList;
        List<Alert__c> alertsToInsert = new List<Alert__c>();
        //Trimming rescheduled Dates and Percentages Lists (null possible from flow)
        List<Date> rescheduledDatesTrimmed = new List<Date>();
        List<Integer> rescheduledPercentagesTrimmed = new List<Integer>();
        Set<Id> accountIds = new Set<Id>();

        for(Date resDate : callRescheduleDates){
            if(resDate != null){
                rescheduledDatesTrimmed.add(resDate);
            }
        }

        for(Integer resPercentage : rescheduledPercentages){
            if(resPercentage != null){
                rescheduledPercentagesTrimmed.add(resPercentage);
            }
        }

        //Placing Tasks in Map by Warehouse
        Map<String, List<Task>> WarehouseToTaskListMap = new Map<String, List<Task>>();
        for(Task tsk : tasksToRedistribute){
            if (WarehouseToTaskListMap.containsKey(tsk.Warehouse__c.trim())){
                WarehouseToTaskListMap.get(tsk.Warehouse__c.trim()).add(tsk);
            } else{
                WarehouseToTaskListMap.put(tsk.Warehouse__c.trim(), new List<Task>{tsk});
            }
        }

        //Create range list
        for(String warehouse : WarehouseToTaskListMap.keySet()){
            List<Task> currentTaskList = WarehouseToTaskListMap.get(warehouse);
            Integer tasksTotal = currentTaskList.size();
            List<Decimal> changePoints = new List<Decimal>{};
            Decimal Total = 0;
            for(Integer i = 0; i<rescheduledDatesTrimmed.size()-1; i++){
                Decimal changePoint = ((tasksTotal*(rescheduledPercentagesTrimmed[i]*.01))).round(System.RoundingMode.HALF_EVEN);
                Total = Total + changePoint;
                changePoints.add(changePoint);
            }
            //In case there are rounding issues, the last date receives the remainder.
            changePoints.add(tasksTotal-total);

            //Going through the tasks and redistributing by corresponding dates
            Integer taskCount = 0;
            for(Integer k=0; k< changePoints.size(); k++){
                for(Integer j=0; j < changePoints[k]; j++){
                        currentTaskList[taskCount].activityDate = rescheduledDatesTrimmed[k];
                        currentTaskList[taskCount].Reschedule_Reason__c = rescheduleReason;
                        currentTaskList[taskCount].Plan__c = planId;
                        taskCount=taskCount+1;
                }
            }
        }

        //Grabbing a list of all the updated Task Dates and placing in List and Map
        List<Id> successfullyMovedTaskIds = new List<Id>();
        Map<Id, Date> taskIdToTaskDate = new Map<Id,Date>();
        for(Task tsk : tasksToRedistribute){
            taskIdToTaskDate.put(tsk.Id, tsk.ActivityDate);
            accountIds.add(tsk.Account__c);
        }

        //Committing the updates
        if(tasksToRedistribute.size()>0){
            List<Database.SaveResult> taskSaveResult = database.update(tasksToRedistribute,false);
            allTaskSaveResults.addAll(taskSaveResult);

            //We would only want to move the calls where the Delivery Date was moved
            for(Database.SaveResult taskSR : allTaskSaveResults){
                if(taskSR.isSuccess()){
                    successfullyMovedTaskIds.add(taskSR.getId());
                }
            }
        }

        List<Alert__c> existingAlerts = AlertDAO.getAlertsByAccountAndPlan(accountIds, planId);
        Map<Id, String> alertPlanMap = new Map<Id, String>();
        for(Alert__c alertObj : existingAlerts){
            alertPlanMap.put(alertObj.Account__c, planId);
        }

        //Create Alerts for the changes
        for(Task tsk: tasksToRedistribute){
            if(tsk.Delivery_Date__c != null){
                if(!alertPlanMap.containsKey(tsk.Account__c)){
                    Alert__c newAlert = new Alert__c();
                    newAlert.Start_Date__c = tsk.Delivery_Date__r.Delivery_Date__c.addDays(-40);
                    newAlert.End_Date__c = tsk.Delivery_Date__r.Delivery_Date__c;
                    newAlert.Account__c = tsk.Account__c;
                    newAlert.Account_Alert__c = true;
                    newAlert.Alert_Message__c = 'This customer is impacted by the upcoming holiday. Please communicate holiday schedule.';
                    newAlert.Plan__c = planId;
                    alertsToInsert.add(newAlert);
                }
            }
        }

        List<Database.SaveResult> taskSaveResult = database.insert(alertsToInsert, false);
        tasksCombined.addAll(tasksToRedistribute);
    }

    global void finish(Database.BatchableContext BC) {
        Set<id> successfulTaskIdSet = new Set<Id>();
        List<Task> successfulTaskMoves = new List<Task>();

        for(Database.SaveResult taskSR : allTaskSaveResults){
            if(taskSR.isSuccess()){
                successfulTaskIdSet.add(taskSR.getId());
            }
        }

        for(Task tsk: tasksCombined){
            if(successfulTaskIdSet.contains(tsk.Id)){
                successfulTaskMoves.add(tsk);
            }
        }
        
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

        Integer tasksCombinedCount = tasksCombined.size();

        Integer successfulTaskMovesCount = successfulTaskMoves.size();

        String emailSubject = ' Holiday Planning Results Plan: ' + planName;

        String emailBody = '<b><u>' + planName + ' Results</u></b> \n\n';

        if(tasksCombinedCount > 0){
            emailBody += '<p> <b>' + successfulTaskMovesCount + ' out of ' + tasksCombinedCount + '</b> Calls were successfully moved. </p>';
        }
        emailBody += taskBreakdown;

        if(taskErrorStrings.size()>0){
            emailBody +='<p>' +  taskErrorStrings.size() + ' Call Tasks could not be updated due to technical errors.  Please see the corresponding attachment for more details. </p>';
        }
        
        //Send the Email
        HolidayPlanningUtility.sendHolidayPlanningEmail(userEmail, emailSubject, emailBody, fileAttachments);
    }
}
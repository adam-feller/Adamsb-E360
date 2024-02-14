global class BatchHolidayPlanningReversionTask implements Database.Batchable<sObject>,  Database.Stateful{
    public String planId;
    public String planName;
    public String userEmail;
    public String warehouses;
    
    public String query;

    public List<Task> tasksCombined= new List<Task>();

    List<Database.SaveResult> allTaskSaveResults = new List<Database.SaveResult>();


    global Database.QueryLocator start(Database.BatchableContext BC) {

        //Split the warehouses and frequencies
        List<String> warehouseList = new List<String>();

        if(!String.isBlank(warehouses)){
                warehouseList = warehouses.split(';');
            }
    
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Task> tasksToRevert) {
        tasksCombined.addAll(tasksToRevert);

        //Grabbing a list of all the updated Delivery Date and placing in List and Map
        List<Id> successfullyMovedTaskIds = new List<Id>();
       
        for(Task tsk : tasksToRevert){
            if(tsk.Status == 'Cancelled'){
                tsk.Status = 'Open';
            }
            tsk.ActivityDate = tsk.Original_Call_Date__c;
            tsk.Reschedule_Reason__c = null;
            tsk.Plan__c = null;
        }

        if(tasksToRevert.size()>0){
            List<Database.SaveResult> taskSaveResult = database.update(tasksToRevert,false);
            allTaskSaveResults.addAll(taskSaveResult);
        }

    }   
    
    global void finish(Database.BatchableContext BC) {

        Set<id> successfulTaskIdsSet = new Set<Id>();

        List<Task> successfulTaskMoves = new List<Task>(); 

        for(Database.SaveResult taskSR : allTaskSaveResults){
            if(taskSR.isSuccess()){
                successfulTaskIdsSet.add(taskSR.getId());
            }
        }

        for(Task tsk : tasksCombined){
            if(successfulTaskIdsSet.contains(tsk.Id)){
                successfulTaskMoves.add(tsk);
            }
        }
        
        String tasKBreakdown = HolidayPlanningUtility.createCallTaskResultsString('Task Reversion Results', successfulTaskMoves);

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

        Integer succesfulTaskMovesCount = successfulTaskMoves.size();

        String emailSubject = ' Holiday Planning Results Plan Reversion (Tasks): ' + planName;

        String emailBody = '<b><u>' + planName + ' Results</u></b> \n\n';
        if(tasksCombinedCount > 0){
            emailBody += '<p> <b>' + succesfulTaskMovesCount + ' out of ' + tasksCombinedCount + '</b> Tasks were successfully reverted. </p>';
        }

        emailBody += taskBreakdown;
        if(taskErrorStrings.size()>0){
            emailBody += '<p>' + taskErrorStrings.size() + ' Tasks could not be updated due to technical errors.  Please see the corresponding attachment for more details. </p>';
        }

        //Send the Email
        HolidayPlanningUtility.sendHolidayPlanningEmail(userEmail, emailSubject, emailBody, fileAttachments);
	}
}
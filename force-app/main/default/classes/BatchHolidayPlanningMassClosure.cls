global class BatchHolidayPlanningMassClosure implements Database.Batchable<sObject>,  Database.Stateful{
    public Id callTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId(); 
    public Date originalDate;
    public String warehouses;
    public String frequencies;

    public String sellTypes;
    public String premises;

    public String userEmail;
    public List<String> citiesList = new List<String>();

    public String query;

    public List<Task> tasksCombined = new List<Task>();

    List<Database.SaveResult> allTaskSaveResults = new List<Database.SaveResult>();

    global Database.QueryLocator start(Database.BatchableContext BC) {
        //Split the Warehouses, Frequencies, Sell Types and Premises
        List<String> warehouseList = new List<String>();
        List<String> frequencyList =  new List<String>();
        List<String> sellTypeList =  new List<String>();
        List<String> premiseList =  new List<String>();

        if (!String.isBlank(warehouses)) {
        	warehouseList = warehouses.split(';');
        }
    
        if (!String.isBlank(frequencies)) {
        	frequencyList = frequencies.split(';');
        }         

        if (!String.isBlank(sellTypes)) {
            sellTypeList = sellTypes.split(';');
        } 
        
        if (!String.isBlank(premises)) {
            premiseList = premises.split(';');
        } 
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Task> tasksToClose) {
        //Grabbing a list of all the updated Task Dates and placing in List and Map
        List<Id> successfullyClosedTaskIds = new List<Id>();

        for(Task tsk : tasksToClose){
            tsk.Status = 'No Call Needed';
        }

        //Committing the updates
        if(tasksToClose.size()>0){
            List<Database.SaveResult> taskSaveResult = database.update(tasksToClose,false);
            allTaskSaveResults.addAll(taskSaveResult);
        }

        tasksCombined.addAll(tasksToClose);
    }   
    
    global void finish(Database.BatchableContext BC) {
        Set<id> successfulTaskIdSet = new Set<Id>();

        List<Task> succesfullTaskClose = new List<Task>();

        for(Database.SaveResult taskSR : allTaskSaveResults){
            if(taskSR.isSuccess()){
                successfulTaskIdSet.add(taskSR.getId());
            }
        }

        for(Task tsk: tasksCombined){
            if(successfulTaskIdSet.contains(tsk.Id)){
                succesfullTaskClose.add(tsk);
            }
        }
        
        String taskBreakdown = HolidayPlanningUtility.createCallTaskResultsString('Task Closure Results', succesfullTaskClose);

        List<Messaging.EmailFileAttachment> fileAttachments = new List<Messaging.EmailFileAttachment>();

        List<String> taskErrorStrings = CSVImportExport.createErrorStrings(allTaskSaveResults);

        if (taskErrorStrings.size() > 0) {
            String taskStringsJoined = String.join(taskErrorStrings,'\n');
            Messaging.EmailFileAttachment taskErrorsAttachment = new Messaging.EmailFileAttachment();
            Blob taskErrorsBlob = Blob.valueOf(taskStringsJoined);
            taskErrorsAttachment.setFileName('taskUpdateErrors.csv');
            taskErrorsAttachment.setBody(taskErrorsBlob);
            fileAttachments.add(taskErrorsAttachment);
        }

        Integer tasksCombinedCount = tasksCombined.size();

        Integer succesfullTaskCloseCount = succesfullTaskClose.size();

        String emailSubject = ' Holiday Planning Mass Closure';

        String emailBody = '<b><u> Mass Closure Results</u></b> \n\n';

        if (tasksCombinedCount > 0) {
            emailBody += '<p> <b>' + succesfullTaskCloseCount + ' out of ' + tasksCombinedCount + '</b> Calls were successfully closed. </p>';
        }
        emailBody += taskBreakdown;

        if (taskErrorStrings.size() > 0) {
            emailBody +='<p>' +  taskErrorStrings.size() + ' Call Tasks could not be updated due to technical errors.  Please see the corresponding attachment for more details. </p>';
        }

        //Send the Email
        HolidayPlanningUtility.sendHolidayPlanningEmail(userEmail, emailSubject, emailBody, fileAttachments);
	}
}
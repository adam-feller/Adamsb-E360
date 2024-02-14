global class BatchMassUpdateDeliveryAndCallTaskDates implements Database.Batchable<sObject> , Database.Stateful {
    public Map<String, CSVImportExport.DeliveryDateWrapper> externalIdToNewDeliveryDate = new Map<String, CSVImportExport.DeliveryDateWrapper>();
    public Set<String> externalIdList = new Set<String>();
    public String planName;
    public String userEmail;
    public String planId;
    public String query;

    List<Database.SaveResult> allTaskSaveResults = new List<Database.SaveResult>();
    List<Database.SaveResult> allDeliveryDateSaveResults = new List<Database.SaveResult>();


    global Database.QueryLocator start( Database.BatchableContext BC ) {
        return Database.getQueryLocator( query );
    }

    global void execute( Database.BatchableContext BC, List<Delivery_Date__c> deliveryDateList) { 
        try {
            //List of Alerts__c for National Accts and Inside Sales
            List<Alert__c> alertsToInsert = new List<Alert__c>();


            //Put all the externalIds in a list
            List<String> deliveryDateIdList = new List<String>();

            for (Delivery_Date__c dd: deliveryDateList) {
                deliveryDateIdList.add(dd.Id);
            }

            //get the corresponding tasks by external Id
            List<Task> taskList = [SELECT Id, ActivityDate, Delivery_Date__c, Delivery_Date__r.External_Id__c FROM Task WHERE Delivery_Date__c IN :deliveryDateIdList];

            //cycle through the tasks and set the Activity Date to the New Call Date (if Not Null)
            for(Task tsk : taskList) {
                Date newCallDate;
                if (externalIdToNewDeliveryDate.get(tsk.Delivery_Date__r.External_Id__c) != null) {
                 	newCallDate = externalIdToNewDeliveryDate.get(tsk.Delivery_Date__r.External_Id__c).NewCallDate != null ? Date.parse(externalIdToNewDeliveryDate.get(tsk.Delivery_Date__r.External_Id__c).NewCallDate) : null;
                } else {
                    newCallDate = null;
                }
                
                if (newCallDate != null) {
                    tsk.ActivityDate = newCallDate;
                    tsk.Plan__c = planId;
                }
            }

           List<Database.SaveResult> taskSaveResults = database.update(taskList, false);
           allTaskSaveResults.addAll(taskSaveResults);

            //Cycle through the batch results, setting the delivery date by getting the  the corresponding New Delivery date from the map

            for (Delivery_Date__c dd : deliveryDateList ) {
                Date newDeliveryDate;
                if (externalIdToNewDeliveryDate.get(dd.External_Id__c) != null) {
                 	newDeliveryDate = externalIdToNewDeliveryDate.get(dd.External_Id__c).NewDeliveryDate != null ? Date.parse(externalIdToNewDeliveryDate.get(dd.External_Id__c).NewDeliveryDate) : null;
                } else {
                    newDeliveryDate = null;
                }                

                if(newDeliveryDate != null){
                    dd.Delivery_Date__c = newDeliveryDate;
                    dd.Plan__c = planId;
                    //Remove the entry from map
                    externalIdToNewDeliveryDate.remove(dd.External_Id__c);
                    if (dd.Account__r.Sell_Type__c == 'NATIONAL ACCTS' || dd.Account__r.Sell_Type__c == 'INSIDE SALES') {
                        Alert__c newAlert = new Alert__c();
                        newAlert.Start_Date__c = dd.Delivery_Date__c.addDays(-40);
                        newAlert.End_Date__c = dd.Delivery_Date__c;
                        newAlert.Account__c = dd.Account__c;
                        newAlert.Account_Alert__c = true;
                        newAlert.Alert_Message__c = 'This customer is impacted by the upcoming holiday. Please communicate holiday schedule.';
                        newAlert.Plan__c = planId;
                        alertsToInsert.add(newAlert);
                    }
                }
            }
            insert alertsToInsert;

            List<Database.SaveResult> deliveryDateSaveResults = database.update(deliveryDateList, false);
            allDeliveryDateSaveResults.addAll(deliveryDateSaveResults);
            //In the finish statement, send an email of any error and remaining items in the map
        } catch(Exception ex) {
            ErrorLog.insertErrorLog(ex.getMessage(), String.valueOf(ex.getLineNumber()), 'BatchMassUpdateDeliveryAndCallTaskDates', 'execute()');
        }
    }   
    
    global void finish( Database.BatchableContext BC ) {

        List<Messaging.EmailFileAttachment> fileAttachments = new List<Messaging.EmailFileAttachment>();

        List<String> taskErrorStrings = CSVImportExport.createErrorStrings(allTaskSaveResults);

        if(taskErrorStrings.size() > 0){
            String taskStringsJoined = String.join(taskErrorStrings,'\n');
            Messaging.EmailFileAttachment taskErrorsAttachment = new Messaging.EmailFileAttachment();
            Blob taskErrorsBlob = Blob.valueOf(taskStringsJoined);

            taskErrorsAttachment.setFileName('taskUpdateErrors.csv');

            taskErrorsAttachment.setBody(taskErrorsBlob);
            fileAttachments.add(taskErrorsAttachment);
        }

        List<String> deliveryDateErrorStrings = CSVImportExport.createErrorStrings(allDeliveryDateSaveResults);

        if(DeliveryDateErrorStrings.size() > 0){
            String deliveryDateStringsJoined = String.join(deliveryDateErrorStrings,'\n');
            Messaging.EmailFileAttachment deliveryDateErrorsAttachment = new Messaging.EmailFileAttachment();
            Blob deliveryDateErrorsBlob = Blob.valueOf(deliveryDateStringsJoined);

            deliveryDateErrorsAttachment.setFileName('DeliveryDateUpdateErrors.csv');

            deliveryDateErrorsAttachment.setBody(deliveryDateErrorsBlob);
            fileAttachments.add(deliveryDateErrorsAttachment);
        }

        List<String> unfoundErrorStrings = CSVImportExport.createUnfoundString(externalIdToNewDeliveryDate);

        if(unfoundErrorStrings.size() > 0){
            String unfoundErrorStringsJoined = String.join(unfoundErrorStrings,'\n');
            Messaging.EmailFileAttachment unfoundErrorsAttachment = new Messaging.EmailFileAttachment();
            Blob unfoundErrorsBlob = Blob.valueOf(unfoundErrorStringsJoined);

            unfoundErrorsAttachment.setFileName('UnfoundErrors.csv');

            unfoundErrorsAttachment.setBody(unfoundErrorsBlob);
            fileAttachments.add(unfoundErrorsAttachment);
        }

        Integer totalDeliveryDatesUpdated = externalIdList.size() - externalIdToNewDeliveryDate.keySet().size() - deliveryDateErrorStrings.size();

        String emailSubject = PlanName + ' Update Results';
        String emailBody = '<p>' + totalDeliveryDatesUpdated + ' Delivery Dates (and corresponding tasks if indicated) were successfully updated. </p>';
        if(externalIdToNewDeliveryDate.keySet().size()>0){
            emailBody += '<p>' + externalIdToNewDeliveryDate.keySet().size()+ ' Delivery Dates could not be found.  Please see the corresponding attachment for more details. </p>';
        }
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
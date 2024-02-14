global class BatchInsertNewDeliveryDates implements Database.Batchable<sObject> , Database.Stateful{
    public Map<String, List<CSVImportExport.DeliveryDateWrapper>> externalIdToNewDeliveryDate = new Map<String, List<CSVImportExport.DeliveryDateWrapper>>();
    public Set<String> externalIdList = new Set<String>();
    public Integer externalIdListSize;
    public Id retailAccountRecordTypeId;
    public String userEmail;
    public String query;
    public Boolean callsInserted = false;
    public Integer numDelivDups = 0;
    public Integer numCallDups = 0;
	public List<Delivery_Date__c> deliveryDatesAlreadyExistList = new List<Delivery_Date__c>();	
    public List<Task> callTasksAlreadyExistList = new List<Task>();
    public Integer numTasksInserted = 0;
    
    List<Database.SaveResult> deliveryDateSaveResults = new List<Database.SaveResult>();
    List<Database.SaveResult> deliveryDateUpdateResults = new List<Database.SaveResult>();
    List<Database.SaveResult> taskInsertResults = new List<Database.SaveResult>();
    List<Database.SaveResult> taskUpdateResults = new List<Database.SaveResult>();

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> accountList) {
        try {
            Set<Id> accountIds = new Set<Id>();
            for(Account accObj : accountList){
                accountIds.add(accObj.Id);
            }

            Date todaysDate = System.today();

            //Create a Map of all the Future Cancelled Delivery Dates by Account
            List<Delivery_Date__c> deliveryDatesExistingCancelled = DeliveryDateDAO.getDeliveryDatesAccountDateStatus(accountIds, todaysDate, 'Cancelled');
            Map<Id, List<Delivery_Date__c>> deliveryDateCancelledMap = new Map<Id, List<Delivery_Date__c>>();
            for(Delivery_Date__c delivDateObj : deliveryDatesExistingCancelled){
                List<Delivery_Date__c> delivDateList = new List<Delivery_Date__c>();
                if(deliveryDateCancelledMap.containsKey(delivDateObj.Account__c)){
                    delivDateList = deliveryDateCancelledMap.get(delivDateObj.Account__c);
                }
                delivDateList.add(delivDateObj);
                deliveryDateCancelledMap.put(delivDateObj.Account__c, delivDateList);
            }
            //Create a Map of all the Future Active Delivery Dates by Account
            List<Delivery_Date__c> deliveryDatesExistingActive = DeliveryDateDAO.getDeliveryDatesAccountDateStatus(accountIds, todaysDate, 'Active');
            Map<Id, List<Delivery_Date__c>> deliveryDateActiveMap = new Map<Id, List<Delivery_Date__c>>();
            for(Delivery_Date__c delivDateObj : deliveryDatesExistingActive){
                List<Delivery_Date__c> delivDateList = new List<Delivery_Date__c>();
                if(deliveryDateActiveMap.containsKey(delivDateObj.Account__c)){
                    delivDateList = deliveryDateActiveMap.get(delivDateObj.Account__c);
                }
                delivDateList.add(delivDateObj);
                deliveryDateActiveMap.put(delivDateObj.Account__c, delivDateList);
            }

            List<Delivery_Date__c> deliveryDatesToInsertList = new List<Delivery_Date__c>();
            List<Delivery_Date__c> deliveryDatesToUpdateList = new List<Delivery_Date__c>();   
            List<Task> callTasksToInsertList = new List<Task>();
            List<Account> accountsToUpdate = new List<Account>();
            //DELIVERY DATES
            //Cycle through the batch results, setting the delivery date by getting the corresponding New Delivery date from the map
            for (Account accObj : accountList) {
                System.debug('processing ' + accObj.ExternalId__c);
                if (externalIdToNewDeliveryDate.containsKey(accObj.ExternalId__c)) {
                    List<Date> deliveryDatesInserted = new List<Date>();
                    for (CSVImportExport.DeliveryDateWrapper delivWrapperObj : externalIdToNewDeliveryDate.get(accObj.ExternalId__c)) {
                        Date newDeliveryDate = delivWrapperObj.NewDeliveryDate != null ? Date.parse(delivWrapperObj.NewDeliveryDate) : null;
                        if (newDeliveryDate != null) {
                            Boolean updateDeliveryDate = false;
                            //Check the cancelled map and if it exists, update the Cancelled Delivery Date to Active
                            if(deliveryDateCancelledMap.containsKey(accObj.Id)){
                                for(Delivery_Date__c delivDateObj : deliveryDateCancelledMap.get(accObj.Id)){
                                    if(newDeliveryDate == delivDateObj.Delivery_Date__c){
                                        deliveryDatesInserted.add(newDeliveryDate);
                                        Delivery_Date__c updateExistingDeliveryDateObj = new Delivery_Date__c();
                                        updateExistingDeliveryDateObj.Id = delivDateObj.Id;
                                        updateExistingDeliveryDateObj.Status__c = 'Active';
                                        deliveryDatesToUpdateList.add(updateExistingDeliveryDateObj);
                                        updateDeliveryDate = true;
                                        break;
                                    }
                                }
                            }
							//Check the Active map and if it exists, we do nothing except keep track that it was already Active
                            if(deliveryDateActiveMap.containsKey(accObj.Id)){
                                for(Delivery_Date__c delivDateObj : deliveryDateActiveMap.get(accObj.Id)){
                                    if(newDeliveryDate == delivDateObj.Delivery_Date__c){
                                        deliveryDatesAlreadyExistList.add(delivDateObj);
                                        updateDeliveryDate = true;
                                        break;
                                    }
                                }
                            }
                            //If the Delivery Date didn't already exist (Active/Cancelled) then create new
                            if (!updateDeliveryDate) {
                                //First check to see if this is a duplicate entry in the file
                                Boolean fndDelDat = false;
                                for (Delivery_Date__c dd : deliveryDatesToInsertList) {                                    
                                    if (dd.Account__c == accObj.Id && dd.Delivery_Date__c == newDeliveryDate) {
                                        //This is a duplicate, don't insert
                                        numDelivDups += 1;
                                        fndDelDat = true;                                     
                                    }
                                }
                                if (fndDelDat == false) {
                                	deliveryDatesInserted.add(newDeliveryDate);
                                	Delivery_Date__c newDeliveryDateObj = new Delivery_Date__c();
                                	newDeliveryDateObj.Account__c = accObj.Id;
                                	newDeliveryDateObj.Delivery_Date__c = newDeliveryDate;
                                	newDeliveryDateObj.Original_Delivery_Date__c = newDeliveryDate;
                                	deliveryDatesToInsertList.add(newDeliveryDateObj);
                                }
                            }
                        }
                    }

                    Account tempAccount = new Account();
                    tempAccount.Id = accObj.Id;
                    if (deliveryDatesInserted.size() > 0) {
                    	tempAccount.Presell_Inserted_Dates__c = String.valueOf(deliveryDatesInserted);
                    }
                    accountsToUpdate.add(tempAccount);
                }
            }

            deliveryDateSaveResults = Database.insert(deliveryDatesToInsertList, false);
            deliveryDateUpdateResults = Database.update(deliveryDatesToUpdateList, false);

            List<Database.SaveResult> fullDeliveryChangeList = new List<Database.SaveResult>();
            fullDeliveryChangeList.addALL(deliveryDateSaveResults);
            fullDeliveryChangeList.addALL(deliveryDateUpdateResults);

            //Get a Set of Ids that were inserted or already existed
            Set<Id> deliveryDateIds = new Set<Id>();
            for (Database.SaveResult SaveResult : fullDeliveryChangeList){
                if (saveResult.isSuccess() == true){
                    deliveryDateIds.add(saveResult.getId());
                }
            }
            for (Delivery_Date__c dd : deliveryDatesAlreadyExistList) {
                deliveryDateIds.add(dd.Id);
            }

            //Get an updated map of the Delivery Dates that were inserted/already existed
            List<Delivery_Date__c> deliveryDatesInsertedUpdatedList = DeliveryDateDAO.getDeliveryDatesByIds(deliveryDateIds);
            Map<String, Delivery_Date__c> deliveryDateNewlyCreatedUpdateddMap = new Map<String, Delivery_Date__c>();
            for(Delivery_Date__c delivDateObj : deliveryDatesInsertedUpdatedList){
                deliveryDateNewlyCreatedUpdateddMap.put(delivDateObj.Account__c+';'+delivDateObj.Delivery_Date__c, delivDateObj);
            }

            //Process the Calls
            List<Task> existingTasksList = TaskDAO.getTasksByDeliveryIds(deliveryDateIds);
            for (Account accObj : accountList) {
                System.debug('processing calls ' + accObj.ExternalId__c);
                if (externalIdToNewDeliveryDate.containsKey(accObj.ExternalId__c)) {
                    for (CSVImportExport.DeliveryDateWrapper delivWrapperObj : externalIdToNewDeliveryDate.get(accObj.ExternalId__c)) {
                        Date newDeliveryDate = delivWrapperObj.NewDeliveryDate != null ? Date.parse(delivWrapperObj.NewDeliveryDate) : null;
                        Date newCallDate = delivWrapperObj.NewCallDate != null ? Date.parse(delivWrapperObj.NewCallDate) : null;
                        if (newCallDate != null) {
                            if (deliveryDateNewlyCreatedUpdateddMap.containsKey(accObj.Id+';'+newDeliveryDate)) {
                                Delivery_Date__c dd = deliveryDateNewlyCreatedUpdateddMap.get(accObj.Id+';'+newDeliveryDate);
                                //See if the Call Task already exists and if so just update the Status if needed
                                Boolean fndTask = false;
                                for (Task t : existingTasksList) {                                    
                                    if (t.Delivery_Date__c == dd.Id && !t.IsClosed) {
                                		fndTask = true;         
                                        callTasksAlreadyExistList.add(t);
                                    }
                                }
                                if (!fndTask) {
                                	callTasksToInsertList.add(DateScheduleUtility.createTask(accObj, newCallDate, dd));
                                }
                            }
                        }
                    }
                    //Remove the entry from map
                    externalIdToNewDeliveryDate.remove(accObj.ExternalId__c);
                }
            }
            
            if(!callTasksToInsertList.isEmpty()){
                numTasksInserted += callTasksToInsertList.size();
                callsInserted = true;
                taskInsertResults = Database.insert(callTasksToInsertList, false);
            }

            if(!accountsToUpdate.isEmpty()){
                AccountDAO.updateAccounts(accountsToUpdate);
            }
            //In the finish statement, send an email of any error and remaining items in the map
        } catch(Exception ex){
            ErrorLog.insertErrorLog(ex.getMessage(), String.valueOf(ex.getLineNumber()), 'BatchInsertNewDeliveryDates', 'execute()');
        }
    }

    global void finish(Database.BatchableContext BC) {
        List<Messaging.EmailFileAttachment> fileAttachments = new List<Messaging.EmailFileAttachment>();

        List<String> deliveryDateErrorStrings = CSVImportExport.createErrorStrings(deliveryDateSaveResults);
        if (DeliveryDateErrorStrings.size() > 0){
            String deliveryDateStringsJoined = String.join(deliveryDateErrorStrings,'\n');
            Messaging.EmailFileAttachment deliveryDateErrorsAttachment = new Messaging.EmailFileAttachment();
            Blob deliveryDateErrorsBlob = Blob.valueOf(deliveryDateStringsJoined);
            deliveryDateErrorsAttachment.setFileName('DeliveryDateUpdateErrors.csv');
            deliveryDateErrorsAttachment.setBody(deliveryDateErrorsBlob);
            fileAttachments.add(deliveryDateErrorsAttachment);
        }

        List<String> deliveryDateUpdateErrorStrings = CSVImportExport.createErrorStrings(deliveryDateUpdateResults);
        if (deliveryDateUpdateErrorStrings.size() > 0){
            String deliveryDateStringsJoined = String.join(deliveryDateUpdateErrorStrings,'\n');
            Messaging.EmailFileAttachment deliveryDateErrorsAttachment = new Messaging.EmailFileAttachment();
            Blob deliveryDateErrorsBlob = Blob.valueOf(deliveryDateStringsJoined);
            deliveryDateErrorsAttachment.setFileName('DeliveryDateUpdateErrors.csv');
            deliveryDateErrorsAttachment.setBody(deliveryDateErrorsBlob);
            fileAttachments.add(deliveryDateErrorsAttachment);
        }

        List<String> taskErrorStrings = CSVImportExport.createErrorStrings(taskInsertResults);
        if (taskErrorStrings.size() > 0) {
            String taskStringsJoined = String.join(taskErrorStrings,'\n');
            Messaging.EmailFileAttachment taskErrorsAttachment = new Messaging.EmailFileAttachment();
            Blob taskErrorsBlob = Blob.valueOf(taskStringsJoined);
            taskErrorsAttachment.setFileName('TaskInsertErrors.csv');
            taskErrorsAttachment.setBody(taskErrorsBlob);
            fileAttachments.add(taskErrorsAttachment);
        }
        
        System.debug('externalIdToNewDeliveryDate: ' + externalIdToNewDeliveryDate);
        List<String> unfoundErrorStrings = CSVImportExport.createUnfoundStringDeliveryDateNew(externalIdToNewDeliveryDate);

        if (unfoundErrorStrings.size() > 0) {
            String unfoundErrorStringsJoined = String.join(unfoundErrorStrings,'\n');
            Messaging.EmailFileAttachment unfoundErrorsAttachment = new Messaging.EmailFileAttachment();
            Blob unfoundErrorsBlob = Blob.valueOf(unfoundErrorStringsJoined);
            unfoundErrorsAttachment.setFileName('UnfoundErrors.csv');
            unfoundErrorsAttachment.setBody(unfoundErrorsBlob);
            fileAttachments.add(unfoundErrorsAttachment);
        }

        Integer deliveryDatesLeft = 0;
        for(String externalId : externalIdToNewDeliveryDate.keySet()){
            for(CSVImportExport.DeliveryDateWrapper delivWrapperObj : externalIdToNewDeliveryDate.get(externalId)){
                deliveryDatesLeft++;
            }
        }
        Integer delivDateErrNum = 0;
        if (deliveryDateErrorStrings != null) {
            delivDateErrNum = deliveryDateErrorStrings.size();
        }
		Integer delivDateUpdErrNum = 0;
        if (deliveryDateUpdateErrorStrings != null) {
            delivDateUpdErrNum = deliveryDateUpdateErrorStrings.size();
        }
        Integer delivDateExistNum = 0;
        if (deliveryDatesAlreadyExistList != null) {
            delivDateExistNum = deliveryDatesAlreadyExistList.size();
        }
        Integer totalDeliveryDatesInserted = externalIdListSize - deliveryDatesLeft - delivDateErrNum - delivDateUpdErrNum - delivDateExistNum - numDelivDups;
        if (totalDeliveryDatesInserted < 0) {
            totalDeliveryDatesInserted = 0;
        }
        
        String emailSubject = ' Delivery Date ';
        if(callsInserted){
            emailSubject += '& Call Task ';
        }
        emailSubject += 'Insert Results';
        String emailBody = '<p>' + totalDeliveryDatesInserted + ' Delivery Date(s) ';
        emailBody += 'were inserted or updated to active. </p>';
        if(externalIdToNewDeliveryDate.keySet().size() > 0){
            emailBody += '<p>' + externalIdToNewDeliveryDate.keySet().size() + ' Account(s) could not be found. Please see the corresponding attachment for more details. </p>';
        }
        if(numDelivDups > 0){
            emailBody += '<p>' + numDelivDups + ' duplicate Delivery Date(s) were found in the upload file.</p>';
        }   
        if(deliveryDatesAlreadyExistList != null && deliveryDatesAlreadyExistList.size() > 0){
            emailBody += '<p>' + deliveryDatesAlreadyExistList.size() + ' Delivery Date(s) were already found to be Active.</p>';
        } 
        if(deliveryDateErrorStrings != null && deliveryDateErrorStrings.size() > 0){
            emailBody += '<p>' + deliveryDateErrorStrings.size() + ' Delivery Date(s) could not be inserted/updated due to technical errors. Please see the corresponding attachment for more details. </p>';
        }
       	emailBody += '<p>' + (numTasksInserted - taskErrorStrings.size()) + ' Call Tasks(s) ';
       	emailBody += 'were inserted or updated to open.</p>';
		if(callTasksAlreadyExistList != null && callTasksAlreadyExistList.size() > 0){
            emailBody += '<p>' + CallTasksAlreadyExistList.size() + ' Call Task(s) were already found to be Open.</p>';
        } 
        if(taskErrorStrings != null && taskErrorStrings.size() > 0){
            emailBody += '<p>' + taskErrorStrings.size() + ' Call Task(s) could not be inserted/updated due to technical errors. Please see the corresponding attachment for more details. </p>';
        }
        
        //Send the Email
        HolidayPlanningUtility.sendHolidayPlanningEmail(userEmail, emailSubject, emailBody, fileAttachments);
    }
}
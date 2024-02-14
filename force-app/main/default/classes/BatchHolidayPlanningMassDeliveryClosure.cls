global class BatchHolidayPlanningMassDeliveryClosure implements Database.Batchable<sObject>,  Database.Stateful{

    public List<Date> originalDates;
    public String warehouses;
    public String frequencies;
    public String sellTypes;
    public String premises;
    public String userEmail;
    public List<String> citiesList = new List<String>();
    public String query;
    public List<Delivery_Date__c> deliveryDatesCombined = new List<Delivery_Date__c>();
    List<Database.SaveResult> allDeliveryDateSaveResults = new List<Database.SaveResult>();

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

    global void execute(Database.BatchableContext BC, List<Delivery_Date__c> deliveryDatesToClose) {
        List<Id> successfullyClosedDeliveryDatesIds = new List<Id>();
        Set<Id> accountIds = new Set<Id>();
        for(Delivery_Date__c deliveryObj : deliveryDatesToClose){
            accountIds.add(deliveryObj.Account__c);
            deliveryObj.Status__c = 'Cancelled';
        }

        List<Account> accountsToUpdate = new List<Account>();
        for(Id accountId : accountIds){
            Account tempAccount = new Account();
            tempAccount.Id = accountId;
            tempAccount.Presell_Cancelled_Dates__c = String.valueOf(originalDates);
            accountsToUpdate.add(tempAccount);
        }

        if(!accountsToUpdate.isEmpty()){
            AccountDAO.updateAccounts(accountsToUpdate);
        }
        //Committing the updates
        if(deliveryDatesToClose.size()>0){
            List<Database.SaveResult> deliveryDateSaveResult = database.update(deliveryDatesToClose,false);
            allDeliveryDateSaveResults.addAll(deliveryDateSaveResult);
        }

        deliveryDatesCombined.addAll(deliveryDatesToClose);
    }
    
    global void finish(Database.BatchableContext BC) {
        Set<Id> successfullDeliveryDateIdSet = new Set<Id>();

        List<Delivery_Date__c> succesfullDeliveryDateClose = new List<Delivery_Date__c>();

        for(Database.SaveResult deliveryDateSR : allDeliveryDateSaveResults){
            if(deliveryDateSR.isSuccess()){
                successfullDeliveryDateIdSet.add(deliveryDateSR.getId());
            }
        }

        for(Delivery_Date__c deliveryDateObj: deliveryDatesCombined){
            if(successfullDeliveryDateIdSet.contains(deliveryDateObj.Id)){
                succesfullDeliveryDateClose.add(deliveryDateObj);
            }
        }
        
        String deliveryDateBreakdown = HolidayPlanningUtility.createDeliveryDateResultsString('Delivery Date Closure Results', succesfullDeliveryDateClose);

        List<Messaging.EmailFileAttachment> fileAttachments = new List<Messaging.EmailFileAttachment>();

        List<String> deliveryDateErrorStrings = CSVImportExport.createErrorStrings(allDeliveryDateSaveResults);

        if(deliveryDateErrorStrings.size()>0){
            String deliveryDateStringsJoined = String.join(deliveryDateErrorStrings,'\n');
            Messaging.EmailFileAttachment deliveryDateErrorsAttachment = new Messaging.EmailFileAttachment();
            Blob deliveryDateErrorsBlob = Blob.valueOf(deliveryDateStringsJoined);
            deliveryDateErrorsAttachment.setFileName('deliveryDateUpdateErrors.csv');
            deliveryDateErrorsAttachment.setBody(deliveryDateErrorsBlob);
            fileAttachments.add(deliveryDateErrorsAttachment);
        }

        Integer deliveryDatesCombinedCount = deliveryDatesCombined.size();

        Integer succesfullDeliveryDateCloseCount = succesfullDeliveryDateClose.size();

        String emailSubject = ' Holiday Planning Mass Delivery Date Closure  ';

        String emailBody = '<b><u> Mass Closure Results</u></b> \n\n';

        if(deliveryDatesCombinedCount > 0){
            emailBody += '<p> <b>' + succesfullDeliveryDateCloseCount + ' out of ' + deliveryDatesCombinedCount + '</b> Delivery Dates were successfully closed. </p>';
        }
        emailBody += deliveryDateBreakdown;

        if(deliveryDateErrorStrings.size()>0){
            emailBody +='<p>' +  deliveryDateErrorStrings.size() + ' Delivery Dates could not be updated due to technical errors.  Please see the corresponding attachment for more details. </p>';
        }

        //Send the Email
        HolidayPlanningUtility.sendHolidayPlanningEmail(userEmail, emailSubject, emailBody, fileAttachments);
	}
}
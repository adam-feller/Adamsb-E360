global class BatchHolidayPlanningReversionDD implements Database.Batchable<sObject>,  Database.Stateful{

    public String planId;
    public String planName;
    public String userEmail;
    public String warehouses;
    
    public String query;

    public List<Delivery_Date__c> deliveryDatesCombined= new List<Delivery_Date__c>();

    List<Database.SaveResult> allDeliveryDateSaveResults = new List<Database.SaveResult>();


    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute

        //Split the warehouses and frequencies
        List<String> warehouseList = new List<String>();

        if(!String.isBlank(warehouses)){
                warehouseList = warehouses.split(';');
            }
    
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Delivery_Date__c> deliveryDatesToRevert) {

        deliveryDatesCombined.addAll(deliveryDatesToRevert);

        //Grabbing a list of all the updated Delivery Date and placing in List and Map
        List<Id> successfullyMovedDeliveryIds = new List<Id>();
       
        for(Delivery_Date__c dd : deliveryDatesToRevert){
            if(dd.Status__c == 'Cancelled'){
                dd.Status__c = 'Active';
            }
            dd.Delivery_Date__c = dd.Original_Delivery_Date__c;
            dd.Reschedule_Reason__c = null;
            dd.Plan__c = null;
        }

        if(deliveryDatesToRevert.size()>0){
            List<Database.SaveResult> ddSaveResult = database.update(deliveryDatesToRevert,false);
            allDeliveryDateSaveResults.addAll(ddSaveResult);
        }

    }   
    
    global void finish(Database.BatchableContext BC) {

        Set<id> successfulDeliveryDateIdsSet = new Set<Id>();

        List<Delivery_Date__c> successfulDeliveryDateMoves = new List<Delivery_Date__c>(); 



        for(Database.SaveResult deliveryDateSR : allDeliveryDateSaveResults){
            if(deliveryDateSR.isSuccess()){
                successfulDeliveryDateIdsSet.add(deliveryDateSR.getId());
            }
        }

        for(Delivery_Date__c dd : deliveryDatesCombined){
            if(successfulDeliveryDateIdsSet.contains(dd.Id)){
                successfulDeliveryDateMoves.add(dd);
            }
        }
        
        String deliveryDateBreakdown = HolidayPlanningUtility.createDeliveryDateResultsString('Delivery Date Reversion Results', successfulDeliveryDateMoves);

        List<Messaging.EmailFileAttachment> fileAttachments = new List<Messaging.EmailFileAttachment>();

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

        Integer successfulDeliveryDateMovesCount = successfulDeliveryDateMoves.size();

        String emailSubject = PlanName + ' Holiday Planning Results Plan Reversion (Delivery Dates): ' + planName;

        String emailBody = '<b><u>' + planName + ' Results</u></b> \n\n';
        if(deliveryDatesCombinedCount > 0){
            emailBody += '<p> <b>' + successfulDeliveryDateMovesCount + ' out of ' + deliveryDatesCombinedCount + '</b> Delivery Dates were successfully reverted. </p>';
        }

        emailBody += deliveryDateBreakdown;
        if(deliveryDateErrorStrings.size()>0){
            emailBody += '<p>' + deliveryDateErrorStrings.size() + ' Delivery Dates could not be updated due to technical errors.  Please see the corresponding attachment for more details. </p>';
        }

        //Send the Email
        HolidayPlanningUtility.sendHolidayPlanningEmail(userEmail, emailSubject, emailBody, fileAttachments);
	}
    
}
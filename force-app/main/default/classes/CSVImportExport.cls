public class CSVImportExport {
    // BSSP-1150 Adding User route Update Functionality
    @AuraEnabled
    public static string updateUserRouteData(String strfromle, String planName){

        List<UserWrapper> userDatalist = (List<UserWrapper>)JSON.deserialize(strfromle, List<UserWrapper>.class);
        integer userListLength = userDatalist.size();

        List<User> newUsersRoutes = new List<User>();

        for(integer i = 0; i < userListLength; i++){
            // check if there is anything for merch Route 
            boolean merchUpdate = String.isBlank(userDatalist[i].MerchRoute);
            boolean routeUpdate = String.isBlank(userDatalist[i].AssignedRoute);
            // Set variables
            String userName      = userDatalist[i].Name;
            String userId        = userDatalist[i].Id;
            String newUserRoute  = userDatalist[i].AssignedRoute;
            String newMerchRoute = userDatalist[i].MerchRoute;
            //system.debug(userName + ', ' + userId + ', ' + newUserRoute);
            List<User> userToUpdate = UserDAO.getUser(userId);
            // If merch route is NOT blank update the route
            if(merchUpdate == false){
                userToUpdate[0].Merch_Route__c = newMerchRoute;
            }
            // If route is NOT blank update the route
            if(routeUpdate == false){
                userToUpdate[0].Assigned_route__c = newUserRoute;
            }
            newUsersRoutes.add(userToUpdate[0]);
        }

            Update newUsersRoutes;


        return 'SUCCESS';
    }

    // BSSP-1150 Adding User route Update Functionality
    public class UserWrapper{
         public String Name;
         public String Id;
         public String AssignedRoute;
         public String MerchRoute;
        }
    
    /* for import data into sobject and insert data from csv file */
    @AuraEnabled
    public static string updateData(String strfromle, String planName){
        Plan__c newPlan = new Plan__c();
        newPlan.Name = planName;
        PlanDAO.insertPlans(new List<Plan__c>{newPlan});

        List<User> activeUser = UserDAO.getUser(UserInfo.getUserId());
        String userEmail = activeUser[0].Email;

        String returnresponse ='';
        List<Delivery_Date__c> deliveryDateList = new List<Delivery_Date__c>();
        List<DeliveryDateWrapper> datalist = (List<DeliveryDateWrapper>)JSON.deserialize(strfromle, List<DeliveryDateWrapper>.class);
        Map<String, DeliveryDateWrapper> externalIdToNewDeliveryDate = new Map<String, DeliveryDateWrapper>();

        for(DeliveryDateWrapper  wrapper: datalist){
            String externalId = wrapper.BusinessUnit+'*'+wrapper.AccountNumber+'*'+wrapper.PriorDeliveryDate;
            externalIdToNewDeliveryDate.put(externalId, wrapper);
        }

        //Build the query selecting all Delivery Dates with the ExternalId
        String query = 'SELECT Id, External_Id__c, Delivery_Date__c, Account__c, Account__r.Sell_Type__c' +
                        ' FROM Delivery_Date__c' + 
                        ' WHERE External_Id__c IN :externalIdList';

        //Call the BatchJob; passing the externalIdTONewDeliveryDat and query
        BatchMassUpdateDeliveryAndCallTaskDates massUpdateBatch = new BatchMassUpdateDeliveryAndCallTaskDates();
        massUpdateBatch.externalIdToNewDeliveryDate = externalIdToNewDeliveryDate;
        massUpdateBatch.externalIdList = externalIdToNewDeliveryDate.keySet();
        massUpdateBatch.userEmail = userEmail;
        massUpdateBatch.planName = planName;
        massUpdateBatch.planId = newPlan.Id;
        massUpdateBatch.query = query;
        if (HolidayPlanningUtility.isEmailTurnedOn()) {
        Database.executeBatch(massUpdateBatch);
        }
        // //BatchJob will go through the results in batch of 200
        // //Put all the externalIds in a list
        // //get the corresponding tasks by external Id
        // //cycle through the tasks and set the Activity Date to the New Call Date (if Not Null)
        // //Cycle through the batch results, setting the delivery date by getting the  the corresponding New Delivery date from the map
        // //Remove the entry from map
        // //In the finish statement, send an email of any error and remaining items in the map
        return 'SUCCESS';
    }

    @AuraEnabled
    public static String insertDeliveryDates(String strfromle){
        //Flow Option: Upload New Delivery and/or Call Days
        List<User> activeUser = UserDAO.getUser(UserInfo.getUserId());
        String userEmail = activeUser[0].Email;

        List<DeliveryDateWrapper> datalist = (List<DeliveryDateWrapper>)JSON.deserialize(strfromle, List<DeliveryDateWrapper>.class);
        Map<String, List<DeliveryDateWrapper>> externalIdToNewDeliveryDate = new Map<String, List<DeliveryDateWrapper>>();
        
        //First check to make sure there are Delivery Dates in the file
        Boolean badFormat = false;
        for (DeliveryDateWrapper wrapper : datalist) {
            if (wrapper.NewDeliveryDate == null) {
                //Send error that there are missing Delivery Dates in the file
                sendEmailFormatError();
                badFormat = true;
                break;
            }
        }
        if (badFormat) {
        	return 'FAILURE';				
        }
        for (DeliveryDateWrapper wrapper : datalist) {
           	wrapper.AccountNumber = wrapper.AccountNumber.leftPad(5, '0');
           	String externalId = wrapper.BusinessUnit + '*' + wrapper.AccountNumber;
           	List<DeliveryDateWrapper> deliveryDateList = new List<DeliveryDateWrapper>();
           	if(externalIdToNewDeliveryDate.containsKey(externalId)){
	    	    deliveryDateList = externalIdToNewDeliveryDate.get(externalId);
	        }
	        deliveryDateList.add(wrapper);
	        externalIdToNewDeliveryDate.put(externalId, deliveryDateList);
	    }
	
	    Id retailAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retail Store').getRecordTypeId();
	    //Build the query selecting all Accounts with the ExternalId
	    String query = 'SELECT Id, ExternalId__c, Warehouse_Lookup__r.ISR_1__c, OwnerId, Name' +
	                    ' FROM Account' + 
	                    ' WHERE ExternalId__c IN :externalIdList' + 
	                    ' AND RecordTypeId = :retailAccountRecordTypeId' + 
	                    ' AND Status__c = \'A\'';
	    //Call the BatchJob; passing the externalIdTONewDeliveryDat and query
	    BatchInsertNewDeliveryDates massInsertDeliveryDatesBatch = new BatchInsertNewDeliveryDates();
	    massInsertDeliveryDatesBatch.externalIdToNewDeliveryDate = externalIdToNewDeliveryDate;
	    massInsertDeliveryDatesBatch.externalIdList = externalIdToNewDeliveryDate.keySet();
	    massInsertDeliveryDatesBatch.externalIdListSize = datalist.size();
	    massInsertDeliveryDatesBatch.retailAccountRecordTypeId = retailAccountRecordTypeId;
	    massInsertDeliveryDatesBatch.userEmail = userEmail;
	    massInsertDeliveryDatesBatch.query = query;
	    Database.executeBatch(massInsertDeliveryDatesBatch);
	
    	// //BatchJob will go through the results in batch of 200
	    // //Put all the externalIds in a list
	    // //Cycle through the batch results, setting the delivery date by getting the corresponding New Delivery date from the map
	    // //Remove the entry from map
	    // //In the finish statement, send an email of any error and remaining items in the map
	    return 'SUCCESS';        
    }

    public class DeliveryDateWrapper{
        public String BusinessUnit;
        public String AccountNumber;
        public String PriorDeliveryDate;
        public String NewDeliveryDate;
        public String PriorCallDate;
        public String NewCallDate;
    }

    public static List<String> createErrorStrings(List<Database.SaveResult> saveResultList){
        List<String> errorStringList = new List<String>();
        for (Database.SaveResult SaveResult : saveResultList){
            if (saveResult.isSuccess() == false){
                for(Database.Error error : saveResult.getErrors()) {
                    errorStringList.add('Something went wrong with the record ID ' + saveResult.getId() + ' : ' + error.getStatusCode() + ' - ' + error.getMessage());
                }
            }
        }
        return errorStringList;
    }

    public static List<String> createUnfoundString(Map<String, DeliveryDateWrapper> updateTracker){
        List<String> unfoundStringList = new List<String>();
        if(updateTracker.keySet().size()>0){
            unfoundStringList.add('BusinessUnit,AccountNumber,PriorDeliveryDate,NewDeliveryDate,PriorCallDate,NewCallDate');
            for(DeliveryDateWrapper ddw : updateTracker.values()){
                String newRow = ddw.BusinessUnit + ',' + ddw.AccountNumber + ',' + ddw.PriorDeliveryDate + ',' + ddw.NewDeliveryDate + ',' + ddw.PriorDeliveryDate + ',' + ddw.NewCallDate;
                unfoundStringList.add(newRow);
            }
        }

        return unfoundStringList;
    }

    public static List<String> createUnfoundStringDeliveryDateNew(Map<String, List<DeliveryDateWrapper>> insertTracker) {
        List<String> unfoundStringList = new List<String>();
        if (insertTracker.keySet().size() > 0) {
            unfoundStringList.add('BusinessUnit,AccountNumber,NewDeliveryDate');
            for(String externalId : insertTracker.keySet()){
                for(DeliveryDateWrapper ddw : insertTracker.get(externalId)){
                    String newRow = ddw.BusinessUnit + ',' + ddw.AccountNumber + ',' + ddw.NewDeliveryDate;
                    unfoundStringList.add(newRow);
                }
            }
        }
        return unfoundStringList;
    }
    
    static void sendEmailFormatError() {
        List<User> activeUser = UserDAO.getUser(UserInfo.getUserId());
        String userEmail = activeUser[0].Email;
        List<String> toAddresses = new List<String> {userEmail};
        String emailSubject = 'Bad File Format - Missing Delivery Dates';
        String emailBody = '<p>The file is missing Delivery Dates, please update your file and try again.';
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setHtmlBody(emailBody);
        email.setSubject(emailSubject);
        email.setToAddresses(toAddresses);
        List<Messaging.SendEmailResult> result = Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {email});
    }
}
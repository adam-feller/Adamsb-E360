public with sharing class HolidayPlanningUtility {

    public static String createDeliveryDateResultsString(String header, List<Delivery_Date__c> deliveryDateList){
        
        String results = '';

        if(deliveryDateList.size() > 0){
            results += '<b><i><u>' + header + '</u></b></i>';
        }
        
        Map<String, Map<Date, List<Delivery_Date__c>>> deliveryDateMapMap = new Map<String, Map<Date, List<Delivery_Date__c>>>();

        for(Delivery_Date__c dd : deliveryDateList){
            
            if(deliveryDateMapMap.containsKey(dd.Account__r.Warehouse__c)){
                Map<Date, List<Delivery_Date__c>> warehouseByDateMap = deliveryDateMapMap.get(dd.Account__r.Warehouse__c);
                if(warehouseByDateMap.containsKey(dd.Delivery_Date__c)){
                    warehouseByDateMap.get(dd.Delivery_Date__c).add(dd);
                }else{
                    List<Delivery_Date__c> mapDateList = new List<Delivery_Date__c>();
                    mapDateList.add(dd);
                    warehouseByDateMap.put(dd.Delivery_Date__c, mapDateList);
                }
            }else{
                Map<Date, List<Delivery_Date__c>> warehouseByDateMap =  new Map<Date, List<Delivery_Date__c>>();
                List<Delivery_Date__c> dateList = new List<Delivery_Date__c>();
                dateList.add(dd);
                warehouseByDateMap.put(dd.Delivery_Date__c, dateList);
                deliveryDateMapMap.put(dd.Account__r.Warehouse__c, warehouseByDateMap);
            }
        }

        for(String warehouse: deliveryDateMapMap.keySet()){
            Map<Date, List<Delivery_Date__c>> warehouseByDateMap = deliveryDateMapMap.get(warehouse);
            results += '<br><b><i>' + warehouse + '</b></i> <br>';
            for(Date deliveryDate : warehouseByDateMap.keySet()){
                List<Delivery_Date__c> ddListByDate = warehouseByDateMap.get(deliveryDate);
                System.debug('results' + results);
                System.debug('deliveryDate' + deliveryDate);
                System.debug('ddListByDate' + ddListByDate);
                if(ddListByDate != null & deliveryDate!=null){
                	results += deliveryDate.format() + ' : ' + ddListByDate.size() + '<br>';
                }
            } 
        }

        return results;

    }

    public static String createCallTaskResultsString(String header, List<task> taskList){
        
        String results = '';

        if(taskList.size() > 0){
            results += '<b><i><u>' + header + '</u></b></i>';
        }

        Map<String, Map<Date, List<Task>>> taskDateMapMap = new Map<String, Map<Date, List<Task>>>();

        for(Task tsk : taskList){
            
            if(taskDateMapMap.containsKey(tsk.Account__r.Warehouse__c)){
                Map<Date, List<Task>> warehouseByDateMap = taskDateMapMap.get(tsk.Account__r.Warehouse__c);
                if(warehouseByDateMap.containsKey(tsk.ActivityDate)){
                    warehouseByDateMap.get(tsk.ActivityDate).add(tsk);
                }else{
                    List<Task> mapDateList = new List<Task>();
                    mapDateList.add(tsk);
                    warehouseByDateMap.put(tsk.ActivityDate, mapDateList);
                }
            }else{
                Map<Date, List<Task>> warehouseByDateMap =  new Map<Date, List<Task>>();
                List<Task> dateList = new List<Task>();
                dateList.add(tsk);
                warehouseByDateMap.put(tsk.ActivityDate, dateList);
                taskDateMapMap.put(tsk.Account__r.Warehouse__c, warehouseByDateMap);
            }
        }

        for(String warehouse: taskDateMapMap.keySet()){
            Map<Date, List<Task>> warehouseByDateMap = taskDateMapMap.get(warehouse);
            results += '<br> <b><i>' + warehouse + '</b></i> <br>';
            for(Date taskDate : warehouseByDateMap.keySet()){
                List<Task> ddListByDate = warehouseByDateMap.get(taskDate);
                if(ddListByDate != null & taskDate!=null){
                    results += taskDate.format() + ' : ' + ddListByDate.size() + '<br>';
                }
            } 
        }

        return results;

    }

    public static List<String> createErrorStrings(List<Database.SaveResult> saveResultList){
        List<String> errorStringList = new List<String>();
        
        for (Database.SaveResult SaveResult : saveResultList){
           if (saveResult.isSuccess() == false){
               for(Database.Error error : saveResult.getErrors())
               {
                   errorStringList.add('Something went wrong with updating a record + : ' + error.getStatusCode() + ' - ' + error.getMessage());
               }
           }
        }

        return errorStringList;
   }
    
    public static Boolean isEmailTurnedOn() {
        try {
            Messaging.reserveSingleEmailCapacity(0);
            return true;
        } catch (System.NoAccessException e) {
            return false;        
        }
    }
    
    public static void sendHolidayPlanningEmail(String userEmail, String subject, String body, List<Messaging.EmailFileAttachment> fileAttachments) {
        //Send to the person logged in
        List<String> toAddresses = new List<String> {userEmail};
		//Copy all Call Center Supervisors
        String userRoleId = [SELECT Id FROM UserRole WHERE Name = 'Call Center Supervisor' LIMIT 1].Id;
        List<User> ccSupervisorsList = [SELECT Email FROM User WHERE UserRole.Id = :userRoleId];
        List<String> ccAddresses = new List<String>();
        for (User u : ccSupervisorsList) {
            ccAddresses.add(u.Email);
        }

        Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;        
        if (isEmailTurnedOn()) {   //Check if Email Deliverability is on (for testing in lower environments)
        	Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setSubject(subject);
            email.setToAddresses(toAddresses);
            if (isSandbox) {
                String copyToText = 'This email would have copied the following users:<br>';
                for (String cc : ccAddresses) {
                    copyToText += cc + '<br>';
                }
            	email.setHtmlBody(copyToText + '<br><br><br>' + body);       
	        } else {
            	email.setHtmlBody(body);
            	email.setCcAddresses(ccAddresses);
    	    }        
        	email.setFileAttachments(fileAttachments);
	        List<Messaging.SendEmailResult> result = Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {email});
        }        
    }

}
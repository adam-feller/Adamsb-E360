public class ChatbotCutoffCheck {
    @InvocableMethod(label='Perform Cutoff Check')
    public static List<ResponseOutput> performCutoffCheck(List<ResponseInput> riList) {
        List<ResponseOutput> roList = new List<ResponseOutput>();
        ResponseOutput ro           = new ResponseOutput();
        Boolean isAfterCutoff       = false;
        Boolean isNearCutoff        = false;

        //Nothing passed in, exit
        if(riList == null || riList.size() <= 0) { return null; }

        ResponseInput ri = riList[0];
		
        //Get the DateTime in the user's time zone
        Date d          = System.today();
        datetime myDate = datetime.newInstance(d.year(), d.month(), d.day());
        String day      = myDate.format('EEEE');
        // Call center is closed on Saturday ... Return after cutoff time
         if(day == 'Saturday'){
             ro.IsNearCutoff  = false;
             ro.IsAfterCutoff = true;
             ro.IsBeforeOpen  = false;
      
            roList.add(ro);
            return roList;
        }
        
       Boolean selectedAccount = false;
       String selectedAccountId;
        
       if(ri.selectedAccount != null && !string.isEmpty(ri.selectedAccount.Id)) {
           selectedAccount   = true;
           selectedAccountId = ri.selectedAccount.Id;
       }
        
        MessagingEndUser meu = [
            SELECT Name 
            FROM MessagingEndUser 
            WHERE Id = :ri.EndUserId
            LIMIT 1
        ];
        String pN          = meu.Name;
        String phoneNumSub = pN.substring(2);
       
        List<TTO_Authorization__c> ttoAuth = new List<TTO_Authorization__c>();
        
        if(selectedAccount == false){
           List<TTO_Authorization__c> ttoAuth1 = [SELECT Name,Contact__r.Phone,Account__c,Id,LastReferencedDate,
                                        	   Account__r.WarehouseCutoffTime__c,Account__r.Warehouse_Lookup__r.TimeZone__c,Account__r.Warehouse_Lookup__r.Name
                                        	  FROM TTO_Authorization__c 
                                              WHERE Contact__r.Phone = :phoneNumSub
                                              LIMIT 1];
            ttoAuth = ttoAuth1;
        }else{
             List<TTO_Authorization__c> ttoAuth2 = [SELECT Name,Contact__r.Phone,Account__c,Id,LastReferencedDate,
                                        	   Account__r.WarehouseCutoffTime__c,Account__r.Warehouse_Lookup__r.TimeZone__c,Account__r.Warehouse_Lookup__r.Name
                                        	  FROM TTO_Authorization__c 
                                              WHERE Account__r.Id = :selectedAccountId
                                              LIMIT 1];
            ttoAuth = ttoAuth2;  
        }
        // Check if there are no TTO Auth records associated with the phone number texting in
        if(ttoAuth.size() <= 0){
        	ro.cutOffTime           = '6:30 PM CT';
            // Call cut off helper method
            String cutOffMessage = cutOffTimeCheck(99, 99, 99, 99);
  			// Update fields depending on if it's cutoff time or not
		    if(cutOffMessage == 'After Cutoff') {
                 ro.IsNearCutoff  = false;
                 ro.IsAfterCutoff = true;
                 ro.IsBeforeOpen  = false;
            }else if(cutOffMessage == 'Before Cutoff'){
                 ro.IsNearCutoff  = false;
                 ro.IsAfterCutoff = false;
                 ro.IsBeforeOpen  = true;
            }else{
                ro.IsNearCutoff  = false;
                ro.IsAfterCutoff = false;
                ro.IsBeforeOpen  = false;
            }
            roList.add(ro);
            return roList;
        }

        	DateTime dtn             = System.now(); 
            Time myTime              = Time.newInstance(dtn.hour(), dtn.minute(), dtn.second(), dtn.millisecond());
            Time myTimeCentral       = myTime.addHours(2);
            Time cutoffTime          = ttoAuth[0].Account__r.WarehouseCutoffTime__c;
            
        // Send cutoff time to bot    
        	Integer cutoffTimeMin   = cutoffTime.minute();
        	Integer cutoffTimeH12   = cutoffTime.hour();
        			cutoffTimeH12   = cutoffTimeH12 - 2;
        	String convertedHour    = String.valueOf(cutoffTimeH12);
        	String convertedHourSub = cutoffTimeMin > 0 ? convertedHour.substring(1) + ':30 PM CT' : convertedHour.substring(1) + ' PM CT';
        	ro.cutOffTime           = convertedHourSub;
            
            // Get Hour
			Integer myHourCentral    = myTimeCentral.hour();
			Integer cutoffTimeHour   = cutoffTime.hour();
		    // Get Minute
            Integer myMinuteCentral  = myTimeCentral.minute();
            Integer cutoffTimeMinute = cutoffTime.minute();
            // Call helper method
            String cutOffMessage     = cutOffTimeCheck(cutoffTimeMinute, cutoffTimeHour, myMinuteCentral , myHourCentral);

            if(cutOffMessage == 'CUTOFF CLOSE'){
                 ro.IsNearCutoff  = true;
                 ro.IsAfterCutoff = false;
                 ro.IsBeforeOpen  = false;
            } else if(cutOffMessage == 'After Cutoff') {
                 ro.IsNearCutoff  = false;
                 ro.IsAfterCutoff = true;
                 ro.IsBeforeOpen  = false;
            }else if(cutOffMessage == 'Before Cutoff'){
                 ro.IsNearCutoff  = false;
                 ro.IsAfterCutoff = false;
                 ro.IsBeforeOpen  = true;
            }else{
                ro.IsNearCutoff  = false;
                ro.IsAfterCutoff = false;
                ro.IsBeforeOpen  = false;
            }
   

            roList.add(ro);
            return roList;
    }
    
    
     /*
    // Summary: Check to see if there is 5 minutes until warehouse cut off time
    //  		Or if it's after cutoff
    //  		Or if it's before call center hours
    */
    public static String cutOffTimeCheck(Integer cutoffTimeMinute, Integer cutoffTimeHour, Integer currentUserMinute, Integer currentUserHour) {
        // Check for cutoff time on top of the hour
        if(cutoffTimeMinute == 0){
            boolean isAlmostCutOff = cutoffTimeHour - currentUserHour == 1 ? true : false;
            if(isAlmostCutOff == true){
                if(currentUserMinute >= 55 && currentUserMinute <= 60){
                    return 'CUTOFF CLOSE';
                }
            }
        }
        // Check for cutoff time @ half hour
        if(cutoffTimeMinute == 30){
            boolean isAlmostCutOff = cutoffTimeHour - currentUserHour == 0 ? true : false;
            if(isAlmostCutOff == true){
                if(currentUserMinute >= 25 && currentUserMinute <= 30){
                    return 'CUTOFF CLOSE';
                }
            }
        }
        // Check if it's within call center hours for TTO messages that don't have a TTO auth record
        if(cutoffTimeMinute == 99){
            DateTime dtn              = System.now();
            Time myTime               = Time.newInstance(dtn.hour(), dtn.minute(), dtn.second(), dtn.millisecond());
            Time centralTime          = myTime.addHours(2);
            Integer centralTimeHour   = centralTime.hour();
            Integer centralTimeMinute = centralTime.minute();
            if(centralTimeHour < 7){
                return 'Before Cutoff';
            }else if(centralTimeHour > 18 && centralTimeMinute > 30){
                return 'After Cutoff';
            }
            else{
                return 'Not Cutoff';
            }   
        }
        // Grab central time to see if user is texting in before call center opens
        DateTime dtn            = System.now();
        Time myTime             = Time.newInstance(dtn.hour(), dtn.minute(), dtn.second(), dtn.millisecond());
        Time centralTime        = myTime.addHours(2);
        Integer centralTimeHour = centralTime.hour();
        if(centralTimeHour < 7){
            return 'Before Cutoff';
        }
        // If user is texting in after cutoff time send after cutoff message
        if(currentUserHour >= cutoffTimeHour &&  currentUserMinute > cutoffTimeMinute){
            return 'After Cutoff';
        }

        return 'Not Cutoff';
    }


    
    public class ResponseInput {
        @InvocableVariable
        public String EndUserId;
        // MJ adding variable below
        @InvocableVariable
        public ChatbotAuthotizationCheck.AccountOption selectedAccount;
    }

    public class ResponseOutput {
        @InvocableVariable
        public Boolean IsNearCutoff;
        @InvocableVariable
        public Boolean IsAfterCutoff;
        // MJ adding variable below
        @InvocableVariable
        public Boolean IsBeforeOpen;
        @InvocableVariable
        public String cutOffTime;
    }
}
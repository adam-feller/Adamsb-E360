public class FsrmasApiController {
    @AuraEnabled
    public static List<visitScheduleParser> getFsrAccountInfo(String recordId) {
        List<Account> acctList = AccountDAO.getAccountsByIds(new Set<Id>{recordId});
        String accountExternalId = acctList[0].ExternalId__c; 
		List<visitScheduleParser> visitParser;       
            if (accountExternalId != null){
                    HttpResponse FSRVisitSchedule = MulesoftUtility.mulesoftCallout('FSR Visit Schedule', accountExternalId, null, null);
                    if (FSRVisitSchedule.getStatusCode() == 200){
                        visitParser = (List<visitScheduleParser>) JSON.deserialize(FSRVisitSchedule.getBody(), List<visitScheduleParser>.class);
                    }    
            } else{
                system.debug('NO RESPONSE');
            }
        return visitParser;
    }
    
    public class visitScheduleParser {     
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String salesman2;
        @AuraEnabled
        public String visitType;
        @AuraEnabled
        public Integer deliveryDay;
        @AuraEnabled
        public Integer deliveryWeek;
        @AuraEnabled
        public String visitWindow;
    }

}
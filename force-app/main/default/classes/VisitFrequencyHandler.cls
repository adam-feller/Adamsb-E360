public without sharing class VisitFrequencyHandler {
    
    public static void calculateVisitFrequency(List<Account> actList, Map<Id, Account> actOldMap){
        for(Account a : actList){
            //on update
            if(actOldMap.size()>0){
                Account oldAccount = actOldMap.get(a.Id);
                if(a.FSRMAS_Minimum_Days_Between_Visits__c == null && a.FSRMAS_Frequency__c!=null){
                    processVisitMinDays(a);
                }
                if(a.FSRMAS_Maximum_Days_Between_Visits__c == null && a.FSRMAS_Frequency__c!=null){
                    processVisitMaxDays(a);
                }
            }
            //on insert
            else if(a.FSRMAS_Frequency__c!=null){
                if(a.FSRMAS_Minimum_Days_Between_Visits__c == null){
                    processVisitMinDays(a);
                }
                if(a.FSRMAS_Maximum_Days_Between_Visits__c == null){
                    processVisitMaxDays(a);
                }
            }
        }
    }

    public static void processVisitMinDays(Account act){
        Map<String, FSRMAS_Visit_Frequency_Value__mdt> values = FSRMAS_Visit_Frequency_Value__mdt.getAll();
        String formatFrequencyValue = act.FSRMAS_Frequency__c.replace(' ','_');
        FSRMAS_Visit_Frequency_Value__mdt frequencyRecord = values.get(formatFrequencyValue);
        act.FSRMAS_Minimum_Days_Between_Visits__c = frequencyRecord.Minimum_Value__c;
    }

    public static void processVisitMaxDays(Account act){
        Map<String, FSRMAS_Visit_Frequency_Value__mdt> values = FSRMAS_Visit_Frequency_Value__mdt.getAll();
        String formatFrequencyValue = act.FSRMAS_Frequency__c.replace(' ','_');
        FSRMAS_Visit_Frequency_Value__mdt frequencyRecord = values.get(formatFrequencyValue);
        act.FSRMAS_Maximum_Days_Between_Visits__c = frequencyRecord.Maximum_Value__c;
    }
}
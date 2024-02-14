public class ShiftTriggerHandler {
    public static void beforeInsertHandler(List<Shift__c> newShifts) {
        //Set Today's Shift Start and End Time
        for (Shift__c s : newShifts) {
            s.Today_Shift_Start_Time__c = s.Start_Time__c;
            s.Today_Shift_End_Time__c = s.End_Time__c;
        }        
    }    
    
    public static void afterUpdateHandler(List<Shift__c> newShifts) {
		ShiftUtilities.updateAllShifts();       
    }
}
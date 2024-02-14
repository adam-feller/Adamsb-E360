public class ShiftChangeTriggerHandler {
    public static void handleShiftChange(List<Shift_Change__c> newShiftChanges) {           
        Set<Id> shiftIds = new Set<Id>();
        for (Shift_Change__c sc : newShiftChanges) {
            shiftIds.add(sc.Shift__c);
        }        
        ShiftUtilities.updateShiftsById(shiftIds);
    }
}
public class ShiftUtilities {
    
    public static void updateAllShifts() {
        //Get a list of all the Active shifts
        List<Shift__c> employeeShifts = ShiftDAO.getShifts();
        updateShifts(employeeShifts);
    }
    
    public static void updateShiftsById(Set<Id> shiftIds) {
        //Get a list of all the Shifts being updated
        List<Shift__c> employeeShifts = ShiftDAO.getShiftsById(shiftIds);
        updateShifts(employeeShifts);
    }
    
    public static void updateShifts(List<Shift__c> employeeShifts) {
        List<Shift__c> updateShifts = new List<Shift__c>();
		for (Shift__c shft : employeeShifts) {
            if (shft.Shift_Changes__r.size() > 0) {
            	for (Shift_Change__c shftChg : shft.Shift_Changes__r) {
                    if (shft.Today_Shift_Start_Time__c <> shftChg.Start_Time__c || shft.Today_Shift_End_Time__c <> shftChg.End_Time__c) {
	   					shft.Today_Shift_Start_Time__c = shftChg.Start_Time__c;
	                	shft.Today_Shift_End_Time__c = shftChg.End_Time__c;
                        updateShifts.add(shft);
                    }
	            }
            } else {
                if (shft.Today_Shift_Start_Time__c <> shft.Start_Time__c || shft.Today_Shift_End_Time__c <> shft.End_Time__c) {
               		shft.Today_Shift_Start_Time__c = shft.Start_Time__c;
	           		shft.Today_Shift_End_Time__c = shft.End_Time__c; 
                    updateShifts.add(shft);
                }
            }
        }
        update updateShifts;
    }
    
}
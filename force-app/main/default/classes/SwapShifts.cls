public without sharing class SwapShifts {

    @InvocableMethod(label='Swap Shifts')
    public static void callObjectiveApprovalProcess(List<FlowInput> input){
        
        if(input[0].employee1 != null && input[0].employee2 != null) {
            System.debug(input[0].employee1);
            System.debug(input[0].employee2);
            Shift__c shift1 = [SELECT Id, Start_Time__c, End_Time__c FROM Shift__c WHERE Id = :input[0].employee1 LIMIT 1];
			Shift__c shift2 = [SELECT Id, Start_Time__c, End_Time__c FROM Shift__c WHERE Id = :input[0].employee2 LIMIT 1];
            
            //Create the first shift change record
            Shift_Change__c shftChg1 = new Shift_Change__c(Shift__c = shift1.Id, Start_Date__c = input[0].startDate, End_Date__c = input[0].endDate, Start_Time__c = shift2.Start_Time__c, End_Time__c = shift2.End_Time__c);
            insert shftChg1;
            //Create the second shift change record
            Shift_Change__c shftChg2 = new Shift_Change__c(Shift__c = shift2.Id, Start_Date__c = input[0].startDate, End_Date__c = input[0].endDate, Start_Time__c = shift1.Start_Time__c, End_Time__c = shift1.End_Time__c);
            insert shftChg2;
            
            //Update the Shift records if the Start or End Date is equal to today
            if (input[0].startDate == System.today() || input[0].endDate == System.today()) {
                shift1.Today_Shift_Start_Time__c = shftChg1.Start_Time__c;
                shift1.Today_Shift_End_Time__c = shftChg1.End_Time__c;
                update shift1;
				shift2.Today_Shift_Start_Time__c = shftChg2.Start_Time__c;
                shift2.Today_Shift_End_Time__c = shftChg2.End_Time__c;
                update shift2;                
            }
        }
    }

    public class FlowInput{
        @InvocableVariable(required=true)
        public Date startDate;

        @InvocableVariable(required=true)
        public Date endDate;

        @InvocableVariable(required=true)
        public Id employee1;

        @InvocableVariable(required=true)
        public Id employee2;
    }

}
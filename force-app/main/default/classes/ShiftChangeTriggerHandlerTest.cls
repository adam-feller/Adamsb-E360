@isTest
public class ShiftChangeTriggerHandlerTest {
    @isTest
    static void testCreateNewShiftChange(){
        Shift__c shift = new Shift__c();
        shift.Employee__c = userinfo.getUserId();
        shift.Start_Time__c = Time.newInstance(7, 0, 0, 0);
        shift.End_Time__c = Time.newInstance(15, 0, 0, 0);   
        insert shift;

        Shift_Change__c shiftChange = new Shift_Change__c();
        shiftChange.Shift__c = shift.Id;
        shiftChange.Start_Date__c = System.today();
        shiftChange.End_Date__c = System.today();
        shiftChange.Start_Time__c = Time.newInstance(8, 0, 0, 0);
        shiftChange.End_Time__c = Time.newInstance(16, 0, 0, 0);   
        insert shiftChange;
        
        //Assertion
        Shift__c checkShift = [SELECT Start_Time__c, End_Time__c, Today_Shift_Start_Time__c, Today_Shift_End_Time__c
                              FROM Shift__c LIMIT 1];
        System.assertEquals(shiftChange.Start_Time__c, checkShift.Today_Shift_Start_Time__c);
        System.assertEquals(shiftChange.End_Time__c, checkShift.Today_Shift_End_Time__c);
        
    }
    
    @isTest
    static void testUpdateShiftChange(){
        Shift__c shift = new Shift__c();
        shift.Employee__c = userinfo.getUserId();
        shift.Start_Time__c = Time.newInstance(7, 0, 0, 0);
        shift.End_Time__c = Time.newInstance(15, 0, 0, 0);   
        insert shift;

        Shift_Change__c shiftChange = new Shift_Change__c();
        shiftChange.Shift__c = shift.Id;
        shiftChange.Start_Date__c = System.today();
        shiftChange.End_Date__c = System.today();
        shiftChange.Start_Time__c = Time.newInstance(8, 0, 0, 0);
        shiftChange.End_Time__c = Time.newInstance(16, 0, 0, 0);   
        insert shiftChange;
        
        Test.startTest();
        shiftChange.Start_Time__c = Time.newInstance(9, 0, 0, 0);
        shiftChange.End_Time__c = Time.newInstance(17, 0, 0, 0);
        update shiftChange;
        Test.stopTest();
        
        //Assertion
        Shift__c checkShift = [SELECT Start_Time__c, End_Time__c, Today_Shift_Start_Time__c, Today_Shift_End_Time__c
                              FROM Shift__c LIMIT 1];
        System.assertEquals(shiftChange.Start_Time__c, checkShift.Today_Shift_Start_Time__c);
        System.assertEquals(shiftChange.End_Time__c, checkShift.Today_Shift_End_Time__c);
        
    }    
    
    @isTest
    static void testDeleteShiftChange(){
        Shift__c shift = new Shift__c();
        shift.Employee__c = userinfo.getUserId();
        shift.Start_Time__c = Time.newInstance(7, 0, 0, 0);
        shift.End_Time__c = Time.newInstance(15, 0, 0, 0);   
        insert shift;

        Shift_Change__c shiftChange = new Shift_Change__c();
        shiftChange.Shift__c = shift.Id;
        shiftChange.Start_Date__c = System.today();
        shiftChange.End_Date__c = System.today();
        shiftChange.Start_Time__c = Time.newInstance(8, 0, 0, 0);
        shiftChange.End_Time__c = Time.newInstance(16, 0, 0, 0);   
        insert shiftChange;
        
        Test.startTest();
        delete shiftChange;
        Test.stopTest();
        
        //Assertion
        Shift__c checkShift = [SELECT Start_Time__c, End_Time__c, Today_Shift_Start_Time__c, Today_Shift_End_Time__c
                              FROM Shift__c LIMIT 1];
        System.assertEquals(checkShift.Start_Time__c, checkShift.Today_Shift_Start_Time__c);
        System.assertEquals(checkShift.End_Time__c, checkShift.Today_Shift_End_Time__c);
        
    }        
}
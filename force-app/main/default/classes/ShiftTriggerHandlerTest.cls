@isTest
public class ShiftTriggerHandlerTest {

    @isTest
    static void testCreateNewShift(){
        Shift__c shift = new Shift__c();
        shift.Employee__c = userinfo.getUserId();
        shift.Start_Time__c = Time.newInstance(7, 0, 0, 0);
        shift.End_Time__c = Time.newInstance(15, 0, 0, 0);   
        insert shift;

        //Assertion
        Shift__c checkShift = [SELECT Start_Time__c, End_Time__c, Today_Shift_Start_Time__c, Today_Shift_End_Time__c
                              FROM Shift__c LIMIT 1];
        System.assertEquals(checkShift.Start_Time__c, checkShift.Today_Shift_Start_Time__c);
        System.assertEquals(checkShift.End_Time__c, checkShift.Today_Shift_End_Time__c);
        
    }
    
    @isTest
    static void testUpdateShift(){
        Shift__c shift = new Shift__c();
        shift.Employee__c = userinfo.getUserId();
        shift.Start_Time__c = Time.newInstance(7, 0, 0, 0);
        shift.End_Time__c = Time.newInstance(15, 0, 0, 0);   
        insert shift;
        
        Test.startTest();
        shift.Start_Time__c = Time.newInstance(6, 0, 0, 0);
        update shift;
		Test.stopTest();
        
        //Assertion
        Shift__c checkShift = [SELECT Start_Time__c, End_Time__c, Today_Shift_Start_Time__c, Today_Shift_End_Time__c
                              FROM Shift__c LIMIT 1];
        System.assertEquals(checkShift.Start_Time__c, checkShift.Today_Shift_Start_Time__c);
        System.assertEquals(checkShift.End_Time__c, checkShift.Today_Shift_End_Time__c);
        
    }    
}
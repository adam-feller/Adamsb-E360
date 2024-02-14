@isTest
public class VisitFrequencyHandlerTest {

    @isTest
    public static void testMinMaxDayValueSetInsert(){
        Account testAccount = new Account();
        FSRMAS_Visit_Frequency_Value__mdt values = FSRMAS_Visit_Frequency_Value__mdt.getAll().values()[0];
        testAccount.FSRMAS_Frequency__c = values.MasterLabel;
        testAccount.Name = 'Test Account';
        testAccount.Account_Type__c = 'None';
        testAccount.VIP_Account_Number__c = '201';
        testAccount.VIP_Instance__c = 'PVA';
        testAccount.ExternalId__c = '72245';
        testAccount.Chain__c = 'FOOD LION';
        testAccount.Beer_Company__c = 'PVA';
        testAccount.Warehouse__c = 'PDVA-CHANTILLY';
        testAccount.ParentId = null;
        testAccount.Store_Number__c = '2345';
        testAccount.Territories__c = '10';
        testAccount.Status__c = 'A';
        Test.startTest();
        insert testAccount;
        Test.stopTest();

        Double valueMin = values.Minimum_Value__c;
        Double valueMax = values.Maximum_Value__c;
        Account returnedAccount = [
            SELECT Id, FSRMAS_Minimum_Days_Between_Visits__c, FSRMAS_Maximum_Days_Between_Visits__c 
            FROM Account 
            LIMIT 1
            ];
        
        System.assertEquals(valueMin, returnedAccount.FSRMAS_Minimum_Days_Between_Visits__c, 'Min days between visit value incorrect');
        System.assertEquals(valueMax, returnedAccount.FSRMAS_Maximum_Days_Between_Visits__c, 'Max days between visit value inccorect');
    }
    @isTest
    public static void testMinMaxDayValueSetUpdate(){
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        FSRMAS_Visit_Frequency_Value__mdt values = FSRMAS_Visit_Frequency_Value__mdt.getAll().values()[0];
        testAccount.FSRMAS_Frequency__c = values.MasterLabel;
        Test.startTest();
        update testAccount;
        Test.stopTest();

        Double valueMin = values.Minimum_Value__c;
        Double valueMax = values.Maximum_Value__c;
        Account returnedAccount = [
            SELECT Id, FSRMAS_Minimum_Days_Between_Visits__c, FSRMAS_Maximum_Days_Between_Visits__c 
            FROM Account 
            LIMIT 1
            ];
        
        System.assertEquals(valueMin, returnedAccount.FSRMAS_Minimum_Days_Between_Visits__c, 'Min days between visit value incorrect');
        System.assertEquals(valueMax, returnedAccount.FSRMAS_Maximum_Days_Between_Visits__c, 'Max days between visit value inccorect');
    }
    @isTest
    public static void testMinMaxDayValueNotChanged(){
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        FSRMAS_Visit_Frequency_Value__mdt values = FSRMAS_Visit_Frequency_Value__mdt.getAll().values()[0];
        testAccount.FSRMAS_Frequency__c = values.MasterLabel;
        update testAccount;
        Test.startTest();
        testAccount.FSRMAS_Minimum_Days_Between_Visits__c = 3;
        testAccount.FSRMAS_Maximum_Days_Between_Visits__c = 3;
        update testAccount;
        Test.stopTest();

        Account returnedAccount = [
            SELECT Id, FSRMAS_Minimum_Days_Between_Visits__c, FSRMAS_Maximum_Days_Between_Visits__c 
            FROM Account 
            LIMIT 1
            ];

        System.assertEquals(3, returnedAccount.FSRMAS_Minimum_Days_Between_Visits__c, 'Min days between visit value incorrect');
        System.assertEquals(3, returnedAccount.FSRMAS_Maximum_Days_Between_Visits__c, 'Max days between visit value inccorect');
    }
}
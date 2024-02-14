@isTest
public class StoreVisitTriggerHandlerTest {
    @TestSetup
    private static void setup() {
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        //insert Store Visit record
        CVS_Store_Visit__c storeVisit = new CVS_Store_Visit__c();
        storeVisit.Account__c = testAccount.Id;
        insert storeVisit;
    }

    @isTest
    static void testFormulaToFieldStampInsert() {  
        //Get the Store Visit 
        CVS_Store_Visit__c sv = [SELECT Id, Name__c, Account_Name__c FROM CVS_Store_Visit__c LIMIT 1];
        System.assertEquals('Test Account', sv.Name__c, 'Name does not match');
    }

    @isTest
    static void testFormulaToFieldStampUpdate() {  
        //Get the Store Visit 
        CVS_Store_Visit__c sv = [SELECT Id, Name__c, Account_Name__c FROM CVS_Store_Visit__c LIMIT 1];
        
        Test.startTest();
        update sv;
        Test.stopTest();
        
        System.assertEquals('Test Account', sv.Name__c, 'Name does not match');
    }
}
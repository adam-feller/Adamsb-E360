@isTest
public class MerchChecklistDAOTest {

    @TestSetup
    private static void setup(){
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '12345');
        Merch_Checklist__c mc = new Merch_Checklist__c(Requested_Completion_Date__c=System.today(), Account__c = testAccount.Id);
        insert mc;
    }

    static Account getAccount() {
        return [SELECT Id, Name
                FROM Account
                LIMIT 1];
    }
    
    static Merch_Checklist__c getMerchChecklist() {
        return [SELECT Id
                FROM Merch_Checklist__c
                LIMIT 1];
    }
       
    @isTest
    static void testGetMerchChecklistsByAccountIds(){
        Account testAccount = getAccount();

        Test.startTest();
        List<Merch_Checklist__c> merchList = MerchChecklistDAO.getMerchChecklistsByAccountIds(new Set<Id>{testAccount.Id});
        MerchChecklistDAO.updateMerchChecklists(merchList);
        Test.stopTest();

        System.assertEquals(1, merchList.size(), '1 record should be returned');
    }
    
    @IsTest
    static void testGetMerchChecklistById(){
		Merch_Checklist__c testChecklist = getMerchChecklist();

        Test.startTest();
        Merch_Checklist__c merchChecklist = MerchChecklistDAO.getMerchChecklistById(testChecklist.Id);        
        Test.stopTest();

        System.assertNotEquals(null, merchChecklist, 'Merch Checklist should have been returned');
    }
}
@isTest
public class AccountDeepLinkControllerTest {

    @TestSetup
    private static void setup(){
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '12345');
        testAccount.ExternalId__c = 'PVA*201';
        testAccount.Account_Manager_Route__c = '300';
        update testAccount;
    }

    static Account getAccount(String Name){
        return [SELECT Id, Name, ExternalId__c FROM Account LIMIT 1];
    }

    @isTest
    static void testMaxerienceDeepLink() {
        Account testAccount = getAccount('Test Account');

        Test.startTest();
            String url = AccountDeepLinkController.getMaxerienceDeepLink(testAccount.Id);        	
        Test.stopTest();
        
        System.assert(url.contains('PVA*201'), 'URL should contain External Id');
    }

    @isTest
    static void testGetMaxerienceDeepLinkNull() {
        Test.startTest();
            String url = AccountDeepLinkController.getMaxerienceDeepLink(null);
        Test.stopTest();

        System.assertEquals(null, url, 'URL should be null');
    }
    
    @isTest
    static void testGetDesignStudioDeepLink() {
        Account testAccount = getAccount('Test Account');

        Test.startTest();
            String url = AccountDeepLinkController.getDesignStudioDeepLink(testAccount.Id);
        Test.stopTest();

        System.assert(url.contains('201'), 'URL should contain VIP Account Number');
    }
    
	@isTest
    static void testGetDesignStudioDeepLinkNull() {
        Test.startTest();
            String url = AccountDeepLinkController.getDesignStudioDeepLink(null);
        Test.stopTest();

        System.assertEquals(null, url, 'URL should be null');
    }    
}
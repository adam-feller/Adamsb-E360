@isTest
private class VIPOrderEntryControllerTest {

    @TestSetup
    private static void setup(){
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '12345');
    }

    static Account getAccount(String Name){
        return [SELECT Id, Name, VIP_Account_Number__c
                FROM Account
                LIMIT 1];
    }

    @isTest
    static void testGetAccountCode(){
        Account testAccount = getAccount('Test Account');

        Test.startTest();
            String accountCode = VIPOrderEntryController.getAccountCode(testAccount.Id);
        Test.stopTest();

        System.assertEquals(accountCode, '201', 'Account code should be 201');
    }

    @isTest
    static void testGetAccountCodeNull(){
        Test.startTest();
            String accountCode = VIPOrderEntryController.getAccountCode(null);
        Test.stopTest();

        System.assertEquals(accountCode, null, 'Account code should be null');
    }
}
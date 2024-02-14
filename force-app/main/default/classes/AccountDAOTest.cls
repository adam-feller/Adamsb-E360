@isTest
private class AccountDAOTest {

    @TestSetup
    private static void setup(){
        Account testParentAccount = TestFactory.createAccount('Test Parent Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '12345');
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', testParentAccount.Id, '2345');
        TestFactory.createGreenmileRetailStore('Test Greenmile Retail Store', 'HDI', 'PA751');
    }

    static Account getAccount(String Name){
        return [SELECT Id, Name
                FROM Account
                LIMIT 1];
    }

    static Account getGreenmileRetailStore(String storenumber){
        return [SELECT Id, Name, VIP_Account_Number__c, Beer_Company__c, Warehouse__c, VIP_Composite_Key__c
                FROM Account
                WHERE VIP_Composite_Key__c = :storenumber
                LIMIT 1];
    }

    static Account getAccountByExternalId(String storenumber){
        return [SELECT Id, Name, VIP_Account_Number__c, Beer_Company__c, Warehouse__c, VIP_Composite_Key__c, ExternalId__c
                FROM Account
                WHERE ExternalId__c = :storenumber
                LIMIT 1];
    }

    @isTest
    static void testGetAccountsByIds(){
        Account testAccount = getAccount('Test Account');

        Test.startTest();
            List<Account> accountList = AccountDAO.getAccountsByIds(new Set<Id>{testAccount.Id});
        Test.stopTest();

        System.assertEquals(accountList.size(), 1, 'accountList should return 1 record');
    }

    @isTest
    static void testGetStoreNumberById() {
        Account testRetailStore = getGreenmileRetailStore('HDIPA751');

        Test.startTest();
            String result = AccountDAO.getStoreNumberById(testRetailStore.Id);
        Test.stopTest();

        System.assertEquals(result, 'HDIPA751', 'A store number is returned');
    }

    @isTest
    static void testGetRetailStoreByStoreNumber() {
        Account testRetailStore = getAccountByExternalId('72245');

        Test.startTest();
            Set<String> storeNumber = new Set<String>();
            storeNumber.add('72245');
            Map<String, Account> result = AccountDAO.getRetailStoreByStoreNumber(storeNumber);
        Test.stopTest();

        System.assertEquals(result.size(), 1, 'A Map of Store is returned');
    }

    @isTest
    static void testGetAccountByParentAccountIds() {
        Account testParentAccount = getAccount('Test Parent Account');

        Test.startTest();
            List<Account> accountList = AccountDAO.getAccountByParentAccountIds(new List<String>{testParentAccount.Id});
        Test.stopTest();

        System.assertEquals(accountList.size(), 1, '1 record should be returned');
    }

    @isTest
    static void testGetAccountsByExternalIds() {
        Account testParentAccount = getAccount('testAccount');

        Test.startTest();
            List<Account> accountList = AccountDAO.getAccountsByExternalIds(new Set<String>{'72245'});
        Test.stopTest();

        System.assertEquals(accountList.size(), 2, '2 records should be returned');
    }

    @isTest
    static void testUpdateAccounts(){
        Account testAccount = getAccount('Test Account');
        testAccount.Name = 'Test Account Update';

        Test.startTest();
            List<Account> accountList = AccountDAO.updateAccounts(new List<Account>{testAccount});
        Test.stopTest();

        List<Account> accountReturned = [SELECT Id FROM Account WHERE Name = 'Test Account Update'];

        System.assertEquals(accountReturned.size(), 1, 'accountList should return 1 record');
    }
}
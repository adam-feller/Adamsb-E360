@isTest
private class RetailStoreDAOTest {

    @TestSetup
    private static void setup(){
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2346');
        Account testGreenmileAccount = TestFactory.createAccount('Test Greenmile Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        Schema.Location testLocation = TestFactory.createLocation('Test Location', 'Site');
        Schema.Location testGreenmileLocation = TestFactory.createLocation('Test Greenmile Location', 'Site');
        TestFactory.createRetailStore('Test Retail Store', testAccount.Id, testLocation.Id, '201', 'CBS', 'PDVA-CHANTILLY');
        TestFactory.createGreenmileRetailStore('Test Greenmile Retail Store', testGreenmileAccount.Id, testGreenmileLocation.Id, '201', 'CBS', 'PDVA-CHANTILLY', 'HDI', 'PA751');
    }

    static Account getAccount(){
        return [SELECT Id, Name
                FROM Account
                LIMIT 1];
    }

    static RetailStore getRetailStore(){
        return [SELECT Id, Name, VIP_Account_Number__c, Beer_Company__c, Warehouse__c
                FROM RetailStore
                LIMIT 1];
    }

    static RetailStore getGreenmileRetailStore(String storenumber){
        return [SELECT Id, Name, VIP_Account_Number__c, Beer_Company__c, Warehouse__c, VIP_Composite_Key__c
                FROM RetailStore
                WHERE VIP_Composite_Key__c = :storenumber
                LIMIT 1];
    }

    @isTest
    static void testGetRetailStoreByIds(){
        RetailStore testRetailStore = getRetailStore();

        Test.startTest();
            List<RetailStore> retailStoreList = RetailStoreDAO.getRetailStoreByIds(new Set<Id>{testRetailStore.Id});
        Test.stopTest();

        System.assertEquals(retailStoreList.size(), 1, 'retailStoreList should return 1 record');
    }

    
    @isTest
    static void testGetRetailStoreByBUAndWarehouse(){
        Test.startTest();
            List<RetailStore> retailStoreList = RetailStoreDAO.getRetailStoreByBUAndWarehouse(new List<String>{'CBS'}, 
                                                                                                new List<String>{'PDVA-CHANTILLY'});
        Test.stopTest();

        System.assertEquals(retailStoreList.size(), 1, 'retailStoreList should return 1 record');
    }
    
    
    @isTest
    static void testGetRetailStoreByAccountIds(){
        Account testAccount = getAccount();

        Test.startTest();
            List<RetailStore> retailStoreList = RetailStoreDAO.getRetailStoreByAccountIds(new List<String>{testAccount.Id});
        Test.stopTest();

        System.assertEquals(retailStoreList.size(), 1, 'retailStoreList should return 1 record');
    }
    

    @isTest
    static void testGetStoreNumberById() {
        RetailStore testRetailStore = getGreenmileRetailStore('HDIPA751');

        Test.startTest();
            String result = RetailStoreDAO.getStoreNumberById(testRetailStore.Id);
        Test.stopTest();

        System.assertEquals(result, 'HDIPA751', 'A store number is returned');
    }

    @isTest
    static void testGetRetailStoreByStoreNumber() {
        RetailStore testRetailStore = getGreenmileRetailStore('HDIPA751');

        Test.startTest();
            Set<String> storeNumber = new Set<String>();
            storeNumber.add('HDIPA751');
            Map<String, RetailStore> result = RetailStoreDAO.getRetailStoreByStoreNumber(storeNumber);
        Test.stopTest();

        System.assertEquals(result.size(), 1, 'A Map of Store is returned');
    }
}
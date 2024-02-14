@isTest
private class BatchProcessObjectiveLocationsTest {

    @TestSetup
    private static void setup() {       
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        UserRole preSalesRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Admin'];
        UserRole salesManagerRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Admin'];
        User testSalesManager = TestFactory.createUser(systemAdminProfile.Id, salesManagerRole.Id, 'newtest3User@gmail.com', null);
        TestFactory.createUser(systemAdminProfile.Id, preSalesRole.Id, 'newtest2User@gmail.com', testSalesManager.Id);

        System.runAs(testSalesManager) {
            //Set up for Non-CBS
            Account testAccount = TestFactory.createAccount('Test Parent Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '12345');       //Parent
            testAccount.Territories__c = '10';
            update testAccount;
            Account testAccount2 = TestFactory.createAccount('Test Account', '202', 'PVA', 'PDVA-CHANTILLY', testAccount.Id, '12346');   //Child
            testAccount2.Territories__c = '10';
            update testAccount2;
            Objective__c testObjective = TestFactory.createObjective('Test Objective', 'PVA', 'Display');            
            Product2 testProd = TestFactory.createProduct('Test Product', '12345', 'MillerCoors', '123*B');
            TestFactory.createObjectiveLocation(testObjective.Id, 'PVA', 'PDVA-CHANTILLY', 100);
            TestFactory.createObjectiveProduct(testObjective.Id, testProd.Id);
            //Set up for CBS
            Account testAccount3 = TestFactory.createAccount('Test Account CBS', '202', 'CBS', 'CBS CHICAGO', null, '12347');                //Parent CBS
            testAccount3.VIP_Instance__c = 'CBS';
            testAccount3.Territories__c = '10';
            update testAccount3;
            Objective__c testObjective2 = TestFactory.createObjective('Test Objective - CBS', 'CBS', 'Display');
			Product2 testProd2 = TestFactory.createProduct('Test Product2', '12346', 'Miller', '124*B');
            TestFactory.createObjectiveLocation(testObjective2.Id, 'CBS', 'CBS CHICAGO', 100);
            TestFactory.createObjectiveProduct(testObjective2.Id, testProd2.Id);
        }
    }

    static Objective__c getObjective(){
        return [SELECT Id, Name, Picture_Required__c
                FROM Objective__c WHERE NOT Name LIKE '%CBS%'
                LIMIT 1];
    }

    static Objective__c getObjectiveCBS(){
        return [SELECT Id, Name, Picture_Required__c
                FROM Objective__c WHERE Name LIKE '%CBS%'
                LIMIT 1];
    }
    
    static Objective_Location__c getObjectiveLocation(){
        return [SELECT Id, Objective__c
                FROM Objective_Location__c WHERE NOT BU__c LIKE '%CBS%'
                LIMIT 1];
    }

    static Objective_Location__c getObjectiveLocationCBS(){
        return [SELECT Id, Objective__c
                FROM Objective_Location__c WHERE BU__c LIKE '%CBS%'
                LIMIT 1];
    }
    
    static User getUserbyUsername(String username){
        return [SELECT Id, Name, UserRoleId, Goal_Amount__c
                FROM User
                WHERE Username = :username
                LIMIT 1];
    }

    static Account getAccount(String Name){
        return [SELECT Id, Name, VIP_Account_Number__c, Beer_Company__c, Warehouse__c, Territories__c
                FROM Account
                WHERE Name = :name
                LIMIT 1];
    }

    static Product2 getProduct(){
        return [SELECT Id, Name, SKU__c
                FROM Product2
                LIMIT 1];
    }

    @isTest
    static void testBatchProcessObjectiveLocations(){
        Objective__c testObjective = getObjective();
        Objective_Location__c testObjLoc = getObjectiveLocation();

        Test.startTest();
            BatchProcessObjectiveLocations batchProcessObjectiveLocation = new BatchProcessObjectiveLocations();
            batchProcessObjectiveLocation.query = 'SELECT Id, Name, VIP_Instance__c, Warehouse__c, OwnerId FROM Account';
            batchProcessObjectiveLocation.objectiveId = testObjective.Id;
            batchProcessObjectiveLocation.objectiveLocationMap = new Map<String, String>{'PVA' => testObjLoc.Id};
            batchProcessObjectiveLocation.objectiveType = 'Display';
            batchProcessObjectiveLocation.pictureRequired = false;
            Database.executeBatch(batchProcessObjectiveLocation);
        Test.stopTest();

        
		List<Account> accList = [SELECT Id FROM Account WHERE NOT Name LIKE '%CBS%'];
        Set<Id> accIds = new Set<Id>();
        for (Account a : accList) {
            accIds.add(a.Id);
        }
        List<Objective_Account__c> objectiveAccountsCreated = [SELECT Id FROM Objective_Account__c WHERE Account__r.Id IN :accIds];
        System.assertEquals(2, objectiveAccountsCreated.size(), '2 Objective Accounts should be created');
    }

	@isTest
    static void testBatchProcessObjectiveLocationsCBS() {
        Objective__c testObjective = getObjectiveCBS();
        Objective_Location__c testObjLoc = getObjectiveLocationCBS();

        Test.startTest();
            BatchProcessObjectiveLocations batchProcessObjectiveLocation = new BatchProcessObjectiveLocations();
            batchProcessObjectiveLocation.query = 'SELECT Id, Name, VIP_Instance__c, Warehouse__c, OwnerId FROM Account';
            batchProcessObjectiveLocation.objectiveId = testObjective.Id;
            batchProcessObjectiveLocation.objectiveLocationMap = new Map<String, String>{'CBS' => testObjLoc.Id};
            batchProcessObjectiveLocation.objectiveType = 'Display';
            batchProcessObjectiveLocation.pictureRequired = false;
            Database.executeBatch(batchProcessObjectiveLocation);
        Test.stopTest();

        
		List<Account> accList = [SELECT Id FROM Account WHERE Name LIKE '%CBS%'];
        Set<Id> accIds = new Set<Id>();
        for (Account a : accList) {
            accIds.add(a.Id);
        }
        List<Objective_Account__c> objectiveAccountsCreated = [SELECT Id FROM Objective_Account__c WHERE Account__r.Id IN :accIds];
        System.assertEquals(1, objectiveAccountsCreated.size(), '1 Objective Account should be created');
    }    
    
    @isTest
    static void testBatchProcessObjectiveLocationsWithExistingObjectiveAccounts() {
        Territory_Matching__c terrMatchingCustomSetting = new Territory_Matching__c();
        terrMatchingCustomSetting.Territory_Matching__c = true;
        insert terrMatchingCustomSetting;
        Objective__c testObjective = getObjective();
        Objective_Location__c testObjLoc = getObjectiveLocation();
        List<Account> accList = [SELECT Id FROM Account WHERE NOT Name LIKE '%CBS%'];
        Set<Id> accIds = new Set<Id>();
        for (Account a : accList) {
            accIds.add(a.Id);
        	Objective_Account__c testObjAcc = TestFactory.createObjectiveAccount(testObjective.Id, 'Incomplete', a.Id);    //Create Objective Accounts so they already exists before the job runs
        }

        Test.startTest();
            BatchProcessObjectiveLocations batchProcessObjectiveLocation = new BatchProcessObjectiveLocations();
            batchProcessObjectiveLocation.query = 'SELECT Id, Name, VIP_Instance__c, Warehouse__c, SalesOrg__c, OwnerId, Territories__c FROM Account';
            batchProcessObjectiveLocation.objectiveId = testObjective.Id;
            batchProcessObjectiveLocation.objectiveLocationMap = new Map<String, String>{'PVA' => testObjLoc.Id};
            batchProcessObjectiveLocation.objectiveType = 'Display';
            batchProcessObjectiveLocation.pictureRequired = false;
            Database.executeBatch(batchProcessObjectiveLocation);
        Test.stopTest();

        List<Objective_Account__c> objectiveAccountsCreated = [SELECT Id FROM Objective_Account__c WHERE Account__r.Id IN :accIds];
        System.assertEquals(2, objectiveAccountsCreated.size(), '2 Objective Accounts should be created');
    }    

    @isTest
    static void testBatchProcessObjectiveLocationsTerritoryMatching(){
        Objective__c testObjective = getObjective();
        Objective_Location__c testObjLoc = getObjectiveLocation();
        Territory_Matching__c terrMatchingCustomSetting = new Territory_Matching__c();
        terrMatchingCustomSetting.Territory_Matching__c = true;
        insert terrMatchingCustomSetting;

        Test.startTest();
            BatchProcessObjectiveLocations batchProcessObjectiveLocation = new BatchProcessObjectiveLocations();
        	batchProcessObjectiveLocation.query = 'SELECT Id, Name, VIP_Instance__c, Warehouse__c, SalesOrg__c, OwnerId, Territories__c FROM Account';
            batchProcessObjectiveLocation.objectiveId = testObjective.Id;
            batchProcessObjectiveLocation.objectiveLocationMap = new Map<String, String>{'PVA' => testObjLoc.Id};
            batchProcessObjectiveLocation.objectiveType = 'Display';
            batchProcessObjectiveLocation.pictureRequired = false;
            Database.executeBatch(batchProcessObjectiveLocation);
        Test.stopTest();

        List<Account> accList = [SELECT Id FROM Account WHERE NOT Name LIKE '%CBS%'];
        Set<Id> accIds = new Set<Id>();
        for (Account a : accList) {
            accIds.add(a.Id);
        }
        List<Objective_Account__c> objectiveAccountsCreated = [SELECT Id FROM Objective_Account__c WHERE Account__r.Id IN :accIds];
        System.assertEquals(2, objectiveAccountsCreated.size(), '2 objective accounts should be created');
    }
}
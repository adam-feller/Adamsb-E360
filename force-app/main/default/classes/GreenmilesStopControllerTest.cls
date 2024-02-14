@isTest
private with sharing class GreenmilesStopControllerTest {

    @TestSetup
    static void setup(){
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        Profile merchProfile = [SELECT Id FROM Profile WHERE Name = 'Merchandiser'];
        UserRole adminRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Admin'];
        User testAdmin = TestFactory.createUser(systemAdminProfile.Id, adminRole.Id, 'newtest2User@gmail.com', UserInfo.getUserId());
        User testMerch = TestFactory.createUser(merchProfile.Id, adminRole.Id, 'merchuser@gmail.com', UserInfo.getUserId());
        System.runAs(testAdmin){
            TestFactory.createGreenmileRetailStore('Test Greenmile Retail Store', 'HDI', 'PA751');
        }
    }

    static Account getRetailStore(){
        return [SELECT Id, Name, VIP_Account_Number__c, Beer_Company__c, Warehouse__c, Store_Number__c, ExternalId__c
                FROM Account
                LIMIT 1];
    }

    static Account getGreenmileRetailStore(String storenumber){
        return [SELECT Id, Name, VIP_Account_Number__c,  Beer_Company__c, Warehouse__c, VIP_Composite_Key__c, ExternalId__c
                FROM Account
                WHERE VIP_Composite_Key__c = :storenumber
                LIMIT 1];
    }

    static User getUserbyUsername(String username){
        return [SELECT Id, Name, UserRoleId, Goal_Amount__c
                FROM User
                WHERE Username = :username
                LIMIT 1];
    }
   
    @isTest
    static void testCheckMerchAcknowledgement() {
        User testUser = getUserbyUsername('merchuser@gmail.com');
        testUser.VIP_Company__c = 'HDI';   //This is a West Coast VIP Instance
        update testUser;
        Boolean result;
        
        System.runAs(testUser){
            Test.startTest();
                result = GreenmilesStopController.checkMerchAcknowledgement();
            Test.stopTest();
        }

        //Assertion
        System.assertEquals(true, result, 'Should have triggered the Acknowledgement');
    }

    @isTest
    static void testSetMerchAcknowledgement() {
        User testUser = getUserbyUsername('merchuser@gmail.com');
        testUser.VIP_Company__c = 'HDI';   //This is a West Coast VIP Instance
        update testUser;        
        
        System.runAs(testUser){
            Test.startTest();
                GreenmilesStopController.setMerchAcknowledgement();
            Test.stopTest();
        }
		//Assertion
		User checkUser = [SELECT Last_Merch_Acknowledgement__c FROM User WHERE Username = 'merchuser@gmail.com'];
        System.assertNotEquals(null, checkUser.Last_Merch_Acknowledgement__c, 'Should have set the Last Acknowledgement');
    }
    
    @isTest
    static void testGetBusinessUnits() {
        List<String> buOptions;
        Test.startTest();
                buOptions = GreenmilesStopController.getBusinessUnits();
        Test.stopTest();
        
        //Assertion
        System.assertNotEquals(0, buOptions.size(), 'Should have found Business Units');
    }
    
    @isTest
    static void testGetGreenmilesStopByUser() {
        User testUser = getUserbyUsername('newtest2User@gmail.com');
        testUser.FederationIdentifier = 'testing';
        update testUser;

        Test.setMock(HttpCalloutMock.class, new GreenmilesAPICalloutMock());

        List<GreenmilesStopController.GreenmileStopViewWrapper> result = new List<GreenmilesStopController.GreenmileStopViewWrapper>();

        System.runAs(testUser){
            Test.startTest();
                result = GreenmilesStopController.getGreenmilesStopByUser(null, null, 'HDI');
            Test.stopTest();
        }

        System.assertEquals('2260832', result[0].routeId, 'Route information with id is returned');
    }

    @isTest
    static void testGetGreenmilesStopByRetailStoreId() {

        Account testRetailStore = getGreenmileRetailStore('HDIPA751');

        Test.setMock(HttpCalloutMock.class, new GreenmilesAPICalloutMock());

        Test.startTest();
            String result = GreenmilesStopController.getGreenmilesStopByRetailStoreId(testRetailStore.Id, 5);
        Test.stopTest();
        GreenmilesStopController.GreenmileStopSummaryWrapper actualValue =   
        (GreenmilesStopController.GreenmileStopSummaryWrapper)JSON.deserialize(result, GreenmilesStopController.GreenmileStopSummaryWrapper.class);

        System.assertEquals(true, actualValue.totalRecord > 0, 'There are stops found');
    }
    
}
@isTest
private class GreenmilesAPICalloutTest {

    @TestSetup
    private static void setup(){
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        UserRole testUserRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Admin'];
        TestFactory.createUser(systemAdminProfile.Id, testUserRole.Id, 'newtest2User@gmail.com', null, 'FedId');
    }

    static User getUserbyUsername(String username){
        return [SELECT Id, Name, UserRoleId, Goal_Amount__c
                FROM User
                WHERE Username = :username
                LIMIT 1];
    }

    static User getUserbyFederatedId(String FederatedId){
        return [SELECT Id, Name, UserRoleId, Goal_Amount__c, FederationIdentifier
                FROM User
                WHERE FederationIdentifier = :FederatedId
                LIMIT 1];
    }

    @isTest
    static void testCallout() {

        Test.setMock(HttpCalloutMock.class, new GreenmilesAPICalloutMock());
        Map<String, String> header = new Map<String, String>();
        header.put('Content-Type', 'application/json');
        Test.startTest();
            HttpResponse result = GreenmilesAPICallout.callout('GET', 'http://localhost', 'test', header);
        Test.stopTest();

        System.assertEquals(200, result.getStatusCode(), 'The callout was successful');

    }
    
    @isTest
    static void testGetVisitByUserLoginAndDate() {

        Test.setMock(HttpCalloutMock.class, new GreenmilesAPICalloutMock());
        Map<String, String> header = new Map<String, String>();
        header.put('Content-Type', 'application/json');
        Test.startTest();
        List<GreenmileRouteInfo> result = GreenmilesAPICallout.getVisitByUserLoginAndDate('FedId', '2020-05-14');
        Test.stopTest();

        System.assertEquals(2260832, result[0].id, 'Route information with id is returned');

    }

    @isTest
    static void testGetVisitByRouteAndDate() {

        Test.setMock(HttpCalloutMock.class, new GreenmilesAPICalloutMock());
        Map<String, String> header = new Map<String, String>();
        header.put('Content-Type', 'application/json');
        Test.startTest();
            List<GreenmileRouteInfo> result = GreenmilesAPICallout.getVisitByRouteAndDate('3193841', '2020-05-14');
        Test.stopTest();

        System.assertEquals(2260832, result[0].id, 'Route information with id is returned');

    }

    @isTest
    static void testGetGreenmileRouteInfoByStoreNumberAndDateRange() {

        Test.setMock(HttpCalloutMock.class, new GreenmilesAPICalloutMock());
        Map<String, String> header = new Map<String, String>();
        header.put('Content-Type', 'application/json');
        Test.startTest();
            List<GreenmileRouteInfo> result = GreenmilesAPICallout.getGreenmileRouteInfoByStoreNumberAndDateRange('HDI60308', '2020-04-14', '2020-05-14');
        Test.stopTest();

        System.assertEquals(2260832, result[0].id, 'Route information with id is returned');

    }
    
}
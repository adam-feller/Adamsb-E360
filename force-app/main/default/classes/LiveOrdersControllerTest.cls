@isTest
private class LiveOrdersControllerTest {

    @TestSetup
    private static void setup(){
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        UserRole testUserRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Admin'];
        TestFactory.createUser(systemAdminProfile.Id, testUserRole.Id, 'newtest2User@gmail.com', null, 'FedId');
    }

    static User getUserbyUsername(String username){
        return [SELECT Id, Name, UserRoleId, Goal_Amount__c, Email
                FROM User
                WHERE Username = :username
                LIMIT 1];
    }

    @isTest
    static void testGetUserDetails(){
        User testUser = getUserbyUsername('newtest2User@gmail.com');

        User userObj = new User();
        System.runAs(testUser){
            Test.startTest();
                userObj = LiveOrdersController.getUserDetails();
            Test.stopTest();
        }

        System.assertEquals(userObj.Email, 'externaluser@gmail.com', 'email of returned used should be externaluser@gmail.com');
    }
}
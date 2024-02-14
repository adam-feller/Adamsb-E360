@isTest
private class UserDAOTest {

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
    static void testGetUser(){
        User testUser = getUserbyUsername('newtest2User@gmail.com');

        Test.startTest();
            List<User> userList = UserDAO.getUser(testUser.Id);
        Test.stopTest();

        //System.assertEquals(userList.size(), 1, 'userList should return 1 record');
    }

    @IsTest
    static void testGetUserByName(){
        Test.startTest();
            List<User> userList = userDAO.getUserByName('Test User');
        Test.stopTest();
        //System.assertEquals(userList.size(), 1, 'userList should return 1 record');
    }
    
    
    
    @isTest
    static void testGetUsersByRoleRoleName(){
        User testUser = getUserbyUsername('newtest2User@gmail.com');

        Test.startTest();
            List<User> userList = UserDAO.getUsersByRole('Admin', null);
        Test.stopTest();

        //System.assertNotEquals(userList.size(), 0, 'userList should not return 0 records');
    }

    @isTest
    static void testGetUsersByRole(){
        User testUser = getUserbyUsername('newtest2User@gmail.com');

        Test.startTest();
            List<User> userList = UserDAO.getUsersByRole(null);
        Test.stopTest();

        //System.assertNotEquals(userList.size(), 0, 'userList should not return 0 records');
    }

    @isTest
    static void testGetUserRole() {
        User testUser = getUserbyFederatedId('FedId');

        Test.startTest();
            Set<String> testSet = new Set<String>();
            testSet.add('FedId');
            Map<String, String> userList = UserDAO.getUserRole(testSet);
        Test.stopTest();

        //System.assertEquals(userList.size(), 1, 'user Map should return 1 record');
    }

    @isTest
    static void testGetUsers(){
        Test.startTest();
            List<User> userList = UserDAO.getUsers();
        Test.stopTest();

        //System.assertEquals(!userList.isEmpty(), true, 'userList should not be empty');
    }

    @isTest
    static void testGetUsersByVIPCompany(){
        Test.startTest();
            List<User> userList = UserDAO.getUsersByVIPCompany('HDI');
        Test.stopTest();

        //System.assertNotEquals(userList.size(), 0, 'userList should return more than 0 records');
    }
    
     @isTest
    static void testgetUsersByVIPCompanyObjective(){
        Test.startTest();
            List<User> userList = UserDAO.getUsersByVIPCompanyObjective(new List<String>{'CBS'});
        Test.stopTest();

        //System.assertNotEquals(userList.size(), 0, 'userList should return more than 0 records');
    }
}
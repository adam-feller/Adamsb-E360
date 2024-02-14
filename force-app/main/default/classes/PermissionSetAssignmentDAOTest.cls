@isTest
private class PermissionSetAssignmentDAOTest {

    @TestSetup
    private static void setup(){
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        UserRole testUserRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Admin'];
        User testUser = TestFactory.createUser(systemAdminProfile.Id, testUserRole.Id, 'newtest2User@gmail.com', null, 'FedId');
        List<PermissionSet> permissionSetList = [SELECT Id FROM PermissionSet WHERE Label = 'National Objective Admin'];
        TestFactory.createPermissionSetAssignment(permissionSetList[0].Id, testUser.Id);
    }

    static User getUserbyUsername(String username){
        return [SELECT Id, Name, UserRoleId, Goal_Amount__c
                FROM User
                WHERE Username = :username
                LIMIT 1];
    }

    @isTest
    static void testGetPermissionSetAssignmentsByUserId(){
        User testUser = getUserbyUsername('newtest2User@gmail.com');

        Test.startTest();
            List<PermissionSetAssignment> permissionSetAssignmentList = PermissionSetAssignmentDAO.getPermissionSetAssignmentsByUserId(testUser.Id);
        Test.stopTest();

        System.assertEquals(permissionSetAssignmentList.size(), 2, 'permissionSetAssignmentList should return 2 records');
    }
}
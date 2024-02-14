@isTest
private class PermissionSetDAOTest {

    @isTest
    static void testGetPermissionSetByIdsAndName(){
        List<PermissionSet> permissionSetsReturned = [SELECT Id FROM PermissionSet WHERE Label = 'National Objective Admin'];

        Test.startTest();
            List<PermissionSet> permissionSetList = PermissionSetDAO.getPermissionSetByIdsAndName(new Set<Id>{permissionSetsReturned[0].Id});
        Test.stopTest();

        System.assertEquals(permissionSetList.size(), 1, 'permissionSetList should return 1 record');
    }
}
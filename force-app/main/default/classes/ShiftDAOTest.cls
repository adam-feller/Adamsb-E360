@isTest
private class ShiftDAOTest {

    @TestSetup
    private static void setup(){
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        UserRole testUserRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Admin'];
        User testSalesManager = TestFactory.createUser(systemAdminProfile.Id, testUserRole.Id, 'newtest34673454User@gmail.com', null);
        System.runAs(testSalesManager){
            TestFactory.createShift(testSalesManager.Id, Time.newInstance(18, 30, 2, 20), Time.newInstance(19, 30, 2, 20));
        }
    }

    @isTest
    static void testGetShifts() {
        Test.startTest();
            List<Shift__c> shiftList = ShiftDAO.getShifts();
        Test.stopTest();

        System.assertEquals(shiftList.size(), 1, '1 record found');
    }
}
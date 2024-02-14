@isTest
private class OutOfOfficeDAOTest {

    @TestSetup
    private static void setup(){
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        UserRole testUserRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Admin'];
        User testSalesManager = TestFactory.createUser(systemAdminProfile.Id, testUserRole.Id, 'newtest34673454User@gmail.com', null);
        System.runAs(testSalesManager){
            TestFactory.createOutOfOffice(testSalesManager.Id, System.today(), System.today() + 1);
        }
    }

    @isTest
    static void testGetOutOfOffices() {
        Test.startTest();
            List<Out_Of_Office__c> outOfOfficeList = OutOfOfficeDAO.getOutOfOffices(System.today(), System.today() + 1);
        Test.stopTest();

        System.assertEquals(outOfOfficeList.size(), 1, '1 record found');
    }
}
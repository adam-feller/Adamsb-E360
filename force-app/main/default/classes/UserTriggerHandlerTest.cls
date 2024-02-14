@isTest
public class UserTriggerHandlerTest {

    @IsTest
    static void testSetManagerFlagsWhenManagerChanges() {
        Profile fieldSalesProfile = [SELECT Id FROM Profile WHERE Name = 'Field Sales'];
        UserRole testRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Admin'];
        
        User manager = [SELECT Id, VIP_Company__c, Assigned_Route__c FROM User WHERE Id = :UserInfo.getUserId()];
		manager.IsManager__c = false;
        update manager;

        User oldManager = TestFactory.createUser(fieldSalesProfile.Id, testRole.Id, 'slsMgrTest1@gmail.com', null);
		oldManager.IsManager__c = false;
        update oldManager;   
        
		Test.startTest();
        	User testDirectReport = TestFactory.createUser(fieldSalesProfile.Id, testRole.Id, 'slsMgrTest2@gmail.com', oldManager.Id);
        	testDirectReport.ManagerId = manager.Id;
        	update testDirectReport;        
        Test.stopTest();

        User checkUser = [SELECT Id, IsManager__c FROM User WHERE Id =:manager.Id];
        System.assertEquals(true, checkUser.IsManager__c, 'Manager Flag should be set to true');
        checkUser = [SELECT Id, IsManager__c FROM User WHERE Id =:oldManager.Id];
        System.assertEquals(false, checkUser.IsManager__c, 'Manager Flag should be set to false');
    }

}
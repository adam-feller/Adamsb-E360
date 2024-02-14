@IsTest
public class MerchRouteAssignmentHandlerTest {
    @TestSetup
    private static void setup(){
        User user = [SELECT Id, ProfileId, UserRoleId, ManagerId FROM User WHERE Id = :UserInfo.getUserId()];
        User storeMerch = [SELECT Id, ProfileId, UserRoleId FROM User WHERE Name = 'Store Merchandiser']; 
        User testMerch;
        User testMerch2;
        User testMerchMgr;
        System.runAs(user) {
            //Create Custom Setting
           	insert new Reyes_Org_Setting__c(Unassigned_Merch_Route_Owner_Id__c = storeMerch.Id);
            //Create Merchandiser Users
            testMerchMgr = TestFactory.createUser(user.ProfileId, user.UserRoleId, 'testMerchMgr@fakeemail.com', null, null);
            update testMerchMgr;
            testMerch = TestFactory.createUser(user.ProfileId, user.UserRoleId, 'testMerch@fakeemail.com', null, null);
            testMerch.Merch_Route__c = '1234';
            testMerch.VIP_Company__c = 'PVA';
            testMerch.ManagerId = testMerchMgr.Id;
            update testMerch;
            testMerch2 = TestFactory.createUser(user.ProfileId, user.UserRoleId, 'testMerch2@fakeemail.com', null, null);
            testMerch2.Merch_Route__c = '3456';
            testMerch2.VIP_Company__c = 'PVA';
            testMerch2.ManagerId = testMerchMgr.Id;
            update testMerch2;            
        }
       
        Account testAccount = TestFactory.createAccount('Test Account', '20135', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        testAccount.Merch_Route__c = '1234';
        update testAccount;
        
		Account testAccount2 = TestFactory.createAccount('Test Account', '20136', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        testAccount2.Merch_Route__c = '2345';
        update testAccount2;
    }
    
    static List<Account> getAccounts() {
        return [SELECT Id, Name, Merch_Route__c, Merchandiser__c, Merchandiser__r.Name, VIP_Instance__c, 
                (SELECT TeamMemberRole FROM AccountTeamMembers) FROM Account WHERE Name='Test Account'];
    }
    
    @IsTest
    static void userRouteChangesTest() {
        List<Account> accountList = getAccounts();
        Test.startTest();
            User user = [SELECT Id, VIP_Company__c, Merch_Route__c FROM User WHERE UserName = 'testMerch@fakeemail.com'];
            user.VIP_Company__c = 'PVA';
            user.Merch_Route__c = '2345';
            update user;        	
        Test.stopTest();
		//Assertion
        Account acc = [SELECT Merchandiser__c FROM Account WHERE Merch_Route__c = '2345'];   //Need to requery
        System.assertEquals(user.Id, acc.Merchandiser__c, 'Merchandiser should be same as first test user');       	
    }
    
    @IsTest
    static void userRouteChangesNoAccountTeamTest() {
        List<Account> accountList = getAccounts();
        User user;
        Test.startTest();
        	//Delete All Account Team Members
        	List<AccountTeamMember> atmList = [SELECT Id FROM AccountTeamMember];
        	delete atmList;
        	//Now update the user
        	User userRunAs = [SELECT Id, ProfileId, UserRoleId, ManagerId FROM User WHERE Id = :UserInfo.getUserId()];
        	System.runAs(userRunAs) {
	            user = [SELECT Id, VIP_Company__c, Merch_Route__c FROM User WHERE UserName = 'testMerch@fakeemail.com'];
	            user.VIP_Company__c = 'PVA';
	            user.Merch_Route__c = '2345';
	            update user;        	
            }
        Test.stopTest();
		//Assertion
        Account acc = [SELECT Merchandiser__c FROM Account WHERE Merch_Route__c = '2345'];   //Need to requery
        System.assertEquals(user.Id, acc.Merchandiser__c, 'Merchandiser should be same as first test user');       	
    }
    
    @IsTest
    static void userRouteChangesNoVIPTest() {
        List<Account> accountList = getAccounts();
        Test.startTest();
            User user = [SELECT Id, VIP_Company__c, Merch_Route__c FROM User WHERE UserName = 'testMerch@fakeemail.com'];
            user.VIP_Company__c = '';
            user.Merch_Route__c = '5432';
            update user;        	
        Test.stopTest();
        
		//Assertion
        Account acc = [SELECT Merchandiser__r.Name FROM Account WHERE Merch_Route__c = '1234'];   //Need to requery
        System.assertEquals('Store Merchandiser', acc.Merchandiser__r.Name, 'Merchandiser should be the generic user in setup');
    }
    
    @IsTest
    static void userRouteChangesNoManagerTest() {
        List<Account> accountList = getAccounts();

        Test.startTest();
            User user = [SELECT Id, VIP_Company__c, Merch_Route__c FROM User WHERE UserName = 'testMerch@fakeemail.com'];
            user.ManagerId = null;
            update user;        	
        Test.stopTest();
        
		//Assertion
        Account acc = [SELECT Merchandiser__c, (SELECT TeamMemberRole FROM AccountTeamMembers) FROM Account WHERE Merch_Route__c = '1234'];   //Need to requery
        System.assertEquals(1, acc.AccountTeamMembers.size(), 'Merchandiser Supervisor should no longer be on the Account Team');
    }
    
    @IsTest
    static void accountRouteChangesTestOpenRoute() {
        Account acc = [SELECT Merchandiser__r.Name FROM Account WHERE Merch_Route__c = '1234'];

        
        Test.startTest();                
      		//Change to a different open route
       		acc.Merch_Route__c = '2345';
       		update acc;
        Test.stopTest();
        
        //Assertion
        List<Account> accList = [SELECT Merchandiser__r.Name FROM Account WHERE Merch_Route__c = '2345'];   //Need to requery        
        System.assertEquals('Store Merchandiser', accList[0].Merchandiser__r.Name, 'Merchandiser should NOT be the generic user in setup');
    }
    
    @IsTest
    static void accountRouteChangesTestValidRoute() {
        Account acc = [SELECT Merchandiser__r.Name FROM Account WHERE Merch_Route__c = '1234'];

        Test.startTest();                
      		//Change to a different valid route      	
       		acc.Merch_Route__c = '3456';
       		update acc;
        Test.stopTest();
        
        //Assertion
        List<Account> accList = [SELECT Merchandiser__r.Name FROM Account WHERE Merch_Route__c = '3456'];   //Need to requery        
        System.assertNotEquals('Store Merchandiser', accList[0].Merchandiser__r.Name, 'Merchandiser should NOT be the generic user in setup');
    }

}
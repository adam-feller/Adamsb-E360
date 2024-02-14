@IsTest
public class AccountTeamControllerTest {

    static testMethod void AccountTeamControllerSalesRepTest() {
 		Account testAccount = TestFactory.createAccount('Test Account', '20135', 'PVA', 'PDVA-CHANTILLY', null, '2345');       
        User user = [Select Id FROM User WHERE Id = :UserInfo.getUserId()];
        //Sales Rep
        AccountTeamMember testAccountTeamMember = new AccountTeamMember();
        testAccountTeamMember.AccountId = testAccount.Id;
        testAccountTeamMember.UserId = user.Id;
        testAccountTeamMember.TeamMemberRole = 'Sales Rep';
        testAccountTeamMember.Sales_Pointer__c = '1';
        insert testAccountTeamMember;
        
                
        Test.StartTest();         
        List <AccountTeamController.TeamMemberData> testList = new List <AccountTeamController.TeamMemberData>();        
        Test.StopTest();

		testList = AccountTeamController.getAccountTeamData((String)testAccount.Id);
        System.assertEquals(1, testList.size(), '1 Team Member should be found');
    }
    
    static testMethod void AccountTeamControllerMerchandiserTest() {
 		Account testAccount = TestFactory.createAccount('Test Account', '20135', 'PVA', 'PDVA-CHANTILLY', null, '2345');       
        User user = [Select Id FROM User WHERE Id = :UserInfo.getUserId()];
        //Merchandiser
        AccountTeamMember testAccountTeamMember = new AccountTeamMember();
        testAccountTeamMember.AccountId = testAccount.Id;
        testAccountTeamMember.UserId = user.Id;
        testAccountTeamMember.TeamMemberRole = 'Merchandiser';
        insert testAccountTeamMember;
        
        Test.StartTest();         
        List <AccountTeamController.TeamMemberData> testList = new List <AccountTeamController.TeamMemberData>();        
        Test.StopTest();

		testList = AccountTeamController.getAccountTeamData((String)testAccount.Id);
        System.assertEquals(1, testList.size(), '1 Team Member should be found');
    }

}
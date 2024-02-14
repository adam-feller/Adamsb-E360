@IsTest
public class BSSTaskAssignmentControllerTest {
    @TestSetup
    private static void setup(){
        User user = [Select Id, ProfileId, UserRoleId FROM User WHERE Id = :UserInfo.getUserId()];
        User testRep;
        User testMerch;
        System.runAs(user) {
            testRep = TestFactory.createUser(user.ProfileId, user.UserRoleId, 'testRepBSSTtest@fakeemail.com', null, null);
            testMerch = TestFactory.createUser(user.ProfileId, user.UserRoleId, 'testRepBSSTtest@fakeemail2.com', null, null);
        }
       
        Account testAccount1 = TestFactory.createAccount('Test Account1', '20135', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        Account testAccount2 = TestFactory.createAccount('Test Account2', '20136', 'PVA', 'PDVA-CHANTILLY', null, '2346');
        
        List<AccountTeamMember> accountTeam = new List<AccountTeamMember>();
        
        AccountTeamMember account1TeamRep = new AccountTeamMember();
        account1TeamRep.AccountId = testAccount1.Id;
        account1TeamRep.UserId = testRep.Id;
        account1TeamRep.TeamMemberRole = 'Sales Rep';
        account1TeamRep.Sales_Pointer__c = '1';
        accountTeam.add(account1TeamRep);

        AccountTeamMember account1TeamManager = new AccountTeamMember();
        account1TeamManager.AccountId = testAccount1.Id;
        account1TeamManager.UserId = user.Id;
        account1TeamManager.TeamMemberRole = 'Sales Manager';
        account1TeamManager.Sales_Pointer__c = '1';
        accountTeam.add(account1TeamManager);

        AccountTeamMember account2TeamRep = new AccountTeamMember();
        account2TeamRep.AccountId = testAccount2.Id;
        account2TeamRep.UserId = user.Id;
        account2TeamRep.TeamMemberRole = 'Sales Rep';
        account2TeamRep.Sales_Pointer__c = '1';
        accountTeam.add(account2TeamRep);

        AccountTeamMember account2Merch = new AccountTeamMember();
        account2Merch.AccountId = testAccount2.Id;
        account2Merch.UserId = testMerch.Id;
        account2Merch.TeamMemberRole = 'Merchandiser';
        accountTeam.add(account2Merch);        
        
        insert accountTeam;        
    } 

    static List<Account> getAccount(){
        return [SELECT Id FROM Account];
    }


    static testMethod void getAccountTeamTest() {
        
        List<Account> accts = getAccount();
        
        Test.StartTest(); 
        
        List<BSSTaskAssignmentController.AcctTeamSelectionWrapper> dataList = new List<BSSTaskAssignmentController.AcctTeamSelectionWrapper>();
        for(Account acct : accts){
            BSSTaskAssignmentController.AcctTeamSelectionWrapper data = BSSTaskAssignmentController.getAccountTeam(acct.Id);
            dataList.add(data);
        }

        Test.StopTest();
        
        //Assertion
        for (BSSTaskAssignmentController.AcctTeamSelectionWrapper d : dataList) {
        	System.assertNotEquals(0, d.accountTeamMembers.size(), 'Account Team Members should have been found.');
        }
    }

}
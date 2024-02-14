@isTest
private class BatchDeleteAccountTeamsListTest {

    @TestSetup
    private static void setup(){
        User testUser = TestFactory.createUser(UserInfo.getProfileId(), UserInfo.getUserRoleId(), 'externalUser123421TEST@gmail.com', null, null);
        System.runAs(testUser){
            Account testAccount = TestFactory.createAccount('Test Account', '1234', 'HDI', null, null, '1234');
            TestFactory.createAccountTeamMember(testAccount.Id, testUser.Id, 'FSR');
        }
    }

    static AccountTeamMember getAccountTeamMember(){
        return [SELECT Id, UserId, AccountId
                FROM AccountTeamMember];
    }

    @isTest
    static void testBatchDeleteAccountTeamsList(){
        AccountTeamMember testAccountTeamMember = getAccountTeamMember();

        Test.startTest();
            BatchDeleteAccountTeamsList batchDeleteAccountTeam = new BatchDeleteAccountTeamsList();
            batchDeleteAccountTeam.accountTeamMembersToDelete = new List<AccountTeamMember>{testAccountTeamMember};
            batchDeleteAccountTeam.accountTeamMembersToInsert = new List<AccountTeamMember>();
            batchDeleteAccountTeam.accountIds = new Set<Id>();
            Database.executeBatch(batchDeleteAccountTeam);
        Test.stopTest();

        List<AccountTeamMember> accountTeamMembersReturned = [SELECT Id FROM AccountTeamMember];

        System.assertEquals(accountTeamMembersReturned.size(), 0, 'There should be no AccountTeamMember records returned');
    }
}
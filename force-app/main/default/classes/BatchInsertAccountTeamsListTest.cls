@isTest
private class BatchInsertAccountTeamsListTest {

    @TestSetup
    private static void setup(){
        User testUser = TestFactory.createUser(UserInfo.getProfileId(), UserInfo.getUserRoleId(), 'externalUser123421TEST@gmail.com', null, null);
        System.runAs(testUser){
            Account testAccount = TestFactory.createAccount('Test Account', '1234', 'HDI', null, null, '1234');
            Account testAccount2 = TestFactory.createAccount('Test Account2', '1235', 'HDI', null, null, '1235');
            TestFactory.createAccountTeamMember(testAccount.Id, testUser.Id, 'FSR');
        }
    }

    static Account getAccount(String name){
        return [SELECT Id, Name
                FROM Account
                WHERE Name = :name
                LIMIT 1];
    }

    static User getUser(String username){
        return [SELECT Id, Name
                FROM User 
                WHERE Username = :username
                LIMIT 1];
    }

    static AccountTeamMember getAccountTeamMember(){
        return [SELECT Id, UserId, AccountId
                FROM AccountTeamMember];
    }

    @isTest
    static void testBatchInsertAccountTeamsList(){
        Account testAccount = getAccount('Test Account2');
        User testUser = getUser('externalUser123421TEST@gmail.com');
        AccountTeamMember testAccountTeamMember = new AccountTeamMember();
        testAccountTeamMember.AccountId = testAccount.Id;
        testAccountTeamMember.UserId = testUser.Id;

        Test.startTest();
            BatchInsertAccountTeamsList batchInsertAccountTeam = new BatchInsertAccountTeamsList();
            batchInsertAccountTeam.accountTeamMembersToInsert = new List<AccountTeamMember>{testAccountTeamMember};
            batchInsertAccountTeam.accountIds = new Set<Id>{testAccount.Id};
            Database.executeBatch(batchInsertAccountTeam);
        Test.stopTest();

        List<AccountTeamMember> accountTeamMembersReturned = [SELECT Id FROM AccountTeamMember];

        System.assertEquals(accountTeamMembersReturned.size(), 2, 'There should be 2 AccountTeamMember records');
    }
}
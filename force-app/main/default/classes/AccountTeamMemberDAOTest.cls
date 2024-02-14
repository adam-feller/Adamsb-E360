@isTest
private class AccountTeamMemberDAOTest {

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
    static void testGetAccountTeamMembersByAccountIds(){
        Account testAccount = getAccount('Test Account');

        Test.startTest();
            List<AccountTeamMember> accountTeamMembers = AccountTeamMemberDAO.getAccountTeamMembersByAccountIds(new Set<Id>{testAccount.Id});
        Test.stopTest();

        System.assertEquals(1, accountTeamMembers.size(), 'There should be 1 AccountTeamMember record');
    }

    @isTest
    static void testGetAccountTeamMembersByAccountIdsAndRole(){
        Account testAccount = getAccount('Test Account');

        Test.startTest();
            List<AccountTeamMember> accountTeamMembers = AccountTeamMemberDAO.getAccountTeamMembersByAccountIdsAndRole(new Set<Id>{testAccount.Id}, new List<String>{'FSR'});
        Test.stopTest();

        System.assertEquals(1, accountTeamMembers.size(), 'There should be 1 AccountTeamMember record');
    }

    @isTest
    static void testGetAccountTeamMembersByUserIds(){
        User testUser = getUser('externalUser123421TEST@gmail.com');

        Test.startTest();
            List<AccountTeamMember> accountTeamMembers = AccountTeamMemberDAO.getAccountTeamMembersByUserIds(new Set<Id>{testUser.Id});
        Test.stopTest();

        System.assertEquals(1, accountTeamMembers.size(), 'There should be 1 AccountTeamMember record');
    }

    @isTest
    static void testInsertAccountTeamMember(){
        Account testAccount = getAccount('Test Account2');
        User testUser = getUser('externalUser123421TEST@gmail.com');
        AccountTeamMember testAccountTeamMember = new AccountTeamMember();
        testAccountTeamMember.AccountId = testAccount.Id;
        testAccountTeamMember.UserId = testUser.Id;

        Test.startTest();
            List<AccountTeamMember> accountTeamMembers = AccountTeamMemberDAO.insertAccountTeamMembers(new List<AccountTeamMember>{testAccountTeamMember});
        Test.stopTest();

        List<AccountTeamMember> accountTeamMembersReturned = [SELECT Id FROM AccountTeamMember];

        System.assertEquals(accountTeamMembersReturned.size(), 2, 'There should be 2 AccountTeamMember records');
    }

    @isTest
    static void testDeleteAccountTeamMember(){
        AccountTeamMember testAccountTeamMember = getAccountTeamMember();

        Test.startTest();
        List<AccountTeamMember> accountTeamMembers = AccountTeamMemberDAO.deleteAccountTeamMembers(new List<AccountTeamMember>{testAccountTeamMember});
        Test.stopTest();

        List<AccountTeamMember> accountTeamMembersReturned = [SELECT Id FROM AccountTeamMember];

        System.assertEquals(accountTeamMembersReturned.size(), 0, 'There should be no AccountTeamMember records returned');
    }
}
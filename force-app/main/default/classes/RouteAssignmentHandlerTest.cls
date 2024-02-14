@isTest
public class RouteAssignmentHandlerTest {
    @TestSetup
    private static void setup(){
        Account testAccount = TestFactory.createAccount('Test Account', '20135', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        testAccount.Sell_Type__c = 'PRESELL';
        testAccount.Account_Manager_Route__c = '1234';
        testAccount.Account_Manager_Route_2__c = '1234';
        testAccount.Account_Manager_Route_3__c = '1234';
        testAccount.Account_Manager_Route_4__c = '1234';
        testAccount.Account_Manager_Route_5__c = '1234';
        testAccount.Account_Manager_Route_6__c = '1234';
        testAccount.Sales_Manager_Route__c = '5678';
        testAccount.Sales_Manager_Route_2__c = '5678';
        testAccount.Sales_Manager_Route_3__c = '5678';
        testAccount.Sales_Manager_Route_4__c = '5678';
        testAccount.Sales_Manager_Route_5__c = '5678';
        testAccount.Sales_Manager_Route_6__c = '5678';
        update testAccount;

        Account testAccountFSR = TestFactory.createAccount('Test Account2', '20136', 'PVA', 'PDVA-CHANTILLY', null, '6789');
        testAccountFSR.Sell_Type__c = 'INSIDE SALES';
        testAccountFSR.Account_Manager_Route__c = '1234';
        testAccountFSR.Account_Manager_Route_2__c = '1234';
        testAccountFSR.Account_Manager_Route_3__c = '1234';
        testAccountFSR.Account_Manager_Route_4__c = '1234';
        testAccountFSR.Account_Manager_Route_5__c = '1234';
        testAccountFSR.Account_Manager_Route_6__c = '1234';
        testAccountFSR.Sales_Manager_Route__c = '5678';
        testAccountFSR.Sales_Manager_Route_2__c = '5678';
        testAccountFSR.Sales_Manager_Route_3__c = '5678';
        testAccountFSR.Sales_Manager_Route_4__c = '5678';
        testAccountFSR.Sales_Manager_Route_5__c = '5678';
        testAccountFSR.Sales_Manager_Route_6__c = '5678';
        update testAccountFSR;

        Account testAccountCBS = TestFactory.createAccount('Test Account CBS', '20135', 'CBS', 'CBS WAREHOUSE', null, '5432');
        testAccountCBS.Sell_Type__c = 'PRESELL';
        testAccountCBS.VIP_Instance__c = 'CBS';
        testAccountCBS.Account_Manager_Route__c = '1234';        
        testAccountCBS.Account_Manager_Route_2__c = '1234';
        testAccountCBS.Account_Manager_Route_3__c = '1234';
        testAccountCBS.Account_Manager_Route_4__c = '1234';
        testAccountCBS.Account_Manager_Route_5__c = '1234';
        testAccountCBS.Account_Manager_Route_6__c = '1234';
        testAccountCBS.Sales_Manager_Route__c = '5678';
        testAccountCBS.Sales_Manager_Route_2__c = '5678';
        testAccountCBS.Sales_Manager_Route_3__c = '5678';
        testAccountCBS.Sales_Manager_Route_4__c = '5678';
        testAccountCBS.Sales_Manager_Route_5__c = '5678';
        testAccountCBS.Sales_Manager_Route_6__c = '5678';
        update testAccountCBS;
        
        Account testAccountFSRCBS = TestFactory.createAccount('Test Account2', '20136', 'CBS', 'CBS WAREHOUSE', null, '6789');
        testAccountFSRCBS.Sell_Type__c = 'INSIDE SALES';
        testAccountFSRCBS.VIP_Instance__c = 'CBS';
        testAccountFSRCBS.Account_Manager_Route__c = '1234';
        testAccountFSRCBS.Account_Manager_Route_2__c = '1234';
        testAccountFSRCBS.Account_Manager_Route_3__c = '1234';
        testAccountFSRCBS.Account_Manager_Route_4__c = '1234';
        testAccountFSRCBS.Account_Manager_Route_5__c = '1234';
        testAccountFSRCBS.Account_Manager_Route_6__c = '1234';
        testAccountFSRCBS.Sales_Manager_Route__c = '5678';
        testAccountFSRCBS.Sales_Manager_Route_2__c = '5678';
        testAccountFSRCBS.Sales_Manager_Route_3__c = '5678';
        testAccountFSRCBS.Sales_Manager_Route_4__c = '5678';
        testAccountFSRCBS.Sales_Manager_Route_5__c = '5678';
        testAccountFSRCBS.Sales_Manager_Route_6__c = '5678';
        update testAccountFSRCBS;
        
        Account testAccountNoVIP = TestFactory.createAccount('Test Account2', '20136', 'CBS', 'CBS WAREHOUSE', null, '6789');
        testAccountNoVIP.Sell_Type__c = 'INSIDE SALES';
        testAccountNoVIP.VIP_Instance__c = '';
        testAccountNoVIP.Account_Manager_Route__c = '1234';
        testAccountNoVIP.Account_Manager_Route_2__c = '1234';
        testAccountNoVIP.Account_Manager_Route_3__c = '1234';
        testAccountNoVIP.Account_Manager_Route_4__c = '1234';
        testAccountNoVIP.Account_Manager_Route_5__c = '1234';
        testAccountNoVIP.Account_Manager_Route_6__c = '1234';
        testAccountNoVIP.Sales_Manager_Route__c = '5678';
        testAccountNoVIP.Sales_Manager_Route_2__c = '5678';
        testAccountNoVIP.Sales_Manager_Route_3__c = '5678';
        testAccountNoVIP.Sales_Manager_Route_4__c = '5678';
        testAccountNoVIP.Sales_Manager_Route_5__c = '5678';
        testAccountNoVIP.Sales_Manager_Route_6__c = '5678';
        update testAccountNoVIP;
        
        
        Objective__c testObjective1 = TestFactory.createObjective('Test Objective', 'PVA', 'Display');
        testObjective1.Start_Date__c = System.today()-1;
        testObjective1.End_Date__c = System.today()+1;
        update testObjective1;        
        TestFactory.createObjectiveAccount(testObjective1.Id, 'Incomplete', testAccount.Id);
        
        Objective__c testObjective2 = TestFactory.createObjective('Test Objective', 'CBS', 'Display');
        testObjective2.Start_Date__c = System.today()-1;
        testObjective2.End_Date__c = System.today()+1;
        update testObjective2;
        TestFactory.createObjectiveAccount(testObjective2.Id, 'Incomplete', testAccountCBS.Id);
    }

    static List<Account> getAccounts(String sellType) {
        return [SELECT Id, OwnerId, Name, Sell_Type__c, Account_Manager_Route__c, Account_Manager_Route_2__c, Account_Manager_Route_3__c, Account_Manager_Route_4__c, Account_Manager_Route_5__c,
                Account_Manager_Route_6__c, Sales_Manager_Route__c, Sales_Manager_Route_2__c, Sales_Manager_Route_3__c, Sales_Manager_Route_4__c, Sales_Manager_Route_5__c, 
                Sales_Manager_Route_6__c, VIP_Instance__c 
                FROM Account
                WHERE Sell_Type__c = :sellType];
    }
    
    @IsTest
    static void RouteAssignmentHandlerTest() {
        List<Account> accountList = getAccounts('PRESELL');

        Test.startTest();
            User user = [SELECT Id, VIP_Company__c, Assigned_Route__c FROM User WHERE Id = :UserInfo.getUserId()];
            user.VIP_Company__c = 'PVA';
            user.Assigned_route__c = '1234';
            update user;
            RouteAssignmentHandler.assignUserToAccountWhenAccountRouteChanges(accountList, null);
        Test.stopTest();

        accountList = getAccounts('PRESELL');

        System.assertEquals(user.Id, accountList[0].OwnerId, 'Owner should be logged in user');
    }

    @IsTest
    static void testIsAccountRouteOrSellTypeChanged(){
        List<Account> accountList = getAccounts('PRESELL');
        Account newAccount = accountList[0];
        newAccount.Sell_Type__c = 'Inside Sales';
        Account oldAccount = accountList[0];
        oldAccount.Sell_Type__c = 'Inside Sales';

        Test.startTest();
            Boolean isSellTypeChanged = RouteAssignmentHandler.isAccountRouteOrSellTypeChanged(newAccount, new Map<Id, Account>{oldAccount.Id => oldAccount});
        Test.stopTest();

        System.assertEquals(false, isSellTypeChanged, 'Boolean should be false');
    }

    @IsTest
    static void testAssignUserToAccountTeamWhenAccountRouteChanges() {
        List<Account> accountList = getAccounts('PRESELL');
        Account testAccount = new Account();
        for (Account a : accountList) {
            if (a.VIP_Instance__c == 'PVA') {
                testAccount = a;
            }
        }

        Test.startTest();
            User user = [SELECT Id, VIP_Company__c, Assigned_Route__c FROM User WHERE Id = :UserInfo.getUserId()];
            user.VIP_Company__c = 'PVA';
            user.Assigned_route__c = '1234';
        	user.IsManager__c = false;
            update user;
            RouteAssignmentHandler.assignUserToAccountTeamWhenAccountRouteChanges(new List<String>{testAccount.Id}, false);
        Test.stopTest();

        List<AccountTeamMember> accountTeamMemberList = [SELECT Id FROM AccountTeamMember];

        System.assertEquals(1, accountTeamMemberList.size(), '1 record should be returned');
    }
    
    @IsTest
    static void testAssignUserToAccountTeamWhenAccountRouteChangesCBS() {
        List<Account> accountList = getAccounts('PRESELL');
        Account testAccount = new Account();
        for (Account a : accountList) {
            if (a.VIP_Instance__c == 'CBS') {
                testAccount = a;
            }
        }
        Test.startTest();
            User user = [SELECT Id, VIP_Company__c, Assigned_Route__c FROM User WHERE Id = :UserInfo.getUserId()];
            user.VIP_Company__c = 'CBS';
            user.Assigned_route__c = '5678';
        	user.IsManager__c = true;
            update user;
            RouteAssignmentHandler.assignUserToAccountTeamWhenAccountRouteChanges(new List<String>{testAccount.Id}, false);
        Test.stopTest();

        List<AccountTeamMember> accountTeamMemberList = [SELECT Id FROM AccountTeamMember];

        System.assertEquals(1, accountTeamMemberList.size(), '1 record should be returned');
    }
    
    @IsTest
    static void testAssignUserToAccountTeamWhenAccountRouteChangesNOVIPINSIDESALES() {
        List<Account> accountList = getAccounts('INSIDE SALES');
        Account testAccount = new Account();
        for (Account a : accountList) {
            if (a.VIP_Instance__c == '') {
                testAccount = a;
            }
        }
        Test.startTest();
            User user = [SELECT Id, VIP_Company__c, Assigned_Route__c FROM User WHERE Id = :UserInfo.getUserId()];
            user.VIP_Company__c = 'CBS';
            user.Assigned_route__c = '1234';
        	user.IsManager__c = false;
            update user;
            RouteAssignmentHandler.assignUserToAccountTeamWhenAccountRouteChanges(new List<String>{testAccount.Id}, false);
        Test.stopTest();

        List<AccountTeamMember> accountTeamMemberList = [SELECT Id FROM AccountTeamMember];

        System.assertEquals(0, accountTeamMemberList.size(), '0 records should be returned');
    }
    
    @IsTest
    static void testAssignUserToAccountTeamWhenAccountRouteChangesNOVIPPRESELL() {
        List<Account> accountList = getAccounts('INSIDE SALES');
        Account testAccount = new Account();
        for (Account a : accountList) {
            if (a.VIP_Instance__c == '') {
                testAccount = a;
                testAccount.Sell_Type__c = 'PRESELL';
                update testAccount;
            }
        }
        Test.startTest();
            User user = [SELECT Id, VIP_Company__c, Assigned_Route__c FROM User WHERE Id = :UserInfo.getUserId()];
            user.VIP_Company__c = 'CBS';
            user.Assigned_route__c = '1234';
        	user.IsManager__c = false;
            update user;
            RouteAssignmentHandler.assignUserToAccountTeamWhenAccountRouteChanges(new List<String>{testAccount.Id}, false);
        Test.stopTest();

        List<AccountTeamMember> accountTeamMemberList = [SELECT Id FROM AccountTeamMember];

        System.assertEquals(0, accountTeamMemberList.size(), '0 records should be returned');
    }

    @IsTest
    static void testAssignAccountsToUsersWhenUserRouteChanges(){
        User user = [SELECT Id, VIP_Company__c, Assigned_Route__c FROM User WHERE Id = :UserInfo.getUserId()];
        user.VIP_Company__c = 'PVA';
        user.Assigned_route__c = '1234';
        user.IsManager__c = false;
        update user;
        User oldUser = [Select Id, VIP_Company__c, Assigned_Route__c FROM User WHERE Id = :UserInfo.getUserId()];
        oldUser.Assigned_Route__c = '1235';

        Test.startTest();
            RouteAssignmentHandler.assignAccountsToUsersWhenUserRouteChanges(new List<User>{user}, new Map<Id, User>{oldUser.Id => oldUser});
        Test.stopTest();

        List<Account> accounts = [SELECT Id, OwnerId FROM Account];

        System.assertEquals(UserInfo.getUserId(), accounts[0].OwnerId, 'OwnerId should match');
    }

    @IsTest
    static void testReassignObjectiveAccountOwners(){
        List<Account> accountList = getAccounts('PRESELL');

        Test.startTest();
            RouteAssignmentHandler.reassignObjectiveAccountOwners(new Set<Id>{accountList[0].Id});
        Test.stopTest();

        List<Objective_Account__c> objAccs = [SELECT Id, OwnerId FROM Objective_Account__c];

        System.assertEquals(UserInfo.getUserId(), objAccs[0].OwnerId, 'OwnerId should match');
    }

    @IsTest
    static void testgetUserLisToReassignId() {

        Test.startTest();
            List<String> returnedList = RouteAssignmentHandler.getUserLisToReassignId();
        Test.stopTest();
    }

}
@isTest
public class BatchBuildAccountTeamsTest {
    @TestSetup
    private static void setup(){
        //Create Account
        Id retailRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retail Store').getRecordTypeId();
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '12345');
        testAccount.Status__c = 'A';
        testAccount.RecordTypeId = retailRecordTypeId;
        testAccount.Sell_Type__c = 'INSIDE SALES';
        testAccount.Displayable_Status__c = 'Displayable';
        testAccount.Premise__c = 'Off Premise';
        testAccount.Warehouse__c = 'PDVA-CHANTILLY';
        testAccount.SalesOrg__c = 'PVA';
        testAccount.ProcessAccountTeamsBuild__c = true;
        update testAccount;
    }
    @isTest
    static void testBatchBuildAccountTeams(){
       
        Test.startTest();
            BatchBuildAccountTeams batchBuildTeams= new BatchBuildAccountTeams();
            batchBuildTeams.query = 'SELECT Id ' +
                                    'FROM Account ' +
                                    'WHERE ProcessAccountTeamsBuild__c = true';
            Database.executebatch(batchBuildTeams);
        Test.stopTest();
        
        //Get all the Objective Accounts (should only be 1)
        List<Account> accList = [SELECT Id, ProcessAccountTeamsBuild__c FROM Account];
		//Assertion
        System.assertEquals(false, accList[0].ProcessAccountTeamsBuild__c, 'Value not returned as false');
    }
}
@isTest
public inherited sharing class BatchExpiringLicenseAlertTest {
    
    @TestSetup
    static void setup(){
        Account testAccount = new Account();
        testAccount.Name = 'Expiring License Store' ;
        testAccount.Account_Type__c = 'None';
        testAccount.LicenseExpirationDate__c = System.today()+35;
        testAccount.Territories__c = '10';

        insert testAccount;
    }


    @isTest
    static void testExpiringLicenseAlertBatch(){

        Test.startTest();
        BatchExpiringLicenseAlert batchExpiringLicenseAlert = new BatchExpiringLicenseAlert();
        Date todayPlus35 = System.today().addDays(35);
        batchExpiringLicenseAlert.todayPlus35 = todayPlus35;
        batchExpiringLicenseAlert.query = 'SELECT Id, LicenseExpirationDate__c ' + 
                                            ' FROM Account' + 
                                            ' WHERE LicenseExpirationDate__c = :todayPlus35';
        
        Database.executebatch(batchExpiringLicenseAlert);
        Test.stopTest();

        List<Alert__c> alertList = [SELECT Id FROM Alert__c];

        System.assertEquals(1, alertList.size());

    }



}
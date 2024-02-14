@isTest
private class  AlertCreatorControllerTest {

    @TestSetup
    static void setup(){
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        Alert__c testAlert = TestFactory.createAlert('Test Alert', System.today(), System.today().addDays(30), 'Test Alert Message - Do Not Deliver', 'Account', testAccount.Id);
    }

    @isTest
    static void testAccountAlertRetrieval(){
        Test.startTest();
        Account acc = [SELECT Id FROM Account LIMIT 1];
        List<Alert__c> alertList = AlertCreatorController.findActiveAlerts(acc.Id, 'Account');
        Test.stopTest();

        System.assertEquals(1, alertList.size(), 'The controller method returned the correct Alerts count.');
    }
}
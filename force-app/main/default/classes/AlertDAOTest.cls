@isTest
private class  AlertDAOTest {

    @TestSetup
    static void setup(){
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        Alert__c testAlert = TestFactory.createAlert('Test Alert', System.today(), System.today().addDays(30), 'Test Alert Message - Do Not Deliver', 'Account', testAccount.Id);


        Alert__c testAlert2 = TestFactory.createAlert('Test Alert', System.today(), System.today().addDays(30), 'Test Alert Message - Do Not Deliver', 'Order', testAccount.Id);


    }

    @isTest
    static void testAlertDAORetrieval(){
        Test.startTest();
        Account acc = [SELECT Id FROM Account LIMIT 1];
        List<Alert__c> alertList = AlertDAO.getAlerts(acc.Id, 'Account', True);
        Test.stopTest();




    }
    
    @isTest
    static void testAlertDAORetrievalOrder(){
        Test.startTest();
        Account acc = [SELECT Id FROM Account LIMIT 1];
        List<Alert__c> alertList = AlertDAO.getAlerts(acc.Id, 'Order', True);
        Test.stopTest();



    }


    @isTest
    static void testGetAlertsByAccountId(){
        Test.startTest();
        Account acc = [SELECT Id FROM Account LIMIT 1];
        List<Alert__c> alertList = AlertDAO.getAlertsByAccountId(acc.Id);
        Test.stopTest();





    }

}
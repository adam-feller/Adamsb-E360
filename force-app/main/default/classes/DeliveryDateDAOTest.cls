@isTest
private class DeliveryDateDAOTest {

    @TestSetup
    private static void setup(){
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '12345');
        testAccount.Delivery_Frequency_Type__C = 'Weekly';
        testAccount.BillingCity = 'Chicago';
        update testAccount;
        Delivery_Date__c newDeliveryDate = new Delivery_Date__c();
        newDeliveryDate.Account__c = testAccount.Id;
        newDeliveryDate.Delivery_Date__c = System.today();
        insert newDeliveryDate;
    }

    static Account getAccount(){
        return [SELECT Id, Name, VIP_Account_Number__c, Beer_Company__c, Warehouse__c
                FROM Account
                LIMIT 1];
    }

    static Delivery_Date__c getDeliveryDate(){
        return [SELECT Id, Delivery_Date__c
                FROM Delivery_Date__c
                LIMIT 1];
    }

    @isTest
    static void testGetDeliveryDatesByIds(){
        Delivery_Date__c existingDeliveryDate = getDeliveryDate();

        Test.startTest();
            List<Delivery_Date__c> deliveryDateList = DeliveryDateDAO.getDeliveryDatesByIds(new Set<Id>{existingDeliveryDate.Id});
        Test.stopTest();

        System.assertEquals(deliveryDateList.size(), 1);
    }

    @isTest
    static void testGetDeliveryDatesByAccount(){

        Test.startTest();
            List<Delivery_Date__c> deliveryDateList = DeliveryDateDAO.getDeliveryDatesByAccountIds(new Set<Id>{getAccount().Id});
        Test.stopTest();

        System.assertNotEquals(deliveryDateList.size(), 0);
    }

    @isTest
    static void testGetDeliveryDatessByWarehouseDeliveryDate(){

        Test.startTest();
            List<Delivery_Date__c> deliveryDateList = DeliveryDateDAO.getDeliveryDatessByWarehouseDeliveryDate(new Set<String>{'PDVA-CHANTILLY'}, System.today(), new List<String>{'Weekly'}, new List<String>{'Chicago'});
        Test.stopTest();

        System.assertEquals(deliveryDateList.size(), 1);
    }

    @isTest
    static void testGetDeliveryDatessAccountDateStatus(){
        Account testAccount = getAccount();

        Test.startTest();
            List<Delivery_Date__c> deliveryDateList = DeliveryDateDAO.getDeliveryDatesAccountDateStatus(new Set<Id>{testAccount.Id}, System.today(), 'Active');
        Test.stopTest();

        System.assertEquals(deliveryDateList.size(), 1);
    }

    @isTest
    static void testGetDeliveryDatessAccountDate(){
        Account testAccount = getAccount();

        Test.startTest();
            List<Delivery_Date__c> deliveryDateList = DeliveryDateDAO.getDeliveryDatesAccountDate(new Set<Id>{testAccount.Id}, System.today());
        Test.stopTest();

        System.assertEquals(deliveryDateList.size(), 1);
    }

    @isTest
    static void testInsertDeliveryDates(){

        Test.startTest();
            Delivery_Date__c newDeliveryDate = new Delivery_Date__c();
            newDeliveryDate.Account__c = getAccount().Id;
            newDeliveryDate.Delivery_Date__c = System.today()+1; 
            DeliveryDateDAO.insertDeliveryDates(new List<Delivery_Date__c>{newDeliveryDate});
        Test.stopTest();

        List<Delivery_Date__c> deliveryDateList = [SELECT Id FROM Delivery_Date__c];

        System.assertEquals(deliveryDateList.size(), 2);
    }

    @isTest
    static void testUpdateDeliveryDates(){

        Test.startTest();
            Delivery_Date__c existingDeliveryDate = getDeliveryDate();
            existingDeliveryDate.Delivery_Date__c = System.today()+1; 
            DeliveryDateDAO.updateDeliveryDates(new List<Delivery_Date__c>{existingDeliveryDate});
        Test.stopTest();

        List<Delivery_Date__c> deliveryDateList = [SELECT Id, Delivery_Date__c FROM Delivery_Date__c];

        System.assertEquals(deliveryDateList[0].Delivery_Date__c, System.today()+1);
    }


    @isTest
    static void testDeleteDeliveryDates(){

        Test.startTest();
            Delivery_Date__c existingDeliveryDate = getDeliveryDate();
            DeliveryDateDAO.deleteDeliveryDates(new List<Delivery_Date__c>{existingDeliveryDate});
        Test.stopTest();

        List<Delivery_Date__c> deliveryDateList = [SELECT Id, Delivery_Date__c FROM Delivery_Date__c];

        System.assertEquals(deliveryDateList.size(), 0);
    }
}
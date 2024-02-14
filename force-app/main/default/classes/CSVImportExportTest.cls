@isTest
private class CSVImportExportTest {
   
    @TestSetup
    private static void setup(){
        Warehouse__c testWarehouse = TestFactory.createWarehouse('PDVA-CHANTILLY', null, 'PVA', null, null, null, null, null);
        Account testAccount = TestFactory.createAccount('Test Account', '20100', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retail Store').getRecordTypeId();
        testAccount.Premise__c = 'On Premise';
        testAccount.Sell_Type__c = 'NATIONAL ACCTS';
        testAccount.Delivery_Frequency_Type__c = 'Weekly';
        testAccount.ExternalId__c = 'PVA*20100';
        testAccount.Status__c = 'A';
        update testAccount;
        TestFactory.createDeliveryDate(testAccount.Id, Date.newInstance(2021, 05, 31), 'Active');
    }

    @isTest
    static void testInsertDeliveryDates(){
        List<CSVImportExport.DeliveryDateWrapper> deliveryDateWrapperList = new List<CSVImportExport.DeliveryDateWrapper>();
        CSVImportExport.DeliveryDateWrapper testDeliveryWrapper = new CSVImportExport.DeliveryDateWrapper();
        testDeliveryWrapper.BusinessUnit = 'PVA';
        testDeliveryWrapper.AccountNumber = '20100';
        testDeliveryWrapper.NewDeliveryDate = '4/14/21';
        deliveryDateWrapperList.add(testDeliveryWrapper);

        Test.startTest();
            CSVImportExport.insertDeliveryDates(JSON.serialize(deliveryDateWrapperList));
        Test.stopTest();

        List<Delivery_Date__c> deliveryDateList = [SELECT Id FROM Delivery_Date__c];

        System.assertEquals(deliveryDateList.size(), 2, 'Should return 2 records');
    }

    @isTest
    static void testInsertDeliveryDatesNotFound(){
        List<CSVImportExport.DeliveryDateWrapper> deliveryDateWrapperList = new List<CSVImportExport.DeliveryDateWrapper>();
        CSVImportExport.DeliveryDateWrapper testDeliveryWrapper = new CSVImportExport.DeliveryDateWrapper();
        testDeliveryWrapper.BusinessUnit = 'PVA';
        testDeliveryWrapper.AccountNumber = '12345';
        testDeliveryWrapper.NewDeliveryDate = '4/14/21';
        deliveryDateWrapperList.add(testDeliveryWrapper);

        Test.startTest();
            CSVImportExport.insertDeliveryDates(JSON.serialize(deliveryDateWrapperList));
        Test.stopTest();

        List<Delivery_Date__c> deliveryDateList = [SELECT Id FROM Delivery_Date__c];

        System.assertEquals(deliveryDateList.size(), 1, 'Should return 1 record');
    }
    
    @isTest
    static void testupdateUserRouteData(){
        List<CSVImportExport.UserWrapper> UserWrapperList = new List<CSVImportExport.UserWrapper>();
        CSVImportExport.UserWrapper testUserWrapper = new CSVImportExport.UserWrapper();
        testUserWrapper.Name          = 'Carl Hamlin';
        testUserWrapper.Id            = '0054v00000EN03bAAD';
        testUserWrapper.AssignedRoute = '112';
        testUserWrapper.MerchRoute    = '456';
             
        UserWrapperList.add(testUserWrapper);

        Test.startTest();
            CSVImportExport.updateUserRouteData(JSON.serialize(UserWrapperList), 'UpdateRoute');
        Test.stopTest();

        //List<Delivery_Date__c> deliveryDateList = [SELECT Id FROM Delivery_Date__c];

        //System.assertEquals(deliveryDateList.size(), 2, 'Should return 2 records');
    }
    
    

    @isTest
    static void testUpdateData(){
        List<CSVImportExport.DeliveryDateWrapper> deliveryDateWrapperList = new List<CSVImportExport.DeliveryDateWrapper>();
        CSVImportExport.DeliveryDateWrapper testDeliveryWrapper = new CSVImportExport.DeliveryDateWrapper();
        testDeliveryWrapper.BusinessUnit = 'PVA';
        testDeliveryWrapper.AccountNumber = '12345';
        testDeliveryWrapper.PriorDeliveryDate = '4/13/21';
        testDeliveryWrapper.NewDeliveryDate = '4/14/21';
        testDeliveryWrapper.PriorCallDate = '4/12/21';
        testDeliveryWrapper.NewCallDate = '4/13/21';
        deliveryDateWrapperList.add(testDeliveryWrapper);

        Test.startTest();
            CSVImportExport.updateData(JSON.serialize(deliveryDateWrapperList), 'Test Plan');
        Test.stopTest();

        List<Delivery_Date__c> deliveryDateList = [SELECT Id FROM Delivery_Date__c];

        System.assertEquals(deliveryDateList.size(), 1, 'Should return 1 record');
    }        
}
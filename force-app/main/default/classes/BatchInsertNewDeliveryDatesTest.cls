@isTest
private class BatchInsertNewDeliveryDatesTest {

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
        TestFactory.createDeliveryDate(testAccount.Id, System.Today() + 1, 'Active');
    }

    @isTest
    static void testBatchInsertNewDeliveryDatesTest() {
        Date delivDate = System.Today() + 2;
        List<CSVImportExport.DeliveryDateWrapper> deliveryDateWrapperList = new List<CSVImportExport.DeliveryDateWrapper>();
        CSVImportExport.DeliveryDateWrapper testDeliveryWrapper = new CSVImportExport.DeliveryDateWrapper();
        testDeliveryWrapper.BusinessUnit = 'PVA';
        testDeliveryWrapper.AccountNumber = '20100';
        testDeliveryWrapper.NewDeliveryDate = delivDate.month() + '/' + delivDate.day() + '/' + delivDate.year();
        deliveryDateWrapperList.add(testDeliveryWrapper);

        Map<String, List<CSVImportExport.DeliveryDateWrapper>> externalIdToNewDeliveryDate = new Map<String, List<CSVImportExport.DeliveryDateWrapper>>();

        for(CSVImportExport.DeliveryDateWrapper wrapper : deliveryDateWrapperList){
            wrapper.AccountNumber = wrapper.AccountNumber.leftPad(5, '0');
            String externalId = wrapper.BusinessUnit+'*'+wrapper.AccountNumber;
            List<CSVImportExport.DeliveryDateWrapper> deliveryDateList = new List<CSVImportExport.DeliveryDateWrapper>();
            if(externalIdToNewDeliveryDate.containsKey(externalId)){
                deliveryDateList = externalIdToNewDeliveryDate.get(externalId);
            }
            deliveryDateList.add(wrapper);
            externalIdToNewDeliveryDate.put(externalId, deliveryDateList);
        }
        Id retailAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retail Store').getRecordTypeId();

        Test.startTest();
            BatchInsertNewDeliveryDates massInsertDeliveryDatesBatch = new BatchInsertNewDeliveryDates();
            massInsertDeliveryDatesBatch.externalIdToNewDeliveryDate = externalIdToNewDeliveryDate;
            massInsertDeliveryDatesBatch.externalIdList = externalIdToNewDeliveryDate.keySet();
            massInsertDeliveryDatesBatch.externalIdListSize = 1;
            massInsertDeliveryDatesBatch.retailAccountRecordTypeId = retailAccountRecordTypeId;
            massInsertDeliveryDatesBatch.userEmail = 'test@gmail.com';
            massInsertDeliveryDatesBatch.query = 'SELECT Id, ExternalId__c, Warehouse_Lookup__r.ISR_1__c, OwnerId, Name' +
                                                ' FROM Account' + 
                                                ' WHERE ExternalId__c IN :externalIdList' + 
                                                ' AND RecordTypeId = :retailAccountRecordTypeId' + 
                                                ' AND Status__c = \'A\'';
            Database.executeBatch(massInsertDeliveryDatesBatch);
        Test.stopTest();

        List<Delivery_Date__c> deliveryDateList = [SELECT Id FROM Delivery_Date__c];

        System.assertEquals(deliveryDateList.size(), 2, 'Should return 2 records');
    }

    @isTest
    static void testBatchInsertNewDeliveryDatesTestNotFound(){
		Date delivDate = System.Today() + 1;        
        List<CSVImportExport.DeliveryDateWrapper> deliveryDateWrapperList = new List<CSVImportExport.DeliveryDateWrapper>();
        CSVImportExport.DeliveryDateWrapper testDeliveryWrapper = new CSVImportExport.DeliveryDateWrapper();
        testDeliveryWrapper.BusinessUnit = 'PVA';
        testDeliveryWrapper.AccountNumber = '12345';
        testDeliveryWrapper.NewDeliveryDate = delivDate.month() + '/' + delivDate.day() + '/' + delivDate.year();
        deliveryDateWrapperList.add(testDeliveryWrapper);

        Map<String, List<CSVImportExport.DeliveryDateWrapper>> externalIdToNewDeliveryDate = new Map<String, List<CSVImportExport.DeliveryDateWrapper>>();

        for(CSVImportExport.DeliveryDateWrapper wrapper : deliveryDateWrapperList){
            wrapper.AccountNumber = wrapper.AccountNumber.leftPad(5, '0');
            String externalId = wrapper.BusinessUnit+'*'+wrapper.AccountNumber;
            List<CSVImportExport.DeliveryDateWrapper> deliveryDateList = new List<CSVImportExport.DeliveryDateWrapper>();
            if(externalIdToNewDeliveryDate.containsKey(externalId)){
                deliveryDateList = externalIdToNewDeliveryDate.get(externalId);
            }
            deliveryDateList.add(wrapper);
            externalIdToNewDeliveryDate.put(externalId, deliveryDateList);
        }
        Id retailAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retail Store').getRecordTypeId();

        Test.startTest();
            BatchInsertNewDeliveryDates massInsertDeliveryDatesBatch = new BatchInsertNewDeliveryDates();
            massInsertDeliveryDatesBatch.externalIdToNewDeliveryDate = externalIdToNewDeliveryDate;
            massInsertDeliveryDatesBatch.externalIdList = externalIdToNewDeliveryDate.keySet();
            massInsertDeliveryDatesBatch.externalIdListSize = 1;
            massInsertDeliveryDatesBatch.retailAccountRecordTypeId = retailAccountRecordTypeId;
            massInsertDeliveryDatesBatch.userEmail = 'test@gmail.com';
            massInsertDeliveryDatesBatch.query = 'SELECT Id, ExternalId__c, Warehouse_Lookup__r.ISR_1__c, OwnerId, Name' +
                                                ' FROM Account' + 
                                                ' WHERE ExternalId__c IN :externalIdList' + 
                                                ' AND RecordTypeId = :retailAccountRecordTypeId' + 
                                                ' AND Status__c = \'A\'';
            Database.executeBatch(massInsertDeliveryDatesBatch);
        Test.stopTest();

        List<Delivery_Date__c> deliveryDateList = [SELECT Id FROM Delivery_Date__c];

        System.assertEquals(deliveryDateList.size(), 1, 'Should return 1 record');
    }

    @isTest
    static void testBatchInsertNewDeliveryDatesTestSameDeliveryDate(){
        Date delivDate = System.Today() + 1;
        List<CSVImportExport.DeliveryDateWrapper> deliveryDateWrapperList = new List<CSVImportExport.DeliveryDateWrapper>();
        CSVImportExport.DeliveryDateWrapper testDeliveryWrapper = new CSVImportExport.DeliveryDateWrapper();
        testDeliveryWrapper.BusinessUnit = 'PVA';
        testDeliveryWrapper.AccountNumber = '20100';
        testDeliveryWrapper.NewDeliveryDate = delivDate.month() + '/' + delivDate.day() + '/' + delivDate.year();
        deliveryDateWrapperList.add(testDeliveryWrapper);

        Map<String, List<CSVImportExport.DeliveryDateWrapper>> externalIdToNewDeliveryDate = new Map<String, List<CSVImportExport.DeliveryDateWrapper>>();

        for(CSVImportExport.DeliveryDateWrapper wrapper : deliveryDateWrapperList){
            wrapper.AccountNumber = wrapper.AccountNumber.leftPad(5, '0');
            String externalId = wrapper.BusinessUnit+'*'+wrapper.AccountNumber;
            List<CSVImportExport.DeliveryDateWrapper> deliveryDateList = new List<CSVImportExport.DeliveryDateWrapper>();
            if(externalIdToNewDeliveryDate.containsKey(externalId)){
                deliveryDateList = externalIdToNewDeliveryDate.get(externalId);
            }
            deliveryDateList.add(wrapper);
            externalIdToNewDeliveryDate.put(externalId, deliveryDateList);
        }
        Id retailAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retail Store').getRecordTypeId();

        Test.startTest();
            BatchInsertNewDeliveryDates massInsertDeliveryDatesBatch = new BatchInsertNewDeliveryDates();
            massInsertDeliveryDatesBatch.externalIdToNewDeliveryDate = externalIdToNewDeliveryDate;
            massInsertDeliveryDatesBatch.externalIdList = externalIdToNewDeliveryDate.keySet();
            massInsertDeliveryDatesBatch.externalIdListSize = 1;
            massInsertDeliveryDatesBatch.retailAccountRecordTypeId = retailAccountRecordTypeId;
            massInsertDeliveryDatesBatch.userEmail = 'test@gmail.com';
            massInsertDeliveryDatesBatch.query = 'SELECT Id, ExternalId__c, Warehouse_Lookup__r.ISR_1__c, OwnerId, Name' +
                                                ' FROM Account' + 
                                                ' WHERE ExternalId__c IN :externalIdList' + 
                                                ' AND RecordTypeId = :retailAccountRecordTypeId' + 
                                                ' AND Status__c = \'A\'';
            Database.executeBatch(massInsertDeliveryDatesBatch);
        Test.stopTest();

        List<Delivery_Date__c> deliveryDateList = [SELECT Id FROM Delivery_Date__c];

        System.assertEquals(1, deliveryDateList.size(), 'Should return 1 record');  //The one created in Setup was same date as date sent to batch job
    }

    @isTest
    static void testBatchInsertNewDeliveryDatesTestCancelledDeliveryDate() {
		Date delivDate = System.Today() + 1;
        Delivery_Date__c deliveryDate = [SELECT Id, Status__c FROM Delivery_Date__c];
        deliveryDate.Status__c = 'Cancelled';
        update deliveryDate;
        List<CSVImportExport.DeliveryDateWrapper> deliveryDateWrapperList = new List<CSVImportExport.DeliveryDateWrapper>();
        CSVImportExport.DeliveryDateWrapper testDeliveryWrapper = new CSVImportExport.DeliveryDateWrapper();
        testDeliveryWrapper.BusinessUnit = 'PVA';
        testDeliveryWrapper.AccountNumber = '20100';
        testDeliveryWrapper.NewDeliveryDate = delivDate.month() + '/' + delivDate.day() + '/' + delivDate.year();
        deliveryDateWrapperList.add(testDeliveryWrapper);

        Map<String, List<CSVImportExport.DeliveryDateWrapper>> externalIdToNewDeliveryDate = new Map<String, List<CSVImportExport.DeliveryDateWrapper>>();

        for(CSVImportExport.DeliveryDateWrapper wrapper : deliveryDateWrapperList){
            wrapper.AccountNumber = wrapper.AccountNumber.leftPad(5, '0');
            String externalId = wrapper.BusinessUnit+'*'+wrapper.AccountNumber;
            List<CSVImportExport.DeliveryDateWrapper> deliveryDateList = new List<CSVImportExport.DeliveryDateWrapper>();
            if(externalIdToNewDeliveryDate.containsKey(externalId)){
                deliveryDateList = externalIdToNewDeliveryDate.get(externalId);
            }
            deliveryDateList.add(wrapper);
            externalIdToNewDeliveryDate.put(externalId, deliveryDateList);
        }
        Id retailAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retail Store').getRecordTypeId();

        Test.startTest();
            BatchInsertNewDeliveryDates massInsertDeliveryDatesBatch = new BatchInsertNewDeliveryDates();
            massInsertDeliveryDatesBatch.externalIdToNewDeliveryDate = externalIdToNewDeliveryDate;
            massInsertDeliveryDatesBatch.externalIdList = externalIdToNewDeliveryDate.keySet();
            massInsertDeliveryDatesBatch.externalIdListSize = 1;
            massInsertDeliveryDatesBatch.retailAccountRecordTypeId = retailAccountRecordTypeId;
            massInsertDeliveryDatesBatch.userEmail = 'test@gmail.com';
            massInsertDeliveryDatesBatch.query = 'SELECT Id, ExternalId__c, Warehouse_Lookup__r.ISR_1__c, OwnerId, Name' +
                                                ' FROM Account' + 
                                                ' WHERE ExternalId__c IN :externalIdList' + 
                                                ' AND RecordTypeId = :retailAccountRecordTypeId' + 
                                                ' AND Status__c = \'A\'';
            Database.executeBatch(massInsertDeliveryDatesBatch);
        Test.stopTest();

        List<Delivery_Date__c> deliveryDateList = [SELECT Id FROM Delivery_Date__c];

        System.assertEquals(1, deliveryDateList.size(), 'Should return 1 records');  //The one created in Setup was same date as date sent to batch job
    }

    @isTest
    static void testBatchInsertNewDeliveryDateAndCallTest(){
        Date delivDate = System.Today() + 2;
        Date callDate = System.Today() + 1;
        List<CSVImportExport.DeliveryDateWrapper> deliveryDateWrapperList = new List<CSVImportExport.DeliveryDateWrapper>();
        CSVImportExport.DeliveryDateWrapper testDeliveryWrapper = new CSVImportExport.DeliveryDateWrapper();
        testDeliveryWrapper.BusinessUnit = 'PVA';
        testDeliveryWrapper.AccountNumber = '20100';
        testDeliveryWrapper.NewDeliveryDate = delivDate.month() + '/' + delivDate.day() + '/' + delivDate.year();
        testDeliveryWrapper.NewCallDate = callDate.month() + '/' + callDate.day() + '/' + callDate.year();
        deliveryDateWrapperList.add(testDeliveryWrapper);

        Map<String, List<CSVImportExport.DeliveryDateWrapper>> externalIdToNewDeliveryDate = new Map<String, List<CSVImportExport.DeliveryDateWrapper>>();

        for(CSVImportExport.DeliveryDateWrapper wrapper : deliveryDateWrapperList){
            wrapper.AccountNumber = wrapper.AccountNumber.leftPad(5, '0');
            String externalId = wrapper.BusinessUnit+'*'+wrapper.AccountNumber;
            List<CSVImportExport.DeliveryDateWrapper> deliveryDateList = new List<CSVImportExport.DeliveryDateWrapper>();
            if(externalIdToNewDeliveryDate.containsKey(externalId)){
                deliveryDateList = externalIdToNewDeliveryDate.get(externalId);
            }
            deliveryDateList.add(wrapper);
            externalIdToNewDeliveryDate.put(externalId, deliveryDateList);
        }
        Id retailAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retail Store').getRecordTypeId();

        Test.startTest();
            BatchInsertNewDeliveryDates massInsertDeliveryDatesBatch = new BatchInsertNewDeliveryDates();
            massInsertDeliveryDatesBatch.externalIdToNewDeliveryDate = externalIdToNewDeliveryDate;
            massInsertDeliveryDatesBatch.externalIdList = externalIdToNewDeliveryDate.keySet();
            massInsertDeliveryDatesBatch.externalIdListSize = 1;
            massInsertDeliveryDatesBatch.retailAccountRecordTypeId = retailAccountRecordTypeId;
            massInsertDeliveryDatesBatch.userEmail = 'test@gmail.com';
            massInsertDeliveryDatesBatch.query = 'SELECT Id, ExternalId__c, Warehouse_Lookup__r.ISR_1__c, OwnerId, Name' +
                                                ' FROM Account' + 
                                                ' WHERE ExternalId__c IN :externalIdList' + 
                                                ' AND RecordTypeId = :retailAccountRecordTypeId' + 
                                                ' AND Status__c = \'A\'';
            Database.executeBatch(massInsertDeliveryDatesBatch);
        Test.stopTest();

        List<Delivery_Date__c> deliveryDateList = [SELECT Id FROM Delivery_Date__c];
        List<Task> taskList = [SELECT Id FROM Task];

        System.assertEquals(deliveryDateList.size(), 2, 'Should return 2 records');
        System.assertEquals(taskList.size(), 1, 'Should return 1 record');
    }
}
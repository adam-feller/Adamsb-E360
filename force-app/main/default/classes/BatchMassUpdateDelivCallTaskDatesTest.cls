@isTest
private class BatchMassUpdateDelivCallTaskDatesTest {

    @TestSetup
    private static void setup(){
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        testAccount.Premise__c = 'On Premise';
        testAccount.Sell_Type__c = 'NATIONAL ACCTS';
        testAccount.Delivery_Frequency_Type__c = 'Weekly';
        update testAccount;
        Delivery_Date__c testDeliveryDate = TestFactory.createDeliveryDate(testAccount.Id, System.today(), 'Active');
        testDeliveryDate.External_Id__c = 'PVA*201*' + System.today().month() + '/' + System.today().day() + '/' + String.valueOf(System.today().year()).right(2);
        Id callRecordType = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId();
        Task testTask = TestFactory.createTaskByRecordType('Test', callRecordType, 'Open', testAccount.Id, System.today());
        testTask.Delivery_Date__c = testDeliveryDate.Id;
        update testTask;
    }

    @isTest
    static void testBatchMassUpdateDelivCallTaskDatesTest() {
        List<CSVImportExport.DeliveryDateWrapper> deliveryDateWrapperList = new List<CSVImportExport.DeliveryDateWrapper>();
        CSVImportExport.DeliveryDateWrapper testDeliveryWrapper = new CSVImportExport.DeliveryDateWrapper();
        testDeliveryWrapper.BusinessUnit = 'PVA';
        testDeliveryWrapper.AccountNumber = '201';
        String tdy = System.today().month() + '/' + System.today().day() + '/' + String.valueOf(System.today().year()).right(2);
        String tmw = System.today().month() + '/' + (System.today()+1).day() + '/' + String.valueOf(System.today().year()).right(2);
        testDeliveryWrapper.PriorDeliveryDate = tdy;
        testDeliveryWrapper.NewDeliveryDate = tmw;
        testDeliveryWrapper.PriorCallDate = tdy;
        testDeliveryWrapper.NewCallDate = tmw;
        deliveryDateWrapperList.add(testDeliveryWrapper);

        Map<String, CSVImportExport.DeliveryDateWrapper> externalIdToNewDeliveryDate = new Map<String, CSVImportExport.DeliveryDateWrapper>();
        for(CSVImportExport.DeliveryDateWrapper wrapper: deliveryDateWrapperList) {
            String externalId = wrapper.BusinessUnit+'*'+wrapper.AccountNumber+'*'+wrapper.PriorDeliveryDate;
            externalIdToNewDeliveryDate.put(externalId, wrapper);
        }

        Test.startTest();
            BatchMassUpdateDeliveryAndCallTaskDates batchHPUDTD = new BatchMassUpdateDeliveryAndCallTaskDates();
            batchHPUDTD.planName = 'Test';
            batchHPUDTD.userEmail = 'test@gmail.com';
            batchHPUDTD.externalIdToNewDeliveryDate = externalIdToNewDeliveryDate;
            batchHPUDTD.externalIdList = externalIdToNewDeliveryDate.keySet();
            batchHPUDTD.query = 'SELECT Id, Delivery_Date__c, External_Id__c, Original_Delivery_Date__c, Account__r.Warehouse__c, Plan__c, Account__r.Sell_Type__c FROM Delivery_Date__c';
            database.executeBatch(batchHPUDTD, 200);
        Test.stopTest();

        List<Task> taskList = [SELECT Id, ActivityDate FROM Task];

        System.assertEquals(taskList.size(), 1, 'Should return 1 record');
    }

    @isTest
    static void testBatchMassUpdateDelivCallTaskDatesTestNotFound(){
        List<CSVImportExport.DeliveryDateWrapper> deliveryDateWrapperList = new List<CSVImportExport.DeliveryDateWrapper>();
        CSVImportExport.DeliveryDateWrapper testDeliveryWrapper = new CSVImportExport.DeliveryDateWrapper();
        testDeliveryWrapper.BusinessUnit = 'PVA';
        testDeliveryWrapper.AccountNumber = '20123';
        String tdy = System.today().month() + '/' + System.today().day() + '/' + String.valueOf(System.today().year()).right(2);
        String tmw = System.today().month() + '/' + (System.today()+1).day() + '/' + String.valueOf(System.today().year()).right(2);
        testDeliveryWrapper.PriorDeliveryDate = tdy;
        testDeliveryWrapper.NewDeliveryDate = tmw;
        testDeliveryWrapper.PriorCallDate = tdy;
        testDeliveryWrapper.NewCallDate = tmw;
        deliveryDateWrapperList.add(testDeliveryWrapper);

        Map<String, CSVImportExport.DeliveryDateWrapper> externalIdToNewDeliveryDate = new Map<String, CSVImportExport.DeliveryDateWrapper>();
        for(CSVImportExport.DeliveryDateWrapper wrapper: deliveryDateWrapperList){
            String externalId = wrapper.BusinessUnit+'*'+wrapper.AccountNumber+'*'+wrapper.PriorDeliveryDate;
            externalIdToNewDeliveryDate.put(externalId, wrapper);
        }

        Test.startTest();
            BatchMassUpdateDeliveryAndCallTaskDates batchHPUDTD = new BatchMassUpdateDeliveryAndCallTaskDates();
            batchHPUDTD.planName = 'Test';
            batchHPUDTD.userEmail = 'test@gmail.com';
            batchHPUDTD.externalIdToNewDeliveryDate = externalIdToNewDeliveryDate;
            batchHPUDTD.externalIdList = externalIdToNewDeliveryDate.keySet();
            batchHPUDTD.query = 'SELECT Id, Delivery_Date__c, External_Id__c, Original_Delivery_Date__c, Account__r.Warehouse__c, Plan__c, Account__r.Sell_Type__c FROM Delivery_Date__c';
            database.executeBatch(batchHPUDTD, 200);
        Test.stopTest();

        List<Task> taskList = [SELECT Id, ActivityDate FROM Task];

        System.assertEquals(taskList.size(), 1, 'Should return 1 record');
    }
}
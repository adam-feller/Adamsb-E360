@isTest
private class CriticalMinuteControllerTest {

    @TestSetup
    private static void setup() {
        Account testAccount = TestFactory.createAccount('Test Account', '20135', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        AccountTeamMember testATM = TestFactory.createAccountTeamMember(testAccount.Id, UserInfo.getUserId(), 'FSR');
        Product2 testProduct = TestFactory.createProduct('Test Product', '12345', 'MillerCoors', '12345');
        Product2 testProduct1 = TestFactory.createProduct('Test Product', '12345', 'MillerCoors', '11455');
        Product2 testSubBrandProduct = createSubBrandProduct('Test Product', '12345', 'MillerCoors', '12343','D48*B');
        Product2 testBrandProduct = createBrandProduct('Test Product', '12345', 'MillerCoors', '12234', 'KG*B');
        testProduct1.Subbrandid__c = testSubBrandProduct.id;
        testProduct1.Brand_External_Id__c = testBrandProduct.id;
        update testProduct1;
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true, AccountId__c = testAccount.Id);
        Update standardPricebook;
        TestFactory.createPricebookEntry(standardPricebook.Id, testProduct.Id, 10.00, false, true);
        TestFactory.createMulesoftUtilitySetting('Suggested Sell', 'http://rh-suggested-sell-xapi.us-e2.cloudhub.io/api/suggested-sell', '/', null, null, null, '123', '123');
        TestFactory.createMulesoftUtilitySetting('Mandates', 'http://rh-mandate-gap-xapi.us-e2.cloudhub.io/api/mandateGap?', 'sourceId=', 'customerId=', null, null, '123', '123');
        TestFactory.createMulesoftUtilitySetting('Karma', 'http://rh-karma-survey-task-sfdc-xapi-dev.us-e2.cloudhub.io?', 'sourceId=', 'customerId=', 'user-email=', '&trimmed-account-codes=true&skip-history=true', '123', '123');
        TestFactory.createMulesoftUtilitySetting('priorityList', 'https://api-uat.reyesholdings.com/priority-product/account', '/', null, null, null, '123', '123');
        
        TestFactory.createTask('Test Task', 'Testing task', 'Open', testAccount.Id);
        Objective__c testObjective = TestFactory.createObjective('Test Objective', 'PVA', 'Distribution');
        TestFactory.createObjectiveAccount(testObjective.Id, 'Incomplete', testAccount.Id);
        ContentNote testContentNote = TestFactory.createContentNote('Test Note');
        TestFactory.createContentDocumentLink(testAccount.Id, testContentNote.Id);
        Id processedRecordTypeId = Schema.SObjectType.Display_Product__c.getRecordTypeInfosByName().get('Processed').getRecordTypeId();
        Display_Product__c testDisplayProduct = TestFactory.createDisplayProduct(Date.today()-1, Date.today()+7, testAccount.Id, testProduct.Id, processedRecordTypeId);
        
    }

    
    public static Product2 createSubBrandProduct(String name, String sku, String brand, String externalId, String subbrandId){
        
        Id subBrandRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Subbrand').getRecordTypeId();  
        Product2 testProduct = new Product2();
        testProduct.Name = name;
        testProduct.RecordTypeId = subBrandRecordTypeId;
        testProduct.Brand__c = brand;
        testProduct.SKU_External_Id__c = externalId;
        testProduct.Subbrand_External_Id__c = subbrandId;
        testProduct.Territories__c = '10';
        testProduct.IsActive = true;
        upsert testProduct Subbrand_External_Id__c;
        return testProduct;
    }
    
    public static Product2 createBrandProduct(String name, String sku, String brand, String externalId, String brandId){
        Id brandRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Brand').getRecordTypeId();
        Product2 testProduct = new Product2();
        testProduct.Name = name;
        testProduct.RecordTypeId = brandRecordTypeId;
        testProduct.Brand__c = brand;
        testProduct.SKU_External_Id__c = externalId;
        testProduct.Brand_External_Id__c = brandId;
        testProduct.Territories__c = '10';
        testProduct.IsActive = true;
        upsert testProduct Brand_External_Id__c;
        return testProduct;
    }

    static Account getAccount() {
        return [SELECT Id, Name, VIP_Account_Number__c, Beer_Company__c, Warehouse__c, Store_Number__c, ExternalId__c
                FROM Account
                LIMIT 1];
    }
    
    static AccountTeamMember getAccountTeamMember() {
        return [SELECT Id, UserId, AccountId, TeamMemberRole, Sales_Pointer__c
                FROM AccountTeamMember
                LIMIT 1];
    }

    static Product2 getProduct() {
        return [SELECT Id, Name, SKU_External_Id__c,Subbrand_External_Id__c,Subbrandid__r.Brand_External_Id__c,Brand_External_Id__c, BrandId__r.Brand_External_Id__c
                FROM Product2
                LIMIT 1];
    }

    static ContentNote getContentNote() {
        return [SELECT Id, Title
                FROM ContentNote
                LIMIT 1];
    }

    static Task getTask(String subject) {
        return [SELECT Id, OwnerId, Subject, Description, Status
                FROM Task
                WHERE Subject = :subject
                LIMIT 1];
    }

    static Objective_Account__c getObjectiveAccount() {
        return [SELECT Id, Objective__c, Account__c, Objective_Name__c, Status__c
                FROM Objective_Account__c
                LIMIT 1];
    }

    static Pricebook2 getPricebook(){
        return [SELECT Id, AccountId__c
                FROM Pricebook2
                LIMIT 1];
    }

    static PricebookEntry getPricebookEntry(){
        return [SELECT Id, Product2Id, Pricebook2Id
                FROM PricebookEntry
                LIMIT 1];
    }

    static Display_Product__c getDisplayProduct(){
        return [SELECT Id, Account__c, Product__c, RecordTypeId, Start_Date__c, End_Date__c
                FROM Display_Product__c
                LIMIT 1];
    }

    @isTest
    static void testFetchUser() {
	  	Test.startTest();
            User u = CriticalMinuteController.fetchUser();
        Test.stopTest();

       System.assertNotEquals(null, u, 'User should have been returned');       
    }


    @isTest
    static void testGetCriticalMinuteWrapperObjectSuggested200() {
        Account testAccount = getAccount();
        Pricebook2 standardPricebook = getPricebook();

        HttpResponse res = new HttpResponse();
        res.setBody('[{"snapShotDatetime": "2021-01-26T07:30:43.28","openGapInd": "FALSE", "productExternalId": "12345","customerExternalId": "72245","displaySequence": 1,"story": "75% within 5 mile radius selling 1.88 cases per week"}]');
        res.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));

        Test.startTest();
            CriticalMinuteController.SuggestedSellDataWrapper criticalMinuteWrapperObj = CriticalMinuteController.getCriticalMinuteSuggestedData(testAccount.Id);
        Test.stopTest();

        System.assertNotEquals(null, criticalMinuteWrapperObj, 'criticalMinuteWrapperObj should not be null');
    }


    
    @isTest
    static void testGetCriticalMinuteWrapperObject(){
        Account testAccount = getAccount();

        Test.startTest();
            CriticalMinuteController.CriticalMinuteWrapper wrapper = CriticalMinuteController.getCriticalMinuteWrapperObject(testAccount.Id, '2');
        Test.stopTest();
       
        System.assertEquals(2, wrapper.taskList.size(), '2 Tasks should have been found');
    }
    
    @isTest
    static void testGetCriticalMinuteWrapperObjectControllable(){
        Account testAccount = getAccount();
        testAccount.Controllable__c = 'Controllable';
        update testAccount;

        Test.startTest();
            CriticalMinuteController.CriticalMinuteWrapper wrapper = CriticalMinuteController.getCriticalMinuteWrapperObject(testAccount.Id, '1');
        Test.stopTest();
       
        System.assertEquals(2, wrapper.taskList.size(), '2 Tasks should have been found');
    }


    @isTest
    static void testgetpriorityListData() {
        Account testAccount = getAccount();
        Pricebook2 standardPricebook = getPricebook();

        HttpResponse res = new HttpResponse();
        String priorityListResponseBody = ' { "customerExternalId": "FDI*40891", "priorityProducts": [{ "priorityType": "Controllable Core Product", "productExternalId": 11455, "productContainerType": "Bottle", "productInvoiceDate": "2022-12-23T06:00:00",  "productWarehouseAvailableQty": 8919,  "productOnHandQty": 0.0000,      "suggestionSource": 1,      "suggestionStory": null,      "suggestionScore": 0,      "suggestionDatetime": "2022-09-30T12:36:41.047"    }	  ]}';
        res.setBody(priorityListResponseBody);
        //res.setBody('[{"snapShotDatetime": "2021-01-26T07:30:43.28","openGapInd": "FALSE", "productExternalId": "12345","customerExternalId": "72245","displaySequence": 1,"story": "75% within 5 mile radius selling 1.88 cases per week"}]');
        res.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));

        Test.startTest();
            CriticalMinuteController.PriorityListDataWrapper priorityListWrapperObj = CriticalMinuteController.getpriorityListData(testAccount.Id,'1');
        Test.stopTest();

        System.assertNotEquals(null, priorityListWrapperObj, 'criticalMinuteWrapperObj should not be null');
    }

    @isTest
    static void testgetpriorityListData400Error() {
        Account testAccount = getAccount();
        Pricebook2 standardPricebook = getPricebook();

        HttpResponse res = new HttpResponse();
        String priorityListResponseBody = ' { "customerExternalId": "FDI*40891", "priorityProducts": [{ "priorityType": "Controllable Core Product", "productExternalId": 11455, "productContainerType": "Bottle", "productInvoiceDate": "2022-12-23T06:00:00",  "productWarehouseAvailableQty": 8919,  "productOnHandQty": 0.0000,      "suggestionSource": 1,      "suggestionStory": null,      "suggestionScore": 0,      "suggestionDatetime": "2022-09-30T12:36:41.047"    }	  ]}';
        res.setBody(priorityListResponseBody);
        //res.setBody('[{"snapShotDatetime": "2021-01-26T07:30:43.28","openGapInd": "FALSE", "productExternalId": "12345","customerExternalId": "72245","displaySequence": 1,"story": "75% within 5 mile radius selling 1.88 cases per week"}]');
        res.setStatusCode(400);

        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));

        Test.startTest();
            CriticalMinuteController.PriorityListDataWrapper priorityListWrapperObj = CriticalMinuteController.getpriorityListData(testAccount.Id,'1');
        Test.stopTest();

        System.assertNotEquals(null, priorityListWrapperObj, 'criticalMinuteWrapperObj should not be null');
    }

        @isTest
    static void testgetpriorityListData401Error() {
        Account testAccount = getAccount();
        Pricebook2 standardPricebook = getPricebook();

        HttpResponse res = new HttpResponse();
        String priorityListResponseBody = ' { "customerExternalId": "FDI*40891", "priorityProducts": [{ "priorityType": "Controllable Core Product", "productExternalId": 11455, "productContainerType": "Bottle", "productInvoiceDate": "2022-12-23T06:00:00",  "productWarehouseAvailableQty": 8919,  "productOnHandQty": 0.0000,      "suggestionSource": 1,      "suggestionStory": null,      "suggestionScore": 0,      "suggestionDatetime": "2022-09-30T12:36:41.047"    }	  ]}';
        res.setBody(priorityListResponseBody);
        //res.setBody('[{"snapShotDatetime": "2021-01-26T07:30:43.28","openGapInd": "FALSE", "productExternalId": "12345","customerExternalId": "72245","displaySequence": 1,"story": "75% within 5 mile radius selling 1.88 cases per week"}]');
        res.setStatusCode(401);

        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));

        Test.startTest();
            CriticalMinuteController.PriorityListDataWrapper priorityListWrapperObj = CriticalMinuteController.getpriorityListData(testAccount.Id,'1');
        Test.stopTest();

        System.assertNotEquals(null, priorityListWrapperObj, 'criticalMinuteWrapperObj should not be null');
    }

    @isTest
    static void testgetpriorityListData404Error() {
        Account testAccount = getAccount();
        Pricebook2 standardPricebook = getPricebook();

        HttpResponse res = new HttpResponse();
        String priorityListResponseBody = ' { "customerExternalId": "FDI*40891", "priorityProducts": [{ "priorityType": "Controllable Core Product", "productExternalId": 11455, "productContainerType": "Bottle", "productInvoiceDate": "2022-12-23T06:00:00", "productWarehouseAvailableQty": 8919, "productOnHandQty": 0.0000, "suggestionSource": 1, "suggestionStory": null, "suggestionScore": 0, "suggestionDatetime": "2022-09-30T12:36:41.047"}]}';
        res.setBody(priorityListResponseBody);
        //res.setBody('[{"snapShotDatetime": "2021-01-26T07:30:43.28","openGapInd": "FALSE", "productExternalId": "12345","customerExternalId": "72245","displaySequence": 1,"story": "75% within 5 mile radius selling 1.88 cases per week"}]');
        res.setStatusCode(404);

        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));

        Test.startTest();
            CriticalMinuteController.PriorityListDataWrapper priorityListWrapperObj = CriticalMinuteController.getpriorityListData(testAccount.Id,'1');
        Test.stopTest();

        System.assertNotEquals(null, priorityListWrapperObj, 'criticalMinuteWrapperObj should not be null');
    }
    
    @isTest
    static void testgetpriorityListDataSuggestedProduct() {
        Account testAccount = getAccount();
        Pricebook2 standardPricebook = getPricebook();

        HttpResponse res = new HttpResponse();
        String priorityListResponseBody = ' { "customerExternalId": "FDI*40891", "priorityProducts": [ {"priorityType": "Suggested Sell", "productExternalId": "11455", "productBrandId": "V5*B", "productSubbrandId": "D1H*B", "productContainerType": "Keg", "productInvoiceDate": "2023-01-12T06:00:00", "productWarehouseAvailableQty": 421, "productOnHandQty": 0.0000, "mandateLevel": "", "suggestionSource": 1, "suggestionStory": "BECAUSE YOU BOUGHT: OFF APEX PRED K 1/2BBL, HALF DAISY K 1/2BBL, HALF BODEM IPA K 1/2BBL", "suggestionScore": 0.537696, "suggestionDatetime": "2023-04-03T03:06:47.617"}]}';
        res.setBody(priorityListResponseBody);
        //res.setBody('[{"snapShotDatetime": "2021-01-26T07:30:43.28","openGapInd": "FALSE", "productExternalId": "12345","customerExternalId": "72245","displaySequence": 1,"story": "75% within 5 mile radius selling 1.88 cases per week"}]');
        res.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));

        Test.startTest();
            CriticalMinuteController.PriorityListDataWrapper priorityListWrapperObj = CriticalMinuteController.getpriorityListData(testAccount.Id,'1');
        Test.stopTest();

        System.assertNotEquals(null, priorityListWrapperObj, 'criticalMinuteWrapperObj should not be null');
    }


    @isTest
    static void testgetpriorityListDataCoreProduct() {
        Account testAccount = getAccount();
        Pricebook2 standardPricebook = getPricebook();

        HttpResponse res = new HttpResponse();
        String priorityListResponseBody = ' { "customerExternalId": "FDI*40891", "priorityProducts": [ {"priorityType": "Controllable Core Product", "productExternalId": "0", "productBrandId": "V5*B", "productSubbrandId": "D1H*B", "productContainerType": "Keg", "productInvoiceDate": "2023-01-12T06:00:00", "productWarehouseAvailableQty": 421, "productOnHandQty": 0.0000, "mandateLevel": "Subbrand", "suggestionSource": 1, "suggestionStory": "BECAUSE YOU BOUGHT: OFF APEX PRED K 1/2BBL, HALF DAISY K 1/2BBL, HALF BODEM IPA K 1/2BBL", "suggestionScore": 0.537696, "suggestionDatetime": "2023-04-03T03:06:47.617"}]}';
        res.setBody(priorityListResponseBody);
        //res.setBody('[{"snapShotDatetime": "2021-01-26T07:30:43.28","openGapInd": "FALSE", "productExternalId": "12345","customerExternalId": "72245","displaySequence": 1,"story": "75% within 5 mile radius selling 1.88 cases per week"}]');
        res.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));

        Test.startTest();
            CriticalMinuteController.PriorityListDataWrapper priorityListWrapperObj = CriticalMinuteController.getpriorityListData(testAccount.Id,'1');
        Test.stopTest();

        System.assertNotEquals(null, priorityListWrapperObj, 'criticalMinuteWrapperObj should not be null');
    }
    
    @isTest
    static void testgetpriorityListDataBothProduct() {
        Account testAccount = getAccount();
        Pricebook2 standardPricebook = getPricebook();

        HttpResponse res = new HttpResponse();
        String priorityListResponseBody = ' { "customerExternalId": "FDI*40891", "priorityProducts": [ {"priorityType": "Both Suggested and Core Product", "productExternalId": "0", "productBrandId": "V5*B", "productSubbrandId": "D1H*B", "productContainerType": "Keg", "productInvoiceDate": "2023-01-12T06:00:00", "productWarehouseAvailableQty": 421, "productOnHandQty": 0.0000, "mandateLevel": "brand", "suggestionSource": 1, "suggestionStory": "BECAUSE YOU BOUGHT: OFF APEX PRED K 1/2BBL, HALF DAISY K 1/2BBL, HALF BODEM IPA K 1/2BBL", "suggestionScore": 0.537696, "suggestionDatetime": "2023-04-03T03:06:47.617"}]}';
        res.setBody(priorityListResponseBody);
        //res.setBody('[{"snapShotDatetime": "2021-01-26T07:30:43.28","openGapInd": "FALSE", "productExternalId": "12345","customerExternalId": "72245","displaySequence": 1,"story": "75% within 5 mile radius selling 1.88 cases per week"}]');
        res.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));

        Test.startTest();
            CriticalMinuteController.PriorityListDataWrapper priorityListWrapperObj = CriticalMinuteController.getpriorityListData(testAccount.Id,'1');
        Test.stopTest();

        System.assertNotEquals(null, priorityListWrapperObj, 'criticalMinuteWrapperObj should not be null');
    }
    

    @isTest
    static void testCreateFeedbackRecord() {
        Account testAccount = getAccount();
         Product2 testProduct = getProduct();
        Pricebook2 standardPricebook = getPricebook();

        Test.startTest();
    		CriticalMinuteController.createFeedbackRecord(testAccount.Id,'feedbackComment','Rejected','Previously Carried SKU',testProduct.id,'Suggested Sell');
        	Product_Feedback__c prodFeedbackObj =  CriticalMinuteController.getProductFeedbackRecord(testAccount.Id,testProduct.id);
        Test.stopTest();

        System.assertNotEquals(null, prodFeedbackObj, 'criticalMinuteWrapperObj should not be null');
    }

    
    

    @isTest
    static void testGetCriticalMinuteWrapperObjectSuggested400() {
        Account testAccount = getAccount();

        HttpResponse res = new HttpResponse();
        res.setBody('{"snapShotDatetime": "2020-06-29T07:30:43.28","productExternalId": "11432*B","customerExternalId": "HJL*20612","displaySequence": 1,"story": "75% within 5 mile radius selling 1.88 cases per week"}');
        res.setStatusCode(400);

        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));

        Test.startTest();
            CriticalMinuteController.SuggestedSellDataWrapper criticalMinuteWrapperObj = CriticalMinuteController.getCriticalMinuteSuggestedData(testAccount.Id);
        Test.stopTest();

        System.assertNotEquals(null, criticalMinuteWrapperObj, 'criticalMinuteWrapperObj should not be null');
    }

    @isTest
    static void testGetCriticalMinuteWrapperObjectSuggested404() {
        Account testAccount = getAccount();

        HttpResponse res = new HttpResponse();
        res.setBody('{"snapShotDatetime": "2020-06-29T07:30:43.28","productExternalId": "11432*B","customerExternalId": "HJL*20612","displaySequence": 1,"story": "75% within 5 mile radius selling 1.88 cases per week"}');
        res.setStatusCode(404);

        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));

        Test.startTest();
            CriticalMinuteController.SuggestedSellDataWrapper criticalMinuteWrapperObj = CriticalMinuteController.getCriticalMinuteSuggestedData(testAccount.Id);
        Test.stopTest();

        System.assertNotEquals(null, criticalMinuteWrapperObj, 'criticalMinuteWrapperObj should not be null');
    }

    @isTest
    static void testGetCriticalMinuteWrapperObjectSuggested500() {
        Account testAccount = getAccount();

        HttpResponse res = new HttpResponse();
        res.setBody('[{"snapShotDatetime": "2020-06-29T07:30:43.28","productExternalId": "11432*B","customerExternalId": "HJL*20612","displaySequence": 1,"story": "75% within 5 mile radius selling 1.88 cases per week"}]');
        res.setStatusCode(500);

        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));

        Test.startTest();
            CriticalMinuteController.SuggestedSellDataWrapper criticalMinuteWrapperObj = CriticalMinuteController.getCriticalMinuteSuggestedData(testAccount.Id);
        Test.stopTest();

        System.assertNotEquals(null, criticalMinuteWrapperObj, 'criticalMinuteWrapperObj should not be null');
    }

    @isTest
    static void testGetCriticalMinuteWrapperObjectMandates200() {
        Account testAccount = getAccount();

        HttpResponse res = new HttpResponse();
        String body = '[{"salesforceMandateId": "a002g000002HjNvAAK","mandateMetInd": "FALSE","openGapInd": "TRUE","mandateType": "None","startDate": "2019-12-31","endDate": "2030-12-31","sourceId": "GBX","customer": {"id": "ZE446", "desc": "APPLEBEE\'S - YUBA CITY" }, "salesOrg": { "id": "GB4", "desc": "GOLDEN BRANDS - CHICO" }, "salesManager": { "id": "4092", "desc": "THORNTON/CHICO" }, "warehouseInfo": { "id": "CHICO", "desc": "CHICO" }, "product1": { "id": "12345", "productDomainCd1": "B", "desc": "C24 12OZ 6P", "upc": "87692006787", "subBrand": { "id": "ABCDEFGHIJKLM", "desc": "TRULY WILD BRY" }, "brand": { "id": "A0O", "desc": "TRULY" }, "container": "Can", "invoiceDate": "2020-05-22", "invoiceNumber": "755917", "soldInd": "TRUE" }, "product2": { "id": "12345", "productDomainCd2": "B", "desc": "C24 12OZ 6P", "upc": "87692006787", "subBrand": { "id": "JWS", "desc": "TRULY WILD BRY" }, "brand": { "id": "A0O", "desc": "TRULY" }, "container": "Can", "invoiceDate": "2020-05-22", "invoiceNumber": "755917", "soldInd": "TRUE" }, "product3": { "id":"12345", "desc": "C24 12OZ 6P", "productDomainCd3": "B", "upc": "87692006787", "subBrand": { "id": "JWS", "desc": "TRULY WILD BRY" }, "brand": { "id": "A0O", "desc": "TRULY" }, "container": "Can", "invoiceDate": "2020-05-22", "invoiceNumber": "755917", "soldInd": "TRUE" },  "product4": { "id": "12345", "productDomainCd4": "B", "desc": "C24 12OZ 6P", "upc": "87692006787", "subBrand": { "id": "JWS", "desc": "TRULY WILD BRY" }, "brand": { "id": "A0O", "desc": "TRULY" }, "container": "Can", "invoiceDate": "2020-05-22", "invoiceNumber": "755917", "soldInd": "TRUE" } }]';
        res.setBody(body);
        res.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));

        Test.startTest();
            CriticalMinuteController.MandateDataWrapper criticalMinuteWrapperObj = CriticalMinuteController.getCriticalMinuteMandateData(testAccount.Id, '2');
        Test.stopTest();

        System.assertNotEquals(null, criticalMinuteWrapperObj, 'criticalMinuteWrapperObj should not be null');
    }
    
    @isTest
    static void testGetCriticalMinuteWrapperObjectMandatesBrand200() {
        Id brandRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Brand').getRecordTypeId();
        Account testAccount = getAccount();
        Product2 testProduct = getProduct();
        Product2 testBrandProduct = new Product2();
        testBrandProduct.Name = 'Test Brand';
        testBrandProduct.Territories__c = '10';
        testBrandProduct.IsActive = true;
        testBrandProduct.Brand_External_Id__c  = 'A0O*B';
        testBrandProduct.RecordTypeId = brandRecordTypeId;
        insert testBrandProduct;
        
        testProduct.BrandId__c = testBrandProduct.Id;
        //testProduct.Brand_External_Id__c = 'A0O*B';
        update testProduct;

        HttpResponse res = new HttpResponse();
        String body = '[{"salesforceMandateId": "a002g000002HjNvAAK","mandateMetInd": "FALSE","openGapInd": "TRUE","mandateType": "None","startDate": "2019-12-31","endDate": "2030-12-31","sourceId": "GBX","customer": {"id": "ZE446", "desc": "APPLEBEE\'S - YUBA CITY" }, "salesOrg": { "id": "GB4", "desc": "GOLDEN BRANDS - CHICO" }, "salesManager": { "id": "4092", "desc": "THORNTON/CHICO" }, "warehouseInfo": { "id": "CHICO", "desc": "CHICO" }, "product1": { "id": "0", "productDomainCd1": "B", "desc": "C24 12OZ 6P", "upc": "87692006787", "subBrand": { "id": "0", "desc": "TRULY WILD BRY" }, "brand": { "id": "A0O", "desc": "TRULY" }, "container": "Can", "invoiceDate": "2020-05-22", "invoiceNumber": "755917", "soldInd": "TRUE" }, "product2": { "id": "0", "productDomainCd2": "B", "desc": "C24 12OZ 6P", "upc": "87692006787", "subBrand": { "id": "0", "desc": "TRULY WILD BRY" }, "brand": { "id": "A0O", "desc": "TRULY" }, "container": "Can", "invoiceDate": "2020-05-22", "invoiceNumber": "755917", "soldInd": "TRUE" }, "product3": { "id":"0", "productDomainCd3": "B", "desc": "C24 12OZ 6P", "upc": "87692006787", "subBrand": { "id": "0", "desc": "TRULY WILD BRY" }, "brand": { "id": "A0O", "desc": "TRULY" }, "container": "Can", "invoiceDate": "2020-05-22", "invoiceNumber": "755917", "soldInd": "TRUE" },  "product4": { "id": "0", "productDomainCd4": "B", "desc": "C24 12OZ 6P", "upc": "87692006787", "subBrand": { "id": "0", "desc": "TRULY WILD BRY" }, "brand": { "id": "A0O", "desc": "TRULY" }, "container": "Can", "invoiceDate": "2020-05-22", "invoiceNumber": "755917", "soldInd": "TRUE" } }]';
        res.setBody(body);
        res.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));

        Test.startTest();
            CriticalMinuteController.MandateDataWrapper criticalMinuteWrapperObj = CriticalMinuteController.getCriticalMinuteMandateData(testAccount.Id, '2');
        Test.stopTest();

        System.assertNotEquals(null, criticalMinuteWrapperObj, 'criticalMinuteWrapperObj should not be null');
    }

    @isTest
    static void testGetCriticalMinuteWrapperObjectMandatesSubBrand200() {
        Id SubbrandRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Subbrand').getRecordTypeId();
        Account testAccount = getAccount();
        Product2 testProduct = getProduct();
        Product2 testSubBrandProduct = new Product2();
        testSubBrandProduct.Name = 'Test SubBrand';
        testSubBrandProduct.Territories__c = '10';
        testSubBrandProduct.IsActive = true;
        testSubBrandProduct.Subbrand_External_Id__c  = 'A0O*B';
        testSubBrandProduct.RecordTypeId = SubbrandRecordTypeId;
        insert testSubBrandProduct;
        
        testProduct.Subbrandid__c = testSubBrandProduct.Id;
        update testProduct;
        HttpResponse res = new HttpResponse();
        String body = '[{"salesforceMandateId": "a002g000002HjNvAAK","mandateMetInd": "FALSE","openGapInd": "TRUE","mandateType": "None","startDate": "2019-12-31","endDate": "2030-12-31","sourceId": "GBX","customer": {"id": "ZE446", "desc": "APPLEBEE\'S - YUBA CITY" }, "salesOrg": { "id": "GB4", "desc": "GOLDEN BRANDS - CHICO" }, "salesManager": { "id": "4092", "desc": "THORNTON/CHICO" }, "warehouseInfo": { "id": "CHICO", "desc": "CHICO" }, "product1": { "id": "0", "productDomainCd1": "B", "desc": "C24 12OZ 6P", "upc": "87692006787", "subBrand": { "id": "A0O", "desc": "TRULY WILD BRY" }, "brand": { "id": "A0O", "desc": "TRULY" }, "container": "Can", "invoiceDate": "2020-05-22", "invoiceNumber": "755917", "soldInd": "TRUE" }, "product2": { "id": "0", "productDomainCd2": "B", "desc": "C24 12OZ 6P", "upc": "87692006787", "subBrand": { "id": "A0O", "desc": "TRULY WILD BRY" }, "brand": { "id": "A0O", "desc": "TRULY" }, "container": "Can", "invoiceDate": "2020-05-22", "invoiceNumber": "755917", "soldInd": "TRUE" }, "product3": { "id":"0", "desc": "C24 12OZ 6P", "productDomainCd3": "B", "upc": "87692006787", "subBrand": { "id": "A0O", "desc": "TRULY WILD BRY" }, "brand": { "id": "A0O", "desc": "TRULY" }, "container": "Can", "invoiceDate": "2020-05-22", "invoiceNumber": "755917", "soldInd": "TRUE" },  "product4": { "id": "0", "productDomainCd4": "B", "desc": "C24 12OZ 6P", "upc": "87692006787", "subBrand": { "id": "A0O", "desc": "TRULY WILD BRY" }, "brand": { "id": "A0O", "desc": "TRULY" }, "container": "Can", "invoiceDate": "2020-05-22", "invoiceNumber": "755917", "soldInd": "TRUE" } }]';
        res.setBody(body);
        res.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));

        Test.startTest();
            CriticalMinuteController.MandateDataWrapper criticalMinuteWrapperObj = CriticalMinuteController.getCriticalMinuteMandateData(testAccount.Id, '2');
        Test.stopTest();

        System.assertNotEquals(null, criticalMinuteWrapperObj, 'criticalMinuteWrapperObj should not be null');
    }

    @isTest
    static void testGetCriticalMinuteWrapperObjectMandates400() {
        Account testAccount = getAccount();

        HttpResponse res = new HttpResponse();
        String body = '[{"salesforceMandateId": "a002g000002HjNvAAK","mandateMetInd": "FALSE","openGapInd": "TRUE","mandateType": "None","startDate": "2019-12-31","endDate": "2020-12-31","sourceId": "GBX","customer": {"id": "ZE446", "desc": "APPLEBEE\'S - YUBA CITY" }, "salesOrg": { "id": "GB4", "desc": "GOLDEN BRANDS - CHICO" }, "salesManager": { "id": "4092", "desc": "THORNTON/CHICO" }, "warehouseInfo": { "id": "CHICO", "desc": "CHICO" }, "product1": { "id": "38902", "desc": "C24 12OZ 6P", "upc": "87692006787", "subBrand": { "id": "ABCDEFGHIJKLM", "desc": "TRULY WILD BRY" }, "brand": { "id": "A0O", "desc": "TRULY" }, "container": "Can", "invoiceDate": "2020-05-22", "invoiceNumber": "755917", "soldInd": "TRUE" }, "product2": { "id": "38902", "desc": "C24 12OZ 6P", "upc": "87692006787", "subBrand": { "id": "JWS", "desc": "TRULY WILD BRY" }, "brand": { "id": "A0O", "desc": "TRULY" }, "container": "Can", "invoiceDate": "2020-05-22", "invoiceNumber": "755917", "soldInd": "TRUE" }, "product3": { "id": "38902", "desc": "C24 12OZ 6P", "upc": "87692006787", "subBrand": { "id": "JWS", "desc": "TRULY WILD BRY" }, "brand": { "id": "A0O", "desc": "TRULY" }, "container": "Can", "invoiceDate": "2020-05-22", "invoiceNumber": "755917", "soldInd": "TRUE" } }]';
        res.setBody(body);
        res.setStatusCode(400);

        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));

        Test.startTest();
            CriticalMinuteController.MandateDataWrapper criticalMinuteWrapperObj = CriticalMinuteController.getCriticalMinuteMandateData(testAccount.Id, '2');
        Test.stopTest();

        System.assertNotEquals(null, criticalMinuteWrapperObj, 'criticalMinuteWrapperObj should not be null');
    }

    @isTest
    static void testGetCriticalMinuteWrapperObjectMandates404() {
        Account testAccount = getAccount();

        HttpResponse res = new HttpResponse();
        String body = '[{"salesforceMandateId": "a002g000002HjNvAAK","mandateMetInd": "FALSE","openGapInd": "TRUE","mandateType": "None","startDate": "2019-12-31","endDate": "2020-12-31","sourceId": "GBX","customer": {"id": "ZE446", "desc": "APPLEBEE\'S - YUBA CITY" }, "salesOrg": { "id": "GB4", "desc": "GOLDEN BRANDS - CHICO" }, "salesManager": { "id": "4092", "desc": "THORNTON/CHICO" }, "warehouseInfo": { "id": "CHICO", "desc": "CHICO" }, "product1": { "id": "38902", "desc": "C24 12OZ 6P", "upc": "87692006787", "subBrand": { "id": "ABCDEFGHIJKLM", "desc": "TRULY WILD BRY" }, "brand": { "id": "A0O", "desc": "TRULY" }, "container": "Can", "invoiceDate": "2020-05-22", "invoiceNumber": "755917", "soldInd": "TRUE" }, "product2": { "id": "38902", "desc": "C24 12OZ 6P", "upc": "87692006787", "subBrand": { "id": "JWS", "desc": "TRULY WILD BRY" }, "brand": { "id": "A0O", "desc": "TRULY" }, "container": "Can", "invoiceDate": "2020-05-22", "invoiceNumber": "755917", "soldInd": "TRUE" }, "product3": { "id": "38902", "desc": "C24 12OZ 6P", "upc": "87692006787", "subBrand": { "id": "JWS", "desc": "TRULY WILD BRY" }, "brand": { "id": "A0O", "desc": "TRULY" }, "container": "Can", "invoiceDate": "2020-05-22", "invoiceNumber": "755917", "soldInd": "TRUE" } }]';
        res.setBody(body);
        res.setStatusCode(404);

        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));

        Test.startTest();
            CriticalMinuteController.MandateDataWrapper criticalMinuteWrapperObj = CriticalMinuteController.getCriticalMinuteMandateData(testAccount.Id, '2');
        Test.stopTest();

        System.assertNotEquals(null, criticalMinuteWrapperObj, 'criticalMinuteWrapperObj should not be null');
    }

    @isTest
    static void testGetCriticalMinuteWrapperObjectMandates500() {
        Account testAccount = getAccount();

        HttpResponse res = new HttpResponse();
        String body = '[{"error": "500"}]';
        res.setBody(body);
        res.setStatusCode(500);

        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));

        Test.startTest();
            CriticalMinuteController.MandateDataWrapper criticalMinuteWrapperObj = CriticalMinuteController.getCriticalMinuteMandateData(testAccount.Id ,'2');
        Test.stopTest();

        System.assertNotEquals(null, criticalMinuteWrapperObj, 'criticalMinuteWrapperObj should not be null');
    }

    @isTest
    static void testCompleteTask() {
        Task testTask = getTask('Test Task');
        testTask.Subject = 'Test Task3';

        Test.startTest();
            CriticalMinuteController.completeTask(testTask);
        Test.stopTest();

        List<Task> returnedTasks = [SELECT Id, Subject, Description, Status FROM Task WHERE Subject = 'Test Task3' LIMIT 1];
        System.assertEquals('Completed', returnedTasks[0].Status, 'Status should be Completed');
    }


    @isTest
    static void testGetRecordTypeValues() {
        Test.startTest();
            List<CriticalMinuteController.SelectDetails> recordTypeValues = CriticalMinuteController.getRecordTypeValues();
        Test.stopTest();

        System.assertNotEquals(null, recordTypeValues, 'recordTypeValues should not be null');
    }

    @isTest
    static void testgetAccountTeamMember() {
        Account testAccount = getAccount();
        Test.startTest();
            List<AccountTeamMember> AccountTeamMember = CriticalMinuteController.getAccountTeamMember(testAccount.id);
        Test.stopTest();

        System.assertEquals(1, AccountTeamMember.size(), 'getAccountTeamMember should return 0 record');
    }

    @isTest
    static void testGetRecTypeId() {
        Test.startTest();
            CriticalMinuteController.TaskDetails taskDetailsObj = CriticalMinuteController.getRecTypeId('General Task');
        Test.stopTest();

        Id generalTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('General Task').getRecordTypeId();

        System.assertNotEquals(taskDetailsObj, null, 'taskDetailsObj should not be null');
        System.assertNotEquals(taskDetailsObj.priorityOptions, null, 'taskDetailsObj.priorityOptions should not be null');
        System.assertNotEquals(taskDetailsObj.statusOptions, null, 'taskDetailsObj.statusOptions should not be null');
        System.assertEquals(taskDetailsObj.recordTypeId, generalTaskRecordTypeId, 'recordTypeId should match the Schema call');
    }
    

    @isTest
    static void testSaveTaskObj() {
        
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body to be insert in test class'); 
        ContentVersion testContentInsert =new ContentVersion(); 
        testContentInsert.VersionData=bodyBlob;
        testContentInsert.PathOnClient ='test';
        testContentInsert.Title ='SampleTitle'; 
        insert testContentInsert;
        
        ContentVersion cvobj = [select id,ContentDocumentId from ContentVersion where id =: testContentInsert.id];
        
        List<ContentDocument> cdList = new List<ContentDocument>();
        ContentDocument cd = new ContentDocument();
        cd.id = cvobj.ContentDocumentId;
        cdList.add(cd);
        
        Account testAccount = getAccount();
        Product2 testproduct = getProduct();
        Pricebook2 testPricebook = getPricebook();
        PricebookEntry testPriceBookEntry = getPriceBookEntry();
        testPriceBookEntry.snapshotDatetime__c = system.today();
        update testPriceBookEntry;

        //PricebookEntry testPriceBookEntry = new PricebookEntry();
        //testPriceBookEntry.Feedback_Reason__c = 'Rejected';
        
        //insert testPriceBookEntry;
        
        Product_Feedback__c pfRecord = new Product_Feedback__c();
        pfRecord.Account__c = testAccount.Id;
        pfRecord.Product__c = testproduct.Id;
        pfRecord.Expiration_date__c = Date.today();
        pfRecord.Snapshot_Date__c = Date.today();
        pfRecord.Feedback__c = 'test feedback';
        pfRecord.Suggested_Feedback_Reason__c = '1';
        insert pfRecord;
        
        AccountTeamMember testATM = getAccountTeamMember();
        Task testTask = new Task();
        testTask.Subject = 'General Task';
        testTask.WhatId = testAccount.Id;
        testTask.Description = 'Test Task';
        testTask.Status = 'Open';
		
        Id generalTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('General Task').getRecordTypeId();

        Test.startTest();
            CriticalMinuteController.saveTaskObj(testTask, generalTaskRecordTypeId, 
                                                 testAccount.Id, true, new List<AccountTeamMember>{testATM}, 
                                                 cvobj.ContentDocumentId);
        	CriticalMinuteController.deleteImageOnTask(cdList);
        	CriticalMinuteController.sendSuggestedSellFeedbackNew(testproduct.Id, testAccount.Id);
        	CriticalMinuteController.sendSuggestedSellFeedback(testPriceBookEntry.Id);
        Test.stopTest();

        List<Task> returnedTasks = [SELECT Id, Subject, Description, Status FROM Task WHERE Subject = 'General Task' LIMIT 1];
        System.assertEquals(1, returnedTasks.size(), 'returnedTasks should return 1 record');
    }
    @isTest
    static void getPricebookEntries() {
        PricebookEntry testPricebookEntry = getPricebookEntry();
        testPricebookEntry.snapshotDatetime__c = DateTime.now();
        update testPricebookEntry;
        Account testAccount = getAccount();
        Test.startTest();
        List<PricebookEntry> pricebookEntry = CriticalMinuteController.getPricebookEntries(testAccount.Id, '2');
        Test.stopTest();
        
        System.assertEquals(1, pricebookEntry.size(), 'getPricebookEntries should return 1 record');
    }

    @isTest
    static void testGetTask() {
        Account testAccount = getAccount();
       
        Test.startTest();
        List<CriticalMinuteController.TaskWrapper> getTask = CriticalMinuteController.getTask(testAccount.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, getTask, 'getTask should not be null');
    }
    
    @isTest
    static void testGetSuggestedSellPicklistValues() {
        Map<String, List<CriticalMinuteController.option>> valueMap = new Map<String, List<CriticalMinuteController.option>>();
        
        Test.startTest();
        valueMap = CriticalMinuteController.suggestedSellPicklistValues();        
        Test.stopTest();
        
        System.assertNotEquals(0, valueMap.size(), 'Should have returned picklist values');
    }
    
    @isTest
    static void testUpdatePriceBookEntry() {
        PricebookEntry testPricebookEntry = getPricebookEntry();
        Test.startTest();       
        CriticalMinuteController.updatePriceBookEntry(testPricebookEntry.Id, '1', 'Comment Test', 'Rejected');
        Test.stopTest();
        
        PricebookEntry PBE = [SELECT Id, Feedback_Reason__c FROM PricebookEntry WHERE Id =: testPricebookEntry.Id LIMIT 1];
        System.assertEquals('1', PBE.Feedback_Reason__c, 'feedback reason should have been updated');
    }
    
    @isTest
    static void testGetAlerts() {
        Account testAccount = getAccount();
        //Create an Alert
        Alert__c alert = new Alert__c();
        alert.Account__c = testAccount.Id;
        alert.Account_Alert__c = true;
        alert.Alert_Message__c = 'Alert for this Account.';
        alert.Start_Date__c = System.today();
        insert alert;
                
        Test.startTest();       
        List<CriticalMinuteController.AlertWrapper> alertWrapper = CriticalMinuteController.getAlerts(testAccount.Id);
        Test.stopTest();
                
        System.assertEquals(1, alertWrapper.size(), 'feedback reason should have been updated');
    }
    
    @isTest
    static void testOutOfTerritoryEmail() {
        Account testAccount = getAccount();
        Product2 testProduct = getProduct();
        //Create a Product Feedback Record
        Product_Feedback__c pf = new Product_Feedback__c();
        pf.Account__c = testAccount.Id;
        pf.Expiration_Date__c = System.today() + 30;
        pf.Feedback__c = 'Test';
        pf.Notes__c = 'Test';
        pf.Product__c = testProduct.Id;
        pf.Type__c = 'Pinned';
        insert pf;
        
        List<CriticalMinuteController.FlowInputs> flowInputs = new List<CriticalMinuteController.FlowInputs>();
        CriticalMinuteController.FlowInputs fi = new CriticalMinuteController.FlowInputs();
       	fi.recordId = pf.Id; 
        flowInputs.add(fi);
            
        Test.startTest();       
        CriticalMinuteController.sendMandateOutofTerritoryEmail(flowInputs);
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();
              
       // System.assertEquals(1, invocations, 'An email should be sent');
    }

    @isTest
    static void testsendSuggestedSellFeedback(){
        Account testAccount = getAccount();
        Product2 testProduct = getProduct();
        Pricebook2 standardPricebook = getPricebook();
        PriceBookEntry pbe = TestFactory.createPricebookEntry(standardPricebook.Id, testProduct.Id, 10.00, false, true);
        pbe.snapshotDatetime__c = system.now();
        pbe.Feedback__c ='No Pitch';
        pbe.Feedback_Reason__c ='4';
        update pbe;
        
		HttpResponse res = new HttpResponse();
        String body = '[{"salesforceMandateId": "a002g000002HjNvAAK","mandateMetInd": "FALSE","openGapInd": "TRUE","mandateType": "None","startDate": "2019-12-31","endDate": "2020-12-31","sourceId": "GBX","customer": {"id": "ZE446", "desc": "APPLEBEE\'S - YUBA CITY" }, "salesOrg": { "id": "GB4", "desc": "GOLDEN BRANDS - CHICO" }, "salesManager": { "id": "4092", "desc": "THORNTON/CHICO" }, "warehouseInfo": { "id": "CHICO", "desc": "CHICO" }, "product1": { "id": "38902", "desc": "C24 12OZ 6P", "upc": "87692006787", "subBrand": { "id": "ABCDEFGHIJKLM", "desc": "TRULY WILD BRY" }, "brand": { "id": "A0O", "desc": "TRULY" }, "container": "Can", "invoiceDate": "2020-05-22", "invoiceNumber": "755917", "soldInd": "TRUE" }, "product2": { "id": "38902", "desc": "C24 12OZ 6P", "upc": "87692006787", "subBrand": { "id": "JWS", "desc": "TRULY WILD BRY" }, "brand": { "id": "A0O", "desc": "TRULY" }, "container": "Can", "invoiceDate": "2020-05-22", "invoiceNumber": "755917", "soldInd": "TRUE" }, "product3": { "id": "38902", "desc": "C24 12OZ 6P", "upc": "87692006787", "subBrand": { "id": "JWS", "desc": "TRULY WILD BRY" }, "brand": { "id": "A0O", "desc": "TRULY" }, "container": "Can", "invoiceDate": "2020-05-22", "invoiceNumber": "755917", "soldInd": "TRUE" } }]';
        res.setBody(body);
        res.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));        
        
        Test.startTest();       
        	Id idval = CriticalMinuteController.sendSuggestedSellFeedback(pbe.id);
        	System.assertNotEquals(idval, null);
        Test.stopTest();
        
    }
    
    @isTest
    static void testsendFeedback() {
        Account testAccount = getAccount();
        Product2 testProduct = getProduct();
        //Create a Product Feedback Record
        Product_Feedback__c pf = new Product_Feedback__c();
        pf.Account__c = testAccount.Id;
        pf.Expiration_Date__c = System.today() + 30;
        pf.Feedback__c = 'Test';
        pf.Notes__c = 'Test';
        pf.Product__c = testProduct.Id;
        pf.Type__c = 'Suggested Sell';
        pf.Suggested_Feedback_Reason__c = '12';
        pf.Snapshot_Date__c = System.today() ;
        insert pf;
		HttpResponse res = new HttpResponse();
        String body = '[{"salesforceMandateId": "a002g000002HjNvAAK","mandateMetInd": "FALSE","openGapInd": "TRUE","mandateType": "None","startDate": "2019-12-31","endDate": "2020-12-31","sourceId": "GBX","customer": {"id": "ZE446", "desc": "APPLEBEE\'S - YUBA CITY" }, "salesOrg": { "id": "GB4", "desc": "GOLDEN BRANDS - CHICO" }, "salesManager": { "id": "4092", "desc": "THORNTON/CHICO" }, "warehouseInfo": { "id": "CHICO", "desc": "CHICO" }, "product1": { "id": "38902", "desc": "C24 12OZ 6P", "upc": "87692006787", "subBrand": { "id": "ABCDEFGHIJKLM", "desc": "TRULY WILD BRY" }, "brand": { "id": "A0O", "desc": "TRULY" }, "container": "Can", "invoiceDate": "2020-05-22", "invoiceNumber": "755917", "soldInd": "TRUE" }, "product2": { "id": "38902", "desc": "C24 12OZ 6P", "upc": "87692006787", "subBrand": { "id": "JWS", "desc": "TRULY WILD BRY" }, "brand": { "id": "A0O", "desc": "TRULY" }, "container": "Can", "invoiceDate": "2020-05-22", "invoiceNumber": "755917", "soldInd": "TRUE" }, "product3": { "id": "38902", "desc": "C24 12OZ 6P", "upc": "87692006787", "subBrand": { "id": "JWS", "desc": "TRULY WILD BRY" }, "brand": { "id": "A0O", "desc": "TRULY" }, "container": "Can", "invoiceDate": "2020-05-22", "invoiceNumber": "755917", "soldInd": "TRUE" } }]';
        res.setBody(body);
        res.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));        
        
        Test.startTest();       
        	Id idval = CriticalMinuteController.sendSuggestedSellFeedbackNew(testProduct.id, testAccount.id);
        	System.assertNotEquals(idval, null);
        Test.stopTest();
    }
}
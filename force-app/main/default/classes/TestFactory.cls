@IsTest
public class TestFactory {
    
    public static Account createAccount(String name, String accountNum, String bu, String warehouse, String parentId, String storeNumber) {
        Account testAccount = new Account();
        testAccount.Name = name;
        testAccount.Account_Type__c = 'None';
        testAccount.VIP_Account_Number__c = accountNum;
        testAccount.VIP_Instance__c = 'PVA';
        testAccount.ExternalId__c = '72245';
        testAccount.Chain__c = 'FOOD LION';
        testAccount.Beer_Company__c = bu;
        testAccount.Warehouse__c = warehouse;
        testAccount.ParentId = parentId;
        testAccount.Store_Number__c = storeNumber;
        testAccount.Territories__c = '10';
        testAccount.Status__c = 'A';
        insert testAccount;
        return testAccount;
    }
    
    public static Account createAccountRecordTypeId(String name, String recordTypeId) {
        Account testAccount = new Account();
        testAccount.Name = name;       
        testAccount.Status__c = 'A';
        testAccount.RecordTypeId = recordTypeId;
        insert testAccount;
        return testAccount;
    }

    public static AccountContactRelation createAccountContactRelation(Id accountId, Id contactId){
        AccountContactRelation testAccountContactRelation = new AccountContactRelation();
        testAccountContactRelation.AccountId = accountId;
        testAccountContactRelation.ContactId = contactId;
        insert testAccountContactRelation;
        return testAccountContactRelation;
    }

    public static Schema.Location createLocation(String name, String locationType){
        Schema.Location testLocation = new Schema.Location();
        testLocation.Name = name;
        testLocation.LocationType = locationType;
        insert testLocation;
        return testLocation;
    }

    public static RetailStore createRetailStore(String name, String accountId, String locationId, String accountCode, String bu, String warehouse) {
        RetailStore testRetailStore = new RetailStore();
        testRetailStore.Name = name;
        testRetailStore.AccountId = accountId;
        testRetailStore.Account_Type__c = 'None';
        testRetailStore.LocationId = locationId;
        testRetailStore.VIP_Account_Number__c = accountCode;
        testRetailStore.Beer_Company__c = bu;
        testRetailStore.Warehouse__c = warehouse;
        insert testRetailStore;
        return testRetailStore;
    }

    public static Objective__c createObjective(String name, String bu, String type){
        Objective__c testObjective = new Objective__c();
        testObjective.Name = name;
        testObjective.BU__c = bu;
        testObjective.Objective_Type__c = type;
        testObjective.Start_Date__c = System.Today() - 1;
        testObjective.End_Date__c = System.Today() + 1;
        testObjective.Goal__c = 100;
        insert testObjective;
        return testObjective;
    }

    public static Objective_Location__c createObjectiveLocation(String objectiveId, String bu, String warehouse, Integer goalAmount) {
        Objective_Location__c testObjectiveLocation = new Objective_Location__c();
        testObjectiveLocation.Objective__c = objectiveId;
        testObjectiveLocation.BU__c = bu;
        testObjectiveLocation.SalesOrg__c = bu;
        testObjectiveLocation.Warehouse__c = warehouse;
        testObjectiveLocation.Goal_Amount__c = goalAmount;
        insert testObjectiveLocation;
        return testObjectiveLocation;
    }

    public static Objective_Product__c createObjectiveProduct(String objectiveId, String productId) {
        Objective_Product__c testObjectiveProduct = new Objective_Product__c();
        testObjectiveProduct.Objective__c = objectiveId;
        testObjectiveProduct.Product__c = productId;
        insert testObjectiveProduct;
        return testObjectiveProduct;
    }

    public static Objective_Account__c createObjectiveAccount(String objectiveId, String status, String accountId) {
        Objective_Account__c testObjectiveAccount = new Objective_Account__c();
        testObjectiveAccount.Objective__c = objectiveId;
        testObjectiveAccount.Status__c = status;
        testObjectiveAccount.Account__c = accountId;
        insert testObjectiveAccount;
        return testObjectiveAccount;
    }

    public static Objective_Account__c createObjectiveAccountRecordTypeId(String objectiveId, String status, String accountId, Id recordTypeId) {
        Objective_Account__c testObjectiveAccount = new Objective_Account__c();
        testObjectiveAccount.RecordTypeId = recordTypeId;
        testObjectiveAccount.Objective__c = objectiveId;
        testObjectiveAccount.Status__c = status;
        testObjectiveAccount.Account__c = accountId;
        insert testObjectiveAccount;
        return testObjectiveAccount;
    }

    public static Objective_Goal__c createObjectiveGoal(String objectiveId, String userId, String objLocId, Integer goalAmount){
        Objective_Goal__c testObjectiveGoal = new Objective_Goal__c();
        testObjectiveGoal.Objective__c = objectiveId;
        testObjectiveGoal.Goal_Assignee__c = userId;
        testObjectiveGoal.Objective_Location__c = objLocId;
        testObjectiveGoal.Goal_Amount__c = goalAmount;
        insert testObjectiveGoal;
        return testObjectiveGoal;
    }
	
    public static Objective_Submission__c createObjectiveSubmission(String objectiveAccId){
        Objective_Submission__c testObjectiveDisplay = new Objective_Submission__c();
        testObjectiveDisplay.Objective_Account__c = objectiveAccId;
        insert testObjectiveDisplay;
        return testObjectiveDisplay;
    }

    public static Product2 createProduct(String name, String sku, String brand, String externalId){
        Product2 testProduct = new Product2();
        testProduct.Name = name;
        testProduct.Brand__c = brand;
        testProduct.SKU_External_Id__c = externalId;
        testProduct.Territories__c = '10';
        testProduct.IsActive = true;
        upsert testProduct SKU_External_Id__c;
        return testProduct;
    }

    public static Display_Product__c createDisplayProduct(Date startDate, Date endDate, String accountId, String productId, String recordTypeId){
        Display_Product__c testDisplayProd = new Display_Product__c();
        testDisplayProd.RecordTypeId = recordTypeId;
        testDisplayProd.Account__c = accountId;
        testDisplayProd.Product__c = productId;
        testDisplayProd.Start_Date__c = startDate;
        testDisplayProd.End_Date__c = endDate;
        insert testDisplayProd;
        return testDisplayProd;
    }

    public static ContentDocumentLink createContentDocumentLink(String recordId, String contentId){
        ContentDocumentLink testContentDocumentLink = new ContentDocumentLink();
        testContentDocumentLink.LinkedEntityId = recordId;
        testContentDocumentLink.ContentDocumentId = contentId;
        testContentDocumentLink.ShareType = 'I';
        testContentDocumentLink.Visibility = 'AllUsers';
        insert testContentDocumentLink;
        return testContentDocumentLink;
    }

    public static ContentNote createContentNote(String title){
        ContentNote testContentNote = new ContentNote();
        testContentNote.Title = title;
        testContentNote.Content = Blob.valueOf('');
        insert testContentNote;
        return testContentNote;
    }

    public static ContentVersion createContentVersion(String title, String description, String pathOnClient, String externalDataSource, 
                                                    String externalId, String contentLocation, String origin){
        ContentVersion testContentVersionObj = new ContentVersion();
        testContentVersionObj.Title = title;
        testContentVersionObj.Description = description;
        testContentVersionObj.PathOnClient = pathOnClient;
        testContentVersionObj.ExternalDataSourceId = externalDataSource;
        testContentVersionObj.ExternalDocumentInfo2 = externalId;
        testContentVersionObj.ContentLocation = contentLocation;
        testContentVersionObj.Origin = origin;
        insert testContentVersionObj;
        return testContentVersionObj;
    }

    public static Sharepoint_Document_Types__c createSharepointDocumentType(String label, String documentType){
        Sharepoint_Document_Types__c testSharepointDocumentType = new Sharepoint_Document_Types__c();
        testSharepointDocumentType.Name = label;
        testSharepointDocumentType.Sharepoint_Document_Types__c = documentType;
        insert testSharepointDocumentType;
        return testSharepointDocumentType;
    }

    public static Mulesoft_API_Settings__c createMulesoftUtilitySetting(String label, String endpoint, String param1, String param2, String param3, String param4,
                                                                        String clientId, String clientSecret){
        Mulesoft_API_Settings__c testMulesoftUtilitySetting = new Mulesoft_API_Settings__c();
        testMulesoftUtilitySetting.Name = label;
        testMulesoftUtilitySetting.Endpoint__c = endpoint;
        testMulesoftUtilitySetting.param1__c = param1;
        testMulesoftUtilitySetting.param2__c = param2;
        testMulesoftUtilitySetting.param3__c = param3;
        testMulesoftUtilitySetting.param4__c = param4;
        testMulesoftUtilitySetting.Client_Id__c = clientId;
        testMulesoftUtilitySetting.Client_Secret__c = clientSecret;
        insert testMulesoftUtilitySetting;
        return testMulesoftUtilitySetting;
    }

    public static Mulesoft_API_Settings__c createmulesoftSuggestedSellPost(String label,String endpoint, String clientId, String clientSecret){
        Mulesoft_API_Settings__c testMulesoftSuggestedFeedbackSetting = new Mulesoft_API_Settings__c();
        testMulesoftSuggestedFeedbackSetting.Name = label;
        testMulesoftSuggestedFeedbackSetting.Endpoint__c = endpoint;
        testMulesoftSuggestedFeedbackSetting.Client_Id__c = clientId;
        testMulesoftSuggestedFeedbackSetting.Client_Secret__c = clientSecret;
        insert testMulesoftSuggestedFeedbackSetting;
        return testMulesoftSuggestedFeedbackSetting;
    }

    public static Task createTask(String subject, String description, String status, String recordId){
        Task testTask = new Task();
        testTask.Subject = subject;
        testTask.WhatId = recordId;
        testTask.Description = description;
        testTask.Status = status;
        insert testTask;
        return testTask;
    }

    public static Task createTaskByRecordType(String subject, String recordTypeId, String status, String recordId, Date taskDate){
        Task testTask = new Task();
        testTask.RecordTypeId = recordTypeId;
        testTask.Subject = subject;
        testTask.WhatId = recordId;
        testTask.Status = status;
        testTask.ActivityDate = taskDate;

        testTask.Original_Call_Date__c = taskDate;

        insert testTask;
        return testTask;
    }

    public static UserRole createUserRole(String name, String developerName){
        UserRole testUserRole = new UserRole();
        testUserRole.DeveloperName = developerName;
        testUserRole.Name = name;
        insert testUserRole;
        return testUserRole;
    }

    public static PermissionSetAssignment createPermissionSetAssignment(String permissionSetId, String userId){
        PermissionSetAssignment testPermissionSetAssignment = new PermissionSetAssignment();
        testPermissionSetAssignment.PermissionSetId = permissionSetId;
        testPermissionSetAssignment.AssigneeId = userId;
        insert testPermissionSetAssignment;
        return testPermissionSetAssignment;
    }

    public static User createUser(Id profileId, String roleId, String username, String managerId){
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User testUser = new User();
        testUser.ProfileId = profileId;
        testUser.UserName = username;
        testUser.Email = username;
        testUser.EmailenCodingKey = 'UTF-8';
        testUser.LocalesIdKey = 'en_US';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.TimeZonesIdKey = 'America/Los_Angeles';
        testUser.Alias = 'extUser';
        testUser.FirstName = 'Test';
        testUser.LastName = 'User';
        testUser.UserRoleId = roleId;
        testUser.ManagerId = managerId;
        insert testUser;
        return testUser;
    }

    public static RetailStore createGreenmileRetailStore(String name, String accountId, String locationId, String accountCode, String bu, String warehouse, String vipInstance, String vipAccount){
        RetailStore testRetailStore = new RetailStore();
        testRetailStore.Name = name;
        testRetailStore.AccountId = accountId;
        testRetailStore.Account_Type__c = 'None';
        testRetailStore.LocationId = locationId;
        testRetailStore.VIP_Account_Number__c = accountCode;
        //testRetailStore.Beer_Company__c = bu;
        testRetailStore.Warehouse__c = warehouse;
        testRetailStore.VIP_Instance__c = vipInstance;
        testRetailStore.VIP_Account_Number__c = vipAccount;
        insert testRetailStore;
        return testRetailStore;
    }

    public static User createUser(Id profileId, String roleId, String username, String managerId, String federatedId){
        User testUser = new User();
        testUser.ProfileId = profileId;
        testUser.UserName = username;
        testUser.Email = 'externalUser@gmail.com';
        testUser.EmailenCodingKey = 'UTF-8';
        testUser.LocalesIdKey = 'en_US';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.TimeZonesIdKey = 'America/Los_Angeles';
        testUser.Alias = 'extUser';
        testUser.FirstName = 'Test';
        testUser.LastName = 'User';
        testUser.VIP_Company__c = 'HDI';
        testUser.UserRoleId = roleId;
        testUser.ManagerId = managerId;
        testUser.FederationIdentifier = federatedId;
        testUser.IsActive = true;
        insert testUser;
        return testUser;
    }

    public static Account createGreenmileRetailStore(String name, String vipInstance, String vipAccount) {
        Account testRetailStore = new Account();
        testRetailStore.Name = name;
        testRetailStore.VIP_Instance__c = vipInstance;
        testRetailStore.VIP_Account_Number__c = vipAccount;
        insert testRetailStore;
        return testRetailStore;
    }

    public static Warehouse__c createWarehouse(String warehouseName, Id ISR, String warehouseId, String warehouseDIMId, string salesOrgId, string salesOrg, String reportingEntity, String reportingEntityId){
        Warehouse__c testWarehouse = new Warehouse__c();
        testWarehouse.Name = warehouseName;
        //testWarehouse.ISR_1__c = ISR;
        testWarehouse.Warehouse_ID__c = warehouseId;
        testWarehouse.Warehouse_Dim_ID__c = warehouseDIMId;
        testWarehouse.Sales_Org_Id__c = salesOrgId;
        testWarehouse.Sales_Org__c = salesOrg; 
        testWarehouse.Reporting_Entity__c = reportingEntity;
        testWarehouse.Reporting_Entity_Id__c = reportingEntityId;
        insert testWarehouse;
        return testWarehouse;
    }
    public static Alert__c createAlert(String name, Date startDate, Date endDate, String alertMessage, String type, Id accountId){

        Boolean isOrder = type.contains('Order');
        Boolean isAccount = type.contains('Account');
        Alert__c accountAlert = new Alert__c();
        accountAlert.Account_Alert__c = isAccount;
        accountAlert.Order_Alert__c = isOrder;

        accountAlert.Start_Date__c = startDate;
        accountAlert.End_Date__c = endDate;
        accountAlert.Alert_Message__c = alertMessage;
        accountAlert.Account__c = accountId;
        insert accountAlert;
        return accountAlert;
    }

    public static Pricebook2 createPriceBook(String accountId, String name, Boolean active, String description){
        Pricebook2 testPriceBook = new Pricebook2();
        testPriceBook.Name = name;
        testPriceBook.Description = description;
        testPriceBook.IsActive = active;
        testPriceBook.AccountId__c = accountId;
        insert testPriceBook;
        return testPriceBook;
    }

    public static Pricebook2 createStandardPriceBook(){
        Pricebook2 testPriceBook = new Pricebook2();
        testPriceBook.Id = Test.getStandardPricebookId();
        testPriceBook.IsActive = true;
        update testPriceBook;
        return testPriceBook;
    }

    public static Order createOrder(String accountId, String priceBookId, Date effectiveDate, String status){
        Order testOrder = new Order();
        testOrder.AccountId = accountId;
        testOrder.EffectiveDate = effectiveDate;
        testOrder.Status = status;
        testOrder.Pricebook2Id = priceBookId;
        testOrder.Delivery_Date__c = effectiveDate;
        insert testOrder;
        return testOrder;
    }

    public static Order createOrderBeerline(String accountId, String priceBookId, Date effectiveDate, String status, String sourceCode){
        Order testOrder = new Order();
        testOrder.AccountId = accountId;
        testOrder.EffectiveDate = effectiveDate;
        testOrder.Status = status;
        testOrder.Pricebook2Id = priceBookId;
        testOrder.OrderSourceCode__c = sourceCode;
        insert testOrder;
        return testOrder;
    }

    public static Order createOrderRecordType(String accountId, String priceBookId, Date effectiveDate, String status, String recordTypeId){
        Order testOrder = new Order();
        testOrder.RecordTypeId = recordTypeId;
        testOrder.AccountId = accountId;
        testOrder.EffectiveDate = effectiveDate;
        testOrder.Status = status;
        testOrder.Pricebook2Id = priceBookId;
        testOrder.Delivery_Date__c = effectiveDate;
        testOrder.Invoice_Date__c = System.today();
        insert testOrder;
        return testOrder;
    }

    public static PriceBookEntry createPriceBookEntry(String priceBookId, String productId, Decimal price, Boolean useStandardPrice, Boolean active){
        PricebookEntry testPriceBookEntry = new PricebookEntry();
        PricebookEntry[] pbeList = [SELECT Id, Pricebook2Id, Product2Id,UnitPrice, UseStandardPrice, IsActive FROM PricebookEntry WHERE 
            Pricebook2Id = :priceBookId AND Product2Id = :productId LIMIT 1];
        if (pbeList.size() == 0){
            testPriceBookEntry = new PricebookEntry();
        testPriceBookEntry.Pricebook2Id = priceBookId;
        testPriceBookEntry.Product2Id = productId;
        testPriceBookEntry.UnitPrice = price;
        testPriceBookEntry.UseStandardPrice = useStandardPrice;
        testPriceBookEntry.IsActive = active;
        insert testPriceBookEntry;
        } else {
            testPriceBookEntry = pbeList[0];
        }
        return testPriceBookEntry;
    }

    public static PriceBookEntry createPriceBookEntryInvoice(String priceBookId, String productId, Decimal price, Boolean useStandardPrice, Boolean active, String invoiceId){
        PricebookEntry testPriceBookEntry = new PricebookEntry();
        testPriceBookEntry.Pricebook2Id = priceBookId;
        testPriceBookEntry.Product2Id = productId;
        testPriceBookEntry.UnitPrice = price;
        testPriceBookEntry.UseStandardPrice = useStandardPrice;
        testPriceBookEntry.IsActive = active;
        testPriceBookEntry.Invoice__c = invoiceId;
        testPriceBookEntry.Quantity_sold__c = 1;
        insert testPriceBookEntry;
        return testPriceBookEntry;
    }

    public static Contact createContact(String accountId, String firstName, String lastName, String email){
        Contact testContact = new Contact();
        testContact.AccountId = accountId;
        testContact.FirstName = firstName;
        testContact.LastName = lastName;
        testContact.Email = email;
        insert testContact;
        return testContact;
    }

    public static OrderItem createOrderItem(String priceBookEntryId, String orderId, Decimal qty, Decimal inventory, Decimal price, String productId){
        OrderItem testOrderItem = new OrderItem();
        testOrderItem.PricebookEntryId = priceBookEntryId;
        testOrderItem.OrderId = orderId;
        testOrderItem.Quantity_Order__c = qty;
        testOrderItem.Inventory__c = inventory;
        testOrderItem.UnitPrice = price;
        testOrderItem.Product2Id = productId;
        testOrderItem.Quantity = 1;
        insert testOrderItem;
        return testOrderItem;
    }

    public static Reyes_Org_Setting__c createReyesOrgSetting(Decimal minOrderQty, Decimal minOrderDays){
        Reyes_Org_Setting__c testReyesOrgSetting = new Reyes_Org_Setting__c();
        testReyesOrgSetting.Min_Order_History_Qty__c = minOrderQty;
        testReyesOrgSetting.Min_Order_history_days__c = minOrderDays;
        insert testReyesOrgSetting;
        return testReyesOrgSetting;
    }

    public static Invoice__c createInvoice(Date invoiceDate, Id accountId){
        Invoice__c testInvoice = new Invoice__c();
        testInvoice.Invoice_Date__c = invoiceDate;
        testInvoice.AccountId__c = accountId;
        insert testInvoice;
        return testInvoice;
    }

    public static Business_Unit__c createBusinessUnit(String name, String url, String userName, String userPassword, String cookie){
        Business_Unit__c testBusinessUnit = new Business_Unit__c();
        testBusinessUnit.Name = name;
        testBusinessUnit.VIP_API_URL__c = url;
        testBusinessUnit.VIP_API_User_Name__c = userName;
        testBusinessUnit.VIP_API_User_Password__c = userPassword;
        testBusinessUnit.VIPCookie__c = cookie;
        insert testBusinessUnit;
        return testBusinessUnit;
    }

    public static Delivery_Date__c createDeliveryDate(Id accountId, Date deliveryDate, String status){
        Delivery_Date__c testDeliveryDate = new Delivery_Date__c();
        testDeliveryDate.Account__c = accountId;
        testDeliveryDate.Delivery_Date__c = deliveryDate;
        testDeliveryDate.Original_Delivery_Date__c = deliveryDate;
        testDeliveryDate.Status__c = status;
        insert testDeliveryDate;
        return testDeliveryDate;
    }

    public static Plan__c createPlan(String name, Date deliveryDate, String callDates, String deliveryDates, String deliveryPercentages,
                                            String callPercentages, String citiesSelected, String frequencies, String premise,
                                            String sellTypes, String warehouses){
        Plan__c testPlan = new Plan__c();
        testPlan.Name = name;
        testPlan.Original_Delivery_Date__c = deliveryDate;
        testPlan.Call_Dates__c = callDates;
        testPlan.Delivery_Percentages__c = deliveryPercentages;
        testPlan.Call_Percentages__c = callPercentages;
        testPlan.Delivery_Dates__c = deliveryDates;
        testPlan.Delivery_Frequencies__c = frequencies;
        testPlan.Premise_Types__c = premise;
        testPlan.Sell_Types__c = sellTypes;
        testPlan.Warehouses__c = warehouses;
        testPlan.Cities_Selected__c = citiesSelected;
        insert testPlan;
        return testPlan;
    }

    public static Shift__c createShift(Id employeeId, Time startTime, Time endTime){
        Shift__c testShift = new Shift__c();
        testShift.Start_Time__c = startTime;
        testShift.End_Time__c = endTime;
        testShift.Employee__c = employeeId;
        insert testShift;
        return testShift;
    }

    public static Out_Of_Office__c createOutOfOffice(Id employeeId, Date startDate, Date endDate){
        Out_Of_Office__c testOutOfOffice = new Out_Of_Office__c();
        testOutOfOffice.Start_Date__c = startDate;
        testOutOfOffice.End_Date__c = endDate;
        testOutOfOffice.Who_Is_Out__c = employeeId;
        insert testOutOfOffice;
        return testOutOfOffice;
    }

    public static AccountTeamMember createAccountTeamMember(Id accountId, Id userId, String role){
        AccountTeamMember testAccountTeamMember = new AccountTeamMember();
        testAccountTeamMember.AccountId = accountId;
        testAccountTeamMember.UserId = userId;
        testAccountTeamMember.TeamMemberRole = role;
        insert testAccountTeamMember;
        return testAccountTeamMember;
    }
    
	public static Merch_Checklist__c createMerchChecklist(Id accountId, Date checklistDate) {
        Merch_Checklist__c testMC = new Merch_Checklist__c();
    	testMC.Display_Approved_By__c = 'Store Manager';
        testMC.Account__c = accountId;
        testMC.Requested_Completion_Date__c = checklistDate;
        testMC.Status__c = 'Open';	        
        insert testMC;
        return testMC;
    }
    
        public static Beerboard_API_Settings__c createBeerboardDraftUtilitySetting(String label, String endpoint, String token){
        Beerboard_API_Settings__c testBBDraftUtilitySetting = new Beerboard_API_Settings__c();
        testBBDraftUtilitySetting.Name = label;
        testBBDraftUtilitySetting.Endpoint__c = endpoint;
        testBBDraftUtilitySetting.tokenid__c = token;
        insert testBBDraftUtilitySetting;
        return testBBDraftUtilitySetting;
    }
    
}
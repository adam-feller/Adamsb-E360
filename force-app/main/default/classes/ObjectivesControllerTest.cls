@isTest
private class ObjectivesControllerTest {

    @TestSetup
    private static void setup() {
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        UserRole preSalesRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Admin'];
        UserRole salesManagerRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Admin'];
        User testSalesManager = TestFactory.createUser(systemAdminProfile.Id, salesManagerRole.Id, 'newtest3User@gmail.com', null);
        TestFactory.createUser(systemAdminProfile.Id, preSalesRole.Id, 'newtest2User@gmail.com', testSalesManager.Id);
        Id localRecordTypeId = Schema.SObjectType.Objective__c.getRecordTypeInfosByName().get('Local').getRecordTypeId();
        Id cascadeRecordTypeId = Schema.SObjectType.Objective__c.getRecordTypeInfosByName().get('Cascade').getRecordTypeId();

        System.runAs(testSalesManager) {
            Account testAccount = TestFactory.createAccount('Test Parent Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '12345');
            testAccount.SalesOrg__c = 'PVA';
            testAccount.Territories__c = 'PVA*1';
            update testAccount;
            Account testAccount2 = TestFactory.createAccount('Test Account', '202', 'PVA', 'PDVA-CHANTILLY', testAccount.Id, '12346');
            testAccount2.SalesOrg__c = 'PVA';
            testAccount2.Territories__c = 'PVA*1';
            update testAccount2;
            //Create Brewer/Supplier Account
            Id brewerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Brewer/Supplier').getRecordTypeId();
            Account testBrewer = TestFactory.createAccountRecordTypeId('MOLSON COORS', brewerRecordTypeId);            
			//Create Brand Product
            Id brandRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Brand').getRecordTypeId();
            Product2 testBrand = TestFactory.createProduct('MILLER64', null, null, 'EN*B');
            testBrand.RecordTypeId = brandRecordTypeId;
            testBrand.BrewerId__c = testBrewer.Id;
            update testBrand;
            //Create Subbrand Product
            Id subbrandRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Subbrand').getRecordTypeId();
            Product2 testSubBrand = TestFactory.createProduct('MILLER64', null, null, '975*B');
            testSubBrand.RecordTypeId = subbrandRecordTypeId;
            testSubBrand.BrewerId__c = testBrewer.Id;
            testSubBrand.BrandId__c = testBrand.Id;
            update testSubBrand;            			
			//Local Objective
            Objective__c testObjective = TestFactory.createObjective('Test Objective', 'PVA', 'Display');
            testObjective.Parent_Child_Independent__c = 'Local';
            testObjective.RecordTypeId = localRecordTypeId;
            update testObjective;
            Product2 testProd = TestFactory.createProduct('Test Product', '12345', 'MillerCoors', '123*B');
            testProd.BrandId__c = testBrand.Id;
            testProd.Subbrandid__c = testSubBrand.Id;
            testProd.Territories__c = 'PVA*1';
            update testProd;
            TestFactory.createObjectiveLocation(testObjective.Id, 'PVA', 'PDVA-CHANTILLY', 100);
            TestFactory.createObjectiveAccount(testObjective.Id, 'Incomplete', testAccount.Id);
            TestFactory.createObjectiveProduct(testObjective.Id, testProd.Id);
            //Cascade Objective
            Objective__c testObjective2 = TestFactory.createObjective('Test Objective', 'PVA', 'Display');
            testObjective2.Parent_Child_Independent__c = 'Cascade';
            testObjective2.RecordTypeId = cascadeRecordTypeId;
            update testObjective2;
            Product2 testProd2 = TestFactory.createProduct('Test Product', '12345', 'MillerCoors', '123*B');
            testProd2.DRAFT_OR_PACKAGE__c = 'Package';
            testProd2.Territories__c = 'PVA*1';
            testProd2.BrandId__c = testBrand.Id;
            testProd2.Subbrandid__c = testSubBrand.Id;
            update testProd2;
            TestFactory.createObjectiveLocation(testObjective2.Id, 'PVA', 'PDVA-CHANTILLY', 100);
            TestFactory.createObjectiveAccount(testObjective2.Id, 'Incomplete', testAccount.Id);
            TestFactory.createObjectiveProduct(testObjective2.Id, testProd.Id);
        }
    }

    static Objective__c getObjective() {
        return [SELECT Id, Name, Picture_Required__c, Goal_Type__c, FiltersInclude__c, FiltersLong__c, ProductFiltersInclude__c, ProductFiltersLong__c
                FROM Objective__c WHERE Parent_Child_Independent__c = 'Local'
                LIMIT 1];
    }
    
    static Objective__c getParentObjective() {
        return [SELECT Id, Name, Picture_Required__c, Goal_Type__c, FiltersInclude__c, FiltersLong__c, ProductFiltersInclude__c, ProductFiltersLong__c
                FROM Objective__c WHERE Parent_Child_Independent__c = 'Cascade'
                LIMIT 1];
    }

    static Objective_Location__c getObjectiveLocation() {
        return [SELECT Id, Objective__c, BU__c, SalesOrg__c, Warehouse__c
                FROM Objective_Location__c
                LIMIT 1];
    }

    static Objective_Product__c getObjectiveProduct(Id objId) {
        return [SELECT Id, Objective__c
                FROM Objective_Product__c WHERE Objective__c = :objId
                LIMIT 1];
    }

    static User getUserbyUsername(String username) {
        return [SELECT Id, Name, UserRoleId, Goal_Amount__c
                FROM User WHERE Username = :username
                LIMIT 1];
    }

    static Account getAccount(String Name) {
        return [SELECT Id, Name, VIP_Account_Number__c, Beer_Company__c, Warehouse__c
                FROM Account WHERE Name = :name
                LIMIT 1];
    }

    static Product2 getProduct() {
        return [SELECT Id, Name, SKU__c
                FROM Product2 WHERE Name = 'Test Product' 
                LIMIT 1];
    }

    @isTest
    static void testGetObjectives() {
        Objective__c testObj = getObjective();

        Test.startTest();
            List<ObjectivesController.ObjectiveWrapper> objectiveList = ObjectivesController.getObjectives(null, 'PVA', testObj.Id);
        Test.stopTest();

        System.assertEquals(1, objectiveList.size(), '1 objective record should be returned');
    }
    
    @isTest
    static void testGetObjectivesNullObjective() {
        Test.startTest();
            List<ObjectivesController.ObjectiveWrapper> objectiveList = ObjectivesController.getObjectives('National Objective Admin', 'PVA', null);
        Test.stopTest();

        System.assertEquals(2, objectiveList.size(), '2 Objectives should be returned');
    }

    @isTest
    static void testGetUserData() {
        User testUser = getUserbyUsername('newtest2User@gmail.com');
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'National_Admin'];
		insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps.Id);
        Objective__c testObj = getObjective();

        ObjectivesController.UserDataWrapper userList = new ObjectivesController.UserDataWrapper();

        System.runAs(testUser) {
            Test.startTest();
            	userList = ObjectivesController.getUserData(testObj.Id);
            Test.stopTest();
        }

        System.assertNotEquals(null, userList, 'userList is not null');
    }

    @isTest
    static void testGetObjectiveRecord() {
        Objective__c testObj = getObjective();

        Test.startTest();
            Objective__c objectiveObj = ObjectivesController.getObjectiveRecord(testObj.Id);
        Test.stopTest();

        System.assertNotEquals(null, objectiveObj, '1 objective record should be returned');
    }
   
    @isTest
    static void testGetFilterDetailsAccount() {
        Objective__c testObj = getObjective();
        testObj.FiltersLong__c = '{"Sales Route #":"1234","Parent Chain":"FOOD LION"}';
        testObj.FiltersInclude__c = '{"Sales Route #":true,"Parent Chain":true}';
        update testObj;

        Test.startTest();
            List<ObjectivesController.FilterDetails> accountFilterObject = ObjectivesController.getAccountFilterDetails(testObj.Id);
        Test.stopTest();

        Assert.areNotEqual(null, accountFilterObject, 'Account filter picklist field options should be returned.');
    }
    
    @isTest
    static void testUpdateAccounts() {
        Objective__c testObjective = getObjective();
        testObjective.FiltersInclude__c = '{"Retailer Status":true}';
        testObjective.FiltersLong__c = '{"Retailer Status":"Active"}';
        update testObjective;        

        Test.startTest();
        	List<ObjectivesController.FilterDetails> accountFilterObject = ObjectivesController.getAccountFilterDetails(testObjective.Id);
            ObjectivesController.ObjectiveErrorResponse errorObj = ObjectivesController.updateAccounts(testObjective.Id, System.JSON.serialize(accountFilterObject));
        Test.stopTest();
        
		//Assert there was not an error
        Assert.areEqual(null, errorObj.errorMsg, 'There should not be an error.');
    }

    @isTest
    static void testUpdateAccountsNoFilters() {
        Objective__c testObjective = getObjective();
        testObjective.FiltersInclude__c = '{}';
        testObjective.FiltersLong__c = '{}';
        update testObjective;     

        Test.startTest();
        	List<ObjectivesController.FilterDetails> accountFilterObject = ObjectivesController.getAccountFilterDetails(testObjective.Id);
            ObjectivesController.ObjectiveErrorResponse errorObj = ObjectivesController.updateAccounts(testObjective.Id, System.JSON.serialize(accountFilterObject));
        Test.stopTest();
        
		//Assert there was an error
        Assert.areEqual('No filters have been applied.', errorObj.errorMsg, 'There should be an error that there are no filters applied.');
    }
    
    @isTest
    static void testUpdateAccountsMultipleUpdates() {
        Objective__c testObjective = getObjective();
        testObjective.FiltersInclude__c = '{"Retailer Status":true}';
        testObjective.FiltersLong__c = '{"Retailer Status":"Active"}';
        update testObjective;     

        Test.startTest();
        	List<ObjectivesController.FilterDetails> accountFilterObject = ObjectivesController.getAccountFilterDetails(testObjective.Id);
            ObjectivesController.updateAccounts(testObjective.Id, System.JSON.serialize(accountFilterObject));   //First Run
        	ObjectivesController.ObjectiveErrorResponse errorObj = ObjectivesController.updateAccounts(testObjective.Id, System.JSON.serialize(accountFilterObject));  //Second Run
        Test.stopTest();
        
		//Assert there was an error
        Assert.areEqual('This objective is already being updated in the background, please try again.', errorObj.errorMsg, 'There should be an error that objective is already being updated.');
    }
    
    @isTest
    static void testUpdateAccountsBadId() {
        Objective__c testObjective = getObjective();
        testObjective.FiltersInclude__c = '{"Retailer Status":true}';
        testObjective.FiltersLong__c = '{"Retailer Status":"Active"}';
        update testObjective;
        
        //Get another record to pass a bad Id
        Account acc = getAccount('Test Account');

        Test.startTest();
        	List<ObjectivesController.FilterDetails> accountFilterObject = ObjectivesController.getAccountFilterDetails(testObjective.Id);
            ObjectivesController.ObjectiveErrorResponse errorObj = ObjectivesController.updateAccounts(acc.Id, System.JSON.serialize(accountFilterObject));
        Test.stopTest();
        
		//Assert there was an error
        Assert.areEqual(true, errorObj.error, 'There should be an error when passing a bad record Id.');
    }
       
    @isTest
    static void testGetFilterDetailsProduct() {
        Objective__c testObj = getObjective();
        testObj.ProductFiltersLong__c = '{"Draft/Package":"Package","Brand":"MillerCoors"}';
        testObj.ProductFiltersInclude__c = '{"Draft/Package":true,"Brand":true}';
        update testObj;

        Test.startTest();
            List<ObjectivesController.FilterDetails> productFilterObject = ObjectivesController.getProductFilterDetails(testObj.Id);
        Test.stopTest();

        //Assert product filter picklists should be returned
        Assert.areNotEqual(null, productFilterObject, 'product filter picklist field options should be returned');
    }
    
    @isTest
    static void testGetFilterDetailsProductChild() {
        Objective__c testObj = getParentObjective();
        testObj.Child_Objective_Product_Selection_Type__c = 'Exclusive';
        testObj.Account_Universe_Selection__c = 'Locked';
        testObj.FiltersInclude__c = '{"Retailer Status":true}';
        testObj.FiltersLong__c = '{"Retailer Status":"Active"}';        
        testObj.ProductFiltersLong__c = '{"Draft/Package":"Package","Brand":"MillerCoors"}';
        testObj.ProductFiltersInclude__c = '{"Draft/Package":true,"Brand":true}';
        testObj.Status__c = 'Ready for BU Assignment';
        update testObj;

        //Now get the Child Objective
        Objective__c childObj = [SELECT Id FROM Objective__c WHERE Parent_Child_Independent__c = 'Child' AND Parent_Objective__c != null LIMIT 1];        
        
        Test.startTest();
            List<ObjectivesController.FilterDetails> productFilterObject = ObjectivesController.getProductFilterDetails(childObj.Id);
        Test.stopTest();
        
        //Assert product filter picklists should be returned
        Assert.areNotEqual(null, productFilterObject, 'product filter picklist field options should be returned');
    }
    
    @isTest
    static void testUpdateProducts() {
        Objective__c testObjective = getObjective();
        testObjective.ProductFiltersInclude__c = '{"Draft/Package":true}';
        testObjective.ProductFiltersLong__c = '{"Draft/Package":"Draft"}';
        update testObjective;        

        Test.startTest();
        	List<ObjectivesController.FilterDetails> productFilterObject = ObjectivesController.getProductFilterDetails(testObjective.Id);
        	ObjectivesController.ObjectiveErrorResponse errorObj = ObjectivesController.updateProducts(testObjective.Id, System.JSON.serialize(productFilterObject), true);
        Test.stopTest();
        
		//Assert there was not an error
        Assert.areEqual(null, errorObj.errorMsg, 'There should not be an error.');
    }
    
    @isTest
    static void testUpdateProductsChildSemiExclusiveMatch() {
        Objective__c testObj = getParentObjective();
        testObj.Child_Objective_Product_Selection_Type__c = 'Semi Exclusive';
        testObj.Account_Universe_Selection__c = 'Locked';
        testObj.FiltersInclude__c = '{"Retailer Status":true}';
        testObj.FiltersLong__c = '{"Retailer Status":"Active"}';        
        testObj.ProductFiltersLong__c = '{"Draft/Package":"Package"}';
        testObj.ProductFiltersInclude__c = '{"Draft/Package":true}';
        testObj.Status__c = 'Ready for BU Assignment';
        update testObj;

        //Now get the Child Objective and update
        Objective__c childObj = [SELECT Id FROM Objective__c WHERE Parent_Child_Independent__c = 'Child' AND Parent_Objective__c != null LIMIT 1];                
        //Keep the filters the same to match parent
        childObj.ProductFiltersLong__c = '{"Draft/Package":"Package"}';
        childObj.ProductFiltersInclude__c = '{"Draft/Package":true}';
        update childObj;

        Test.startTest();        
        	List<ObjectivesController.FilterDetails> productFilterObject = ObjectivesController.getProductFilterDetails(childObj.Id);
        	ObjectivesController.ObjectiveErrorResponse errorObj = ObjectivesController.updateProducts(childObj.Id, System.JSON.serialize(productFilterObject), true);
        Test.stopTest();
        
		//Assert there was not an error
        Assert.areEqual(null, errorObj.errorMsg, 'There should not be an error.');
    }

    @isTest
    static void testUpdateProductsChildSemiExclusiveNoMatch() {
        Objective__c testObj = getParentObjective();
        testObj.Child_Objective_Product_Selection_Type__c = 'Semi Exclusive';
        testObj.Account_Universe_Selection__c = 'Locked';
        testObj.FiltersInclude__c = '{"Retailer Status":true}';
        testObj.FiltersLong__c = '{"Retailer Status":"Active"}';        
        testObj.ProductFiltersLong__c = '{"Draft/Package":"Package","Brand":"MillerCoors"}';
        testObj.ProductFiltersInclude__c = '{"Draft/Package":true,"Brand":true}';
        testObj.Status__c = 'Ready for BU Assignment';
        update testObj;

        //Now get the Child Objective and update
        Objective__c childObj = [SELECT Id FROM Objective__c WHERE Parent_Child_Independent__c = 'Child' AND Parent_Objective__c != null LIMIT 1]; 
        //Change the filters to not match parent
        childObj.ProductFiltersInclude__c = '{"Draft/Package":true}';
        childObj.ProductFiltersLong__c = '{"Draft/Package":"Draft"}';
        update childObj;        

        Test.startTest();
        	List<ObjectivesController.FilterDetails> productFilterObject = ObjectivesController.getProductFilterDetails(childObj.Id);
        	ObjectivesController.ObjectiveErrorResponse errorObj = ObjectivesController.updateProducts(childObj.Id, System.JSON.serialize(productFilterObject), true);
        Test.stopTest();
        
		//Assert there was an error
        Assert.areEqual('At least one cascaded product must be selected', errorObj.errorMsg, 'There should be an error that filters do not match.');
    }
    
    @isTest
    static void testUpdateProductsNoFilters() {
        Objective__c testObjective = getObjective();
        testObjective.ProductFiltersInclude__c = '{}';
        testObjective.ProductFiltersLong__c = '{}';
        update testObjective;     

        Test.startTest();
        	List<ObjectivesController.FilterDetails> productFilterObject = ObjectivesController.getProductFilterDetails(testObjective.Id);
            ObjectivesController.ObjectiveErrorResponse errorObj = ObjectivesController.updateProducts(testObjective.Id, System.JSON.serialize(productFilterObject), true);
        Test.stopTest();
        
		//Assert there was an error
        Assert.areEqual('No filters have been applied.', errorObj.errorMsg, 'There should be an error that there are no filters applied.');
    }
    
    @isTest
    static void testUpdateProductsMultipleUpdates() {
        Objective__c testObjective = getObjective();
        testObjective.ProductFiltersInclude__c = '{"Draft/Package":true}';
        testObjective.ProductFiltersLong__c = '{"Draft/Package":"Draft"}';
        update testObjective;     

        Test.startTest();
            List<ObjectivesController.FilterDetails> productFilterObject = ObjectivesController.getProductFilterDetails(testObjective.Id);
        	ObjectivesController.updateProducts(testObjective.Id, System.JSON.serialize(productFilterObject), true);	//First Run
        	ObjectivesController.ObjectiveErrorResponse errorObj = ObjectivesController.updateProducts(testObjective.Id, System.JSON.serialize(productFilterObject), true);  //Second Run
        Test.stopTest();
        
		//Assert there was an error
        Assert.areEqual('This objective is already being updated in the background, please try again.', errorObj.errorMsg, 'There should be an error that objective is already being updated.');
    }    
    
    @isTest
    static void testUpdateProductsBadId() {
        Objective__c testObjective = getObjective();
        testObjective.ProductFiltersInclude__c = '{"Draft/Package":true}';
        testObjective.ProductFiltersLong__c = '{"Draft/Package":"Draft"}';
        update testObjective;
        
        //Get another record to pass a bad Id
        Account acc = getAccount('Test Account');

        Test.startTest();
            List<ObjectivesController.FilterDetails> productFilterObject = ObjectivesController.getProductFilterDetails(testObjective.Id);
            ObjectivesController.ObjectiveErrorResponse errorObj = ObjectivesController.updateProducts(acc.Id, System.JSON.serialize(productFilterObject), true);
        Test.stopTest();
        
		//Assert there was an error
        Assert.areEqual(true, errorObj.error, 'There should be an error when passing a bad record Id.');
    }
        
    @isTest
    static void testGetFieldValuesFromParent() {
        Objective__c testObj = getParentObjective();
        List<Product2> parentProducts = ObjectivesController.getParentProducts(testObj.Id);
        
        Test.startTest();
        	List<ObjectivesController.SelectDetails> selectDetailsObject = ObjectivesController.getFieldValuesFromParent('DRAFT_OR_PACKAGE__c', parentProducts);
        Test.stopTest();

        //Asert values are returned
        Assert.areNotEqual(null, selectDetailsObject, 'select details options should be returned');
    }
    
    @isTest
    static void testBuildBuWarehouseQueryString(){
        List<BU_Division__mdt> buDivisions = [SELECT Id, MasterLabel, Division__c FROM BU_Division__mdt];
        Map<String, List<String>> buDivisionMap = new Map<String, List<String>>();
        for(BU_Division__mdt buDivisionObj : buDivisions){
            List<String> divisionList = new List<String>();
            if(buDivisionMap.containsKey(buDivisionObj.Division__c)){
                divisionList = buDivisionMap.get(buDivisionObj.Division__c);
            }
            divisionList.add(buDivisionObj.MasterLabel);
            buDivisionMap.put(buDivisionObj.Division__c, divisionList);
        }

        Test.startTest();
            String buWarehouseQueryString = ObjectivesController.buildBuWarehouseQueryString(new List<String>{'PVA'}, new List<String>{'PDVA-CHANTILLY'}, new List<String>{'PVA'}, buDivisionMap);
        Test.stopTest();

        //Assert correct query string is returned
        Assert.areEqual('VIP_Instance__c IN :buSelected AND (Warehouse__c IN :warehouseSelected AND SalesOrg__c IN :salesorgSelected)', buWarehouseQueryString, 'Strings should match');
    }

    @isTest
    static void testBuildBuWarehouseQueryStringJustBU(){
        List<BU_Division__mdt> buDivisions = [SELECT Id, MasterLabel, Division__c FROM BU_Division__mdt];
        Map<String, List<String>> buDivisionMap = new Map<String, List<String>>();
        for(BU_Division__mdt buDivisionObj : buDivisions){
            List<String> divisionList = new List<String>();
            if(buDivisionMap.containsKey(buDivisionObj.Division__c)){
                divisionList = buDivisionMap.get(buDivisionObj.Division__c);
            }
            divisionList.add(buDivisionObj.MasterLabel);
            buDivisionMap.put(buDivisionObj.Division__c, divisionList);
        }

        Test.startTest();
            String buWarehouseQueryString = ObjectivesController.buildBuWarehouseQueryString(new List<String>{'PVA'}, new List<String>(), new List<String>(), buDivisionMap);
        Test.stopTest();

        //Assert correct query string is returned
        Assert.areEqual('VIP_Instance__c IN :buSelected AND SalesOrg__c IN :salesorgSelected', buWarehouseQueryString, 'Strings should match');
    }

    @isTest
    static void testBuildBuWarehouseQueryStringJustSalesOrg(){
        List<BU_Division__mdt> buDivisions = [SELECT Id, MasterLabel, Division__c FROM BU_Division__mdt];
        Map<String, List<String>> buDivisionMap = new Map<String, List<String>>();
        for(BU_Division__mdt buDivisionObj : buDivisions){
            List<String> divisionList = new List<String>();
            if(buDivisionMap.containsKey(buDivisionObj.Division__c)){
                divisionList = buDivisionMap.get(buDivisionObj.Division__c);
            }
            divisionList.add(buDivisionObj.MasterLabel);
            buDivisionMap.put(buDivisionObj.Division__c, divisionList);
        }

        Test.startTest();
            String buWarehouseQueryString = ObjectivesController.buildBuWarehouseQueryString(new List<String>{'PVA'}, new List<String>(), new List<String>{'PVR'}, buDivisionMap);
        Test.stopTest();

        //Assert correct query string is returned
        Assert.areEqual('VIP_Instance__c IN :buSelected AND SalesOrg__c IN :salesorgSelected', buWarehouseQueryString, 'Strings should match');
    }
   
    @isTest
    static void testBuildWhereClauseStringMultiANDInclude(){
        String accountFilters = '[{"filterAPIName":"Chain__c","filterLabel":"Chain","filterQueryCondition":"AND","filterType":"Multi Select","include":true,"filterValue":"","filterValues":["FOOD LION"]}]';

        List<ObjectivesController.FilterDetails> filterDetailsList = (List<ObjectivesController.FilterDetails>)JSON.deserialize(accountFilters, List<ObjectivesController.FilterDetails>.class);

        Test.startTest();
            String whereClauseString = ObjectivesController.buildWhereClauseString(filterDetailsList);
        Test.stopTest();

        //Assert correct query string is returned
        Assert.areEqual(' AND Chain__c IN (\'FOOD LION\'))', whereClauseString, 'Strings should match');
    }

    @isTest
    static void testBuildWhereClauseStringSingleANDInclude(){
        String accountFilters = '[{"filterAPIName":"Sales_Manager_Route__c","filterLabel":"Sales Manager #","filterQueryCondition":"AND","filterType":"Text","include":true,"filterValue":"123", "filterValues":[]}]]';

        List<ObjectivesController.FilterDetails> filterDetailsList = (List<ObjectivesController.FilterDetails>)JSON.deserialize(accountFilters, List<ObjectivesController.FilterDetails>.class);

        Test.startTest();
            String whereClauseString = ObjectivesController.buildWhereClauseString(filterDetailsList);
        Test.stopTest();

        //Assert correct query string is returned
        Assert.areEqual(' AND Sales_Manager_Route__c IN (\'123\'))', whereClauseString, 'Strings should match');
    }

    @isTest
    static void testBuildWhereClauseStringMultiORInclude(){
        String accountFilters = '[{"filterAPIName":"Chain__c","filterLabel":"Chain","filterQueryCondition":"OR","filterType":"Multi Select","include":true,"filterValue":"","filterValues":["FOOD LION"]}]]';

        List<ObjectivesController.FilterDetails> filterDetailsList = (List<ObjectivesController.FilterDetails>)JSON.deserialize(accountFilters, List<ObjectivesController.FilterDetails>.class);

        Test.startTest();
            String whereClauseString = ObjectivesController.buildWhereClauseString(filterDetailsList);
        Test.stopTest();

        //Assert correct query string is returned
        Assert.areEqual(') OR Chain__c IN (\'FOOD LION\')', whereClauseString, 'Strings should match');
    }

    @isTest
    static void testBuildWhereClauseStringSingleORInclude(){
        String accountFilters = '[{"filterAPIName":"Sales_Manager_Route__c","filterLabel":"Sales Manager #","filterQueryCondition":"OR","filterType":"Text","include":true,"filterValue":"123", "filterValues":[]}]';

        List<ObjectivesController.FilterDetails> filterDetailsList = (List<ObjectivesController.FilterDetails>)JSON.deserialize(accountFilters, List<ObjectivesController.FilterDetails>.class);

        Test.startTest();
            String whereClauseString = ObjectivesController.buildWhereClauseString(filterDetailsList);
        Test.stopTest();

        //Assert correct query string is returned
        Assert.areEqual(') OR Sales_Manager_Route__c IN (\'123\')', whereClauseString, 'Strings should match');
    }

    @isTest
    static void testBuildWhereClauseStringMultiANDExclude(){
        String accountFilters = '[{"filterAPIName":"Chain__c","filterLabel":"Chain","filterQueryCondition":"AND","filterType":"Multi Select","include":false,"filterValue":"","filterValues":["FOOD LION"]}]';

        List<ObjectivesController.FilterDetails> filterDetailsList = (List<ObjectivesController.FilterDetails>)JSON.deserialize(accountFilters, List<ObjectivesController.FilterDetails>.class);

        Test.startTest();
            String whereClauseString = ObjectivesController.buildWhereClauseString(filterDetailsList);
        Test.stopTest();

        //Assert correct query string is returned
        Assert.areEqual(' AND Chain__c NOT IN (\'FOOD LION\'))', whereClauseString, 'Strings should match');
    }

    @isTest
    static void testBuildWhereClauseStringSingleANDExclude(){
        String accountFilters = '[{"filterAPIName":"Sales_Manager_Route__c","filterLabel":"Sales Manager #","filterQueryCondition":"AND","filterType":"Text","include":false,"filterValue":"123", "filterValues":[]}]]';

        List<ObjectivesController.FilterDetails> filterDetailsList = (List<ObjectivesController.FilterDetails>)JSON.deserialize(accountFilters, List<ObjectivesController.FilterDetails>.class);

        Test.startTest();
            String whereClauseString = ObjectivesController.buildWhereClauseString(filterDetailsList);
        Test.stopTest();

        //Assert correct query string is returned
        Assert.areEqual(' AND Sales_Manager_Route__c NOT IN (\'123\'))', whereClauseString, 'Strings should match');
    }

    @isTest
    static void testBuildWhereClauseStringMultiORExclude(){
        String accountFilters = '[{"filterAPIName":"Chain__c","filterLabel":"Chain","filterQueryCondition":"OR","filterType":"Multi Select","include":false,"filterValue":"","filterValues":["FOOD LION"]}]]';

        List<ObjectivesController.FilterDetails> filterDetailsList = (List<ObjectivesController.FilterDetails>)JSON.deserialize(accountFilters, List<ObjectivesController.FilterDetails>.class);

        Test.startTest();
            String whereClauseString = ObjectivesController.buildWhereClauseString(filterDetailsList);
        Test.stopTest();

        //Assert correct query string is returned
        Assert.areEqual(') OR Chain__c NOT IN (\'FOOD LION\')', whereClauseString, 'Strings should match');
    }

    @isTest
    static void testBuildWhereClauseStringSingleORExclude(){
        String accountFilters = '[{"filterAPIName":"Sales_Manager_Route__c","filterLabel":"Sales Manager #","filterQueryCondition":"OR","filterType":"Text","include":false,"filterValue":"123", "filterValues":[]}]';

        List<ObjectivesController.FilterDetails> filterDetailsList = (List<ObjectivesController.FilterDetails>)JSON.deserialize(accountFilters, List<ObjectivesController.FilterDetails>.class);

        Test.startTest();
            String whereClauseString = ObjectivesController.buildWhereClauseString(filterDetailsList);
        Test.stopTest();

        //Assert correct query string is returned
        Assert.areEqual(') OR Sales_Manager_Route__c NOT IN ', whereClauseString, 'Strings should match');
    }

    @isTest
    static void testQueryStringBuilderCount(){
        List<BU_Division__mdt> buDivisions = [SELECT Id, MasterLabel, Division__c FROM BU_Division__mdt];
        Map<String, List<String>> buDivisionMap = new Map<String, List<String>>();
        for(BU_Division__mdt buDivisionObj : buDivisions){
            List<String> divisionList = new List<String>();
            if(buDivisionMap.containsKey(buDivisionObj.Division__c)){
                divisionList = buDivisionMap.get(buDivisionObj.Division__c);
            }
            divisionList.add(buDivisionObj.MasterLabel);
            buDivisionMap.put(buDivisionObj.Division__c, divisionList);
        }

        String query = 'SELECT count() FROM Account WHERE (';
        String accountFilters = '[{"filterAPIName":"Chain__c","filterLabel":"Chain","filterQueryCondition":"AND","filterType":"Multi Select","filterValue":"","filterValues":["FOOD LION"]}]';

        List<ObjectivesController.FilterDetails> filterDetailsList = (List<ObjectivesController.FilterDetails>)JSON.deserialize(accountFilters, List<ObjectivesController.FilterDetails>.class);

        Test.startTest();
            Integer accountCount = ObjectivesController.queryStringBuilderCount(query, new List<String>{'PVA'}, new List<String>{'PDVA-CHANTILLY'}, new List<String>{'PVA'}, buDivisionMap,
                                                                                filterDetailsList);
        Test.stopTest();

        //Assert accounts are returned
        Assert.areEqual(2, accountCount, '2 accounts should be returned');
    }
    
    @isTest
    static void testConvertListStringToLiteral(){
        Test.startTest();
            String listToString = ObjectivesController.convertListStringToLiteral(new List<String>{'123'});
        Test.stopTest();

        //Assert correct query string is returned
        Assert.areEqual('(\'123\')', listToString, 'String should match');
    }

    @isTest
    static void testCreateObjectives() {
        Product2 testProduct = getProduct();
        Objective__c testObjective = new Objective__c();
        testObjective.Name = 'Test Objective';
        testObjective.BU__c = 'PVA';
        testObjective.Objective_Type__c = 'Display';
        testObjective.Start_Date__c = System.Today();
        testObjective.End_Date__c = System.Today() + 1;
        testObjective.Parent_Child_Independent__c = 'Local';

        Territory_Matching__c terrMatchingCustomSetting = new Territory_Matching__c();
        terrMatchingCustomSetting.Territory_Matching__c = true;
        insert terrMatchingCustomSetting;

        Objective_Location__c testObjLoc = new Objective_Location__c();
        testObjLoc.BU__c = 'PVA';
        testObjLoc.Warehouse__c = 'PDVA-CHANTILLY';
        testObjLoc.Goal_Amount__c = 100;

        String filter = '[{"filterAPIName":"Chain__c","filterLabel":"Chain","filterQueryCondition":"OR","filterType":"Multi Select","include":true,"filterValue":"","filterValues":["FOOD LION"]}]]';
        Test.startTest();
            ObjectivesController.createObjectives(new List<String>{testProduct.Id}, testObjective, false, filter, false, new List<String>{'PVA'}, new List<String>{'PDVA-CHANTILLY'},
                                                new List<String>{'PVA'}, new List<Objective_Location__c>{testObjLoc}, new List<Objective_Location__c>(), new List<String>(), false);
        Test.stopTest();

        List<Objective_Account__c> objectiveAccountList = [SELECT Id FROM Objective_Account__c WHERE Objective__c = :testObjective.Id];
        List<Objective_Product__c> objectiveProductList = [SELECT Id FROM Objective_Product__c WHERE Objective__c = :testObjective.Id];
        List<Objective_Location__c> objectiveLocationList = [SELECT Id FROM Objective_Location__c WHERE Objective__c = :testObjective.Id];

        System.assertEquals(2, objectiveAccountList.size(), '2 Objective Accounts should have been created');
        System.assertEquals(1, objectiveProductList.size(), '1 Objective Product should have been created');
        System.assertEquals(1, objectiveLocationList.size(), '1 Objective Location should have been created');
    }
            
    @isTest
    static void testCreateObjectivesAccountFiltersChainNoTerritory(){
        Territory_Matching__c terrMatchingCustomSetting = new Territory_Matching__c();
        terrMatchingCustomSetting.Territory_Matching__c = false;
        insert terrMatchingCustomSetting;

        Account testAccount = getAccount('Test Parent Account');
        Account testAccount2 = getAccount('Test Account');
        testAccount2.Chain__c = 'WALMART SUPR';
        update testAccount2;
        Product2 testProduct = getProduct();
        Objective__c testObjective = new Objective__c();
        testObjective.Name = 'Test Objective';
        testObjective.BU__c = 'PVA';
        testObjective.Objective_Type__c = 'Display';
        testObjective.Start_Date__c = System.Today();
        testObjective.End_Date__c = System.Today() + 1;
        testObjective.Parent_Child_Independent__c = 'Local';

        Objective_Location__c testObjLoc = new Objective_Location__c();
        testObjLoc.BU__c = 'PVA';
        testObjLoc.Warehouse__c = 'PDVA-CHANTILLY';
        testObjLoc.Goal_Amount__c = 100;

        String filter = '[{"filterAPIName":"Chain__c","filterLabel":"Chain","filterQueryCondition":"OR","filterType":"Multi Select","include":true,"filterValue":"","filterValues":["FOOD LION"]}]]';

        Test.startTest();
            ObjectivesController.createObjectives(new List<String>{testProduct.Id}, testObjective, false, filter, false, new List<String>{'PVA'}, new List<String>{'PDVA-CHANTILLY'},
                                                new List<String>{'PVA'}, new List<Objective_Location__c>{testObjLoc}, new List<Objective_Location__c>(), new List<String>(), false);
        Test.stopTest();

        List<Objective_Account__c> objectiveAccountList = [SELECT Id FROM Objective_Account__c WHERE Objective__c = :testObjective.Id];
        List<Objective_Product__c> objectiveProductList = [SELECT Id FROM Objective_Product__c WHERE Objective__c = :testObjective.Id];
        List<Objective_Location__c> objectiveLocationList = [SELECT Id FROM Objective_Location__c WHERE Objective__c = :testObjective.Id];

        System.assertEquals(2, objectiveAccountList.size(), '2 Objective Accounts should have been created');
        System.assertEquals(1, objectiveProductList.size(), '1 Objective Product should have been created');
        System.assertEquals(1, objectiveLocationList.size(), '1 Objective Location should have been created');
    }

    @isTest
    static void testCreateObjectivesAccountFiltersChainTerritoryMatching(){
        Territory_Matching__c terrMatchingCustomSetting = new Territory_Matching__c();
        terrMatchingCustomSetting.Territory_Matching__c = true;
        insert terrMatchingCustomSetting;

        Account testAccount = getAccount('Test Parent Account');
        Account testAccount2 = getAccount('Test Account');
        testAccount2.Chain__c = 'WALMART SUPR';
        update testAccount2;
        Product2 testProduct = getProduct();
        Objective__c testObjective = new Objective__c();
        testObjective.Name = 'Test Objective';
        testObjective.BU__c = 'PVA';
        testObjective.Objective_Type__c = 'Display';
        testObjective.Start_Date__c = System.Today();
        testObjective.End_Date__c = System.Today() + 1;
		testObjective.Parent_Child_Independent__c = 'Local';

        Objective_Location__c testObjLoc = new Objective_Location__c();
        testObjLoc.BU__c = 'PVA';
        testObjLoc.Warehouse__c = 'PDVA-CHANTILLY';
        testObjLoc.Goal_Amount__c = 100;

        String filter = '[{"filterAPIName":"Chain__c","filterLabel":"Chain","filterQueryCondition":"OR","filterType":"Multi Select","include":true,"filterValue":"","filterValues":["FOOD LION"]}]]';

        Test.startTest();
            ObjectivesController.createObjectives(new List<String>{testProduct.Id}, testObjective, false, filter, false, new List<String>{'PVA'}, new List<String>{'PDVA-CHANTILLY'},
                                                    new List<String>{'PVA'}, new List<Objective_Location__c>{testObjLoc}, new List<Objective_Location__c>(), new List<String>(), false);
        Test.stopTest();

        List<Objective_Account__c> objectiveAccountList = [SELECT Id FROM Objective_Account__c WHERE Objective__c = :testObjective.Id];
        List<Objective_Product__c> objectiveProductList = [SELECT Id FROM Objective_Product__c WHERE Objective__c = :testObjective.Id];
        List<Objective_Location__c> objectiveLocationList = [SELECT Id FROM Objective_Location__c WHERE Objective__c = :testObjective.Id];

        System.assertEquals(2, objectiveAccountList.size(), '2 Objective Accounts should have been created');
        System.assertEquals(1, objectiveProductList.size(), '1 Objective Product should have been created');
        System.assertEquals(1, objectiveLocationList.size(), '1 Objective Location should have been created');
    }
    
    @isTest
    static void testCreateObjectivesAccountFiltersChainTerritoryMatchingNoSalesOrg(){
        Territory_Matching__c terrMatchingCustomSetting = new Territory_Matching__c();
        terrMatchingCustomSetting.Territory_Matching__c = true;
        insert terrMatchingCustomSetting;

        Account testAccount = getAccount('Test Parent Account');
        Account testAccount2 = getAccount('Test Account');
        testAccount2.Chain__c = 'FOOD LION';
        update testAccount2;
        Product2 testProduct = getProduct();
        Objective__c testObjective = new Objective__c();
        testObjective.Name = 'Test Objective';
        testObjective.BU__c = 'PVA';
        testObjective.Objective_Type__c = 'Display';
        testObjective.Start_Date__c = System.Today();
        testObjective.End_Date__c = System.Today() + 1;
        testObjective.Parent_Child_Independent__c = 'Local';

        Objective_Location__c testObjLoc = new Objective_Location__c();
        testObjLoc.BU__c = 'PVA';
        testObjLoc.Warehouse__c = 'PDVA-CHANTILLY';
        testObjLoc.Goal_Amount__c = 100;

        String filter = '[{"filterAPIName":"Chain__c","filterLabel":"Chain","filterQueryCondition":"OR","filterType":"Multi Select","include":true,"filterValue":"","filterValues":["FOOD LION"]}]]';

        Test.startTest();
            ObjectivesController.createObjectives(new List<String>{testProduct.Id}, testObjective, false, filter, false, new List<String>{'PVA'}, new List<String>{'PDVA-CHANTILLY'},
                                                  new List<String>{'--None--'}, new List<Objective_Location__c>{testObjLoc}, new List<Objective_Location__c>(), new List<String>(), false);
        Test.stopTest();

        List<Objective_Account__c> objectiveAccountList = [SELECT Id FROM Objective_Account__c WHERE Objective__c = :testObjective.Id];
        List<Objective_Product__c> objectiveProductList = [SELECT Id FROM Objective_Product__c WHERE Objective__c = :testObjective.Id];
        List<Objective_Location__c> objectiveLocationList = [SELECT Id FROM Objective_Location__c WHERE Objective__c = :testObjective.Id];

        System.assertEquals(2, objectiveAccountList.size(), '2 Objective Accounts should have been created');
        System.assertEquals(1, objectiveProductList.size(), '2 Objective Product should have been created');
        System.assertEquals(1, objectiveLocationList.size(), '1 Objective Location should have been created');
    }

    @isTest
    static void testCreateObjectivesUpdate() {        
        Account testAccount = getAccount('Test Account');

        Product2 testProduct = getProduct();
        Objective__c testObjective = getObjective();
        testObjective.Name = 'Test Objective';
        testObjective.Goal_Type__c = 'Individual Goal';
        testObjective.BU__c = 'PVA';
        testObjective.Objective_Type__c = 'Display';
        testObjective.Start_Date__c = System.Today();
        testObjective.End_Date__c = System.Today() + 1;
        testObjective.Parent_Child_Independent__c = 'Local';

        Territory_Matching__c terrMatchingCustomSetting = new Territory_Matching__c();
        terrMatchingCustomSetting.Territory_Matching__c = true;
        insert terrMatchingCustomSetting;

        Objective_Location__c testObjLoc = getObjectiveLocation();
        Objective_Location__c testObjLoc2 = new Objective_Location__c();
        testObjLoc2.BU__c = 'PVA';
        testObjLoc2.SalesOrg__c = 'PVR';
        testObjLoc2.Warehouse__c = 'PDVA-CHANTILLY';
        testObjLoc2.Goal_Amount__c = 100;

        String filter = '[{"filterAPIName":"Chain__c","filterLabel":"Chain","filterQueryCondition":"OR","filterType":"Multi Select","include":true,"filterValue":"","filterValues":["FOOD LION"]}]]';

        Test.startTest();
            ObjectivesController.createObjectives(new List<String>{testProduct.Id}, testObjective, true, filter, false, new List<String>{'PVA'}, new List<String>{'PDVA-CHANTILLY'},
                                                new List<String>{'PVA'}, new List<Objective_Location__c>{testObjLoc2}, new List<Objective_Location__c>{testObjLoc}, new List<String>(), false);
        Test.stopTest();

        List<Objective_Account__c> objectiveAccountList = [SELECT Id FROM Objective_Account__c WHERE Objective__c = :testObjective.Id];
        List<Objective_Product__c> objectiveProductList = [SELECT Id FROM Objective_Product__c WHERE Objective__c = :testObjective.Id];
        List<Objective_Location__c> objectiveLocationList = [SELECT Id FROM Objective_Location__c WHERE Objective__c = :testObjective.Id];

        System.assertEquals(2, objectiveAccountList.size(), '2 Objective Accounts should have been created');
        System.assertEquals(1, objectiveProductList.size(), '1 Objective Product should have been created');
        System.assertEquals(3, objectiveLocationList.size(), '3 Objective Locations should have been created');
    }
           
   	@isTest
    static void testCreateObjectivesDeleteLocations(){
        Product2 testProduct = getProduct();
        Objective__c testObjective = getObjective();
        Objective_Location__c testObjLoc1 = getObjectiveLocation();
        Objective_Location__c testObjLoc2 = new Objective_Location__c();
        testObjLoc2.BU__c = 'CBS';
        testObjLoc2.Goal_Amount__c = 100;        

        String filter = '[{"filterAPIName":"Chain__c","filterLabel":"Chain","filterQueryCondition":"OR","filterType":"Multi Select","include":true,"filterValue":"","filterValues":["FOOD LION"]}]]';

        Test.startTest();
            ObjectivesController.createObjectives(new List<String>{testProduct.Id}, testObjective, true, filter, false, new List<String>{'PVA'}, new List<String>{'PDVA-CHANTILLY'},
                                                  new List<String>{'PVA'}, new List<Objective_Location__c>{testObjLoc2}, null, new List<String>{testObjLoc1.Id}, false);
        Test.stopTest();
        		
        //Verify Objective Location sent to delete was deleted
        List<Objective_Location__c> objectiveLocationList = [SELECT Id FROM Objective_Location__c WHERE Objective__c = :testObjective.Id];
        Assert.areEqual(1, objectiveLocationList.size(), 'Should be 1 Objective Location left (we deleted one created in Test Setup and created a new one)');
    }
    
    @isTest
    static void testUpdateProductsOnObjectives() {
        Objective__c testObjective = getObjective();
        testObjective.ProductFiltersInclude__c = '{"Draft/Package":true}';
        testObjective.ProductFiltersLong__c = '{"Draft/Package":"Package"}';
        update testObjective;               

        Test.startTest();
        	ObjectivesController.updateProductsOnObjective(new Set<Id>{testObjective.Id});
        Test.stopTest();
        
		//Verify Objective Products are added
		List<Objective_Product__c> objectiveProductList = [SELECT Id FROM Objective_Product__c WHERE Objective__c = :testObjective.Id];
        Assert.areEqual(1, objectiveProductList.size(), 'Should be 1 Objective Product created');   
    }    
         
    @isTest
    static void testGetProductSearchResults() {
        Objective__c testObjective = getObjective();        

        Test.startTest();        
        	List<Product2> productList = ObjectivesController.getProductSearchResults('Test', testObjective.Id);
        Test.stopTest();
        
		//Verify Search Results
        Assert.areEqual(1, productList.size(), 'Should be 1 Product returned in the search');       
    }
    
    @isTest
    static void testAddProductToObjectiveManual() {
        Objective__c testObjective = getObjective();
        Product2 testProduct = getProduct();

        Test.startTest();        
        	ObjectivesController.addProductToObjectiveManual(testObjective.Id, testProduct.Id);
        Test.stopTest();
        
        //Verify Objective Product was added
		List<Objective_Product__c> objectiveProductList = [SELECT Id FROM Objective_Product__c WHERE Objective__c = :testObjective.Id];
        Assert.areEqual(2, objectiveProductList.size(), 'Should be 2 Objective Product returned (1 here and 1 in setup');   
    }  
   
    @isTest
    static void testGetAccountSearchResults() {
        Objective__c testObjective = getObjective();        

        Test.startTest();        
        	List<Account> accountList = ObjectivesController.getAccountSearchResults('Test', testObjective.Id);
        Test.stopTest();
        
		//Verify Search Results
        Assert.areEqual(2, accountList.size(), 'Should be 2 Accounts returned in the search');   
    }
    
    @isTest
    static void testAddAccountToObjectiveManual() {
        Objective__c testObjective = getObjective();
        Account testAccount = getAccount('Test Account');

        Test.startTest();        
        	ObjectivesController.addAccountToObjectiveManual(testObjective.Id, testAccount.Id);
        Test.stopTest();
        
        //Verify Objective Account was added
		List<Objective_Account__c> objectiveAccountList = [SELECT Id FROM Objective_Account__c WHERE Objective__c = :testObjective.Id];
        Assert.areEqual(2, objectiveAccountList.size(), 'Should be 2 Objective Accounts returned (1 here and 1 in setup)');    
    }
    
    @isTest
    static void testGetObjectiveProducts() {
        Objective__c testObjective = getObjective();
        
        Test.startTest();        
        	List<Objective_Product__c> objProducts = ObjectivesController.getObjectiveProducts(testObjective.Id);
        Test.stopTest();
                
		//Assert that objective product was returned
		Assert.areEqual(1, objProducts.size(), 'Should have returned 1 Objective Product');
    }
    
    @isTest
    static void testIsUserMarketLeaderForParentCreate() {        
        Test.startTest();
        	Boolean isMarketLeader = ObjectivesController.isUserMarketLeaderForParentCreate();
        Test.stopTest();
                
		//Assert that the user is not a Market Leader
		Assert.areEqual(true, isMarketLeader, 'User is Market Leader');
    }
    
}
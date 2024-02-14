@isTest
public class BatchConvertNewCustomerRequestsTest {
    
    @TestSetup
    private static void setup(){      
        User testUser = TestFactory.createUser(UserInfo.getProfileId(), UserInfo.getUserRoleId(), 'TestUser123421TEST@gmail.com', null, null);
        //User testUser = [SELECT Id FROM User WHERE ProfileId =: UserInfo.getProfileId() LIMIT 1];
        Profile fsrProfile = [SELECT Id,Name FROM Profile WHERE Name = 'Field Sales'];
        Profile fsrProfile1 = [SELECT Id,Name FROM Profile WHERE Name = 'Call Center'];
        //
        //create open lastname user
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User testUser1 = new User();
        testUser1.ProfileId = fsrProfile.Id;
        testUser1.UserName = 'TestUser1234TEST@gmail.com';
        testUser1.Email = 'TestUser123TEST@gmail.com';
        testUser1.EmailenCodingKey = 'UTF-8';
        testUser1.LocalesIdKey = 'en_US';
        testUser1.LanguageLocaleKey = 'en_US';
        testUser1.TimeZonesIdKey = 'America/Los_Angeles';
        testUser1.Alias = 'extUser';
        testUser1.FirstName = 'Test';
        testUser1.LastName = 'Open';
        testUser1.UserRoleId = UserInfo.getUserRoleId();
        testUser1.ManagerId = null;
        insert testUser1;

        

		system.debug('fsrProfile1 :' + fsrProfile1);
        User testFSR = [SELECT Id, Email,VIP_Company__c,FederationIdentifier, profile.name FROM User WHERE ProfileId =: fsrProfile.Id and isactive=true and CompanyName='MD' LIMIT 1];
        system.debug('testFSR :' + testFSR);
        User testFSR1 = [SELECT Id,Name,Email,ProfileId,Profile.Name,FederationIdentifier FROM User WHERE ProfileId =: fsrProfile1.Id and isactive=true LIMIT 1];

        System.runAs(testUser){
        //Create the Endpoint in the Settings
        	TestFactory.createMulesoftUtilitySetting('New Customer Request Status', 'http://rh-suggested-sell-xapi.us-e2.cloudhub.io/api/new-customer-request', '/', null, null, null, '123', '123');
        
        
        
        
        	UserRole testUserRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Admin'];
           // User testFSR = TestFactory.createUser(fsrProfile.Id, testUserRole.Id, 'newtest34673454User@gmail.com', null);
            testFSR.VIP_Company__c = 'FGC';
            testFSR.FederationIdentifier = '123456';
            update testFSR;
          //  User testFSR1 = TestFactory.createUser(fsrProfile.Id, testUserRole.Id, 'newtest34673454User11@gmail.com', null);
            testFSR1.VIP_Company__c = 'FGC';
            testFSR1.FederationIdentifier = '12345678';
            update testFSR1;
		
        
        
        
         system.debug('testFSR1 :' + testFSR1);
        //Create the Prospective Customer as if it's already send to the DMO
        Lead testNCR = new Lead(OwnerId = testFSR.Id, Requested_For__c = testFSR.Id, Business_Unit__c = '', Status = 'Submitted to DMO', 
                                Company = 'Test Company', Licensee_Name__c = 'Test Account', Tax_ID_Seller_Permit__c = '11111', License_1__c = '11111', 
                                License_Expiration_Date__c = System.today().addYears(1), License_Type__c = 'Beer Wine & Liquor', License_Status__c = 'Active',
                                Street = '111 Test Street', City = 'Chicago', State = 'IL', PostalCode = '60618', FirstName = 'John', LastName = 'Doe',
                                Phone = '555-555-5555', Email = 'john@testcompany.com', Sell_Type__c = 'Presell', Premise__c = 'On Premise', 
                                Class__c = 'Bar/Tavern', Subclass__c = 'Irish Pub', Chain_Independent__c = 'Independent', Civilian_Military__c = 'Civilian', 
                                Beer_Industry_Volume__c = 'Top 50/20%', Ethnic_Patron__c = 'General Pop', Lifestyle__c = 'General Pop', 
                                Occupation_Code__c = 'College', Patron_Age_Code__c = 'General Pop', Residence__c = 'Local', Beer_Salesman_1__c = testFSR.Id,
                                Requested_Delivery_Days__c = 'Monday', Package_Type__c = 'Package Only', Draft_Status__c = 'Draft Opportunity', 
                                Displayable__c = 'Displayable', POS_Materials__c = '<50 Case Display', Company__c = 'Gold Coast Beverage', Warehouse__c = 'Doral',
                                Print_Separate_Empty_Invoice__c = true, Print_UCS_Code_Labels__c= true,PDA_Print_UPC_Barcode__c='test', Terms__c = 'Check', 
                                Barcoded_Invoice__c = 'Case UPC Sorted by UPC Code',NCRGUID__c = '98765', 
                                UPC_Print__c='test', VIP_Account_Number__c = 'FGC*123');
        insert testNCR;
        
        Lead testNCR1 = new Lead(OwnerId = testFSR1.Id, Requested_For__c = testFSR.Id, Business_Unit__c = 'PMD', Status = 'Submitted to DMO',
                                 Beer_Salesman_1__c = testUser1.Id,Street = '111 Test Street',Displayable__c = 'Displayable', City = 'Chicago', State = 'IL', PostalCode = '60618',
                                 Company = 'Test Company1', Draft_Status__c = 'Draft Opportunity',Licensee_Name__c = 'Test Account 1', Tax_ID_Seller_Permit__c = '11111', 
                                 License_1__c = '11111', FirstName = 'John2', Sell_Type__c = 'House Account', Premise__c = 'On Premise', Ethnic_Patron__c = 'General Pop',
                                 License_Expiration_Date__c = System.today().addYears(1), License_Type__c = 'Beer Wine & Liquor', License_Status__c = 'Active',
                                 Phone = '555-555-5555', Email = 'john@testcompany21.com', LastName = 'Test Query2',Company__c = 'Gold Coast Beverage', Warehouse__c = 'Doral',
                                 Class__c = 'Bar/Tavern', Subclass__c = 'Irish Pub', Chain_Independent__c = 'Independent', Civilian_Military__c = 'Civilian', Residence__c = 'Local',
                                 Beer_Industry_Volume__c = 'Top 50/20%', Lifestyle__c = 'General Pop', Occupation_Code__c = 'College', Patron_Age_Code__c = 'General Pop', 
                                 Requested_Delivery_Days__c = 'Monday', Package_Type__c = 'Package Only', POS_Materials__c = '<50 Case Display', Terms__c = 'Check',
                                 Print_Separate_Empty_Invoice__c = true, Print_UCS_Code_Labels__c= true, NCRGUID__c = '98765',Barcoded_Invoice__c = 'Case UPC Sorted by UPC Code', VIP_Account_Number__c = 'FGC*123');
        insert testNCR1;
        
        Lead testNCR2 = new Lead(OwnerId = testFSR1.Id,  Business_Unit__c = 'CBS', Status = 'Submitted to DMO',
                                 Beer_Salesman_1__c = testFSR.Id,Street = '111 Test Street',Displayable__c = 'Displayable', City = 'Chicago', State = 'IL', PostalCode = '60618',
                                 Company = 'Test Company12', Draft_Status__c = 'Draft Opportunity',Licensee_Name__c = 'Test Account 1', Tax_ID_Seller_Permit__c = '11111', 
                                 License_1__c = '11112', FirstName = 'John', Sell_Type__c = 'House Account', Premise__c = 'On Premise', Ethnic_Patron__c = 'General Pop',
                                 License_Expiration_Date__c = System.today().addYears(1), License_Type__c = 'Beer Wine & Liquor', License_Status__c = 'Active',
                                 Phone = '555-555-5556', Email = 'john22@testcompany1.com', LastName = 'Test Query',Company__c = 'Gold Coast Beverage1', Warehouse__c = 'Doral',
                                 Class__c = 'Bar/Tavern', Subclass__c = 'Irish Pub', Chain_Independent__c = 'Independent', Civilian_Military__c = 'Civilian', Residence__c = 'Local',
                                 Beer_Industry_Volume__c = 'Top 50/20%', Lifestyle__c = 'General Pop', Occupation_Code__c = 'College', Patron_Age_Code__c = 'General Pop', 
                                 Requested_Delivery_Days__c = 'Monday', Package_Type__c = 'Package Only', POS_Materials__c = '<50 Case Display', Terms__c = 'Check',
                                 Print_Separate_Empty_Invoice__c = true, Print_UCS_Code_Labels__c= true, NCRGUID__c = '98766', VIP_Account_Number__c = 'FGC*123');
       // insert testNCR2;
        Database.DMLOptions dml2 = new Database.DMLOptions();
        dml2.DuplicateRuleHeader.AllowSave = true;
        Database.insert(testNCR2, dml2);
        
        //Create the matching Account
        Id retailRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retail Store').getRecordTypeId();
        Account testAccount = TestFactory.createAccount('Test Company', '1234', 'FGC', null, null, '1234');
        testAccount.NCRGuid__c = testNCR.NCRGuid__c;
        testAccount.ExternalId__c = testNCR.VIP_Account_Number__c;
        testAccount.RecordTypeId = retailRecordTypeId;
        update testAccount;
        
        //Create the matching Contact
        Contact testContact = new Contact(AccountId = testAccount.Id, FirstName = 'John', LastName = 'Doe', Email = 'john@testcompany.com');
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true;
        Database.insert(testContact, dml);
       }        
    }
    
    @isTest
    static void testRejectNewCustomerRequest() {
                   
        Test.startTest();
        //Set up the mock response
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setBody('[{"ncrGuid":98765,"accountNumber":"","employeeNumber":"123456","status":"Rejected","dmoComment":"This is a duplicate."}]');
        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));
       
        Lead leadrecord = [SELECT Id, Requested_For__c, Business_Unit__c, Status, Beer_Salesman_1__c,
                          Street, Displayable__c, City, State, PostalCode, Company, Draft_Status__c, Licensee_Name__c, 
                          Tax_ID_Seller_Permit__c, License_1__c, FirstName, Sell_Type__c, Premise__c,Ethnic_Patron__c,
                          License_Expiration_Date__c, License_Type__c, License_Status__c,Phone, Email, LastName,Company__c,
                          Warehouse__c, Class__c, Subclass__c, Chain_Independent__c,Civilian_Military__c,Residence__c,
                          Beer_Industry_Volume__c, Lifestyle__c, Occupation_Code__c, Patron_Age_Code__c, 
                          Requested_Delivery_Days__c, Package_Type__c, POS_Materials__c, Terms__c,
                          Print_Separate_Empty_Invoice__c, NCRGUID__c, VIP_Account_Number__c,
                          OwnerId, Owner.Name, Owner.ProfileId, Owner.Profile.Name
                          FROM Lead WHERE LastName = 'Test Query2' LIMIT 1];
      
        
						 
        BatchConvertNewCustomerRequests batchConvertNCRs = new BatchConvertNewCustomerRequests();
        batchConvertNCRs.query = 'SELECT Id, Company, State, VIP_Account_Number__c, NCRGUID__c, FirstName, LastName, Requested_For__r.Email,' + 
            ' Requested_For__r.FederationIdentifier,OwnerId,Owner.Name,Owner.ProfileId, Owner.Email, DMO_Comment__c, Owner.Profile.Name, Requested_For__c ' +
            ' FROM Lead' +
            ' WHERE NCRGUID__c != null AND Status = \'Submitted to DMO\'';
        Database.executebatch(batchConvertNCRs);
        Test.stopTest();
        
        //Assertion
        Account acc = [SELECT Id, NCRGUID__c FROM Account LIMIT 1];
        System.assertEquals('98765', acc.NCRGUID__c, 'NCR GUID should match from the New Customer Request');
        // }
    }
  
    
    @isTest
    static void testConvertNewCustomerRequestConfirmedStatus() {
         Test.startTest();
        //Set up the mock response
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setBody('[{"ncrGuid":98765,"accountNumber":"FGC*123","employeeNumber":"123456","status":"Confirmed","dmoComment":""}]');
        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));
        Lead leadrecord = [SELECT Id, Requested_For__c, Business_Unit__c, Status, Beer_Salesman_1__c,
                          Street, Displayable__c, City, State, PostalCode, Company, Draft_Status__c, Licensee_Name__c, 
                          Tax_ID_Seller_Permit__c, License_1__c, FirstName, Sell_Type__c, Premise__c,Ethnic_Patron__c,
                          License_Expiration_Date__c, License_Type__c, License_Status__c,Phone, Email, LastName,Company__c,
                          Warehouse__c, Class__c, Subclass__c, Chain_Independent__c,Civilian_Military__c,Residence__c,
                          Beer_Industry_Volume__c, Lifestyle__c, Occupation_Code__c, Patron_Age_Code__c, 
                          Requested_Delivery_Days__c, Package_Type__c, POS_Materials__c, Terms__c,
                          Print_Separate_Empty_Invoice__c, NCRGUID__c, VIP_Account_Number__c,
                          OwnerId, Owner.Name, Owner.ProfileId, Owner.Profile.Name
                          FROM Lead WHERE LastName = 'Test Query2' LIMIT 1];
        
       
        BatchConvertNewCustomerRequests batchConvertNCRs = new BatchConvertNewCustomerRequests();
        batchConvertNCRs.query = 'SELECT Id, Company, State, VIP_Account_Number__c, NCRGUID__c, FirstName, LastName, Requested_For__r.Email,' + 
            ' Requested_For__r.FederationIdentifier, OwnerId,Owner.Name,Owner.ProfileId,Owner.Email, DMO_Comment__c, Owner.Profile.Name, Requested_For__c' +
            ' FROM Lead' +
            ' WHERE NCRGUID__c != null AND Status = \'Submitted to DMO\'';
        Database.executebatch(batchConvertNCRs);
        Test.stopTest();
        
        //Assertion
        Account acc = [SELECT Id, NCRGUID__c FROM Account LIMIT 1];
        System.assertEquals('98765', acc.NCRGUID__c, 'NCR GUID should match from the New Customer Request');
    }
    
    
    @isTest
    static void testConvertNewCustomerRequest() {
       Test.startTest();      
        //Set up the mock response
        
        HttpResponse res = new HttpResponse();
							   
        res.setBody('[{"ncrGuid":98765,"accountNumber":"FGC*123","employeeNumber":"123456","status":"Complete","dmoComment":""}]');
        res.setStatusCode(200);
     
        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));
   
						 
        BatchConvertNewCustomerRequests batchConvertNCRs = new BatchConvertNewCustomerRequests();
        batchConvertNCRs.query = 'SELECT Id, Company, State, VIP_Account_Number__c, NCRGUID__c, FirstName, LastName, Requested_For__r.Email,' + 
            ' Requested_For__r.FederationIdentifier, OwnerId,Owner.Name ,Owner.ProfileId,Owner.Email, DMO_Comment__c, Owner.Profile.Name, Requested_For__c' +
            ' FROM Lead' +
            ' WHERE NCRGUID__c != null AND Status = \'Submitted to DMO\'';
        Database.executebatch(batchConvertNCRs);
        Test.stopTest();
        
        //Assertion
        Account acc = [SELECT Id, NCRGUID__c FROM Account LIMIT 1];
        System.assertEquals('98765', acc.NCRGUID__c, 'NCR GUID should match from the New Customer Request');
    }

}
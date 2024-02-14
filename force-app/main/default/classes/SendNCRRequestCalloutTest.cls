@isTest
public class SendNCRRequestCalloutTest {

    @TestSetup
    private static void setup() {
        //Create the Endpoint in the Settings
        TestFactory.createMulesoftUtilitySetting('New Customer Request', 'http://rh-suggested-sell-xapi.us-e2.cloudhub.io/api/new-customer-request', '/', null, null, null, '123', '123');
        
        //Create a Field Sales User
        Profile p = [SELECT Id FROM Profile WHERE Name='Field Sales'];
        User fsr = new User(Alias='fsruser', Email='fsr@testorg.com', FederationIdentifier = '123456',
						EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
						LocaleSidKey='en_US', ProfileId=p.Id, VIP_Company__c = 'CBS', Assigned_Route__c = '12345', 
						TimeZoneSidKey='America/Los_Angeles', UserName='fsr@testorg.com');
		insert fsr;
               
        //Create a Chain
        Chain__c chain = new Chain__c(Name='AMAZON', Business_Unit__c='CBS', Chain_Id__c='181AM');
        insert chain;
        
        //Create an NCR
        Lead testNCR = new Lead();
        testNCR.Business_Unit__c = 'CBS';
        testNCR.Requested_For__c = fsr.Id;
        testNCR.Company = 'Test Company';
        testNCR.Licensee_Name__c = 'Test Company, LLC';
        testNCR.Street = '123 1st Avenue';
        testNCR.City = 'Chicago';
        testNCR.State = 'IL';
        testNCR.PostalCode = '60018';
        testNCR.County__c = 'CK';
        testNCR.FirstName = 'John';
        testNCR.LastName = 'Doe';
        testNCR.Phone = '555-555-5555';
        testNCR.Fax = '555-555-5555';
        testNCR.License_1__c = '11111';
        testNCR.License_Expiration_Date__c = System.today().addYears(1);
        testNCR.License_Type__c = 'Beer Wine & Liquor';
        testNCR.License_Status__c = 'Active';
        testNCR.Tax_ID_Seller_Permit__c = '1111111111';
        testNCR.Beer_Salesman_1__c = fsr.Id;
        testNCR.Package_Type__c = 'Draft & Pkg';
        testNCR.Draft_Status__c = 'Mixed Draft Account';
        testNCR.Seasonal_Open_Month__c = 'January';
        testNCR.Seasonal_Close_Month__c = 'February';
        testNCR.Displayable__c = 'Displayable';
        testNCR.POS_Materials__c = '<50 Case Display';
        testNCR.Subclass__c = 'Local Bar';
        testNCR.Sell_Type__c = 'House Account';
        testNCR.Chain__c = chain.Id;
        testNCR.Chain_Independent__c = 'Chain';
        testNCR.Beer_Industry_Volume__c = 'Top 50/20%';
        testNCR.Civilian_Military__c = 'Civilian';
        testNCR.Ethnic_Patron__c = 'General Pop';
        testNCR.Lifestyle__c = 'General Pop';
        testNCR.Occupation_Code__c = 'Blue Collar';
        testNCR.Patron_Age_Code__c = 'General Pop';
        testNCR.Residence__c = 'Local';
        testNCR.Company__c = 'Chicago Beverage';
        testNCR.Warehouse__c = 'Chicago Beverage';
		testNCR.Print_Separate_Empty_Invoice__c = true;
        testNCR.Terms__c = 'Charge';
        testNCR.Premise__c = 'On Premise';
        testNCR.Class__c = 'Bar/Tavern';
        testNCR.Requested_Delivery_Days__c = 'Monday';
        testNCR.Email = 'test@test.org';
        testNCR.Comments_for_MDM_Team__c = 'Test Sending NCR';
        testNCR.Callout_Retry_Attempts__c = 2;   //Setting to 2, so it executes failure code
        insert testNCR;
    }
    
	@isTest
    static void testSendNCRValid() {
        Lead testNCR = [SELECT Id FROM Lead LIMIT 1];
		User inside = [SELECT Id FROM User WHERE Lastname LIKE '%Inside%' LIMIT 1];
        testNCR.Sell_Type__c = 'Inside Sales';
        testNCR.Beer_Salesman_1__c = inside.Id;
        update testNCR;
        List<Id> ncrIds = new List<Id>();
        ncrIds.add(testNCR.Id);
        
        //Set up the mock response
        HttpResponse res = new HttpResponse();
        res.setStatusCode(201);
        res.setBody('{"ncrGuid": "12345"}');
        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));

        Test.startTest();
            SendNCRRequestCallout.sendNCRRequest(ncrIds);
        Test.stopTest();

        //Verify the response
        Lead validateNCR = [SELECT Status FROM Lead LIMIT 1];
        System.assertEquals('Submitted to DMO', validateNCR.Status, 'The status of the request should be "Submitted to DMO"');
    }
    
    @isTest
    static void testSendNCRValid2() {
        Lead testNCR = [SELECT Id FROM Lead LIMIT 1];
		User inside = [SELECT Id FROM User WHERE Lastname LIKE '%Inside%' LIMIT 1];
        testNCR.Sell_Type__c = 'National Accounts';
        testNCR.Beer_Salesman_1__c = inside.Id;
        update testNCR;
        List<Id> ncrIds = new List<Id>();
        ncrIds.add(testNCR.Id);
        
        //Set up the mock response
        HttpResponse res = new HttpResponse();
        res.setStatusCode(201);
        res.setBody('{"ncrGuid": "12345"}');
        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));

        Test.startTest();
            SendNCRRequestCallout.sendNCRRequest(ncrIds);
        Test.stopTest();

        //Verify the response
        Lead validateNCR = [SELECT Status FROM Lead LIMIT 1];
        System.assertEquals('Submitted to DMO', validateNCR.Status, 'The status of the request should be "Submitted to DMO"');
    }
        
	@isTest
    static void testSendNCRInvalid() {
        Lead testNCR = [SELECT Id FROM Lead LIMIT 1];
        User fsr = [SELECT Id FROM User WHERE Username = 'fsr@testorg.com' LIMIT 1];
        User open = [SELECT Id FROM User WHERE Lastname LIKE '%Open%' LIMIT 1];
        testNCR.FirstName = 'First Name - longer than 25 characters';
        testNCR.LastName = 'Last Name - longer than 25 characters';
        testNCR.Company = 'Test Company - make greater than 25 characters';
		testNCR.Street = '123 Test Street - make longer than 25 characters';
        testNCR.City = 'Chicago - make longer than 15 characters';
        testNCR.PostalCode = '60018-5555';
        testNCR.Fax = '';
        testNCR.Seasonal_Open_Month__c = 'March';
        testNCR.Seasonal_Close_Month__c = 'April';
        testNCR.Beer_Salesman_1__c = open.Id;
		testNCR.Beer_Salesman_2__c = fsr.Id;
        testNCR.Beer_Salesman_2__c = fsr.Id;
        testNCR.Beer_Salesman_3__c = fsr.Id;
        testNCR.Supervisor__c = fsr.Id;
        testNCR.Supervisor_2__c = fsr.Id;
        testNCR.Supervisor_3__c = fsr.Id;
		testNCR.Chain_Independent__c = 'Independent';        
        testNCR.Chain__c = null;
        testNCR.Email = 'test-Makelongerthan60charactersssssssssssssssssssssss@test.org';
        testNCR.Callout_Retry_Attempts__c = 2;   //Setting to 2, so it executes failure code
        update testNCR;
        List<Id> ncrIds = new List<Id>();
        ncrIds.add(testNCR.Id);
        
        //Set up the mock response
        HttpResponse res = new HttpResponse();
        res.setStatusCode(500);
        res.setBody('{"statusCode": "500","message": "INTERNAL_SERVER_ERROR","detailErrorMessage": "HTTP POST on resource \'http://internal-reyes-mulesoft-non-prod-internal.lb.anypointdns.net:80/rh-ncr-sapi-dev/api/ncr\' failed: internal server error (500)."}');
        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));

        Test.startTest();
            SendNCRRequestCallout.sendNCRRequest(ncrIds);
        Test.stopTest();

        //Verify the response
        Lead validateNCR = [SELECT Status FROM Lead LIMIT 1];
        System.assertEquals('Error Posting to DMO', validateNCR.Status, 'The status of the request should be "Error Posting to DMO"');
    }  
    
	@isTest
    static void testConvertMonth() {
        List<String> months = new List<String>{'January','February','March','April','May','June','July','August','September','October','November','December'};
        
        for (String m : months) {
            String str = SendNCRRequestCallout.convertMonth(m);
            System.assertNotEquals(null,str);
        }       
    }    
}
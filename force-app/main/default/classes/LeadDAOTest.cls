@isTest
private class LeadDAOTest {

	@TestSetup
    private static void setup() {
        Id userId = UserInfo.getUserId();
        User testUser = [SELECT Id FROM User WHERE Id = :userId];
        System.runAs(testUser){
            Profile fsrProfile = [SELECT Id FROM Profile WHERE Name = 'Field Sales'];
        	UserRole testUserRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Admin'];
        	User testFSR = TestFactory.createUser(fsrProfile.Id, testUserRole.Id, 'newtest34673454User@gmail.com', null);
            testFSR.VIP_Company__c = 'FGC';
            update testFSR;
			//Create the Prospective Customer as if it's already send to the DMO
            Lead testNCR = new Lead(Requested_For__c = testFSR.Id, Business_Unit__c = 'FGC', Status = 'Submitted to DMO', 
                                    Company = 'Test Company', Licensee_Name__c = 'Test Account', Tax_ID_Seller_Permit__c = '11111', License_1__c = '11111', 
                                    License_Expiration_Date__c = System.today().addYears(1), License_Type__c = 'Beer Wine & Liquor', License_Status__c = 'Active',
                                    Street = '111 Test Street', City = 'Chicago', State = 'IL', PostalCode = '60618', FirstName = 'John', LastName = 'Doe',
                                    Phone = '555-555-5555', Email = 'john@testcompany.com', Sell_Type__c = 'Presell', Premise__c = 'On Premise', 
                                    Class__c = 'Bar/Tavern', Subclass__c = 'Irish Pub', Chain_Independent__c = 'Independent', Civilian_Military__c = 'Civilian', 
                                    Beer_Industry_Volume__c = 'Top 50/20%', Ethnic_Patron__c = 'General Pop', Lifestyle__c = 'General Pop', 
                                    Occupation_Code__c = 'College', Patron_Age_Code__c = 'General Pop', Residence__c = 'Local', Beer_Salesman_1__c = testFSR.Id,
                                    Requested_Delivery_Days__c = 'Monday', Package_Type__c = 'Package Only', Draft_Status__c = 'Draft Opportunity', 
                                    Displayable__c = 'Displayable', POS_Materials__c = '<50 Case Display', Company__c = 'Gold Coast Beverage', Warehouse__c = 'Doral',
                                    Print_Separate_Empty_Invoice__c = true, Terms__c = 'Check', NCRGUID__c = '98765');
            insert testNCR;
        }
    }

    @isTest
    static void testGetLeadById() {
        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        
        Test.startTest();
            Lead leadCheck = LeadDAO.getLeadById(lead.Id);        
        Test.stopTest();

        System.assertNotEquals(null, leadCheck, '1 Lead should be returned');
    }
    
    @isTest
    static void testGetConvertedNCRList() {
        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        //Convert the Lead
        Database.LeadConvert lc = new Database.LeadConvert();
		lc.setLeadId(lead.Id);						
		lc.setConvertedStatus('Created in E360');
		lc.setDoNotCreateOpportunity(true);
        Database.DMLOptions dml = new Database.DMLOptions();
		dml.DuplicateRuleHeader.AllowSave = true;        
		Database.LeadConvertResult lcr = Database.convertLead(lc, dml);
                
        Test.startTest();
            List<Lead> leadList = LeadDAO.getConvertedNCRList();
        	LeadDAO.updateLeads(leadList);
        Test.stopTest();

        System.assertEquals(1, leadList.size(), '1 Lead should be returned');
    }

}
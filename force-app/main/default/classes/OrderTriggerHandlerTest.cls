@isTest
public class OrderTriggerHandlerTest {
	@TestSetup
	static void testDate(){
		
		Account testAccount = new Account();
        testAccount.Name = 'Test Account';
		insert testAccount;
        
        Order ord  = new Order();          
    	ord.Status='Pending';
    	ord.EffectiveDate = system.today() + 5 ;
    	ord.AccountId = testAccount.Id;
		insert ord;
	}
    @isTest
	/*
		Delete an Order as a System Admin
	*/
    static void testOrderDelSystemAdminUser() {
		Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
		User systemAdminUser = TestFactory.createUser(systemAdminProfile.Id, null, 'testfs1@gmail.com', null);
		Order ord = [SELECT Id, IsDeleted FROM Order LIMIT 1];
        
		Test.startTest();
			System.runAs(systemAdminUser){
				delete ord;
			}
   		Test.stopTest();
		
        Integer ordSize = [SELECT Id, IsDeleted FROM Order].size();
        System.assertEquals(ordSize, 0, 'The order was not deleted');	
    }
	/*
		Delete an Order as a Field Sales User
	*/
	@isTest
	static void testOrderDelFieldSalesUser() {
		Profile fieldSalesProfile = [SELECT Id FROM Profile WHERE Name = 'Field Sales'];
		User fieldSalesUser = TestFactory.createUser(fieldSalesProfile.Id, null, 'testfs1@gmail.com', null);
		Order ord = [SELECT Id, IsDeleted FROM Order LIMIT 1];
		ord.OwnerId = fieldSalesUser.Id;
		update ord;
        
		Test.startTest();
			System.runAs(fieldSalesUser){
				try {
					delete ord;
				} catch (System.DmlException e) {
					System.assertEquals('You do not have permissions to delete this record!', 
						e.getDMLMessage(0), 'wrong error message');
				}
			}
   		Test.stopTest();
    }
	@isTest
    static void testStampAccountOwnerField() {
		Order ord = [SELECT Account_Owner__c, Account_OwnerId_formula__c FROM Order LIMIT 1];
        System.assertEquals(ord.Account_Owner__c, ord.Account_OwnerId_formula__c,
			'The Account Owner field was not copied as the same');	
		Test.startTest();
			ord.Account_Owner__c = null;
			update ord;
   		Test.stopTest();
		
		ord = [SELECT Account_Owner__c, Account_OwnerId_formula__c FROM Order LIMIT 1];
        System.assertEquals(ord.Account_Owner__c, ord.Account_OwnerId_formula__c,
			'The Account Owner field was not copied as the same');		
    }
}
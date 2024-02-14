@isTest
public class sendOrderEmailAlertInvocableTest {
	@TestSetup
    public static void testData(){
    	//Account Owner
    	//Account Owner Profile
    	//Primary POC
    	//Order Placer
    	//Manager
    	//Manager Profile
    	//Order Line Item
       
    	
    	Profile callCenterSuper = [SELECT Id FROM Profile WHERE Name = 'Call Center Supervisor'];
    	Profile callCenter = [SELECT Id FROM Profile WHERE Name = 'Call Center'];
        Contact ordPlacer = new Contact();
        ordPlacer.FirstName = 'Happy ordPlacer';
        ordPlacer.LastName = 'Test';
        ordPlacer.Email = 'orderPlacerTest@test.com';
        ordPlacer.Phone = '1234567777';
        
        insert ordPlacer;
        
        Contact poc = new Contact();
        poc.FirstName = 'Happy POC';
        poc.LastName = 'Test';
        poc.Email = 'pocTest@test.com';
        poc.Phone = '1234568888';
        poc.EmailOrderConfirmation__c = true;
        
        insert poc;
        
    	User manager = new User();
        manager.FirstName = 'Test';
        manager.LastName = 'Manager';
        manager.Email = 'ManagerTest@test.com';
        manager.ProfileId = callCenterSuper.Id;
        manager.Username = 'superuniquemanager@username.com';
        manager.alias = 'tmana';
        manager.TimeZoneSidKey= 'America/Mexico_City';
        manager.LocaleSidKey= 'en_US';
        manager.EmailEncodingKey= 'ISO-8859-1';
        manager.LanguageLocaleKey= 'en_US';
        
        insert manager;
        
        
        User accOwner = new User();
       	accOwner.FirstName = 'Test';
        accOwner.LastName = 'accOwner';
        accOwner.Email= 'accOwner@test.com';
        accOwner.ProfileId = callCenter.Id;
        accOwner.ManagerId = manager.Id;
        accOwner.Username = 'superuniquemanageruser@namebutnot.com';
        accOwner.alias = 'atest';
        accOwner.TimeZoneSidKey= 'America/Mexico_City';
        accOwner.LocaleSidKey= 'en_US';
        accOwner.EmailEncodingKey= 'ISO-8859-1';
        accOwner.LanguageLocaleKey= 'en_US';
        
        insert accOwner;
        
        Id retailStore = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retail Store').getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Super Email Test Account';
        acc.RecordTypeId = retailStore;
        acc.OwnerId = accOwner.Id;
        acc.Primary_POC__c = poc.Id;
        
        insert acc;
        
        Id prodId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('SKU').getRecordTypeId();
        Product2 product = new Product2();
        product.RecordTypeId = prodId;
        product.Name = 'Test product time';
        
        insert product;
        


        
    }
    
    @isTest
    public static void testEmailOrderConfirm1(){
        List<String> ords = new List<String>();
        Account testAcc = [SELECT Id FROM Account WHERE Name = 'Super Email Test Account'];
		Product2 testProd = [SELECT Id FROM Product2 WHERE Name = 'Test product time' ];
		Contact placer = [SELECT Id FROM Contact WHERE Name = 'Happy ordPlacer Test'];
        
        Order ord = new Order();
        ord.Order_Placed_By__c = placer.Id;
        ord.AccountId = testAcc.Id;
        ord.Status = 'Pending Draft';
        ord.EffectiveDate = Date.today();

        insert ord;
        
        OrderItem item = new OrderItem();
        item.Product2Id = testProd.Id;
        item.OrderId = ord.Id;
        item.Quantity = 1;
        
        insert item;
        
        Test.startTest();
        ord.Status = 'Posted to VIP';
        ords.add(ord.Id);
        update ord;
        sendOrderEmailAlertInvocable.sendOrderEmail(ords);
        Test.stopTest();
    }
    
        @isTest
    	public static void testEmailOrderConfirm2(){
        List<String> ords = new List<String>();
        Account testAcc = [SELECT Id FROM Account WHERE Name = 'Super Email Test Account'];
		Product2 testProd = [SELECT Id FROM Product2 WHERE Name = 'Test product time' ];
        Contact testPoc = [SELECT Id FROM Contact WHERE Name = 'Happy POC Test'];
        Contact placer = [SELECT Id FROM Contact WHERE Name = 'Happy ordPlacer Test'];
        testPoc.EmailOrderConfirmation__c = false;
            
        Order ord = new Order();
        ord.Order_Placed_By__c = placer.Id;
        ord.AccountId = testAcc.Id;
        ord.Status = 'Pending Draft';
        ord.EffectiveDate = Date.today();

        insert ord;
        
        OrderItem item = new OrderItem();
        item.Product2Id = testProd.Id;
        item.OrderId = ord.Id;
        item.Quantity = 1;
        
        insert item;
        
        Test.startTest();
        ord.Status = 'Posted to VIP';
        ords.add(ord.Id);
        update ord;
        sendOrderEmailAlertInvocable.sendOrderEmail(ords);
        Test.stopTest();
    }
    
}
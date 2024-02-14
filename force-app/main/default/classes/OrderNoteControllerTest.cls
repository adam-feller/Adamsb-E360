@isTest
public class OrderNoteControllerTest {
    
    static testMethod void testOrderNoteFromComponent() {
        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
		insert testAccount;
        
        Order ord  = new Order();          
    	ord.Status='Pending';
    	ord.EffectiveDate = system.today() + 5 ;
    	ord.AccountId = testAccount.Id;
		insert ord;
                
		Test.startTest();
        	Account acc = OrderNoteController.getAccount(testAccount.Id);
        	Order order = OrderNoteController.getOrder(ord.Id);
			OrderNoteController.createNote(order.Id, acc.Id, 'Test', Blob.valueOf('This is a test'));			
		Test.stopTest();
                                           
        //Assertions
        List<ContentDocumentLink> accVersionList = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :acc.Id];
		System.assertEquals(1,accVersionList.size());
        List<ContentDocumentLink> ordVersionList = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :order.Id];
		System.assertEquals(1,ordVersionList.size());
    }
    
    
    static testMethod void testOrderNoteFromRecord() {
        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
		insert testAccount;
        
        Order ord  = new Order();          
    	ord.Status='Pending';
    	ord.EffectiveDate = system.today() + 5 ;
    	ord.AccountId = testAccount.Id;
		insert ord;
                
		Test.startTest();
        	Order order = OrderNoteController.getOrder(ord.Id);	
        	Account acc = OrderNoteController.getAccountByOrderId(order.Id);        	
			OrderNoteController.createNote(order.Id, acc.Id, 'Test', Blob.valueOf('This is a test'));			
		Test.stopTest();
                                           
        //Assertions
        List<ContentDocumentLink> accVersionList = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :acc.Id];
		System.assertEquals(1,accVersionList.size());
        List<ContentDocumentLink> ordVersionList = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :order.Id];
		System.assertEquals(1,ordVersionList.size());
    }
}
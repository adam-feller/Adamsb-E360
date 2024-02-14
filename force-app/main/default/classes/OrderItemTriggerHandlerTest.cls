@isTest
public class OrderItemTriggerHandlerTest {
    
    static testMethod void testOrderDel() {
        //Set up Account/Pricebook/Products/Order
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2346');
        Pricebook2 testStandardPriceBook = TestFactory.createStandardPriceBook();
        Product2 testProd = TestFactory.createProduct('Test Product', '12345', 'MillerCoors', '123*B');
        PriceBookEntry testPriceBookEntry = TestFactory.createPriceBookEntry(testStandardPriceBook.Id, testProd.Id, 11.99, false, true);
        Id invoiceOrderRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Invoice').getRecordTypeId();
        Order testOrderInvoice = TestFactory.createOrderRecordType(testAccount.Id, testStandardPriceBook.Id, System.today(), 'Invoice', invoiceOrderRecordTypeId);
        //Create the Pinned Product        
		Product_Feedback__c pinnedProduct = ProductFeedbackDAO.createProductFeedback(testAccount.Id, testProd.Id, 'Test Notes', System.today()+30, '', 'Pinned');
        
		Test.startTest();
			//Create the Order Item
			TestFactory.createOrderItem(testPriceBookEntry.Id, testOrderInvoice.Id, 1, 2, 11.99, testProd.Id);			
		Test.stopTest();
        
        //Assertions
        //Requery the pinned product and make sure it has been updated
		Product_Feedback__c pf = [SELECT Id, Feedback__c, isHidden__c FROM Product_Feedback__c WHERE Id =: pinnedProduct.Id];
        System.assertEquals(true, pf.isHidden__c);
        System.assert(pf.Feedback__c.contains('Product was Sold In'), 'Feedback should have been updated.');
    }
    
}
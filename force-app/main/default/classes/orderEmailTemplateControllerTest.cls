@isTest
public class orderEmailTemplateControllerTest {
    
    @isTest
    public static void testOrderItemVFComponent(){
        //create an account
        RecordType retail = [SELECT Id
                             FROM RecordType
                             WHERE Name = 'Retail Store'];
        Account acc = new Account();
        acc.Name = 'Happy Little Test Account';
        acc.RecordTypeId = retail.Id;
        
        insert acc;
		//create an order
		Order myOrder = new Order();
        myOrder.AccountId = acc.Id;
        myOrder.EffectiveDate = Date.today();
        myOrder.Status = 'Pending Draft';
		
        insert myOrder;
		//create a product
		RecordType SKU = [SELECT Id
                          FROM RecordType
                          WHERE Name = 'SKU'];
		Product2 prod = new Product2();
        prod.RecordTypeId = SKU.Id;
        prod.Name = 'Happy Little Product Name';
        
        insert prod;
		//create an order item
		OrderItem item = new OrderItem();
        item.Quantity = 1;
        item.Product2Id = prod.Id;
        item.OrderId = myOrder.Id;
		
        insert item;
        
        orderEmailTemplateController testController = new orderEmailTemplateController();
      
        
        
        
        Test.startTest();
        String idString = String.valueOf(item.Id);
		//run query using order id to get order items
    	testcontroller.getOrderItems();        
        
        Test.stopTest();
    
    }

}
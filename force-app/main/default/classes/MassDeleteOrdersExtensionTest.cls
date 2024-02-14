// Tests for MassDeleteExtension
@isTest
private class MassDeleteOrdersExtensionTest {
    static testMethod void testDeleteRecords() {

        List<Order> Orders = new List<Order>();
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(Orders);
        MassDeleteOrdersExtension extension = new MassDeleteOrdersExtension(sc);

        System.assertNotEquals(null, extension.deleteRecords());
    }

    static testMethod void testSelectedSize() {
        List<Order> orders = new List<order>();
        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
		insert testAccount;
        
        Order ord  = new Order();          
    	ord.Status='Pending';
    	ord.EffectiveDate = system.today() + 5 ;
    	ord.AccountId = testAccount.Id;
		insert ord;
        orders.add(ord);

        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(orders);
        sc.setSelected(orders);
        MassDeleteOrdersExtension extension = new MassDeleteOrdersExtension(sc);
		
        System.assertEquals('1', extension.getMySelectedSize());

        System.assertNotEquals(null, extension.deleteRecords());
    }
}
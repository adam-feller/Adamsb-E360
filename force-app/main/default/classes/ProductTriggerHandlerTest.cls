@isTest
private class ProductTriggerHandlerTest {
    @TestSetup
    private static void setup() {
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2346');
        Product2 testProd = TestFactory.createProduct('Test Product', '12345', 'MillerCoors', '123*B');
        //Create the Pinned Product        
		Product_Feedback__c pinnedProduct = ProductFeedbackDAO.createProductFeedback(testAccount.Id, testProd.Id, 'Test Notes', System.today()+30, '', 'Pinned');
    }

    static Product2 getProduct() {
        return [SELECT Id, Name FROM Product2 LIMIT 1];
    }

    static Product_Feedback__c getProductFeedback() {
        return [SELECT Id, Feedback__c FROM Product_Feedback__c LIMIT 1];
    }
    
    @isTest
    static void testcopySKUvalues() {
        
        Test.startTest();
        	Product2 testProduct = getProduct();
        	testProduct.Description = 'Test Description';
        	testProduct.Pkg_name__c = 'Test Pkg Name';
			update testProduct;
        Test.stopTest();
                
        //Assertion        
        Product2 checkProduct = getProduct();
     	System.assertEquals('Test Description Test Pkg Name', checkProduct.Name);
    }
    
    @isTest
    static void testInactivedProduct() {
        
        Test.startTest();
        	Product2 testProduct = getProduct();
        	testProduct.IsActive = false;
			update testProduct;
        Test.stopTest();
        
        //Assertion
        Product_Feedback__c checkFeedback = getProductFeedback();
        System.assert(checkFeedback.Feedback__c.contains('Product was Inactivated on'));
    }    
}
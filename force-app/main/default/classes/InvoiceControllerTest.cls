@isTest
public class InvoiceControllerTest {
	@TestSetup
    private static void setup() {
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        UserRole adminRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Admin'];
        User testAdmin = TestFactory.createUser(systemAdminProfile.Id, adminRole.Id, 'newtestUser99@gmail.com', UserInfo.getUserId());
        
        System.runAs(testAdmin) {
        	//Create Account and Contact
        	Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2346');
        	Contact testContact = TestFactory.createContact(testAccount.Id, 'Test', 'Contact', 'test2@reyesholdings.com');
        	//Create the Invoice
        	Pricebook2 testPriceBook = TestFactory.createPriceBook(testAccount.Id, testAccount.Name, true, 'Account Pricebook');        
        	Id invoiceOrderRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Invoice').getRecordTypeId();
        	Order testOrderInvoice = TestFactory.createOrderRecordType(testAccount.Id, testPriceBook.Id, System.today(), 'Pending Draft', invoiceOrderRecordTypeId);
        	testOrderInvoice.Order_Origin__c = 'Text To Order';
            testOrderInvoice.Invoice_Number__c = '100000';
        	update testOrderInvoice;
        }
    }
    
    static Account getAccount() {
        return [SELECT Id, ExternalId__c FROM Account LIMIT 1];
    }

    static Contact getContact() {
        return [SELECT Id FROM Contact LIMIT 1];
    }
    
    static Order getInvoice() {
        return [SELECT Id FROM Order LIMIT 1];
    }

    
    @isTest
    static void testGetInvoiceData() {
        Account testAccount = getAccount();

        Test.startTest();
            InvoiceController.InvoiceDataWrapper results = InvoiceController.getInvoiceData(testAccount.Id);
        Test.stopTest();

		//Assertion
        System.assertEquals(1, results.invoiceList.size(), 'Should have found the Test Invoice');
    }
    
    
    @isTest
    static void testSendInvoiceToCustomer() {
        Contact testContact = getContact();
        Order testInvoice = getInvoice();

        InvoiceController.InputVariables inputList = new InvoiceController.InputVariables();
        inputList.contactId = testContact.Id;
        inputList.invoiceId = testInvoice.Id;
        
        //Set Mock Response
        HttpResponse res = new HttpResponse();
        res.setBody('[{"this is a test"}]');
        res.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));
        
        Test.startTest();        
        	InvoiceController.sendInvoiceToCustomer(new List<InvoiceController.InputVariables>{inputList});
     		Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();
            
		//Assertion
        System.assertEquals(1, invocations, 'An email should be sent');
    }
    
    
     @isTest
    static void testViewInvoice() {
		Account testAccount = getAccount();
        Order testInvoice = getInvoice();

        InvoiceController.InputVariables inputList = new InvoiceController.InputVariables();
        inputList.invoiceId = testInvoice.Id;
        
		//Set Mock Response
        HttpResponse res = new HttpResponse();
        res.setBody('[{"this is a test"}]');
        res.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));
        
        Test.startTest();        
        	InvoiceController.sendInvoiceToCustomer(new List<InvoiceController.InputVariables>{inputList});
        Test.stopTest();
            
		//Assertion
		String tempFileName = 'Invoice_' + testAccount.ExternalId__c;        
        List<ContentDocument> tempFileList = [SELECT Id FROM ContentDocument WHERE Title = :tempFileName];
        System.assertEquals(1, tempFileList.size(), 'There should be a temp invoice file created');
    }
    
    @isTest
    static void testDeleteTempInvoiceFiles() {
        Account testAccount = getAccount();
        
        Test.startTest();        
        	InvoiceController.deleteTempInvoiceFiles(testAccount.Id);
        Test.stopTest();
              
        //Assertion
       	String tempFileName = 'Invoice_' + testAccount.ExternalId__c;        
        List<ContentDocument> tempFileList = [SELECT Id FROM ContentDocument WHERE Title = :tempFileName];
        System.assertEquals(0, tempFileList.size(), 'No temp invoice files should exist.');
    }
    
}
@isTest
public with sharing class PricebookEntryStageHandlerTest {
    @TestSetup
    private static void setup(){
        Account testAccount = TestFactory.createAccount('Test Account', '20135', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        Product2 prod = TestFactory.createProduct(
            'Beer', '45567','Brand', '345*34'
        );
        Invoice__c testInvoice = new Invoice__c();
        testInvoice.AccountId__c = testAccount.Id;
        testInvoice.External_Id__c = '123456';
        testInvoice.Name = 'TestInvoice';
        insert testInvoice;
    }
    

    @isTest
    private static void afterInvoiceHandler_TEST(){

        PricebookEntry_Stage__c pbe = new PricebookEntry_Stage__c(
                    CE_QTY__c = 1,
                    Discount_Amount__c = 1,
                    Expiration_Date__c = Date.Today(),
                    Extended_price_amt__c = 1,
                    External_Id__c = '123456*12',
                    Invoice_Line_Number__c = 1,
                    Invoice_External_Id__c = '123456',
                    Order_Date__c = Date.Today(),
                    Order_Method__c = 'CRM',
                    Out_of_Stock_unit_Qty__c = 3,
                    Product_External_Id__c = '345*34',
                    Quantity_sold__c = 3,
                    SALES_ORG_DIM_ID__c = 'CBS',
                    VIP_Instance__c = 'CBS'
            );
        insert  pbe;
    }
}
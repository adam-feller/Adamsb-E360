@isTest
public class DSOFControllerTest {
	
    @TestSetup
    private static void setup(){
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2345');
    	Product2 testProduct = TestFactory.createProduct('Test Product', '12345', 'MillerCoors', '123*B');
        Objective__c testObjective = TestFactory.createObjective('Test Objective', 'PVA', 'Display');
        Id processedDisplayProductRecordTypeId = Schema.SObjectType.Display_Product__c.getRecordTypeInfosByName().get('Processed').getRecordTypeId();
        TestFactory.createDisplayProduct(System.today() - 1, System.today() + 1, testAccount.Id, testProduct.Id, processedDisplayProductRecordTypeId);
    }
    
    static Account getAccount(){
        return [SELECT Id, Name, VIP_Account_Number__c, Beer_Company__c, Warehouse__c
                FROM Account
                LIMIT 1];
    }
    
    static Product2 getProduct(){
        return [SELECT Id, Name, SKU__c
                FROM Product2
                LIMIT 1];
    }
    
    static Objective__c getObjective(){
        return [SELECT Id, Name
                FROM Objective__c
                LIMIT 1];
    }
    
    static Display_Product__c getDisplayProduct(){
        return [SELECT Id, Name, Account__c, Product__c, Start_Date__c, End_Date__c
                FROM Display_Product__c
                LIMIT 1];
    }

    @isTest
    static void testFetchDisplayProduct(){
        Account testAccount = getAccount();

        Test.startTest();
            List<Display_Product__c> displayProductList = DSOFController.fetchDisplayProductsNullZeroCases(testAccount.Id ,'2');
        Test.stopTest();
        
        System.assertEquals(1, displayProductList.size(), '1 display product should be returned');
    }
    
    @isTest
    static void testfetchDisplayProductQuickAction(){
        Account testAccount = getAccount();

        Test.startTest();
            List<Display_Product__c> displayProductList = DSOFController.fetchDisplayProducts(testAccount.Id);
        Test.stopTest();
        
        System.assertEquals(1, displayProductList.size(), '1 display product should be returned');
    }

    @isTest
    static void testFetchDisplayProductNull(){
        Account testAccount = getAccount();

        Test.startTest();
            List<Display_Product__c> displayProductList = DSOFController.fetchDisplayProductsNullZeroCases(null, '2');
        Test.stopTest();
        
        System.assertEquals(displayProductList, new List<Display_Product__c>(), 'displayProductList should be null');
    }

    @isTest
    static void testGetPickListValues(){
        Test.startTest();
            DSOFController.getNoReasonPickListValues();
        Test.stopTest();

        system.assertNotEquals(null, DSOFController.getNoReasonPickListValues(), 'There are values in the picklist');
    }
    
    @isTest 
    static void testGetManagerRefusedPickListValues(){
        Test.startTest();
        	DSOFController.getManagerRefusedPickListValues();
        Test.stopTest();
        
        System.assertNotEquals(null, DSOFController.getManagerRefusedPickListValues(), 'There should be values in the manager refused picklist');
    }

    @isTest
    static void testcreateDisplayProduct0Cases(){
        Account testAccount = getAccount();
        Display_Product__c testDisplayProduct = getDisplayProduct();
        testDisplayProduct.Number_of_Cases__c = 0;
        testDisplayProduct.Primary_Secondary__c = 'Primary';

        List<Display_Product__c> displayProductList = new List<Display_Product__c>{testDisplayProduct};
        String jsonInput = JSON.serialize(displayProductList);

        Test.startTest();
            DSOFController.createDisplayProduct(testAccount.Id, jsonInput, '2');
        Test.stopTest();

        List<Task> taskListReturned = [SELECT Id FROM Task];

        System.assertEquals(1, taskListReturned.size(), '1 task record should be inserted for DSOF Gap');
    }
    
    @isTest
    static void testcreateDisplayProductNonZeroCases(){
        Account testAccount = getAccount();
        Display_Product__c testDisplayProduct = getDisplayProduct();
        testDisplayProduct.Number_of_Cases__c = 10;
        testDisplayProduct.Primary_Secondary__c = 'Primary';
        testDisplayProduct.Primary_Secondary__c = 'Primary';

        List<Display_Product__c> displayProductList = new List<Display_Product__c>{testDisplayProduct};
        String jsonInput = JSON.serialize(displayProductList);

        Test.startTest();
            DSOFController.createDisplayProduct(testAccount.Id, jsonInput, '2');
        Test.stopTest();

        //Verify the Reason Code was cleared
        Display_Product__c displayProduct = [SELECT Id, No_Display_Reason_Code__c FROM Display_Product__c LIMIT 1];
        System.assertEquals(null, displayProduct.No_Display_Reason_Code__c, 'The reason code should have been cleared because a non-zero value was entered');
    }
}
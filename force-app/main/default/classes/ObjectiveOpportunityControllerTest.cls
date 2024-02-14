@IsTest
public class ObjectiveOpportunityControllerTest {
    @TestSetup
    private static void setup() {
        Account testAccount = TestFactory.createAccount('Test Account', '20135', 'PVA', 'PDVA-CHANTILLY', null, '2345');        
        
        Objective__c testObjective = new Objective__c();
        testObjective.Name = 'Test Objective';
        testObjective.BU__c = 'PVA';
        testObjective.Objective_Type__c = 'Effective';
        testObjective.Start_Date__c = System.Today() - 1;
        testObjective.End_Date__c = System.Today() + 1;
        testObjective.Goal__c = 100;
        insert testObjective;
        
        Objective_Account__c testObjectiveAccount = new Objective_Account__c();
        testObjectiveAccount.Objective__c = testObjective.Id;
        testObjectiveAccount.recordTypeId = Schema.getGlobalDescribe().get('Objective_Account__c').getDescribe().getRecordTypeInfosByName().get('Effective').getRecordTypeId();
        testObjectiveAccount.Status__c = 'Incomplete';
        testObjectiveAccount.Account__c = testAccount.Id;
        testObjectiveAccount.Objective_Opportunity__c = '[{"product_type": "Brand","product_cd": "12345","container_type": "Can","ce_qty": 0.00000},{"product_type": "Sub-Brand","product_cd": "12345","container_type": "Can","ce_qty": 0.00000},{"product_type": "SKU","product_cd": "12345","container_type": "Can","ce_qty": 0.00000}]';
        insert testObjectiveAccount;
        
        List<Product2> testProducts = new List<Product2>();
        Product2 testProduct1 = new Product2();
        testProduct1.Name = 'Test Brand';
        testProduct1.Brand_External_Id__c = '12345';
        testProducts.add(testProduct1);
        Product2 testProduct2 = new Product2();
        testProduct2.Name = 'Test Sub-Brand';
        testProduct2.Subbrand_External_Id__c = '12345';
        testProducts.add(testProduct2);
        Product2 testProduct3 = new Product2();
        testProduct3.Name = 'Test SKU';
        testProduct3.SKU_External_Id__c = '12345';
        testProducts.add(testProduct3);
        insert testProducts;
    } 

    static Objective_Account__c getObjectiveAccount() {
        return [SELECT Id, recordTypeId FROM Objective_Account__c];
    }
    
    static Product2 getProduct(String prodName) {
        return [SELECT Id, recordTypeId FROM Product2 WHERE Name = :prodName];
    }

    static testMethod void ObjectiveOpportunityControllerTest() {        
        Objective_Account__c objAcc = getObjectiveAccount();
        
        Test.StartTest();        
        ObjectiveOpportunityController.ObjOppData tester = new ObjectiveOpportunityController.ObjOppData();
        tester = ObjectiveOpportunityController.getObjOppData(objAcc.Id);
        Test.StopTest();
        
        //Assertion
        System.assertEquals(3, tester.productData.size(), '3 Objective Opportunity Product should be returned');    
    }
    
    static testMethod void ObjectiveOpportunityControllerNonMatchingTest() {
        //Update the External Ids on the Brand and Sub Brand to not match
        Objective_Account__c objAcc = getObjectiveAccount();
        Product2 brandProd = getProduct('Test Brand');
        brandProd.Brand_External_Id__c = '12345*B';
        update brandProd;
        Product2 subbrandProd = getProduct('Test Sub-Brand');
        brandProd.Subbrand_External_Id__c = '12345*B';
        update subbrandProd;
        
        Test.StartTest();        
        ObjectiveOpportunityController.ObjOppData tester = new ObjectiveOpportunityController.ObjOppData();
        tester = ObjectiveOpportunityController.getObjOppData(objAcc.Id);
        Test.StopTest();
        
        //Assertion
        System.assertEquals(3, tester.productData.size(), '3 Objective Opportunity Product should be returned');    
    }

}
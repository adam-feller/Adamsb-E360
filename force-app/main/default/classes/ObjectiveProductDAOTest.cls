@isTest
private class ObjectiveProductDAOTest {

    @TestSetup
    private static void setup(){
        Product2 testProd = TestFactory.createProduct('Test Product', '12345', 'MillerCoors', '123*B');
        Account testAccount = TestFactory.createAccount('Test Account', '202', 'PVA', 'PDVA-CHANTILLY', null, '12346');
        Objective__c testObjective = TestFactory.createObjective('Test Objective', 'PVA', 'Distribution');
        TestFactory.createObjectiveLocation(testObjective.Id, 'PVA', 'PDVA-CHANTILLY', 100);
        TestFactory.createObjectiveAccount(testObjective.Id, 'Incomplete', testAccount.Id);
        TestFactory.createObjectiveProduct(testObjective.Id, testProd.Id);
    }

    static Account getAccount(){
        return [SELECT Id, Name
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

    static Objective_Product__c getObjectiveProduct(){
        return [SELECT Id, Name
                FROM Objective_Product__c
                LIMIT 1];
    }

    @isTest
    static void testGetObjectiveProductByObjectiveIds(){
        Objective__c testObjective = getObjective();

        Test.startTest();
            List<Objective_Product__c> objectiveProductList = ObjectiveProductDAO.getObjectiveProductByObjectiveIds(new Set<Id>{testObjective.Id});
        Test.stopTest();

        System.assertEquals(objectiveProductList.size(), 1, '1 objective product should be returned');
    }

    @isTest
    static void testFetchObjectiveProducts(){
        Account testAccount = getAccount();

        Test.startTest();
            List<Objective_Product__c> objectiveProductList = ObjectiveProductDAO.fetchObjectiveProducts(testAccount.Id);
        Test.stopTest();

        System.assertEquals(objectiveProductList.size(), 1, '1 objective product should be returned');
    }

    @isTest
    static void testInsertObjectiveProducts(){
        Objective__c testObjective = getObjective();
        Product2 testProduct = getProduct();

        Objective_Product__c testObjectiveProduct = new Objective_Product__c();
        testObjectiveProduct.Objective__c = testObjective.Id;
        testObjectiveProduct.Product__c = testProduct.Id;

        Test.startTest();
            List<Objective_Product__c> objectiveProductList = ObjectiveProductDAO.insertObjectiveProducts(new List<Objective_Product__c>{testObjectiveProduct});
        Test.stopTest();

        List<Objective_Product__c> objectiveProductsReturned = [SELECT Id
                                                                FROM Objective_Product__c];

        System.assertEquals(objectiveProductsReturned.size(), 2, '2 objective product record should be returned');
    }

    @isTest
    static void testUpdateObjectiveProducts(){
        Objective_Product__c testObjectiveProduct = getObjectiveProduct();

        Test.startTest();
            List<Objective_Product__c> objectiveProductList = ObjectiveProductDAO.updateObjectiveProducts(new List<Objective_Product__c>{testObjectiveProduct});
        Test.stopTest();

        List<Objective_Product__c> objectiveProductsReturned = [SELECT Id
                                                                FROM Objective_Product__c];

        System.assertEquals(objectiveProductsReturned.size(), 1, '1 objective product record should be returned');
    }

    @isTest
    static void testDeleteObjectiveProducts(){
        Objective_Product__c testObjectiveProduct = getObjectiveProduct();

        Test.startTest();
            List<Objective_Product__c> objectiveProductList = ObjectiveProductDAO.deleteObjectiveProducts(new List<Objective_Product__c>{testObjectiveProduct});
        Test.stopTest();

        List<Objective_Product__c> objectiveProductsReturned = [SELECT Id
                                                                FROM Objective_Product__c];

        System.assertEquals(objectiveProductsReturned.size(), 0, '0 objective product records should be returned');
    }
}
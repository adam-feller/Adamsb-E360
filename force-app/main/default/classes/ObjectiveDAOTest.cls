@isTest
private class ObjectiveDAOTest {

    @TestSetup
    private static void setup(){
        Objective__c testObjective = TestFactory.createObjective('Test Objective', 'PVA', 'Distribution');
        Product2 testProduct = TestFactory.createProduct('ProductBeer', 'SKU125', 'MillerCoors','SKU125');
        Objective_Product__c testObjProd = TestFactory.createObjectiveProduct(testObjective.id, testProduct.id);
        
        TestFactory.createObjectiveLocation(testObjective.Id, 'PVA', 'PDVA-CHANTILLY', 100);
    }

    static Objective__c getObjective(){
        return [SELECT Id, Name, Status__c
                FROM Objective__c
                LIMIT 1];
    }

    @isTest
    static void testGetObjectives(){
        Test.startTest();
            List<Objective__c> objectiveList = ObjectiveDAO.getObjectives();
        Test.stopTest();

        System.assertEquals(objectiveList.size(), 1, 'objectiveList should return 1 record');
    }

    @isTest
    static void testGetObjectivesByIds(){
        Objective__c testObj = getObjective();

        Test.startTest();
            List<Objective__c> objectiveList = ObjectiveDAO.getObjectivesByIds(new Set<Id>{testObj.Id});
        Test.stopTest();

        System.assertEquals(objectiveList.size(), 1, 'objectiveList should return 1 record');
    }

    @isTest
    static void testGetObjectiveById(){
        Objective__c testObj = getObjective();

        Test.startTest();
            List<Objective__c> objectiveList = ObjectiveDAO.getObjectiveById(testObj.Id);
        Test.stopTest();

        System.assertEquals(objectiveList.size(), 1, 'objectiveList should return 1 record');
    }

    @isTest
    static void testGetObjectiveByStatusReadyForExecution(){
        Objective__c testObj = getObjective();
        testObj.Status__c = 'Ready For Execution';
        update testObj;

        Test.startTest();
            List<Objective__c> objectiveList = ObjectiveDAO.getObjectiveByStatusReadyForExecution();
        Test.stopTest();

        System.assertEquals(objectiveList.size(), 1, 'objectiveList should return 1 record');
    }

    @isTest
    static void testGetObjectivesByBUAccountSync(){
        Test.startTest();
            List<Objective__c> objectiveList = ObjectiveDAO.getObjectivesByBUAccountSync(new Set<String>{'PVA'});
        Test.stopTest();

        System.assertEquals(objectiveList.size(), 1, 'objectiveList should return 1 record');
    }

    @isTest
    static void testUpdateObjectives(){
        Objective__c testObjective = getObjective();
        testObjective.Objective_Type__c = 'Display';

        Test.startTest();
            List<Objective__c> objectiveList = ObjectiveDAO.updateObjectives(new List<Objective__c>{testObjective});
        Test.stopTest();

        List<Objective__c> updatedObjective = [SELECT Id, Objective_Type__c
                                                FROM Objective__c];

        System.assertEquals(updatedObjective[0].Objective_Type__c, 'Display', 'Objective Type should be Display');
    }

    @isTest
    static void testInsertObjectives(){
        Objective__c testObjective = new Objective__c();
        testObjective.Name = 'Test Objective';
        testObjective.Objective_Type__c = 'Display';
        testObjective.BU__c = 'PVA';
        testObjective.Start_Date__c = System.Today();
        testObjective.End_Date__c = System.Today() + 1;
        testObjective.Goal__c = 50;

        Test.startTest();
            List<Objective__c> objectiveList = ObjectiveDAO.insertObjectives(new List<Objective__c>{testObjective});
        Test.stopTest();

        List<Objective__c> objectivesReturned = [SELECT Id
                                                FROM Objective__c];

        System.assertEquals(objectivesReturned.size(), 2, '2 objective records should be returned');
    }
    
    @isTest
    static void testGetObjectiveProducts(){
        Objective__c testObjective = getObjective();
        Test.startTest();
            List<Product2> prodList = ObjectiveDAO.getObjectiveProducts(testObjective.Id);
        Test.stopTest();

        System.assertEquals(prodList.size(), 1, 'Product List should return 1 record');
    }
}
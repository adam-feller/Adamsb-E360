@isTest
private class ObjectiveLocationDAOTest {

    @TestSetup
    private static void setup(){
        Objective__c testObjective = TestFactory.createObjective('Test Objective', 'PVA', 'Distribution');
        TestFactory.createObjectiveLocation(testObjective.Id, 'PVA', 'PDVA-CHANTILLY', 100);
    }

    static Objective__c getObjective(){
        return [SELECT Id, Name
                FROM Objective__c
                LIMIT 1];
    }

    static Objective_Location__c getObjectiveLocation(){
        return [SELECT Id, Goal_Amount__c
                FROM Objective_Location__c
                LIMIT 1];
    }

    @isTest
    static void testGetObjectiveLocationByObjectiveIds(){
        Objective__c testObjective = getObjective();

        Test.startTest();
            List<Objective_Location__c> objectiveLocationList = ObjectiveLocationDAO.getObjectiveLocationByObjectiveIds(new Set<Id>{testObjective.Id});
        Test.stopTest();

        System.assertEquals(objectiveLocationList.size(), 1, 'objectiveLocationList should return 1 record');
    }

    @isTest
    static void testgetObjectiveLocationByObjectiveIdsAllTime(){
        Objective__c testObjective = getObjective();

        Test.startTest();
            List<Objective_Location__c> objectiveLocationList = ObjectiveLocationDAO.getObjectiveLocationByObjectiveIdsAllTime(new Set<Id>{testObjective.Id});
        Test.stopTest();

        System.assertEquals(objectiveLocationList.size(), 1, 'objectiveLocationList should return 1 record');
    }

    @isTest
    static void testGetObjectiveLocationByObjectiveId(){
        Objective__c testObjective = getObjective();

        Test.startTest();
            List<Objective_Location__c> objectiveLocationList = ObjectiveLocationDAO.getObjectiveLocationByObjectiveId(testObjective.Id);
        Test.stopTest();

        System.assertEquals(objectiveLocationList.size(), 1, 'objectiveLocationList should return 1 record');
    }

    @isTest
    static void testGetObjectiveLocationByObjectiveLocationIds(){
        Objective_Location__c testObjectiveLocation = getObjectiveLocation();

        Test.startTest();
            List<Objective_Location__c> objectiveLocationList = ObjectiveLocationDAO.getObjectiveLocationByObjectiveLocationIds(new List<String>{testObjectiveLocation.Id});
        Test.stopTest();

        System.assertEquals(objectiveLocationList.size(), 1, 'objectiveLocationList should return 1 record');
    }

    @isTest
    static void testGetObjectiveLocationByObjectiveIdsNoDistributedCheck(){
        Objective__c testObjective = getObjective();

        Test.startTest();
            List<Objective_Location__c> objectiveLocationList = ObjectiveLocationDAO.getObjectiveLocationByObjectiveIdsNoDistributedCheck(new Set<Id>{testObjective.Id});
        Test.stopTest();

        System.assertEquals(objectiveLocationList.size(), 1, 'objectiveLocationList should return 1 record');
    }

    @isTest
    static void testGetObjectiveLocationByObjectiveIdsAndBU(){
        Objective__c testObjective = getObjective();

        Test.startTest();
            List<Objective_Location__c> objectiveLocationList = ObjectiveLocationDAO.getObjectiveLocationByObjectiveIdsAndBU(new Set<Id>{testObjective.Id}, 'PVA');
        Test.stopTest();

        System.assertEquals(objectiveLocationList.size(), 1, 'objectiveLocationList should return 1 record');
    }

    @isTest
    static void testUpdateObjectiveLocations(){
        Objective_Location__c testObjectiveLocation = getObjectiveLocation();
        testObjectiveLocation.Goal_Amount__c = 150;

        Test.startTest();
            List<Objective_Location__c> objectiveLocationList = ObjectiveLocationDAO.updateObjectiveLocations(new List<Objective_Location__c>{testObjectiveLocation});
        Test.stopTest();

        System.assertEquals(objectiveLocationList.size(), 1, 'objectiveLocationList should return 1 record');
        System.assertEquals(objectiveLocationList[0].Goal_Amount__c, 150, 'Goal amount should be 150');
    }

    @isTest
    static void testInsertObjectiveLocations(){
        Objective__c testObjective = getObjective();

        Objective_Location__c testObjectiveLocation = new Objective_Location__c();
        testObjectiveLocation.Objective__c = testObjective.Id;
        testObjectiveLocation.BU__c = 'PVA';
        testObjectiveLocation.Warehouse__c = 'PDVA-CHANTILLY';
        testObjectiveLocation.Goal_Amount__c = 200;

        Test.startTest();
            List<Objective_Location__c> objectiveLocationList = ObjectiveLocationDAO.insertObjectiveLocations(new List<Objective_Location__c>{testObjectiveLocation});
        Test.stopTest();

        List<Objective_Location__c> objectiveLocationsReturned = [SELECT Id 
                                                                FROM Objective_Location__c];

        System.assertEquals(objectiveLocationsReturned.size(), 2, 'objectiveLocationList should return 2 records');
    }

    @isTest
    static void testDeleteObjectiveLocations(){
        Objective_Location__c testObjectiveLocation = getObjectiveLocation();

        Test.startTest();
            List<Objective_Location__c> objectiveLocationList = ObjectiveLocationDAO.deleteObjectiveLocations(new List<Objective_Location__c>{testObjectiveLocation});
        Test.stopTest();

        List<Objective_Location__c> objectiveLocationsReturned = [SELECT Id 
                                                                FROM Objective_Location__c];

        System.assertEquals(0, objectiveLocationsReturned.size(), 'objectiveLocationList should return 0 records');
    }
}
@IsTest
private class PlanDAOTest {

    @TestSetup
    private static void setup(){
        TestFactory.createPlan('Test Plan', System.today(), null, String.valueOf(System.today()), '100',
                                null, 'Chicago', '2', 'On Premise', 'Presell', 'PDVA-CHANTILLY');
    }

    static Plan__c getPlan(){
        return [SELECT Id
                FROM Plan__c
                LIMIT 1];
    }

    @isTest
    static void testGetPlansForFilterDate(){

        Test.startTest();
            List<Plan__c> planList = PlanDAO.getPlansForFilterDate(System.today());
        Test.stopTest();

        System.assertEquals(planList.size(), 1, 'planList should return 1 record');
    }

    @isTest
    static void testGetPlansByIds(){
        Plan__c testPlan = getPlan();

        Test.startTest();
            List<Plan__c> planList = PlanDAO.getPlansByIds(new Set<Id>{testPlan.Id});
        Test.stopTest();

        System.assertEquals(planList.size(), 1, 'planList should return 1 record');
    }

    @isTest
    static void testInsertPlans(){
        Plan__c testPlan = new Plan__c();
        testPlan.Name = 'Test Plan';

        Test.startTest();
            List<Plan__c> planList = PlanDAO.insertPlans(new List<Plan__c>{testPlan});
        Test.stopTest();

        System.assertEquals(planList.size(), 1, 'planList should return 1 record');
    }

    @isTest
    static void testUpdatePlans(){
        Plan__c testPlan = getPlan();
        testPlan.Original_Delivery_Date__c = System.today();

        Test.startTest();
            List<Plan__c> planList = PlanDAO.updatePlans(new List<Plan__c>{testPlan});
        Test.stopTest();

        List<Plan__c> plans = [SELECT Id, Original_Delivery_Date__c FROM Plan__c];

        System.assertEquals(plans[0].Original_Delivery_Date__c, System.today(), 'Original delivery date should be today');
    }
}
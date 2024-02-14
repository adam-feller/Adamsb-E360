/**
 * @description       : ObjctiveFilterDAO Test Class
 * @author            : cbraaten@reyesholdings.com
 * @last modified on  : 11-29-2022
 * @last modified by  : cbraaten@reyesholdings.com
**/
@isTest
private class ObjectiveFilterDAOTest {

    @isTest
    static void testGetObjectiveAccountFilters(){
        Test.startTest();
            List<Objective_Filter__mdt> objectiveAccountFilterList = ObjectiveFilterDAO.getObjectiveAccountFilters();
        Test.stopTest();

        System.assertEquals(true, !objectiveAccountFilterList.isEmpty(), 'objectiveAccountFilterList should not be empty');
    }

    @isTest
    static void testGetObjectiveProductFilters(){
        Test.startTest();
            List<Objective_Filter__mdt> objectiveProductFilterList = ObjectiveFilterDAO.getObjectiveProductFilters();
        Test.stopTest();

        System.assertEquals(true, !objectiveProductFilterList.isEmpty(), 'objectiveProductFilterList should not be empty');
    }
}
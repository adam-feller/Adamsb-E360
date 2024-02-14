@isTest
private class BusinessUnitDAOTest {

    @TestSetup
    private static void setup(){
        TestFactory.createBusinessUnit('PVA', 'http://rbdtest:8804', 'pvacrm@reyesholdings.com', 'p850085', 'B13KI');
    }

    @isTest
    static void testGetBusinessUnits(){
        Test.startTest();
        List<Business_Unit__c> businessUnitList = BusinessUnitDAO.getBusinessUnits('PVA');
        Test.stopTest();

        System.assertEquals(businessUnitList.size(), 1, '1 record should be returned');
    }
}
@isTest
private class BUDivisionDAOTest {

    @isTest
    static void testGetBuDivisions(){
        Test.startTest();
            List<BU_Division__mdt> buDivisionList = BUDivisionDAO.getBuDivisions();
        Test.stopTest();

        System.assertEquals(!buDivisionList.isEmpty(), true, 'buDivisionList should not be empty');
    }
}
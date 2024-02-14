@isTest
public class FlaggedProductFrequencyDAOTest {

    @isTest
    static void testGetFlaggedProductFrequencyByCategory(){
        Test.startTest();
            List<Flagged_Product_Frequency__mdt> flaggedFrequencyList = FlaggedProductFrequencyDAO.getFlaggedProductFrequencyByCategory('Weekly');
        Test.stopTest();

        System.assertEquals(!flaggedFrequencyList.isEmpty(), true, 'flaggedFrequencyList should not be empty');
    }
}
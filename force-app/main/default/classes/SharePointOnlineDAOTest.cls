@isTest
public class SharePointOnlineDAOTest {

    @isTest
    static void testgetSharePointDocumentByDocumentTypeChainBUOrStoreNumber() {
        Test.startTest();
            List<items_SharePointOnline__x> result = SharePointOnlineDAO.getSharePointDocumentByDocumentTypeChainBUOrStoreNumber(new List<String>{'Other'}, 'FOOD LION', 'HJL', 'HJL02389', 'PDVA-CHANTILLY', 'On Premise','Controllable', 'CBS');
        Test.stopTest();

        System.assert(result.isEmpty(), 'No Other file found');
    }
}
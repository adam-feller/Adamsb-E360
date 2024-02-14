@isTest
public class BrewforceControllerTest {

    @isTest
    static void testGetSalesforceLicenses() {

        Test.startTest();
        List<Integer> licenses = BrewforceController.getSalesforceLicenses();
        Test.stopTest();
        
        System.assertNotEquals(0, licenses.size(), 'Should return a list of licenses');
    }

    @isTest
    static void testGetExternalLinks() {
        
        Test.startTest();
        List <Brewforce_External_Links__mdt> extLinks = BrewforceController.getExternalLinks();
        Test.stopTest();
        
        System.assertNotEquals(0, extLinks.size(), 'Should return a list of external links');
    }

}
@isTest
private class SearchControllerTest {

    @testSetup
    static void testSetup() {
        TestFactory.createProduct('Test Product', '12345', 'MillerCoors', '123*B');
    }

    @isTest
    static void testRetrieveSearchResults(){
        SearchController.filterSetup filter = new SearchController.filterSetup();
        filter.operator = 'OR';
        filter.fieldAPI = 'SKU__c';
        filter.value = 'Test';
        filter.groupLeft = false;
        filter.groupRight = false;
        filter.eval = null;
        String filters = JSON.serialize(new List<SearchController.filterSetup>{filter});

        Test.startTest();
            List<SearchController.ObjInfo> returnedResults = SearchController.retrieveSearchResults('Test', 'Product2', 'Name', new List<String>{'SKU__c'}, filters);
        Test.stopTest();

        System.assertEquals(returnedResults.size(), 1, '1 record should be returned');
    }

    @isTest
    static void testRetrieveSearchResultsEmpty(){
        SearchController.filterSetup filter = new SearchController.filterSetup();
        filter.operator = 'OR';
        filter.fieldAPI = 'SKU__c';
        filter.value = 'Test';
        filter.groupLeft = false;
        filter.groupRight = false;
        filter.eval = null;
        String filters = JSON.serialize(new List<SearchController.filterSetup>{filter});

        Test.startTest();
            List<SearchController.ObjInfo> returnedResults = SearchController.retrieveSearchResults('Not Found', 'Product2', 'Name', new List<String>{'SKU__c'}, filters);
        Test.stopTest();

        System.assertEquals(returnedResults.size(), 0, '0 records should be returned');
    }
}
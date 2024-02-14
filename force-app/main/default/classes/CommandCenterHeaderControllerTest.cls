/**
 * Created by alexander.velitsky on 1/7/21.
 */

@isTest
private class CommandCenterHeaderControllerTest {

    @isTest
    static void testBehavior() {
        CommandCenterHeaderController.initData();
        CommandCenterHeaderController.overrideUserRoute('04','HJL');
    }
    
    @isTest
    static void testGetHomeLinks() {
        
        Test.startTest();
        List <Beerline_Home_Links__mdt> homeLinks = CommandCenterHeaderController.getBevLineHomeLinks();
        Test.stopTest();
        
        Assert.areNotEqual(0, homeLinks.size(), 'Should return a list of links');
    }
}
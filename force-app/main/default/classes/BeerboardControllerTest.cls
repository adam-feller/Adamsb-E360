@isTest
public class BeerboardControllerTest {
    @TestSetup
    private static void setup(){
        Account testAcc = TestFactory.createAccount('Hooters Test', '235412', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        TestFactory.createBeerboardDraftUtilitySetting('Draft Products','https://api.devbeerboard.io/Drafts', 'AdB665BvXua0XAJdoTQcq5x17ia7MLTaYMBO8iq7');
        TestFactory.createBeerboardDraftUtilitySetting('Not Sold After Purchase','https://api.devbeerboard.io/NotSoldAfterPurchase', 'AdB665BvXua0XAJdoTQcq5x17ia7MLTaYMBO8iq7');
        TestFactory.createBeerboardDraftUtilitySetting('Out Of Code Products','https://api.devbeerboard.io/OutOfCodeProducts', 'AdB665BvXua0XAJdoTQcq5x17ia7MLTaYMBO8iq7');
        TestFactory.createBeerboardDraftUtilitySetting('Mandate Compliance','https://api.devbeerboard.io/MandateCompliance', 'AdB665BvXua0XAJdoTQcq5x17ia7MLTaYMBO8iq7');
    }
    @isTest
    static void testBeerboardCallout200(){
        Account acct2 = [SELECT Id FROM Account WHERE Name='Hooters Test' LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new BeerboardDraftProductsAPIMock());
        Test.startTest();
        List<BeerboardController.draftProductsParser> res = BeerboardController.getBeerboardDraftInfo(acct2.Id);
        BeerboardController.getAccountExternalId(acct2.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testBeerboardNSAPCallout200(){
        Account acct2 = [SELECT Id FROM Account WHERE Name='Hooters Test' LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new BeerboardNSAPAPIMock());
        Test.startTest();
        List<BeerboardController.notSoldAfterPurchaseParser> res = BeerboardController.getBeerboardNotSoldAfterPurchase(acct2.Id);
        BeerboardController.getAccountExternalId(acct2.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testBeerboardOOCCallout200(){
        Account acct2 = [SELECT Id FROM Account WHERE Name='Hooters Test' LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new BeerboardOOCAPIMock());
        Test.startTest();
        List<BeerboardController.outOfCodeProductsParser> res = BeerboardController.getBeerboardOutOfCodeProducts(acct2.Id);
        BeerboardController.getAccountExternalId(acct2.Id);
        Test.stopTest();
    }
    
        @isTest
    static void testBeerboardMCCallout200(){
        Account acct2 = [SELECT Id FROM Account WHERE Name='Hooters Test' LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new BeerboardMCAPIMock());
        Test.startTest();
        List<BeerboardController.mandateComplianceParser> res = BeerboardController.getBeerboardMandateCompliance(acct2.Id);
        BeerboardController.getAccountExternalId(acct2.Id);
        Test.stopTest();
    }
    
}
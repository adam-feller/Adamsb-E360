@isTest
public class FsrmasApiControllerTest {
    @TestSetup
    private static void setup(){
        Account testAcc = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        TestFactory.createMulesoftUtilitySetting('FSR Visit Schedule','https://api-dev.reyesholdings.com/account/accounts/visit-schedule', '/', null, null, null, '123', '123');
    }
    @isTest
    static void testFsrmasCallout200(){
        Account acct2 = [SELECT Id FROM Account WHERE Name='Test Account' LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new FsrmasApiMock());
        Test.startTest();
        List<FsrmasApiController.visitScheduleParser> res = FsrmasApiController.getFsrAccountInfo(acct2.Id);
        Test.stopTest();
    }
    
}
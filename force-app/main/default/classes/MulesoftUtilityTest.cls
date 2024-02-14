@isTest
public class MulesoftUtilityTest {

    @TestSetup
    private static void setup(){
        TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        TestFactory.createMulesoftUtilitySetting('Suggested Sell', 'http://rh-suggested-sell-xapi.us-e2.cloudhub.io/api/suggested-sell', '/', null, null, null, '123', '123');
        TestFactory.createmulesoftSuggestedSellPost('Suggested Sell Feedback', 'http://rh-suggested-sell-xapi.us-e2.cloudhub.io/api/suggested-sellfeedback', '123', '123');
        TestFactory.createMulesoftUtilitySetting('priorityList', 'https://api-uat.reyesholdings.com/priority-product/account', '/', null, null, null, '123', '123');
 
    }
   
    static Account getAccount(){
        return [SELECT Id, Name, VIP_Account_Number__c, Beer_Company__c, Warehouse__c, Store_Number__c,VIP_Instance__c,ExternalId__c
                FROM Account
                LIMIT 1];
    }

    
    @isTest
    static void testMulesoftCallout200(){
        Account testAccount = getAccount();

        HttpResponse res = new HttpResponse();
        res.setBody('{"snapShotDatetime": "2020-06-25T07:30:43.28","productExternalId": "11432*B","customerExternalId": "HJL*20612","displaySequence": 1}');
        res.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));

        Test.startTest();
            HttpResponse result = MulesoftUtility.mulesoftCallout('Suggested Sell', testAccount.Id, null, null);
        Test.stopTest();
        System.debug(result);

      //  System.assertEquals(result.getStatusCode(), 200, 'Status should be 200');
    }

    



    @isTest
    static void testmulesoftSuggestedSellPost(){
        Account testAccount = getAccount();
        Long tmp = 12342;
        Mulesoft_API_Settings__c mulesoftApiSettings = TestFactory.createmulesoftSuggestedSellPost('Suggested Sell Feedback', 'http://rh-suggested-sell-xapi.us-e2.cloudhub.io/api/suggested-sellfeedback', '123', '123');
        HttpResponse res = new HttpResponse();
         res.setBody('{"snapShotDatetime": "2020-06-25T07:30:43.28","productExternalId": "11432*B","customerExternalId": "HJL*20612","displaySequence": 1}');
        res.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));
        Test.startTest();
            res  = MulesoftUtility.mulesoftSuggestedSellPost('Suggested Sell Feedback', 1, '123', '123', 1,'comments',tmp);
        Test.stopTest();
        //System.assertEquals(res.getStatusCode(), 200, 'Status should be 200');
    }

    

    @isTest
    static void testMulesoftCalloutForPriorityData200(){
        Account testAccount = getAccount();
        HttpResponse res = new HttpResponse();
        String priorityListResponseBody = ' { "customerExternalId": "FDI*40891", "priorityProducts": [{ "priorityType": "Controllable Core Product", "productExternalId": 11455, "productContainerType": "Bottle", "productInvoiceDate": "2022-12-23T06:00:00",  "productWarehouseAvailableQty": 8919,  "productOnHandQty": 0.0000,      "suggestionSource": 1,      "suggestionStory": null,      "suggestionScore": 0,      "suggestionDatetime": "2022-09-30T12:36:41.047"    }	  ]}';
        res.setBody(priorityListResponseBody);
        res.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));
        String param1='';
        if (testAccount.VIP_Instance__c != null && testAccount.VIP_Account_Number__c != null){
            //make a call with new priorityList API
             param1= testAccount.ExternalId__c +'/priority-product';
        }
         
        Test.startTest();
            res  = MulesoftUtility.mulesoftCallout('priorityList', param1, testAccount.VIP_Account_Number__c.leftPad(5, '0'), null, null);
        Test.stopTest();
        //System.assertEquals(res.getStatusCode(), 200, 'Status should be 200');
    }

    
    @isTest
    static void testMulesoftCallout400(){
        Account testAccount = getAccount();

        HttpResponse res = new HttpResponse();
        res.setBody('{"snapShotDatetime": "2020-06-25T07:30:43.28","productExternalId": "11432*B","customerExternalId": "HJL*20612","displaySequence": 1}');
        res.setStatusCode(400);

        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));

        Test.startTest();
            HttpResponse result = MulesoftUtility.mulesoftCallout('Suggested Sell', testAccount.Id, null, null);
        Test.stopTest();
        System.debug(result);

        //System.assertEquals(result.getStatusCode(), 400, 'Status should be 400');
    }

    @isTest
    static void testAuth(){
        Account testAccount = getAccount();

        HttpResponse res = new HttpResponse();
        res.setBody('{"snapShotDatetime": "2020-06-25T07:30:43.28","productExternalId": "11432*B","customerExternalId": "HJL*20612","displaySequence": 1}');
        res.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));

        Test.startTest();
            HttpResponse result = MulesoftUtility.mulesoftCallout('Suggested Sell', testAccount.Id, null, null);
        Test.stopTest();
        System.debug(result);

        //System.assertEquals(result.getStatusCode(), 200, 'Status should be 200');
    }
 
   @isTest
    static void testreqAuth(){
        Account testAccount = getAccount();

        HttpResponse res = new HttpResponse();
        res.setBody('{"expires_in": "20","access_token": "11432*B","expire_time": "25"}'); 
        res.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));

        Test.startTest();
             MulesoftUtility.callReqAuth();
        Test.stopTest();
       // System.debug(result);

        //System.assertEquals(result.getStatusCode(), 200, 'Status should be 200');
    }



}
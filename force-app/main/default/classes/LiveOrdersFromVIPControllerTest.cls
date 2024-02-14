@isTest(seealldata=false)
public with sharing class LiveOrdersFromVIPControllerTest {
   

   private  Static String  response = '{"SM":"360","Orders":[{"ServerOrderID":"632121","StatusCode":"Accepted","StatusDesc":"Accepted","SourceDesc":"iOS/PDA (PALMEDIT)","IsEditable":true,"AccountNumber":"L0147","DeliveryDate":20220805,"InvoiceType":"B","ARType":"","TotalPrice":257.96,"OrderDate":20220804,"LineItems":[{"LineNumber":1,"Type":0,"ItemCode":"010327","Quantity":1,"IsUnitQuantity":false,"SourceDesc":"iOS/PDA (PALMEDIT)","OriginalOrderID":"360524271","LastUpdatedTimestamp":"2022-08-04T00.17.23-0500","LastUpdatedUser":"PVAASP","PerformanceDiscount":false,"Price":37.4,"Discount":0,"PostOff":0,"ExtendedPrice":37.4},{"LineNumber":2,"Type":0,"ItemCode":"045952","Quantity":1,"IsUnitQuantity":false,"SourceDesc":"iOS/PDA (PALMEDIT)","OriginalOrderID":"360524271","LastUpdatedTimestamp":"2022-08-04T00.17.23-0500","LastUpdatedUser":"PVAASP","PerformanceDiscount":false,"Price":31.6,"Discount":0,"PostOff":0,"ExtendedPrice":31.6},{"LineNumber":3,"Type":0,"ItemCode":"050936","Quantity":1.00,"IsUnitQuantity":false,"SourceDesc":"iOS/PDA (PALMEDIT)","OriginalOrderID":"360524271","LastUpdatedTimestamp":"2022-08-04T00.17.23-0500","LastUpdatedUser":"PVAASP","PerformanceDiscount":false,"Price":35.18,"Discount":0,"PostOff":0,"ExtendedPrice":35.18},{"LineNumber":4,"Type":0,"ItemCode":"018179","Quantity":1,"IsUnitQuantity":false,"SourceDesc":"iOS/PDA (PALMEDIT)","OriginalOrderID":"360524271","LastUpdatedTimestamp":"2022-08-04T00.17.23-0500","LastUpdatedUser":"PVAASP","PerformanceDiscount":false,"Price":29.4,"Discount":0.62,"PostOff":0,"ExtendedPrice":28.78},{"LineNumber":5,"Type":0,"ItemCode":"012401","Quantity":1,"IsUnitQuantity":false,"SourceDesc":"iOS/PDA (PALMEDIT)","OriginalOrderID":"360524271","LastUpdatedTimestamp":"2022-08-04T00.17.23-0500","LastUpdatedUser":"PVAASP","PerformanceDiscount":false,"Price":95,"Discount":0,"PostOff":0,"Deposit":"30.00","ExtendedPrice":125}]},{"ServerOrderID":"636371","StatusCode":"Accepted","StatusDesc":"Accepted","SourceDesc":"iOS/PDA (PALMEDIT)","IsEditable":true,"AccountNumber":"63637","DeliveryDate":20220805,"InvoiceType":"B","ARType":"B","TotalPrice":768.31,"OrderDate":20220804,"LineItems":[{"LineNumber":1,"Type":0,"ItemCode":"010194","Quantity":2,"IsUnitQuantity":false,"SourceDesc":"iOS/PDA (PALMEDIT)","OriginalOrderID":"360524268","LastUpdatedTimestamp":"2022-08-04T00.11.38-0500","LastUpdatedUser":"PVAASP","PerformanceDiscount":false,"Price":81,"Discount":0,"PostOff":0,"Deposit":30,"ExtendedPrice":222},{"LineNumber":2,"Type":0,"ItemCode":"010224","Quantity":3,"IsUnitQuantity":false,"SourceDesc":"iOS/PDA (PALMEDIT)","OriginalOrderID":"360524268","LastUpdatedTimestamp":"2022-08-04T00.11.38-0500","LastUpdatedUser":"PVAASP","PerformanceDiscount":false,"Price":23.25,"Discount":2.3,"PostOff":0,"ExtendedPrice":62.85},{"LineNumber":3,"Type":0,"ItemCode":"010158","Quantity":2,"IsUnitQuantity":false,"SourceDesc":"iOS/PDA (PALMEDIT)","OriginalOrderID":"360524268","LastUpdatedTimestamp":"2022-08-04T00.11.38-0500","LastUpdatedUser":"PVAASP","PerformanceDiscount":false,"Price":29.4,"Discount":0,"PostOff":0,"ExtendedPrice":58.8},{"LineNumber":4,"Type":0,"ItemCode":"010032","Quantity":1,"IsUnitQuantity":false,"SourceDesc":"iOS/PDA (PALMEDIT)","OriginalOrderID":"360524268","LastUpdatedTimestamp":"2022-08-04T00.11.38-0500","LastUpdatedUser":"PVAASP","PerformanceDiscount":false,"Price":79,"Discount":0,"PostOff":0,"Deposit":30,"ExtendedPrice":109},{"LineNumber":5,"Type":0,"ItemCode":"010037","Quantity":2,"IsUnitQuantity":false,"SourceDesc":"iOS/PDA (PALMEDIT)","OriginalOrderID":"360524268","LastUpdatedTimestamp":"2022-08-04T00.11.38-0500","LastUpdatedUser":"PVAASP","PerformanceDiscount":false,"Price":23.25,"Discount":2.3,"PostOff":0,"ExtendedPrice":41.9},{"LineNumber":6,"Type":0,"ItemCode":"013315","Quantity":6,"IsUnitQuantity":false,"SourceDesc":"iOS/PDA (PALMEDIT)","OriginalOrderID":"360524268","LastUpdatedTimestamp":"2022-08-04T00.11.38-0500","LastUpdatedUser":"PVAASP","PerformanceDiscount":false,"Price":25.46,"Discount":0,"PostOff":0,"ExtendedPrice":152.76},{"LineNumber":7,"Type":0,"ItemCode":"010318","Quantity":2,"IsUnitQuantity":false,"SourceDesc":"iOS/PDA (PALMEDIT)","OriginalOrderID":"360524268","LastUpdatedTimestamp":"2022-08-04T00.11.38-0500","LastUpdatedUser":"PVAASP","PerformanceDiscount":false,"Price":23.75,"Discount":0,"PostOff":0,"ExtendedPrice":47.5},{"LineNumber":8,"Type":0,"ItemCode":"051826","Quantity":1,"IsUnitQuantity":false,"SourceDesc":"iOS/PDA (PALMEDIT)","OriginalOrderID":"360524268","LastUpdatedTimestamp":"2022-08-04T00.11.38-0500","LastUpdatedUser":"PVAASP","PerformanceDiscount":false,"Price":31.6,"Discount":0,"PostOff":0,"ExtendedPrice":31.6},{"LineNumber":9,"Type":0,"ItemCode":"011455","Quantity":2,"IsUnitQuantity":false,"SourceDesc":"iOS/PDA (PALMEDIT)","OriginalOrderID":"360524268","LastUpdatedTimestamp":"2022-08-04T00.11.38-0500","LastUpdatedUser":"PVAASP","PerformanceDiscount":false,"Price":23.25,"Discount":2.3,"PostOff":0,"ExtendedPrice":41.9}]},{"ServerOrderID":"D10521","StatusCode":"Accepted","StatusDesc":"Accepted","SourceDesc":"iOS/PDA (PALMEDIT)","IsEditable":true,"AccountNumber":"D1052","DeliveryDate":20220805,"InvoiceType":"B","ARType":"B","TotalPrice":890.4,"OrderDate":20220803,"LineItems":[{"LineNumber":1,"Type":0,"ItemCode":"011251","Quantity":2,"IsUnitQuantity":false,"SourceDesc":"iOS/PDA (PALMEDIT)","OriginalOrderID":"360524257","LastUpdatedTimestamp":"2022-08-03T23.07.06-0500","LastUpdatedUser":"PVAASP","PerformanceDiscount":false,"Price":19.18,"Discount":0,"PostOff":0,"ExtendedPrice":38.36},{"LineNumber":2,"Type":0,"ItemCode":"011274","Quantity":7,"IsUnitQuantity":false,"SourceDesc":"iOS/PDA (PALMEDIT)","OriginalOrderID":"360524257","LastUpdatedTimestamp":"2022-08-03T23.07.06-0500","LastUpdatedUser":"PVAASP","PerformanceDiscount":false,"Price":23.25,"Discount":2.75,"PostOff":0,"ExtendedPrice":143.5},{"LineNumber":3,"Type":0,"ItemCode":"010235","Quantity":2,"IsUnitQuantity":false,"SourceDesc":"iOS/PDA (PALMEDIT)","OriginalOrderID":"360524257","LastUpdatedTimestamp":"2022-08-03T23.07.06-0500","LastUpdatedUser":"PVAASP","PerformanceDiscount":false,"Price":20.95,"Discount":0,"PostOff":0,"ExtendedPrice":41.9},{"LineNumber":4,"Type":0,"ItemCode":"010216","Quantity":1,"IsUnitQuantity":false,"SourceDesc":"iOS/PDA (PALMEDIT)","OriginalOrderID":"360524257","LastUpdatedTimestamp":"2022-08-03T23.07.06-0500","LastUpdatedUser":"PVAASP","PerformanceDiscount":false,"Price":143,"Discount":5,"PostOff":0,"Deposit":30,"ExtendedPrice":168},{"LineNumber":5,"Type":0,"ItemCode":"010158","Quantity":1,"IsUnitQuantity":false,"SourceDesc":"iOS/PDA (PALMEDIT)","OriginalOrderID":"360524257","LastUpdatedTimestamp":"2022-08-03T23.07.06-0500","LastUpdatedUser":"PVAASP","PerformanceDiscount":false,"Price":29.4,"Discount":0,"PostOff":0,"ExtendedPrice":29.4},{"LineNumber":6,"Type":0,"ItemCode":"010069","Quantity":1,"IsUnitQuantity":false,"SourceDesc":"iOS/PDA (PALMEDIT)","OriginalOrderID":"360524257","LastUpdatedTimestamp":"2022-08-03T23.07.06-0500","LastUpdatedUser":"PVAASP","PerformanceDiscount":false,"Price":17.45,"Discount":0,"PostOff":0,"ExtendedPrice":17.45},{"LineNumber":7,"Type":0,"ItemCode":"010094","Quantity":1,"IsUnitQuantity":false,"SourceDesc":"iOS/PDA (PALMEDIT)","OriginalOrderID":"360524257","LastUpdatedTimestamp":"2022-08-03T23.07.06-0500","LastUpdatedUser":"PVAASP","PerformanceDiscount":false,"Price":19.93,"Discount":0,"PostOff":0,"ExtendedPrice":19.93},{"LineNumber":8,"Type":0,"ItemCode":"010032","Quantity":2,"IsUnitQuantity":false,"SourceDesc":"iOS/PDA (PALMEDIT)","OriginalOrderID":"360524257","LastUpdatedTimestamp":"2022-08-03T23.07.06-0500","LastUpdatedUser":"PVAASP","PerformanceDiscount":false,"Price":79,"Discount":0,"PostOff":0,"Deposit":30,"ExtendedPrice":218},{"LineNumber":9,"Type":0,"ItemCode":"010048","Quantity":7,"IsUnitQuantity":false,"SourceDesc":"iOS/PDA (PALMEDIT)","OriginalOrderID":"360524257","LastUpdatedTimestamp":"2022-08-03T23.07.06-0500","LastUpdatedUser":"PVAASP","PerformanceDiscount":false,"Price":23.25,"Discount":2.75,"PostOff":0,"ExtendedPrice":143.5},{"LineNumber":10,"Type":0,"ItemCode":"011136","Quantity":2,"IsUnitQuantity":false,"SourceDesc":"iOS/PDA (PALMEDIT)","OriginalOrderID":"360524257","LastUpdatedTimestamp":"2022-08-03T23.07.06-0500","LastUpdatedUser":"PVAASP","PerformanceDiscount":false,"Price":35.18,"Discount":0,"PostOff":0,"ExtendedPrice":70.36}]},{"ServerOrderID":"454401","StatusCode":"Accepted","StatusDesc":"Accepted","SourceDesc":"iOS/PDA (PALMEDIT)","IsEditable":true,"AccountNumber":"45440","DeliveryDate":20220811,"InvoiceType":"B","ARType":"B","TotalPrice":184.24,"OrderDate":20220803,"LineItems":[{"LineNumber":1,"Type":0,"ItemCode":"010042","Quantity":1,"IsUnitQuantity":false,"SourceDesc":"iOS/PDA (PALMEDIT)","OriginalOrderID":"08488549","LastUpdatedTimestamp":"2022-08-03T21.41.54-0500","LastUpdatedUser":"PVAASP","PerformanceDiscount":false,"Price":23.18,"Discount":0,"PostOff":0,"ExtendedPrice":23.18},{"LineNumber":2,"Type":0,"ItemCode":"011432","Quantity":2,"IsUnitQuantity":false,"SourceDesc":"iOS/PDA (PALMEDIT)","OriginalOrderID":"08488549","LastUpdatedTimestamp":"2022-08-03T21.41.54-0500","LastUpdatedUser":"PVAASP","PerformanceDiscount":false,"Price":19.18,"Discount":0,"PostOff":0,"ExtendedPrice":38.36},{"LineNumber":3,"Type":0,"ItemCode":"011274","Quantity":3,"IsUnitQuantity":false,"SourceDesc":"iOS/PDA (PALMEDIT)","OriginalOrderID":"08488549","LastUpdatedTimestamp":"2022-08-03T21.41.54-0500","LastUpdatedUser":"PVAASP","PerformanceDiscount":false,"Price":23.25,"Discount":2.75,"PostOff":0,"ExtendedPrice":61.5},{"LineNumber":4,"Type":0,"ItemCode":"010169","Quantity":2,"IsUnitQuantity":false,"SourceDesc":"iOS/PDA (PALMEDIT)","OriginalOrderID":"08488549","LastUpdatedTimestamp":"2022-08-03T21.41.54-0500","LastUpdatedUser":"PVAASP","PerformanceDiscount":false,"Price":30.6,"Discount":0,"PostOff":0,"ExtendedPrice":61.2}]},{"ServerOrderID":"024891","StatusCode":"Accepted","StatusDesc":"Accepted","SourceDesc":"iOS/PDA (PALMEDIT)","IsEditable":true,"AccountNumber":"02489","DeliveryDate":20220811,"InvoiceType":"W","ARType":"B","PurchaseOrder":"VO-846180","TotalPrice":70.36,"OrderDate":20220803,"LineItems":[{"LineNumber":1,"Type":0,"ItemCode":"017460","Quantity":2,"IsUnitQuantity":false,"SourceDesc":"iOS/PDA (PALMEDIT)","OriginalOrderID":"08484793","LastUpdatedTimestamp":"2022-08-03T21.41.47-0500","LastUpdatedUser":"PVAASP","PerformanceDiscount":false,"Price":35.18,"Discount":0,"PostOff":0,"ExtendedPrice":70.36}]},{"ServerOrderID":"L01041","StatusCode":"Accepted","StatusDesc":"Accepted","SourceDesc":"iOS/PDA (PALMEDIT)","IsEditable":true,"AccountNumber":"L0104","DeliveryDate":20220805,"InvoiceType":"B","ARType":"","TotalPrice":260.18,"OrderDate":20220803,"LineItems":[{"LineNumber":1,"Type":0,"ItemCode":"055743","Quantity":1,"IsUnitQuantity":false,"SourceDesc":"iOS/PDA (PALMEDIT)","OriginalOrderID":"254__3168","LastUpdatedTimestamp":"2022-08-03T19.55.19-0500","LastUpdatedUser":"PVAASP","PerformanceDiscount":false,"Price":84,"Discount":0,"PostOff":0,"Deposit":30,"ExtendedPrice":114},{"LineNumber":2,"Type":0,"ItemCode":"038923","Quantity":1,"IsUnitQuantity":false,"SourceDesc":"iOS/PDA (PALMEDIT)","OriginalOrderID":"254__3168","LastUpdatedTimestamp":"2022-08-03T19.55.19-0500","LastUpdatedUser":"PVAASP","PerformanceDiscount":false,"Price":81,"Discount":0,"PostOff":0,"Deposit":30,"ExtendedPrice":111},{"LineNumber":3,"Type":0,"ItemCode":"010168","Quantity":1,"IsUnitQuantity":false,"SourceDesc":"iOS/PDA (PALMEDIT)","OriginalOrderID":"254__3168","LastUpdatedTimestamp":"2022-08-03T19.55.19-0500","LastUpdatedUser":"PVAASP","PerformanceDiscount":false,"Price":35.18,"Discount":0,"PostOff":0,"ExtendedPrice":35.18}]},{"ServerOrderID":"661931","StatusCode":"Accepted","StatusDesc":"Accepted","SourceDesc":"iOS/PDA (PALMEDIT)","IsEditable":true,"AccountNumber":"66193","DeliveryDate":20220808,"InvoiceType":"B","ARType":"B","TotalPrice":63.2,"OrderDate":20220803,"LineItems":[{"LineNumber":1,"Type":0,"ItemCode":"010441","Quantity":2,"IsUnitQuantity":false,"SourceDesc":"iOS/PDA (PALMEDIT)","OriginalOrderID":"241__5750","LastUpdatedTimestamp":"2022-08-03T18.02.10-0500","LastUpdatedUser":"PVAASP","PerformanceDiscount":false,"Price":31.6,"Discount":0,"PostOff":0,"ExtendedPrice":63.2}]}]}';
    
    @testSetup
    private static void setupTestData(){
        TestFactory.createProduct('name', '10327', 'test', '10327');
        TestFactory.createMulesoftUtilitySetting('LiveOrder', 'http://rh-sfdc-price-inventory-xapi-dev.us-e2.cloudhub.io/api/price-inventory', 'accountNumber=', null, null, null, '123', '123');
    }
    
    
    @isTest
    public static void liveOrderGoodResponseTest(){
     //Positive Scenario
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(response);
        res.setStatusCode(200);
        
        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));
        
        Test.startTest();
        LiveOrdersFromVIPController.getLiveOrders('ac123','test');
        Test.stopTest(); 
    }
    
    @isTest
    public static void liveOrderBadResponseTest(){
        //Negative Scenario if the api response status code is 400
        HttpResponse res = new HttpResponse();
        res.setStatusCode(400);
        
        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));
        
        Test.startTest();
        LiveOrdersFromVIPController.getLiveOrders('ac123','123');
        Test.stopTest();
    }
    
    
    @isTest
    public static void liveOrderExceptionTest(){
        //Negative Scenario, if the mulesoft API Settings doesn't exists
        Mulesoft_API_Settings__c mulesoftAPI = Mulesoft_API_Settings__c.getValues('LiveOrder');
        delete mulesoftAPI;
        
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        
        Test.setMock(HttpCalloutMock.class, new MulesoftAPIMock(res));
        
        Test.startTest();
        LiveOrdersFromVIPController.getLiveOrders('ac123','123');
        Test.stopTest();
    }
 
}
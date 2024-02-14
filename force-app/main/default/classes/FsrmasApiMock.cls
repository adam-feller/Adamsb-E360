@isTest
global with sharing class FsrmasApiMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('[ { "id": "GBX*ZJ130", "salesman2": "FSR71", "visitType": "CQ", "deliveryDay": 2, "deliveryWeek": 9, "visitWindow": "Evening" } ]');
        response.setStatusCode(200);
        system.debug(response.getBody());
        return response; 
    }
}
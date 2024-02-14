@isTest
global with sharing class BeerboardOOCAPIMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('[ {"VIPNumber":"20829","ChainStoreNumber":1189,"Customer":"HOOTERS-HOA-SOUTH DIV","Location":"Kissimmee East","Distributor":"Florida Distributing Company LLC","Product":"Funky Buddha Floridian","supplierProductSKU":"32737","purchasedate":"2022-02-08T00:00:00.000Z","dayDiff":71} ]');
        response.setStatusCode(200);
        system.debug(response.getBody());
        return response; 
    }
}
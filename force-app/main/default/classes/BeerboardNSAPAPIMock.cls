@isTest
global with sharing class BeerboardNSAPAPIMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('[ {"Customer":"HOOTERS-HOA-SOUTH DIV","ChainStoreNumber":1189,"id":11346,"VIPNumber":"20829","Location":"Kissimmee East","Distributor":"Florida Distributing Company LLC","Type":"Package","Product":"Heineken","ProductSKU":"10294","Size":"12oz Bottle","PurchaseDate":"2021-12-27T00:00:00.000Z"} ]');
        response.setStatusCode(200);
        system.debug(response.getBody());
        return response; 
    }
}
@isTest
global with sharing class BeerboardMCAPIMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('[{"VIPNumber":"20829","ChainStoreNumber":1189,"Customer":"HOOTERS-HOA-SOUTH DIV","Location":"Kissimmee East","Distributor":"Florida Distributing Company LLC","Product":"New Belgium Voodoo Ranger Juicy Haze IPA","supplierProductSKU":"38924","BeerType":"Draft"} ]');
        response.setStatusCode(200);
        system.debug(response.getBody());
        return response; 
    }
}
@isTest
global with sharing class BeerboardDraftProductsAPIMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('[ { "VIPNumber": "23541", "ChainStoreNumber": 1017, "Customer": "HOOTERS-HOA-SOUTH DIV", "Location": "Kirkman Road", "Distributor": "Florida Distributing Company LLC", "Brewery": "Blue Moon Brewing Company", "Product": "Blue Moon Belgian White", "Style": "Belgian Wit", "ProductSKU": "10194" } ]');
        response.setStatusCode(200);
        system.debug(response.getBody());
        return response; 
    }
}
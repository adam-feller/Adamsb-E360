@isTest
global with sharing class PowerBiReportIdMock implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest request) {
        String dt = DateTime.now().format('YYYY-MM-dd');
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"PowerBiEmbedToken": {"token":2, "tokenId":"2","expiration": "2021-10-25"}}');
        response.setStatusCode(200);
        return response; 
    }
}
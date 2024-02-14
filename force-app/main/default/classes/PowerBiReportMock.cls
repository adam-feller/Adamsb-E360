@isTest
global with sharing class PowerBiReportMock implements HttpCalloutMock{

    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"PowerBiReport": {"id":2, "reportType":"2","name":"5", "webUrl":"abc", "embedUrl":"2","isFromPbix":false, "isOwnedByMe":false,"datasetId":"12"}}');
        response.setStatusCode(200);
        return response; 
    }
}
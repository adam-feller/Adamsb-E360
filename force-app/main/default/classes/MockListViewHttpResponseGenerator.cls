@isTest
global class MockListViewHttpResponseGenerator implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {
        
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"query":"SELECT Id, Subject FROM Task"}');
        res.setStatusCode(200);
        return res;
    }
}
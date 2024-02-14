@isTest
global with sharing class PowerBiAccessTokenMock implements HttpCalloutMock{
   
    global HTTPResponse respond(HTTPRequest request) {
        
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"ClientCredentialResponse": {"access_token":2, "expires_in":"2","ext_expires_in":"5", "token_type":"abc"}}');
        response.setStatusCode(200);
        return response; 
    }



}
@isTest
global with sharing class PowerBiEmbedManagerMock implements HttpCalloutMock{

    Map<string, HttpCalloutMock> multiRequestMap;
    
    global PowerBiEmbedManagerMock(Map<string, HttpCalloutMock> requests){
        this.multiRequestMap = requests;
    }

    public void addRequestMock(String url, HttpCalloutMock mock){
        multiRequestMap.put(url,mock);
    }

    global HTTPResponse respond(HTTPRequest request) {
        HttpCalloutMock mock = multiRequestMap.get(request.getEndpoint());
        if(mock != null){
            return mock.respond(request);
        }
        return null;
       
    }
}
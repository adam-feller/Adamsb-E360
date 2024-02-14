public with sharing class BeerboardUtility {
    

    public static HttpResponse BeerboardCallout(String apiCalloutType, String body) {
        Beerboard_API_Settings__c BeerboardAPI = Beerboard_API_Settings__c.getValues(apiCalloutType);
        String endpoint = BeerboardAPI.Endpoint__c;
        endpoint = endpoint + '?token=' + BeerboardAPI.Tokenid__c;
        endpoint = endpoint + '&vipnumber=' + body;
 
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);   
//        request.setHeader('Content-Type', 'application/json');
        request.setMethod('GET');
        
        request.setTimeout(120000);
        return http.send(request);
    }
}
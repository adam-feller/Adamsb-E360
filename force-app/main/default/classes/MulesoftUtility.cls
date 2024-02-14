public with sharing class MulesoftUtility {
    private static final string AZURE_SESSION_VAR = 'AZURESESSION1';
    public static HttpResponse mulesoftCallout(String apiCalloutType, String param1, String param2, String param3) {
        return mulesoftCallout (apiCalloutType, param1,  param2,  param3, null);
    }
    public static HttpResponse mulesoftCallout(String apiCalloutType, String param1, String param2, String param3, String body) {
        Mulesoft_API_Settings__c mulesoftAPI = Mulesoft_API_Settings__c.getValues(apiCalloutType);
        String endpoint = mulesoftAPI.Endpoint__c;
        //Pradeep priority-product api call
        if(mulesoftAPI.param1__c != null && param1 != null){
            if(mulesoftAPI.param1__c == 'priority-product'){
                System.debug('#### param1 '+param1);
                endpoint += '/'+ param1;
            }else{
                endpoint +=  mulesoftAPI.param1__c + param1;
            }
           
        }
        if(mulesoftAPI.param2__c != null && param2 != null){
            System.debug('#### param1 '+param1);
            endpoint += '&' + mulesoftAPI.param2__c + param2;
        }
        if(mulesoftAPI.param3__c != null && param3 != null){
            endpoint += '&' + mulesoftAPI.param3__c + param3;
        }
        if(mulesoftAPI.param4__c != null){
            endpoint += mulesoftAPI.param4__c;
        }
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setHeader('client_id', mulesoftAPI.Client_Id__c);
        request.setHeader('client_secret', mulesoftAPI.Client_Secret__c);
        addMulesoftAuthentication(request);
        if(body != null){
            request.setHeader('Content-Type', 'application/json');
            request.setBody(body);
            request.setMethod('POST');
        } else {
            request.setMethod('GET');
        }
        request.setTimeout(120000);
        HttpResponse res = new HttpResponse();
       // if(!Test.isRunningTest()){
            res = http.send(request);
        //}
        return res;
    }

    private class AuthWrapper{
        Integer expires_in;
        String access_token;
        Datetime expire_time;
    }
    
    private static HttpRequest addMulesoftAuthentication(HttpRequest req){
        AuthWrapper auth = getAuthenticationToken();
        req.setHeader('Authorization','Bearer '+auth.access_token);
        System.debug(auth.access_token);
        return req;
    }

    private static AuthWrapper getAuthenticationToken(){
        if(!Test.isRunningTest()){
            AuthWrapper auth = (AuthWrapper) Cache.Org.get(AuthInfoCache.class, AZURE_SESSION_VAR);
            if (auth == null || auth.access_token == null || auth.expire_time == null || Datetime.now() > auth.expire_time){
                auth = requestAzureAuthToken();
                Cache.Org.put(AZURE_SESSION_VAR, auth, auth.expires_in-100);
            }
            return auth;
        } else {
            AuthWrapper auth = new AuthWrapper();
            auth.access_token = 'asdi124lafubwWRWY123124';
            //requestAzureAuthToken();
            return auth;
        }
    }

    class AuthInfoCache implements Cache.CacheBuilder {
        public Object doLoad(String Session) {
            return requestAzureAuthToken();
        }
    }
 
   private static AuthWrapper requestAzureAuthToken() {
        String developerName = '';
        Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        if(isSandbox){
            developerName = 'Azure_Dev';
        } else {
            developerName = 'Azure_Prod';
        }

        AuthProvider AP = [SELECT ConsumerKey, ConsumerSecret, DefaultScopes, DeveloperName, TokenUrl FROM AuthProvider WHERE DeveloperName = :developerName];
        String postData = 'grant_type=client_credentials&client_id=' + AP.ConsumerKey + '&scope=' + AP.DefaultScopes + '&client_secret=' + AP.ConsumerSecret;
        HttpRequest req = new HttpRequest();
        req.setEndpoint(AP.TokenUrl);
        req.setMethod('POST');
        req.setBody(postData);
        req.setTimeout(20000);
        Http http = new Http();
        HttpResponse res = http.send(req);
        	System.debug('### mulesoftUtility requestAzureAuthToken res.getBody() ### '+res.getBody());
            AuthWrapper ac = null;
            //if(!Test.isRunningTest())
        		ac = (AuthWrapper) JSON.deserialize(res.getBody(), AuthWrapper.class);
        if(ac.expires_in != null)
        	ac.expire_time = Datetime.now().addSeconds(ac.expires_in);
        return ac;
    }

    
    public static void callReqAuth(){
        requestAzureAuthToken();
    }

    public static HttpResponse mulesoftSuggestedSellPost(String apiCalloutType, Integer feedbackDateSID, String customerID, String productID, Integer feedbackCD, String comment, Long timestamp) {


        Mulesoft_API_Settings__c mulesoftAPI = Mulesoft_API_Settings__c.getValues(apiCalloutType);
        String endpoint = mulesoftAPI.Endpoint__c;
        JSONGenerator suggestedSellJSON = JSON.createGenerator(true);
        suggestedSellJSON.writeStartObject();
        suggestedSellJSON.writeNumberField('feedbackDateSID',feedbackDateSID);
        suggestedSellJSON.writeStringField('customerID',customerID);   
        suggestedSellJSON.writeStringField('productID',productID);   
        suggestedSellJSON.writeNumberField('feedbackCD',feedbackCD);   
        suggestedSellJSON.writeStringField('comment',comment);   
        suggestedSellJSON.writeNumberField('timestamp', timestamp); 
        String jsonString = suggestedSellJSON.getAsString();
        system.debug('Suggested Sell Feedback' + jsonString);      
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setHeader('client_id', mulesoftAPI.Client_Id__c);
        request.setHeader('client_secret', mulesoftAPI.Client_Secret__c);
        addMulesoftAuthentication(request);
        request.setBody(jsonString);
        request.setMethod('POST');
        HttpResponse response = new HttpResponse();
       // if(!Test.isRunningTest())
             response = http.send(request); 
        return response;
    }
}
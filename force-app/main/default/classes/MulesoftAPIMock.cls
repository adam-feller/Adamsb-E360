@isTest
public class MulesoftAPIMock implements HttpCalloutMock{
    HttpResponse mulesoftResponse;

    public MulesoftAPIMock(HttpResponse response) {
        mulesoftResponse = response;
    }

    public HttpResponse respond(HttpRequest mulesoftReq) {
        return mulesoftResponse;
    }
}
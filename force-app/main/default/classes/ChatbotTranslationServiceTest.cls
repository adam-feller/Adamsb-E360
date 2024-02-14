@isTest
private class ChatbotTranslationServiceTest {
    static final String tokenEndpoint = 'https://sso.transperfect.com/connect/token';
    static final String serviceEndpoint = 'https://gl-aiportal.translations.com/apigateway/texttranslator?from=en&to=es&textType=text';

    @testSetup
    private static void setup() {
        LiveChatVisitor chasitor = new LiveChatVisitor();
        insert chasitor;

        LiveChatTranscript transcript = new LiveChatTranscript(
            LiveChatVisitorId = chasitor.Id,
            ChatKey = 'ChatbotTranslationServiceTest1234'
        );
        insert transcript;
    }

    @isTest
    private static void testTranslateChat() {
        SingleRequestMock tokenResp = new SingleRequestMock(200,
                                                         'OK',
                                                         '{"access_token":"eyJhbGciOiJSUzI1NiIsImtpZCI6IkU4MTY2QjA0RDlBQTI5RTlFRURDNkU2QTk1RUNGNzgxMzMyQzcwNTAiLCJ0eXAiOiJKV1QiLCJ4NXQiOiI2QlpyQk5tcUtlbnUzRzVxbGV6M2dUTXNjRkEifQ'
                                                            + '.' + 'eyJuYmYiOjE2MTc3MTgyMDQsImV4cCI6MTYxNzcxOTEwNCwiaXNzIjoiaHR0cHM6Ly9zc28tc3RnLnRyYW5zcGVyZmVjdC5jb20iLCJhdWQiOlsiaHR0cHM6Ly9zc28tc3RnLnRyYW5zcGVyZmVjdC5jb20vcmVzb3VyY2VzIiwiR0xBSVBvcnRhbCJdLCJjbGllbnRfaWQiOiJSYU5hNkI0YXJtYVFhM1FzM2ozdWo5VkM1YkJLZzZkdyIsInNjb3BlIjpbIkdMQUlQb3J0YWwiXX0'
                                                            + '.' + 'YPExh7Ma6N-SBU0zenrgrPukGRi"}',
                                                         null);
 
        SingleRequestMock translationResp = new SingleRequestMock(200,
                                                  'OK',
                                                  '{"message" : [{"Text":"Hola, mundo","detectedLanguage":"en","TXLFPath":null,"translated":false}], "success" : true}',
                                                   null);
 
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.put(tokenEndpoint, tokenResp);
        endpoint2TestResp.put(serviceEndpoint, translationResp);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        String translatedStr = ChatbotTranslationService.translateChat('en', 'es', 'Hello world', 'ChatbotTranslationServiceTest1234');
        Test.stopTest();

        System.assertEquals('Hola, mundo', translatedStr);
    }

    @isTest
    private static void testExpiredToken() {
        LiveChatTranscript transcript = [
            SELECT Id, Translation_Access_Token__c
            FROM LiveChatTranscript
            LIMIT 1
        ];
        transcript.Translation_Access_Token__c = 'eyJhbGciOiJSUzI1NiIsImtpZCI6IkU4MTY2QjA0RDlBQTI5RTlFRURDNkU2QTk1RUNGNzgxMzMyQzcwNTAiLCJ0eXAiOiJKV1QiLCJ4NXQiOiI2QlpyQk5tcUtlbnUzRzVxbGV6M2dUTXNjRkEifQ'
                                                    + '.' + 'eyJuYmYiOjE2MTc3MTgyMDQsImV4cCI6MTYxNzcxOTEwNCwiaXNzIjoiaHR0cHM6Ly9zc28tc3RnLnRyYW5zcGVyZmVjdC5jb20iLCJhdWQiOlsiaHR0cHM6Ly9zc28tc3RnLnRyYW5zcGVyZmVjdC5jb20vcmVzb3VyY2VzIiwiR0xBSVBvcnRhbCJdLCJjbGllbnRfaWQiOiJSYU5hNkI0YXJtYVFhM1FzM2ozdWo5VkM1YkJLZzZkdyIsInNjb3BlIjpbIkdMQUlQb3J0YWwiXX0'
                                                    + '.' + 'YPExh7Ma6N-SBU0zenrgrPukGRi';
        update transcript;

        SingleRequestMock tokenResp = new SingleRequestMock(200,
                                                         'OK',
                                                         '{"access_token":"eyJhbGciOiJSUzI1NiIsImtpZCI6IkU4MTY2QjA0RDlBQTI5RTlFRURDNkU2QTk1RUNGNzgxMzMyQzcwNTAiLCJ0eXAiOiJKV1QiLCJ4NXQiOiI2QlpyQk5tcUtlbnUzRzVxbGV6M2dUTXNjRkEifQ'
                                                            + '.' + 'eyJuYmYiOjE2MTc3MTgyMDQsImV4cCI6MTYxNzcxOTEwNCwiaXNzIjoiaHR0cHM6Ly9zc28tc3RnLnRyYW5zcGVyZmVjdC5jb20iLCJhdWQiOlsiaHR0cHM6Ly9zc28tc3RnLnRyYW5zcGVyZmVjdC5jb20vcmVzb3VyY2VzIiwiR0xBSVBvcnRhbCJdLCJjbGllbnRfaWQiOiJSYU5hNkI0YXJtYVFhM1FzM2ozdWo5VkM1YkJLZzZkdyIsInNjb3BlIjpbIkdMQUlQb3J0YWwiXX0'
                                                            + '.' + 'YPExh7Ma6N-SBU0zenrgrPukGRi"}',
                                                         null);
 
        SingleRequestMock translationResp = new SingleRequestMock(401,
                                                  'Unauthorized',
                                                  '{"message" : "Access token not valid", "success" : false}',
                                                   null);
 
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.put(tokenEndpoint, tokenResp);
        endpoint2TestResp.put(serviceEndpoint, translationResp);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        String translatedStr = ChatbotTranslationService.translateChat('en', 'es', 'Hello world', 'ChatbotTranslationServiceTest1234');
        Test.stopTest();
    }
}
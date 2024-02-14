public without sharing class ChatbotTranslationService {
    private static String authToken;
    private static Translation_API_Configuration__mdt connectionDetails;
    
    @AuraEnabled
    public static String translateChat(String sourceLanguageCode, String targetLanguageCode, String textToTranslate, String chatKey) {
        String toReturn = '';

        // Get API details
        connectionDetails = [
            SELECT Id,
                   DeveloperName,
                   MasterLabel,
                   Client_Id__c,
                   Client_Secret__c,
                   Grant_Type__c,
                   Auth_Endpoint__c,
                   API_Endpoint__c
            FROM Translation_API_Configuration__mdt 
            WHERE DeveloperName = 'TransPerfect_OAuth2'
            LIMIT 1
        ];

        // Get access token if it exists. If not, get a new token.
        LiveChatTranscript transcript = [
            SELECT Id,
                   Translation_Access_Token__c
            FROM LiveChatTranscript
            WHERE ChatKey = :chatKey
            LIMIT 1
        ];
        if (String.isNotEmpty(transcript.Translation_Access_Token__c)) {
            authToken = transcript.Translation_Access_Token__c;
        } else {
            getNewToken();
        }

        // Create request
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndPoint(connectionDetails.API_Endpoint__c + '?from=' + sourceLanguageCode + '&to=' + targetLanguageCode + '&textType=text');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + authToken);
        req.setBody('[{"Text": "' + textToTranslate + '"}]');

        // Call endpoint and parse translation into return variable
        try {
            HTTPResponse resp = http.send(req);
            if (resp.getStatusCode() == 200) {
                // Handle successful callout
                TextTranslationResponseDTO dto = (TextTranslationResponseDTO)JSON.deserialize(resp.getBody(), TextTranslationResponseDTO.class);
                if (dto.success = true) {
                    toReturn = dto.message[0].Text;
                }

                // Write token to transcript
                writeTokenOnTranscript(chatKey, authToken);
            } else if (resp.getStatusCode() == 401) {
                // Renew expired token
                getNewToken();

                // Make callout again
                req.setHeader('Authorization', 'Bearer ' + authToken);
                resp = http.send(req);
                if (resp.getStatusCode() == 200) {
                    TextTranslationResponseDTO dto = (TextTranslationResponseDTO)JSON.deserialize(resp.getBody(), TextTranslationResponseDTO.class);
                    if (dto.success = true) {
                        toReturn = dto.message[0].Text;
                    }
                    // Write token to transcript
                    writeTokenOnTranscript(chatKey, authToken);
                } else {
                    System.debug('TRANSLATION ERROR----');
                    System.debug('ERROR_STATUS_CODE: '+ resp.getStatusCode());
                    System.debug('ERROR_STATUS: '+ resp.getStatus());
                    System.debug('ERROR_RESPONSE_BODY: '+ resp.getBody());
                }
            } else {
                // Display error in debug logs
                System.debug('TRANSLATION ERROR----');
                System.debug('ERROR_STATUS_CODE: '+ resp.getStatusCode());
                System.debug('ERROR_STATUS: '+ resp.getStatus());
                System.debug('ERROR_RESPONSE_BODY: '+ resp.getBody());
            }
        } catch (Exception e) {
            System.debug('Aura Error in TransPerfect Translation Callout: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }

        return toReturn;
    }

    private static void getNewToken() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(connectionDetails.Auth_Endpoint__c + '/token');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setBody('client_id=' + connectionDetails.Client_Id__c
                        + '&client_secret=' + connectionDetails.Client_Secret__c
                        + '&grant_type=' + connectionDetails.Grant_Type__c);

        try {
            HTTPResponse resp = http.send(request);
            if (resp.getStatusCode() == 200) {
                // Handle successful callout
                Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(resp.getBody());
                authToken = String.valueOf(results.get('access_token'));
            } else {
                // Display error in debug logs
                System.debug('AUTH ERROR----');
                System.debug('ERROR_STATUS_CODE: '+ resp.getStatusCode());
                System.debug('ERROR_STATUS: '+ resp.getStatus());
                System.debug('ERROR_RESPONSE_BODY: '+ resp.getBody());
            }
        } catch (Exception e) {
            System.debug('Aura Error in TransPerfect Auth Callout: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static void writeTokenOnTranscript(String chatKey, String authToken) {
        LiveChatTranscript transcript = [
            SELECT Id,
                   Translation_Access_Token__c
            FROM LiveChatTranscript
            WHERE ChatKey = :chatKey
            LIMIT 1
        ];

        transcript.Translation_Access_Token__c = authToken;
        update transcript;
    }
}
public class ChatbotTranslationResponse {
    @InvocableMethod(label = 'Translate Bot Response')
    public static List<TranslationOutput> getChatbotTranslation(List<TranslationInput> inputToTranslate) {
        List<TranslationOutput> listOfTranslations = new List<TranslationOutput>();
        TranslationOutput to = new TranslationOutput();
        String language = getLanguage(inputToTranslate[0].languageCode);
        String translation = getCachedBotResponse(inputToTranslate[0].associatedDialog, language);

        if (translation != null) {
            to.translation = translation;
            listOfTranslations.add(to);
        }
        
        return listOfTranslations;
    }

    public static String getCachedBotResponse(String dialog, String language) {
        String response = '';
        String strQuery = 'SELECT Id, ' + language + '_Asset__c '
                          + 'FROM Bot_Translation_Asset__mdt '
                          + 'WHERE Asset_Type__c = \'Response\' '
                          + 'AND Dialog__c = \'' + dialog + '\' '
                          + 'LIMIT 1';
        List<Bot_Translation_Asset__mdt> lstBTA = Database.query(strQuery);

        if (lstBTA.size() > 0) {
            response = (String)lstBTA[0].get(language + '_Asset__c');
        }
        
        return response;
    }

    private static String getLanguage(String languageCode){
        Map<String, String> languageCodeMap = new Map<String, String>{
            'en' => 'English',
            'es' => 'Spanish'
        };

        return languageCodeMap.get(languageCode);
    }

    public class TranslationInput {
        @InvocableVariable(required=true)
        public String languageCode;
        @InvocableVariable(required=true)
        public String associatedDialog;
    }

    public class TranslationOutput {
        @InvocableVariable(required=true)
        public String translation;
    }
}
public class ChatbotGetMenus {
    @InvocableMethod(label='Translate Bot Menu')
    public static List<List<MenuOutput>> getMenus(List<MenuInput> input) {
        List<List<MenuOutput>> toReturn = new List<List<MenuOutput>>();
        List<MenuOutput> lstOutput = new List<MenuOutput>();
        String language = getLanguage(input[0].languageCode);

        // Get CMT asset
        String strQuery = 'SELECT Id, English_Asset__c, Menu_Order__c';
        if (language != 'English') {
            strQuery += ', ' + language + '_Asset__c';
        }
        strQuery += ' FROM Bot_Translation_Asset__mdt '
                    + 'WHERE Asset_Type__c = \'Menu\' '
                    + 'AND Dialog__c = \'' + input[0].associatedDialog + '\' '
                    + 'ORDER BY Menu_Order__c ASC';

        for (Bot_Translation_Asset__mdt bta : Database.query(strQuery)) {
            MenuOutput output = new MenuOutput();
            output.englishChoice = bta.English_Asset__c;
            output.translatedChoice = (String)bta.get(language + '_Asset__c');
            lstOutput.add(output);
        }
        toReturn.add(lstOutput);
        
        return toReturn;
    }

    private static String getLanguage(String languageCode){
        Map<String, String> languageCodeMap = new Map<String, String>{
            'en' => 'English',
            'es' => 'Spanish'
        };

        return languageCodeMap.get(languageCode);
    }

    public class MenuInput {
        @InvocableVariable(required=true)
        public String languageCode;
        @InvocableVariable(required=true)
        public String associatedDialog;
    }

    public class MenuOutput {
        @InvocableVariable(required=true)
        public String englishChoice;
        @InvocableVariable(required=true)
        public String translatedChoice;
    }
}
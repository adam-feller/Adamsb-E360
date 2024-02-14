@isTest
private class SurveyRedirectControllerTest {
    @isTest
    private static void testConstructor() {
        LiveChatVisitor chasitor = new LiveChatVisitor();
        insert chasitor;

        LiveChatTranscript englishTranscript = new LiveChatTranscript(
            LiveChatVisitorId = chasitor.Id,
            Language__c = 'en',
            ChatKey = 'SurveyRedirectControllerTest1234',
            Survey_URL__c = 'https://isrconfig1-reyes.cs125.force.com/service/survey/runtimeApp.app?invitationId=0Ki3K00000005odSAA&surveyName=chatbot_customer_satisfaction&UUID=61a2196e-64be-4424-88e7-a96e30e7dee1&guestUserLang=en'
        );
        insert englishTranscript;

        PageReference pageRef = Page.SurveyRedirectPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('chatKey', 'SurveyRedirectControllerTest1234');
        SurveyRedirectController englishTest = new SurveyRedirectController();

        LiveChatTranscript spanishTranscript = new LiveChatTranscript(
            LiveChatVisitorId = chasitor.Id,
            Language__c = 'es',
            ChatKey = 'SurveyRedirectControllerTest5678',
            Survey_URL__c = 'https://isrconfig1-reyes.cs125.force.com/service/survey/runtimeApp.app?invitationId=0Ki3K00000005odSAA&surveyName=chatbot_customer_satisfaction&UUID=61a2196e-64be-4424-88e7-a96e30e7dee1&guestUserLang=es'
        );
        insert spanishTranscript;

        ApexPages.currentPage().getParameters().put('chatKey', 'SurveyRedirectControllerTest5678');
        SurveyRedirectController spanishTest = new SurveyRedirectController();
    }
}
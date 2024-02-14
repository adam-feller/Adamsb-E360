public without sharing class SurveyRedirectController {
    public String surveyURL {get; set;}
    public String titleLabel {get; set;}
    public String buttonLabel {get; set;}

    public SurveyRedirectController(){
        LiveChatTranscript transcript = [SELECT Id, Survey_URL__c, Language__c, ChatKey FROM LiveChatTranscript WHERE ChatKey = : ApexPages.currentPage().getParameters().get('chatKey')];
        surveyURL = transcript.Survey_URL__c;

        if (transcript.Language__c == 'en') {
            titleLabel = 'We\'d love to hear from you!';
            buttonLabel = 'Start Survey';
        } else if (transcript.Language__c == 'es') {
            titleLabel = '¡Nos encantaría recibir noticias suyas!';
            buttonLabel = 'Iniciar encuesta';
        }
    }
}
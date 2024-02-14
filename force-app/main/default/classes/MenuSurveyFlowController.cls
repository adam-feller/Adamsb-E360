public class MenuSurveyFlowController {
    @InvocableMethod(label='Clone Files')
    public static void cloneContentVersion(List<cloneFileRequest> input) {
        List<List<String>> newDocumentIds = new List<List<String>>();
        List<String> newDocumentId = new List<String>();
        List<ContentVersion> docs = new List<ContentVersion>();
        List<ContentDocumentLink> links = new List<ContentDocumentLink>();

        for(ContentVersion doc: input[0].files){
            ContentVersion img = new ContentVersion();
            img.ContentLocation = doc.ContentLocation;
            img.PathOnClient = doc.PathOnClient;
            img.Title = doc.Title;
            img.VersionData = doc.VersionData;
            docs.add(img);
        }

        if(docs.size()>0){
            insert docs;
            List<Id> ids = new List<Id>();
            for(ContentVersion c: docs){
                ids.add(c.Id);
            }
            List<ContentVersion> newFiles = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :ids];

            for(ContentVersion d: newFiles){
                ContentDocumentLink link = New ContentDocumentLink();
                link.LinkedEntityId = input[0].surveyId; 
                link.ContentDocumentId = d.ContentDocumentId; 
                link.shareType = 'I';
                links.add(link);
            }
            insert links;
        }
    }
    public class cloneFileRequest {
        
        @InvocableVariable
        public String surveyId;

        @InvocableVariable
        public List<ContentVersion> files;
    }
}
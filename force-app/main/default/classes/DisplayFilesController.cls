public class DisplayFilesController {
	@AuraEnabled
   	public static List<ContentVersion> getContents(String recordId) {
	    Set<Id> contentIds = new Set<Id>();
        //SOQL query to get pictures from object
        for (ContentDocumentLink cont :[SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =:recordId]) {
    	    contentIds.add(cont.ContentDocumentId);
        }
    	return [SELECT Id, Title FROM ContentVersion WHERE ContentDocumentId IN :contentIds];
    }
    
    @AuraEnabled
	public static void postFeed(Id recordId, String body){
        //Get the Task
        Task tsk = [SELECT Id, CreatedById FROM Task WHERE Id =:recordId LIMIT 1];
        //Post the Chatter message
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
		ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
		ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
		messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
		mentionSegmentInput.id = tsk.CreatedById;
        messageBodyInput.messageSegments.add(mentionSegmentInput);
        textSegmentInput.text = ' ' + body;
        messageBodyInput.messageSegments.add(textSegmentInput);
        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = tsk.Id;
        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
	}
        
}
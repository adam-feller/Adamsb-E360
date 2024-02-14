global class DownloadPhotos {
	public String recordId {get; set;} 
    public String accountId {get; set;} 
    
	public DownloadPhotos(){    
	    recordId = ApexPages.CurrentPage().getParameters().get('Id');
       	//Get Account Id
	    accountId = [SELECT Id, Account__r.Id FROM Merch_Checklist__c WHERE Id =:recordId].Account__r.Id;      
 	}
    
    /*Function to check whether there are any photos*/
	@AuraEnabled   
 	public static Boolean getTasksHavePhotos(String recId) {
 		List<Task> taskList = [SELECT Id FROM Task WHERE Merch_Checklist__c =:recId];
        List<Id> taskIds = new List<Id>();
        for (Task t : taskList) {
            taskIds.add(t.Id);
        }
        if (taskIds.size() > 0) {
			List<ContentDocumentLink> contentLinks = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN :taskIds];
 			if(contentLinks.size() > 0) {
		 		return true;
		 	} else {
		 		return false;
		 	}
        } else {
            return false;
        }
 	}
    
 	/*Function to fetch the attachments related to the Record*/
 	@RemoteAction
 	public static List<PhotoWrapper> getPhotos(String recId){ 
        //Get Files
	    List<PhotoWrapper> lstPhotoWrapper = new List <PhotoWrapper>();
	    //Get All the Merch Tasks Associated with this Merch Checklist
	    List<Task> taskList = [SELECT Id FROM Task WHERE Merch_Checklist__c =:recId];
        List<Id> taskIds = new List<Id>();
        for (Task t : taskList) {
            taskIds.add(t.Id);
        }
		List<ContentDocumentLink> contentLinks = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN :taskIds];
	    Set<Id> conIds = new Set<Id>();
	    for (ContentDocumentLink lk : contentLinks) {
	         conIds.add(lk.ContentDocumentId);
	    }    
		List<ContentDocument> cdList = [SELECT Id FROM ContentDocument WHERE Id IN :conIds];
	    Set<Id> cdIds = (new Map<Id,ContentDocument>(cdList)).keySet();
	     
	    List<ContentVersion> contentVersions = [SELECT Id, Title, FileExtension, VersionData FROM ContentVersion WHERE ContentDocumentId IN :cdIds AND IsLatest = True];
        Integer cnt = 1;
	    for (ContentVersion cv : contentVersions) {
	        PhotoWrapper wrapper = new PhotoWrapper();            
	 		wrapper.photoName = cv.Title + ' (' + cnt + ').' + cv.FileExtension;
	        Blob b = cv.VersionData;
	 		wrapper.photoEncodedBody = EncodingUtil.base64Encode(b);
	 		lstPhotoWrapper.add(wrapper);
            cnt += 1;
	     }    
	 	return lstPhotoWrapper;
 	}
	       	    
 	/*Wrapper Class which holds the Name and Body of Attachments*/
 	public class PhotoWrapper {
		public String photoEncodedBody {get; set;}
	 	public String photoName {get; set;}
 	}	    
}
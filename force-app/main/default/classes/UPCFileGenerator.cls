public class UPCFileGenerator { 
    public id recId{get; set;}
    public string imageBody {get; set;}
    public boolean removeText {get; set;}
    private Product2 prod;
    private static String fileTitle = 'UPC Codes';
    
    public UPCFileGenerator(ApexPages.StandardController stdController) {
        recId = stdController.getRecord().Id;
        prod = (Product2)stdController.getRecord();
    }
     
    public void generateFile()
    {
        Product2 pr  = [SELECT id, UPCLastModifiedDate__c FROM Product2 WHERE id =: recId]; //That can queried before the generation of new code.
        List<ContentDocument> cdListToDelete = new List<ContentDocument>();
        boolean isNewUPC = false; //will generate new UPC image only if one of the UPC codes was changed (need to create corresponding flow or trigger, only the field now.);
		boolean noFilesFound = true;//Go through all the fields marked as UPC code.
        for(ContentDocumentLink cdl : (List<ContentDocumentLink>) [Select ContentDocument.Id, ContentDocument.LatestPublishedVersion.ContentModifiedDate, Id,LinkedEntityId 
                                       FROM ContentDocumentLink 
                                       WHERE LinkedEntityId =: recId AND ContentDocument.LatestPublishedVersion.is_UPC_Code__c = true]){
           cdListToDelete.add(cdl.ContentDocument);
           noFilesFound = false;
           //Look if there are UPCCode changes made after the last UPC file was created;
           if (pr.UPCLastModifiedDate__c == null || pr.UPCLastModifiedDate__c  > cdl.ContentDocument.LatestPublishedVersion.ContentModifiedDate){
               isNewUPC = true;
           }
        }
    	try {
            if (isNewUPC) delete cdListToDelete;    
        } catch (Exception ex){
            system.debug(ex);//check that there is no ownership issues for non admin users. If there are any -  play with cdl.ShareType and cdl.Visibility below;
        }
        if (isNewUPC || noFilesFound){
            ContentVersion fileContentVersion = new ContentVersion();
            fileContentVersion.Title = fileTitle;
            fileContentVersion.VersionData = EncodingUtil.base64Decode(imageBody.replaceFirst('data:image/png;base64,',''));
            fileContentVersion.PathOnClient = fileTitle+'.png';
            fileContentVersion.is_UPC_Code__c = true;
            insert fileContentVersion;  // Salesforce Creates a ContentDocument record for you when you create a first version of a file, but you need to get ContentDocumentId to associate this file with salesforce record.
 

         	fileContentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :fileContentVersion.Id];
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = fileContentVersion.ContentDocumentId;
            cdl.LinkedEntityId = recId; // that would be the record id you want assosiate it with
            cdl.ShareType = 'I';  //This drives who sees the file "I' means that everyone who has read access to a record will see it.
            cdl.Visibility = 'AllUsers';
            insert cdl;
        }
    }
	
}
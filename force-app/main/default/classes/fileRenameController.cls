public with sharing class fileRenameController {

    @AuraEnabled
    public static void uploadPhotos(String fileName, String fileType, String base64Data, String recordId){
        Id tempId = recordId;
        system.debug('Object Name: ' + tempId.getSObjectType().getDescribe().getName());
        if(tempId.getSObjectType().getDescribe().getName() == 'Objective_Submission__c'){
            List<ContentDocumentLink> previousCDLs = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];
            if(previousCDLs !=null){
                List<ContentDocument> cdsToDelete = new List<ContentDocument>();
                for(ContentDocumentLink cdl : previousCDLs){
                    ContentDocument cd = new ContentDocument();
                    cd.Id = cdl.ContentDocumentId;
                    cdsToDelete.add(cd);
                }
                delete cdsToDelete;
            }
        }
        
        ContentVersion img = new ContentVersion();
        img.ContentLocation = 'S';
        img.PathOnClient = '/' + fileName + '.' + fileType.substring(fileType.indexOf('/') + 1);
        img.Title = fileName;
        img.VersionData = EncodingUtil.base64Decode(base64Data); 
        insert img;

        Id imgId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:img.Id].ContentDocumentId;
            
        ContentDocumentLink parentLink = New ContentDocumentLink();
        parentLink.LinkedEntityId = recordId; 
        parentLink.ContentDocumentId = imgId; 
        parentLink.shareType = 'I';
        insert parentLink;
    }

}

//A potential future solution to handle image replacement for Feature and Reset objective completions would be to grab images uploaded by using the flow start time.
//Separate the images into 2 lists of previous uploads and current uploads using the flow start time
//To differentiate between current images for situations that require 2 uploads for submission would be to check the title of the CV
//For Example with Resets, If the title of the current CV being uploaded .contains('BEFORE') check if the current uploads list has a CV that .contains('BEFORE')
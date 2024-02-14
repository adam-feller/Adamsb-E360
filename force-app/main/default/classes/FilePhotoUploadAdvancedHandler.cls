public class FilePhotoUploadAdvancedHandler {

    @AuraEnabled  
    public static List<ContentDocument> getFiles(String recordId, string filecategory){ 
        Set<Id> recordIds = new Set<Id>{recordId};
        String filecatvar = '%' + filecategory + '%';
        List<ContentDocumentLink> cdlList = [SELECT Id, LinkedEntityId, ContentDocumentId FROM 
                                             ContentDocumentLink WHERE LinkedEntityId IN :recordIds
                                             AND ContentDocument.Title LIKE :filecatvar
                                            ];                         
        Set<Id> documentIds = new Set<Id>(); 
        for(ContentDocumentLink cdl:cdlList){  
            documentIds.add(cdl.ContentDocumentId);  
        }    
        return [SELECT Id, Title, FileType FROM ContentDocument WHERE Id IN :documentIds];        
    } 
    
    @AuraEnabled  
    public static void deleteFile(String contentDocumentId){ 
        delete [SELECT Id from ContentDocument WHERE Id = :contentDocumentId];       
    }  
    
    @AuraEnabled
    public static void uploadPhotos(String fileName, String fileType, String base64Data, String recordId){
        Id tempId = recordId;
        
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
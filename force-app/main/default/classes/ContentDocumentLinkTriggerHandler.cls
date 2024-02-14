public without sharing class ContentDocumentLinkTriggerHandler {

    public static void handleContentDocumentLinks(List<ContentDocumentLink> cdls){
        try{
            Set<Id> parentIds = new Set<Id>();
            for (ContentDocumentLink cdl : cdls){
                String IdString = String.valueof(cdl.LinkedEntityId);
                if(!(IdString.startsWith('001')) && !(IdString.startsWith('005'))) {
                    parentIds.add(cdl.LinkedEntityId);
                }
            }

            if(!parentIds.isEmpty()){
                for (List<Product2> products : [ SELECT Id, ( SELECT ContentDocumentId,ContentDocument.LatestPublishedVersionId,
                                                Id,IsDeleted,LinkedEntityId,ShareType,SystemModstamp,Visibility 
                                                FROM ContentDocumentLinks WHERE ContentDocument.LatestPublishedVersion.is_UPC_Code__c = True 
                                                ORDER BY SystemModStamp desc LIMIT 1)
                                                FROM Product2 WHERE Id IN :parentIds ]){
                    //query content version id based on content document
                    for(Product2 p : products){
                        for(ContentDocumentLink cdl : p.contentDocumentLinks){
                            p.Version_Id__c = cdl.ContentDocument.LatestPublishedVersionId;
                        }
                    }
                    update products;
                }
            }
        } catch(Exception ex){
            ErrorLog.insertErrorLog(ex.getMessage(), String.valueOf(ex.getLineNumber()), 'ContentDocumentLinkTriggerHandler', 'handleContentDocumentLinks');
        }
    }
}
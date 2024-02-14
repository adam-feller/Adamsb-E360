public with sharing class ContentDocumentLinkDAO {

    public static List<ContentDocumentLink> getContentDocumentLinkByAccountId(Set<Id> accountIds){
        return [SELECT Id, ContentDocumentId 
                FROM ContentDocumentLink 
                WHERE LinkedEntityId IN :accountIds
                AND ContentDocument.LatestPublishedVersion.ExternalDocumentInfo2 = NULL
                ORDER BY ContentDocument.CreatedDate];
    }

    public static List<ContentDocumentLink> getContentDocumentLinkExternalIdAndAccountId(Id accountId, Set<String> externalIds){
                return [SELECT Id, ContentDocumentId, ContentDocument.LatestPublishedVersion.ExternalDocumentInfo2, ContentDocument.LatestPublishedVersion.Title, ContentDocument.LatestPublishedVersion.Description,ContentDocument.Title, ContentDocument.Description, ContentDocument.LatestPublishedVersion.DocumentType__c 
                FROM ContentDocumentLink 
                WHERE LinkedEntityId = :accountId
                AND ContentDocument.LatestPublishedVersion.ExternalDocumentInfo2 IN :externalIds];
    }

    public static List<ContentDocumentLink> insertContentDocumentLinks(List<ContentDocumentLink> contentDocumentLinksToInsert){
        insert contentDocumentLinksToInsert;
        return contentDocumentLinksToInsert;
    }
}
public with sharing class ContentVersionDAO {

    public static List<ContentVersion> getContentVersionByDataSourceAndExternalIdsSet(String externalDataSourceId, Set<String> externalIds){
        return [SELECT Id, ContentDocumentId, ExternalDocumentInfo2, Title, Description, DocumentType__c
                FROM ContentVersion 
                WHERE ExternalDataSourceId = :externalDataSourceId 
                AND ExternalDocumentInfo2 IN :externalIds];
    }

    public static List<ContentVersion> insertContentVersions(List<ContentVersion> contentVersionsToInsert){
        insert contentVersionsToInsert;
        return contentVersionsToInsert;
    }
}
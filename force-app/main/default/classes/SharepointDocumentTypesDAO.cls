public without sharing class SharepointDocumentTypesDAO {

    public static List<Sharepoint_Document_Types__c> getSharepointDocumentTypeValues(String documentCategory) {
        return [SELECT Name, Sharepoint_Document_Types__c
                FROM Sharepoint_Document_Types__c
                WHERE Name = :documentCategory];
    }
}
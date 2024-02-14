public class ObjectiveDisplayPhotosController {

    /**
     * Class is used to gather photos to be displayed in ObjectiveDisplayPhotos.vfp
     * 
     * @author Christy Braaten
     */

    public Objective_Submission__c objDisplay {get; set;}
    
    //Get the Record ID passed in url
    private final Id recordId = ApexPages.currentPage().getParameters().get('id');

    public ObjectiveDisplayPhotosController() {
        objDisplay = [SELECT Id, Account_Name__c, Objective_Name__c, Qualifier_Notes__c,
                      (SELECT Id, ContentDocumentId, ContentDocument.LatestPublishedVersionId 
                      FROM ContentDocumentLinks)
                      FROM Objective_Submission__c
                      WHERE Id = :recordId 
                      ORDER BY CreatedDate];
    }

}
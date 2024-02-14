public class MerchChecklistPDFController {

    /**
     * Class is used to gather data to be displayed in MerchChecklistPDF.vfp
     **/

    public List<Task> tasks {get; set;}
    public Merch_CheckLIst__c merchCL {get; set;}
    
    //Get the URL Parameters passed in
    private final String merchId = ApexPages.currentPage().getParameters().get('id');
        
    
    public MerchChecklistPDFController() {
		merchCL = [SELECT Id, Name, OwnerId, Owner.Name, Requested_Completion_Date__c, Account__r.Name FROM Merch_Checklist__c WHERE Id =: merchId LIMIT 1];        
        tasks = [SELECT Id, Subject, Task_Details__c, Account__r.Name, Location__c, Product__r.Name, OwnerId, Owner.Name, Description, Status,
                (SELECT Id, ContentDocumentId, ContentDocument.LatestPublishedVersionId FROM Task.ContentDocumentLinks)
                FROM Task WHERE Merch_Checklist__c = :merchId ORDER BY CreatedDate ASC];                
    }
}
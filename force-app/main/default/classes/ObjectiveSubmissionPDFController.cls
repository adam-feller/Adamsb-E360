public class ObjectiveSubmissionPDFController {

    /**
     * Class is used to gather data to be used in ObjectiveSubmissionPDF.vfp
     **/

    public List<Objective_Submission__c> getApprovedObjectiveSubmissions {get;set;}
    public Objective__c getParentObjective {get;set;}
    
    //Get the record's Id Object Name
    private final Id recordId = ApexPages.currentPage().getParameters().get('id');
    private final String objectName = recordId.getSobjectType().getDescribe().getName();
    private final String objectType = ApexPages.currentPage().getParameters().get('Name');

    public ObjectiveSubmissionPDFController() {
        if (objectName == 'Objective__c') {
            getParentObjective = [SELECT Id, Objective_Type__c, Name, Start_Date__c, End_Date__c FROM Objective__c WHERE Objective__c.Id = :recordId];
            getApprovedObjectiveSubmissions = [SELECT ID, CreatedDate, Objective_Account__r.Objective__c, Objective_Account__r.Objective__r.Name,  
                                                    Objective_Account__r.Account__r.VIP_Account_Number__c, Objective_Account__r.Account__r.Name,
                                                    Objective_Account__r.Account__r.Address__c, Objective_Account__r.Account__r.Owner.Name,
                                                    Objective_Account__r.Objective__r.CreatedDate, How_many_cases_are_on_display__c,Display_Location__c,Feature_POC__c,
                                                    (SELECT ID, ContentDocumentId, ContentDocument.LatestPublishedVersionId FROM Objective_Submission__c.ContentDocumentLinks)
                                                    FROM Objective_Submission__c
                                                    WHERE Status__c = 'Approved' AND Objective_Account__r.Objective__c = :recordId 
                                                    ORDER BY Objective_Account__r.Account__r.Owner.Name ASC];
        } else if (objectName == 'Objective_Location__c') {            
            getApprovedObjectiveSubmissions = [SELECT ID, CreatedDate, Objective_Account__r.Objective__c, Objective_Account__r.Objective__r.Name,  
                                                    Objective_Account__r.Account__r.VIP_Account_Number__c, Objective_Account__r.Account__r.Name,
                                                    Objective_Account__r.Account__r.Address__c, Objective_Account__r.Account__r.Owner.Name,
                                                    Objective_Account__r.Objective__r.CreatedDate, How_many_cases_are_on_display__c,Display_Location__c,Feature_POC__c,
                                                    (SELECT ID, ContentDocumentId, ContentDocument.LatestPublishedVersionId FROM Objective_Submission__c.ContentDocumentLinks)
                                                    FROM Objective_Submission__c
                                                    WHERE Status__c = 'Approved' AND Objective_Account__r.Objective_Location__c = :recordId
                                                    ORDER BY Objective_Account__r.Account__r.Owner.Name ASC];

            Objective_Location__c currentObjectiveLocation = [SELECT Objective__c FROM Objective_Location__c WHERE Objective_Location__c.Id = :recordId LIMIT 1];
            String parentObjectiveId = currentObjectiveLocation.Objective__c;
            getParentObjective = [SELECT Id, Name, Start_Date__c, End_Date__c FROM Objective__c WHERE Objective__c.Id = :parentObjectiveId LIMIT 1];
            
        }
        
    }
}
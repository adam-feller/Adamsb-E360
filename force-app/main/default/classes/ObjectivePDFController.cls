public class ObjectivePDFController {

    /**
     * Class is used to gather data to be displayed in ObjectivePDF.vfp
     **/

    public List<Objective_Submission__c> getApprovedObjectiveSubmissions {get; set;}
    public Date startDate {get; set;}
    public Date endDate {get; set;}
    public String startSalesRepIds {get; set;}
    
    //Get the URL Parameters passed from the Flow
    private final List<String> objIds = ApexPages.currentPage().getParameters().get('ids').split(';');
    private final List<String> locations = ApexPages.currentPage().getParameters().get('locations').split(';');
    private final String strStartDate = ApexPages.currentPage().getParameters().get('startDate');
    private final String strEndDate = ApexPages.currentPage().getParameters().get('endDate');
    private final List<String> salesReps = ApexPages.currentPage().getParameters().get('salesReps').split(';');
        
    
    public ObjectivePDFController() {
        startDate = Date.valueOf(strStartDate);
        endDate = Date.valueOf(strEndDate);
        List<Objective_Submission__c> objSubmissions = new List<Objective_Submission__c>();
		objSubmissions = [SELECT Id, CreatedDate, Number_of_Photos__c, Objective_Account__c, Objective_Account__r.Objective__c, Objective_Account__r.Objective__r.Name,  
               	                                    Objective_Account__r.Account__r.VIP_Account_Number__c, Objective_Account__r.Account__r.Name,
	                                                Objective_Account__r.Account__r.Address__c, Objective_Account__r.Account__r.Owner.Name, Objective_Account__r.Account__r.Owner.Id, 
                              						Objective_Account__r.Account__r.VIP_Instance__c, Objective_Account__r.Account__r.SalesOrg__c, Objective_Account__r.Account__r.Warehouse__c,
	                                                Objective_Account__r.Objective__r.CreatedDate, How_many_cases_are_on_display__c,Display_Location__c,Feature_POC__c,
	                                                (SELECT Id, ContentDocumentId, ContentDocument.LatestPublishedVersionId FROM Objective_Submission__c.ContentDocumentLinks)
	                                                FROM Objective_Submission__c
	                                                WHERE Status__c = 'Approved' AND Objective_Account__r.Objective__c IN :objIds 
	                                                ORDER BY Objective_Account__r.Objective__r.Name, Objective_Account__r.Account__r.Owner.Name, CreatedDate ASC];  

        //Now make sure the Objectives meet the Location and Submitter criteria		
		getApprovedObjectiveSubmissions = new List<Objective_Submission__c>();
		String strLocKey = '';
        for (Objective_Submission__c os : objSubmissions) {            
            strLocKey = os.Objective_Account__r.Account__r.VIP_Instance__c + ' / ' + os.Objective_Account__r.Account__r.SalesOrg__c + ' / ' + os.Objective_Account__r.Account__r.Warehouse__c;
            Date compareDate = os.CreatedDate.Date();            
            if (locations.contains(strLocKey) && salesReps.contains(os.Objective_Account__r.Account__r.Owner.Id) && compareDate>=startDate && compareDate<=endDate) {
				getApprovedObjectiveSubmissions.add(os);
            }
        }     
                
        //Set which record Ids start a Sales Rep (New Page)
        String currentSalesRep = '';
        startSalesRepIds = '';
        for (Objective_Submission__c os : getApprovedObjectiveSubmissions) {
            if (os.Objective_Account__c <> null) {
            	if (os.Objective_Account__r.Account__r.Owner.Name <> currentSalesRep) {
	                startSalesRepIds += ';' + os.Id;
	                currentSalesRep = os.Objective_Account__r.Account__r.Owner.Name;
	            }
            }
        }
    }
}
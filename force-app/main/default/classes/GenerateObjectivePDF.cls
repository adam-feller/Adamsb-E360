public class GenerateObjectivePDF {
	@InvocableMethod
	public static List<FlowOutputs> createPDF(List<FlowInputs> req) {
        List<FlowOutputs> responses = new List<FlowOutputs>();
		ContentVersion v;
        //*****Create the PDF File*****
		//Remove supervisors from the list
        List<String> tempSalesReps = req[0].salesReps.split(';');
        String newSalesReps = '';
        for (String s : tempSalesReps) {
            if (!s.contains('supv:')) {
                if (newSalesReps != '') {
                	newSalesReps += ';' + s;
                } else {
                    newSalesReps = s;
                }
            }
        }
        PageReference pdfRef = new PageReference('/apex/ObjectivePDF?&ids=' + req[0].objectiveIds + '&locations=' + req[0].locations + '&startDate=' + req[0].startDate + '&endDate=' + req[0].endDate + '&salesReps=' + newSalesReps);
        Blob file;
        if (Test.IsRunningTest()) {
            file = Blob.valueOf('UNIT.TEST');
        } else {
           file = pdfRef.getContentAsPDF();
        }          
            
       	//See if there is already a Draft Created
       	String dtTitle = Date.today().format().replaceAll('/','-');
       	String queryDate = '%' + dtTitle;
       	String objectiveId = req[0].objectiveIds.split(';')[0];
       	
        //Delete any previously created PDF files
        List<ContentDocumentLink> cdlList = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =:objectiveId];
       	if (cdlList.size() > 0) {
			delete cdlList;
       	}
        
       	//Insert the File
       	v = new ContentVersion();
       	v.versionData = file;
       	v.title = 'Objective PDF_' + dtTitle;
       	v.pathOnClient = 'Objective PDF_' + dtTitle + '.pdf';
       	v.IsMajorVersion = true;
	    insert v;
       	//Link to the Objective
       	ContentDocumentLink cdl = new ContentDocumentLink();
		cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: v.Id].ContentDocumentId;
        cdl.LinkedEntityId = objectiveId;
        cdl.ShareType = 'I';
        insert cdl;
        
        //Requery the Document        
        List<ContentDocumentLink> cdlList1 = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =:objectiveId AND ContentDocument.title LIKE :queryDate];
        FlowOutputs res = new FlowOutputs();
		if (cdlList1.size() > 0) {
	       	res.pdfId = cdlList1[0].ContentDocumentId;
        } else {
            res.pdfId = '';
        }
        responses.add(res);
	    return responses;
    }
    
    //Input variables
    public class FlowInputs {
        @InvocableVariable(label='Objectives')
        public String objectiveIds;
        @InvocableVariable(label='Locations')
        public String locations;
        @InvocableVariable(label='Start Date')
        public String startDate;
        @InvocableVariable(label='End Date')
        public String endDate;
        @InvocableVariable(label='Sales Reps')
        public String salesReps;
    }
    
    //Output variables
    public class FlowOutputs {
        @InvocableVariable()
        public String pdfId;
    }	
}
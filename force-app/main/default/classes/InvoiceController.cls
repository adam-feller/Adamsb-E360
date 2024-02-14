public without sharing class InvoiceController {

    //Called by the invoiceSendSelection LWC, retrieves the past 90 days of invoices and display in a table.  The user can click a "Select" button next
    //to the one they want to send to the customer
    @AuraEnabled(cacheable=true)
    public static InvoiceDataWrapper getInvoiceData(String recordId) {
        List<Account> accountList = AccountDAO.getAccountsByIds(new Set<Id>{recordId});
        InvoiceDataWrapper invoiceData = new InvoiceDataWrapper();
        invoiceData.accountName = accountList[0].Name;
        invoiceData.accountNumber = accountList[0].VIP_Account_Number__c;
        invoiceData.externalId = accountList[0].ExternalId__c;
        //Get Invoices for this Customer for the past 90 days
        Id invoiceOrderRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Invoice').getRecordTypeId();
        List<Order> invoiceList = OrderDAO.getInvoiceOrderDetailsbyAccountDateRange(new Set<Id>{recordId}, 100, System.today()-90, invoiceOrderRecordTypeId);
        if (invoiceList.size() > 0) {
            List<InvoiceDetails> invoiceDetailsList = new List<InvoiceDetails>();
        	for (Order invoice : invoiceList) {                
                InvoiceDetails invoiceDetails = new InvoiceDetails();
                InvoiceDetails.id = invoice.Id;
                invoiceDetails.invoiceNumber = invoice.Invoice_Number__c;
                invoiceDetails.invoiceDate = invoice.Invoice_Date__c.addDays(1);
                invoiceDetails.invoiceURL = invoice.Invoice_Url__c;
                invoiceDetails.totalNetPrice = invoice.Total_Net_Price__c;
				invoiceDetailsList.add(invoiceDetails);
        	}
            invoiceData.invoiceList = invoiceDetailsList;
            invoiceData.invoiceError = null;
        } else {
            invoiceData.invoiceList = null;
            invoiceData.invoiceError = 'No Invoices found in past 90 days.';
        }    
        return invoiceData;
    }
    
    //Called by the Send_View_Invoice component to clean up any temp invoices
    @AuraEnabled
    public static void deleteTempInvoiceFiles(Id recordId) {
        //Get the Account
        List<Account> accountList = AccountDAO.getAccountsByIds(new Set<Id>{recordId});
        //Get any Temp Invoice Files created for this Account
        String tempFileName = 'Invoice_' + accountList[0].ExternalId__c;
        List<ContentDocument> tempFileList = [SELECT Id FROM ContentDocument WHERE Title = :tempFileName];
        if (tempFileList.size() > 0) {
            delete tempFileList;        
        }
    }
        
    @InvocableMethod(label='Send Invoice to Customer')
	public static void sendInvoiceToCustomer(List<InputVariables> inputVariables) {
        Id contactId = inputVariables.get(0).contactId;
        Id invoiceId = inputVariables.get(0).invoiceId;
        Order invoice = [SELECT Id, Invoice_Date__c, Invoice_URL__c, Invoice_Number__c, Account.ExternalId__c FROM Order WHERE Id =:invoiceId];
        if (contactId != null) {
            //User is sending invoice to the customer
        	Contact contact = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Id =: contactId];
        	Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        	//Send from org wide email address
        	OrgWideEmailAddress owea = new OrgWideEmailAddress();
        	owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName='SipMarket'];
        	if (owea != null) {
				message.setOrgWideEmailAddressId(owea.Id);
			}
	        message.setUseSignature(false);
	        message.setBccSender(false);
	        message.setSaveAsActivity(false); 
	        EmailTemplate emailTemplate = [SELECT Id, Subject, Description, HtmlValue, Body, DeveloperName FROM EmailTemplate WHERE DeveloperName = 'Send_Invoice_To_Customer'];
    	    if (emailTemplate != null) {    
	            //Need to replace the values on the template
                if (contact.FirstName != null) {
	            	emailTemplate.Body = emailTemplate.Body.replace('{!Contact.FirstName}', contact.FirstName);            
                } else {
                   emailTemplate.Body = emailTemplate.Body.replace('{!Contact.FirstName}', contact.LastName);  
                }
	        	//Comments are entered in the flow
	            if (inputVariables.get(0).comments != null) {
	                emailTemplate.Body = emailTemplate.Body.replace('{!comments}', inputVariables.get(0).comments);
	            }
	            message.setSubject(emailTemplate.Subject);
                message.setPlainTextBody(emailTemplate.Body);
	        	message.toAddresses = new String[] {contact.Email};
	            //Create the attachment to send in the email            
				String imagedataURL = 'https://www.sipmarket.com/AccountOrdersBlock/GetInvoice?url=' + EncodingUtil.urlEncode(invoice.Invoice_URL__c, 'UTF-8');            
				HttpRequest req = new HttpRequest();
				req.setEndpoint(imagedataURL);
				req.setMethod('GET');
				req.setTimeout(120000);
				Http binding = new Http();
				HttpResponse res = binding.send(req); 
				Blob image = res.getBodyAsBlob();
	            Messaging.EmailFileAttachment att = new Messaging.EmailFileAttachment();            
	            att.setFileName('Invoice_' + invoice.Invoice_Number__c + '_' + invoice.Account.ExternalId__c + '.pdf');
	            att.setBody(image);
	            message.setFileAttachments(new Messaging.EmailFileAttachment[]{att});
	        	//Send the email
	            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};                
	            Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
	            List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Id = :userinfo.getProfileId() LIMIT 1];
	            if (isEmailTurnedOn()) {   //Need to check for test environments
	                //Only send email from a sandbox if the current user is a System Administrator
	                if (!isSandbox || (isSandbox && profiles[0].Name == 'System Administrator')) {
	        			Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
	        			if (results[0].success) {
				            System.debug('The email was sent successfully.');
				        } else {
				            System.debug('The email failed to send: ' +  results[0].errors[0].message);
				 		}
	                }
	            }
            }
        } else {
            //User wants to view the invoice          
			String imagedataURL = 'https://www.sipmarket.com/AccountOrdersBlock/GetInvoice?url=' + EncodingUtil.urlEncode(invoice.Invoice_URL__c, 'UTF-8');            
			HttpRequest req = new HttpRequest();
			req.setEndpoint(imagedataURL);
			req.setMethod('GET');
			req.setTimeout(120000);
			Http binding = new Http();
			HttpResponse res = binding.send(req); 
			Blob image = res.getBodyAsBlob();
            //Create a temporary file
            String tempFileName = 'Invoice_' + invoice.Account.ExternalId__c;
            ContentVersion objCV = new ContentVersion(Title = tempFileName, PathOnClient = 'invoice.pdf', VersionData = image);
			insert objCV;
			objCV = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: objCV.Id];
			ContentDocumentLink objCDL = new ContentDocumentLink(ContentDocumentId = objCV.ContentDocumentId, LinkedEntityId = invoiceId, Visibility = 'AllUsers');
			insert objCDL;
        }        
    }
       
    public static Boolean isEmailTurnedOn() {
        try {
            Messaging.reserveSingleEmailCapacity(0);
            return true;
        } catch (System.NoAccessException e) {
            return false;        
        }
    }   
    
    public class InvoiceDataWrapper {
        @AuraEnabled
        public String accountName{ get; set; }        
        @AuraEnabled
        public String accountNumber{ get; set; }   
        @AuraEnabled
        public String externalId{ get; set; }
        @AuraEnabled
        public List<InvoiceDetails> invoiceList{ get; set; }
        @AuraEnabled
        public String invoiceError{ get; set; }        
    }

	public class InvoiceDetails {
		@AuraEnabled
        public String id;
        @AuraEnabled
        public String invoiceNumber;
        @AuraEnabled
        public Date invoiceDate;
        @AuraEnabled
        public String invoiceURL;
        @AuraEnabled
        public Double totalNetPrice;
    }
    
    public class InputVariables {
        @InvocableVariable
        public Id contactId;
        @InvocableVariable
        public Id invoiceId;
        @InvocableVariable
        public String comments;
    }
}
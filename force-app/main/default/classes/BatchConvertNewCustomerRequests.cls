public class BatchConvertNewCustomerRequests implements Database.Batchable<sObject>, Database.AllowsCallouts {
    public String query;
    
    public BatchConvertNewCustomerRequests() {
        
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Lead> ncrList) {
        try{
            //*****************************************************'
            // GO THROUGH THE NCRs NEEDING STATUS UPDATE/CONVERSION
            //*****************************************************'            
            //JSON of Employee Numbers to be passed in NCR Status Update Callout
            JSONGenerator ncrJSON = JSON.createGenerator(true);
            ncrJSON.writeStartArray();
            
            Set<Id> reqByIds = new Set<Id>();
            Map<Id,User> usermap;
            for (Lead ncr : ncrList) {
                if(string.valueOf(ncr.OwnerId).startsWith('005')){
                    reqByIds.add(ncr.OwnerId);
                }
            }
            usermap = new Map<Id,User>([Select id,FederationIdentifier, profile.name from User where id IN: reqByIds]);
            
            for (Lead ncr : ncrList) {
                ncrJSON.writeStartObject();
                if(string.valueOf(ncr.OwnerId).startsWith('00G')){
                    if(ncr.Requested_For__c != null){
                        ncrJSON.writeStringField('employeeNumber', ncr.Requested_For__r.FederationIdentifier);
                    }
                }else{
                    String profileName ='';
                    if(usermap != null && usermap.containsKey(ncr.OwnerId)){
                        profileName =  usermap.get(ncr.OwnerId).profile.name;
                    }
                    
                    String callCenterProfiles =System.label.CallCenterProfileNames;
                    List<String> callCenterProfileList = callCenterProfiles.split(',');
                    if(callCenterProfileList.contains(profileName) && ncr.Requested_For__c != null && ncr.Requested_For__r.FederationIdentifier != null){
                        ncrJSON.writeStringField('employeeNumber', ncr.Requested_For__r.FederationIdentifier);
                    }else if(usermap != null && usermap.containsKey(ncr.OwnerId)){
                        ncrJSON.writeStringField('employeeNumber', usermap.get(ncr.OwnerId).FederationIdentifier);    
                    }
                }
                
                ncrJSON.writeEndObject();
            }
            ncrJSON.writeEndArray();
            String jsonString = ncrJSON.getAsString();    
            
            HttpResponse ncrResponse = new HttpResponse();
            ncrResponse = MulesoftUtility.mulesoftCallout('New Customer Request Status', null, null, null, jsonString);
            
            //           ncrResponse.setStatusCode(200);
            //          ncrResponse.setBody('[{"ncrGuid":98765,"accountNumber":"FGC*123","employeeNumber":"123456","status":"Complete","dmoComment":""}]');
            if (ncrResponse.getStatusCode() == 200) {
                //Request was sent successfully    	    
                //Map to Store Results in (ncrGuid ==> accountNumber : status : dmoComment)
                Map<String, String> mapNCRStatus = new Map<String, String>();
                //Parse JSON response to get the NCR GUID
                JSONParser parser = JSON.createParser(ncrResponse.getBody());
                String ncrGuid;
                String accountNumber;
                String status;
                String dmoComment;
                while (parser.nextToken() != null) {
                    
                    if ((parser.getText() == 'ncrGuid')) {
                        parser.nextToken();                
                        ncrGuid = parser.getText();						                        
                    }
                    if ((parser.getText() == 'accountNumber')) {
                        parser.nextToken();                
                        accountNumber = parser.getText();					                        
                    }
                    if ((parser.getText() == 'status')) {
                        parser.nextToken();                
                        status = parser.getText();
                    }       
                    if ((parser.getText() == 'dmoComment')) {
                        parser.nextToken();                
                        dmoComment = parser.getText();
                        mapNCRStatus.put(ncrGuid, convertBlank(accountNumber) + ':' + convertBlank(status) + ':' + convertBlank(dmoComment));
                    }                                        
                }    
                //Now cycle through the NCRs and update the Account Number/Status/Comments from DMO
                List<Lead> ncrCompleteList = new List<Lead>();        
                for (Lead ncrStatusUpdate : ncrList) {
                    String updateVals = mapNCRStatus.get(ncrStatusUpdate.NCRGUID__c);                    
                    if (updateVals != null) {
                        String[] arrVals = updateVals.split(':');
                        if (arrVals[0] != '--') {
                            ncrStatusUpdate.VIP_Account_Number__c = arrVals[0];
                        }
                        if (arrVals[1] != '--') {
                            ncrStatusUpdate.DMO_Status__c = arrVals[1];
                        }
                        if (arrVals[2] != '--') {
                            if (arrVals[2].length() > 50) {
                                ncrStatusUpdate.DMO_Comment__c = arrVals[2].substring(0,50);
                            } else {
                                ncrStatusUpdate.DMO_Comment__c = arrVals[2];
                            }
                        }
                        //If the DMO Status is Rejected change NCR to Rejected by DMO
                        if (arrVals[1] == 'Rejected') {
                            ncrStatusUpdate.Status = 'Rejected by DMO';
                            sendDMORejectedEmail(ncrStatusUpdate);
                            //If the DMO Status is Complete, we need to add to list to Convert
                        } else if (arrVals[1] == 'Complete') {
                            ncrCompleteList.add(ncrStatusUpdate);
                        }else if(arrVals[1] == 'Confirmed') {
                            ncrStatusUpdate.status = 'Confirmed by DMO';
                            //ncrCompleteList.add(ncrStatusUpdate);
                        }
                    }
                }
                update ncrList;
                
                
                //Set of Account Numbers
                Set<String> accountNumbers  = new Set<String>();
                Map<String,Account> accountMap = new Map<String,Account>();
                
                for (Lead ncr : ncrCompleteList) {
                    accountNumbers.add(ncr.VIP_Account_Number__c);
                }
                //List of Accounts Matching the VIP Account Numbers
                List<Account> accounts = [SELECT Id, Name, ExternalId__c, (SELECT Id, FirstName, LastName FROM Contacts) 
                                          FROM Account WHERE ExternalId__c IN :accountNumbers];
                
                //Map of Accounts with those VIP Account Numbers
                Map<String, Account> mapAccounts = new Map<String, Account>();
                
                //Cycle through accounts and store in Map
                for (Account acc : accounts) {
                    mapAccounts.put(acc.ExternalId__c, acc);
                }
                
                //List to store Accounts we converted NCRs into
                List<Account> accConvertedList = new List<Account>();
                //List of NCRs status of created in VIP
                List<Lead> ncrStatusCreatedinVIP = new List<Lead>();
                //Now cycle through the 'Complete' NCRs and convert if there is a matching account
                for (Lead ncrConvert : ncrCompleteList) {
                    Account accConvert = mapAccounts.get(ncrConvert.VIP_Account_Number__c);  
                    System.debug('accConvert = '+accConvert);
                    Id contactId = null;
                    if (accConvert != null) {
                        //See if there is a matching contact
                        for (Contact c : accConvert.Contacts) {
                            if (c.FirstName == ncrConvert.FirstName && c.LastName == ncrConvert.LastName) {
                                contactId = c.Id;
                            }
                        }
                        //Convert the Lead
                        Database.LeadConvert lc = new Database.LeadConvert();
                        // System.debug();
                        lc.setLeadId(ncrConvert.Id);						
                        lc.setConvertedStatus('Created in E360');
                        lc.setAccountId(accConvert.Id);
                        if (contactId != null) {
                            lc.setContactId(contactId);
                        }
                        lc.setDoNotCreateOpportunity(true);
                        Database.DMLOptions dml = new Database.DMLOptions();
                        dml.DuplicateRuleHeader.AllowSave = true;
                        Database.LeadConvertResult lcr = Database.convertLead(lc, dml);						
                        if (lcr.isSuccess()) {
                            System.debug('In success');
                            sendAccountCreatedinE360Email(ncrConvert, accConvert);
                        } else {
                            System.debug('Exception here 147');
                            System.debug(lcr.errors[0]);
                            ErrorLog.insertErrorLog('Lead conversion error: ' + String.valueOf(lcr.errors[0]), '', 'BatchConvertNewCustomerRequests', 'BatchConvertNewCustomerRequests.execute()');
                        }
                        //Set fields on the Account
                        accConvert.DMO_Comment__c = ncrConvert.DMO_Comment__c;
                        accConvertedList.add(accConvert);
                    } else {
                        //Accounts not created in E360
                        ncrConvert.Status ='Created in VIP';
                        ncrStatusCreatedinVIP.add(ncrConvert);
                    }
                }
                //Update Converted Accounts
                update accConvertedList;
                //update created in VIP ncrs
                if(ncrStatusCreatedinVIP.size() > 0){
                    update ncrStatusCreatedinVIP;
                }
            } else {
                //Request was not sent successfully
                Error_Log__c log = ErrorLog.returnErrorLog('NCR Status Update Callout Error', '', 'BatchConvertNewCustomerRequests', 'BatchConvertNewCustomerRequests.execute()');
                log.Error_Response__c = ncrResponse.getStatusCode() + ':' + ncrResponse.getStatus() + ':' + ncrResponse.getBody();
                insert log;
            }		
        } catch(Exception ex) {
            System.debug(String.valueOf(ex.getLineNumber()) + ' : ' + ex.getMessage());
            ErrorLog.insertErrorLog(ex.getMessage(), String.valueOf(ex.getLineNumber()), 'BatchConvertNewCustomerRequests', 'BatchConvertNewCustomerRequests.execute()');
        }
    }
    
    /*
public static void sendAccountCreatedEmail(Lead lead, Account acc) {
if (isEmailTurnedOn()) {   //Check if Email Deliverability is on (for testing in lower environments)           
Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
email.setSubject('NCR set up in VIP');
email.setHtmlBody(acc.Name + ' is now set up in VIP and ready for an order.<br><br>VIP Account Number: ' + acc.ExternalId__c + '<br><br><a href="'+ URL.getSalesforceBaseUrl().toExternalForm() + '/' + acc.Id + '">Link</a>');
email.toAddresses = new String[] {lead.Requested_For__r.Email, lead.Owner.Email};
Mandate_Setting__mdt ms = Mandate_Setting__mdt.getInstance('MDM_Email_Address');	//Set the reply to (MDM Teams address that we also use for Mandates)
email.setReplyTo(ms.Value__c);
OrgWideEmailAddress[] owea = [SELECT Id from OrgWideEmailAddress WHERE DisplayName = 'E360 Auto Process'];
if (owea.size() > 0) {
email.setOrgWideEmailAddressId(owea.get(0).Id);
}            
List<Messaging.SendEmailResult> result = Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {email});
}
}*/
    
    
    public static void sendAccountCreatedinE360Email(Lead lead, Account acc) {
        if (isEmailTurnedOn()) {   //Check if Email Deliverability is on (for testing in lower environments)           
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setSubject('Account Created in E360');
            email.setHtmlBody('Hi,<br><br>'+'Account is now set up in E360 and ready for an order.<br><br>VIP Account Number: ' + acc.ExternalId__c + '<br><br>'+URL.getSalesforceBaseUrl().toExternalForm() + '/' + acc.Id);
            email.toAddresses = new String[] {lead.Requested_For__r.Email};
                //Mandate_Setting__mdt ms = Mandate_Setting__mdt.getInstance('MDM_Email_Address');	//Set the reply to (MDM Teams address that we also use for Mandates)
                //email.setReplyTo(ms.Value__c);
                OrgWideEmailAddress[] owea = [SELECT Id from OrgWideEmailAddress WHERE DisplayName = 'E360 Auto Process'];
            if (owea.size() > 0) {
                email.setOrgWideEmailAddressId(owea.get(0).Id);
            }            
            List<Messaging.SendEmailResult> result = Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {email});
        }
    }
    
    public static void sendDMORejectedEmail(Lead lead) {
        if (isEmailTurnedOn()) {   //Check if Email Deliverability is on (for testing in lower environments)           
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setSubject('NCR was Rejected by DMO');
            //email.setHtmlBody('Your New Customer Request for ' + lead.Company + ' was Rejected by DMO.<br><br>DMO Comment: ' + lead.DMO_Comment__c + '<br><br><a href="'+ URL.getSalesforceBaseUrl().toExternalForm() + '/' + lead.Id + '">Link</a>');
            //For now removing the DMO Comment from the email, there were never be anything returned there - this is a future enhancement
            email.setHtmlBody('Your New Customer Request for ' + lead.Company + ' was Rejected by DMO.<br><br><a href="'+ URL.getSalesforceBaseUrl().toExternalForm() + '/' + lead.Id + '">Link</a>');
            email.toAddresses = new String[] {lead.Requested_For__r.Email, lead.Owner.Email};
                Mandate_Setting__mdt ms = Mandate_Setting__mdt.getInstance('MDM_Email_Address');	//Set the reply to (MDM Teams address that we also use for Mandates)
            email.setReplyTo(ms.Value__c);
            OrgWideEmailAddress[] owea = [SELECT Id from OrgWideEmailAddress WHERE DisplayName = 'E360 Auto Process'];
            if (owea.size() > 0) {
                email.setOrgWideEmailAddressId(owea.get(0).Id);
            }
            List<Messaging.SendEmailResult> result = Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {email});
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
    
    private static String convertBlank(String val) {
        if (val == null || val == '') {
            return '--';
        } else {
            return val;
        }
    }
    
    public void finish(Database.BatchableContext BC) {
    }    
    
}
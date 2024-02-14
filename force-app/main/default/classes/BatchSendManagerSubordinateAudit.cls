global class BatchSendManagerSubordinateAudit implements Database.Batchable<sObject> {
    /**************************************************************************************************************************
    / Batch class called by the "Scheduled Flow - Create Security Audit Cases" Flow every 6 months to send
    / Email to all managers containing a list of their subordinates and login information for them to verify/make changes to
    ***************************************************************************************************************************/
    //Variable to be able to pass in a single manager instead of running on all (helpful for testing)
    private String managerId;
    
    //Invocable Method called from the flow
    @InvocableMethod
    public static void callBatchSendManagerSubordinateAudit() {
        Id jobId = Database.executeBatch(new BatchSendManagerSubordinateAudit(null), 100);
    }
    
    public BatchSendManagerSubordinateAudit(String managerId) {
        this.managerId = managerId;
    }
    
    global List<User> start(Database.BatchableContext bc) {
        
        //Get a list of all active User records flagged as a Manager
        List<User> managers = new List<User>();
        String query = 'SELECT Id, Name, FirstName, Email FROM User WHERE IsManager__c = true AND isActive = true' + 
            			(this.managerId != null ? ' AND Id = \'' + this.managerId + '\'' : '') + 
            			(Test.isRunningTest() ? ' LIMIT 100':'');
        managers = Database.query(query);
        return managers;
    }
    
    global void execute(Database.BatchableContext bc, List<User> scope) {
        //Variable to store current manager being processed (useful for error logging)            
        String currentMgrId = 'None';
        try{            
            //Create a list of Email Messages to Send
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            
            //Template used to send email to managers
            EmailTemplate emailTemp = [SELECT Id, Subject, HtmlValue From EmailTemplate Where DeveloperName = 'Manager_Subordinate_Audit'];
            
            //Is this a sandbox?
            Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
            
            //Get a Set of all the Manager Ids
            Set<Id> mgrIds = new Set<Id>();
            for (User mgr : scope) {
               mgrIds.add(mgr.Id);
            }
            
            //Get a list of all Subordinates for the Manager Ids
            List<User> subordinateList = [SELECT Id, FirstName, LastName, Email, Manager.Name, LastLoginDate FROM User WHERE isActive = true 
                                          AND ManagerId IN :mgrIds ORDER BY LastName];
            
            //Org Wide Email Address to Send From
            OrgWideEmailAddress owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName='E360 Auto Process'];
            
            //Get the Reply To address
            List<EmailServicesAddress> emailToCaseList = [SELECT Id, LocalPart, EmailDomainName FROM EmailServicesAddress WHERE 
                                                Function.FunctionName='EmailToCase' AND DeveloperName ='rbge360support'];
            
            //Loop through all the Managers:
            //1. Create an HTML table of their subordinate information
            //2. Insert the table into the email template
            //3. Create an Email to be sent to the Manager
            for (User mgr : scope) {
                currentMgrId = mgr.Id;
	            //Create a table of subordinates
	            String subordinateTable = '<table><th align="left" width=15%>First Name</th><th align="left" width=15%>Last Name</th>' + 
                    					  '<th align="left" width=30%>Email</th><th align="left" width=20%>Manager</th><th align="left" width=20%>Last Login</th>';
                for (User subordinate : subordinateList) {
                    if (subordinate.ManagerId == mgr.Id) {
                    	String firstName = subordinate.FirstName == null ? '' : subordinate.FirstName;
                    	String managerName = subordinate.Manager.Name == null ? '' : subordinate.Manager.Name;
                    	String lastLogin = subordinate.LastLoginDate == null ? 'Unknown' : subordinate.LastLoginDate.format();
                    	subordinateTable += '<tr><td>' + firstName + 
	                        				'</td><td>' + subordinate.LastName + 
	                        				'</td><td>' + subordinate.Email + 
	                        				'</td><td>' + managerName + 
	                        				'</td><td>' + lastLogin + '</td></tr>';
                    }
                }
                subordinateTable += '</table>';
                
                if (subordinateTable.contains('<tr>')) {  //At lease one subordinate was found
                	//Insert the table into the email template
                	String body = emailTemp.HtmlValue.replace('{!User.FirstName}', mgr.FirstName);
                	body = body.replace('[SubordinateTable]', subordinateTable);
                
	                //Create the email message
    	            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        	        mail.setUseSignature(false);
	        		mail.setSaveAsActivity(false);
                	//Send from org wide email address
        			if (owea != null) {
						mail.setOrgWideEmailAddressId(owea.Id);
					}
	            	mail.setSubject(emailTemp.Subject);
                	mail.setHtmlBody(body);                  
                    
                	if (isSandbox) {
	                	mail.setToAddresses(new list<String>{UserInfo.getUserEmail()});
                		//Set the Reply To Address to go to the configured Email-To-Case
                    	if (emailToCaseList.size() > 0) {
                            if (emailToCaseList[0].LocalPart != null && emailToCaseList[0].EmailDomainName != null) {
	                        	mail.setReplyTo(emailToCaseList[0].LocalPart + '@' + emailToCaseList[0].EmailDomainName);
                            }
                    	}                        
                    } else {
        	        	mail.setToAddresses(new list<String>{mgr.Email});
                        mail.setReplyTo('rbge360support@reyesholdings.com');
            	    }                
                	emailList.add(mail);                
                }
            }
            
            //Send all the emails
            if (!emailList.isEmpty() && isEmailTurnedOn()) {
                Messaging.sendEmailResult[] results = Messaging.sendEmail(emailList);
            }
        
        } catch(Exception ex) {
            ErrorLog.insertErrorLog(ex.getMessage(), String.valueOf(ex.getLineNumber()), 'BatchSendSubordinateAuditToManagers', 
                                    'BatchSendSubordinateAuditToManagers.execute(): ' + currentMgrId);
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

    global void finish(Database.BatchableContext bc) {
		
    }
    
}
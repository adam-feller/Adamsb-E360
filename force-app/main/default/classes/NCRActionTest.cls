@isTest
public class NCRActionTest {
    
    
    @isTest
    static void testcreateCaseEmailAttachmentsToNCR(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Field Sales'];
        User fsr = new User(Alias='fsruser', Email='fsr@testorg.com', FederationIdentifier = '12345690',
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId=p.Id, VIP_Company__c = 'CBS', Assigned_Route__c = '12345', 
                            TimeZoneSidKey='America/Los_Angeles', UserName='fsr123@testorg.com');
        insert fsr;
        
        
        //Create a Chain
        Chain__c chain = new Chain__c(Name='AMAZON', Business_Unit__c='CBS', Chain_Id__c='181AM');
        insert chain;
        
        //create case
        Case caseObj = new case();
        caseObj.Buyer_Name__c='test';
        insert CaseObj;
        
       // Case cse = new Case(Subject = 'test', Status = 'New');
        //insert cse;
        //
        
        //create email message
        EmailMessage emailMessage = new EmailMessage();
        emailMessage.status = '3'; // email was sent
        emailMessage.fromName = 'Test Name'; // from name
        emailMessage.subject = 'This is the Subject!'; // email subject
        emailMessage.htmlBody = '<html><body><b>Hello</b></body></html>'; // email body
        
        //case Id
        String[] toIds = new String[]{ CaseObj.id };
		emailMessage.incoming=true;
        emailMessage.toIds = toIds;
        // additional recipients who don’t have a corresponding contact, lead or user id in the Salesforce org (optional)
        //emailMessage.toAddress = ’emailnotinsalesforce@toexample.com, anotherone@toexample.com’;
        insert emailMessage; // insert
        
        // Add Email Message Relation for id of the sender
        EmailMessageRelation emr = new EmailMessageRelation();
        emr.emailMessageId = emailMessage.Id;
        //emr.relationId = CaseObj.id;
        emr.relationType = 'FromAddress';
       // insert emr;
        
        
        
        // Create the attachment
        Messaging.EmailFileAttachment emailattachment = new Messaging.EmailFileAttachment();            
        emailattachment.setFileName('attachmentFilename.pdf');           
        emailattachment.setContentType('application/pdf');           
        emailattachment.setBody(Blob.valueOf('Test Body'));
       
        
        // Send the email         
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();           
        message.setToAddresses(new List<String>{'Test@test.com'});             
        message.setSubject('test');             
        message.setPlainTextBody('test');            
        message.setFileAttachments(new Messaging.EmailFileAttachment[] { emailattachment });       
        message.setWhatId(CaseObj.Id);         
        Messaging.sendEmail(new List<Messaging.Email>{message});
        
        List<EmailMessage> emList = [
            SELECT id, ParentID, FromAddress, FromName, HasAttachment, Headers, Subject, ActivityID, ToAddress
            FROM EmailMessage
            WHERE ParentID = :CaseObj.id and HasAttachment=true
            
        ];
        system.debug('#### emList ##### '+emList);
        
        
        
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setUseSignature(false);
        email.setSaveAsActivity(true);
        //email.incoming=true;
        email.setSubject('Email using Apex');
        String[] toAddresses = new String[] {'abc@def.com'};
        email.setToAddresses(toAddresses);
        email.setHtmlBody('<html><body>Hi <b>Saroj</b></body></html>');
        email.setFileAttachments(new Messaging.EmailFileAttachment[] { emailattachment }); 
        Messaging.SingleEmailMessage[] emailList = new Messaging.SingleEmailMessage[] {email};
            
        //Messaging.sendEmail(emailList);              
        //System.debug(emailList[0].getToAddresses());
        
        /*
        EmailMessage emailMsg = new EmailMessage(); // Created a EmailMessage and copy all details from above.
        emailMsg.ToAddress=(emailList[0].getToAddresses())[0];
        emailMsg.Subject=emailList[0].getSubject();
        emailMsg.HtmlBody=emailList[0].getHtmlBody();
        emailMsg.ParentId = CaseObj.Id; //Attach with the case
        emailMsg.MessageDate = system.now();
        emailMsg.Status = '0';
        insert emailMsg;
        */
        
        ContentVersion content=new ContentVersion(); 
        content.Title='test content att'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob = Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData = bodyBlob; 
        //content.LinkedEntityId = CaseObj.id;
        //content.origin = 'H';
        insert content;
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = CaseObj.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =:content.id].contentdocumentid;
        //contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        system.debug('ContentDocumentLink contentlink --' + contentlink);
        system.debug('ContentDocumentLink contentlink --' + [Select Id, LinkedEntityId, contentdocumentid,ShareType,Visibility from ContentDocumentLink where id =:contentlink.id] );
        
            
        //Create an NCR
        Lead testNCR = new Lead();
        testNCR.Business_Unit__c = 'CBS';
        testNCR.Requested_For__c = fsr.Id;
        testNCR.CaseId__c = CaseObj.id;
        testNCR.Company = 'Test 1Company';
        testNCR.Licensee_Name__c = 'Test 1Company, LLC';
        testNCR.Street = '1233 1st Avenue';
        testNCR.City = 'Chicago';
        testNCR.State = 'IL';
        testNCR.PostalCode = '60018';
        testNCR.County__c = 'CK';
        testNCR.FirstName = 'Joh1n';
        testNCR.LastName = 'Do1e';
        testNCR.Phone = '555-555-5255';
        testNCR.Fax = '555-555-5535';
        testNCR.License_1__c = '11111';
        testNCR.License_Expiration_Date__c = System.today().addYears(1);
        testNCR.License_Type__c = 'Beer Wine & Liquor';
        testNCR.License_Status__c = 'Active';
        testNCR.Tax_ID_Seller_Permit__c = '1111111111';
        testNCR.Beer_Salesman_1__c = fsr.Id;
        testNCR.Package_Type__c = 'Draft & Pkg';
        testNCR.Draft_Status__c = 'Mixed Draft Account';
        testNCR.Seasonal_Open_Month__c = 'January';
        testNCR.Seasonal_Close_Month__c = 'February';
        testNCR.Displayable__c = 'Displayable';
        testNCR.POS_Materials__c = '<50 Case Display';
        testNCR.Subclass__c = 'Local Bar';
        testNCR.Sell_Type__c = 'House Account';
        testNCR.Chain__c = chain.Id;
        testNCR.Chain_Independent__c = 'Chain';
        testNCR.Beer_Industry_Volume__c = 'Top 50/20%';
        testNCR.Civilian_Military__c = 'Civilian';
        testNCR.Ethnic_Patron__c = 'General Pop';
        testNCR.Lifestyle__c = 'General Pop';
        testNCR.Occupation_Code__c = 'Blue Collar';
        testNCR.Patron_Age_Code__c = 'General Pop';
        testNCR.Residence__c = 'Local';
        testNCR.Company__c = 'Chicago Beverage';
        testNCR.Warehouse__c = 'Chicago Beverage';
        testNCR.Print_Separate_Empty_Invoice__c = true;
        testNCR.Terms__c = 'Charge';
        testNCR.Premise__c = 'On Premise';
        testNCR.Class__c = 'Bar/Tavern';
        testNCR.Requested_Delivery_Days__c = 'Monday';
        testNCR.Email = 'test111@test.org';
        testNCR.Comments_for_MDM_Team__c = 'Tes1t Sending NCR';
        insert testNCR;
        
        //Lead leadObj = [select id from lead limit 1];
        List<string> leadIdList = new List<String>();
        leadIdList.add(testNCR.id);
       // Test.startTest();
        	
        	
           List<EmailMessage> emList1 = [
            SELECT id, ParentID, FromAddress, FromName, HasAttachment, Headers, Subject, ActivityID, ToAddress
            FROM EmailMessage 
            
        ]; 
        
        system.debug('EMMMMMMMM---- '+emList1);
        List<ContentDocument> contentDoc = [select Id from ContentDocument];
        system.debug('contentDoc---- '+contentDoc);
        for(ContentDocument cd : contentDoc){
         	system.debug('Content_---- '+[select ContentDocumentId, Sharetype,Visibility,LinkedEntityId from ContentDocumentLink where ContentDocumentId =:cd.Id]);   
        }
        
        NCRAction.createCaseEmailAttachmentsToNCR(leadIdList);
       // Test.stopTest();
    }
    
    
    
}
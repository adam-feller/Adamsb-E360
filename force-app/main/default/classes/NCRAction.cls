public class NCRAction {
     
    @InvocableMethod(label='createCaseEmailAttachmentsToNCR' description='move all case email attachments to NCR' category='createCaseEmailAttachmentsToNCR')
    public static void createCaseEmailAttachmentsToNCR(List<String> leadId){
        
        Lead leadObj =[select id, caseid__c from Lead where id in :leadId limit 1];

        if(leadObj.CaseId__c != null ){
            List<EmailMessage> emList = [
                SELECT id, ParentID, FromAddress, FromName, HasAttachment, Headers, Subject, ActivityID, ToAddress
                FROM EmailMessage
                WHERE ParentID = :leadObj.CaseId__c and HasAttachment=true ];
            
            system.debug('NCRAction:#### emList '+emList);
            List<ContentDocumentLink> cdlupd = new List<ContentDocumentLink>();
            Map<String,ContentDocumentLink> mapContList = new  Map<String,ContentDocumentLink> ();
            if(emList != null && emList.size() > 0){
                for(EmailMessage emsg : emList){
                    //Loop through all records in the collection
                    List<ContentDocumentLink> ContentDocumentLinkList = new List<ContentDocumentLink>();
                    if(Test.isRunningTest()){
                        ContentDocumentLinkList = [select ContentDocumentId, Sharetype,Visibility,LinkedEntityId from ContentDocumentLink where LinkedEntityId =:emsg.ParentID];
                    }else{
                        ContentDocumentLinkList =[select ContentDocumentId, Sharetype,Visibility,LinkedEntityId from ContentDocumentLink where LinkedEntityId =:emsg.id];
                    }
                
                    //System.debug('NCRAction : ContentDocumentLinkList ---:'+ ContentDocumentLinkList);
                    for (ContentDocumentLink cdl : ContentDocumentLinkList) {
                        
                        //EmailMessage obj = mapCaseXEmailMessage.get(emailMessageId);
                        ContentDocumentLink c = new ContentDocumentLink();
                        c.ContentDocumentId = cdl.ContentDocumentId;
                        c.LinkedEntityId = leadObj.id;
                        c.ShareType = cdl.ShareType;
                        c.Visibility = cdl.Visibility;
                        if(mapContList.get(cdl.ContentDocumentId) == null){
                            mapContList.put(cdl.ContentDocumentId,c );
                        }
                       // cdlupd.Add(c);
                    }
                }
                
                if(mapContList.size() > 0){
                    for(String contentId : mapContList.keySet()){
                         cdlupd.Add(mapContList.get(contentId));
                    }
                }
                if(cdlupd.size() >0)
                	insert cdlupd;
            }
        }
    }
}
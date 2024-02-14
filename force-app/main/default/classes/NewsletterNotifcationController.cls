public class NewsletterNotifcationController {
    
    @AuraEnabled(cacheable=true)
    public static InfoWrapper getNewsletterRecord(){
        try {
            InfoWrapper w = new InfoWrapper();
            w.toggleModal = false;
            //get current user info
            User u = [SELECT Id, Last_E360_Newsletter_Acknowledgement__c FROM User WHERE Id = :UserInfo.getUserId()];

            //get the current newsletter record
            DateTime now = DateTime.parse(System.now().format());
            E360_Newsletter__c nl = [SELECT Id, Description__c, Release_Date__c
                                    FROM E360_Newsletter__c
                                    WHERE Release_Date__c <= :now
                                    ORDER BY Release_Date__c desc
                                    LIMIT 1
                                    ];
            //logic for if user has not acknowledged newsletter yet
            if(now >= nl.Release_Date__c && 
            (nl.Release_Date__c > u.Last_E360_Newsletter_Acknowledgement__c || u.Last_E360_Newsletter_Acknowledgement__c == null)){
                w.description = nl.Description__c;
                w.toggleModal = true;
                //query ContentDocumentLink
                List<ContentDistribution> cDistribution = new List<ContentDistribution>();
                List<ContentDocumentLink> cdl = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :nl.Id LIMIT 1];
                //command center file data
                if(cdl.size()>0){
                    w.fileId = cdl[0].ContentDocumentId;
                    cDistribution = [SELECT Id, DistributionPublicUrl FROM ContentDistribution WHERE ContentDocumentId = :cdl[0].ContentDocumentId];
                }
                //login flow file data
                if(cDistribution.size()>0){
                    w.url = cDistribution[0].DistributionPublicUrl;
                }
                return w;
            }
            else{
                return w;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void updateUser(){
        try {
            DateTime now = DateTime.parse(System.now().format());
            Id userId = UserInfo.getUserId();
            User u = new User();
            u.Id = userId;
            u.Last_E360_Newsletter_Acknowledgement__c = now;
            update u;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class InfoWrapper{
        @AuraEnabled public String fileId;
        @AuraEnabled public String url;
        @AuraEnabled public String description;
        @AuraEnabled public Boolean toggleModal;
    }
}
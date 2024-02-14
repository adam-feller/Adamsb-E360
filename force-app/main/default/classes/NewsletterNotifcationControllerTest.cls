@isTest
public class NewsletterNotifcationControllerTest {
    
    @isTest
    public static void testException(){
        try {
            NewsletterNotifcationController.getNewsletterRecord();
        } catch (Exception e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'exception error does not match');
        }
    }

    @isTest
    public static void testGetNewsletterRecord(){

        Id userId = UserInfo.getUserId();
        User u = new User();
        u.Id = userId;
        u.Last_E360_Newsletter_Acknowledgement__c = null;
        update u;

        DateTime yesterday = DateTime.parse(System.now().format()).addDays(-1);
        //add newsletter record
        E360_Newsletter__c newsletter = new E360_Newsletter__c();
        newsletter.Release_Date__c = yesterday;
        newsletter.Description__c = 'sample text here';
        insert newsletter;
        //add file
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test';
        cv.PathOnClient = 'test.jpg';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        insert cv;
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1];
        //add ContentDocumentLink
        ContentDocumentLink cl = new ContentDocumentLink();
        cl.LinkedEntityId = newsletter.Id;
        cl.ContentDocumentId = cv.ContentDocumentId;
        cl.ShareType = 'I';
        insert cl;
        //Add public URL to file
        ContentDistribution cd = new ContentDistribution();
        cd.ContentVersionId = cv.Id;
        cd.Name = 'Test';
        cd.PreferencesAllowPDFDownload = false;
        cd.PreferencesAllowViewInBrowser = false;
        cd.PreferencesNotifyOnVisit = false;
        cd.PreferencesPasswordRequired = false;
        insert cd;

        NewsletterNotifcationController.InfoWrapper wrapper = NewsletterNotifcationController.getNewsletterRecord();
        System.assertEquals(cv.ContentDocumentId, wrapper.fileId, 'FileId does not match');
        System.assertEquals(true, wrapper.toggleModal, 'ToggleModal value does not match');
        System.assertEquals(newsletter.Description__c, wrapper.description, 'Description value does not match');
    }
    @isTest
    public static void testUpdateUser(){
        NewsletterNotifcationController.UpdateUser();
        User u = [SELECT Id, Last_E360_Newsletter_Acknowledgement__c FROM User WHERE Id = :UserInfo.getUserId()];
        DateTime now = DateTime.parse(System.now().format());
        System.assertEquals(now, u.Last_E360_Newsletter_Acknowledgement__c, 'DateTime field was not updated');
    }

}
@isTest
public class ContentDocumentLinkTriggerTest {

    @isTest
    static void cdlsTest(){
        Product2 prod = new Product2(name = 'Test Product');
        insert prod;

        ContentVersion content = new ContentVersion();
        content.Title = 'UPC Image';
        content.PathOnClient = content.Title +'.png';
        String encodedString = 'this is the encoded string'; 
        Blob bodyBlob = Blob.valueOf('This will be the test body');
        content.VersionData = EncodingUtil.base64Decode(encodedString.replaceFirst('data:image/png;base64,',''));
        insert content;

        ContentDocumentLink contentLink = new ContentDocumentLink();
        contentLink.LinkedEntityId=prod.id;
        contentLink.ContentDocumentId=[SELECT contentdocumentid FROM contentVersion where id =:content.id].contentdocumentid;
        contentLink.ShareType = 'I';

        Test.startTest();
            insert contentLink;
        Test.stopTest();

        System.assertEquals(prod.Id, contentLink.LinkedEntityId, 'The Prod Id is the linked Entity id');
    }
}
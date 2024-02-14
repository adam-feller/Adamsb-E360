@isTest
public class UPCFileGeneratorTest {
	
    @TestSetup
    private static void setup(){
    	Product2 testProduct = TestFactory.createProduct('Test Product', '12345', 'MillerCoors', '123*B');
    }
    
    static Product2 getProduct(){
        return [SELECT Id, Name, SKU__c
                FROM Product2
                LIMIT 1];
    }
    
    @isTest
    static void generateFileTest(){
        Product2 testProduct = getProduct();
        ContentVersion fileContentVersion = new ContentVersion();
        fileContentVersion.PathOnClient = 'Test.png';
        Blob vData = Blob.valueOf( 'Test Image File.png' );
        fileContentVersion.VersionData = vData;
        //insert fileContentVersion;
        
		//insert cdl;
        
        Test.startTest();
        	ApexPages.StandardController controller = new ApexPages.standardController(testProduct);
            UPCFileGenerator ext = new UPCFileGenerator(controller);
            ext.imageBody = 'data:image/png;base64,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';
           	insert fileContentVersion;
            fileContentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :fileContentVersion.Id];
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = testProduct.Id;
            cdl.ContentDocumentId = fileContentVersion.ContentDocumentId;

            insert cdl;
            ext.generateFile();
           
        Test.stopTest();
        
     
        //System.assertNotEquals(ext.generateFile().size, null, 'should not be null');
        //System.assertNotEquals(noteWrapperObj.noteId, null, 'noteWrapperObj.noteId should not be null');
        //System.assertEquals(returnedContentDocumentLinks.size(), 2, '2 content document links should be returned');
        
    }
}
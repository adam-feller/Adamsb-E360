@isTest
public class ExternalFileViewerControllerTest {

    @TestSetup
    private static void setup(){
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        TestFactory.createSharepointDocumentType('Planogram', 'Planogram');
        
        contentVersion testcVersion = TestFactory.createContentVersion(
            'SPINX #260 Spring 2021', 
            'https://e360--uat.my.salesforce.com/contenthub/download/0XC6300000001lO%3Aitem%3AL3NpdGVzL3JiZ2Vjc2FsZXM%3Ac4db3f3f-4bc1-465b-a400-8c6644386852%3Ad18606af-3ba6-4f28-b80d-183b1990af80%3A131935',
            'SPINX #260 Spring 2021', 
            '0XC6g000000YEjDGAW',
            'item:L3NpdGVzL3JiZ2Vjc2FsZXM:c4db3f3f-4bc1-465b-a400-8c6644386852:d18606af-3ba6-4f28-b80d-183b1990af80:131935',
             'E', 
            'H');
        ContentVersion cdvData = [select ContentDocumentId from ContentVersion where id = :testcVersion.Id];
        testcVersion.DocumentType__c = 'SellerSheets';
        
        update testcVersion;
                
        ContentDocumentLink cdlink = TestFactory.createContentDocumentLink(testAccount.id,cdvData.ContentDocumentId);
    }

    static Account getAccount(){
        return [SELECT Id, Name, VIP_Account_Number__c, Beer_Company__c, Warehouse__c, Store_Number__c, Premise__c,
                VIP_Composite_Key__c, Chain__c, VIP_Instance__c
                FROM Account
                LIMIT 1];
    }

    @isTest
    static void testFetchDocument(){
        Account testAccount = getAccount();

        Test.startTest();
        
        List<ContentDocumentLink> result = ExternalFileViewerController.fetchDocument(testAccount.Id, 'Planogram');
        
        Test.stopTest();

        System.assert(result.isEmpty(), 'No Planogram file found');
    }

    @isTest
    static void testFetchOtherDocument(){
        Account testAccount = getAccount();

        Test.startTest();
            List<ContentDocumentLink> result = ExternalFileViewerController.fetchDocument(testAccount.Id, 'Other');
        Test.stopTest();

        System.assert(result.isEmpty(), 'No Other file found');
    }
    
    @isTest
    static void testGetFilesTree(){
        Account testAccount = getAccount();

        Test.startTest();
            List<ExternalFileViewerController.item> resultItems = ExternalFileViewerController.getFilesTree(testAccount.Id, 'Planogram');
        Test.stopTest();

        System.assert(resultItems.isEmpty(), 'No Planogram file found');
    }

    @isTest
    static void testGetSharepointDocumentTypeValues(){

        Test.startTest();
            List<String> documentTypes = ExternalFileViewerController.getSharepointDocumentTypeValues('Planogram');
        Test.stopTest();

        System.assertEquals(documentTypes.size(), 1, '1 document type should be returned');
    }

    @isTest
    static void testGetDownloadURL(){
        ContentDocument cd = [SELECT Id FROM ContentDocument LIMIT 1];

        Test.startTest();
            String url = ExternalFileViewerController.getDownloadURL(cd.Id);
        Test.stopTest();
        system.debug(url);
        System.assertEquals(url!=null, true, '1 CD should be returned');
    }

    @isTest
    static void testFilesFound(){
        Account testAccount = getAccount();

        Test.startTest();

        items_SharePointOnline__x sharePointMockedRecord1 = new items_SharePointOnline__x(
            ExternalId = '0XC6g000000YEjD:item:L3NpdGVzL3JiZ2Vjc2FsZXM:c4db3f3f-4bc1-465b-a400-8c6644386852:d18606af-3ba6-4f28-b80d-183b1990af80:204953',
            LicenseType__c='Beer & Wine',
            Salesorg__c = 'abc',
            Document_Type__c='Test Type',
            Expiration_Date_New__c = '10/11/2100',
            Tags__c = 'independent'
        );
        ExternalFileViewerController.mockedSharePointRecords.add(sharePointMockedRecord1);
        //tests date expiration logic
        Set<String> dates = new Set <String> {
            '1234Jan005123456789012342100',
            '1234Feb005123456789012342100',
            '1234Mar005123456789012342100',
            '1234Apr005123456789012342100',
            '1234May005123456789012342100',
            '1234Jun005123456789012342100',
            '1234Jul005123456789012342100',
            '1234Aug005123456789012342100',
            '1234Sep005123456789012342100',
            '1234Oct005123456789012342100',
            '1234Nov005123456789012342100',
            '1234Dec005123456789012342100'
        };
        Integer i = 10;
        for(String d : dates){
            items_SharePointOnline__x sharePointMockedRecordByMonth = new items_SharePointOnline__x(
                ExternalId = '0XC6g000000YEjD:item:L3NpdGVzL3JiZ2Vjc2FsZXM:c4db3f3f-4bc1-465b-a400-8c6644386852:d18606af-3ba6-4f28-b80d-183b1990af80:2049'+i,
                LicenseType__c='Beer & Wine',
                Document_Type__c='Test Type',
                Expiration_Date_New__c = d
            );
            i++;
            ExternalFileViewerController.mockedSharePointRecords.add(sharePointMockedRecordByMonth);
        }
        List<ExternalFileViewerController.item> resultItems = ExternalFileViewerController.getFilesTree(testAccount.Id, 'Planogram');
        Test.stopTest();

        System.assertEquals(resultItems.size(), 1, '1 item should be returned');
    }
}
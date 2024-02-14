public without sharing class ExternalFileViewerController {

    @TestVisible 
    private static List<items_SharePointOnline__x> mockedSharePointRecords = new List<items_SharePointOnline__x>();

    @TestVisible
    private static List<String> getSharepointDocumentTypeValues(String documentCategory) {
        List<Sharepoint_Document_Types__c> sharepointDocumentTypes = SharepointDocumentTypesDAO.getSharepointDocumentTypeValues(documentCategory);

        List<String> documentTypes = new List<String>();
        for(Sharepoint_Document_Types__c docType : sharepointDocumentTypes) {
            if(docType.Sharepoint_Document_Types__c != null){
                documentTypes = docType.Sharepoint_Document_Types__c.split(',');
            }
        }

        return documentTypes;
    }

    @AuraEnabled
    public static List<ContentDocumentLink> fetchDocument(Id recordId, String documentType) {
        List<Account> accountDetails = AccountDAO.getAccountsByIds(new Set<Id>{recordId});
        List<String> documentTypes = getSharepointDocumentTypeValues(documentType);
        Set<items_SharePointOnline__x> files = new Set<items_SharePointOnline__x>();
        // MJ Changes Below
        List<items_SharePointOnline__x> sharepointFiles = SharePointOnlineDAO.getSharePointDocumentByDocumentTypeChainBUOrStoreNumber(documentTypes, accountDetails[0].Chain__c, accountDetails[0].VIP_Instance__c, 
                                                                                                                                      accountDetails[0].VIP_Composite_Key__c, accountDetails[0].Warehouse__c,
                                                                                                                                      accountDetails[0].Premise__c, accountDetails[0].Controllable__c, 
                                                                                                                                      accountDetails[0].SalesOrg__c);
        // MJ Changes Above
        files.addAll(sharepointFiles);
        
        //AZ Changes Below
        //Seperate query and logic added due to bug using License Type logic. '&' symbol in License Type value causes incorrect files to be returned in query
        List<items_SharePointOnline__x> sharepointLicenseTypeFiles = SharePointOnlineDAO.getSharePointDocumentByLicenseType(documentTypes, accountDetails[0].SalesOrg__c, accountDetails[0].License_Type_cd__c);
		for(items_SharePointOnline__x file: sharepointLicenseTypeFiles){
            if(file.LicenseType__c !=null && file.Salesorg__c !=null && accountDetails[0].License_Type_cd__c !=null && accountDetails[0].SalesOrg__c!=null){
                if(file.LicenseType__c.contains(accountDetails[0].License_Type_cd__c) && 
                file.Salesorg__c.contains(accountDetails[0].SalesOrg__c)){
                    files.add(file);
                }
            }
        }
        //AZ Changes Above
     
        String externalDataSourceId = '';
        List<items_SharePointOnline__x> documentList = new  List<items_SharePointOnline__x>();
        Map<String, ContentDocumentLink> finalContentDocumentLinkMap = new Map<String, ContentDocumentLink>();
        List<ContentVersion> contentVersionsReturned = new List<ContentVersion>();
        Set<String> externalIds = new Set<String>();

        if(Test.isRunningTest()) {
            files.addAll(mockedSharePointRecords);
        }
        System.debug('Files queried: '+ files);
        for(items_SharePointOnline__x doc : files) {
            Boolean addDoc = true;
            
            if(doc.Controllable__c != null){
                if(doc.Controllable__c != accountDetails[0].Controllable__c){
                     addDoc = false;
                }
            }
            if(doc.Salesorg__c != null && accountDetails[0].SalesOrg__c!=null){
                String documentSalesOrgTag = doc.Salesorg__c.toLowercase();
                List<String> salesOrgs = documentSalesOrgTag.split(';');
                if(!salesOrgs.contains(accountDetails[0].SalesOrg__c.toLowercase())){
                        addDoc = false;
                }
            }
            // MJ Below
            if(doc.Expiration_Date_New__c != null){
                String subStringNewDate = doc.Expiration_Date_New__c;
                system.debug('Expiration date value is: '+subStringNewDate);
                date mydate1;

                if (subStringNewDate.contains('/'))
                     mydate1 = date.Parse(doc.Expiration_Date_New__c.substringBefore(' '));
                else {
                    system.debug('substringDate' +subStringNewDate);
                    String strMnth    = subStringNewDate.substring(4,7);
                    String day        = subStringNewDate.substring(8,10);
                    String year       = subStringNewDate.substring(24,28);
                    string strMonth ;
                    if(strMnth=='Jan')
                        strMonth ='1';
                    else if (strMnth == 'Feb' )
                        strMonth ='2';
                    else if (strMnth == 'Mar' )
                        strMonth ='3';
                    else if (strMnth == 'Apr' )
                        strMonth ='4';
                    else if (strMnth == 'May' )
                        strMonth ='5';
                    else if (strMnth == 'Jun' )
                        strMonth ='6';
                    else if (strMnth == 'Jul' )
                        strMonth ='7';
                    else if (strMnth == 'Aug' )
                        strMonth ='8';
                    else if (strMnth == 'Sep' )
                        strMonth ='9';
                    else if (strMnth == 'Oct' )
                        strMonth ='10';   
                    else if (strMnth == 'Nov' )
                        strMonth ='11';
                    else if (strMnth == 'Dec' )
                        strMonth ='12';
                    
                    String strDate = strMonth +'/'+day+'/'+year;
                    System.debug('------>'+strDate );
                    mydate1 = date.parse(strDate);
                    System.debug('------>'+mydate1 );
                }
                
                if(mydate1 < System.today()){
                    addDoc = false;
                }
            }
            // MJ Above
            if(doc.Premise__c != null){
                if(doc.Premise__c != accountDetails[0].Premise__c){
                    addDoc = false;
                }
            }
            if(doc.BU__c != null){
                List<String> bu = doc.BU__c.split('\n');
                if(!bu.contains(accountDetails[0].VIP_Instance__c)){
                    addDoc = false;
                }
            }
            if(doc.Warehouse__c != null){
                String documentWarehouseTag = doc.Warehouse__c.toLowercase();
                List<String> warehouses = documentWarehouseTag.split(';');
                if(!warehouses.contains(accountDetails[0].Warehouse__c.toLowercase())){
                    addDoc = false;
                }
            }
            if(doc.Tags__c != null){
                List <String> chains = new List <String> ();
                String tagsFormatted = doc.Tags__c.toLowercase();
                //one tag value
                if(!tagsFormatted.contains(',')){
                    chains.add(tagsFormatted);
                }
                //multiple tag values
                else{
                    chains = tagsFormatted.split('\\s*,\\s*');
                }

                if(!chains.contains(accountDetails[0].Chain__c.toLowercase())){
                    addDoc = false;
                }
            }
            if(doc.Store_Number__c != null){
                List<String> storeNumbers = doc.Store_Number__c.split('\\s*,\\s*');
                if(!storeNumbers.contains(accountDetails[0].VIP_Composite_Key__c)){
                    addDoc = false;
                }
            }

            if(addDoc){
                documentList.add(doc);
                externalDataSourceId = doc.ExternalId.split(':')[0];
                String externalId = doc.ExternalId.split('item')[1];
                externalIds.add('item' + externalId);
            }
        }

        if(externalDataSourceId != '' && !externalIds.isEmpty()){
            List<ContentDocumentLink> contentDocumentLinks = ContentDocumentLinkDAO.getContentDocumentLinkExternalIdAndAccountId(accountDetails[0].Id, externalIds);

            Map<String, ContentDocumentLink> existingContentDocumentLinkMap = new Map<String, ContentDocumentLink>();
            for(ContentDocumentLink contDocLinkObj : contentDocumentLinks){
                existingContentDocumentLinkMap.put(contDocLinkObj.ContentDocument.LatestPublishedVersion.ExternalDocumentInfo2, contDocLinkObj);
            }

            List<ContentVersion> contentVersionsToInsert = new List<ContentVersion>();
            List<ContentVersion> contentVersionsToUpdate = new List<ContentVersion>();
            List<ContentDocument> contentDocumentToUpdate = new List<ContentDocument>();

            for(items_SharePointOnline__x sharepointDoc : documentList){
                String externalId = sharepointDoc.ExternalId.split('item')[1];
                if(!existingContentDocumentLinkMap.containsKey('item' + externalId)){
                    ContentVersion testContentVersionObj = new ContentVersion();
                    testContentVersionObj.Title = setName(sharepointDoc.Name__c);
                    testContentVersionObj.Description = sharepointDoc.DownloadUrl__c;
                    testContentVersionObj.PathOnClient = setName(sharepointDoc.Name__c);
                    testContentVersionObj.ExternalDataSourceId = sharepointDoc.ExternalId.split(':')[0];
                    testContentVersionObj.ExternalDocumentInfo2 = 'item' + externalId;
                    testContentVersionObj.ContentLocation = 'E';
                    testContentVersionObj.Origin = 'H';
                    testContentVersionObj.DocumentType__c = sharepointDoc.Document_Type__c;
                    contentVersionsToInsert.add(testContentVersionObj);
                } else {
                    ContentDocumentLink checkForUpdDocLinkObj = existingContentDocumentLinkMap.get('item' + externalId);
                    if ((sharepointDoc.Name__c != checkForUpdDocLinkObj.ContentDocument.LatestPublishedVersion.Title) || 
                        (sharepointDoc.Document_Type__c != checkForUpdDocLinkObj.ContentDocument.LatestPublishedVersion.DocumentType__c)) {
                        ContentVersion UpdCV = new ContentVersion();
                        UpdCV.id = checkForUpdDocLinkObj.ContentDocument.LatestPublishedVersionId;
                        UpdCV.Title = setName(sharepointDoc.Name__c);
                        UpdCV.DocumentType__c = sharepointDoc.Document_Type__c;
                        contentVersionsToUpdate.add(updCV);
                    }
                    if ((sharepointDoc.Name__c != checkForUpdDocLinkObj.ContentDocument.LatestPublishedVersion.Title)) {
                        ContentDocument UpdCD = new ContentDocument();
                        UpdCD.id = checkForUpdDocLinkObj.ContentDocument.id;
                        UpdCD.Title = setName(sharepointDoc.Name__c);
                        contentDocumentToUpdate.add(updCD);
                    }
                }
            }

            if(!contentVersionsToUpdate.isEmpty()){
                update contentVersionsToUpdate;
            }
            
            if(!contentDocumentToUpdate.isEmpty()){
                update contentDocumentToUpdate;
            }

            if(!contentVersionsToInsert.isEmpty()){
                ContentVersionDAO.insertContentVersions(contentVersionsToInsert);
            }

            contentVersionsReturned = ContentVersionDAO.getContentVersionByDataSourceAndExternalIdsSet(externalDataSourceId, externalIds);
            List<ContentDocumentLink> contentDocumentLinksToInsert = new List<ContentDocumentLink>();
            for(ContentVersion contVers : contentVersionsReturned){
                if(!existingContentDocumentLinkMap.containsKey(contVers.ExternalDocumentInfo2)){
                    ContentDocumentLink cdl = new ContentDocumentLink();
                    cdl.LinkedEntityId = accountDetails[0].Id;
                    cdl.ContentDocumentId = contVers.ContentDocumentId;
                    cdl.ShareType = 'I';
                    cdl.Visibility = 'AllUsers';
                    contentDocumentLinksToInsert.add(cdl);
                }
            }

            if(!contentDocumentLinksToInsert.isEmpty()){
                ContentDocumentLinkDAO.insertContentDocumentLinks(contentDocumentLinksToInsert);
            }

            List<ContentDocumentLink> finalContentDocumentLinks = ContentDocumentLinkDAO.getContentDocumentLinkExternalIdAndAccountId(accountDetails[0].Id, externalIds);
            for(ContentDocumentLink contDocLinkObj : finalContentDocumentLinks){
                finalContentDocumentLinkMap.put(contDocLinkObj.ContentDocument.LatestPublishedVersion.ExternalDocumentInfo2, contDocLinkObj);
            }
        }
        system.debug('finalContentDocumentLinkMap.values(); ' +  finalContentDocumentLinkMap.values());

        return finalContentDocumentLinkMap.values();
    }

    @AuraEnabled
    public static List<item> getFilesTree(Id recordId, String documentType){
        List<ContentDocumentLink> cdlfetechList = fetchDocument(recordId, documentType);

        List<string> filedataList = new List<String>();
        Map<String, List<String>> existingContentDocumentLinkMap = new Map<String, List<String>>();

        for(ContentDocumentLink contDocLinkObj : cdlfetechList){
            if(existingContentDocumentLinkMap.get(contDocLinkObj.ContentDocument.LatestPublishedVersion.DocumentType__c) == null){
                List<String> tempList = new List<String>();
                String strVal = contDocLinkObj.ContentDocument.id +';'+contDocLinkObj.ContentDocument.LatestPublishedVersion.Description + ','  + contDocLinkObj.ContentDocument.Title;
                templist.add(strval);
                existingContentDocumentLinkMap.put(contDocLinkObj.ContentDocument.LatestPublishedVersion.DocumentType__c, templist);
            } else {
                List<String> tempList = existingContentDocumentLinkMap.get(contDocLinkObj.ContentDocument.LatestPublishedVersion.DocumentType__c);
                String strVal = contDocLinkObj.ContentDocument.id +';'+contDocLinkObj.ContentDocument.LatestPublishedVersion.Description + ','  + contDocLinkObj.ContentDocument.Title;
                templist.add(strval);
                existingContentDocumentLinkMap.put(contDocLinkObj.ContentDocument.LatestPublishedVersion.DocumentType__c, templist);
            }
        }

        List<item> items = new List<item>();
        List<ContentDocumentLink> contDocumentListList = new List<ContentDocumentLink>();

        List<item> fileItems = new List<item>();
        for(String cat: existingContentDocumentLinkMap.keyset() ){
            Item itm = new Item();
            itm.name = 'ParentNode';
            itm.label = cat;
            itm.expanded = true;
            List<Item> linkItems = new List<item>(); 
            List<String> linkList = existingContentDocumentLinkMap.get(cat);
            for(String links : linkList){
                Item linkItem = new Item();
                linkItem.name= links.substring(0, links.indexOf(','));
                linkItem.label = links.substring( links.indexOf(',')+1);
                linkItem.expanded = true;
                linkItems.add(linkItem);
            }
            itm.items = linkItems;
            fileItems.add(itm);
        }
        return fileItems;
    }

    public class item{
        @AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public String name {get; set;}
        @AuraEnabled
        public Boolean expanded {get; set;}
        @AuraEnabled
        public List<item> items {get; set;}
        public item(){

        }
        public item(String label, String name, Boolean expanded, List<item> items){
            this.label = label;
            this.name = name;
            this.expanded = expanded;
            this.items = items;
        }
    }

    @AuraEnabled
    public static String getDownloadURL(Id recordId){
        ContentDocument contDoc =  [SELECT LatestPublishedVersion.Description FROM ContentDocument WHERE Id = :recordId];
        return contDoc.LatestPublishedVersion.Description;
    }

    public static String setName(String name){
        if(Test.isRunningTest()){
            name = 'test file name';
            return name;
        }
        else {
            return name;
        }
    }
}
public class BatchPhotoResize  { /* implements Database.Batchable<SObject>,Database.AllowsCallouts {
    
    public Datetime lastBatch;
    public Id objId;
    Boolean allCVNoFilter = false;
    static final Integer SIZE_LIMIT = 150000;
    //CONSTRUCTORS
    public BatchPhotoResize(Datetime batchTime){ new
        lastBatch = batchTime;
        allCVNoFilter = false;
    }
    public BatchPhotoResize(Boolean allCVNoFilter){
        this.allCVNoFilter = allCVNoFilter;
        lastBatch = Datetime.now();
    }
    public BatchPhotoResize setObjectiveId(Id ObjectiveId){
        objId = ObjectiveId;
        return this;
    }
    public void execute(Integer batchSize){
        Database.executeBatch(this,batchSize);   
    }
    

    //BATCH
    public Database.QueryLocator start(Database.BatchableContext BC){
        if(!allCVNoFilter){
            Map<Id,Objective_Display__c> objDisplays;
            
            if(objId != null){
                objDisplays = new Map<Id,Objective_Display__c>([SELECT Id FROM Objective_Display__c WHERE Status__c != 'Rejected' AND CreatedDate < 2021-02-18T00:00:00.000Z AND Objective_Account__r.Objective__c = :objId]);
            }else{
                objDisplays = new Map<Id,Objective_Display__c>([SELECT Id FROM Objective_Display__c WHERE Status__c != 'Rejected' AND CreatedDate < 2021-02-18T00:00:00.000Z]);
            }
            List<ContentDocumentLink> cdLinks = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN :objDisplays.keyset()];
            Set<Id> cdIds = new Set<Id>();
            for(ContentDocumentLink cdl : cdLinks){
                cdIds.add(cdl.ContentDocumentId);
            }
            return Database.getQueryLocator([SELECT Id FROM ContentVersion WHERE ContentDocumentId IN :cdIds AND ContentSize > :SIZE_LIMIT AND isLatest = true AND FILETYPE IN ('PNG','JPG','JPEG','GIF') AND CreatedDate < :lastBatch]);
        }else{
            return Database.getQueryLocator([SELECT Id FROM ContentVersion WHERE ContentSize > :SIZE_LIMIT AND isLatest = true AND FILETYPE IN ('PNG','JPG','JPEG','GIF') AND CreatedDate < :lastBatch]);
        }    
        
    }
    public void execute(Database.BatchableContext BC, List<ContentVersion> scope){
        //system.debug('execute');
        Set<Id> cvIds = new Set<Id>();
        for(ContentVersion cv : scope){
            cvIds.add(cv.Id);
        }
        List<ContentVersion> versionBatch = new List<ContentVersion>();
        versionBatch = [SELECT Id, ContentDocumentId, ContentLocation, FileType, Origin, OwnerId, PathOnClient, Title, VersionData FROM ContentVersion WHERE Id IN :cvIds];
        compressAndResize(versionBatch);
    }
    public void finish(Database.BatchableContext BC){
        //system.debug('finish');
    }

    //CALLOUT AND LOGIC
    public static void compressAndResize(List<ContentVersion> versionBatch) {
        
        String username = 'api';
        String password = 'Wmd8dBcl7DTfRML2y932kj7YHShpFLJ9';
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
        
        HttpResponse response;

        if(versionBatch.size() != 0){
            for(ContentVersion version : versionBatch){
                Blob fileData = version.VersionData;
                
                Http http1 = new Http();
                HttpRequest request1 = new HttpRequest();
                request1.setTimeout(120000);
                request1.setEndpoint('https://api.tinify.com/shrink');
                request1.setMethod('POST');
                request1.setHeader('Authorization', authorizationHeader);
                request1.setHeader('Content-Type', 'image');
                // Set the body as a JSON object
                request1.setBodyAsBlob(fileData);
                response = http1.send(request1);
                // Parse the JSON response
                if (response.getStatusCode() != 201) {
                    System.debug('The status code returned was not expected: ' +
                        response.getStatusCode() + ' ' + response.getStatus());
                } else {
                    //System.debug(response.getBody());
                    
                    TinyPNGReturnData data = (TinyPNGReturnData)JSON.deserialize(response.getBody(), TinyPNGReturnData.class);
                    String compressURL = data.output.url;

                    Http http2 = new Http();
                    HttpRequest request2 = new HttpRequest();
                    request2.setTimeout(120000);
                    request2.setEndpoint(compressURL);
                    request2.setMethod('POST');
                    request2.setHeader('Authorization', authorizationHeader);
                    request2.setHeader('Content-Type', 'application/json');
                    request2.setBody('{"resize": {"method": "fit","width": 550,"height": 500}}');
                    response = http2.send(request2);
                    
                    if (response.getStatusCode() != 200) {
                        System.debug('The status code returned was not expected: ' +
                            response.getStatusCode() + ' ' + response.getStatus());
                    } else {
                        version.VersionData = response.getBodyAsBlob();
                        version.Id = null;
                        version.ContentBodyId = null;
                    }
                }
            }    
        }else{
            system.debug('No Photos');
        }

        if(versionBatch.size() > 0){
            insert versionBatch;
        }        

    }

    public class TinyPNGReturnData {
        public InputData input;
        public OutputData output;
    }

    public class InputData {
        public String size;
        public String type;
    }

    public class OutputData {
        public String size;
        public String type;
        public String width;
        public String height;
        public String ratio;
        public String url;
    }
    */
}
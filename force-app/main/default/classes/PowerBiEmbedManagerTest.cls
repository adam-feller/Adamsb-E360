/**
 * Created by alexander.velitsky on 1/7/21.
 */

@IsTest
Public class PowerBiEmbedManagerTest {
   
    @isTest
    static void testgetPowerBiAccessToken(){ 
        // get auth settings from Custom Metadata Type reconrd
        Power_BI_Auth_Setting__mdt authSetting = Power_BI_Auth_Setting__mdt.getInstance('PowerBiApp');
        string TenantId = authSetting.TenantId__c;    
        string ClientId = authSetting.ClientId__c;    
        string ClientSecret = authSetting.ClientSecret__c;  
        // construct URL for client credentials flow
        String aadTokenEndpoint = 'https://login.microsoftonline.com/' + TenantId + '/oauth2/v2.0/token';
        Map<string, HttpCalloutMock> multiRequestMap = new Map<string, HttpCalloutMock> ();
        multiRequestMap.put(aadTokenEndpoint, new PowerBiAccessTokenMock());
        Test.setMock(HttpCalloutMock.class, new PowerBiEmbedManagerMock(multiRequestMap));
        PowerBiEmbedManager.getPowerBiAccessToken();
    }


    @isTest
    static void testgetEmbeddingDataForReport(){
        String recordId='1234';
        Test.startTest();
        // get auth settings from Custom Metadata Type reconrd
        Power_BI_Auth_Setting__mdt authSetting = Power_BI_Auth_Setting__mdt.getInstance('PowerBiApp');
        string TenantId = authSetting.TenantId__c;    
        string ClientId = authSetting.ClientId__c;    
        string ClientSecret = authSetting.ClientSecret__c;  
        // construct URL for client credentials flow
        String aadTokenEndpoint = 'https://login.microsoftonline.com/' + TenantId + '/oauth2/v2.0/token';
        Map<string, HttpCalloutMock> multiRequestMap = new Map<string, HttpCalloutMock> ();
        multiRequestMap.put(aadTokenEndpoint, new PowerBiAccessTokenMock());

        String workspaceId ='123';
        String reportId ='232';
       
        String urlGetReport = 'https://api.powerbi.com/v1.0/myorg/groups/' + WorkspaceId + '/reports/' + ReportId;
        multiRequestMap.put(urlGetReport, new PowerBiReportMock());

        String urlGetEmbedToken = 'https://api.powerbi.com/v1.0/myorg/groups/' + WorkspaceId + '/reports/' + ReportId + '/GenerateToken';
        multiRequestMap.put(urlGetEmbedToken, new PowerBiReportIdMock());

        Test.setMock(HttpCalloutMock.class, new PowerBiEmbedManagerMock(multiRequestMap));
        PowerBiEmbedManager.getEmbeddingDataForReport(WorkspaceId, ReportId, RecordId);
        Test.stopTest();
    }
    
  
}
public class BrewforceController {

    @AuraEnabled(cacheable = true)
    public static List<Integer> getSalesforceLicenses() {        
        List<Integer> licenses = new List<Integer>();
        
        //Get the Total and Used Licenses
    	UserLicense ul = [SELECT Id, Name, UsedLicenses, TotalLicenses FROM UserLicense WHERE Name = 'Salesforce' LIMIT 1];
        licenses.add(ul.TotalLicenses);
        licenses.add(ul.UsedLicenses);
        licenses.add(ul.TotalLicenses - ul.UsedLicenses);
    	
        //Get count of users that have System Administrator/Other Licenses
    	Integer cnt = [SELECT count() FROM User WHERE IsActive = true AND UserType='Standard' AND Profile.Name != 'Field Sales' AND Profile.Name != 'Call Center' AND Profile.Name != 'Call Center Supervisor' AND Profile.Name != 'Merchandiser' AND Profile.Name != 'Merchandiser Manager'];
        licenses.add(cnt);
        
        //Get count of users that have Field Sales Licenses
    	cnt = [SELECT count() FROM User WHERE IsActive = true AND UserType='Standard' AND Profile.Name = 'Field Sales'];
        licenses.add(cnt);
        
        //Get count of users that have Call Center Licenses
    	cnt = [SELECT count() FROM User WHERE IsActive = true AND UserType='Standard' AND (Profile.Name = 'Call Center' OR Profile.Name = 'Call Center Supervisor')];
        licenses.add(cnt);
        
        //Get count of users that have Merchandiser Licenses
    	cnt = [SELECT count() FROM User WHERE IsActive = true AND UserType='Standard' AND (Profile.Name = 'Merchandiser' OR Profile.Name = 'Merchandiser Manager')];
        licenses.add(cnt);
        
        //Get Messaging User Licenses
    	PermissionSetLicense pm = [SELECT MasterLabel, TotalLicenses, UsedLicenses FROM PermissionSetLicense WHERE MasterLabel = 'Messaging User'];
        licenses.add(pm.TotalLicenses);
        licenses.add(pm.UsedLicenses);
        licenses.add(pm.TotalLicenses - pm.UsedLicenses);

        //Get Service User Licenses
    	pm = [SELECT MasterLabel, TotalLicenses, UsedLicenses FROM PermissionSetLicense WHERE MasterLabel = 'Service User'];
        licenses.add(pm.TotalLicenses);
        licenses.add(pm.UsedLicenses);
        licenses.add(pm.TotalLicenses - pm.UsedLicenses);
        
        //Return all the license values
        return licenses;
	}
   
    @AuraEnabled( cacheable=true )  
    public static List<Brewforce_External_Links__mdt > getExternalLinks() {        
        List <Brewforce_External_Links__mdt> extLinks = [SELECT Id, MasterLabel, Image_URL__c, URL__c, Order__c FROM Brewforce_External_Links__mdt ORDER BY Order__c];
       	return extLinks; 
    }
  
}
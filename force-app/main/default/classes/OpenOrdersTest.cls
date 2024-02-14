@isTest
public class OpenOrdersTest {

    @isTest
    static void getPermissionTest(){
        Profile p = [SELECT Id FROM Profile WHERE name = 'Standard User'];
        Profile pAdmin = [SELECT Id FROM Profile WHERE name = 'System Administrator'];
        User u = new User(Alias = 'testU', Email='preSalessuser@test.com',
                          EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles',
                          ProfileId = p.Id,
                          UserName='testpermissionsetuser@test.com');
        insert u;
        
        User sysAdmin = new User(Alias = 'admin', Email='Adminsuser@test.com',
                          EmailEncodingKey='UTF-8', LastName='TestAdmin', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles',
                          ProfileId = pAdmin.Id,
                          UserName='testprofileuser@test.com');
        insert sysAdmin;
    	
        System.runAs(u){
            System.assertEquals(false, OpenOrders.getPermissionSet());
        }
        
        System.runAs(sysAdmin){
            System.assertEquals(true, OpenOrders.getPermissionSet());
        }
        
    }
        
}
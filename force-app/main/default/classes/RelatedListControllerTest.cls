/*
  @File Name          : RelatedListControllerTest.cls
  @Description        : This file containes the code needed for testing the RelatedListController
  @Author             : Slalom run:CRM
  @Group              : run:CRM
  @Last Modified By   : marshall.lanners@slalom.com
  @Last Modified On   : 6/18/2020, 10:00:00 AM
*/

@isTest
public class RelatedListControllerTest {

    @testSetup static void setup(){
        
        Account account = new Account(
            Name = 'test account'
        );
        
		insert account;
        
        Contact contact = new Contact(
            AccountId  = account.Id,
            Firstname = 'test firstname',
            LastName = 'test lastname'
        );
        
        insert contact;
        
        Opportunity opportunity1 = new Opportunity(
            AccountId  = account.Id,
            Name = 'test opportunity',
            Amount = 30000,
            StageName = 'Prospecting',
            CloseDate = System.today()
        );

        Opportunity opportunity2 = new Opportunity(
            AccountId  = account.Id,
            Name = 'test opportunity2',
            Amount = 30000,
            StageName = 'Prospecting',
            CloseDate = System.today()
        );
        
        Opportunity opportunity3 = new Opportunity(
            AccountId  = account.Id,
            Name = 'test opportunity3',
            Amount = 40000,
            StageName = 'Prospecting',
            CloseDate = System.today()
        );
        
        List<Opportunity> oppList = new List<Opportunity>();
        
        oppList.add(opportunity1);
        oppList.add(opportunity2);
        oppList.add(opportunity3);
        
        insert oppList;
    }
    
    // this is used to test if the admin profile has create and delete on the related list
    @isTest static void testPermissionAdmin(){
        Id id = [SELECT Id FROM Profile WHERE Name='System Administrator'].Id;
        
        User admin = new User(Alias = 'stnt', Email='SystemAdministrator123@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName='SystemAdministrator123@testorg.com');

        Id accountId = [SELECT Id FROM Account WHERE Name = 'test account'].Id;
        
        System.runAs(admin) {

            Test.startTest();
            
            RelatedListController.Wrapper wrapper = RelatedListController.getRelatedList(
                'testdata',
                accountId,
                true
            );

            Test.stopTest();
            
            System.assert(wrapper.recordList.size() == 3);
            System.assert(wrapper.canCreate == true);
            System.assert(wrapper.canDelete == true);
        }

    }
    
    // this is to test that the read only profile cannot create, delete related lit records.
    @isTest static void testPermissionReadOnly(){
        Id id = [SELECT Id FROM Profile WHERE Name='Read Only'].Id;
        
        User readOnly = new User(Alias = 'stnt', Email='ReadOnly12356@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing234', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName='ReadOnly12356@testorg.com');
        
        Id accountId = [SELECT Id FROM Account WHERE Name = 'test account'].Id;
        
        System.runAs(readOnly) {

            Test.startTest();

            RelatedListController.Wrapper wrapper = RelatedListController.getRelatedList(
                'testdata',
                accountId,
                true
            );

            Test.StopTest();

//            System.assert(wrapper.recordList.size() == 0);
            System.assert(wrapper.canCreate == false);
            System.assert(wrapper.canDelete == false);
        }
    }
    
    // used to make sure code still returns records if no where clause or record type is specified. 
    @isTest static void getRelatedLabelsTest() {
        Id accountId = [SELECT Id FROM Account WHERE Name = 'test account'].Id;
        
        Map<String, Map<String,String>> labels = RelatedListController.getRelatedLabels(
            'testdata',
            accountId,
            true
        );
        
        Set<String> keys = labels.keySet();
        System.assert(keys.contains('AccountId'));
    }
}
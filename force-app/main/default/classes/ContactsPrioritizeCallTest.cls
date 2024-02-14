@isTest
public class ContactsPrioritizeCallTest {

    static testMethod void prioritizeContacts() {        
        //Create Account
        Account testAccount = TestFactory.createAccount('Test Account', '20135', 'HDI', 'HDI Warehouse', null, '2345');
        
        Test.startTest();
      	//Create Contacts
      	Contact testContact = new Contact(FirstName='Test',LastName='Person',AccountId=testAccount.Id);
        insert testContact;
       	Contact testContact2 = new Contact(FirstName='Test2',LastName='Person',AccountId=testAccount.Id,Primary_Contact__c = true);
        insert testContact2;
        Test.stopTest();       
        //Check the priorities
        AccountContactRelation acccon1 = [SELECT Priority__c FROM AccountContactRelation WHERE ContactId = :testContact.Id];
        System.assertEquals('2', acccon1.Priority__c);
        AccountContactRelation acccon2 = [SELECT Priority__c FROM AccountContactRelation WHERE ContactId = :testContact2.Id];
        System.assertEquals('1', acccon2.Priority__c);  
    }         
}
@isTest
public class TTOAuthorizationTriggerHandler_Test {
    public static Id createAccount(String name) {
        Account a = new Account();
        a.Name = name;
        insert a;
        return a.Id;
    }

    public static Id createContact(String lastName, Id accToRelate) {
        Contact c = new Contact();
        c.LastName = lastName;
        c.AccountId = accToRelate;
        c.Phone = '1234567890';
        insert c;
        return c.Id;
    }

    static testMethod void ttoAuthWithExistingACR() {
        Id a = createAccount('Test Account 1');
        Id c = createContact('Test 1', a);
        
        Test.startTest();
            TTO_Authorization__c ttoAuthToInsert = new TTO_Authorization__c();
            ttoAuthToInsert.Contact__c = c;
            ttoAuthToInsert.Account__c = a;
            insert ttoAuthToInsert;

            List<AccountContactRelation> acrList = [SELECT Id FROM AccountContactRelation];
        Test.stopTest();

        system.assert(acrList.size() == 1);     
    }

    static testMethod void ttoAuthWithNoExistingACR() {
        Id a = createAccount('Test Account 1');
        Id a2 = createAccount('Test Account 2');
        Id c = createContact('Test 1', a);
        
        Test.startTest();
            TTO_Authorization__c ttoAuthToInsert = new TTO_Authorization__c();
            ttoAuthToInsert.Contact__c = c;
            ttoAuthToInsert.Account__c = a2;
            insert ttoAuthToInsert;

            List<AccountContactRelation> acrList = [SELECT Id FROM AccountContactRelation];
        Test.stopTest();

        system.assert(acrList.size() == 2);
    }
}
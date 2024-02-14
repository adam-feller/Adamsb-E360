@isTest 
public class TTOAuthorizationCleanup_Test {
    static testMethod void testCleanup() {
        List<Account> accountList = new List<Account>();
        for(Integer i=0; i < 200; i++) {
            Account acc = new Account();
            acc.Name = 'Name' + i;
            accountList.add(acc);
        }        
        insert accountList;

        List<Contact> contactList = new List<Contact>();
        for(Integer i=0; i < 200; i++) {
            Contact con = new Contact();
            con.LastName = 'Name' + i;
            con.AccountId = accountList[i].Id;
            contactList.add(con);
        }        
        insert contactList;

        List<TTO_Authorization__c> ttoAuthList = new List<TTO_Authorization__c>();
        for(Integer i=0; i < 200; i++) {
            TTO_Authorization__c ttoAuth = new TTO_Authorization__c();
            ttoAuth.Contact__c = contactList[i].Id;
            ttoAuth.Account__c = accountList[i].Id;
            ttoAuthList.add(ttoAuth);
        }        
        insert ttoAuthList;
        
        Order o1 = new Order();
        o1.AccountId = accountList[0].Id;
        o1.Status = 'Pending';
        o1.EffectiveDate = Date.today();
        insert o1;
        
        Order o2 = new Order();
        o2.AccountId = accountList[2].Id;
        o2.Status = 'Pending';
        o2.EffectiveDate = Date.today();
        insert o2;

        Test.setCreatedDate(o1.Id, Datetime.now().addMonths(-5));
        Test.startTest();
            TTOAuthorizationCleanup cleanup = new TTOAuthorizationCleanup();
            Database.executeBatch(cleanup);
            TTOAuthorizationCleanup_Scheduler.schedule();
        Test.stopTest();
    }
}
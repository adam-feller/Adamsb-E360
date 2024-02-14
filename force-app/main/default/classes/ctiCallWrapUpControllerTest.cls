@isTest
public class ctiCallWrapUpControllerTest {
    @TestSetup
    public static void testData(){
        //new account
        Account acc = new Account();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retail Store').getRecordTypeId();
        acc.Name = 'Happy Little Test Store';
        insert acc;
        
        //new contact
        Contact con = new Contact();
        con.FirstName = 'Happy';
        con.LastName = 'Tester';
        con.AccountId = acc.Id;
        insert con;
        
        //new task
        Task t = new Task();
        t.Subject = 'outbound test call';
        t.Account__c = acc.Id;
        t.WhatId = acc.Id;
        t.ActivityDate = Date.today();
        insert t;
    }

    @isTest
    public static void testUniqueId(){
        ctiCallWrapUpController cti = new CTIcallWrapUpController();
        cti.onSave();
        cti.getCallResultOptions();
        cti.myMethod();
    }
    
    @isTest
    public static void testRelAccount() {
        ctiCallWrapUpController cti = new CTIcallWrapUpController();
        Account acc = [SELECT Id FROM Account WHERE Name = 'Happy Little Test Store' LIMIT 1];
        cti.relObjId = acc.Id;
        cti.sObjType = 'Account';
        cti.onSave();
    }
    
    @isTest
    public static void testRelContact() {
        ctiCallWrapUpController cti = new CTIcallWrapUpController();
        Contact con = [SELECT Id FROM Contact WHERE Name = 'Happy Tester' LIMIT 1];
        cti.relObjId = con.Id;
        cti.sObjType = 'Contact';
        cti.onSave();
    }
    
    @isTest
    public static void testACR() {
    	ctiCallWrapUpController cti = new CTIcallWrapUpController();
        Account acc = [SELECT Id FROM Account WHERE Name = 'Happy Little Test Store' LIMIT 1];
        AccountContactRelation acr = [SELECT Id FROM AccountContactRelation WHERE AccountId = :acc.Id LIMIT 1];
        cti.relObjId = acr.Id;
        cti.sObjType = 'AccountContactRelation';
        cti.onSave();    
    }
}
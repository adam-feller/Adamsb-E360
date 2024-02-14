@isTest
public without sharing class CustomLookupControllerTest {

  @IsTest
  static void returnsListOfObjectsWithNoFilter(){
    Test.startTest();
    Integer loopInt = 5;
    List<Id> fixedSearchResults = new List<Id>();
    List<Account> acts = new List<Account>();
    for(Integer i =0 ; i <loopInt; i++){
      Account act = new Account();
      act.Name = 'Test Account ';
      acts.add(act);
    }
    insert acts;

    for(Account act : acts){
      fixedSearchResults.add(act.Id);
    }

    Test.setFixedSearchResults(fixedSearchResults);

    List<SObject> sobjs = CustomLookupController.fetchLookupData('Test', 'Account', '', 3);
  
    Test.stopTest();
    System.assert(sobjs.size() == 3, 'did not return expected results' + sobjs);
   }

   @IsTest
   static void returnsListOfObjectsWithFilter(){
    Test.startTest();
    Integer loopInt = 5;
    List<Id> fixedSearchResults = new List<Id>();
    List<Account> acts = new List<Account>();
    for(Integer i =0 ; i <loopInt; i++){
     Account act = new Account();
     act.Name = 'Test Account ';
     acts.add(act);
    }
    acts[0].Industry = 'Insurance';
    insert acts;

    for(Account act:acts){
     fixedSearchResults.add(act.Id);
    }

    Test.setFixedSearchResults(fixedSearchResults);

    List<SObject> sobjs = CustomLookupController.fetchLookupData('Test', 'Account', 'WHERE (Industry = \'Insurance\')', 3);
    
    Test.stopTest();
    System.assert(sobjs.size() == 1, 'did not return expected results' + sobjs);
   }

   @IsTest
   static void returnsEmptyList(){
       
    Test.startTest();
    List<SObject> sobjs = CustomLookupController.fetchLookupData('Test', 'Contact', '', 5);
    
    Test.stopTest();
    System.assert(sobjs.size() == 0, 'did not return no results' + sobjs);
   }

   @IsTest
   static void returnsDefaultRecord(){
       
    Test.startTest();
    Account act = new Account();
    act.Name = 'Test Account';
    insert act;
    Test.setFixedSearchResults(new List<Id>{act.Id});
    SObject sobj = CustomLookupController.fetchDefaultRecord(act.Id, 'Account');
    Sobject sobj2 = CustomLookupController.fetchDefaultRecord('', 'Account');
    System.assert(sobj.Id != null, 'sobject was not returned');
    Test.stopTest();
       
   }
   @IsTest
   static void noRecIdDoesNotReturnDefaultRecord(){
       
    Test.startTest();
    Sobject sobj2 = CustomLookupController.fetchDefaultRecord('', 'Account');
    System.assert(sobj2 == null, 'a sobject was returned');
    Test.stopTest();
   }

   @IsTest
   static void noSearchKeyReturnsBlank(){
       
    Test.startTest();
    List<Sobject> sobjs = CustomLookupController.fetchLookupData('', 'Account', '', 3);
    System.assert(sobjs.size() == 0, 'sobjects were returned');
    Test.stopTest();  
   }
   @IsTest
   static void noSobjectReturnsBlank(){
       
    Test.startTest();
    List<Sobject> sobjs = CustomLookupController.fetchLookupData('Test', 'thisObjectDoesntExist', '', 3);
    System.assert(sobjs.size() == 0, 'sobjects were returned');
    Test.stopTest(); 
   }
}
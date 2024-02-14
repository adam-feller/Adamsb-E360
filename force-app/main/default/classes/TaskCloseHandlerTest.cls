@isTest
public class TaskCloseHandlerTest {

    static final Id ACCOUNT_CUSTOMER_RECORDTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
    static final String USER_EMAIL_VALUE = 'newtest34673454User@gmail.com';
    static final String METADATA_DEVELOPERNAME_VALUE = 'Primary_POC';
    
    @TestSetup
    static void setup(){      
        User testUser = TestFactory.createUser(UserInfo.getProfileId(), UserInfo.getUserRoleId(), 'TestUser123421TEST@gmail.com', null, null);
        System.runAs(testUser){
            //create Account Owner
            Profile fsrProfile = [SELECT Id FROM Profile WHERE Name = 'Field Sales'];
        	UserRole testUserRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Admin'];
        	User testFSR = TestFactory.createUser(fsrProfile.Id, testUserRole.Id, USER_EMAIL_VALUE, null);
            
            AccountRequiredData__mdt firstMetadataObject = AccountRequiredData__mdt.getInstance(METADATA_DEVELOPERNAME_VALUE);
            List<Id> recordTypeIdsList = new List<Id>(BatchAccountMissingDataTask.getRecordTypeIds(firstMetadataObject.Account_Record_Type_Values_to_Apply_to__c));
            List<String> premiseList = new List<String>(BatchAccountMissingDataTask.getPremiseValues(firstMetadataObject.Premise_Values_to_Apply_to__c));
            //Create Accounts
            List<Account> acctsInsert = new List<Account>();
            for(Integer i=0; i<200; i++){
                Account testAccount = new Account();
                testAccount.Name = 'Test Company'+i;
                testAccount.OwnerId = testFSR.Id;
                testAccount.Status__c = 'A';
                testAccount.Premise__c = premiseList[0];
                testAccount.RecordTypeId = recordTypeIdsList[0];
                acctsInsert.add(testAccount);
            }
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.allowSave = true;
            Database.insert(acctsInsert, true);
        }
        BatchAccountMissingDataTask batchTaskCreation = new BatchAccountMissingDataTask();
        Database.executebatch(batchTaskCreation, 200); 
    }
    
    @isTest
    static void testCloseTasksWhenAccountFieldPopulated() {
        
        AccountRequiredData__mdt firstMetadataObject = AccountRequiredData__mdt.getInstance(METADATA_DEVELOPERNAME_VALUE);
        String field = firstMetadataObject.Field_API_Name__c;

        List <Account> acts = [SELECT Id FROM Account];
        Contact cnt = TestFactory.createContact(acts[0].Id, 'testFirstName', 'testLastName', 'testEmail@testEmail.testcom');

    
        Integer i = 0;
        for(Account act : acts){
            act.put(field, cnt.Id);
            i++;
        }
        Test.startTest();
            update acts;
        Test.stopTest();

        //Each task is marked as completed. Number is equal to number of metadata records
        List<Task> tasks = [SELECT Id, Status FROM Task WHERE Status = 'Completed' AND Field_With_Missing_Data__c = :field];
        System.assertEquals(tasks.size(), i, 'An incorrect number of Tasks where marked Completed');        
    }
}
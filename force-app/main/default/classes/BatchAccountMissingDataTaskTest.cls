@isTest
public class BatchAccountMissingDataTaskTest {

    static final string USER_EMAIL_VALUE = 'newtest34673454User@gmail.com';
    
    @TestSetup
    static void setup(){      
        User testUser = TestFactory.createUser(UserInfo.getProfileId(), UserInfo.getUserRoleId(), 'TestUser123421TEST@gmail.com', null, null);
        System.runAs(testUser){
            //create Account Owner
            Profile fsrProfile = [SELECT Id FROM Profile WHERE Name = 'Field Sales'];
        	UserRole testUserRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Admin'];
        	User testFSR = TestFactory.createUser(fsrProfile.Id, testUserRole.Id, USER_EMAIL_VALUE, null);
            //get Account criteria dynamically from custom metadata
            AccountRequiredData__mdt firstMetadataObject = AccountRequiredData__mdt.getAll().values()[0];
            List<Id> recordTypeIdsList = new List<Id>(BatchAccountMissingDataTask.getRecordTypeIds(firstMetadataObject.Account_Record_Type_Values_to_Apply_to__c));
            List<String> premiseList = new List<String>(BatchAccountMissingDataTask.getPremiseValues(firstMetadataObject.Premise_Values_to_Apply_to__c));
            //Create Accounts using metadata values
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
    }
    
    @isTest
    static void testNewMisingDataTaskCreated() {
        
        Test.startTest();
            BatchAccountMissingDataTask batchTaskCreation = new BatchAccountMissingDataTask();
            Database.executebatch(batchTaskCreation, 200);  
        Test.stopTest();

        String blankValue = AccountRequiredData__mdt.getAll().values()[0].Field_API_Name__c;
        List<Task> tasks = [SELECT Id, OwnerId FROM Task WHERE Field_With_Missing_Data__c = :blankValue];
        Id userId = [SELECT Id FROM User WHERE Email = :USER_EMAIL_VALUE LIMIT 1].Id;
        System.assertEquals(200, tasks.size(), 'An incorrect numner of Tasks where created');
        System.assertEquals(userId, tasks[0].OwnerId, 'The Account Owner does not match the Task OwnerId');
    }
}
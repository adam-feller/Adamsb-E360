@isTest
public class ObjectiveCompletionApprovalCallTest {

    //Objective Submission Display Record Type
    static Id displayRecordTypeId = Schema.SObjectType.Objective_Submission__c.getRecordTypeInfosByName().get('Display').getRecordTypeId();
    //Objective Submission Reset Record Type
    static Id resetRecordTypeId = Schema.SObjectType.Objective_Submission__c.getRecordTypeInfosByName().get('Reset').getRecordTypeId();
    
    @TestSetup
    private static void setup() {       
        //Create All User Data
        User user = [Select Id, ProfileId, UserRoleId FROM User WHERE Id = :UserInfo.getUserId()];
        User fsrSM;
        User fsrAM;
        User fsrAMNoMgr;
        User cbsSM;
        User cbsAM;
        User salesManager;

        System.runAs(user){
            fsrSM = TestFactory.createUser(user.ProfileId, user.UserRoleId, 'fsrSM@email.com', null);
            fsrAM = TestFactory.createUser(user.ProfileId, user.UserRoleId, 'fsrAM@email.com', fsrSM.Id);
            fsrAMNoMgr = TestFactory.createUser(user.ProfileId, user.UserRoleId, 'fsrAMNoMgr@email.com', null);    
            cbsSM = TestFactory.createUser(user.ProfileId, user.UserRoleId, 'cbsSM@email.com', null);
            cbsSM.VIP_Company__c = 'CBS';
            cbsSM.Assigned_route__c = 'S5678';
            update cbsSM;
            cbsAM = TestFactory.createUser(user.ProfileId, user.UserRoleId, 'cbsAM@email.com', cbsSM.Id);
            cbsAM.VIP_Company__c = 'CBS';
            cbsAM.Assigned_route__c = '1234';
            update cbsAM;
            salesManager = TestFactory.createUser(user.ProfileId, user.UserRoleId, 'salesManagerovl@email.com', null);
        }
        
        //Create All Account Data
        Account testAccountFSR = TestFactory.createAccount('Test Account FSR', '20135', 'HDI', 'HDI Warehouse', null, '2345');
        testAccountFSR.Sell_Type__c = 'INSIDE SALES';
        testAccountFSR.VIP_Instance__c = 'HDI';
        update testAccountFSR;

        Account testAccountCBS = TestFactory.createAccount('Test Account CBS', '20136', 'CBS', 'CBS Warehouse', null, '6789');
        testAccountCBS.Sell_Type__c = 'PRESELL';
        testAccountCBS.Account_Manager_Route__c = '1234';
        testAccountCBS.Sales_Manager_Route__c = '5678';
        testAccountCBS.VIP_Instance__c = 'CBS';
        update testAccountCBS;

        Account testAccount = TestFactory.createAccount('Test Account', '20136', 'HDI', 'HDI Warehouse', null, '6789');
        testAccount.Sell_Type__c = 'PRESELL';
        testAccount.VIP_Instance__c = 'HDI';
        testAccount.Sales_Manager_Id__c = salesManager.Id;
        update testAccount;

        Account testAccountNoSlsMgr = TestFactory.createAccount('Test Account', '20136', 'HDI', 'HDI Warehouse', null, '6789');
        testAccountNoSlsMgr.Sell_Type__c = 'PRESELL';
        testAccountNoSlsMgr.VIP_Instance__c = 'HDI';
        update testAccountNoSlsMgr;
        
        //Create all Objective Data
        
        //*******
        // RESET
        //*******
        Objective__c testResetObjective = new Objective__c();
        testResetObjective.Name = 'Test Reset';
        testResetObjective.BU__c = 'HDI';
        testResetObjective.Objective_Type__c = 'Reset';
        testResetObjective.Start_Date__c = System.Today() - 1;
        testResetObjective.End_Date__c = System.Today() + 1;
        testResetObjective.Goal__c = 100;
        testResetObjective.Picture_Required__c = true;
        insert testResetObjective;
        
        Objective_Account__c testResetObjectiveAccount = new Objective_Account__c();
        testResetObjectiveAccount.Objective__c = testResetObjective.Id;
        testResetObjectiveAccount.recordTypeId = Schema.getGlobalDescribe().get('Objective_Account__c').getDescribe().getRecordTypeInfosByName().get('Reset').getRecordTypeId();
        testResetObjectiveAccount.Status__c = 'Incomplete';
        testResetObjectiveAccount.Account__c = testAccountFSR.Id;
        testResetObjectiveAccount.Pictured_Required__c = true;
        insert testResetObjectiveAccount;
        
        Objective_Submission__c testResetObjectiveSubmission = new Objective_Submission__c();
        testResetObjectiveSubmission.RecordTypeId = resetRecordTypeId;
        testResetObjectiveSubmission.Objective_Account__c = testResetObjectiveAccount.Id;
        insert testResetObjectiveSubmission;


        //********
        // DISPLAY
        //********
        //CBS
        Objective__c testDisplayObjective = new Objective__c();
        testDisplayObjective.Name = 'Test Display';
        testDisplayObjective.BU__c = 'CBS';
        testDisplayObjective.Objective_Type__c = 'Display';
        testDisplayObjective.Start_Date__c = System.Today() - 1;
        testDisplayObjective.End_Date__c = System.Today() + 1;
        testDisplayObjective.Goal__c = 100;
        testDisplayObjective.Picture_Required__c = true;
        insert testDisplayObjective;
        
        //Not CBS
        Objective__c testDisplayObjective2 = new Objective__c();
        testDisplayObjective2.Name = 'Test Display';
        testDisplayObjective2.BU__c = 'HDI';
        testDisplayObjective2.Objective_Type__c = 'Display';
        testDisplayObjective2.Start_Date__c = System.Today() - 1;
        testDisplayObjective2.End_Date__c = System.Today() + 1;
        testDisplayObjective2.Goal__c = 100;
        testDisplayObjective2.Picture_Required__c = true;
        insert testDisplayObjective2;
        
        //Create Objective Account/Submission (Display)
        Objective_Account__c testCBSObjectiveAccount = new Objective_Account__c();
        testCBSObjectiveAccount.Objective__c = testDisplayObjective.Id;
        testCBSObjectiveAccount.recordTypeId = Schema.getGlobalDescribe().get('Objective_Account__c').getDescribe().getRecordTypeInfosByName().get('Display').getRecordTypeId();
        testCBSObjectiveAccount.Status__c = 'Incomplete';
        testCBSObjectiveAccount.Account__c = testAccountCBS.Id;
        testCBSObjectiveAccount.Pictured_Required__c = true;
        insert testCBSObjectiveAccount;

        Objective_Submission__c testCBSObjectiveSubmission = new Objective_Submission__c();
        testCBSObjectiveSubmission.RecordTypeId = displayRecordTypeId;
        testCBSObjectiveSubmission.Objective_Account__c = testCBSObjectiveAccount.Id;
        insert testCBSObjectiveSubmission;


        Objective_Account__c testPRESELLObjectiveAccount = new Objective_Account__c();
        testPRESELLObjectiveAccount.Objective__c = testDisplayObjective.Id;
        testPRESELLObjectiveAccount.recordTypeId = Schema.getGlobalDescribe().get('Objective_Account__c').getDescribe().getRecordTypeInfosByName().get('Display').getRecordTypeId();
        testPRESELLObjectiveAccount.Status__c = 'Incomplete';
        testPRESELLObjectiveAccount.Account__c = testAccount.Id;
        testPRESELLObjectiveAccount.Pictured_Required__c = true;
        insert testPRESELLObjectiveAccount;
        
        Objective_Account__c testPRESELLObjectiveAccountNoSlsMgr = new Objective_Account__c();
        testPRESELLObjectiveAccountNoSlsMgr.Objective__c = testDisplayObjective.Id;
        testPRESELLObjectiveAccountNoSlsMgr.recordTypeId = Schema.getGlobalDescribe().get('Objective_Account__c').getDescribe().getRecordTypeInfosByName().get('Display').getRecordTypeId();
        testPRESELLObjectiveAccountNoSlsMgr.Status__c = 'Incomplete';
        testPRESELLObjectiveAccountNoSlsMgr.Account__c = testAccountNoSlsMgr.Id;
        testPRESELLObjectiveAccountNoSlsMgr.Pictured_Required__c = true;
        insert testPRESELLObjectiveAccountNoSlsMgr;        

        Objective_Submission__c testPRESELLObjectiveDisplay = new Objective_Submission__c();
        testPRESELLObjectiveDisplay.Objective_Account__c = testPRESELLObjectiveAccount.Id;
        testPRESELLObjectiveDisplay.RecordTypeId = displayRecordTypeId;
        insert testPRESELLObjectiveDisplay;
        
        Objective_Submission__c testPRESELLObjectiveDisplayNoSlsMgr = new Objective_Submission__c();
        testPRESELLObjectiveDisplayNoSlsMgr.Objective_Account__c = testPRESELLObjectiveAccountNoSlsMgr.Id;
        testPRESELLObjectiveDisplayNoSlsMgr.RecordTypeId = displayRecordTypeId;
        insert testPRESELLObjectiveDisplayNoSlsMgr;
        
        Objective_Account__c testINSIDESALESObjectiveAccount = new Objective_Account__c();
        testINSIDESALESObjectiveAccount.Objective__c = testDisplayObjective2.Id;
        testINSIDESALESObjectiveAccount.recordTypeId = Schema.getGlobalDescribe().get('Objective_Account__c').getDescribe().getRecordTypeInfosByName().get('Display').getRecordTypeId();
        testINSIDESALESObjectiveAccount.Status__c = 'Incompete';
        testINSIDESALESObjectiveAccount.Account__c = testAccountFSR.Id;
        testINSIDESALESObjectiveAccount.Pictured_Required__c = true;
        insert testINSIDESALESObjectiveAccount;

        Objective_Submission__c testINSIDESALESObjectiveDisplay = new Objective_Submission__c();
        testINSIDESALESObjectiveDisplay.Objective_Account__c = testINSIDESALESObjectiveAccount.Id;
        testINSIDESALESObjectiveDisplay.RecordTypeId = displayRecordTypeId;
        insert testINSIDESALESObjectiveDisplay;
    } 
    
    //Data Get Methods
    static Objective_Submission__c getResetObjectiveSubmission() {
        return [SELECT Id
                FROM Objective_Submission__c WHERE RecordTypeId = :resetRecordTypeId LIMIT 1];
    }

    static List<Objective_Submission__c> getObjectiveSubmissions() {
        return [SELECT Id
                FROM Objective_Submission__c WHERE RecordTypeId = :displayRecordTypeId];
    }
    
    static User getFSRUser() {
        return [SELECT Id
                FROM User
                WHERE Username = 'fsrAM@email.com'];
    }
    
    static User getFSRUserNoMgr() {
        return [SELECT Id
                FROM User
                WHERE Username = 'fsrAMNoMgr@email.com'];
    }
    
    static User getCBSUser() {
        return [SELECT Id
                FROM User
                WHERE Username = 'cbsAM@email.com'];
    }

    //Test Methods FSR, CBS and PRESELL
    static testMethod void FSRTest() {
        Objective_Submission__c testResetObjectiveSubmission = getResetObjectiveSubmission();
        User fsrAM = getFSRUser();
        
        List <ObjectiveCompletionApprovalCall.FlowInput> inputList = new List <ObjectiveCompletionApprovalCall.FlowInput>();
        ObjectiveCompletionApprovalCall.FlowInput flowInput = new ObjectiveCompletionApprovalCall.FlowInput();
        flowInput.recordIdToApprove = testResetObjectiveSubmission.Id;
        flowInput.submitterId = fsrAM.Id;
        inputList.add(flowInput);

        Test.startTest();
        ObjectiveCompletionApprovalCall.callObjectiveApprovalProcess(inputList);
        Test.stopTest();
    }
    
    static testMethod void FSRTestNoMgr() {
        Objective_Submission__c testResetObjectiveSubmission = getResetObjectiveSubmission();
        User fsrAMNoMgr = getFSRUserNoMgr();
        
        List <ObjectiveCompletionApprovalCall.FlowInput> inputList = new List <ObjectiveCompletionApprovalCall.FlowInput>();
        ObjectiveCompletionApprovalCall.FlowInput flowInput = new ObjectiveCompletionApprovalCall.FlowInput();
        flowInput.recordIdToApprove = testResetObjectiveSubmission.Id;
        flowInput.submitterId = fsrAMNoMgr.Id;
        inputList.add(flowInput);

        Test.startTest();
        ObjectiveCompletionApprovalCall.callObjectiveApprovalProcess(inputList);
        Test.stopTest();
    }
    
    static testMethod void ObjectiveSubmissionsTest() {
        List<Objective_Submission__c> testObjectiveSubmissions = getObjectiveSubmissions();
        User cbsAM = getCBSUser();

        Test.startTest();
        for(Objective_Submission__c objSubmission : testObjectiveSubmissions){
            List <ObjectiveCompletionApprovalCall.FlowInput> inputList = new List <ObjectiveCompletionApprovalCall.FlowInput>();
            ObjectiveCompletionApprovalCall.FlowInput flowInput = new ObjectiveCompletionApprovalCall.FlowInput();
            flowInput.recordIdToApprove = objSubmission.Id;
            flowInput.submitterId = cbsAM.Id;
            inputList.add(flowInput);
            
            ObjectiveCompletionApprovalCall.callObjectiveApprovalProcess(inputList);
        }
        Test.stopTest();
    }

}
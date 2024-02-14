@isTest
public class BatchSendManagerSubordinateAuditTest {
	
    @isTest
    public static void BatchSendManagerSubordinateAuditTest() {
               
        Test.startTest();
        	BatchSendManagerSubordinateAudit.callBatchSendManagerSubordinateAudit();        	
        	Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();
        
		//Assertion
        List<Error_Log__c> logs = [SELECT Id FROM Error_Log__c]; 
        Assert.isTrue(logs.size() == 0, 'Error(s) were logged.');
    }
    
    @isTest
    public static void BatchSendManagerSubordinateAuditSingleManagerTest() {
               
        Test.startTest();
        	Database.executeBatch(new BatchSendManagerSubordinateAudit('0054v00000EQyoYAAT'));
        	Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();
        
		//Assertion
		List<Error_Log__c> logs = [SELECT Id FROM Error_Log__c]; 	
        Assert.isTrue(logs.size() == 0, 'Error(s) were logged.');
    }
}
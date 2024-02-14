public class ErrorLog {

    public static void insertErrorLog(String errorMsg, String lineNumber, String className, String methodName){
        Error_Log__c log = new Error_Log__c();
        log.Class_Name__c = className;
        log.Method_Name__c = methodName;
        log.Line_Number__c = lineNumber;
        log.Error_Msg__c = errorMsg.left(255);
        insert log;
    }

    public static Error_Log__c returnErrorLog(String errorMsg, String lineNumber, String className, String methodName){
        Error_Log__c log = new Error_Log__c();
        log.Class_Name__c = className;
        log.Method_Name__c = methodName;
        log.Line_Number__c = lineNumber;
        log.Error_Msg__c = errorMsg.left(255);
        return log;
    }
}
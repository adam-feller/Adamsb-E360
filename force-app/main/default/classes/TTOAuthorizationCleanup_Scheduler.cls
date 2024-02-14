global class TTOAuthorizationCleanup_Scheduler implements Schedulable {
    public static String sched = '0 00 00 * * ?';  //Every Day at Midnight 

    global static String schedule() {
        TTOAuthorizationCleanup_Scheduler ttoAuthCleanupScheduler = new TTOAuthorizationCleanup_Scheduler();
        return System.schedule('TTO Authorization Cleanup Test', sched, ttoAuthCleanupScheduler);
    }
    
    global void execute(SchedulableContext sc) {
        TTOAuthorizationCleanup ttAuthCleanup = new TTOAuthorizationCleanup();
        ID batchProcessId = Database.executeBatch(ttAuthCleanup);
    }
}
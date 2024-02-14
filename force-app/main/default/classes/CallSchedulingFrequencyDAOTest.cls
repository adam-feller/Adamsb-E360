@isTest
private class CallSchedulingFrequencyDAOTest {

    @isTest
    static void testGetCallSchedlingFrequency(){
        Test.startTest();
            List<Call_Scheduling_Frequency__mdt> callScheduleList = CallSchedulingFrequencyDAO.getCallSchedlingFrequency();
        Test.stopTest();

        System.assertEquals(!callScheduleList.isEmpty(), true, 'callScheduleList should not be empty');
    }
}
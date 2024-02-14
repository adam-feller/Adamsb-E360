@isTest
public class ChatbotNextAvailableDay_Test {
    static testMethod void checkNextDay() {
        List<ChatbotNextAvailableDay.ResponseInput> riList = new List<ChatbotNextAvailableDay.ResponseInput>();
        ChatbotNextAvailableDay.ResponseInput ri = new ChatbotNextAvailableDay.ResponseInput();
        ri.createdDate = DateTime.now();
        riList.add(ri);

        Test.startTest();
        List<ChatbotNextAvailableDay.ResponseOutput> roList = ChatbotNextAvailableDay.getNextAvailableDay(riList);
        Test.stopTest();

        System.assert(roList[0].nextDay == 'Monday' || roList[0].nextDay == 'tomorrow' || roList[0].nextDay == 'Sunday');
    }
}
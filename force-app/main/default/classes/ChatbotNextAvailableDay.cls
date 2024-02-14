public with sharing class ChatbotNextAvailableDay {
    @InvocableMethod(label='Get Available Next Day')
    public static List<ResponseOutput> getNextAvailableDay(List<ResponseInput> riList) {
        ResponseInput ri = new ResponseInput();
        ResponseOutput ro = new ResponseOutput();
        List<ResponseOutput> roList = new List<ResponseOutput>();
    
        if(riList == null || riList.size() <= 0) { return null; }

        ri = riList[0];

        DateTime today = DateTime.now();
        String formattedDate = today.format('EEE, MMM d yyyy HH:mm:ss');
        String nextDayReturn = '';
              
        if(!string.isEmpty(formattedDate) && formattedDate.length() >= 3) {
            switch on (formattedDate.substring(0, 3)) {
                when 'Fri' {
                    nextDayReturn = 'Sunday';
                } when else {
                    nextDayReturn = 'tomorrow';
                }
            }
        } 

        ro.nextDay = nextDayReturn;
        roList.add(ro);

        return roList;
    }

    public class ResponseInput {
        @InvocableVariable
        public DateTime createdDate;
    }

    public class ResponseOutput {
        @InvocableVariable
        public string nextDay;
    }
}
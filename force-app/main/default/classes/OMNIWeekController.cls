public with sharing class OMNIWeekController {
    public static Integer currentWeek;
    public static Integer currentMonth;
    public static Integer currentYear;

    @AuraEnabled
    public static String getOMNIWeek(){
        currentWeek = currentWeek != null ? currentWeek : Integer.valueOf(DateTime.newInstance(Date.today().toStartOfWeek(),Time.NewInstance(12,0,0,0)).format('w'));
        currentMonth = currentMonth != null ? currentMonth : Date.today().Month();
        // The last week of December defaults to 1 so we have to override it to 53
        if(currentMonth == 12 && currentWeek == 1){
            currentWeek = 53;
        }
        String currentYearDevName = currentYear != null ? 'X'+String.valueOf(currentYear) : 'X'+String.valueOf(System.Today().year());
        // Get schedule start week values for the begining of the year in custom metadata
        OMNI_Week_Settings__mdt startValues = OMNI_Week_Settings__mdt.getInstance(currentYearDevName);
        Integer startWeekNum = Integer.valueOf(startValues.Year_Number_Start_Week_Picklist__c);
        String startSalesWeekValue = startValues.Year_Sales_Week_Start_Picklist__c;
        
        //sets the beginning sales week schedule for the year
        List<String> salesWeeks = new list<String> {'A1','B2','A3','B4'};
        if(startSalesWeekValue == 'B2'){
            salesWeeks = new list<String> {'B2','A3','B4','A1'};
        }
        if(startSalesWeekValue == 'A3'){
            salesWeeks = new list<String> {'A3','B4','A1','B2'};
        }
        if(startSalesWeekValue == 'B4'){
            salesWeeks = new list<String> {'B4','A1','B2','A3'};
        }

        String currentSalesWeek = 'A1';
        Integer currentSalesWeekNum = 1;
        Integer weekCount = 0;
        //iterates over the current week of the year
        for(Integer i = 0; i < currentWeek; i++){
            //sales week value repeats every 4 weeks
            if(weekCount > 3){
                weekCount = 0;
            }
            //week number repeats every 12 weeks
            if(startWeekNum > 12){
                startWeekNum = 1;
            }
            //sets Sales Week. E.g. A1;
            currentSalesWeek = salesWeeks[weekCount];
            //set Sales Week number. e.g 1 - 12
            currentSalesWeekNum = startWeekNum;
           
            startWeekNum++;
            weekCount++;
        }
        String returnStr = 'FSR/OMNI Visit Week: ' + currentSalesWeek +  ', ' + String.ValueOf(currentSalesWeekNum);
       
        return returnStr;
    }
    

}
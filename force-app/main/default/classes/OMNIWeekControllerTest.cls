@isTest
public class OMNIWeekControllerTest {
        @isTest 
        static void testGetOMNIWeek() {
            String weekNumber = DateTime.newInstance(Date.newInstance(2023, 11, 8).toStartOfWeek(), 
                                                Time.NewInstance(12,0,0,0)).format('w');
    		Integer month = Date.newInstance(2023, 11, 8).Month();
            Integer year = 2023;
            
            OMNIWeekController.currentWeek = Integer.valueOf(weekNumber);
            OMNIWeekController.currentMonth = month;
            OMNIWeekController.currentYear = year;
            String salesWeek = OMNIWeekController.getOMNIWeek();
            System.assertEquals('FSR/OMNI Visit Week: B2, 10', salesWeek, 'returned string incorrect');
    }
    
        @isTest 
        static void testGetOMNILastWeek() {
            String weekNumber = DateTime.newInstance(Date.newInstance(2023, 12, 28).toStartOfWeek(), 
                                                Time.NewInstance(12,0,0,0)).format('w');
    		Integer month = Date.newInstance(2023, 12, 28).Month();
            Integer year = 2023;
            
            OMNIWeekController.currentWeek = Integer.valueOf(weekNumber);
            OMNIWeekController.currentMonth = month;
            OMNIWeekController.currentYear = year;
            String salesWeek = OMNIWeekController.getOMNIWeek();
            System.assertEquals('FSR/OMNI Visit Week: A1, 5', salesWeek, 'returned string inccorect');
    }
}
public with sharing class OutboundCallRedistribution {
    //Employee ID to Shift Map
    public static Map<String,List<Shift__c>> employeeIDtoShiftMap = new Map<String, List<Shift__c>>();

    //Employee ID to Shift Map
    public static Map<String,List<Out_Of_Office__c>> employeeIDtoOOOMap = new Map<String, List<Out_Of_Office__c>>();

    //Employee ID to Task Map
    public static Map<String,List<Task>> initialEmployeeIdtoTaskMap = new Map<String, List<Task>>();
    
    //Employee ID to Hours Map
    public static Map<String, Decimal> employeeIdtoHours = new Map<String, Decimal>();

    //Key Values
    public static DateTime startTime;
    public static DateTime endTime;
    public static Decimal numberOfHours;
    public static Integer taskCount;

    //Number of Calls Per Hour and Target Average Calls
    public static Decimal callsPerHour;
    public static Integer targetAverage;

    //Buckets
    public static Map<String,List<Task>> underAverageMap = new Map<String, List<Task>>();
    public static Map<String,List<Task>> atAverageMap = new Map<String, List<Task>>();
    public static Map<String,List<Task>> overAverageMap = new Map<String, List<Task>>();
    public static Map<String,List<Task>> unclaimed = new Map<String, List<Task>>();
        
    //Lists
    public static List<Task> tasksToRedistributeSpanish = new List<Task>();
    public static List<Task> tasksToResdistribute = new List<Task>();
    public static List<Task> tasksToUpdate = new List<Task>();

    public static void redistributeOutboundCalls(List<Task> todayTaskList, String employeeToRedistribute) {
        DateTime currentDateTime = System.now();   //For testing can addDays and addHours (i.e., .addDays(3).addHours(-8))
        if (Test.isRunningTest()) {
            currentDateTime = Datetime.newInstance(currentDateTime.year(), currentDateTime.month(), currentDateTime.day(), 0, 0, 0);  //For testing we want the current DateTime to be the beginning of the day
        }        
        Id callTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId();
        String CALL_CENTER_PROFILE = 'Call Center';
        
        //First we want to update Today's Start and End Times to get any Shift Changes for the day
        ShiftUtilities.updateAllShifts();
        //Get a list of all the Active shifts
        List<Shift__c> employeeShifts = ShiftDAO.getShifts();

        //Obtain Employee ID to Shift Map
        for(Shift__c shft : employeeShifts){
            if (String.valueOf(shft.Employee__c) != employeeToRedistribute) {   //If we are redistributing for this employee we don't want to add to the shift map
            	if (employeeIDtoShiftMap.containsKey(shft.Employee__c)) {
	                employeeIDtoShiftMap.get(shft.Employee__c).add(shft);
	            } else {
	                List<Shift__c> shiftList = new List<Shift__c>();
	                shiftList.add(shft);
	                employeeIDtoShiftMap.put(shft.Employee__c, shiftList);
	            }
            }
        }        
        
        //Retrieve all Out Of Offices for Today
        List<Out_Of_Office__c> outOfOfficeList = OutOfOfficeDAO.getOutOfOffices(currentDateTime.date(), currentDateTime.date());

        //Obtain Employee Id to Out of Office Map
        for (Out_Of_Office__c ooo : OutOfOfficeList) {
            if (employeeIDtoOOOMap.containsKey(ooo.Who_Is_Out__c)) {
                List<Out_Of_Office__c> oooList = employeeIDtoOOOMap.get(ooo.Who_Is_Out__c);
                oooList.add(ooo);
            } else {
                List<Out_Of_Office__c> oooList = new List<Out_Of_Office__c>();
                oooList.add(ooo);
                employeeIDtoOOOMap.put(ooo.Who_Is_Out__c, oooList);
            }
        }
        
        Map<Id, List<Shift__c>> shiftsToAdd = new Map<Id, List<Shift__c>>();
        Map<Id, List<Integer>> shiftsToRemove = new Map<Id, List<Integer>>();

        //Remove or Edit Shifts which conflict with Out Of Office
        for (String oooEmployeeId : employeeIdToOOOMap.keySet()) {
            for (Out_Of_Office__c ooo : employeeIDtoOOOMap.get(oooEmployeeId)) {
                Date startDateDate = ooo.Start_Date__c.date();
                Date endDateDate = ooo.End_Date__c.date();
                Time startDateTime = ooo.Start_Date__c.time();
                Time endDateTime = ooo.End_Date__c.time();

                //If there is a shift for an Out of Office Employee
                if (employeeIDtoShiftMap.containsKey(oooEmployeeId)) {
                    List<Shift__c> employeeShiftList = employeeIDtoShiftMap.get(oooEmployeeId);
                    if (startDateDate != currentDateTime.date() && endDateDate != currentDateTime.date()) {  //Today is not the start or end of the OOO, so remove
                        employeeIDtoShiftMap.remove(oooEmployeeId);
                    } else if (startDateDate == currentDateTime.date() && endDateDate == currentDateTime.date()) { //OOO is only for today
                        Integer index = 0;
                        for (Shift__c shft : employeeShiftList) {
                            if (shft.Today_Shift_Start_Time__c == startDateTime && shft.Today_Shift_End_Time__c == endDateTime) { //OOO Start and End Times match the Shift Start and End Times, so remove
                                addToRemoveMapList(shiftsToRemove, OOOEmployeeId, index);
                            } else if (shft.Today_Shift_Start_Time__c <= startDateTime && shft.Today_Shift_End_Time__c >= endDateTime) { //OOO is contained inside shift
                                Shift__c newShift = new Shift__c();
                                newShift.Today_Shift_Start_Time__c = endDateTime;
                                newShift.End_Time__c = shft.Today_Shift_End_Time__c;
                                addtToAddMapList(shiftsToAdd, oooEmployeeId, newShift);
                                shft.End_Time__c = startDateTime;
                            } else if (shft.Today_Shift_Start_Time__c < startDateTime && shft.Today_Shift_End_Time__c <= endDateTime && shft.Today_Shift_End_Time__c > startDateTime) { //OOO overlaps with the Shift End Time
                                shft.End_Time__c = startDateTime;
                            } else if (shft.Today_Shift_Start_Time__c >= startDateTime && shft.Today_Shift_End_Time__c >= endDateTime && shft.Today_Shift_Start_Time__c < endDateTime) { //OOO overlaps with the Shift Start Time
                                shft.Today_Shift_Start_Time__c = endDateTime;
                            } else if(shft.Today_Shift_Start_Time__c >= startDateTime && shft.Today_Shift_End_Time__c <= endDateTime) { //Shift is contained within OOO
                                addToRemoveMapList(shiftsToRemove, OOOEmployeeId, index);
                            }
                            index += 1;
                        }
                    } else if (startDateDate == currentDateTime.date() && endDateDate != currentDateTime.date()) {  //OOO starts today, but doesn't end today
                        Time tempEndDateTime = Time.newInstance(23,59,59,0);
                        Integer index = 0;
                        for (Shift__c shft : employeeShiftList) {
                            if( startDateTime <= shft.Today_Shift_Start_Time__c &&  tempEndDateTime >= shft.Today_Shift_End_Time__c){//Shift is contained inside the OOO
                                addToRemoveMapList(shiftsToRemove, OOOEmployeeId, index);
                            } else if (shft.Today_Shift_Start_Time__c < startDateTime && shft.Today_Shift_End_Time__c < tempEndDateTime) { //OOO overlaps with the Shift End Time
                                shft.End_Time__c = startDateTime;
                            } else if (shft.Today_Shift_Start_Time__c > startDateTime && shft.Today_Shift_End_Time__c > tempEndDateTime) { //OOO overlaps with the Shift Start Time (this shouldn't happen in this scenario)
                                System.debug('StartDate unexpected Scenario');
                            }
                            index += 1;
                        }
                    } else if (startDateDate != currentDateTime.date() && endDateDate == currentDateTime.date()) { //OOO ends today but doesn't start today
                        Time tempStartDateTime = Time.newInstance(0,0,0,0);
                        Integer index = 0;
                        for (Shift__c shft : employeeShiftList) {
                            if( tempStartDateTime <= shft.Today_Shift_Start_Time__c && endDateTime >= shft.Today_Shift_End_Time__c) { //Shift is contained inside the OOO
                                addToRemoveMapList(shiftsToRemove, OOOEmployeeId, index);
                            } else if (shft.Today_Shift_Start_Time__c < tempStartDateTime && shft.Today_Shift_End_Time__c < endDateTime ){ //OOO overlaps with the Shift Start Time
                                System.debug('EndDate unexpected Scenario');
                            } else if (shft.Today_Shift_Start_Time__c > tempStartDateTime && shft.Today_Shift_End_Time__c > endDateTime) { //OOO overlaps with the Shift End Time (this shouldn't happen in this scenario)
                                shft.Today_Shift_Start_Time__c = endDateTime;
                            }
                            index += 1;
                        }
                    }
                }
            }
        }

        //Obtain Employee ID to Hours Map
        Decimal numHours;
        for (Shift__c shft : employeeShifts) {
            if (String.valueOf(shft.Employee__c) != employeeToRedistribute) {   //If we are redistributing for this employee we don't want to add to the hours map
            	startTime = DateTime.newInstance(currentDateTime.date(), shft.Today_Shift_Start_Time__c);
				endTime = DateTime.newinstance(currentDateTime.date(), shft.Today_Shift_End_Time__c);
            	if (currentDateTime.getTime() < startTime.getTime()) {
	            	numHours = Decimal.valueOf((endTime.getTime() - startTime.getTime()))/3600000;
	            } else if (currentDateTime.getTime() > endTime.getTime()) {
	                numHours = 0;
    	        } else if (currentDateTime.getTime() > startTime.getTime() && currentDateTime.getTime() < endTime.getTime()) {
    	            numHours = Decimal.valueOf((endTime.getTime() - currentDateTime.getTime()))/3600000;
	            }
    	        if (employeeIdtoHours.containsKey(shft.Employee__c)) {
	                employeeIdtoHours.put(shft.Employee__c, employeeIdtoHours.get(shft.Employee__c) + numHours);
	            } else {
	                employeeIdtoHours.put(shft.Employee__c, numHours);
    	        }
            }
        }

        for (Id employeeId : shiftsToAdd.keySet()) {
            employeeIDtoShiftMap.get(employeeId).addAll(shiftsToAdd.get(employeeId));
        }

        for (Id employeeId : shiftsToRemove.keySet()) {
            for (Integer index : shiftsToRemove.get(employeeId)) {
                if (employeeIDtoShiftMap.containsKey(employeeId)) {
                    if (employeeIDtoShiftMap.get(employeeId).size() >= index+1) {
                		employeeIDtoShiftMap.get(employeeId).remove(index);
                    }
                }
            }
        }

        for (Id employeeId : employeeIdToShiftMap.keySet()) {
            if (employeeIDtoShiftMap.get(employeeId).size()==0) {
                employeeIDtoShiftMap.remove(employeeId);
            }
        }

        //Retrieve Key Starting Numbers and Averages
        //BSSP-802 - Changing how we do targetAverage, we now want to have the targetAverage be calls per hour, so if
        //redistributed in the middle of the days want to give more calls to people who have more time in their shift
        taskCount = todayTaskList.size();
		numberOfHours = 0;
        for (String employeeId : employeeIdToShiftMap.keySet()) {
        	numberOfHours += employeeIdtoHours.get(employeeId);
        }
        callsPerHour = todayTaskList.size()/numberOfHours;

        //Re-assign spanish speakers -- TO DO - this doesn't look at employee shift times
        Integer empIdIndex = 0;
        for (Task tsk : todayTaskList) {
            Boolean mismatchEmployeeLanguage = false;
            if (employeeIdtoShiftMap.containsKey(tsk.OwnerId) == false && (tsk.Account.Primary_Language_Preference__c != 'English' && tsk.Account.Primary_Language_Preference__c != null)) {
                mismatchEmployeeLanguage = true;
            } else if (employeeIdtoShiftMap.containsKey(tsk.OwnerId) == true && employeeIdtoShiftMap.get(tsk.OwnerId)[0].Employee__r.Spanish_Bilingual__c == false && tsk.Account.Primary_Language_Preference__c == 'Spanish') {
                mismatchEmployeeLanguage = true;
            }
            if (mismatchEmployeeLanguage == true) {
                Boolean match = false;
                Integer loopCnt = 0;
                while (match==false && loopCnt < 100) {
                    List<String> employeeIdList = new List<String>(employeeIDtoShiftMap.keySet());
                    String employeeId = employeeIdList[empIdIndex];
                    if (employeeIDtoShiftMap.get(employeeId)[0].Employee__r.Spanish_Bilingual__c == true) {
                        tsk.OwnerId = employeeId;
                        match = true;
                    }
                    empIdIndex = empIdIndex == employeeIdList.size()-1 ? 0 : empIdIndex + 1;
                    loopCnt += 1;
                }
            }
        }
        
        //Obtain Employee ID to Task Map
        for (Task tsk : todayTaskList) {
            if (employeeIDtoShiftMap.containsKey(tsk.OwnerId)) {
                if (initialEmployeeIdtoTaskMap.containsKey(tsk.OwnerId)) {
                    initialEmployeeIdtoTaskMap.get(tsk.OwnerId).add(tsk);
                } else {
                    List<Task> tskList = new List<Task>();
                    tskList.add(tsk);
                    initialEmployeeIdtoTaskMap.put(tsk.OwnerId, tskList);
                }
            } else {
                tasksToResdistribute.add(tsk);
            }
        } 

        //Place each employee Id in a bucket based on if they under, over or at the Target Average
        for (String employeeId : employeeIDtoShiftMap.keySet()) {
            Decimal tmpTarget = callsPerHour*employeeIdtoHours.get(employeeId);
            targetAverage = Integer.valueOf(tmpTarget.round(System.RoundingMode.FLOOR)) + 1;
            placeEmployeeInStatusBuckets(employeeId, initialEmployeeIdtoTaskMap, targetAverage);
        }
        
               
        //First remove all the tasks for overAverage Employees which have a mismatch of Call Window and Employee Shift
        //down to the target average
        //Do not redistribute any Tasks in progress (Call Result (Call_Result__c) has something in it)
        for (String overEmpId : overAverageMap.keySet()) {
            Decimal tmpTarget = callsPerHour*employeeIdtoHours.get(overEmpId);
            targetAverage = Integer.valueOf(tmpTarget.round(System.RoundingMode.FLOOR));
            Integer taskCount = overAverageMap.get(overEmpId).size()-1;
            while (overAverageMap.get(overEmpId).size() > targetAverage && taskCount > 0) {
                for (Shift__c overEmpShift : employeeIDtoShiftMap.get(overEmpId)) {
                    if (overAverageMap.get(overEmpId)[taskCount].Account.Primary_Call_Window_Start__c != null   //Don't redistribute if there is no Start Window on the call
                            && overAverageMap.get(overEmpId)[taskCount].Account.Primary_Call_Window_End__c != null //Don't redistribute if there is no End Window on the call
                            && !(overAverageMap.get(overEmpId)[taskCount].Account.Primary_Call_Window_Start__c < overEmpShift.End_Time__c && overAverageMap.get(overEmpId)[0].Account.Primary_Call_Window_End__c > overEmpShift.Start_Time__c) //Don't redistribute if the task's Account call window is within the Shift Time
                            && overAverageMap.get(overEmpId)[taskCount].Account.Primary_Language_Preference__c != 'Spanish'
                       		&& (overAverageMap.get(overEmpId)[taskCount].Call_Result__c == null || //Don't redistribute if there is already information in the Call Result and the owner is not OOO
                               (overAverageMap.get(overEmpId)[taskCount].Call_Result__c != null && employeeIDtoOOOMap.containsKey(overEmpId)))
                      ){
                        tasksToResdistribute.add(overAverageMap.get(overEmpId)[taskCount]);
                        overAverageMap.get(overEmpId).remove(taskCount);
                        break;
                    }
               }
               taskCount--;
            }
        }

        //Next, get the overAverages task size down to average by removing tasks at random
        //down to the target average
        //Do not redistribute any Tasks in progress (Call Result (Call_Result__c) has something in it)
        for (String overEmpId : overAverageMap.keySet()) {
            Decimal tmpTarget = callsPerHour*employeeIdtoHours.get(overEmpId);
            targetAverage = Integer.valueOf(tmpTarget.round(System.RoundingMode.FLOOR));
            Integer taskCount = overAverageMap.get(overEmpId).size()-1;
            while (overAverageMap.get(overEmpId).size() > targetAverage && taskCount > 0) {
                if (overAverageMap.get(overEmpId)[taskCount].Account.Primary_Language_Preference__c != 'Spanish' 
                    && (overAverageMap.get(overEmpId)[taskCount].Call_Result__c == null || //Don't redistribute if there is already information in the Call Result and the owner is not OOO
                       (overAverageMap.get(overEmpId)[taskCount].Call_Result__c != null && employeeIDtoOOOMap.containsKey(overEmpId)))
                ) {
                    tasksToResdistribute.add(overAverageMap.get(overEmpId)[taskCount]);
                    overAverageMap.get(overEmpId).remove(taskCount);
                }
                taskCount--;
            }
        }

        // First add tasks to underAverageEmployees which match Call Window and Employee Shift regardless of Warehouse time
        // up to the targetAverage
        for (String underEmpId : underAverageMap.keySet()) {
            Decimal tmpTarget = callsPerHour*employeeIdtoHours.get(underEmpId);
            targetAverage = Integer.valueOf(tmpTarget.round(System.RoundingMode.FLOOR));
            Integer taskCount = tasksToResdistribute.size()-1;
            while (underAverageMap.get(underEmpId).size() < targetAverage && taskCount>0) {
                for (Shift__c underEmpShift : employeeIDtoShiftMap.get(underEmpId)) {
                    if (tasksToResdistribute[taskCount].Account.Primary_Call_Window_Start__c != null
                            && tasksToResdistribute[taskCount].Account.Primary_Call_Window_Start__c < underEmpShift.Today_Shift_End_Time__c 
                            && tasksToResdistribute[taskCount].Account.Primary_Call_Window_End__c > underEmpShift.Today_Shift_Start_Time__c ) {
                        underAverageMap.get(underEmpId).add(tasksToResdistribute[taskCount]);
                        tasksToResdistribute.remove(taskCount);
                        break;
                    }
                }
                taskCount--;
            }
        }

        // Next add tasks to underAverageEmployees which match Call Window and Employee Shift and more than 2 hours from Warehouse cutoffTime
        // up to the targetAverage
       for (String underEmpId : underAverageMap.keySet()) {
            Decimal tmpTarget = callsPerHour*employeeIdtoHours.get(underEmpId);
            targetAverage = Integer.valueOf(tmpTarget.round(System.RoundingMode.FLOOR));
            Integer taskCount = tasksToResdistribute.size()-1;
            while (underAverageMap.get(underEmpId).size() < targetAverage && taskCount > 0) {
                for (Shift__c underEmpShift : employeeIDtoShiftMap.get(underEmpId)) {
                    if (tasksToResdistribute[taskCount].Account.Warehouse_Lookup__r.OrderCutoff__c != null
                        && underEmpShift.End_Time__c.addHours(-1) <= tasksToResdistribute[taskCount].Account.Warehouse_Lookup__r.OrderCutoff__c) {
                        underAverageMap.get(underEmpId).add(tasksToResdistribute[taskCount]);
                        tasksToResdistribute.remove(taskCount);
                        break;
                    }
                }
                taskCount--;
            }
        }

        //Add to those where we ran out of tasks to redistribute
        if (tasksToResdistribute.size() > 0) {
            for (String underEmpId : underAverageMap.keySet()) {
            	Decimal tmpTarget = callsPerHour*employeeIdtoHours.get(underEmpId);
            	targetAverage = Integer.valueOf(tmpTarget.round(System.RoundingMode.FLOOR));
                Integer taskCount = tasksToResdistribute.size();
                while (underAverageMap.get(underEmpId).size() < targetAverage && taskCount>0) {
                    underAverageMap.get(underEmpId).add(tasksToResdistribute[0]);
                    tasksToResdistribute.remove(0);
                    taskCount--;
                }
            }
        }
        
        //Go through the UnderAverage Map again, increasing by 1
        //Just add the remaining randomly
        if (tasksToResdistribute.size() > 0) {
            for (String underEmpId : underAverageMap.keySet()) {
                Decimal tmpTarget = callsPerHour*employeeIdtoHours.get(underEmpId);
            	targetAverage = Integer.valueOf(tmpTarget.round(System.RoundingMode.FLOOR))+1;
                Integer taskCount = tasksToResdistribute.size();
                while (underAverageMap.get(underEmpId).size() < targetAverage && taskCount > 0) {
                    underAverageMap.get(underEmpId).add(tasksToResdistribute[0]);
                    tasksToResdistribute.remove(0);
                    taskCount--;
                }
            }
        }

        //Go through the AtAverage Map, increasing by 1
        if (tasksToResdistribute.size() > 0) {
            for (String atEmpId : atAverageMap.keySet()) {
                Decimal tmpTarget = callsPerHour*employeeIdtoHours.get(atEmpId);
            	targetAverage = Integer.valueOf(tmpTarget.round(System.RoundingMode.FLOOR)+1);
                Integer taskCount = tasksToResdistribute.size();
                while (atAverageMap.get(atEmpId).size() < targetAverage && taskCount > 0) {
                    atAverageMap.get(atEmpId).add(tasksToResdistribute[0]);
                    tasksToResdistribute.remove(0);
                    taskCount--;
                }
            }
        }

        for (String overEmpId : overAverageMap.keySet()) {
            for (Task tsk: overAverageMap.get(overEmpId)) {
                tsk.OwnerId = overEmpId;
                tasksToUpdate.add(tsk);
            }
        }

        for (String atEmpId : atAverageMap.keySet()) {
            for (Task tsk: atAverageMap.get(atEmpId)) {
                tsk.OwnerId = atEmpId;
                tasksToUpdate.add(tsk);
            }
        }

        for (String underEmpId : underAverageMap.keySet()) {
            for (Task tsk: underAverageMap.get(underEmpId)) {
                tsk.OwnerId = underEmpId;
                tasksToUpdate.add(tsk);
            }
        }
        update tasksToUpdate;
    }

    public static void placeEmployeeInStatusBuckets(String employeeId, Map<String,List<Task>> mapToReBucket, Integer targetAverage) {
        List<Task> empTskList = mapToReBucket.get(employeeId);
        if (empTskList == null) {
            List<Task> tskList = new List<Task>();
            underAverageMap.put(employeeId, tskList);
        } else if (empTskList.size() < targetAverage) {
            underAverageMap.put(employeeId, empTskList);
        } else if (empTskList.size() > targetAverage) {
            overAverageMap.put(employeeId, empTskList);
        } else {
            atAverageMap.put(employeeId, empTskList);
        }
    }

    public static void addtToAddMapList(Map<Id, List<Shift__c>> addList, Id employeeId, Shift__c shft) {
        if (addList.containsKey(employeeId)) {
            addList.get(employeeId).add(shft);
        } else {
            List<Shift__c> shftList = new List<Shift__c>();
            shftList.add(shft);
            addList.put(employeeId, shftList);
        }
    }

    public static void addToRemoveMapList(Map<Id, List<Integer>> removeList, Id employeeId, Integer index) {
        if (removeList.containsKey(employeeId)) {
            removeList.get(employeeId).add(index);
        } else {
            List<Integer> indexList = new List<Integer>();
            indexList.add(index);
            removeList.put(employeeId, indexList);
        }
    }
}
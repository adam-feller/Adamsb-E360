public with sharing class GreenmilesStopController {

    @AuraEnabled
    public static Boolean checkMerchAcknowledgement() {
        //Get a list of all the West Coast VIP Instances
        List<String> westCoastVIPInstances = new List<String>();
        List<BU_Division__mdt> buDivisions = BUDivisionDAO.getBuDivisions();
        for (BU_Division__mdt buDivisionObj : buDivisions) {            
            if (buDivisionObj.Division__c == 'West') {
                westCoastVIPInstances.add(buDivisionObj.MasterLabel);
            }
        }
        
        //Get the User's Record VIP Instance and Last Acknowledgement Date
        try {
            User usr = [SELECT Id, VIP_Company__c, Last_Merch_Acknowledgement__c FROM User WHERE Id =:UserInfo.getUserId() LIMIT 1];
            Id merchProfileId = [SELECT Id FROM Profile WHERE Name = 'Merchandiser'].Id;
            //If the user is on the West Coast and they have not seen the pop-up window today
            if (westCoastVIPInstances.contains(usr.VIP_Company__c) && UserInfo.getProfileId() == merchProfileId && 
                (usr.Last_Merch_Acknowledgement__c == null || usr.Last_Merch_Acknowledgement__c.date() < System.today())
               ) {
                return true;
            } else {
                return false;
            }
        } catch (Exception e) {
            System.debug('Could not find User record: ' + e.getMessage());
            return false;
        }
    }

    @AuraEnabled
    public static void setMerchAcknowledgement() {        
        //Get the User's Record VIP Instance and Last Acknowledgement Date
        try {
            User usr = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            //Set the last time they received the Acknowledgement to the current Date/Time
            usr.Last_Merch_Acknowledgement__c = System.now();
            update usr;
        } catch (Exception e) {
            System.debug('Could not update User record.');
        }
    }

    @AuraEnabled
    public static List<String> getBusinessUnits() {
        List<BU_Division__mdt> buDivisions = BUDivisionDAO.getBuDivisions();
        List<String> buOptions = new List<String>();
        for(BU_Division__mdt buObj : buDivisions){
            buOptions.add(buObj.MasterLabel);
        }
        return buOptions;
    }

    @AuraEnabled
    public static List<GreenmileStopViewWrapper> getGreenmilesStopByUser(String debugTodayDate, String routeNumber, String buValue) {
        List<GreenmileStopViewWrapper> results = new List <GreenmileStopViewWrapper>();

        List <User> userList = UserDAO.getUser(UserInfo.getUserId());
        String greenmileOrgKey = userList[0].GM_Org_Key__c;
        String userEmployeeId = userList[0].FederationIdentifier;
        String greenmileRouteNumber = userList[0].Greenmile_Route_Override__c;
        String userVIPCompany = userList[0].VIP_Company__c;
        String greenmileBUValue = userList[0].Greenmile_BU_Override__c;
        Date greenmileDate = userList[0].Greenmile_Date_Override__c;        
        Date today = Date.today();
        if (debugTodayDate != null && debugTodayDate != '') {
        	today = Date.newInstance(Integer.valueOf(debugTodayDate.substring(0,4)), Integer.valueOf(debugTodayDate.substring(5,7)), Integer.valueOf(debugTodayDate.substring(8,10))).toStartOfWeek();
        }
        String todayDateStr = DateTime.newInstance(today.year(), today.month(), today.day()).format('yyyy-MM-dd');   
        today = today.toStartOfWeek();
        String startDateStr = DateTime.newInstance(today.year(), today.month(), today.day()).format('yyyy-MM-dd');        
        
        if(buValue == null){
            buValue = userVIPCompany;
        }

        Boolean updateUser = false;
        if(routeNumber == null){
            if(greenmileRouteNumber != null){
                //if(greenmileDate == System.today()) {   //Removing this, causing routes to not populate if this date is not today's date
                    routeNumber = greenmileRouteNumber;
                    buValue = greenmileBUValue;
                //}
            }
        }

        if(String.isNotBlank(userEmployeeId) || String.isNotBlank(routeNumber)) {
            List<GreenmileRouteInfo> routes = new List<GreenmileRouteInfo>();
            if(routeNumber != null){
                routes = GreenmilesAPICallout.getVisitByRouteAndDate(routeNumber, startDateStr, greenmileOrgKey);
            } else {
                routes = GreenmilesAPICallout.getVisitByUserLoginAndDate(userEmployeeId, todayDateStr, greenmileOrgKey);
            }

            if(!routes.isEmpty()) {
                updateUser = true;
                Map<String, String> buDivisionMap = new Map<String, String>();
                List<BU_Division__mdt> buDivisions = BUDivisionDAO.getBuDivisions();
                for(BU_Division__mdt buDivisionObj : buDivisions){
                    buDivisionMap.put(buDivisionObj.MasterLabel, buDivisionObj.DeveloperName);
                }
                Set<String> storeNumberList = new Set<String>();
                for(GreenmileRouteInfo route : routes) {
                    if(route.stops != null){
                        for(GreenmileRouteInfo.Stops stop : route.stops) {
                            if(stop?.location?.key != null){
                            	String vipInstance = stop?.location?.key?.substring(0,3);
                            	if(vipInstance == buValue){
                                	String accountKey;
                                	String instance;
                                    if (buDivisionMap.containsKey(stop?.location?.key?.substring(0,3))) {
                                        instance = buDivisionMap.get(stop?.location?.key?.substring(0,3));
                                    }
                                    accountKey = instance + '*' + stop?.location?.key?.right(5);
                                	storeNumberList.add(accountKey);
                           	 	}
                            }
                        }
                    }
                }
                Map<String,Account> retailStoreList = new Map<String, Account>();
                if (!storeNumberList.isEmpty()) {
                    retailStoreList = AccountDAO.getRetailStoreByStoreNumber(storeNumberList);
                }

                Integer i = 1;
                for(GreenmileRouteInfo route : routes) {
                    if(route.stops != null){
                        for(GreenmileRouteInfo.Stops stop : route.stops) {
                            String vipInstance = stop?.location?.key?.substring(0,3);
                            if(vipInstance == buValue){
                                GreenmileStopViewWrapper visit = new GreenmileStopViewWrapper();
                                
                                String accountKey;
                                String instance;
                                if(stop?.location?.key != null){
                                    if(buDivisionMap.containsKey(stop?.location?.key?.substring(0,3))){
                                        instance = buDivisionMap.get(stop?.location?.key?.substring(0,3));
                                    }
                                    accountKey = instance + '*' + stop?.location?.key?.right(5);
                                }
                                //START ADD ROUTES BASED ON PROFILES
                                String orgKey = '';
                                if(route.Organization != null){
                                    orgKey= route.Organization.key;
                                }
                                if((userList[0].profile.name == 'Merchandiser' || userList[0].profile.name == 'Merchandiser Manager')
                                && !orgKey.contains('MER')){   
                                    continue;
                                }
                                else if(userList[0].profile.name == 'Field Sales' && orgKey.contains('MER')){
                                    continue;
                                    }
                                visit.orgKey = orgKey;
                                //END ADD ROUTES BASED ON PROFILES
                                visit.id = i;
                                visit.routeId = String.valueOf(route.id);
                                visit.routeDescription = route.description;
                                visit.userBUVal = buValue;
                                visit.stopId =  String.valueOf(stop.id);
                                visit.locationKey = accountKey;
                                visit.stopAddress =  ifNotBlank(stop?.location?.addressLine1, '') + ' '
                                            + ifNotBlank(stop?.location?.addressLine2, '') + ', '
                                            + ifNotBlank(stop?.location?.city, '') + ', '
                                            + ifNotBlank(stop?.location?.state, '') + ', '
                                            + ifNotBlank(stop?.location?.zipCode, '');
                                visit.retailStoreName = retailStoreList.containsKey(accountKey) ? retailStoreList.get(accountKey).Name : stop?.location?.description;
                                visit.retailStoreRecordId = retailStoreList.containsKey(accountKey) ? retailStoreList.get(accountKey).Id : null;
                                visit.representativeName = userList[0].Name;
                                visit.representativeRole = userList[0].UserRole.Name;

                                if(stop.canceled){
                                    visit.stopStatus = 'CANCELLED';
                                    visit.stopStatusIcon = 'action:close';
                                    visit.stopStatusIconVariant = 'destructive';
                                }
                                else if(stop.actualDeparture != null){
                                    visit.stopStatus = 'COMPLETED';
                                    visit.stopStatusIcon = 'action:approval';
                                    visit.stopStatusIconVariant = 'success';
                                }else{
                                    visit.stopStatus = 'INCOMPLETE';
                                    visit.stopStatusIcon = 'action:remove';
                                    visit.stopStatusIconVariant = 'Neutral';
                                    visit.stopDisableButton = true;
                                }
                                visit.stopDate =  String.isEmpty(stop.actualService) ? ConvertStringToDate(stop.actualArrival) : ConvertStringToDate(stop.actualService);
                                visit.stopArrivalTime = String.isEmpty(stop.actualArrival)? null : ConvertStringToDate(stop.actualArrival);
                                visit.stopDepartureTime =  String.isEmpty(stop.actualDeparture)? null : ConvertStringToDate(stop.actualDeparture);
                                visit.estimateStopArrivalTime =  String.isEmpty(stop.plannedArrival)? null : ConvertStringToDate(stop.plannedArrival) ;
                                visit.estimateStopDepartureTime = String.isEmpty(stop.plannedDeparture)? null : ConvertStringToDate(stop.plannedDeparture);
                                visit.estimateStopDuration = calculateDuration(visit.estimateStopArrivalTime, visit.estimateStopDepartureTime);
                                visit.projectedStopArrivalTime =  String.isEmpty(stop.projectedArrival)? null : ConvertStringToDate(stop.projectedArrival) ;
                                visit.projectedStopDepartureTime = String.isEmpty(stop.projectedDeparture)? null : ConvertStringToDate(stop.projectedDeparture);
                                visit.projectedStopDuration = calculateDuration(visit.projectedStopArrivalTime, visit.projectedStopDepartureTime);
                                visit.stopDuration = calculateDuration(visit.stopArrivalTime, visit.stopDepartureTime);
                                visit.stopPlannedSize1 = stop.plannedSize1;
                                visit.stopPlannedSize2 = stop.plannedSize2;
                                visit.stopPlannedSize3 = stop.plannedSize3;
                                visit.stopActualSize1 = stop.actualSize1;
                                visit.stopActualSize2 = stop.actualSize2;
                                visit.stopActualSize3 = stop.actualSize3;
                                //BSSP-1000 Add cancel reason to the CommanCenter
                                visit.stopCancelReason = stop.cancelCode != null ? stop?.cancelCode?.key : '';

                                //BSSP-2122 START: Updates Column to Visit Info               
                                Boolean accountNotCallable = retailStoreList.containsKey(accountKey) ? retailStoreList.get(accountKey).Do_Not_Call__c : false;
                                String sellType = retailStoreList.containsKey(accountKey) ? retailStoreList.get(accountKey).Sell_Type__c : null;
                                Boolean earlyCutoffFlag = retailStoreList.containsKey(accountKey) ? retailStoreList.get(accountKey).Early_Cutoff__c : false;
                                //early cutoff only
                                if(earlyCutoffFlag){
                                    visit.visitInfoIconName='clockImage';
                                }
								if(sellType=='INSIDE SALES' || sellType=='NATIONAL ACCTS') {
                                    //combo icon
                                    if(earlyCutoffFlag){
                                        if(accountNotCallable){
                                            visit.visitInfoIconName='doNotCallAndEarlyCutOffImage';
                                        }
                                        else {
                                            visit.visitInfoIconName='canCallAndEarlyCutOffImage';
                                        }
                                    }
                                    //one icon
                                    else {
                                        if(accountNotCallable){
                                            visit.visitInfoIconName='doNotCallOnlyImage';
                                        }
                                        else {
                                            visit.visitInfoIconName='phoneImage';
                                        }
                                    }
                                }
                                //BSSP-2122 ENDS: Updates Column to Visit Info
                                if (visit.stopDate == null) {
                                    visit.stopDate = ConvertStringToDate(stop.plannedArrival);
                                    visit.stopDateWeekday = visit.stopDate != null ? visit.stopDate?.format('EEE') : '';
                                } else {
                                    visit.stopDateWeekday = visit.stopDate != null ? visit.stopDate?.format('EEE') : '';
                                }

                                results.add(visit);
                                i += 1 ;
                            }
                        }
                        results.sort();
                    }
                }
            }
        }
        return results;
    }

    @AuraEnabled
    public static String getGreenmilesStopByRetailStoreId(Id recordId, Integer pageSize) {
        List<GreenmileStopViewWrapper> results = new List <GreenmileStopViewWrapper>();

        String storeNumber =  AccountDAO.getStoreNumberById(recordId);
        String maxDateStr = DateTime.now().format('yyyy-MM-dd');
        String minDateStr = Datetime.now().addDays(-30).format('yyyy-MM-dd');
        
        Map<String, String> buDivisionMap = new Map<String, String>();
        List<BU_Division__mdt> buDivisions = BUDivisionDAO.getBuDivisions();
        for(BU_Division__mdt buDivisionObj : buDivisions){
        	buDivisionMap.put(buDivisionObj.DeveloperName, buDivisionObj.MasterLabel);
        }
		
        if(storeNumber != null){
            if(buDivisionMap.containsKey(storeNumber.substring(0,3))){
                String instance = buDivisionMap.get(storeNumber.substring(0,3));
                storeNumber = instance + storeNumber.right(5);
            }
        }

        List<GreenmileRouteInfo> routes = GreenmilesAPICallout.getGreenmileRouteInfoByStoreNumberAndDateRange(storeNumber, minDateStr, maxDateStr);

        if(!routes.isEmpty()) {
            Set<String> employeeIds = new Set<String>();
            for(GreenmileRouteInfo route : routes) {

                if(route.driverAssignments != null && !route.driverAssignments.isEmpty()){
                    employeeIds.add(route.driverAssignments[0]?.driver?.login);
                }
            }

            Map<String, String> employeeRoles = UserDAO.getUserRole(employeeIds);
        
            Integer i = 1;
            for(GreenmileRouteInfo route : routes) {
                
                for(GreenmileRouteInfo.Stops stop : route.stops) {
                    GreenmileStopViewWrapper visit = new GreenmileStopViewWrapper();

                    visit.id = i;
                    visit.routeId = String.valueOf(route.id);
                    visit.stopId =  String.valueOf(stop.id);
                    visit.locationKey = stop?.location?.key;
                    visit.retailStoreName = stop?.location?.description;
                    visit.retailStoreRecordId = recordId;
                    visit.representativeName = route.driverAssignments != null && !route?.driverAssignments?.isEmpty()? route?.driverAssignments[0]?.driver?.name : 'unknown';
                    if(route.organization != null) {
                        String temp = route.organization?.description;
                        visit.representativeRole = temp.right(temp.length()-temp.lastIndexOf(' '));
                    }
                    visit.stopStatus = stop.deliveryStatus;
                    if(! String.isEmpty(stop.actualService)) {
                        visit.stopDate = ConvertStringToDate(stop.actualService);
                    }
                    else if (! String.isEmpty(stop.actualArrival)) {
                        visit.stopDate =  ConvertStringToDate(stop.actualArrival);
                    }
                    else if (! String.isEmpty(stop.plannedArrival)){
                        visit.stopDate =  ConvertStringToDate(stop.plannedArrival);
                    }
                    else {
                        visit.stopDate = null;
                    }
                    visit.stopDateWeekday = visit.stopDate != null ? visit.stopDate?.format('EEE') : '';
                    visit.stopArrivalTime = String.isEmpty(stop.actualArrival)? null : ConvertStringToDate(stop.actualArrival);
                    visit.stopDepartureTime =  String.isEmpty(stop.actualDeparture)? null : ConvertStringToDate(stop.actualDeparture);
                    visit.estimateStopArrivalTime =  String.isEmpty(stop.plannedArrival)? null : ConvertStringToDate(stop.plannedArrival) ;
                    visit.estimateStopDepartureTime = String.isEmpty(stop.plannedDeparture)? null : ConvertStringToDate(stop.plannedDeparture);
                    visit.estimateStopDuration = calculateDuration(visit.estimateStopArrivalTime, visit.estimateStopDepartureTime);
                    visit.projectedStopArrivalTime =  String.isEmpty(stop.projectedArrival)? null : ConvertStringToDate(stop.projectedArrival) ;
                    visit.projectedStopDepartureTime = String.isEmpty(stop.projectedDeparture)? null : ConvertStringToDate(stop.projectedDeparture);
                    visit.projectedStopDuration = calculateDuration(visit.projectedStopArrivalTime, visit.projectedStopDepartureTime);
                    visit.stopDuration = calculateDuration(visit.stopArrivalTime, visit.stopDepartureTime);
                    visit.stopPlannedSize1 = stop.plannedSize1;
                    visit.stopPlannedSize2 = stop.plannedSize2;
                    visit.stopPlannedSize3 = stop.plannedSize3;

                    visit.stopActualSize1 = stop.actualSize1;
                    visit.stopActualSize2 = stop.actualSize2;
                    visit.stopActualSize3 = stop.actualSize3;
                    if(stop.canceled){
                        visit.stopStatus = 'CANCELLED';
                        visit.stopStatusIcon = 'action:close';
                        visit.stopStatusIconVariant = 'destructive';
                    }
                    else if(stop.actualDeparture != null){
                        visit.stopStatus = 'COMPLETED';
                        visit.stopStatusIcon = 'action:approval';
                        visit.stopStatusIconVariant = 'success';
                    }else{
                        visit.stopStatus = 'INCOMPLETE';
                        visit.stopStatusIcon = 'action:remove';
                        visit.stopStatusIconVariant = 'Neutral';
                        visit.stopDisableButton = true;
                    }
                    visit.stopCancelReason = stop.cancelCode != null ? stop?.cancelCode?.key : '';

                    results.add(visit);
                    i += 1 ;
                }
            }
        }
       
        GreenmileStopSummaryWrapper summaryResult = new GreenmileStopSummaryWrapper();
        summaryResult.pageSize = pageSize;
        summaryResult.totalRecord = results.size();
        summaryResult.recordList = results;

        return JSON.serialize(summaryResult);
    }

    @TestVisible
    private static String calculateDuration(DateTime minDatetime, DateTime maxDateTime) {
        String result  = null;
        if(minDatetime != null && maxDateTime != null) {
            Long milliseconds = maxDateTime.getTime() - minDatetime.getTime();
            Long seconds = milliseconds / 1000;
            Long minutes = seconds / 60;
            result = (minutes/60 > 0 ? String.valueOf(minutes/60)+' hr(s) ' : '') + ( Math.mod(minutes, 60) > 0 ? String.valueOf(Math.mod(minutes, 60))+ ' mins' :'' ) ;
            
        }
        return result;
    }

    @TestVisible
    private static String ifNotBlank(String value, String replaceValue) {
        if(String.isNotEmpty(value)) {
            return  value;
        }
        return replaceValue;
    }
    
    @TestVisible
    private static DateTime ConvertStringToDate(String dt) {
        DateTime value = null;
        if(!String.isEmpty(dt)){
            value = (DateTime)JSON.deserialize('"' + dt + '"', DateTime.class); 
        }
        return value;
    }

    public class GreenmileStopSummaryWrapper {

        @AuraEnabled
        public Integer totalRecord {get; set;}
        
        @AuraEnabled
        public Integer pageSize {get; set;}

        @AuraEnabled
        public List <GreenmileStopViewWrapper> recordList {get; set;}
    }

    public class GreenmileStopViewWrapper implements Comparable{
        
        @AuraEnabled
        public Integer id {get; set; }

        @AuraEnabled
        public String userBUVal {get; set; }

        @AuraEnabled
        public String stopAddress {get; set; }

        @AuraEnabled
        public String routeId {get; set; }

        @AuraEnabled
        public String routeDescription {get; set; }

        @AuraEnabled
        public String stopId {get; set; }
        
        @AuraEnabled
        public String locationKey {get; set; }
        
        @AuraEnabled
        public String retailStoreName {get; set; }

        @AuraEnabled
        public String retailStoreRecordId {get; set; }
        
        @AuraEnabled
        public String representativeName {get; set; }

        @AuraEnabled
        public String representativeRole {get; set; }

        @AuraEnabled
        public String stopStatus {get; set; }

        @AuraEnabled
        public Datetime stopDate {get; set; }

        @AuraEnabled
        public String stopDateWeekday {get; set; }

        @AuraEnabled
        public DateTime stopArrivalTime {get; set; }

        @AuraEnabled
        public DateTime stopDepartureTime {get; set; }

        @AuraEnabled
        public String stopDuration {get; set; }

        @AuraEnabled
        public datetime estimateStopArrivalTime {get; set; }

        @AuraEnabled
        public datetime estimateStopDepartureTime {get; set; }

        @AuraEnabled
        public String estimateStopDuration {get; set; }

        @AuraEnabled
        public datetime projectedStopArrivalTime {get; set; }

        @AuraEnabled
        public datetime projectedStopDepartureTime {get; set; }

        @AuraEnabled
        public String projectedStopDuration {get; set; }

        @AuraEnabled
        public String stopCancelReason {get; set; }
        //BSSP-1829 Early cutoff indicator
        @AuraEnabled
        public String earlyCutoffClass {get; set; }

        @AuraEnabled
        public String retailStoreSFDCURL {get; set; }
        
        @AuraEnabled
        public String stopStatusIcon {get; set; }

        @AuraEnabled
        public String stopStatusNoText {get; set; }

        @AuraEnabled
        public String stopStatusIconVariant {get; set; }

        @AuraEnabled
        public Boolean stopDisableButton {get; set; }

        @AuraEnabled
        public Double stopPlannedSize1 {get; set; }

        @AuraEnabled
        public Double stopPlannedSize2 {get; set; }

        @AuraEnabled
        public Double stopPlannedSize3 {get; set; }

        @AuraEnabled
        public Double stopActualSize1 {get; set; }

        @AuraEnabled
        public Double stopActualSize2 {get; set; }

        @AuraEnabled
        public Double stopActualSize3 {get; set; }

        @AuraEnabled
        public String visitInfoIconName {get; set; }

        @AuraEnabled
        public String orgKey {get; set; }

        public Integer compareTo(Object compareTo){
            GreenmileStopViewWrapper gmWrap = (GreenmileStopViewWrapper)compareTo;

            if(this.stopStatus == 'CANCELLED'){
                if(gmWrap.stopStatus == 'CANCELLED'){
                    return 0;
                }else if(gmWrap.stopStatus == 'COMPLETED'){
                    return 1;
                }else{
                    return 1;
                }
            }else if(this.stopStatus == 'COMPLETED'){
                if(gmWrap.stopStatus == 'CANCELLED'){
                    return -1;
                }else if(gmWrap.stopStatus == 'COMPLETED'){
                    return 0;
                }else{
                    return 1;
                }
            }else{
                if(gmWrap.stopStatus == 'CANCELLED'){
                    return -1;
                }else if(gmWrap.stopStatus == 'COMPLETED'){
                    return -1;
                }else{
                    return 0;
                }
            }
        }
    }

}
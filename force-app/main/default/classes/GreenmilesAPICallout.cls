public class GreenmilesAPICallout {

    public class GreenmileAPIException extends Exception {}

    public static List<GreenmileRouteInfo> getVisitByUserLoginAndDate(String userLogin, String todayDate) {
        return getVisitByUserLoginAndDate( userLogin, todayDate, null);
    }

    public static List<GreenmileRouteInfo> getVisitByUserLoginAndDate(String userLogin, String todayDate, String greenmileOrgKey) {
        String criteria = '{"filters":["id", "stops.id", "description", "stops.location.key", "stops.location.key", "stops.location.description", "stops.location.addressLine1", "stops.location.addressLine2","stops.location.city", "stops.location.state","stops.location.zipCode", "stops.actualArrival","stops.actualDeparture","stops.plannedArrival","stops.plannedDeparture", "stops.plannedService" , "stops.projectedArrival", "stops.projectedDeparture", "stops.actualService","driverAssignments.driver.name", "driverAssignments.driver.login", "stops.deliveryStatus", "date","status", "stops.cancelCode", "driverAssignments.driver.key", "stops.actualSize1", "stops.actualSize2", "stops.actualSize3", "stops.plannedSize1", "stops.plannedSize2", "stops.plannedSize3"]}';
        List<String> gmOrgList = getGreenmileOrgs();
        List<GreenmileRouteInfo> routes = null;
        String queryString = '?criteria=' + EncodingUtil.urlEncode(criteria,'UTF-8');
        Map<String, String> header = new Map<String,String>();
        header.put('Content-Type', 'application/json;charset=UTF-8');

        GreenmileAPIHelper.AndCondition ac = new GreenmileAPIHelper.AndCondition();
        ac.add(New GreenmileAPIHelper.AttrCondition('driverAssignments.driver.login',userLogin));
        ac.add(New GreenmileAPIHelper.AttrCondition('date',todayDate));
        //Use In Condition after the greenmile upgrade
        //GreenmileAPIHelper.InCondition oc = New GreenmileAPIHelper.InCondition();
        GreenmileAPIHelper.OrCondition oc = New GreenmileAPIHelper.OrCondition();
//        for (String org : gmOrgList){
            ac.add(New GreenmileAPIHelper.AttrCondition('organization.key', GreenmileAPIHelper.Operator.INX, gmOrgList ));
//        }
//        ac.add(oc);
        String body = '{"criteriaChain":['+ac.toJSON()+']}';
        system.debug(body);

        HttpResponse response = callout('POST', queryString, body, header);

        if(response.getStatusCode() == 200) {
            routes = (List<GreenmileRouteInfo>)JSON.deserialize(response.getBody(), List<GreenmileRouteInfo>.class);
        }
        else {
            throw new GreenmileAPIException('Error code: ' + response.getStatusCode() + ' Error Message: ' +  response.getBody() );
        }
        return routes;
    }

    public static List<GreenmileRouteInfo> getVisitByRouteAndDate(String routeNumber, String todayDate) {
        return getVisitByRouteAndDate( routeNumber,  todayDate, null);
    }

    public static List<GreenmileRouteInfo> getVisitByRouteAndDate(String routeNumber, String todayDate, String greenmileOrgKey) {
        String criteria = '{"filters":["id","description","organization.key", "stops.id", "stops.location.key", "stops.location.key", "stops.location.description", "stops.location.addressLine1", "stops.location.addressLine2","stops.location.city", "stops.location.state","stops.location.zipCode", "stops.actualArrival","stops.actualDeparture","stops.plannedArrival","stops.plannedDeparture", "stops.plannedService" , "stops.projectedArrival", "stops.projectedDeparture", "stops.actualService","driverAssignments.driver.name", "driverAssignments.driver.login", "stops.deliveryStatus", "date","status", "stops.cancelCode", "driverAssignments.driver.key", "stops.actualSize1", "stops.actualSize2", "stops.actualSize3", "stops.plannedSize1", "stops.plannedSize2", "stops.plannedSize3"]}';
        List<String> gmOrgList = getGreenmileOrgs();
        List<GreenmileRouteInfo> routes = null;
        String queryString = '?criteria=' + EncodingUtil.urlEncode(criteria,'UTF-8');
        Map<String, String> header = new Map<String,String>();
        header.put('Content-Type', 'application/json;charset=UTF-8');

        GreenmileAPIHelper.AndCondition ac = new GreenmileAPIHelper.AndCondition();
        ac.add(New GreenmileAPIHelper.AttrCondition('key',routeNumber));

        ac.add(New GreenmileAPIHelper.AttrCondition('date',GreenmileAPIHelper.Operator.GREATER_THAN_OR_EQUAL_TO,todayDate));

        String maxDateStr = Datetime.now().addDays(+6).format('yyyy-MM-dd');
        ac.add(New GreenmileAPIHelper.AttrCondition('date',GreenmileAPIHelper.Operator.LESS_THAN_OR_EQUAL_TO,maxDateStr));
      // String ccdateStr = '{"attr": "date", "gte": "' + todayDate + '" }';
      //  ac.add(New ccdateStr);

        //Use In Condition after the greenmile upgrade
        // GreenmileAPIHelper.OrCondition oc = New GreenmileAPIHelper.OrCondition();
//          GreenmileAPIHelper.InCondition oc = New GreenmileAPIHelper.InCondition();
//        for (String org : gmOrgList){
            ac.add(New GreenmileAPIHelper.AttrCondition('organization.key', GreenmileAPIHelper.Operator.INX, gmOrgList));
//        }
//        ac.add(oc);
        String body = '{"criteriaChain":['+ac.toJSON()+']}';
        System.debug(body);
        HttpResponse response = callout('POST', queryString, body, header);

        if(response.getStatusCode() == 200) {
            routes = (List<GreenmileRouteInfo>)JSON.deserialize(response.getBody(), List<GreenmileRouteInfo>.class);
                        system.debug('response from  Greenmile API' + routes);
        }
        else {
            throw new GreenmileAPIException('Error code: ' + response.getStatusCode() + ' Error Message: ' +  response.getBody() );
        }
        return routes;
    }

    public static List<GreenmileRouteInfo> getGreenmileRouteInfoByStoreNumberAndDateRange(String storeNumber, String minDateStr, String maxDateStr) {
        List<GreenmileRouteInfo> routes = null;
        String criteria = '{"filters":["id","organization.key","organization.description", "stops.id", "stops.location.key", "stops.location.key", "stops.location.description", "stops.actualArrival","stops.actualDeparture","stops.plannedArrival","stops.plannedDeparture", "stops.plannedService", "stops.actualService","driverAssignments.driver.name", "driverAssignments.driver.login", "stops.deliveryStatus", "date","status", "stops.cancelCode", "driverAssignments.driver.key", "stops.projectedArrival", "stops.projectedDeparture", "stops.cancelCode.description", "stops.cancelCode.key", "stops.actualSize1", "stops.actualSize2", "stops.actualSize3", "stops.plannedSize1", "stops.plannedSize2", "stops.plannedSize3"]}';

        String body = '{"criteriaChain":[{"and":[{"attr":"stops.location.key","eq":"#storeNbr#"},{"attr":"date","gte":"#minDate#"},{"attr":"date","lte":"#maxDate#"}]}]}';

        body = body.replace('#storeNbr#', storeNumber);        
        body = body.replace('#minDate#', minDateStr);
        body = body.replace('#maxDate#', maxDateStr);

        String queryString = '?criteria=' + EncodingUtil.urlEncode(criteria,'UTF-8');
        Map<String, String> header = new Map<String,String>();
        header.put('Content-Type', 'application/json;charset=UTF-8');

        HttpResponse response = callout('POST', queryString, body, header);

        if(response.getStatusCode() == 200) {
            routes = (List<GreenmileRouteInfo>)JSON.deserialize(response.getBody(), List<GreenmileRouteInfo>.class);

        }
        else {
            throw new GreenmileAPIException('Error code: ' + response.getStatusCode() + ' Error Message: ' +  response.getBody() );
        }
        return routes;
    }

    @TestVisible
    private static HttpResponse callout(String httpMethod, String queryString, String body, Map <String, String> header) {
        HttpRequest request = new HttpRequest();
        request.setMethod(httpMethod);
        request.setBody(body);
        request.setEndpoint('callout:GreenmileAPI/' + 'Route/restrictions' +  queryString);
        request.setTimeout(120000);
        if(!header.isEmpty()) {
            for(String key : header.keySet()) {
                request.setHeader(key, header.get(key));
            }
        }
        HttpResponse response = new Http ().send(request);
        return response;
    }

    @TestVisible
    private static List<String> getGreenmileOrgs() {
        List<String> gmOrgList = new List<String>();
        List<Greenmile_Org_List__mdt> greenmileOrgList = [SELECT Id, DeveloperName 
                                                        FROM Greenmile_Org_List__mdt];
        List<user> userData = userDAO.getUser(userinfo.getUserId());
        for(Greenmile_Org_List__mdt greenmileOrgObj : greenmileOrgList){
            if(userData[0].profile.name == 'Merchandiser' || userData[0].profile.name == 'Merchandiser Manager'){
                if(greenmileOrgObj.DeveloperName.contains('MER')){
                     gmOrgList.add(greenmileOrgObj.DeveloperName);
                }
            }else if(userData[0].profile.name == 'Field Sales'){
                if(!greenmileOrgObj.DeveloperName.contains('MER')){
                     gmOrgList.add(greenmileOrgObj.DeveloperName);
                }
            }else{
                 gmOrgList.add(greenmileOrgObj.DeveloperName);
            }
        }
        return gmOrgList;
    }
}
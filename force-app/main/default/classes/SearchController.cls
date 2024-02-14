public with sharing class SearchController {
    @AuraEnabled
    public static List<ObjInfo> retrieveSearchResults(String search, String objectName, String fieldName, List<String> subField, String filters) {
        String searchFields = 'Id';
        searchFields += ',' + (String.escapeSingleQuotes(fieldName.trim()));
        if(subField != null){
            for(String field : subField){
                searchFields += ',' + (String.escapeSingleQuotes(field.trim()));
            }
        }

        String filterString = '';
        if(filters != null){
            filterSetup[] filterJSON = (filterSetup[])JSON.deserialize(filters, filterSetup[].class);
            for (filterSetup filter : filterJSON) {
                filterString = filterString + ' ' + String.escapeSingleQuotes(filter.operator) + ' ';
                if (filter.groupLeft) {
                    filterString = filterString + '(';
                }
                String comparison = '';
                if(filter.eval != null){
                    comparison = filter.eval;
                } else {
                    comparison = ' = ';
                }
                filterString = filterString + String.escapeSingleQuotes(filter.fieldAPI) + ' ' + comparison + ' \''+String.escapeSingleQuotes(filter.value)+'\'';
                if (filter.groupRight) {
                    filterString = filterString + ')';
                }
            }
        }

        List<sObject> results = Database.query('SELECT ' + searchFields + ' FROM ' + objectName + ' WHERE ' + String.escapeSingleQuotes(fieldName.trim()) + ' LIKE' + ' \'%'+String.escapeSingleQuotes(search)+'%\'' +  filterString + ' ORDER BY ' + String.escapeSingleQuotes(fieldName.trim()) + ' ASC LIMIT 100');

        List<ObjInfo> objInfoResults = new List<ObjInfo>();
        for(sObject obj : results) {
            ObjInfo objInfo = new ObjInfo();
            objInfo.id = (String)obj.get('Id');
            objInfo.name = (String)obj.get('Name');
            objInfoResults.add(objInfo);
        }
        return objInfoResults;
    }

    public class ObjInfo {
        @AuraEnabled public String name {get; set;}
        @AuraEnabled public String id {get; set;}
    }

    public class filterSetup {
        // AND/OR/LIKE :: Placed at the begining of the string
        public String operator {get;set;}
        // The field that is being filtered against
        public String fieldAPI {get;set;}
        // The value for comparison
        public String eval {get;set;}
        // The value being filtered with
        public String value {get;set;}
        // Determines if a ( should be added to the left side of the string after the operator
        public Boolean groupLeft {get;set;}
        // Determines if a ) should be added to the right side of the string
        public Boolean groupRight {get;set;}
    }
}
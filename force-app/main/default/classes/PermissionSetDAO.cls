public with sharing class PermissionSetDAO {

    public static List<PermissionSet> getPermissionSetByIdsAndName(Set<Id> permissionSetIds){
        return [SELECT Id, Label
                FROM PermissionSet
                WHERE Id IN :permissionSetIds
                AND (Label = 'National Objective Admin'
                OR Label = 'BU Admin')];
    }
}
public with sharing class PermissionSetAssignmentDAO {

    public static List<PermissionSetAssignment> getPermissionSetAssignmentsByUserId(String userId){
        return [SELECT Id, PermissionSetId
                FROM PermissionSetAssignment
                WHERE AssigneeId = :userId];
    }
}
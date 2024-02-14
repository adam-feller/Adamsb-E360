public without sharing class ScheduleBatchBuildAccountTeams implements Schedulable {
    public void execute(SchedulableContext sc) {
        BatchBuildAccountTeams batchBuildTeams= new BatchBuildAccountTeams();
        batchBuildTeams.query = 'SELECT Id ' +
                                'FROM Account ' +
                                'WHERE ProcessAccountTeamsBuild__c = true';
        Database.executebatch(batchBuildTeams, 20);   //Keep batch size low to avoid too many soql queries/too many query rows
    }
}
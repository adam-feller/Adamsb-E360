public with sharing class ContentNoteDAO {

    public static List<ContentNote> getContentNoteByIdAndTodaysCreatedDate(Set<Id> noteIds){
        return [SELECT Id, Title, Content 
                FROM ContentNote 
                WHERE Id IN :noteIds 
                AND CreatedDate = Today];
    }

    public static List<ContentNote> getContentNotes(Set<Id> noteIds){
        return [SELECT Id, Title, Content 
                FROM ContentNote 
                WHERE Id IN :noteIds];
    }

    public static List<ContentNote> insertContentNotes(List<ContentNote> contentNotesToInsert){
        insert contentNotesToInsert;
        return contentNotesToInsert;
    }

    public static List<ContentNote> updateContentNotes(List<ContentNote> contentNotesToUpdate){
        update contentNotesToUpdate;
        return contentNotesToUpdate;
    }
}
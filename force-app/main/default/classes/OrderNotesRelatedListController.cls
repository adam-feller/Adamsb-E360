public without sharing class OrderNotesRelatedListController {

    @AuraEnabled(cacheable=true)
    public static List<NoteWrapper> getNotes(String accountId){
        List<NoteWrapper> noteWrapperList = new List<NoteWrapper>();
        List<ContentDocumentLink> contentDocumentLinks = ContentDocumentLinkDAO.getContentDocumentLinkByAccountId(new Set<Id>{accountId});
        if(!contentDocumentLinks.isEmpty()){
            Set<Id> noteIds = new Set<Id>();
            for(ContentDocumentLink contDocLink : contentDocumentLinks){
                noteIds.add(contDocLink.ContentDocumentId);
            }
            List<ContentNote> noteList = ContentNoteDAO.getContentNotes(noteIds);
            if(!noteList.isEmpty()){
                for(ContentNote noteObj : noteList){
                    NoteWrapper noteWrapperObj = new NoteWrapper();
                    noteWrapperObj.id = noteObj.Id;
                    noteWrapperObj.idLink = '/' + noteObj.Id;
                    noteWrapperObj.title = noteObj.Title;
                    noteWrapperObj.content = noteObj.Content.toString().replaceAll( '<[^>]+>',' ' );
                    noteWrapperList.add(noteWrapperObj);
                }
            }
        }
        return noteWrapperList;
    }

    @AuraEnabled
    public static NoteWrapper insertNewNote(String accountId, String orderId, String noteTitle, String noteContent) {
        try{
            List<Account> accountList = AccountDAO.getAccountsByIds(new Set<Id>{accountId});

            DateTime dt = System.now();
            String dateString = dt.format('MM/dd');

            ContentNote noteObj = new ContentNote();
            noteObj.Title = noteTitle;
            noteObj.Content = Blob.valueOf(noteContent);
            ContentNoteDAO.insertContentNotes(new List<ContentNote>{noteObj});

            ContentDocumentLink noteObjOrderLink = new ContentDocumentLink();
            noteObjOrderLink.LinkedEntityId = orderId;
            noteObjOrderLink.ContentDocumentId = noteObj.Id;
            noteObjOrderLink.ShareType = 'I';
            noteObjOrderLink.Visibility = 'AllUsers';
            ContentDocumentLinkDAO.insertContentDocumentLinks(new List<ContentDocumentLink>{noteObjOrderLink});

            ContentDocumentLink noteObjLink = new ContentDocumentLink();
            noteObjLink.LinkedEntityId = accountId;
            noteObjLink.ContentDocumentId = noteObj.Id;
            noteObjLink.ShareType = 'I';
            noteObjLink.Visibility = 'AllUsers';
            ContentDocumentLinkDAO.insertContentDocumentLinks(new List<ContentDocumentLink>{noteObjLink});

            NoteWrapper noteWrapperObj = new NoteWrapper();
            noteWrapperObj.id = noteObj.Id;
            noteWrapperObj.title = noteObj.Title;
            noteWrapperObj.content = noteObj.Content.toString().replaceAll( '<[^>]+>',' ' );

            return noteWrapperObj;
        } catch(Exception ex){
            ErrorLog.insertErrorLog(ex.getMessage(), String.valueOf(ex.getLineNumber()), 'OrderNoteRelatedListController', 'insertNewNote()');
            return null;
        }
    }

    @AuraEnabled
    public static NoteWrapper saveNoteUpdate(String noteId, String noteTitle, String noteContent){
        if(noteContent == null){
            noteContent = '';
        }
        ContentNote noteObj = new ContentNote();
        noteObj.Id = noteId;
        noteObj.Title = noteTitle;
        noteObj.Content = Blob.valueOf(noteContent);
        ContentNoteDAO.updateContentNotes(new List<ContentNote>{noteObj});

        NoteWrapper noteWrapperObj = new NoteWrapper();
        noteWrapperObj.id = noteId;
        noteWrapperObj.title = noteTitle;
        noteWrapperObj.content = noteObj.Content.toString().replaceAll( '<[^>]+>',' ' );
        return noteWrapperObj;
    }

    // this wrapper class is used to make an easy return type used for accessing values in the LWC component.
    public class NoteWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String idLink;
        @AuraEnabled public String title;
        @AuraEnabled public String content;
    }
}
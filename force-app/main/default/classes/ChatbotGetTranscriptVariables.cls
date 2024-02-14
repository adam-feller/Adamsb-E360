public with sharing class ChatbotGetTranscriptVariables {
    @InvocableMethod(label='Get Transcript Variables')
    public static List<TranscriptOutput> getTranscriptVariables(List<TranscriptInput> transcripts) {

      List<TranscriptOutput> outputList = new List<TranscriptOutput>();

      for (TranscriptInput transcript : transcripts) {

        // Query for the transcript record based on the ID
        LiveChatTranscript transcriptRecord = [
            SELECT Id,
                   First_Name__c,
                   Last_Name__c,
                   Email__c,
                   Is_Authenticated__c,
                   Business_Unit_ID__c,
                   Account_Number__c,
                   ContactId,
                   Language__c
            FROM LiveChatTranscript
            WHERE Id = :transcript.routableID
            LIMIT 1
        ];

        TranscriptOutput output = new TranscriptOutput();

        // Store the Transcript fields in output variables
        output.sFirstName = transcriptRecord.First_Name__c;
        output.sLastName = transcriptRecord.Last_Name__c;
        output.sEmail = transcriptRecord.Email__c;
        output.sIsAuthenticated = transcriptRecord.Is_Authenticated__c;
        output.sBusinessUnitId = transcriptRecord.Business_Unit_ID__c;
        output.sAccountNumber = transcriptRecord.Account_Number__c;
        output.sIsBotInit = true;
        output.sLanguage = transcriptRecord.Language__c;

        // Add the values to the list of outputs
        outputList.add(output);
      }

      return outputList;
    }

    public class TranscriptInput {
      @InvocableVariable(required=true)
      public ID routableID;
    }

    public class TranscriptOutput {
      @InvocableVariable(required=true)
      public String sFirstName;

      @InvocableVariable(required=true)
      public String sLastName;

      @InvocableVariable(required=true)
      public String sEmail;

      @InvocableVariable(required=true)
      public Boolean sIsAuthenticated;

      @InvocableVariable(required=true)
      public String sBusinessUnitId;

      @InvocableVariable(required=true)
      public String sAccountNumber;

      @InvocableVariable(required=true)
      public Boolean sIsBotInit;

      @InvocableVariable(required=true)
      public String sLanguage;
    }
}
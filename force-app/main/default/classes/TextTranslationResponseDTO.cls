public class TextTranslationResponseDTO {
    public List<Message> message;
    public Boolean success;

    public class Message {
        public String Text;
        public String TXLFPath;
        public String detectedLanguage;
    }
}
public class ChatbotSelectedMenuUtil {
    @InvocableMethod(label='Convert Menu CMT to String')
    public static List<ResponsesOutput> populateVariable(List<ResponsesInput> inputs) {
        List<ResponsesOutput> outputList = new List<ResponsesOutput>();
        ResponsesOutput ro = new ResponsesOutput();
        ro.selectedMenuEnglish = inputs[0].selectedMenu.englishChoice;
        outputList.add(ro);

        return outputList;
    }

    public class ResponsesInput {
        @InvocableVariable(required=true)
        public ChatbotGetMenus.MenuOutput selectedMenu;
    }

    public class ResponsesOutput {
        @InvocableVariable(required=true)
        public String selectedMenuEnglish;
    }
}
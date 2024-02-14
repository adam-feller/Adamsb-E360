@isTest
private class FieldSetRecordFormControllerTest {

    @isTest
    static void testGetFieldsByFieldSetName(){
        Test.startTest();
            List<FieldSetWrapperLWC> fieldSetFields = FieldSetRecordFormController.getFieldsByFieldSetName('Account', 'AccountOrderDetails');
        Test.stopTest();

        System.assertNotEquals(fieldSetFields.size(), 0, 'Fields should be returned');
    }
}
/**
 * Created by alexander.velitsky on 1/7/21.
 */

@IsTest
private class GreenmileButtonControllerTest {
    @IsTest
    static void testBehavior() {
        GreenmileButtonController.getUserData();
        GreenmileButtonController.getUIThemeDescription();
    }
}
/**
 * Created by alexander.velitsky on 5/18/20.
 */

@IsTest
private class StandardUserSSOJitHandlerTEST {

    private static Map<String, String> TEST_ATTRIBUTES = new Map<String, String>{

            'FirstName' => 'Testfirstname',
            'LastName' => 'TestLastName',
            'CompanyCode' => 'RH',
            'Email' => 'testssouser@reyes.com.mytest'
    };

    //'Username' => 'testssoUser@reyes.com.mytest',

    private static User getUserByID(String uid){
        return [SELECT Username, Email, FirstName, LastName, Alias, CompanyName, Id, FederationIdentifier FROM User WHERE Id=:uid];
    }

    @IsTest
    static void test_default_behavior() {
        StandardUserSSOJitHandler handler = new StandardUserSSOJitHandler();
        User u = handler.createUser(null, null, null, 'testFederation', TEST_ATTRIBUTES,'testDummyAssertion');
        insert u;
        String uid = u.Id;
        User updatedUser = getUserByID(uid);
        System.assertEquals('testssouser@reyes.com.mytest', updatedUser.Username );
        System.assertEquals('Testfirstname', updatedUser.FirstName );
        System.assertEquals('TestLastName', updatedUser.LastName );
        System.assertEquals('testssouser@reyes.com.mytest', updatedUser.Email );
        System.assertEquals('RH', updatedUser.CompanyName );


        TEST_ATTRIBUTES = new Map<String, String>{
                'FirstName' => 'TestFirstnameChanged',
                'LastName' => 'TestLastNameChanged',
                'CompanyCode' => 'RBS',
                'Email' => 'testssouser@reyes.com.mytest23',
                'Username' => 'shouldnotchange@reyes.com.mytest23'
        };
        handler.updateUser(uid, null,null,null, 'testFederation', TEST_ATTRIBUTES, 'testDummyAssertion2');
        updatedUser = getUserByID(uid);
        System.assertEquals('testssouser@reyes.com.mytest', updatedUser.Username );
        System.assertEquals('TestFirstnameChanged', updatedUser.FirstName );
        System.assertEquals('TestLastNameChanged', updatedUser.LastName );
        System.assertEquals('testssouser@reyes.com.mytest23', updatedUser.Email );
        System.assertEquals('RBS', updatedUser.CompanyName );
    }

    @IsTest
    static void test_username() {
        StandardUserSSOJitHandler handler = new StandardUserSSOJitHandler();
        TEST_ATTRIBUTES.put('Username', 'testssouser@reyes.com.mytest2');
        User u = handler.createUser(null, null, null, 'testFederation', TEST_ATTRIBUTES,'testDummyAssertion');
        insert u;
        String uid = u.Id;
        User updatedUser = getUserByID(uid);
        system.assertEquals('testssouser@reyes.com.mytest2', updatedUser.Username );

    }
}
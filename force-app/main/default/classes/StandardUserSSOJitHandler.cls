/**
 * Created by alexander.velitsky on 5/8/20.
 */

global without sharing class StandardUserSSOJitHandler implements Auth.SamlJitHandler {
    private class JitException extends Exception{}

    private void handleUser(boolean create, User u, Map<String, String> attributes,
            String federationIdentifier, boolean isStandard) {
        system.debug(u);
        system.debug(federationIdentifier);
        if(create && attributes.containsKey('Username')) {
            u.Username = attributes.get('Username');
        }
        if(attributes.containsKey('FirstName')) {
            u.Firstname = attributes.get('FirstName');
        }
        if(attributes.containsKey('LastName')) {
            u.LastName = attributes.get('LastName');
        }
        if(attributes.containsKey('CompanyCode')) {
            u.CompanyName = attributes.get('CompanyCode');
        }
        if(attributes.containsKey('Email')) {
            u.Email = attributes.get('Email');
        }
        if(create) {
            Profile p = [SELECT Id FROM Profile WHERE name = 'Standard User'];
            u.ProfileId = p.Id;
            if(attributes.containsKey('Email')) {
                u.Email = attributes.get('Email');
                if (create && String.isEmpty(u.Username)){
                    u.Username = u.Email;
                }
            }
            u.Alias = u.Firstname.left(1)+u.LastName.left(4);
            u.EmailEncodingKey = 'ISO-8859-1';
            u.LanguageLocaleKey = 'en_US';
            u.LocaleSidKey = 'en_US';
            u.TimeZoneSidKey = 'America/Chicago';
            u.FederationIdentifier = federationIdentifier;
        } else {
            update(u);
        }
    }

    private void handleJit(boolean create, User u, Id samlSsoProviderId, Id communityId, Id portalId,
            String federationIdentifier, Map<String, String> attributes, String assertion) {
        /*
        System.debug('handleJit');

        System.debug('samlSsoProviderId: '+samlSsoProviderId);
        System.debug('create: '+create);
        System.debug('communityId: '+communityId);
        System.debug('portalId: '+portalId);
        System.debug('attributes: ');
        for (String key: attributes.keySet()){
            System.debug(key+': '+attributes.get(key));
        }
        System.debug('attributes: '+attributes);
        System.debug('assertion:\n'+assertion);
        System.debug('User');
        System.debug(u);
        */

        if(communityId != null || portalId != null) {
            /*String account = handleAccount(create, u, attributes);

            handleContact(create, account, u, attributes);
            handleUser(create, u, attributes, federationIdentifier, false);

             */
        } else {

            handleUser(create, u, attributes, federationIdentifier, true);
        }
    }

    global User createUser(Id samlSsoProviderId, Id communityId, Id portalId,
            String federationIdentifier, Map<String, String> attributes, String assertion) {
        System.debug('Create User');
        User u = new User();
        handleJit(true, u, samlSsoProviderId, communityId, portalId,
                federationIdentifier, attributes, assertion);
        return u;
    }

    global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId,
            String federationIdentifier, Map<String, String> attributes, String assertion) {
        User u = [SELECT Id FROM User WHERE Id=:userId];
        handleJit(false, u, samlSsoProviderId, communityId, portalId,
                federationIdentifier, attributes, assertion);
    }
}
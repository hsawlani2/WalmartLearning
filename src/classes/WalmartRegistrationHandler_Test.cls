/**
 * AUTHOR       : Lennard Santos(Cloud Sherpas)
 * DESCRIPTION  : Registration handler class test coverage for Auth Provider Setup
 * HISTORY      : 03.MAR.2014 - Created (LSantos)
 * */
@isTest
private class WalmartRegistrationHandler_Test {
    /**
     * AUTHOR       : Lennard Santos(Cloud Sherpas)
     * DESCRIPTION  : method for setting up test data that will be used throughout the test coverage methods
     * PARAM        : None
     * RETURN       : None
     * HISTORY      : 03.MAR.2014 - Created (LSantos)
     **/
    @testSetup static void setupTestData(){
        Id adminProfId = [Select id from Profile WHERE Name=:'System Administrator'].Id;
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        User adminUser = walmartDataUtility.buildTestUser('walmartadmin@walmart.com.test', adminProfId);
        adminUser.UserRoleId = portalRole.Id;
        insert adminUser;
        System.runAs(adminUser){
            Walmart_Open_Id__c walmartSettings = new Walmart_Open_Id__c();
            walmartSettings.Link__c = 'https://phase3dev-walmartsupport.cs51.force.com/cases';
            walmartSettings.Auth_Provider__c = 'Walmart_OpenId__mdt';
            walmartSettings.SFDC_Network_Id__c = '0DB61000000PBLZ';
            walmartSettings.Profile_Name__c = 'Seller Community User';
            walmartSettings.Error_Page_Link__c   = 'http://sfdc.koduru.we.bs/error.php';
            walmartSettings.Name = 'WalmartOpenId';
            insert walmartSettings;

            Account testAccount = walmartDataUtility.buildTestAccount('Walmart Seller');
            insert testAccount;
            Contact testContact = walmartDataUtility.buildTestContact('walmart', 'SellerContact', testAccount.Id);
            insert testContact;
            Id commProfId = [Select id from Profile WHERE Name=:'Seller Community User'].Id;
            User communityUser = walmartDataUtility.buildTestUser('walmartSellerContact@walmart.com.test',commProfId);
            communityUser.ContactId = testContact.Id;
            insert communityUser;
        }
    }
    /**
     * AUTHOR       : Lennard Santos(Cloud Sherpas)
     * DESCRIPTION  : method for testing user creating during sso flow
     * PARAM        : None
     * RETURN       : None
     * HISTORY      : 03.MAR.2014 - Created (LSantos)
     **/
    static testMethod void testCreateAndUpdateUser() {
        walmartRegistrationHandler handler = new walmartRegistrationHandler();
        Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
            'testFirst testLast', 'testuser@example.com', null, 'testuser@example.com', 'en_US', 'facebook',
            null, new Map<String, String>{'language' => 'en_US','sfdc_networkid' => ''});
        User u = handler.createUser(null, sampleData);
        String uid = u.id;
        
        sampleData = new Auth.UserData('testNewId', 'testNewFirst', 'testNewLast',
            'testNewFirst testNewLast', 'testnewuser@example.org', null, 'testnewuserlong', 'en_US', 'facebook',
            null, new Map<String, String>{});
        handler.updateUser(uid, null, sampleData);
        User updatedUser = [SELECT userName, email, firstName, lastName, alias FROM user WHERE id=:uid];
    }
}
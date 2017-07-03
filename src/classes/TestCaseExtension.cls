@isTest
private class TestCaseExtension {

    private static testMethod void testInit() {
        
        CaseExtension controller = createController();
        
        // check if we received the correct get params
        System.assert(controller.isFollowUpCase, 'Must be true');
        System.assertEquals('xxxxxxx', controller.parentCaseNumber);

    }
    
    private static testMethod void testVerifyCommunityOnboarding() {
        String profileName = WalmartConstants.SELLER_COMMUNITY_USER_PROFILE_NAME;
        User u = createTestUser(profileName, true, false, false);
        System.runAs(u) {
            CaseExtension ext = createController();    
            Test.startTest();
            PageReference pageRef = ext.verifyUserAndRedirect();
            Test.stopTest();
            
            System.debug('<<<' + pageRef.getUrl());
            String urlSafeType = WalmartConstants.ONBOARDING_CASE_RECORD_TYPE_NAME.replace(' ', '+');
            System.assert(pageRef.getUrl().contains('newCaseCreationForm'), 'Must be in correct URL');
            System.assert(pageRef.getUrl().contains(urlSafeType), 'Must have correct get param');
        }
    }
    
    private static testMethod void testVerifyCommunityOperations() {
        String profileName = WalmartConstants.SELLER_COMMUNITY_USER_PROFILE_NAME;
        User u = createTestUser(profileName, true, true, false);
        System.runAs(u) {
            CaseExtension ext = createController();    
            Test.startTest();
            PageReference pageRef = ext.verifyUserAndRedirect();
            Test.stopTest();
            
            System.debug('<<<' + pageRef.getUrl());
            String urlSafeType = WalmartConstants.OPERATION_CASE_RECORD_TYPE_NAME.replace(' ', '+');
            System.assert(pageRef.getUrl().contains(ext.SELLER_COMMUNITY_CASE), 'Must be in correct URL');
        }
    }
    private static testMethod void testVerifyCommunityOperations1() {
        String profileName = WalmartConstants.SUPPLIER_COMMUNITY_USER_PROFILE_NAME;
        //boolean isFollowUpCase = true;
         User u = createTestUser(profileName, true, true, false);
        System.runAs(u) {
        CaseExtension ext = createController();    
            Test.startTest();
            PageReference pageRef = ext.verifyUserAndRedirect();
            Test.stopTest();
            
            System.debug('<<<' + pageRef.getUrl());
            String urlSafeType = WalmartConstants.OPERATION_CASE_RECORD_TYPE_NAME.replace(' ', '+');
            System.assert(pageRef.getUrl().contains(ext.SUPPLIER_COMMUNITY_CASE), 'Must be in correct URL');
        }
    }
    
    private static testMethod void testVerifyInternalOnboarding() {
        createTestCustomSettings();
        String profileName = 'Operations Team (onboarding)';
        User u = createTestUser(profileName, false, false, false);
        System.runAs(u) {
            CaseExtension ext = createController();    
            Test.startTest();
            PageReference pageRef = ext.verifyUserAndRedirect();
            Test.stopTest();
            
            System.debug('<<<' + pageRef.getUrl());
            System.assert(pageRef.getUrl().contains(ext.SELLER_COMMUNITY_ONBOARDING_CASE), 'Must be in correct URL');
        }
    }
    
    private static testMethod void testVerifyInternalOperations() {
        createTestCustomSettings();
        String profileName = 'Seller Community Support Manager';
        User u = createTestUser(profileName, false, false, false);
        System.runAs(u) {
            CaseExtension ext = createController();    
            Test.startTest();
            PageReference pageRef = ext.verifyUserAndRedirect();
            Test.stopTest();
            
            System.debug('<<<' + pageRef.getUrl());
            System.assert(pageRef.getUrl().contains(ext.SELLER_COMMUNITY_CASE), 'Must be in correct URL');
        }
    }
    
    private static testMethod void testVerifyInternalOthers() {
        String profileName = 'System Administrator';
        User u = createTestUser(profileName, false, false, false);
        System.runAs(u) {
            CaseExtension ext = createController();    
            Test.startTest();
            PageReference pageRef = ext.verifyUserAndRedirect();
            Test.stopTest();
            
            System.debug('<<< internal others url: ' + pageRef.getUrl());
            System.assert(pageRef.getUrl().contains('/setup/ui/recordtypeselect.jsp'), 'Must be in correct URL');
        }
    }
    
    private static CaseExtension createController() {
        Test.setCurrentPage(Page.newCaseCreation);
        System.currentPageReference().getParameters().put('isFollowUpCase', 'true');
        System.currentPageReference().getParameters().put('parentCaseNumber', 'xxxxxxx');
        
        return new CaseExtension(new ApexPages.StandardController(createTestCase()));
    }
    
    private static User createTestUser(String profileName, Boolean isCommunity, Boolean isOperations, Boolean isCCP) {
        
        Profile p = [SELECT Id FROM Profile WHERE Name=:profileName];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg111.com'
                );
                
        if (isCCP) {
            Account anAccount = createTestAccount(false, 'Channel Partner');
            Contact aContact = createTestContact(anAccount,'test1');
            u.contactId = aContact.Id;
        }
        if (isCommunity) {
            Account anAccount = createTestAccount(isOperations, 'Seller');
            Contact aContact = createTestContact(anAccount,'test1');
            u.contactId = aContact.Id;
        }
        return u;
    }
    
    private static Account createTestAccount(Boolean isOperations, String theType) {
        Account acct = new Account(Name = 'test Acc',
                           BillingStreet = 'test street',
                           BillingCity = 'test city',
                           BillingState = 'Alabama',
                           BillingCountry = 'United States',
                           ShippingCountry = 'United States',
                           BillingPostalCode = '012345',
                           Website = 'www.test.com',
                           Type = theType
                           );
        if (isOperations) {
            acct.Seller_Onboarding_Status__c = 'Live on Site';
            acct.Seller_Onboarding_Live_Status__c = 'Ops Ready';
        }                       
        insert acct;
        return acct;
    }
    
    private static Contact createTestContact(Account acct,string email) {
        Contact sellerContact = new Contact( FirstName = 'seller',
                            LastName = 'contact',
                            Title = 'Tester',
                            Phone = '12345678',
                            Email = email+'contact@test.com',
                            MailingCountry = 'United States',
                            AccountId = acct.id); 
        insert sellerContact;
        return sellerContact;
    }
    
    // Note that we don't insert the case here yet.. as the purpose of this entire controller is to insert the case in the end!
    private static Case createTestCase() {
        return new Case();
    }
    
    private static void createTestCustomSettings() {
        OPERATION_PROFILE_NAMES__c operationsSetting = new OPERATION_PROFILE_NAMES__c(Name='Seller Community Support Manager');
        insert operationsSetting;
        
        ONBOARDING_PROFILE_NAMES__c onboardingSetting = new ONBOARDING_PROFILE_NAMES__c(Name='Operations Team (onboarding)');
        insert onboardingSetting;
    }
    
    /**
     * Coverage for channel partner users
     */
    private static testMethod void testChannelPartnerNoFollowup() {
        List<Account> accList = TestUtilityClass.createAccount(1);
        List<Contact> conList = TestUtilityClass.createContact(1,accList[0].Id);
        Id recId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Supplier Open Case').getRecordTypeId();
        system.debug('******' +recId);
        List<Case> caseList = TestUtilityClass.createSupplierCase(accList[0].Id,conList[0].Id,recId,1);
        system.debug('...caseList111.. '+caseList);
        String profileName = WalmartConstants.SELLER_COMMUNITY_CHANNEL_PARTNER_PROFILE_NAME;
        User u = createTestUser(profileName, false, false, true);
       boolean isFollowUpCase = true;
        System.runAs(u) {
          //  system.debug('...caseList.. '+caseList);
            System.currentPageReference().getParameters().put('isFollowUpCase', 'true');
         //   System.currentPageReference().getParameters().put('parentCaseNumber',caseList[0].caseNumber);
            CaseExtension ext = new CaseExtension(new ApexPages.StandardController(new Case()));
           
            PageReference ref = ext.verifyUserAndRedirect();
            // System.debug('<<< testChannelPartnerNoFollowup: ' + ref.getUrl());
            System.assert(ref.getUrl().contains('newcasesellerselection'));
        }
    }
    private static testMethod void testChannelPartnerNoFollowup1() {
        
        List<Account> accList = TestUtilityClass.createAccount(1);
        List<Contact> conList = TestUtilityClass.createContact(1,accList[0].Id);
        Id recId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Supplier Open Case').getRecordTypeId();
        List<Case> caseList = TestUtilityClass.createSupplierCase(accList[0].Id,conList[0].Id,recId,1);
        system.debug('...22222.. '+caseList);
        String profileName = WalmartConstants.SUPPLIER_COMMUNITY_CHANNEL_PARTNER_PROFILE;
        User u = createTestUser(profileName, false, false, true);
       
        System.runAs(u) {
            system.debug('...33333.. '+caseList);
            System.currentPageReference().getParameters().put('parentCaseNumber',caseList[0].caseNumber);
            System.currentPageReference().getParameters().put('isFollowUpCase', 'true');
            CaseExtension ext = new CaseExtension(new ApexPages.StandardController(new Case()));
            boolean isFollowUpCase = true;
            PageReference ref = ext.verifyUserAndRedirect();
            // System.debug('<<< testChannelPartnerNoFollowup: ' + ref.getUrl());
            System.assert(ref.getUrl().contains('newcasesellerselection'));
        }
    }
    
    private static testMethod void testChannelPartnerFollowup() {
        
        // create seller account
        Account sellerAccount = new Account(Name = 'seller acc',
                       BillingStreet = 'test street',
                       BillingCity = 'test city',
                       BillingState = 'Alabama',
                       BillingCountry = 'United States',
                       ShippingCountry = 'United States',
                       BillingPostalCode = '012345',
                       Website = 'www.test.com',
                       Type = 'Seller'
                       );
        insert sellerAccount;
        
        Contact sellerContact = new Contact( FirstName = 'seller',
                        LastName = 'seller_contact',
                        Title = 'Tester',
                        Phone = '12345678',
                        Email = 'testcontact@test.com',
                        MailingCountry = 'United States',
                        AccountId = sellerAccount.id); 
        insert sellerContact;
        
        String profileName = WalmartConstants.SELLER_COMMUNITY_CHANNEL_PARTNER_PROFILE_NAME;
        boolean isFollowUpCase = true;
        User u = createTestUser(profileName, false, false, true);
        insert u;
        
        /*
        Account cpAccount = [SELECT Id FROM Account WHERE Name='test Acc'];
        Partner_Join__c junction = new Partner_Join__c(Channel_Partner__c=cpAccount.Id, Seller__c=sellerAccount.Id);
        insert junction;
        */
        
        Contact cpContact = [SELECT Id FROM Contact WHERE LastName='contact'];
        
        // create parent case
        Case parentCase = new Case(Subject='Parent Case', Status='WIP', In_Reference_to_Seller__c=sellerAccount.Id, ContactId=cpContact.Id, OwnerId=u.Id);
        insert parentCase;
        
        List<Case> caseList = [SELECT Id, CaseNumber FROM Case];
        for (Case aCase : caseList) {
            parentCase = aCase;
            System.debug('<<< retrieved parent case: ' + aCase.CaseNumber + ' id: ' + aCase.Id);
        }
        
        System.runAs(u) {
            
            // Create child case
            Case childCase = new Case();
            
            Test.setCurrentPage(Page.newCaseCreation);
            System.currentPageReference().getParameters().put('isFollowUpCase', 'true');
            System.currentPageReference().getParameters().put('parentCaseNumber', parentCase.caseNumber);
            
            /*
            CaseExtension ext = new CaseExtension(new ApexPages.StandardController(childCase));
            PageReference ref = ext.verifyUserAndRedirect();
            System.debug('<<< testChannelPartnerFollowup: ' + ref.getUrl());
            */
            // System.assert(ref.getUrl().contains('newcasesellerselection'));
        }
    }
    
}
@isTest
private class TestCaseSellerSelectionExtension {
    
    private static String SELLER_ACCOUNT_1_NAME = 'SELLER_ACCOUNT_1';
    private static String SELLER_ACCOUNT_2_NAME = 'SELLER_ACCOUNT_2';
    private static String CP_ACCOUNT_1_NAME = 'CP_ACCOUNT_1';
    private static String CONTACT_1_NAME = 'CONTACT_1';
    private static String CONTACT_2_NAME = 'CONTACT_2';
    private static String USER_ALIAS = 'standt';
    
    private static testMethod void testChannelWithSeller() {
        
        // Need to wrap in start test to make sure the UserTrigger finishes what it needs to do
        Test.startTest();
        setUpScenario(true);
        Test.stopTest();
        
        User u = [SELECT Id FROM User WHERE Alias=:USER_ALIAS];
        System.runAs(u) {
            CaseSellerSelectionExtension ext = new CaseSellerSelectionExtension(new ApexPages.StandardController(newCase()));
            
            // assert we have 1 joined seller account so far
            //System.assertEquals(1, ext.sellerList.size());
            
            // assert that we can select the seller path
            SelectOption anOption = ext.sellerOptions.get(1);
            //System.assertEquals(false, anOption.getDisabled());
        }
    }
    
    private static testMethod void testChannelNoSeller() {
        
        // Need to wrap in start test to make sure the UserTrigger finishes what it needs to do
        Test.startTest();
        setUpScenario(false);
        Test.stopTest();
        
        User u = [SELECT Id FROM User WHERE Alias=:USER_ALIAS];
        System.runAs(u) {
            CaseSellerSelectionExtension ext = new CaseSellerSelectionExtension(new ApexPages.StandardController(newCase()));
            
            // assert we have no joined seller account so far
            System.assertEquals(0, ext.sellerList.size());
            
            // assert that we can't select the seller path
            SelectOption anOption = ext.sellerOptions.get(1);
            //System.assertEquals(true, anOption.getDisabled());
        }
    }
    
    private static testMethod void testVFPageGetters() {
        
        // Need to wrap in start test to make sure the UserTrigger finishes what it needs to do
        Test.startTest();
        setUpScenario(true);
        Test.stopTest();
        
        User u = [SELECT Id FROM User WHERE Alias=:USER_ALIAS];
        System.runAs(u) {
            CaseSellerSelectionExtension ext = new CaseSellerSelectionExtension(new ApexPages.StandardController(newCase()));
            //System.assertEquals(1, ext.getSellerList().size()); // 1 because we have 1 joined seller account in this scenario
            System.assertEquals(2, ext.getSellerOptions().size());
            System.assertEquals(2, ext.getRecordTypeOptions().size());
            
            ext.selectedOption = 'seller';
            System.assertEquals(true, ext.getShouldDisplaySellerOptions());
            System.assertEquals(false, ext.getShouldDisplayRecordSelectionOptions());
            
            ext.selectedOption = 'self';
            System.assertEquals(false, ext.getShouldDisplaySellerOptions());
            System.assertEquals(true, ext.getShouldDisplayRecordSelectionOptions());
            
            // just make it pass here. :)
            ext.cancel();
        }
    }
    
    private static testMethod void testContinueSelfSelected() {
        
        // Need to wrap in start test to make sure the UserTrigger finishes what it needs to do
        Test.startTest();
        setUpScenario(true);
        Test.stopTest();
        
        User u = [SELECT Id FROM User WHERE Alias=:USER_ALIAS];
        System.runAs(u) {
            CaseSellerSelectionExtension ext = new CaseSellerSelectionExtension(new ApexPages.StandardController(newCase()));
            ext.selectedOption = 'self';
            ext.selectedRecordType = WalmartConstants.ONBOARDING_CASE_RECORD_TYPE_NAME;
            PageReference pageRef = ext.continueForm();
            // System.debug('<<< testContinueSelfSelected: ' + pageRef.getUrl());
            System.assert(pageRef.getUrl().contains('isCPCaseForSeller=false'));
        }
    }
    
    private static testMethod void testContinueSellerSelected() {
        
        // Need to wrap in start test to make sure the UserTrigger finishes what it needs to do
        Test.startTest();
        setUpScenario(true);
        Test.stopTest();
        
        User u = [SELECT Id FROM User WHERE Alias=:USER_ALIAS];
        System.runAs(u) {
            CaseSellerSelectionExtension ext = new CaseSellerSelectionExtension(new ApexPages.StandardController(newCase()));
            ext.selectedOption = 'seller';
            //ext.caseRecord.In_Reference_to_Seller__c = [SELECT Id FROM Account WHERE Name=:SELLER_ACCOUNT_1_NAME].Id;
            PageReference pageRef = ext.continueForm();
            // System.debug('<<< testContinueSellerSelected: ' + pageRef.getUrl());
           // System.assert(pageRef.getUrl().contains('isCPCaseForSeller=true'));
        }
    }
    
    private static void setUpScenario(Boolean hasSeller) {
        
        // set up channel partner 1
        Account acct = createAccount(CP_ACCOUNT_1_NAME, 'Channel Partner');
        insert acct;
        
        //Account acct1 = createAccount('testNAme', 'Channel Partner');
        //insert acct1;

        
        Id channelPartnerId = [SELECT Id FROM Account WHERE Name=:CP_ACCOUNT_1_NAME].Id;
        
        if (hasSeller) {
            // set up seller account 1
            acct = createAccount(SELLER_ACCOUNT_1_NAME, 'Seller');
            insert acct;
            
            // set up partner joins
            /*
            Id sellerId = [SELECT Id FROM Account WHERE Name=:SELLER_ACCOUNT_1_NAME].Id;
            Partner_Join__c aJunction = new Partner_Join__c(Channel_Partner__c = channelPartnerId, Seller__c = sellerId);
            insert aJunction;
            */
        }
        
        // set up channel partner contact 1
        Contact aContact = createContact(channelPartnerId, CONTACT_1_NAME);
        insert aContact;
        
        // create user
        Profile p = [SELECT Id FROM Profile WHERE Name=:'System Administrator'];
        User u = [SELECT Id FROM User WHERE ProfileId=:p.Id AND IsActive = True Limit 1];
        
        System.runAs(u) {
          //User users = TestUtilityClass.createUsers();
          User aUser1 = createTestUser(aContact.Id, aContact.LastName);
          insert auser1;
        }
    }
    
    private static Account createAccount(String theName, String theType) {
     recordtype rec = [select id from recordtype where name=: 'MP Account' AND sObjectType =: 'Account' limit 1];
        Account acct = new Account(Name = theName,
               BillingStreet = 'test street',
               BillingCity = 'test city',
               BillingState = 'Alabama',
               BillingCountry = 'United States',
               ShippingCountry = 'United States',
               BillingPostalCode = '012345',
               Type = theType,
               Website = 'www.test.com',
               recordTypeId = rec.Id);
        return acct;
    }
    
    private static Contact createContact(Id theAcctId, String theLastName) {
        Contact aContact = new Contact( FirstName = 'seller',
                            LastName = theLastName,
                            Title = 'Tester',
                            Phone = '12345678',
                            Email = 'testcontact@test.com',
                            MailingCountry = 'United States',
                            AccountId = theAcctId); 
        return aContact;
    }
    
    private static User createTestUser(Id theContactId, String theName) {
        //UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        //UserRole portalRole = [Select Id From UserRole Where Name =: 'ShipRushZFirmCustomerUser' Limit 1];
        Profile p = [SELECT Id FROM Profile WHERE Name=:WalmartConstants.SELLER_COMMUNITY_CHANNEL_PARTNER_PROFILE_NAME];
        //UserRole ur = new UserRole();
        //ur.PortalType = 'Partner';
        //ur.PortalAccountId = acct;
        //insert ur;
        User u = new User(Alias = USER_ALIAS, Email='standarduser@testorg.com',
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles', UserName=theName+'@test.org'
                );
        
        u.contactId = theContactId;
        return u;
    }
    
    private static Case newCase() {
        return new Case(Status='New', Subject='Test case');
    }

}
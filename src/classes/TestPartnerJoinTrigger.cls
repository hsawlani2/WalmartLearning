@isTest
private class TestPartnerJoinTrigger {
    
    private static final String CP_ACCOUNT_NAME = 'channel_partner_account';
    private static final String S_ACCOUNT_NAME = 'seller_account';
    private static final String S_ACCOUNT_NAME_2 = 'seller_account2';
    private static final String CONTACT_LAST_NAME = 'contact';
    private static final String USERNAME = 'standarduser@testorg111.com';
    
    @testSetup
    private static void setUpTestData() {
        Account testChannelPartnerAccount = createTestAccount(CP_ACCOUNT_NAME, 'Channel Partner');
        Account testChannelPartnerAccount2 = createTestAccount(CP_ACCOUNT_NAME + '_2', 'Channel Partner');
        Contact testContact = createTestContact(testChannelPartnerAccount);
        createTestUser(testContact);
        createTestAccount(S_ACCOUNT_NAME, 'Seller');
        createTestAccount(S_ACCOUNT_NAME_2, 'Seller');
    }

    private static testMethod void test() {
        Account sellerAccount = [SELECT Id, Integration_Channel__c,Integration_Method__c FROM Account WHERE Name = :S_ACCOUNT_NAME];
        Account sellerAccount2 = [SELECT Id, Integration_Channel__c,Integration_Method__c FROM Account WHERE Name = :S_ACCOUNT_NAME_2];
        Account channelPartnerAccount = [SELECT Id, Integration_Channel__c,Integration_Method__c FROM Account WHERE Name = :CP_ACCOUNT_NAME];
        Account channelPartnerAccount2 = [SELECT Id, Integration_Channel__c,Integration_Method__c FROM Account WHERE Name = :CP_ACCOUNT_NAME + '_2'];
        User testUser = [SELECT Id FROM User WHERE UserName = :USERNAME];
        
        sellerAccount.Integration_Method__c ='test';
        update sellerAccount;
        // start test by creating the junction object
        Test.startTest();
        Partner_Join__c toInsert = new Partner_Join__c(Channel_Partner__c = channelPartnerAccount.Id, Seller__c = sellerAccount.Id);
        insert toInsert;

        Partner_Join__c toInsert1 = new Partner_Join__c(Channel_Partner__c = channelPartnerAccount2.Id, Seller__c = sellerAccount.Id);
        insert toInsert1;
        
        Partner_Join__c toInsert2 = new Partner_Join__c(Channel_Partner__c = channelPartnerAccount.Id, Seller__c = sellerAccount2.Id);
        //insert toInsert2;
        
        
        List<AccountShare> sharingRules = [SELECT AccountId, UserOrGroupId, AccountAccessLevel FROM AccountShare 
                                            WHERE AccountId = :sellerAccount.Id AND UserOrGroupId = :testUser.Id];
        System.assert(sharingRules.size() > 0, 'Must have created a sharing rule');
        System.assertEquals(sellerAccount.Id, sharingRules[0].AccountId);
        System.assertEquals(testUser.Id, sharingRules[0].UserOrGroupId);
        System.assertEquals('Read', sharingRules[0].AccountAccessLevel);
        
        for (Account anAccount : [SELECT Id, Integration_Channel__c FROM Account]) {
            System.debug('<<< Id: ' + anAccount.Id + ' integration channel: ' + anAccount.Integration_Channel__c);
        }
        
        
        // after this remove the sharing rule we created
        Partner_Join__c toDelete = [SELECT Id FROM Partner_Join__c WHERE Channel_Partner__c =:channelPartnerAccount.Id AND Seller__c = :sellerAccount.Id];
        delete toDelete;
        sharingRules = [SELECT AccountId, UserOrGroupId, AccountAccessLevel FROM AccountShare 
                                            WHERE AccountId = :sellerAccount.Id AND UserOrGroupId = :testUser.Id];
        System.assert(sharingRules.size() == 0, 'Must have deleted the sharing rule');
        
        
        Test.stopTest();
                                            
    }
    
    private static User createTestUser(Contact theContact) {
        
        Profile p = [SELECT Id FROM Profile WHERE Name=:WalmartConstants.SELLER_COMMUNITY_CHANNEL_PARTNER_PROFILE_NAME];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles', UserName=USERNAME
                );
        
        u.contactId = theContact.Id;
        insert u;
        return u;
    }
    
    
    private static Account createTestAccount(String accountName, String theType) {
        Account acct = new Account(Name = accountName,
                           BillingStreet = 'test street',
                           BillingCity = 'test city',
                           BillingState = 'Alabama',
                           BillingCountry = 'United States',
                           ShippingCountry = 'United States',
                           BillingPostalCode = '012345',
                           Website = 'www.test.com',
                           Type = theType);
        insert acct;
        return acct;
    }
    
    private static Contact createTestContact(Account acct) {
        Contact sellerContact = new Contact( FirstName = 'seller',
                            LastName = CONTACT_LAST_NAME,
                            Title = 'Tester',
                            Phone = '12345678',
                            Email = 'testcontact@test.com',
                            MailingCountry = 'United States',
                            AccountId = acct.id); 
        insert sellerContact;
        return sellerContact;
    }

}
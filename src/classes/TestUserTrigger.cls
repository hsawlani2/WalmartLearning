@isTest
private class TestUserTrigger {
    
    private static String SELLER_ACCOUNT_1_NAME = 'Mike';
    private static String SELLER_ACCOUNT_2_NAME = 'TED';
    private static String CP_ACCOUNT_1_NAME = 'CP_ACCOUNT_1';
    private static String CONTACT_1_NAME = 'CONTACT_1';
    private static String CONTACT_2_NAME = 'CONTACT_2';
    
    /**
     * Test scenario: One channel partner account connected to two 2 seller accounts
     * Two contacts associated with the channel partner
     * New users will be created to each contact eventually
     */
    @testSetup
    private static void setUpTest() {
        Recordtype rec = [select id from recordtype where developername='MP_Account' Limit 1];
        // set up seller account 1
        list<Account> lstAccounts = new list<Account>();
        Account acct1 = createAccount(SELLER_ACCOUNT_1_NAME, 'Seller',rec);
        /*try{
        insert acct1;
        }
        catch(Exception exp){
            system.debug('Exception==> '+ exp);
        }*/
        lstAccounts.add(acct1);
        
        // set up seller account 2
        Account acct2 = createAccount(SELLER_ACCOUNT_2_NAME, 'Seller',rec);
        /*try{
        insert acct2;
        }
        catch(Exception exp){
            system.debug('Exception==> '+ exp);
        }*/
        lstAccounts.add(acct2);
        
        // set up channel partner 1
        Account acct3 = createAccount(CP_ACCOUNT_1_NAME, 'Channel Partner',rec);
        /*try{
        insert acct3;
        }
        catch(Exception exp){
            system.debug('Exception==> '+ exp);
        }*/
        lstAccounts.add(acct3);
        insert lstAccounts;
        
        
        // set up partner joins
        Id channelPartnerId = [SELECT Id FROM Account WHERE Name=:CP_ACCOUNT_1_NAME].Id;
        //Id sellerId = [SELECT Id FROM Account WHERE Name=:SELLER_ACCOUNT_1_NAME].Id;
        //Partner_Join__c aJunction = new Partner_Join__c(Channel_Partner__c = channelPartnerId, Seller__c = sellerId);
        //insert aJunction;
        
        //sellerId = [SELECT Id FROM Account WHERE Name=:SELLER_ACCOUNT_2_NAME].Id;
        //aJunction = new Partner_Join__c(Channel_Partner__c = channelPartnerId, Seller__c = sellerId);
        //insert aJunction;
        
        // set up channel partner contact 1
        List<Contact> lstContacts = new List<Contact>();
        Contact aContact = createContact(channelPartnerId, CONTACT_1_NAME);
        //insert aContact;
        lstContacts.add(aContact);
        // set up channel partner contact 2
        aContact = createContact(channelPartnerId, CONTACT_2_NAME);
        //insert aContact;
        lstContacts.add(aContact);
        insert lstContacts;
        
       Integration_Method_Mapping__c immap = new Integration_Method_Mapping__c();
       immap.Account_Id__c=channelPartnerId;
       immap.Account_Name__c = CP_ACCOUNT_1_NAME;
       immap.Name= 'IM-001';
       insert immap;
       
    }

  private static testMethod void testUserTrigger() {
        
        Test.startTest();
        
        // insert user 1
        Contact aContact = [SELECT Id, LastName FROM Contact WHERE LastName=:CONTACT_1_NAME];
        User aUser1 = createTestUser(aContact.Id, aContact.LastName);
        insert aUser1;
        
        // insert user 2
        contact bContact = [SELECT Id, LastName FROM Contact WHERE LastName=:CONTACT_2_NAME];
        User aUser2 = createTestUser(bContact.Id, bContact.LastName);
        insert aUser2;
        
        
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name=:SELLER_ACCOUNT_1_NAME];
        
        for(Account oAccount :lstAccounts){
            oAccount.Integration_Channel__c = 'Partner';
            oAccount.Integration_Method__c = CP_ACCOUNT_1_NAME;
        }
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update lstAccounts;
        Test.stopTest();
        
        
        // assertions here
        List<AccountShare> accessList = [SELECT Id FROM AccountShare WHERE UserOrGroupId=:aUser1.Id];
        //System.assertEquals(2, accessList.size());
        
        accessList = [SELECT Id FROM AccountShare WHERE UserOrGroupId=:aUser2.Id];
        //System.assertEquals(2, accessList.size());
  }
  
  private static Account createAccount(String theName, String theType,RecordType rectype ) {
      Account acct = new Account(Name = theName,
               BillingStreet = 'test street',
               BillingCity = 'test city',
               BillingState = 'Alabama',
               BillingCountry = 'United States',
               ShippingCountry = 'United States',
               BillingPostalCode = '012345',
               Type = theType,
               RecordTypeID=rectype.ID,
               Website = 'www.test.com',
              Seller_Onboarding_Status__c = 'Seller Setup');
        return acct;
  }
  
  private static Contact createContact(Id theAcctId, String theLastName) {
      Contact aContact = new Contact( FirstName = 'seller',
                            LastName = theLastName,
                            Title = 'Tester',
                            Phone = '12345678',
                            Email = theLastName+'testcontact@test.com',
                            MailingCountry = 'United States',
                            AccountId = theAcctId); 
        return aContact;
  }
  
  
  private static User createTestUser(Id theContactId, String theName) {
      
      Profile p = [SELECT Id FROM Profile WHERE Name=:WalmartConstants.SELLER_COMMUNITY_CHANNEL_PARTNER_PROFILE_NAME];
      User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
              LocaleSidKey='en_US', ProfileId = p.Id,
              TimeZoneSidKey='America/Los_Angeles', UserName=theName+'@test.org'
              );
      
        u.contactId = theContactId;
        return u;
  }

}
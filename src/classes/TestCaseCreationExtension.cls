/**
 * @see CaseCreationExtension
 * 
 * @author		Cloud Sherpas
 * @createddate	10-March-2016
 */ 

@isTest
private class TestCaseCreationExtension {
    
    private static final String PARENT_CASE_SUBJECT = 'ParentCase';
    private static final String CURRENT_CASE_SUBJECT = 'FollowUpCase';
    private static final String ACCOUNT_NAME = 'test Acc';
    private static final String CONTACT_LAST_NAME = 'contact';
    private static final String USERNAME = 'standarduser@testorg111.com';
    private static final Integer ARTICLE_COUNT = 5;
    private static final String KB_URL = 'http://sampleurl.com/';
    
    /**
     * Set up the test scenario. We have successfully tested different user profiles and record types on TestCaseExtension,
     * so we can be comfortable testing this class using just one profile.
     * 
     * For these series of tests, we're only creating an account, contact and user once, 
     * and create a new case (and subsequently a controller) for every test method.
     */
    @testSetup
    private static void setUp() {
        createCustomSettings();

        Account testAccount = createTestAccount();
        Contact testContact = createTestContact(testAccount);
        createTestUser(testAccount, testContact);
        createKnowledgeArticles();
    }
    
    /**
     * Invokes a part of the preceding controller/VF before proceeding with actual controller creation because
     * we need the get params from the prior.
     */
    private static CaseCreationExtension createExt() {
        
        // Account and contact are already created in the setUp method.
        Account testAccount = [SELECT Id FROM Account WHERE Name=:ACCOUNT_NAME];
        Contact testContact = [SELECT Id FROM Contact WHERE LastName=:CONTACT_LAST_NAME];
        Case testCase = createTestCase(testAccount, testContact, false, false);
        
        // create a parent case and fetch it
        createTestCase(testAccount, testContact, true, true);
        Case testParentCase = [SELECT Id, CaseNumber FROM Case WHERE Subject=:PARENT_CASE_SUBJECT];
        
        Test.setCurrentPage(Page.newCaseCreation);
        System.currentPageReference().getParameters().put('isFollowUpCase', 'true');
        System.currentPageReference().getParameters().put('parentCaseNumber', testParentCase.CaseNumber);
    
        CaseExtension caseExt = new CaseExtension(new ApexPages.StandardController(testCase));
        PageReference pageRef = caseExt.verifyUserAndRedirect();
        Test.setCurrentPageReference(pageRef);
        return new CaseCreationExtension(new ApexPages.StandardController(testCase));
    }
    
    /**
     * Tests the constructor method to make sure needed get params are interpreted correctly.
     * Also test the some of the Getters that the VF looks for.
     */
	private static testMethod void testInitAndGetters() {
	    System.runAs(fetchUser()) {
	        Test.startTest();
	        CaseCreationExtension controller = createExt();
	        Test.stopTest();
	        System.assertNotEquals(controller.caseRecord, null);
    	    System.assertNotEquals(controller.caseRecordTypeId, null);
    	    System.assertNotEquals(controller.deflectionRecordId, null);
    	    System.assertNotEquals(controller.contactId, null);
    	    System.assertNotEquals(controller.accountId, null);
    	    System.assertNotEquals(controller.caseRecordTypeName, null);
    	    System.assertNotEquals(controller.articlesController, null);
    	    System.assertNotEquals(controller.authToken, null);
    	    
    	    System.assertEquals(controller.getIsFollowUpCase(), true);
    	    System.assert(String.isNotBlank(controller.pkbToken), 'Should not be blank');
    	    System.assertEquals('__kav', controller.kavExt);
    	    System.assertEquals(KB_URL, controller.kbURL);
	    }
	}
	
	private static testMethod void testSave() {
	    System.runAs(fetchUser()) {
	        CaseCreationExtension ext = createExt();
	        
	        Test.startTest();
	        ext.caseRecord.Subject = 'EditedCase';
	        PageReference pageRef = ext.save();
	        Test.stopTest();
	        
	        List<Case> fetchedCases = [SELECT Id, Subject FROM Case WHERE Subject='EditedCase'];
	        System.assertEquals(fetchedCases.size(), 1);
	        System.assert(pageRef.getUrl().contains(fetchedCases.get(0).Id), 'Wrong page reference');
	        
	        // test if deflection record is sane
	        Case_Initiation__c deflectionRecord = [select Deflected__c, Case__r.Id,Case_Subject__c
	            from Case_Initiation__c where id = :ext.deflectionRecordId limit 1];
            
            System.assertEquals(deflectionRecord.Deflected__c, false);
            System.assertEquals(deflectionRecord.Case__r.Id, fetchedCases.get(0).Id);
	    }
	}
	
	private static testMethod void testCancel() {
	    System.runAs(fetchUser()) {
	        CaseCreationExtension ext = createExt();
	        Test.startTest();
	        PageReference pageRef = ext.cancel();
	        Test.stopTest();
	        System.assert(pageRef.getUrl().contains('/cases/500/o'), 'incorrect URL');
	    }
	}
	
	/**
	 * We have three scenarios for KB querying: 
	 * 1. When we searched for something and we fetched some results
	 * 2. When we searched nothing i.e. empty search query
	 * 3. When we searched for something and no results were returned
	 */
	private static testMethod void testKBQueryFilled() {
       createTestAccountWRecordType();
	   System.runAs(fetchUser()) {
	       List<KnowledgeArticleVersion> publishedArticles = [SELECT Id FROM KnowledgeArticleVersion WHERE PublishStatus='online' AND Language='en_US'];
	       List<Id> articleIds = new List<Id>();
	       for (KnowledgeArticleVersion kav : publishedArticles) {
	           articleIds.add(kav.Id);
	       }
	       Test.setFixedSearchResults(articleIds); // Forces indexing for SOSL queries
	       
	       CaseCreationExtension ext = createExt();
	       Test.startTest();
	       ext.searchQuery = 'article';
	       ext.performSearch();
	       Test.stopTest();
	       System.assertEquals(ext.getDisplaySearchHelp(), false);
	       System.assertEquals(ext.getDisplayNoArticles(), false);
	       System.assertEquals(ext.getResults().size(), ARTICLE_COUNT);
	   } 
	}
	
	private static testMethod void testKBQueryEmptyQuery() {
	    System.runAs(fetchUser()) {
	        CaseCreationExtension ext = createExt();
	        Test.startTest();
	        ext.searchQuery = '';
	        ext.performSearch();
	        Test.stopTest();
	        System.assertEquals(ext.getDisplaySearchHelp(), true);
	    }
	}
	
	private static testMethod void testKBQueryNoResults() {
        createTestAccountWRecordType();
	    System.runAs(fetchUser()) {

	        Test.setFixedSearchResults(new List<Id>()); // Should return no results
	        
	        CaseCreationExtension ext = createExt();
	        Test.startTest();
	        ext.searchQuery = 'abcdefg';
	        ext.performSearch();
	        Test.stopTest();
	        System.assertEquals(ext.getDisplaySearchHelp(), false);
	        System.assertEquals(ext.getDisplayNoArticles(), true);
	    }
	}
	
	private static testMethod void testSaveArticleDeflection() {
	    System.runAs(fetchUser()) {
	       
	        CaseCreationExtension ext = createExt();
	        Test.startTest();
	        ext.deflectedArticleLink = 'http://deflectedarticle.com/bla?token=123123123231';
	        ext.saveArticleDeflection();
	        Test.stopTest();
	        
	        List<Case_Initiation__c> caseInitiations = [SELECT Id, Deflected__c, Knowledge_Link__c, Case_Subject__c 
                FROM Case_Initiation__c WHERE Id=:ext.deflectionRecordId LIMIT 1];
            
	        System.assert(caseInitiations.size() > 0);
	        Case_Initiation__c caseInitiation = caseInitiations.get(0);
	        System.assertEquals(true, caseInitiation.Deflected__c);
	    }
	}
	
    /*  
    Scenario: Create an Account without a KB_Category_Visibility__c value.
    Result: We should return all the articles in the test domain (i.e. ARTICLE_COUNT), since we don't have a category context.
    */
    @isTest
	private static void testKBQueryFilledWithoutKbCategoryVisibility() {
		Account localAcct = createTestAccountWRecordType();
		List<Account> localAccountList = [Select id, name, KB_Category_Visibility__c from Account Where id = :localAcct.Id];
		System.assertEquals(1, localAccountList.size());
		System.assertEquals(localAccountList[0].KB_Category_Visibility__c, 'Seller');
		localAccountList[0].KB_Category_Visibility__c = null;
		update localAccountList;
		Account lclTestAccount = [Select id, name, KB_Category_Visibility__c from Account Where id = :localAcct.Id];
		System.assertEquals(lclTestAccount.Id, localAcct.Id);
		System.assertEquals(lclTestAccount.KB_Category_Visibility__c, null);
	    Contact sellerContact2 = new Contact( FirstName = 'seller2',
							LastName = CONTACT_LAST_NAME,
							Title = 'Tester2',
							Phone = '12345678',
							Email = 'testcontact2@test.com',
							MailingCountry = 'United States',
							AccountId = localAcct.Id); 
	    insert sellerContact2;
        Contact lclTestContact = [Select id, name from Contact where id = :sellerContact2.Id];
	    Profile p = [SELECT Id FROM Profile WHERE Name=:WalmartConstants.SELLER_COMMUNITY_USER_PROFILE_NAME];
	    User communityUser = new User(Alias = 'standt', Email='testcontact2@test.com',
    	        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
    	        LocaleSidKey='en_US', ProfileId = p.Id,
    	        TimeZoneSidKey='America/Los_Angeles', UserName='testcontact2@test.com'
    	        );
	    
        communityUser.contactId = lclTestContact.Id;
        insert communityUser;

		System.runAs(communityUser) {
			List<KnowledgeArticleVersion> publishedArticles = [SELECT Id FROM KnowledgeArticleVersion WHERE PublishStatus='online' AND Language='en_US'];
			List<Id> articleIds = new List<Id>();
			for (KnowledgeArticleVersion kav : publishedArticles) {
			   articleIds.add(kav.Id);
			}
			Test.setFixedSearchResults(articleIds); // Forces indexing for SOSL queries

			CaseCreationExtension ext = createExt();
			Test.startTest();
			ext.searchQuery = 'article';
			ext.performSearch();
			Test.stopTest();
			System.assertEquals(ext.getDisplaySearchHelp(), false);
			System.assertEquals(ext.getDisplayNoArticles(), false);
			System.assertEquals(ext.getResults().size(), ARTICLE_COUNT);
		}
	}
	
	// ---------------------
	// TEST SETUP METHODS
	// ---------------------
    
    private static User createTestUser(Account theAccount, Contact theContact) {
	    
	    Profile p = [SELECT Id FROM Profile WHERE Name=:WalmartConstants.SELLER_COMMUNITY_USER_PROFILE_NAME];
	    User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
    	        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
    	        LocaleSidKey='en_US', ProfileId = p.Id,
    	        TimeZoneSidKey='America/Los_Angeles', UserName=USERNAME
    	        );
	    
        u.contactId = theContact.Id;
        insert u;
        return u;
	}
	
	private static Account createTestAccount() {
	    Account acct = new Account(Name = ACCOUNT_NAME,
                           BillingStreet = 'test street',
                           BillingCity = 'test city',
                           BillingState = 'Alabama',
                           BillingCountry = 'United States',
                           ShippingCountry = 'United States',
                           BillingPostalCode = '012345',
                           Website = 'www.test.com');
        insert acct;
        return acct;
	}
	
	private static Account createTestAccountWRecordType() {
        Map<ID, RecordType> rtMap = new Map<ID, RecordType>([Select Id, Name, IsActive, BusinessProcessId, DeveloperName, SObjectType from RecordType Where SObjectType = 'Account']);
	    Account acct = new Account(Name = ACCOUNT_NAME,
                           BillingStreet = 'test street',
                           BillingCity = 'test city',
                           BillingState = 'Alabama',
                           BillingCountry = 'United States',
                           ShippingCountry = 'United States',
                           BillingPostalCode = '012345',
                           Website = 'www.test.com',
                           RecordTypeId = rtMap.get('012610000002gtz').Id); //Seller Record Type.
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
	
	private static Case createTestCase(Account acct, Contact sellerContact, Boolean isParent, Boolean shouldInsert) {
        Case caseRec = new Case(Status = 'WIP',
                           AccountId = acct.Id, ContactId = sellerContact.Id);
        caseRec.Subject = isParent ? PARENT_CASE_SUBJECT : CURRENT_CASE_SUBJECT;
        
        // only insert parent cases: child cases will be saved in subsequent events
        if (shouldInsert) {
            insert caseRec;    
        }
        return caseRec;
	}
	
	private static void createCustomSettings() {
	    PKB_TOKEN_COOKIE_TIMEOUT_HOURS__c timeoutHours = new PKB_TOKEN_COOKIE_TIMEOUT_HOURS__c(Name='Default');
	    timeoutHours.TIMEOUT_HOURS__c = 4;
	    insert timeoutHours;
	    
	    KNOWLEDGEBASE_URL__c kbURL = new KNOWLEDGEBASE_URL__c(Name='Default');
	    kbURL.KB_URL__c = KB_URL;
	    insert kbURL;

	    // 20161227 CDSIM-1074 Add cs for Community Case Article filter process.
	    Account_Custom_Settings__c[] sellerCSRecord = new Account_Custom_Settings__c[] {
	    													new Account_Custom_Settings__c(Name='MP_Account', 
															Matching_Configured_Data_Category__c='Marketplace__c',
															RecordTypeNameValue__c='Seller'),
															new Account_Custom_Settings__c(Name='X1P_Account',
															Matching_Configured_Data_Category__c='Suppliers__c',
															RecordTypeNameValue__c='Supplier')};
	    insert sellerCSRecord;
        
     
    }
	
	private static User fetchUser() {
	    return [SELECT Id FROM User WHERE UserName=:USERNAME];
	}
	
	/**
	 * Warning: To use this method without encountering errors, the user running the test must have Knowledge enabled.
	 */
	private static void createKnowledgeArticles() {
	    List<Article__kav> articlesToInsert = new List<Article__kav>();
	    for (Integer i = 1; i <= ARTICLE_COUNT; i++) {
	        Article__kav article= new Article__kav(
                Title = 'article '+i,
                UrlName = 'article-'+i,
                IsVisibleInPkb = true,
                IsVisibleInCsp = true,
                Language = 'en_US',
                Summary = 'article '+i,
                Information__c = 'article '+i
            );
            articlesToInsert.add(article);
            
	    }
	    insert articlesToInsert;
	    
	    List<Id> insertedIds = new List<Id>();
	    for (Article__kav anArticle : articlesToInsert) {
	        insertedIds.add(anArticle.Id);
	    }
	    
	    List<KnowledgeArticleVersion> articleVersions = [SELECT KnowledgeArticleId FROM KnowledgeArticleVersion WHERE Id IN :insertedIds];
	    System.assertEquals(articleVersions.size(), ARTICLE_COUNT);
	    
	    for (KnowledgeArticleVersion aKav : articleVersions) {
	        KbManagement.PublishingService.publishArticle(aKav.KnowledgeArticleId, true);
	    }
	    
	}

}
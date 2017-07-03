@isTest
private class WalmartPkbControllerTest {

    static String siteName = 'PKB_TEST_' + String.valueOf(Crypto.getRandomInteger());    // use this to set the siteName prop of the pkb_Controller class
    static String publishStatus = 'draft'; // use this to set the pub status prop of the pkb_Controller
    static String lang = pkb_SettingsController.DEFAULT_LANGUAGE;//'en_US';
    static PKB__c pkb;
    static SObject kavObj;
    static String objType;
    static PKB_Featured__c featured;
    static PKB_Featured__c keyword;
    static List<PKB_Article_Feedback_Deflection__c> pafds;
    class TestException extends Exception { }

    static testMethod void testController() {
        setupData();
        categoryGroup1();

        Id kaId = (Id)kavObj.get('KnowledgeArticleId');
        Id kavId = (Id)kavObj.get('Id');
        String articleNumber = (String)kavObj.get('ArticleNumber');

        System.debug('***** SITE NAME: ' +siteName+ '*****');
        System.debug('***** PKB NAME: ' +pkb.Name+ '*****');
        System.debug('***** KEYWORD PKB NAME: ' +keyword.PKB_Name__c+ ' *****');

        System.debug('***** DOES KEYWORD RECORD EXIST? *****');
        System.debug([select Id, Name, Article_Number__c from PKB_Article_Feedback_Deflection__c where Id = :keyword.Id]);

        String catString;

        // setupData will have instantiated kavObj, and if it hasn't, show the error and return
        if (kavObj == null) {
          System.debug('***** APEX UNIT TEST ERROR: PLEASE ENSURE THAT AT LEAST ONE CUSTOM ARTICLE TYPE IS DEFINED IN THE ORG *****');
          return;
        }

        // set the fixed search results to all possible ids that should be returned via sosl throughout the code
        List<String> searchResults = new List<String>{
          keyword.Id,
          kavId
        };
        Test.setFixedSearchResults(searchResults);

        System.debug('***** THESE IDs WILL ALWAYS RETURN WITH SOSL QUERIES: ***** ');
        System.debug(searchResults);

        // refCon is an essentially empty instance of the controller that allows access to the public variables that refer
        // to the names of the various url params that will be used to set up tests
        walmart_pkb_Controller refCon = new walmart_pkb_Controller();
        walmart_pkb_Controller pkbCon;
        PageReference p;

        // test first with no params and empty KA
        p = new PageReference('/');
        System.debug('****** TESTING WITH URL: ' +p.getUrl()+ ' *****');
        Test.setCurrentPage(p);
        pkbCon = new walmart_pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));
        System.assertNotEquals(pkbCon.publishStatus, null);

        // test with query of foo, language of english, and random category, and generate search RSS
        p = new PageReference('/');
        p.getParameters().put(refCon.queryParam, 'foor');
        p.getParameters().put(refCon.languageParam, lang);

        p.getParameters().put(refCon.categoryParam, catString);
        System.debug('****** TESTING WITH URL: ' +p.getUrl()+ ' *****');
        Test.setCurrentPage(p);
        pkbCon = new walmart_pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));
        pkbCon.prepareSearchRSS();

        // test with actual article id, so that viewingArticle will be true in the controller
        p = new PageReference('/?id=' +kaId);
        System.debug('****** TESTING WITH URL: ' +p.getUrl()+ ' *****');
        Test.setCurrentPage(p);
        pkbCon = new walmart_pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle(Id = kaId)));
        pkbCon.prepareSearchRSS(); // to execute negative branch of first line of method

        // run through a bunch of the basic props
        System.assertNotEquals(pkbCon.pageTitle, null);
        System.assertNotEquals(pkbCon.selectedLanguageURL, null);
        pkbCon.selectedCategory = 'foo';
        System.assertNotEquals(pkbCon.selectedCategoryLabel, null);
        pkbCon.selectedCategory = '';
        System.assert(!pkbCon.caseCreateError);
        System.assert(!pkbCon.caseCreated);
        System.assert(!pkbCon.feedbackRecorded);
        System.assertNotEquals(pkbCon.languageOptions, null);
        System.assertEquals(pkbCon.currPage, 1);
        pkbCon.nextPage();
        pkbCon.prevPage();
        System.assertEquals(pkbCon.currPage, 1);

        // test basic defferal -- a deflection record should be created with an article associated to it since an article is being viewed
        pkbCon.deferred();
        pafds = [select Id, Session_ID__c from PKB_Article_Feedback_Deflection__c where Article_Number__c = :articleNumber];
        System.assert(pafds.size() == 1);


        //check that the deflection has been related to the contact
        pafds = [select Id, Session_ID__c from PKB_Article_Feedback_Deflection__c where Session_ID__c = :pkbCon.sessionId];
        System.assert(pafds.size() == 1);
        system.debug('\n\n===== MY TEST PKB_Article_Feedback_Deflection__c : '+pafds+'\n sessionID '+pkbCon.sessionId);
        // test with contact us, while viewing article, and already entered question
        p = new PageReference('/');
        p.getParameters().put('id', kaId);
        p.getParameters().put(refCon.contactUsParam, refCon.contactUsValue);
        //p.getParameters().put(refCon.queryParam, 'help me');
        System.debug('****** TESTING WITH URL: ' +p.getUrl()+ ' *****');
        Test.setCurrentPage(p);
        pkbCon = new walmart_pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle(Id = kaId)));

        // should add another defferal record
        pkbCon.feedbackComments = 'some comments';
        pkbCon.recordArticleFeedback();
        pafds = [select Id from PKB_Article_Feedback_Deflection__c where Article_Number__c = :articleNumber];
        System.assert(pafds.size() == 2);

        // should add another defferal record
        pkbCon.contactUsDeferral();
        pafds = [select Id from PKB_Article_Feedback_Deflection__c where Article_Number__c = :articleNumber];
        System.assert(pafds.size() == 3);

        // // set up for case creation
        // pkbCon.theCud.firstName = 'Foo';
        // pkbCon.theCud.lastName = 'Bar';
        // pkbCon.theCud.email = 'test@gmail.com'; 
        // pkbCon.createCase();
        // System.assert(pkbCon.caseCreateError);

        // System.debug('***** CASE TYPE OPTS: *****');
        // System.debug(refCon.caseTypeOptions);

        String validType = 'foo';
        if (!refCon.caseTypeOptions.isEmpty()) {
          for (SelectOption so : refCon.caseTypeOptions) {
            if (!isBlank(so.getValue())) validType = so.getValue();
            break;
          }
        }

        Boolean b = pkbCon.displayCategory1;
        b = pkbCon.displayCategory2;
        b = pkbCon.displayCategory3;
        b = pkbCon.displayNarrow;

        b = pkbCon.displayFeedbackYesNo;
        b = pkbCon.displayFeedbackDialog;

        // // email should fail
        pkbCon.theCud.firstName = 'Foo';
        pkbCon.theCud.lastName = 'Bar';
        pkbCon.theCud.email = 'foo';
        pkbCon.theCud.reqType = validType;
        // pkbCon.createCase();
        // System.debug(pkbCon.theCud.firstName);
        // System.debug(pkbCon.theCud.lastName);
        // System.debug(pkbCon.theCud.email);
        // System.debug(pkbCon.theCud.reqType);
        // System.assert(pkbCon.caseCreateError);
        // System.debug('***** ERROR MSG: ' +pkbCon.createCaseErrorMsg+ ' *****');

        // // make email pass
        pkbCon.theCud.email = siteName+ '@bar.com';
        // System.debug(pkbCon.theCud.email);
        pkbCon.createCase();
        // System.debug('***** ERROR MSG: ' +pkbCon.createCaseErrorMsg+ ' *****');
        // // System.assert(!pkbCon.caseCreateError);

        // // flip the pkb setting to create account and contact
        // pkb.Create_Contact_and_Account__c = true;
        // update pkb;
        // pkbCon.createCase();

        // System.debug('***** FROM TEST, CURRENT CON/ACCT CREATION SETTING VALUE: ' +pkb.Create_Contact_and_Account__c+ ' *****');

        // // set site admin to a fake user when testing
        // pkbCon.siteAdmin = new User(FirstName = 'Test', LastName = 'Admin', Email = 'TestAdmin@foo.com');
        // pkbCon.createCase(); // this will succeed
        // pkbCon.theCase = pkbCon.theCase.clone(false);
        // pkbCon.theCud.firstName = '';
        // pkbCon.theCud.lastName = '';
        // pkbcon.theCud.email = null;
        // System.debug('***** CUSTOMER ENTERED DATE FROM TEST: *****');
        // System.debug(pkbCon.theCud);
        // pkbCon.insertRecords(); // this will fail due to setting first/last to null
        // System.assert(pkbCon.caseCreateError);

        // // requery the custom setting and assert that the value was flipped
        // System.debug('***** CREATE SETTING BEFORE REQUERY: ' +pkb.Create_Contact_and_Account__c+ ' *****');
        // pkb = PKB__c.getInstance(siteName);
        // System.debug('***** CREATE SETTING AFTER REQUERY: ' +pkb.Create_Contact_and_Account__c+ ' *****');
        // System.assert(!pkb.Create_Contact_and_Account__c);

        // // make theCud valid again but hijack theCase with a fake account id (which will throw a Dml Exception)
        // pkbCon.theCase = pkbCon.theCase.clone(false);
        // pkbCon.theCud.firstName = 'Foo';
        // pkbCon.theCud.lastName = 'Bar';
        // pkbCon.theCud.email = siteName+ '@bar.com';
        // pkbCon.theCud.reqType = validType;
        // pkbCon.createCase();
        // pkbCon.theCase.AccountId = '0013010101jQrdW'; // fake account number, on purpose, have to call this after createCase since createCase instantiates theCase
        // pkbCon.insertRecords();
        // System.debug('***** CREATE CASE FINISHED *****');
        // System.assert(pkbCon.caseCreateError);

        // testing some static stuff and other independent operations
        TestException e = new TestException('Test Exception!!');
        walmart_pkb_Controller.debugException(e);
        pkbCon.notifyAdmin(null, e, 'some message here');

        pkbCon.selectedCategory = null;
        System.assertEquals(pkbCon.buildCategorySosl(), null);
        pkbCon.selectedCategory = 'foo_t:bar';
        System.assertNotEquals(pkbCon.buildCategorySosl(), null);

        walmart_pkb_Controller.initFromListOfArticleIds(null, lang);
        walmart_pkb_Controller.initFromListOfArticleIds(new List<String>(), lang);
        walmart_pkb_Controller.initFromListOfArticleIds(new List<String>{kaId}, lang);

        walmart_pkb_Controller.initFromListOfKAVIds(null, lang);
        walmart_pkb_Controller.initFromListOfKAVIds(new List<String>(), lang);
        walmart_pkb_Controller.initFromListOfKAVIds(new List<String>{kavId}, lang);

        User u = walmart_pkb_Controller.getSiteAdmin();
    }

    static testMethod void testSettingsController() {
    categoryGroup1();

    pkb_SettingsController refCon = new pkb_SettingsController();
    pkb_SettingsController pkbsc;
    PageReference p;

    // test with new record
    p = new PageReference('/?' +refCon.createSettingsParam+ '=' +refCon.createSettingsValue);
    Test.setCurrentPage(p);
    pkbsc = new pkb_SettingsController(new ApexPages.StandardController(new PKB__c()));
    System.assert(pkbsc.creatingSettings);

    // test with existing record
    p = new PageReference('/?id=' +pkb.Id);
    Test.setCurrentPage(p);
    pkbsc = new pkb_SettingsController(new ApexPages.StandardController(pkb));
    System.assert(!pkbsc.creatingSettings);

    // there is at least one pkb settings record and so the settings options list is not empty
    System.assert(!pkbsc.settingsOptions.isEmpty());

    // this will fail the first time since there is no site named with this test's site name
    p = pkbsc.saveSettings();
    System.assertEquals(p, null);

    // throw the test bit and try again
    // save the settings and assert that the resulting page ref contains the id of the settings
    pkb_SettingsController.isRunningTest = true;
    p = pkbsc.saveSettings();
    System.assert(p.getUrl().contains(pkb.Id));


    }


    static testMethod void testSettings_CTI_keywords() {
        categoryGroup1();

        pkb_SettingsController refCon = new pkb_SettingsController();
        pkb_SettingsController pkbsc;
        PageReference p;

        // test with existing record
        p = new PageReference('/?id=' +pkb.Id);
        Test.setCurrentPage(p);
        pkbsc = new pkb_SettingsController(new ApexPages.StandardController(pkb));

        pkb.CTI_configuration__c = '';
        pkb.Add_Case_Id__c = false;

        p = pkbsc.saveSettings();
        System.assertEquals(p, null);

        PKB__c updatedElm = null;
        Map<String,PKB__c> settingsMap = PKB__c.getAll();
        if (settingsMap.containsKey(pkb.Name)){
            updatedElm = settingsMap.get(pkb.Name);
        }

        system.assertEquals(updatedElm.Add_Case_Id__c,pkb.Add_Case_Id__c);

        //  try to save invalid keywords [[[[[p]43
        pkb.CTI_configuration__c = '[[[[[p]43';
        pkb.Add_Case_Id__c = true;

        p = pkbsc.saveSettings();
        System.assertEquals(p, null);

        updatedElm = null;
        settingsMap = PKB__c.getAll();
        if (settingsMap.containsKey(pkb.Name)){
            updatedElm = settingsMap.get(pkb.Name);
        }

        system.assertEquals(updatedElm.Add_Case_Id__c,false);

        //  try to save invalid keywords [P]3[CN]
        pkb.CTI_configuration__c = '[P]3[CN]';
        pkb.Add_Case_Id__c = true;

        p = pkbsc.saveSettings();
        System.assertEquals(p, null);

        updatedElm = null;
        settingsMap = PKB__c.getAll();
        if (settingsMap.containsKey(pkb.Name)){
            updatedElm = settingsMap.get(pkb.Name);
        }

        system.assertEquals(updatedElm.Add_Case_Id__c,false);

    }

    static testMethod void test_searchString() {
        setupData();
        categoryGroup1();

        Id kaId = (Id)kavObj.get('KnowledgeArticleId');
        Id kavId = (Id)kavObj.get('Id');
        String catString;
        // refCon is an essentially empty instance of the controller that allows access to the public variables that refer
        // to the names of the various url walmart_pkb_Controller that will be used to set up tests
        walmart_pkb_Controller refCon = new walmart_pkb_Controller();
        walmart_pkb_Controller pkbCon;
        PageReference p;

        // test first with no params and empty KA
        p = new PageReference('/');
        System.debug('****** TESTING WITH URL: ' +p.getUrl()+ ' *****');
        Test.setCurrentPage(p);
        pkbCon = new walmart_pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));
        System.assertNotEquals(pkbCon.publishStatus, null);

        // test with query of foo, language of english, and random category, and generate search RSS
        p = new PageReference('/');
        p.getParameters().put(refCon.queryParam, 'fr');
        p.getParameters().put(refCon.languageParam, lang);

        p.getParameters().put(refCon.categoryParam, catString);
        System.debug('****** TESTING WITH URL: ' +p.getUrl()+ ' *****');
        Test.setCurrentPage(p);
        pkbCon = new walmart_pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));
        //there was a search query but with less than 4 chars
        system.assertEquals(pkbCon.enteredSearchQuery, pkbCon.searchPrompt);

    }

    private static testMethod void testCommunityLogin() {
        
        createCustomSettings();
        categoryGroup1();
        String authToken = EncryptionUtility.createEncryptedString(false);
        PageReference pageRef = Page.walmart_pkb_home;
        pageRef.getParameters().put(walmart_pkb_Controller.AUTH_TOKEN, authToken);
        Test.setCurrentPage(pageRef);
        walmart_pkb_Controller aController = new walmart_pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));
        Boolean hasHeadlines = aController.hasHeadlines;
    }

    static void categoryGroup1() {
    // create custom settings collection based on siteName
        pkb = new PKB__c();
        pkb.Name = siteName;
        //pkb.Category_Group_1__c = '1';
        pkb.Category_Group_1__c = 'LifeCycle';
        pkb.Category_Group_2__c = '2';
        pkb.Category_Group_3__c = '3';
        //pkb.Root_Category_1__c = '1';
        pkb.Root_Category_1__c = 'All';
        pkb.Root_Category_2__c = '2';
        pkb.Root_Category_3__c = '3';
        pkb.Default_Category_for_Browsing__c = 'Marketplace';

        pkb.Create_Contact_and_Account__c = false;
        pkb.Display_Article_Summary__c = true;
        pkb.Multi_Language_Enabled__c = false;
        pkb.Popular_Articles_Size__c = 2;
        pkb.Related_Articles_Size__c = 2;
        pkb.Results_Page_Size__c = 2;
        insert pkb;
    }

    private static void createCustomSettings() {
        PKB_TOKEN_COOKIE_TIMEOUT_HOURS__c timeoutHours = new PKB_TOKEN_COOKIE_TIMEOUT_HOURS__c(Name='Default');
        timeoutHours.TIMEOUT_HOURS__c = 4;
        insert timeoutHours;
        
        KNOWLEDGEBASE_URL__c kbURL = new KNOWLEDGEBASE_URL__c(Name='Default');
        kbURL.KB_URL__c = 'http://sampleurl.com/';
        insert kbURL;
    }

    static void setupData() {
        
        createCustomSettings();
          
        // create article of first type found in the objects that end with __kav
        List<String> kavNames = new List<String>(walmart_pkb_Controller.kavNames);
        if (kavNames.isEmpty()) return;

        // set the controller's default pub status to draft so that the queries will find records
        walmart_pkb_Controller.DEFAULT_PUBLISH_STATUS = publishStatus;
        walmart_pkb_Controller.DEFAULT_SITE_NAME = siteName;

        objType = kavNames.get(0);

        System.debug('***** CUSTOM ARTICLE TYPE: ' +objType+ ' *****');

        kavObj = Schema.getGlobalDescribe().get(objType).newSObject();
        kavObj.put('Title','Foo Foo Foo!!!'+String.valueOf(Crypto.getRandomInteger()));
        kavObj.put('UrlName', 'foo-foo-foo'+String.valueOf(Crypto.getRandomInteger()));
        kavObj.put('Summary', 'This is a summary!!! Foo. Foo. Foo.');
        kavObj.put('Language', lang);
        insert kavObj;

        // requery the kavObj to get the KnowledgeArticleId on it that is created automatically
        String q = 'select ' +walmart_pkb_Controller.join(walmart_pkb_Controller.kavFields, ',')+ ' from KnowledgeArticleVersion where Id = \'' +kavObj.get('Id')+  '\' and PublishStatus = :publishStatus';
        kavObj = (KnowledgeArticleVersion)Database.query(q);

        // create featured record
        featured = new PKB_Featured__c(
          Article_Number__c = (String)kavObj.get('ArticleNumber'),
          Is_Keyword_Article__c = false,
          PKB_Name__c = siteName
        );
        insert featured;

        System.debug('***** FEATURED RECORD JUST CREATED: ' +featured.Id+ ' *****');
        System.debug(featured);

        // create keyword recommended record
        keyword = new PKB_Featured__c(
          Article_Number__c = (String)kavObj.get('ArticleNumber'),
          Is_Keyword_Article__c = true,
          Keyword__c = 'foo',
          PKB_Name__c = siteName
        );
        insert keyword;

        System.debug('***** KEYWORD RECORD JUST CREATED: ' +keyword.Id+ ' *****');
        System.debug(keyword);

    }

    // returns true if string is null or empty
    static Boolean isBlank(String s) {
        return ( s == null || s == '');
    }

    /* ******************** Tests related to the dropdown feature ******************** */
    @isTest
    static void testCategoriesInOrg(){
        List <String> objTypeLocal = new List<String>();
        objTypeLocal.add('KnowledgeArticleVersion');
        List<Schema.DescribeDataCategoryGroupResult> describeCategoryResult = Schema.describeDataCategoryGroups(objTypeLocal);
        System.assertEquals('LifeCycle', describeCategoryResult[0].getName());
    }

    /*  
    Scenario: We load the knowledbase page without a category parameter initially.  Then load the page with a category.
    Result: the chosenCategory should change from "All" default to a different value.
    */
    @isTest
    static void testKBPageLoadWithURL(){
        setupData();
        categoryGroup1();

        Id kaId = (Id)kavObj.get('KnowledgeArticleId');
        Id kavId = (Id)kavObj.get('Id');
        String catString='LifeCycle:Suppliers';
        // refCon is an essentially empty instance of the controller that allows access to the public variables that refer
        // to the names of the various url walmart_pkb_Controller that will be used to set up tests
        walmart_pkb_Controller refCon = new walmart_pkb_Controller();
        walmart_pkb_Controller pkbCon;
        PageReference p;

        // test first with no params and empty KA
        p = new PageReference('/');
        System.debug('****** TESTING WITH URL: ' +p.getUrl()+ ' *****');
        Test.setCurrentPage(p);
        pkbCon = new walmart_pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));
        System.assertNotEquals(pkbCon.publishStatus, null);

        // test with query of foo, language of english, and random category, and generate search RSS
        System.assertEquals('Marketplace', pkbCon.chosenCategory);
        p = new PageReference('/');
        p.getParameters().put(refCon.queryParam, 'price');
        p.getParameters().put(refCon.languageParam, lang);
        p.getParameters().put(refCon.categoryParam, catString);
        System.debug('****** TESTING WITH URL: ' +p.getUrl()+ ' *****');
        Test.setCurrentPage(p);
        pkbCon = new walmart_pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));
        System.assertEquals('Suppliers', pkbCon.chosenCategory);
        System.assertEquals('Suppliers', p.getCookies().get('ChosenCategory').getValue());
    }

    /*
    ** Scenario: We setup a cookie with "TestValue" and then load the knowledgebase page without a category parameter in the URL.
    ** Result: The chosenCategory should be set to Cookie value (TestValue.)
    */
    @isTest
    static void testKBPageLoadWithExistingCookie(){
        setupData();
        categoryGroup1();

        Id kaId = (Id)kavObj.get('KnowledgeArticleId');
        Id kavId = (Id)kavObj.get('Id');
        String catString='LifeCycle:Taxes';
        // refCon is an essentially empty instance of the controller that allows access to the public variables that refer
        // to the names of the various url walmart_pkb_Controller that will be used to set up tests
        walmart_pkb_Controller refCon = new walmart_pkb_Controller();
        walmart_pkb_Controller pkbCon;
        PageReference p;

        // test first with no params and empty KA
        p = new PageReference('/');
        System.debug('****** TESTING WITH URL: ' +p.getUrl()+ ' *****');
        Test.setCurrentPage(p);
        refCon.writeCookie('ChosenCategory', 'TestValue');
        pkbCon = new walmart_pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));
        System.assertNotEquals(pkbCon.publishStatus, null);
        System.assertEquals('TestValue', pkbCon.chosenCategory);
        System.assertEquals('TestValue', p.getCookies().get('ChosenCategory').getValue());
    }

    /*  
    Scenario: We load the knowledbase page with a category parameter initially which is a lower level category.  
    Result: The dropdown should change to the associated top tier category.
    */
    @isTest
    static void testKBPageURLLoadWithResultingDropdownUpdate(){
        setupData();
        categoryGroup1();

        Id kaId = (Id)kavObj.get('KnowledgeArticleId');
        Id kavId = (Id)kavObj.get('Id');
        String catString='LifeCycle:Pricing';
        // refCon is an essentially empty instance of the controller that allows access to the public variables that refer
        // to the names of the various url walmart_pkb_Controller that will be used to set up tests
        walmart_pkb_Controller refCon = new walmart_pkb_Controller();
        walmart_pkb_Controller pkbCon;
        PageReference p;
        p = new PageReference('/');
        p.getParameters().put(refCon.queryParam, 'price');
        p.getParameters().put(refCon.languageParam, lang);
        p.getParameters().put(refCon.categoryParam, catString);
        System.debug('****** TESTING WITH URL: ' +p.getUrl()+ ' *****');
        Test.setCurrentPage(p);
        pkbCon = new walmart_pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));
        // After dropdown change the chosenCategory and Cookie should be updated.
        System.assertEquals('Marketplace', pkbCon.chosenCategory);
        System.assertEquals('Marketplace', p.getCookies().get('ChosenCategory').getValue());
        System.assertEquals('LifeCycle:Marketplace', p.getCookies().get('FullyQualifiedCategory').getValue());
    }

    /*  
    Scenario: We load the knowledbase page with a category parameter initially.  Then use the dropdown to change the category.
    Result: the chosenCategory should change from previous to a different value.
    */
    @isTest
    static void testKBPageURLLoadWithOnChangeOfDropdown(){
        setupData();
        categoryGroup1();

        Id kaId = (Id)kavObj.get('KnowledgeArticleId');
        Id kavId = (Id)kavObj.get('Id');
        String catString='LifeCycle:Pricing';
        // refCon is an essentially empty instance of the controller that allows access to the public variables that refer
        // to the names of the various url walmart_pkb_Controller that will be used to set up tests
        walmart_pkb_Controller refCon = new walmart_pkb_Controller();
        walmart_pkb_Controller pkbCon;
        PageReference p;
        p = new PageReference('/');
        p.getParameters().put(refCon.queryParam, 'price');
        p.getParameters().put(refCon.languageParam, lang);
        p.getParameters().put(refCon.categoryParam, catString);
        System.debug('****** TESTING WITH URL: ' +p.getUrl()+ ' *****');
        Test.setCurrentPage(p);
        pkbCon = new walmart_pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));
        // After dropdown change the chosenCategory and Cookie should be updated.
        System.assertEquals('Marketplace', pkbCon.chosenCategory);
        System.assertEquals('Marketplace', p.getCookies().get('ChosenCategory').getValue());
        System.debug('****** TESTING WITH URL: ' +p.getUrl()+ ' *****');
        pkbCon.chosenCategory = 'Suppliers';
        p = pkbCon.setCategorySelectionViaDropdown();
        Test.setCurrentPage(p);
        pkbCon = new walmart_pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));
        System.assertEquals('Suppliers', pkbCon.chosenCategory);
        System.assertEquals('Suppliers', p.getCookies().get('ChosenCategory').getValue());
    }

    /*  
    Scenario: We load the knowledbase page with ONLY a category parameter initially.  Then use the dropdown to change the category.
    Result: the chosenCategory should change from previous to a different value.
    */
    @isTest
    static void testKBPageURLLoadWithOnChangeOfDropdown2(){
        setupData();
        categoryGroup1();

        Id kaId = (Id)kavObj.get('KnowledgeArticleId');
        Id kavId = (Id)kavObj.get('Id');
        String catString='LifeCycle:Pricing';
        // refCon is an essentially empty instance of the controller that allows access to the public variables that refer
        // to the names of the various url walmart_pkb_Controller that will be used to set up tests
        walmart_pkb_Controller refCon = new walmart_pkb_Controller();
        walmart_pkb_Controller pkbCon;
        PageReference p;
        p = new PageReference('/');
        p.getParameters().put(refCon.categoryParam, catString);
        System.debug('****** TESTING WITH URL: ' +p.getUrl()+ ' *****');
        Test.setCurrentPage(p);
        pkbCon = new walmart_pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));
        System.assertEquals('Marketplace', pkbCon.chosenCategory);
        System.assertEquals('Marketplace', p.getCookies().get('ChosenCategory').getValue());
        System.debug('****** TESTING WITH URL: ' +p.getUrl()+ ' *****');
        pkbCon.chosenCategory = 'Suppliers';
        p = pkbCon.setCategorySelectionViaDropdown();
        Test.setCurrentPage(p);
        pkbCon = new walmart_pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));
        System.assertEquals('Suppliers', pkbCon.chosenCategory);
        System.assertEquals('Suppliers', p.getCookies().get('ChosenCategory').getValue());
    }

    /*  
    Scenario: We load the knowledbase page with a category parameter initially.  Then simulate a change to the category selection via Browsing.
    Result: the chosenCategory should not change from "Marketplace".
    */
    @isTest
    static void testKBPageLoadWithURLChangeViaSidebarBrowsing(){
        setupData();
        categoryGroup1();

        Id kaId = (Id)kavObj.get('KnowledgeArticleId');
        Id kavId = (Id)kavObj.get('Id');
        String catString='LifeCycle:Taxes';
        // refCon is an essentially empty instance of the controller that allows access to the public variables that refer
        // to the names of the various url walmart_pkb_Controller that will be used to set up tests
        walmart_pkb_Controller refCon = new walmart_pkb_Controller();
        walmart_pkb_Controller pkbCon;
        PageReference p;
        // test first with no params and empty KA
        p = new PageReference('/');
        System.debug('****** TESTING WITH URL: ' +p.getUrl()+ ' *****');
        Test.setCurrentPage(p);
        pkbCon = new walmart_pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));
        System.assertNotEquals(pkbCon.publishStatus, null);
        // Default value initially set for chosenCategory.
        System.assertEquals('Marketplace', pkbCon.chosenCategory);
        System.assertEquals('Marketplace', p.getCookies().get('ChosenCategory').getValue());
        // After browsing change the chosenCategory and Cookie should be updated.
        System.debug('****** TESTING WITH URL: ' +p.getUrl()+ ' *****');
        // NOTE: Taxes is a sub category of "Integrating with Walmart".  So the value in chosenCategory should be "Integrating_with_Walmart".
        pkbCon.chosenCategory = 'Taxes';
        p = pkbCon.setCategorySelectionViaDropdown();
        Test.setCurrentPage(p);
        pkbCon = new walmart_pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));
        System.assertEquals('Marketplace', pkbCon.chosenCategory);
        System.assertEquals('Marketplace', p.getCookies().get('ChosenCategory').getValue());
    }

    /*  
    Scenario: We load the knowledbase page with a search string.  Then simulate a FAQ check for the context.
    Result: the FAQ associated with the Marketplace Category is returned.
    */
    @isTest
    static void testKBPageLoadWithFaqReload(){
        setupData();
        categoryGroup1();

        Id kaId = (Id)kavObj.get('KnowledgeArticleId');
        Id kavId = (Id)kavObj.get('Id');
        // refCon is an essentially empty instance of the controller that allows access to the public variables that refer
        // to the names of the various url walmart_pkb_Controller that will be used to set up tests
        walmart_pkb_Controller refCon = new walmart_pkb_Controller();
        walmart_pkb_Controller pkbCon;
        PageReference p;
        // test first with no params and empty KA
        p = new PageReference('/');
        p.getParameters().put(refCon.languageParam, lang);
        p.getParameters().put(refCon.queryParam, 'Tier');
        System.debug('****** TESTING WITH URL: ' +p.getUrl()+ ' *****');
        Test.setCurrentPage(p);
        pkbCon = new walmart_pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));
        System.assertNotEquals(pkbCon.publishStatus, null);
        // Default value initially set for chosenCategory.
        System.assertEquals('Marketplace', pkbCon.chosenCategory);
        System.assertEquals('Marketplace', p.getCookies().get('ChosenCategory').getValue());
        // After browsing change the chosenCategory and Cookie should be updated.
        System.debug('****** TESTING WITH URL: ' +p.getUrl()+ ' *****');
        // NOTE: Taxes is a sub category of "Integrating with Walmart".  So the value in chosenCategory should be "Integrating_with_Walmart".
        PageReference pRef = new PageReference(pkbCon.faqUrl);
        Test.setCurrentPage(pRef);
        //pkbCon = new walmart_pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));
        System.assertEquals(true, pRef.getUrl().contains('FAQ?'));
    }

    /*  
    Scenario: We load the knowledbase page with a search string.  Then simulate a FAQ check for the context.
    Result: the FAQ associated with the Marketplace Category is returned.
    */
    @isTest
    static void testKBPageLoadWithFaqReloadOfNoneDefaultContext(){
        setupData();
        categoryGroup1();

        Id kaId = (Id)kavObj.get('KnowledgeArticleId');
        Id kavId = (Id)kavObj.get('Id');
        String catString='LifeCycle:Suppliers';
        // refCon is an essentially empty instance of the controller that allows access to the public variables that refer
        // to the names of the various url walmart_pkb_Controller that will be used to set up tests
        walmart_pkb_Controller refCon = new walmart_pkb_Controller();
        walmart_pkb_Controller pkbCon;
        PageReference p;
        // test first with no params and empty KA
        p = new PageReference('/');
        p.getParameters().put(refCon.languageParam, lang);
        p.getParameters().put(refCon.queryParam, 'Tier');
        p.getParameters().put(refCon.categoryParam, catString);
        System.debug('****** TESTING WITH URL: ' +p.getUrl()+ ' *****');
        Test.setCurrentPage(p);
        pkbCon = new walmart_pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));
        System.assertNotEquals(pkbCon.publishStatus, null);
        // Default value initially set for chosenCategory.
        System.assertEquals('Suppliers', pkbCon.chosenCategory);
        System.assertEquals('Suppliers', p.getCookies().get('ChosenCategory').getValue());
        // After browsing change the chosenCategory and Cookie should be updated.
        System.debug('****** TESTING WITH URL: ' +p.getUrl()+ ' *****');
        // NOTE: Taxes is a sub category of "Integrating with Walmart".  So the value in chosenCategory should be "Integrating_with_Walmart".
        PageReference pRef = new PageReference(pkbCon.faqUrl);
        Test.setCurrentPage(pRef);
        //pkbCon = new walmart_pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));
        System.assertEquals(true, pRef.getUrl().contains('FAQ-Suppliers?'));
    }

    /*  
    Scenario: We load the knowledbase page with a search string.  Then simulate a ContactUs check for the context.
    Result: the ContactUs article associated with the default Marketplace Category is returned.
    */
    @isTest
    static void testKBPageLoadWithContactUsReload(){
        setupData();
        categoryGroup1();

        Id kaId = (Id)kavObj.get('KnowledgeArticleId');
        Id kavId = (Id)kavObj.get('Id');
        // refCon is an essentially empty instance of the controller that allows access to the public variables that refer
        // to the names of the various url walmart_pkb_Controller that will be used to set up tests
        walmart_pkb_Controller refCon = new walmart_pkb_Controller();
        walmart_pkb_Controller pkbCon;
        PageReference p;
        // test first with no params and empty KA
        p = new PageReference('/');
        p.getParameters().put(refCon.languageParam, lang);
        p.getParameters().put(refCon.queryParam, 'Tier');
        System.debug('****** TESTING WITH URL: ' +p.getUrl()+ ' *****');
        Test.setCurrentPage(p);
        pkbCon = new walmart_pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));
        System.assertNotEquals(pkbCon.publishStatus, null);
        // Default value initially set for chosenCategory.
        System.assertEquals('Marketplace', pkbCon.chosenCategory);
        System.assertEquals('Marketplace', p.getCookies().get('ChosenCategory').getValue());
        // After browsing change the chosenCategory and Cookie should be updated.
        System.debug('****** TESTING WITH URL: ' +p.getUrl()+ ' *****');
        // NOTE: Taxes is a sub category of "Integrating with Walmart".  So the value in chosenCategory should be "Integrating_with_Walmart".
        PageReference pRef = new PageReference(pkbCon.contactUsUrl);
        Test.setCurrentPage(pRef);
        //pkbCon = new walmart_pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));
        System.assertEquals(true, pRef.getUrl().contains('login'));
    }

    /*  
    Scenario: We load the knowledbase page using a URL Category Parameter.  Then simulate a ContactUs check for the context.
    Result: the ContactUs article associated with the parameter Category is returned.
    */
    @isTest
    static void testKBPageLoadWithContactUsReloadOfNoneDefaultContext(){
        setupData();
        categoryGroup1();

        Id kaId = (Id)kavObj.get('KnowledgeArticleId');
        Id kavId = (Id)kavObj.get('Id');
        String catString='LifeCycle:Suppliers';
        // refCon is an essentially empty instance of the controller that allows access to the public variables that refer
        // to the names of the various url walmart_pkb_Controller that will be used to set up tests
        walmart_pkb_Controller refCon = new walmart_pkb_Controller();
        walmart_pkb_Controller pkbCon;
        PageReference p;
        // test first with no params and empty KA
        p = new PageReference('/');
        p.getParameters().put(refCon.languageParam, lang);
        p.getParameters().put(refCon.queryParam, 'Tier');
        p.getParameters().put(refCon.categoryParam, catString);
        System.debug('****** TESTING WITH URL: ' +p.getUrl()+ ' *****');
        Test.setCurrentPage(p);
        pkbCon = new walmart_pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));
        System.assertNotEquals(pkbCon.publishStatus, null);
        // Default value initially set for chosenCategory.
        System.assertEquals('Suppliers', pkbCon.chosenCategory);
        System.assertEquals('Suppliers', p.getCookies().get('ChosenCategory').getValue());
        // After browsing change the chosenCategory and Cookie should be updated.
        System.debug('****** TESTING WITH URL: ' +p.getUrl()+ ' *****');
        // NOTE: Taxes is a sub category of "Integrating with Walmart".  So the value in chosenCategory should be "Integrating_with_Walmart".
        PageReference pRef = new PageReference(pkbCon.contactUsUrl);
        Test.setCurrentPage(pRef);
        //pkbCon = new walmart_pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));
        System.assertEquals(true, pRef.getUrl().contains('Contactus-Suppliers?'));
    }

    /*
    Scenario: We load the Knowledge Base page.  Then simulate a Knowledge Base Tab selection.
    Result: The Context should stay the same but the URL should have a kb=1 parameter definition.
    */
    @isTest
    static void testKBPageLoadWithKBTabLoad(){
        setupData();
        categoryGroup1();

        Id kaId = (Id)kavObj.get('KnowledgeArticleId');
        Id kavId = (Id)kavObj.get('Id');
        // refCon is an essentially empty instance of the controller that allows access to the public variables that refer
        // to the names of the various url walmart_pkb_Controller that will be used to set up tests
        walmart_pkb_Controller refCon = new walmart_pkb_Controller();
        walmart_pkb_Controller pkbCon;
        PageReference p;
        // test first with no params and empty KA
        p = new PageReference('/');
        System.debug('****** TESTING WITH URL: ' +p.getUrl()+ ' *****');
        Test.setCurrentPage(p);
        pkbCon = new walmart_pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));
        System.assertNotEquals(pkbCon.publishStatus, null);
        // Default value initially set for chosenCategory.
        System.assertEquals('Marketplace', pkbCon.chosenCategory);
        System.assertEquals('Marketplace', p.getCookies().get('ChosenCategory').getValue());
        System.assertNotEquals(true, p.getUrl().contains('kb=0'));
        // Now go to KB tab.
        p.getParameters().put(refCon.knowledgeBaseParam, pkbCon.valueOfSiteKbParam);
        p.getParameters().put(refCon.categoryParam, pkbCon.identifyTopTierCategory);
        Test.setCurrentPage(p);
        pkbCon = new walmart_pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));
        System.assertEquals(true, p.getUrl().contains('kb=0'));
    }

    /*
    Scenario: We load the Knowledge Base page URL using a Category param.  Then simulate a Knowledge Base Tab selection.
    Result: The Context should stay the same but the URL should have a kb=1 parameter definition.
    */
    @isTest
    static void testKBPageUrlLoadWithKBTabLoad(){
        setupData();
        categoryGroup1();

        Id kaId = (Id)kavObj.get('KnowledgeArticleId');
        Id kavId = (Id)kavObj.get('Id');
        String catString = 'LifeCycle:Suppliers';
        // refCon is an essentially empty instance of the controller that allows access to the public variables that refer
        // to the names of the various url walmart_pkb_Controller that will be used to set up tests
        walmart_pkb_Controller refCon = new walmart_pkb_Controller();
        walmart_pkb_Controller pkbCon;
        PageReference p;
        // test first with no params and empty KA
        p = new PageReference('/');
        p.getParameters().put(refCon.categoryParam, catString);
        System.debug('****** TESTING WITH URL: ' +p.getUrl()+ ' *****');
        Test.setCurrentPage(p);
        pkbCon = new walmart_pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));
        System.assertNotEquals(pkbCon.publishStatus, null);
        // Default value initially set for chosenCategory.
        System.assertEquals('Suppliers', pkbCon.chosenCategory);
        System.assertEquals('Suppliers', p.getCookies().get('ChosenCategory').getValue());
        System.assertEquals(false, p.getUrl().contains('kb=1'));
        // Now go to KB tab.
        p.getParameters().put(refCon.knowledgeBaseParam, '1');
        p.getParameters().put(refCon.categoryParam, pkbCon.identifyTopTierCategory);
        Test.setCurrentPage(p);
        pkbCon = new walmart_pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));
        System.assertEquals(true, p.getUrl().contains('kb=1'));
    }

    /*
    Scenario: We load the Knowledge Base page URL using a KB param = 1 (going to kb tab directly.)  Then simulate a dropdown selection.
    Result: The Context should change to Marketplace, and the URL should have a kb=1 parameter definition.
    */
    @isTest
    static void testKBPageURLLoadWithOnChangeOfDropdown3(){
        setupData();
        categoryGroup1();

        Id kaId = (Id)kavObj.get('KnowledgeArticleId');
        Id kavId = (Id)kavObj.get('Id');
        String catString = 'LifeCycle:Suppliers';
        // refCon is an essentially empty instance of the controller that allows access to the public variables that refer
        // to the names of the various url walmart_pkb_Controller that will be used to set up tests
        walmart_pkb_Controller refCon = new walmart_pkb_Controller();
        walmart_pkb_Controller pkbCon;
        PageReference p;
        p = new PageReference('/');
        p.getParameters().put(refCon.categoryParam, catString);
        p.getParameters().put(refCon.knowledgeBaseParam, '1');
        Test.setCurrentPage(p);
        pkbCon = new walmart_pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));
        System.assertEquals('Suppliers', pkbCon.chosenCategory);
        System.assertEquals(true, p.getUrl().contains('kb=1'));        
        pkbCon.chosenCategory = 'Marketplace';
        p = pkbCon.setCategorySelectionViaDropdown();
        Test.setCurrentPage(p);
        pkbCon = new walmart_pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));
        System.assertEquals('Marketplace', pkbCon.chosenCategory);
        System.assertEquals('Marketplace', p.getCookies().get('ChosenCategory').getValue());
        System.assertEquals(true, p.getUrl().contains('kb=1'));        
    }

    /*
    Scenario: We load the Knowledge Base page URL using a KB param = 0 (similar to loading the home page.)  Then simulate a dropdown selection.
    Result: The Context should change to Marketplace, and the URL should have a kb=1 parameter definition.
    */
    @isTest
    static void testKBPageURLLoadWithOnChangeOfDropdown4(){
        setupData();
        categoryGroup1();

        Id kaId = (Id)kavObj.get('KnowledgeArticleId');
        Id kavId = (Id)kavObj.get('Id');
        String catString = 'LifeCycle:Suppliers';
        // refCon is an essentially empty instance of the controller that allows access to the public variables that refer
        // to the names of the various url walmart_pkb_Controller that will be used to set up tests
        walmart_pkb_Controller refCon = new walmart_pkb_Controller();
        walmart_pkb_Controller pkbCon;
        PageReference p;
        p = new PageReference('/');
        p.getParameters().put(refCon.categoryParam, catString);
        p.getParameters().put(refCon.knowledgeBaseParam, '0');
        Test.setCurrentPage(p);
        pkbCon = new walmart_pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));
        System.assertEquals('Suppliers', pkbCon.chosenCategory);
        System.assertEquals(true, p.getUrl().contains('kb=0'));        
        pkbCon.chosenCategory = 'Marketplace';
        p = pkbCon.setCategorySelectionViaDropdown();
        Test.setCurrentPage(p);
        pkbCon = new walmart_pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));
        System.assertEquals('Marketplace', pkbCon.chosenCategory);
        System.assertEquals('Marketplace', p.getCookies().get('ChosenCategory').getValue());
        System.assertEquals(true, p.getUrl().contains('kb=0'));        
    }

    /*
    Scenario: We load the Knowledge Base page URL using a q param (similar to loading a search directly.)  Then simulate a dropdown selection.
    Result: The Context should change to Suppliers, and the URL should not have a q parameter definition.
    */
    @isTest
    static void testKBPageURLLoadWithOnChangeOfDropdown5(){
        setupData();
        categoryGroup1();

        Id kaId = (Id)kavObj.get('KnowledgeArticleId');
        Id kavId = (Id)kavObj.get('Id');
        String q = 'Tier';
        // refCon is an essentially empty instance of the controller that allows access to the public variables that refer
        // to the names of the various url walmart_pkb_Controller that will be used to set up tests
        walmart_pkb_Controller refCon = new walmart_pkb_Controller();
        walmart_pkb_Controller pkbCon;
        PageReference p;
        p = new PageReference('/');
        p.getParameters().put(refCon.queryParam, q);
        Test.setCurrentPage(p);
        pkbCon = new walmart_pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));
        System.assertEquals('Marketplace', pkbCon.chosenCategory);
        System.assertEquals(true, p.getUrl().contains('q=Tier'));
        pkbCon.chosenCategory = 'Suppliers';
        p = pkbCon.setCategorySelectionViaDropdown();
        Test.setCurrentPage(p);
        pkbCon = new walmart_pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));
        System.assertEquals('Suppliers', pkbCon.chosenCategory);
        System.assertEquals('Suppliers', p.getCookies().get('ChosenCategory').getValue());
        System.assertEquals(false, p.getUrl().contains('q=Tier'));        
    }

    /*
    Scenario: Load a KB page with a Marketplace category param.
    Result: the controller should respond in the negative for loading the Featured Articles section of the home page.
    */
    @isTest
    static void testKBPageLoadWithURLAndHomeFeaturedArticleValidationNegative(){
        setupData();
        categoryGroup1();
        Id kaId = (Id)kavObj.get('KnowledgeArticleId');
        Id kavId = (Id)kavObj.get('Id');
        String catString = 'LifeCycle:Suppliers';
        // refCon is an essentially empty instance of the controller that allows access to the public variables that refer
        // to the names of the various url walmart_pkb_Controller that will be used to set up tests
        walmart_pkb_Controller refCon = new walmart_pkb_Controller();
        walmart_pkb_Controller pkbCon;
        PageReference p;
        p = new PageReference('/');
        p.getParameters().put(refCon.categoryParam, catString);
        Test.setCurrentPage(p);
        pkbCon = new walmart_pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));
        System.assertEquals('Suppliers', pkbCon.chosenCategory);
        System.assertEquals(false, pkbCon.displayHomeFeaturedArticle);
    }

    /*
    Scenario: Load a KB page with a Marketplace category param.
    Result: the controller should respond in the affermative for loading the Featured Articles section of the home page.
    */
    @isTest
    static void testKBPageLoadWithURLAndHomeFeaturedArticleValidationAffirmative(){
        setupData();
        categoryGroup1();
        Id kaId = (Id)kavObj.get('KnowledgeArticleId');
        Id kavId = (Id)kavObj.get('Id');

        // refCon is an essentially empty instance of the controller that allows access to the public variables that refer
        // to the names of the various url walmart_pkb_Controller that will be used to set up tests
        walmart_pkb_Controller refCon = new walmart_pkb_Controller();
        walmart_pkb_Controller pkbCon;
        PageReference p;
        p = new PageReference('/');
        Test.setCurrentPage(p);
        pkbCon = new walmart_pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));
        System.assertEquals('Marketplace', pkbCon.chosenCategory);
        System.assertEquals(true, pkbCon.displayHomeFeaturedArticle);
    }

    /*
    Scenario: Create an Article; Load the KB by URL to the Article; Then change the context.
    Result: The KB Search Results page should load and the article list result should be 1.
    */
    @isTest
    static void testArticleListResult(){
        setupData();
        categoryGroup1();
        Id kaId = (Id)kavObj.get('KnowledgeArticleId');
        Id kavId = (Id)kavObj.get('Id');
        String catString = 'LifeCycle:Marketplace';

        // refCon is an essentially empty instance of the controller that allows access to the public variables that refer
        // to the names of the various url walmart_pkb_Controller that will be used to set up tests
        walmart_pkb_Controller refCon = new walmart_pkb_Controller();
        walmart_pkb_Controller pkbCon;
        PageReference p;
        p = new PageReference('/Walmart_article_template');
        p.getParameters().put(refCon.categoryParam, catString);
        p.getParameters().put('id', kaId);
        p.getParameters().put(refCon.knowledgeBaseParam, '0');
        p.getParameters().put(refCon.publishStatus, 'o');
        Test.setCurrentPage(p);
        pkbCon = new walmart_pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));
        System.assertEquals('Marketplace', pkbCon.chosenCategory);
        System.assertEquals(true, p.getUrl().contains('id='));
        //Change Context.
        pkbCon.chosenCategory = 'Suppliers';
        p = pkbCon.setCategorySelectionViaDropdown();
        Test.setCurrentPage(p);
        pkbCon = new walmart_pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));
        WalmartPkbSearchController searchCon = new WalmartPkbSearchController();
        System.assertEquals('Suppliers', pkbCon.chosenCategory);
        System.assertEquals('Suppliers', p.getCookies().get('ChosenCategory').getValue());
        System.assertEquals(false, p.getUrl().contains('id='));
        //System.assertEquals(1, searchCon.getResultSize());
    }
    /* ******************** End of dropdown feature tests ******************** */
}
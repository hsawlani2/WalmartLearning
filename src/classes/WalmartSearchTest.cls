@isTest(SeeAllData=true)
private class WalmartSearchTest {
    
    static String siteName = 'PKB_TEST_' + String.valueOf(Crypto.getRandomInteger());    // use this to set the siteName prop of the pkb_Controller class
    static String publishStatus = 'draft'; // use this to set the pub status prop of the pkb_Controller
    static String objType;
    static SObject kavObj;
    static String lang = pkb_SettingsController.DEFAULT_LANGUAGE;//'en_US';
    static PKB_Featured__c featured;
    static PKB_Featured__c keyword;
    static PKB__c pkb;

	private static testMethod void testSearch() {
	    
	    setupData();
        setupSettingsData();
        WalmartPkbSearchController refCon = new WalmartPkbSearchController();
        WalmartPkbSearchController pkbCon;
        PageReference p;
        
        // Test with public knowledge base param
        p = new PageReference('/');
        p.getParameters().put(refCon.knowledgeBaseParam, refCon.affirmativeValue);
        Test.setCurrentPage(p);
        pkbCon = new WalmartPkbSearchController();
        if (pkbCon.displayKnowledgeBase) {
            pkbCon.performSearch();
        }
        else {
            System.assert(false, 'Failed searching inside kb');
        }
        System.debug('LEO: overall results returned: ' + pkbCon.getResultSize());
        
        /*
        // Test with category browsing
        p = new PageReference('/');
        p.getParameters().put(refCon.categoryParam, 'foo_t:bar');
        Test.setCurrentPage(p);
        pkbCon = new WalmartPkbSearchController();
        if (pkbCon.browsingCategories) {
            pkbCon.performSearch();
        }
        else {
            System.assert(false, 'Failed browsing categories');
        }
        System.debug('LEO: overall results returned: ' + pkbCon.getResultSize());
        */
        
        if (pkbCon.browsingCategories) {
            System.debug(pkbCon.selectedCategoryLabel);
        }
        
        pkbCon.sortByLastUpdated();
        pkbCon.performSearch();
        
        pkbCon.sortByTitle();
        pkbCon.performSearch();
        
        // Test with search query
        p = new PageReference('/');
        p.getParameters().put(refCon.queryParam, 'Foo');
        Test.setCurrentPage(p);
        pkbCon = new WalmartPkbSearchController();
        pkbCon.performSearch();
        System.debug('LEO: string search results returned: ' + pkbCon.getResultSize());
        
        pkbCon.getHasNext();
        pkbCon.getHasPrevious();
	}
	
	static void setupData() {
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
  
    static void setupSettingsData() {
    // create custom settings collection based on siteName
        pkb = new PKB__c();
        pkb.Name = siteName;
        pkb.Category_Group_1__c = '1';
        pkb.Category_Group_2__c = '2';
        pkb.Category_Group_3__c = '3';
        pkb.Root_Category_1__c = '1';
        pkb.Root_Category_2__c = '2';
        pkb.Root_Category_3__c = '3';

        pkb.Create_Contact_and_Account__c = false;
        pkb.Display_Article_Summary__c = true;
        pkb.Multi_Language_Enabled__c = false;
        pkb.Popular_Articles_Size__c = 2;
        pkb.Related_Articles_Size__c = 2;
        pkb.Results_Page_Size__c = 2;
        insert pkb;
    }

    /* ******************** Tests related to the dropdown feature ******************** */
    // create custom settings collection based on siteName
    static void categoryGroup1() {
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

    /*
    Scenario: Load page with category url and a preconfigured cookie.  Then do a search.
    Result: Should get a pickedCategoryLabel value of 'Suppliers'.
    */
    @isTest
    static void testKBPageLoadWithCategoryLink(){
        setupData();
        categoryGroup1();

        Id kaId = (Id)kavObj.get('KnowledgeArticleId');
        Id kavId = (Id)kavObj.get('Id');
        String catString='LifeCycle:Suppliers';
        // refCon is an essentially empty instance of the controller that allows access to the public variables that refer
        // to the names of the various url walmart_pkb_Controller that will be used to set up tests
        Test.startTest();
        walmart_pkb_Controller refCon = new walmart_pkb_Controller();
        walmart_pkb_Controller pkbCon;
        WalmartPkbSearchController searchCon;
        PageReference p;
        PageReference searchResultPage = new PageReference('/');
        p = new PageReference('/');
        p.getParameters().put(refCon.queryParam, 'price');
        p.getParameters().put(refCon.languageParam, lang);
        p.getParameters().put(refCon.categoryParam, catString);

        // Test with search query
        Test.setCurrentPage(p);
        refCon.writeCookie('ChosenCategory', 'Marketplace');
        searchCon = new WalmartPkbSearchController();
        pkbCon = new walmart_pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));
        Test.stopTest();
        System.assertEquals('Suppliers', pkbCon.chosenCategory);
        System.assertEquals('Suppliers', p.getCookies().get('ChosenCategory').getValue());
        System.assertEquals('Suppliers', searchCon.pickedCategoryLabel);
    }

    /*
    Scenario: Load page without category url and a preconfigured cookie.  Then do a search.
    Result: Should get a pickedCategoryLabel value of 'Marketplace'.
    */
    @isTest
    static void testKBPageLoadWithoutCategoryLink(){
        setupData();
        categoryGroup1();

        Id kaId = (Id)kavObj.get('KnowledgeArticleId');
        Id kavId = (Id)kavObj.get('Id');
        // refCon is an essentially empty instance of the controller that allows access to the public variables that refer
        // to the names of the various url walmart_pkb_Controller that will be used to set up tests
        Test.startTest();
        walmart_pkb_Controller refCon = new walmart_pkb_Controller();
        walmart_pkb_Controller pkbCon;
        WalmartPkbSearchController searchCon;
        PageReference p;
        PageReference searchResultPage = new PageReference('/');
        p = new PageReference('/');
        p.getParameters().put(refCon.queryParam, 'price');
        p.getParameters().put(refCon.languageParam, lang);

        // Test with search query
        Test.setCurrentPage(p);
        refCon.writeCookie('ChosenCategory', 'Marketplace');
        refCon.writeCookie('FullyQualifiedCategory', 'LifeCycle:Marketplace');
        searchCon = new WalmartPkbSearchController();
        pkbCon = new walmart_pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));
        Test.stopTest();
        System.assertEquals('Marketplace', pkbCon.chosenCategory);
        System.assertEquals('Marketplace', p.getCookies().get('ChosenCategory').getValue());
        System.assertEquals('Marketplace', searchCon.pickedCategoryLabel);
    }

    /*
    Scenario: Load page with category url and a preconfigured cookie.  Then do a search. Then change the dropdown.
    Result: search string should be cleared.
    */
    @isTest
    static void testKBPageLoadWithSearchReload(){
        setupData();
        categoryGroup1();

        Id kaId = (Id)kavObj.get('KnowledgeArticleId');
        Id kavId = (Id)kavObj.get('Id');
        // refCon is an essentially empty instance of the controller that allows access to the public variables that refer
        // to the names of the various url walmart_pkb_Controller that will be used to set up tests
        Test.startTest();
        walmart_pkb_Controller refCon = new walmart_pkb_Controller();
        walmart_pkb_Controller pkbCon;
        WalmartPkbSearchController searchCon;
        PageReference p;
        PageReference searchResultPage = new PageReference('/');
        p = new PageReference('/');
        p.getParameters().put(refCon.queryParam, 'price');
        p.getParameters().put(refCon.languageParam, lang);

        // Test with search query
        Test.setCurrentPage(p);
        refCon.writeCookie('ChosenCategory', 'Marketplace');
        refCon.writeCookie('FullyQualifiedCategory', 'LifeCycle:Marketplace');
        searchCon = new WalmartPkbSearchController();
        pkbCon = new walmart_pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));
        System.assertEquals('Marketplace', pkbCon.chosenCategory);
        System.assertEquals('Marketplace', p.getCookies().get('ChosenCategory').getValue());
        System.assertEquals('Marketplace', searchCon.pickedCategoryLabel);
        System.assertEquals('price', p.getParameters().get('q'));
        pkbCon.chosenCategory = 'Suppliers';
        p = pkbCon.setCategorySelectionViaDropdown();
        Test.setCurrentPage(p);
        pkbCon = new walmart_pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));
        Test.stopTest();
        System.assertEquals('Suppliers', pkbCon.chosenCategory);
        System.assertEquals('Suppliers', p.getCookies().get('ChosenCategory').getValue());
        System.assertEquals(null, p.getParameters().get('q'));
    }

    /*
    Scenario: Load page without category url or cookie.  Then do a search. Then change the dropdown.
    Result: search string should be cleared.
    */
    @isTest
    static void testKBPageLoadWithSearchReloadAndNoCookie(){
        setupData();
        categoryGroup1();

        Id kaId = (Id)kavObj.get('KnowledgeArticleId');
        Id kavId = (Id)kavObj.get('Id');
        // refCon is an essentially empty instance of the controller that allows access to the public variables that refer
        // to the names of the various url walmart_pkb_Controller that will be used to set up tests
        Test.startTest();
        walmart_pkb_Controller refCon = new walmart_pkb_Controller();
        walmart_pkb_Controller pkbCon;
        WalmartPkbSearchController searchCon;
        PageReference p;
        PageReference searchResultPage = new PageReference('/');
        p = new PageReference('/');
        p.getParameters().put(refCon.queryParam, 'price');
        p.getParameters().put(refCon.languageParam, lang);

        // Test with search query
        Test.setCurrentPage(p);
        searchCon = new WalmartPkbSearchController();
        pkbCon = new walmart_pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));
        System.assertEquals('Marketplace', pkbCon.chosenCategory);
        System.assertEquals('Marketplace', p.getCookies().get('ChosenCategory').getValue());
        System.assertEquals('price', p.getParameters().get('q'));
        pkbCon.chosenCategory = 'Suppliers';
        p = pkbCon.setCategorySelectionViaDropdown();
        Test.setCurrentPage(p);
        pkbCon = new walmart_pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));
        Test.stopTest();
        System.assertEquals('Suppliers', pkbCon.chosenCategory);
        System.assertEquals('Suppliers', p.getCookies().get('ChosenCategory').getValue());
        System.assertEquals(null, p.getParameters().get('q'));
    }

    @isTest
    static void testCategoriesInOrg(){
        List <String> objTypeLocal = new List<String>();
        objTypeLocal.add('KnowledgeArticleVersion');
        List<Schema.DescribeDataCategoryGroupResult> describeCategoryResult = Schema.describeDataCategoryGroups(objTypeLocal);
        System.assertEquals('LifeCycle', describeCategoryResult[0].getName());
    }

    /* ******************** End of tests related to the dropdown feature ******************** */
}
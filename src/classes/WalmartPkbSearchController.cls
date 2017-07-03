public without sharing class WalmartPkbSearchController {
    
    private final static String QUERY_PARAM = 'q';
    private final static String CATEGORY_PARAM = 'c';
    private final static String KNOWLEDGEBASE_PARAM = 'kb';
    private final static String AFFIRMATIVE = '1';
    private final static String KAV_EXTENSION = '__kav';
    private final static String DEFAULT_LANG = 'en_US';
    private final static String DEFAULT_STATUS = 'online';
    
    public String queryParam            { get { return QUERY_PARAM; } }
    public String categoryParam         { get { return CATEGORY_PARAM; } }
    public String knowledgeBaseParam    { get { return KNOWLEDGEBASE_PARAM; } }
    public String affirmativeValue      { get { return AFFIRMATIVE; } }
    public String kavExtension          { get { return KAV_EXTENSION; } }
    public String defaultLang           { get { return DEFAULT_LANG; } }
    
    private ApexPages.StandardSetController setController;
    public String selectedCategory     { get; set; }
    public String urlSearchQuery       { get; set; }
    
    public Boolean hasLoadedInitially   { get; set; }
    public WalmartPkbSearchController myController { get { return this; } }
    transient private Map<String, Cookie> siteCookies = new Map<String, Cookie>();
    public string Customertype{get;set;}
    
    /********** method for getting the user IP Address and putting it into the organization cache corresponding to the landing URL *****/
    public pagereference logintoknowledgebase(){
        
        /************** Getting the IP Address of the User **********/
         string ReturnValue = '';  
        // True-Client-IP has the value when the request is coming via the caching integration.
        ReturnValue = ApexPages.currentPage().getHeaders().get('True-Client-IP');
        // X-Salesforce-SIP has the value when no caching integration or via secure URL.
        if (ReturnValue == '' || ReturnValue == null) {
         ReturnValue = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
        } // get IP address when no caching (sandbox, dev, secure urls)
        if (ReturnValue == '' || ReturnValue == null) {
         ReturnValue = ApexPages.currentPage().getHeaders().get('X-Forwarded-For');
        } // get IP address from standard header if proxy in use
        system.debug('User IP Address ' + ReturnValue);
        //appending BC in the beginning and replacing '.' with 'A' as the key can only be alphanumeric and IP address with have periods in it.
        ReturnValue = 'BC' + ReturnValue.replace('.','A'); 
        system.debug('key setting in cache ' + ReturnValue);
        
        /******** get Or Cache Details and then putting the IP address and the landing url in the cache. Key : IP Address, Value : Landing Url ***********/
        Cache.OrgPartition orgPart = Cache.Org.getPartition('local.Default1'); // getting the default prtition cache
        system.debug('Cache ' + orgPart);
        system.debug('IP Address ' + ReturnValue);
        system.debug('Get value from cache ' + orgPart.getKeys()); // getting the keys already there in the cache
        String finalcategory = selectedCategory.split(':')[0] + ':' + chosenCategoryLabel;
        orgPart.put(ReturnValue, '/apex/walmart_pkb_Home?c='+finalcategory); // placing the landing URL, which should be the home page of the knowledge Base.
        
        /******** Getting return url from label **********/
        system.debug('Selected Category' + chosenCategoryLabel);
        String returnurl = '';
        String categoryselected = chosenCategoryLabel + '__c';
        Account_Setting_Metadata__mdt asMdt = [SELECT Matching_Login_URL__c FROM Account_Setting_Metadata__mdt  where Matching_Configured_Data_Category__c = :categoryselected LIMIT 1];
        if(asMdt != null)
        {
            returnurl = asMdt.Matching_Login_URL__c;
        }
        else
            returnurl = null;
        return new pagereference(returnurl);
    }
    
    public WalmartPkbSearchController() {
        //User Agent Value
        system.debug('User Agent Value ' + ApexPages.currentPage().getHeaders().get('USER-AGENT'));
        setController = new ApexPages.StandardSetController(new List<KnowledgeArticleVersion>());
        hasLoadedInitially = false;
        
        // Process get parameters
        String q = ApexPages.currentPage().getParameters().get(QUERY_PARAM);
        String c = ApexPages.currentPage().getParameters().get(CATEGORY_PARAM);
        //if (!isBlank(c)) selectedCategory = String.escapeSingleQuotes(c);
        /* ********************* Check for a chosenCategory Cookie to set the selectedCategory - 20161116 ********************* */
        siteCookies = ApexPages.currentPage().getCookies();
        Cookie selectedCategoryCookie = siteCookies.get('FullyQualifiedCategory');
        Cookie chosenCategoryCookie = siteCookies.get('ChosenCategory');
        Cookie SellerCookie = siteCookies.get('SellerUser');
        system.debug('DDDDDDDDDDDDD' + siteCookies);
        if(chosenCategoryCookie != null){
          chosenCategoryLabel = chosenCategoryCookie.getValue();          
        }
        if(!isBlank(c)){
          selectedCategory = String.escapeSingleQuotes(c);
            if(selectedCategory.contains('Marketplace'))
                Customertype = 'Seller';
            else if(selectedCategory.contains('Suppliers'))
                Customertype = 'Supplier';
            else
                Customertype = null;
              
        } else if (selectedCategoryCookie != null){
          // We need to build the selectedCategory with the categoryGroup1 info + ":"
          selectedCategory = selectedCategoryCookie.getValue();
        }
        /* ********************* End of check for cookie ********************* */
        if (!isBlank(q) && q.length() > 2) {
            urlSearchQuery = String.escapeSingleQuotes(q);
        }
    }
    
    public PageReference performSearch() {
        
        List<KnowledgeArticleVersion> articleList;
        
        if (!isBlank(urlSearchQuery)) {
            articleList = performSOSL();
        }
        else {
            articleList = performSOQL();
        }
        
        setController = new ApexPages.StandardSetController(articleList);
        setController.setPageSize(10);
        
        system.debug('\n\n[DEBUG-PKB CONTROLLER] Query result: '+ setController.getResultSize() + ' records');
        
        hasLoadedInitially = true;
        
        return null;
    }
    
    // Use this for browsing articles through the knowledge base or categories
    private List<KnowledgeArticleVersion> performSOQL() {
        String query = 'SELECT ArticleType,FirstPublishedDate,Summary,Title,UrlName FROM KnowledgeArticleVersion ';
        
        // add default where clauses
        query += ' where PublishStatus = \'' + DEFAULT_STATUS + '\' and Language = \'' + DEFAULT_LANG + '\' ';
        
        // add categories, if any
        query += buildCategorySoql();
        
        // add ordering
        if (currentSortKeyword.equals(SORT_CODE_TITLE)) {
            query += ' ORDER BY ' + SORT_CODE_TITLE + ' ASC ';
        }
        else if (currentSortKeyword.equals(SORT_CODE_LAST_UPDATED)) {
            query += ' ORDER BY ' + SORT_CODE_LAST_UPDATED + ' DESC ';
        }
        
        query += ' UPDATE TRACKING';
        
        return Database.query(query);
    }
    
    // Use this for searching articles using search terms
    private List<KnowledgeArticleVersion> performSOSL() {
        String q = '';
        q += 'FIND \'' + urlSearchQuery + '*\' IN ALL FIELDS RETURNING KnowledgeArticleVersion(' +join(kavFields, ',')+ ' where PublishStatus = :DEFAULT_STATUS and Language = :DEFAULT_LANG) ';

        // add categories, if any
        q += buildCategorySoql();
        
        q += ' UPDATE TRACKING';

        List<List<SObject>> searchList = Search.query(q);
        return (List<KnowledgeArticleVersion>)searchList[0];
    
    }
    
    public List<KnowledgeArticleVersion> getResults() {
        return setController.getRecords();
    }
    
    public Integer getResultSize() {
        return setController.getResultSize();
    }
    
    /* ***** KNOWLEDGE BASE SORTING ******* */
  
      // Sort codes
      private final static String SORT_CODE_MOST_VIEWED = 'mostViewed';
      private final static String SORT_CODE_LAST_UPDATED = 'LastPublishedDate';
      private final static String SORT_CODE_TITLE ='Title';
      
      private final static String SORT_LABEL_MOST_VIEWED = 'Popular';
      private final static String SORT_LABEL_LAST_UPDATED = 'Recently Updated';
      private final static String SORT_LABEL_TITLE = 'Title';
      
      public void sortByMostViewed() {
          resetSorting(SORT_CODE_MOST_VIEWED);
      }
      
      public void sortByLastUpdated() {
          resetSorting(SORT_CODE_LAST_UPDATED);
      }
      
      public void sortByTitle() {
          resetSorting(SORT_CODE_TITLE);
      }
      
      private void resetSorting(String newCode) {
          this.currentSortKeyword = newCode;
          system.debug('\n\n[DEBUG-PKB CONTROLLER] Sort update: '+this.currentSortKeyword + ' label: ' + this.sortingLabel);
          performSearch();
      }
      
      public String currentSortKeyword {
          set;
          get {
              if (currentSortKeyword == null) {
                  currentSortKeyword = SORT_CODE_TITLE;
              }
              return currentSortKeyword;
          }
      }
      
      public String sortingLabel {
          get {
              if (this.currentSortKeyword.equals(SORT_CODE_MOST_VIEWED)) {
                  return SORT_LABEL_MOST_VIEWED;
              }
              else if (this.currentSortKeyword.equals(SORT_CODE_LAST_UPDATED)) {
                  return SORT_LABEL_LAST_UPDATED;
              }
              return SORT_LABEL_TITLE;
          }
      }
      
    public Boolean getHasNext() {
        return setController.getHasNext();
    }

    public void next() {
        if (setController.getHasNext()) {
            setController.next();
        }
    }

    public Boolean getHasPrevious() {
        return setController.getHasPrevious();
    }

    public void previous() {
        if (setController.getHasPrevious()) {
            setController.previous();
        }
    }
    
    public static Set<String> kavFields {
    get {
        if (kavFields == null) {
            kavFields = new Set<String>{
          'Id'
          ,'Title'
          ,'Summary'
          ,'UrlName'
          ,'ArticleNumber'
          ,'LastModifiedDate'
          ,'FirstPublishedDate'
          ,'LastPublishedDate'
          ,'Language'
          ,'PublishStatus'
          ,'ArticleType '
            };
        }
      return kavFields;
    }
    private set;
  }
    
    /** PKB OOB methods **/
    public Boolean displayKnowledgeBase { get { return (ApexPages.currentPage().getParameters().get(KNOWLEDGEBASE_PARAM) == AFFIRMATIVE); } }
    public Boolean displaySearchResultHeader { get { return (ApexPages.currentPage().getParameters().get(KNOWLEDGEBASE_PARAM) == '-1'); } }
    public Boolean browsingCategories { get { return (!isBlank(selectedCategory)); } }
    
    public String currentSiteUrl {
        set;
        get {
            if (currentSiteUrl == null) {
                currentSiteUrl = Site.getBaseUrl()+'/';//Site.getCurrentSiteUrl();
            }
            return currentSiteUrl;
        }
    }
    
    // 11/30/2016 - Should not include the Category Group information in the returned string, so we'll create a new property. 
    public String selectedCategoryLabel {
        get {
            return selectedCategory.replace(',', ', ').replace(':', ': ').replace('_', ' ');
        }
    }

    public String pickedCategoryLabel { 
      get {
        List<String> selectedCategoryTokens = selectedCategory.split(',');
        Map<String, String> tempMap = new Map<String, String>();
        for (String s : selectedCategoryTokens){
          tempMap.put(s, s.trim().substringAfter(':'));
        }
        if (tempMap.size() > 1) {
          pickedCategoryLabel = join(tempMap.values(), ', ');
        } else {
          if(tempMap.values()[0] != ''){
            pickedCategoryLabel = tempMap.values()[0];
          } else {
            pickedCategoryLabel = chosenCategoryLabel;
          }
        }
        return pickedCategoryLabel;
      }
      set; 
    }

    private String chosenCategoryLabel { get; set; }
    
    public String buildCategorySoql() {
        if (isBlank(selectedCategory)) return '';
        
        List<String> selectedCategorySOSL = new List<String>();
        List<String> selectedCategoryTokens = selectedCategory.split(',');
        List<String> temp;
        for (String s : selectedCategoryTokens) {
            temp = s.trim().split(':');
            temp[0] = temp[0] + '__c';
            temp[1] = temp[1] + '__c';
            selectedCategorySOSL.add(join(temp, ' BELOW '));//AT
        }
        return ' WITH DATA CATEGORY ' + (join(selectedCategorySOSL, ' AND '));
    }
    
    public static Boolean isBlank(String s) {
        return ( s == null || s == '');
    }

    // joins elements in the passed list of strings by the passed string c
    // c can be a single character or a longer string -- useful for joinging segments of a dynamic sosl or soql query
    public static String join(List<String> strings, String c) {
        if (strings == null || strings.isEmpty()) return null;

        String sep = (isBlank(c) ? ',' : c);
        Integer i, size;
        String s = strings[0];

        size = strings.size();
        for (i = 1; i < size; i++) {
            s += (sep + strings[i]);
        }
        return s;
    }

    // version of join method that takes a set of strings
    public static String join(Set<String> strings, String c) {
        return join(new List<String>(strings), c);
    }
    
    /** PKB OOB methods end **/
}
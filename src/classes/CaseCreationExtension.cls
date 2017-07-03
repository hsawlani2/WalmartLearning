/**
 * Extension class to support New Onboarding/Operations case creation.
 * 
 * This class is in addition to #CaseExtension class supporting the new case creation
 * form.
 * 
 * @see CaseExtension
 * @see CaseCRUDHelper
 * @see EncryptionUtility
 * 
 * @author      Cloud Sherpas
 * @createddate 26-Feb-2016
 */ 
public class CaseCreationExtension {
    
    public Case caseRecord;
    public Id caseRecordTypeId;
    public Id deflectionRecordId;
    public Id contactId;
    public Id accountId;
    private Account acctRecord;
    public String caseRecordTypeName;
    public Boolean isCPCaseForSeller;
    public String cspSelectionType;
    // public String accountName { get; set; }
    
    public String searchQuery { get; set; }
    public String deflectedArticleLink { get; set; }
    public ApexPages.StandardSetController articlesController;

    public Boolean isFollowUpCase;
    public String authToken;
    public String communityName;
    
    private Map<String , Account_Custom_Settings__c> acs2;
    private Map<String, Account_Setting_Metadata__mdt> asm = new Map<String, Account_Setting_Metadata__mdt>();
    private Map<ID, RecordType> rtMap;
    
    public string sMessageForDisplay{get;set;}      
        public string sRedirectUrl{get;set;}        
        public boolean bRedirectOnOk{get;set;}      
        public boolean bShowCancel{get;set;}        
        public boolean bShowMessage{get;set;}       
        map<string,CaseCustomSettings__c> mapCaseCustomSettings;

    // default contructor
    public CaseCreationExtension(ApexPages.StandardController stdController) {
        
        articlesController = new ApexPages.StandardSetController(new List<KnowledgeArticleVersion>());
        acs2 = Account_Custom_Settings__c.getAll();
        
        List<Account_Setting_Metadata__mdt > asmList = [SELECT a.QualifiedApiName, a.Matching_Configured_Data_Category__c,  a.Matching_Configured_Partner_Space__c, a.Matching_Configured_KB_Category_Value__c, a.Account_Record_Type_DeveloperName__c, a.MasterLabel, a.Label, a.Id, a.DeveloperName 
                    FROM Account_Setting_Metadata__mdt a
                        ];
        system.debug('...Account asmList.. '+asmList);
        
        for(Account_Setting_Metadata__mdt asmd : asmList){
            asm.put(asmd.Account_Record_Type_DeveloperName__c,asmd);
        }
        system.debug('...Account metadata.. '+asm);
        system.debug('...Account metadata.. '+acs2);
        
        //communityName = [SELECT Name FROM Network where Id = :Network.getNetworkId()].Name;
        system.debug('..community Name.. '+communityName);
        
        rtMap = new Map<ID, RecordType>([Select Id, DeveloperName, SObjectType from RecordType Where SObjectType = 'Account']);
        // record type as passed from CaseExtension
        caseRecordTypeId = ApexPages.currentPage().getParameters().get('recordTypeId');
        deflectionRecordId = ApexPages.currentPage().getParameters().get('deflectionRecordId');
        caseRecordTypeName = ApexPages.currentPage().getParameters().get('recordTypeName');
        contactId = ApexPages.currentPage().getParameters().get('contactId');
        accountId = ApexPages.currentPage().getParameters().get('accountId');
        if(accountId == null){
        accountId = [Select Contact.AccountId from User where Id =: UserInfo.getUserId()].Contact.AccountId;
        }
        cspSelectionType = ApexPages.currentPage().getParameters().get('isCSPSelected');
        acctRecord = [SELECT id, name, KB_Category_Visibility__c,RecordType.developerName from Account WHERE id=:accountId];
        caseRecord = (Case) stdController.getRecord();
        
        // for channel partners
        String isCPCaseForSellerParam = ApexPages.currentPage().getParameters().get('isCPCaseForSeller');
        isCPCaseForSeller = (isCPCaseForSellerParam == 'true' ? true : false);
        if (isCPCaseForSeller) {
            caseRecord.In_Reference_to_Seller__c = accountId;
        }

        // for creation of follow up cases
        String isFollowUpCaseParam = ApexPages.currentPage().getParameters().get('isFollowUpCase');
        isFollowUpCase = (isFollowUpCaseParam == 'true' ? true : false);
        if(isFollowUpCase) {
            // now get the parent case number and populate the parent case id for display and save
            String parentCaseNumber = ApexPages.currentPage().getParameters().get('parentCaseNumber');
            Id parentCaseId = [select Id from Case where CaseNumber = :parentCaseNumber limit 1].Id;
            caseRecord.ParentId = parentCaseId;
        }

        
        // set the record type in constructor so that picklist values
        // related to that record type is only rendered
        caseRecord.RecordTypeId = caseRecordTypeId;
        
        // create the auth token
        authToken = EncryptionUtility.createEncryptedString();
        system.debug('... inside controller.. ');
        
        mapCaseCustomSettings = new map<string,CaseCustomSettings__c>();        
        for(CaseCustomSettings__c oCaseCustomSettings : CaseCustomSettings__c.getAll().values()){       
          string sKey = oCaseCustomSettings.Category__c + '|'+ oCaseCustomSettings.SubCategory__c;      
          mapCaseCustomSettings.put(sKey,oCaseCustomSettings);      
        }       
        //CaseCustomSettings__c
    }

    /** 
    * Use Account Category Visibility information to specifiy top level Data Category for filter use.  
    * 
    * @param none
    * @return Data Category Filter for SOSL search OR null value when KB_Category_Visibility__c is empty.
    */

    public String getDataCategoryFilter(){
        //1. Pull acctRrd with KB_Category_Visibility__c info.  Done.
        //Map it to the correct Data Category filter.
        //1.5 Create a List of the various members of the MSP.
        //2. Create a Map of available MSP options to their respective Data Categories.
        //3. Build a Data Category filter based on each member of the MSP field.
        //Map<String, String> catVsbltToDataCatMap = new Map<String, String>(['Seller' => 'Marketplace',
        //                                                                    'Supplier' => 'Suppliers',
        //                                                                    'Partner' => 'LifeCycle']);
        if(acctRecord.KB_Category_Visibility__c == null){
            return null;
        }
        List<String> result = new List<String>();
        List<String> mspValList = acctRecord.KB_Category_Visibility__c.trim().split(';');
 
        for(String row : mspValList){
            for(String catVisRow : asm.keySet()){
                    system.debug('Matching result... '+asm.get(catVisRow).Matching_Configured_Data_Category__C);
                    system.debug('RecordTypeNameValue result... '+asm.get(catVisRow).Matching_Configured_KB_Category_Value__c);
                if( asm.get(catVisRow).Matching_Configured_KB_Category_Value__c == row && 
                    asm.get(catVisRow).Matching_Configured_Data_Category__C != 'INVALID'){
                    system.debug('Matching result... '+asm.get(catVisRow).Matching_Configured_Data_Category__C);
                    result.add(asm.get(catVisRow).Matching_Configured_Data_Category__C);
                    system.debug('result... '+result);
                }
            }
        }
        return 'WITH DATA CATEGORY LifeCycle__c BELOW (' + String.join(result, ', ') + ')';
    }
    
    
    /**
     * Method to return if the flow is from the Create Follow-up Case button
     * or is a regular new case creation flow
     * 
     * @return true of false based on the flow
     */ 
    public Boolean getIsFollowUpCase() {
        return isFollowUpCase;
    }
    
    public Boolean getIsCPCaseForSeller() {
        return isCPCaseForSeller;
    }
    
    
    /**
     * The standard save method.
     * 1. Saves the case
     * 2. Updates the deflection record with case details
     * 
     * @return reference to the detail page of the case after creation
     */ 
    public PageReference save() {
    
        bShowMessage = false;       
        string sKey = caseRecord.Issue_Category__c + '|'+ caseRecord.Sub_Category_1__c;     
        if(mapCaseCustomSettings.containsKey(sKey)){        
          bShowMessage = true;      
          CaseCustomSettings__c oCaseCustomSettings = mapCaseCustomSettings.get(sKey);      
          sMessageForDisplay = oCaseCustomSettings.Message__c;      
          if(oCaseCustomSettings.Message2__c!=null){        
            sMessageForDisplay += oCaseCustomSettings.Message2__c;      
          }     
                  bRedirectOnOk = oCaseCustomSettings.RedirectToExternalUrlOnOK__c;     
                  bShowCancel = oCaseCustomSettings.ShowCancel__c;      
                  if(bRedirectOnOk){        
                    sRedirectUrl = oCaseCustomSettings.ExternalUrl__c;      
                  }     
          return null;      
        }
        
        
        // create a new case now
        caseRecord.ContactId = contactId;
        caseRecord.CSP_Selection_Type__c = cspSelectionType;
        insert caseRecord;

        // with case creation, the deflected record should be updated to 
        // capture that the case was created
        CaseCRUDHelper.updateDeflectionRecord(deflectionRecordId, caseRecord.Id, caseRecord.Subject);
        
        return new PageReference('/' + caseRecord.Id);
    }
    
    
    /**
     * Navigates back to the Home page of Case. 
     * 
     * @return reference to the case home page
     */ 
    public PageReference cancel() {
       /* String profileName = [Select Id, Name from Profile where Id = :UserInfo.getProfileId()].Name;
        if(CaseUtility.getSupplierCommunityProfileNames().contains(profileName)){
            return new PageReference('/500/o');
        }else{
            return new PageReference('/500/o');
        }  
        */  
        return new PageReference('/500/o');
    }
    
    /**
     * Called by the VF page to display the results of the KB search.
     * 
     * @return list of records fetched after the SOSL query.
     */
    public List<KnowledgeArticleVersion> getResults() {
        return articlesController.getRecords();
    }
    
    /**
     * Called by the VF page for logic when to display the help text.
     * Typically its when the search query is blank.
     */
    public Boolean getDisplaySearchHelp() {
        return String.isBlank(searchQuery);
    }
    
    /**
     * Called by the VF page for logic when to display the 'no articles found' error text.
     *
     * @return boolean value for when search query is present but no results where found.
     */
    public Boolean getDisplayNoArticles() {
        return !String.isBlank(searchQuery) && articlesController.getResultSize() == 0;
    }
    
    /**
     * Used by the VF page to know the base URL of the KB, for article linking.
     * 
     * @return base url of the KB
     */
    public String kbURL {
        get {
            return KNOWLEDGEBASE_URL__c.getInstance('Default').KB_URL__c;
        }
    }
    
    /** Used by the VF page to get the extension string for all KB records. Also used for article linking.
     * 
     * @return extension string of KAV records (__kav)
     */
    public String kavExt {
        get {
            return WalmartConstants.KAV_EXT;
        }
    }
    
    /**
     * Used by the VF page to return an encrypted string to be passed to the PKB for user authentication.
     * @see EncryptionUtility
     */
    public String pkbToken {
        get {
            return authToken;
        }
    }
    
    
    /**
     * Used by the VF page to return the dropdown selection option.
     * 
     */
    public String kbType{
        get {
            if(communityName == WalmartConstants.SUPPLIER_COMMUNITY_NAME){
                string dataCategory = asm.get('X1P_Account').Matching_Configured_Data_Category__C;
                return 'LifeCycle:'+dataCategory.substring(0,dataCategory.length()-3);
            }else{
                string dataCategory = asm.get('MP_Account').Matching_Configured_Data_Category__C;
                return 'LifeCycle:'+dataCategory.substring(0,dataCategory.length()-3);
            }
            //return Account_Custom_Settings__c.getInstance(acctRecord.RecordType.developerName).Knowledge_Base_Type__c;
        
        }
    }
    
    
    /**
     * Essentially searches through KB for matching articles given the searchQuery.
     * Right now is called through an apex:actionFunction.
     */
    public void performSearch() {
        
        List<KnowledgeArticleVersion> articleList;
        
        if (!String.isBlank(searchQuery) && searchQuery.trim().length() > 1) {
            articleList = performSOSL(searchQuery);
        }
        else {
            articleList = new List<KnowledgeArticleVersion>();
        }

        articlesController = new ApexPages.StandardSetController(articleList);
        
        // Sets the page size to 10 for pagination
        articlesController.setPageSize(10);
    }
    
    /** 
     * Use this for searching articles using search terms. Performs SOSL query on KB articles.
     * 
     * @return List of knowledge articles resulting from the SOSL query.
     */
    private List<KnowledgeArticleVersion> performSOSL(String theSearchQuery) {
        theSearchQuery = String.escapeSingleQuotes(theSearchQuery); // escape single quotes to prevent SOSL injection
        String publishStatus = WalmartConstants.DEFAULT_STATUS;
        String lang = WalmartConstants.DEFAULT_LANG;
        String q = 'FIND \'' + theSearchQuery + '*\' IN ALL FIELDS RETURNING KnowledgeArticleVersion(' +join(kavFields(), ',') 
                    + ' where PublishStatus = \'' + publishStatus + '\'  and Language = \'' + lang + '\') ';
        String catFilter = getDataCategoryFilter();
        system.debug('.. catfilter.. '+catFilter);
        if(catFilter != null){
            q = q + ' ' + catFilter;
        }

        System.debug('<<< SOSL query: ' + q);

        List<List<SObject>> searchList = Search.query(q);
        system.debug('search resut.. '+searchList);
        return (List<KnowledgeArticleVersion>)searchList[0];
    }
    
    /**
     * Invoked by an actionFunction from VF to save the deflected article.
     */
    public void saveArticleDeflection() {
        
        System.debug('<<< article link: ' + deflectedArticleLink);
        String shortenedLink = deflectedArticleLink.left(deflectedArticleLink.indexOf('token='));
        System.debug('<<< shortened link: ' + shortenedLink);
        
        List<Case_Initiation__c> caseInitiations = [SELECT Id, Deflected__c, Knowledge_Link__c, Case_Subject__c 
            FROM Case_Initiation__c WHERE Id=:deflectionRecordId LIMIT 1];
        if (caseInitiations.size() > 0) {
            Case_Initiation__c caseInitiation = caseInitiations.get(0);
            caseInitiation.Deflected__c = true;
            caseInitiation.Knowledge_Link__c = shortenedLink;
            caseInitiation.Case_Subject__c = searchQuery;
            try {
                update caseInitiation;
            }
            catch(Exception e) {
                System.debug('<<< Encountered error during caseInitiation update: ' + e);
            }
        }
        else {
            System.debug('<<< Problem! no case initiations matching the ID were found.');
        }
    }
    
    /**
     * @return List of relevant KAV fields to us for displaying the article list and necessary ones for article linking.
     */
    public static List<String> kavFields() {
        return new List<String>{
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
    
    /**
     * Joins elements in the passed list of strings by the passed string c
     * c can be a single character or a longer string -- useful for joinging segments of a dynamic sosl or soql query
     */
    public static String join(List<String> strings, String c) {
        if (strings == null || strings.isEmpty()) return null;

        String sep = (String.isEmpty(c) ? ',' : c);
        Integer i, size;
        String s = strings[0];

        size = strings.size();
        for (i = 1; i < size; i++) {
            s += (sep + strings[i]);
        }
        return s;
    }
}
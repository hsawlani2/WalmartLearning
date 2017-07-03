public without sharing class QuestionnaireController {
    
    // Test Application ID: a054B000000JROh
    
    public Application__c application { get; set; }
    private Opportunity opportunity { get; set; }
    
    // A flag than is turned on after the form is submitted and saved.
    // When this is turned on, the dialog will be displayed the moment the page reloads.
    public Boolean isApplicationCompleted { get; set; }
    
    // Flag is turned on when no matching Opportunities are found.
    // This means that either the Opportunity is past the 'Opportunity' Stage or there are problems with the get parameters.
    // We'll show an error dialog that blocks the user from proceeding.
    public Boolean isApplicationBlocked { get; set; }
    
    public String selectedMarketplaces { get; set; }
    public String selectedCategories { get; set; }
    public String selectedIntegrations { get; set; }
    public String otherCategoryName { get; set; }
    public String otherCategoryId { get; set; } // field that gets set internally during query
    public String taxID { get; set; } // because FLS will prevent the actual tax ID from being visible on the form.
    public map<string,string> mapIntegrationMethodIndirect;
    // Private variables
    public List<Category__c> categoryList;
    
    public list<SelectOption> getDirectIntegrationMethod(){
        System.debug('@Developer --> getDirectIntegrationMethod :');
        list<SelectOption> lstOption = new list<SelectOption>();
        lstOption.add(new SelectOption('','--None--'));
        for(IntegrationMethodWrapper imw : fetchIntegrationMethods('Direct')){
            lstOption.add(new SelectOption(imw.Name,imw.Name));
        }
        return lstOption;
    }
    
    public list<SelectOption> getIndirectIntegrationMethod(){
        System.debug('@Developer --> getIndirectIntegrationMethod :');
        mapIntegrationMethodIndirect = new map<string,string>();
        list<SelectOption> lstOption = new list<SelectOption>();
        lstOption.add(new SelectOption('','--None--'));
        for(IntegrationMethodWrapper imw : fetchIntegrationMethods('Partner')){
            lstOption.add(new SelectOption(imw.Id,imw.Name));
            mapIntegrationMethodIndirect.put(imw.Id,imw.Name);
        }
        return lstOption;
    }
    
    public list<SelectOption> getSpecialitypartnersList(){
        List<SelectOption> lstSpecialitypartners = new List<SelectOption>();
        mapSpecialitypartners = new map<string,string>();
        for(Account oAccount : [Select Id,Name From Account Where RecordType.DeveloperName ='Partner_Account' and Partner_Type__c='Specialty Partner' and (Partner_Onboarding_Status__c = 'Live' or Partner_Onboarding_Status__c = 'Pilot')]){
                        lstSpecialitypartners.add(new SelectOption(oAccount.Id,oAccount.Name));
                        mapSpecialitypartners.put(oAccount.Id,oAccount.Name);
                        System.debug('@Developer --> oAccount.Id :'+oAccount.Id+',oAccount.Name:'+oAccount.Name);
        }
        return lstSpecialitypartners;
    }
    
    public String userAgent { get; set; }
    
    /* ***** HANDLE TO CURRENT INSTANCE OF CONTROLLER (to be passed to rendered VF components, avoids re-instantiation of controller) ***** */
    public QuestionnaireController qCon { get { return this; } }
    
    /* ***** URL PARAM CONSTANTS ***** */
    private final static String APP_PARAM = 'app_d';
    public final static String ACCT_PARAM = 'account_id';
    private final static String CHANNEL_PARAM = 'cId';
    private final static String OPP_NAME = 'Opportunity';
    
    private final static Boolean testMode = false;
    public String channelPartnerId { get; set; }
    public map<string,string> mapSpecialitypartners;
    public QuestionnaireController() {
        
        userAgent = ApplicationFormUtils.getUserAgent();
        
        if (isDirectSeller()) {
            String accountId = ApexPages.currentPage().getParameters().get(ACCT_PARAM);
            System.debug('\n\nLQ: Began direct seller path with account id ' + accountId + '\n');
            
            initializeUsingAccountId(accountId);
            
        }
        else if (isChannelPartner()) {
            this.channelPartnerId = ApexPages.currentPage().getParameters().get(CHANNEL_PARAM);
            System.debug('\n\nLQ: Began channel partner path with id ' + this.channelPartnerId + '\n');
            if (ApplicationFormUtils.fetchAccount(this.channelPartnerId, testMode) == null) {
                System.debug('\n\nLQ: Missing channel account!');    
                isApplicationBlocked = true;
            }
        }
        else {
            System.debug('\n\nLQ: No get params provided! Defaulting to empty form.');
            if (!testMode) {
                isApplicationBlocked = true;
            }
        }
        
        // Build the category list on init
        this.categoryList = buildCategoryList();
        
        setDefaults();
        
    }
    
    private void setDefaults() {
        
        if (application == null) {
            application = new Application__c();
        }
        if (ApplicationFormUtils.isBlank(application.Country__c)) {
            application.Country__c = 'United States';
        }
        /*if (ApplicationFormUtils.isBlank(application.State_of_Incorporation__c)) {
            application.State_of_Incorporation__c = '';
        }
        if (ApplicationFormUtils.isBlank(application.How_did_you_hear_about_Marketplace__c)) {
            application.How_did_you_hear_about_Marketplace__c = 'Walmart Business Development';
        }*/
        if (ApplicationFormUtils.isBlank(application.Selling_on_any_other_Marketplace__c)) {
            application.Selling_on_any_other_Marketplace__c = 'Yes';
        }
        if (ApplicationFormUtils.isBlank(application.Free_Shipping__c)) {
            application.Free_Shipping__c = 'Yes';
        }
        
        // set default
        taxID = '';
    }
    
    
    public void initializeUsingAccountId(String accountId) {
        Account anAccount = ApplicationFormUtils.fetchAccount(accountId, testMode);
        if (anAccount != null) {
            // fetch opportunity now
            opportunity = ApplicationFormUtils.fetchOpportunity(anAccount.Id, OPP_NAME, !testMode, true, false);
            Contact aContact = ApplicationFormUtils.fetchContact(opportunity);
            
            if (opportunity != null && aContact != null) {
                application = ApplicationFormUtils.fetchApplicationWithOpportunity(opportunity.Id);
                if (application == null) {
                    system.debug('no application has been created yet, so create a new one');
                    application = new Application__c();
                    initializeApplicationRecord(application, anAccount, opportunity, aContact);
                }
            }
            else {
                system.debug('missing contact and/or opportunity ');
                isApplicationBlocked = true;
            }
        }
        else {
            System.debug('missing account! ' + accountId);
            isApplicationBlocked = true;
        }
    }
    
    public PageReference saveApplicationData() {
        //
        String messageCode = ApplicationFormUtils.ERROR_CODE;
        if (application != null) {
            // application.Categories__c = this.selectedCategories;
            System.debug('\n\nLQ: Saving categories ' + this.selectedCategories+ '\n');
            System.debug('\n\nLQ: Saving integration ' + this.selectedIntegrations+ '\n');
            
            
            try {
                application.Marketplace_selections__c = this.selectedMarketplaces;
                application.Preferred_integration__c = this.selectedIntegrations;
        
                application.Top_Category__c = getTopCategoryName();
                application.Tax_ID__c = taxID;
         
                saveFulfillmentPercentage();
                /*if(application.Preferred_integration_General__c==null || application.Preferred_integration_General__c!='Channel Aggregator'){
                                application.Integration_Method_Id__c = null;
                            }*/
                            System.debug('@Developer --> application.SpecialitypartnerIds__c :'+application.SpecialitypartnerIds__c);
                            if(application.Preferred_integration_General__c!=null && application.Preferred_integration_General__c=='Partner'){
                                if(application.Preferred_integration_Specific_Id__c!=null && mapIntegrationMethodIndirect.containsKey(application.Preferred_integration_Specific_Id__c)){
                                    application.Preferred_integration_Specific__c = mapIntegrationMethodIndirect.get(application.Preferred_integration_Specific_Id__c);
                                }
                            }
                            else{
                                application.Preferred_integration_Specific_Id__c = null;
                            }
                            string sSpecialitypartnerNames;
                            if(application.SpecialitypartnerIds__c!=null && application.SpecialitypartnerIds__c!=''){
                                if(application.SpecialitypartnerIds__c.startsWith('[')){
                                                                            application.SpecialitypartnerIds__c = application.SpecialitypartnerIds__c.substring(1);
                                                                    }
                                if(application.SpecialitypartnerIds__c.endsWith(']')){
                                                                            application.SpecialitypartnerIds__c = application.SpecialitypartnerIds__c.left(application.SpecialitypartnerIds__c.length()-1);
                                                                    }
                                application.SpecialitypartnerIds__c =application.SpecialitypartnerIds__c.replace(' ','');
                                                                    for(string sId : application.SpecialitypartnerIds__c.split(',')){
                                                                        if(sId!=null && sId!=''){
                                                                            string sSpecialitypartnerName = mapSpecialitypartners.get(sId);
                                                                            System.debug('@Developer --> id :'+sId+',sSpecialitypartnerName:'+sSpecialitypartnerName);
                                                                            if(sSpecialitypartnerNames==null){
                                                                                sSpecialitypartnerNames = sSpecialitypartnerName;
                                                                            }
                                                                            else{
                                                                                sSpecialitypartnerNames += ',' + sSpecialitypartnerName;
                                                                            }
                                                                        }
                                                                    }
                                                                }
                            application.Specialitypartner__c = sSpecialitypartnerNames;
                System.debug('\n\nLQ: Before upserting application ');
                upsert application;  
                System.debug('\n\nLQ: After upserting application ');
                // Invoke the Linker class to update related accounts
                Application_Seller_Link.link(application.Id, this.channelPartnerId);
                System.debug('\n\nLQ: After linking application and channel partner ');
                // also save categories
                saveCategoryList(application);
                
                // also save the attachment
                if (attachment.body != null) {
                    System.debug('\n\nLQ: Saving file attachment on record ' + application.Id + '\n');
                    attachment.ParentId = application.Id;
                    attachment.OwnerId = UserInfo.getUserId();
                    
                    insert attachment;
                }
                else {
                    System.debug('\n\nLQ: No attachments added \n');        
                }
                
                isApplicationCompleted = true;
                messageCode = ApplicationFormUtils.FORM_SUCCESS_CODE;
            }
            catch (Exception e) {
                PageReference pr = Page.FormSaveSuccess;
                isApplicationCompleted = false;
                messageCode = ApplicationFormUtils.ERROR_CODE;
                System.debug('Error encountered! ' + e.getMessage());
                pr.getParameters().put(ApplicationFormUtils.MESSAGE_CODE, messageCode);
                pr.getParameters().put(ApplicationFormUtils.ERROR_DETAILS, 'Error details: ' + e.getMessage() + '. Please provide this information for further diagnosis.');
                return pr;
                // Show an error during save
            } finally {
                // Any finally clauses?
            }
            
        }
        PageReference pr = Page.FormSaveSuccess;
        pr.getParameters().put(ApplicationFormUtils.MESSAGE_CODE, messageCode);
        return pr;
    }
    
    private void saveCategoryList(Application__c theApplication) {
        // save categories
        System.debug('\n\n\n JSON:\n' + this.selectedCategories);
        
        if (!ApplicationFormUtils.isBlank(this.selectedCategories)) {
            List<ApplicationCategories__c> categoriesToSave = new List<ApplicationCategories__c>();
            ApplicationCategoryData data = ApplicationCategoryData.parse(this.selectedCategories);
            
            for (ApplicationCategoryData.CategoryList parsed : data.categoryList) {
                ApplicationCategories__c anAppCategory = new ApplicationCategories__c();
                anAppCategory.No_of_Brands_to_be_sold_on_Walmart__c = parsed.brands;
                anAppCategory.No_of_SKU_s_to_be_sold_at_Walmart__c = parsed.walmart_skus;
                anAppCategory.Percentage_of_Annual_Sales__c = parsed.perc_annual_sales;
                anAppCategory.Total_Number_of_SKU_s__c = parsed.skus;
                anAppCategory.Category__c = parsed.id;
                anAppCategory.Application__c = theApplication.id;
                
                // save other category name
                if (parsed.id.equals(this.otherCategoryId)) {
                    System.debug('Equal! setting category name ' + this.otherCategoryName);
                    anAppCategory.Other_Name__c = this.otherCategoryName;
                }
                else {
                    System.debug('parsed id:'+parsed.id+';;;; other category id:'+otherCategoryId);    
                }
                if (opportunity != null) {
                    anAppCategory.Opportunity__c = opportunity.Id;
                }
                System.debug('\n\n\n Before inserting categories:\n' );
                categoriesToSave.add(anAppCategory);
                System.debug('\n\n\n After inserting categories:\n' );
            }
            insert categoriesToSave;
        }
    }
    
    private void saveFulfillmentPercentage() {
        List<Decimal> amazonPct = new List<Decimal>();
        List<Decimal> othersPct = new List<Decimal>();
        System.debug('\n\nLQ: saveFulfillmentPercentage ');
        // fill up the values in the list
        groupFulfillmentPct(application.Fulfillment_Service_Provider_1__c, application.Percentage_of_Total_Orders_Shipped_1__c, amazonPct, othersPct);
        groupFulfillmentPct(application.Fulfillment_Service_Provider_2__c, application.Percentage_of_Total_Orders_Shipped_2__c, amazonPct, othersPct);
        groupFulfillmentPct(application.Fulfillment_Service_Provider_3__c, application.Percentage_of_Total_Orders_Shipped_3__c, amazonPct, othersPct);
        groupFulfillmentPct(application.Fulfillment_Service_Provider_4__c, application.Percentage_of_Total_Orders_Shipped_4__c, amazonPct, othersPct);
        groupFulfillmentPct(application.Fulfillment_Service_Provider_5__c, application.Percentage_of_Total_Orders_Shipped_5__c, amazonPct, othersPct);
        
        //application.Amazon_Fulfillment_Perc__c = computeAverage(amazonPct);
        application.Others_Fulfillment_Perc__c = computeAverage(othersPct);
        System.debug('\n\nAverage fullfilment percent: ' + application.Others_Fulfillment_Perc__c );
    }
    
    private void groupFulfillmentPct(String providerName, Decimal fulfillmentPct, List<Double> amazonPctList, List<Double> othersPctList) {
        System.debug('\n\nLQ: Inside groupFulfillmentPct ');
        if (fulfillmentPct != null && !String.isBlank(providerName) != null) {
            String[] amazon = Application_Settings__c.getInstance('Default').Amazon_Fulfillment_Providers__c.split(',');
            Boolean addToAmazon = false;
            for (Integer i = 0; i < amazon.size(); i++) {
                String subString = amazon[i];
                if (subString.equalsIgnoreCase(providerName)) {
                    addToAmazon = true;
                }      
            }
            if (addToAmazon) {
                amazonPctList.add(fulfillmentPct);
            }
            else {
                othersPctList.add(fulfillmentPct);
            }
        }
    }
    
    private Decimal computeAverage(List<Decimal> aList) {
        if (aList.size() > 0) {
            Decimal total = 0;
            for (Integer i = 0; i < aList.size(); i++) {
                total += aList.get(i);
            }
            return total / aList.size();
        }
        return 0;
    }
    
    private String getTopCategoryName() {
        
        if (!ApplicationFormUtils.isBlank(this.selectedCategories)) {
            String topCategoryId = '';
            Integer topCategoryPct = 0;
            
            List<ApplicationCategories__c> categoriesToSave = new List<ApplicationCategories__c>();
            ApplicationCategoryData data = ApplicationCategoryData.parse(this.selectedCategories);
            for (ApplicationCategoryData.CategoryList parsed : data.categoryList) {
                if (parsed.perc_annual_sales >  topCategoryPct) {
                    topCategoryId = parsed.id;
                    topCategoryPct = parsed.perc_annual_sales;
                }
            }
            
            // iterate through fetched categories to find the category name
            for (Category__c aCategory : this.categoryList) {
                if (aCategory.Id.equals(topCategoryId)) {
                    return aCategory.Name;
                }
            }
        }
        
        return null;
    }
    
    /**
     * Custom Getters and Setters
     */
    
    private Boolean isDirectSeller() {
        return ApexPages.currentPage().getParameters().get(ACCT_PARAM) != null;
    }
    
    private Boolean isChannelPartner() {
        return ApexPages.currentPage().getParameters().get(CHANNEL_PARAM) != null;
    }
    
    public List<SelectOption> allMarketplaceSelectionOptions {
        get {
            return getPickListOptions(Application__c.Marketplace_selections__c.getDescribe());
        }
    }
    
    private Integer categoryPageSize() {
        return Integer.valueOf(Math.ceil(this.categoryList.size() / 3));
    }
    
    public List<Category__c> categoriesPage1 {
        get {
            return getSubList(this.categoryList, categoryPageSize(), 0);
        }
    }
    
    public List<Category__c> categoriesPage2 {
        get {
            return getSubList(this.categoryList, categoryPageSize(), 1);
        }
    }
    
    public List<Category__c> categoriesPage3 {
        get {
            return getSubList(this.categoryList, categoryPageSize(), 2);
        }
    }
    
    // Snippet from https://developer.salesforce.com/blogs/developer-relations/2008/12/using-the-metadata-api-to-retrieve-picklist-values.html
    private List<SelectOption> getPickListOptions(Schema.DescribeFieldResult fieldResult) {
        List<SelectOption> options = new List<SelectOption>();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
        for( Schema.PicklistEntry f : ple) {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    
    private List<Category__c> buildCategoryList() {
        String query = 'SELECT Id,Name,Custom_Naming__c FROM Category__c WHERE Active__c = true ORDER BY Sort_Order__c ASC NULLS FIRST, Name ASC';
        List<Category__c> resultList = Database.query(query);
        
        // determine the 'Other' category
        for (Category__c aCategory : resultList) {
            if (aCategory.Custom_Naming__c) {
                this.otherCategoryId = aCategory.Id;
            }
        }
        
        return resultList;
    }
    
    
    private List<Category__c> getSubList(List<Category__c> mainList, Integer size, Integer pageIndex) {
        List<Category__c> subList = new List<Category__c>();
        for (Integer i = pageIndex * size; (i < (pageIndex * size) + size) && (i < mainList.size()); i++) {
            subList.add(mainList.get(i));
        }
        return subList;
    }
    
    private void initializeApplicationRecord(Application__c anApplication, Account anAccount, Opportunity anOpportunity, Contact aContact) {
        anApplication.Legal_Company_Name__c = anAccount.Name;
        anApplication.Website__c = anAccount.Website;
        anApplication.Tax_ID__c = anAccount.Tax_ID__c;
        anApplication.Year_Company_Founded__c = anAccount.Year_Company_Founded__c;
        anApplication.Legal_Address_Line_1__c = anAccount.BillingStreet;
        anApplication.Postal_Zip_Code__c = anAccount.BillingPostalCode;
        anApplication.City_Town__c = anAccount.BillingCity;
        anApplication.State_Province_Region__c = anAccount.BillingState;
        anApplication.Country__c = anAccount.BillingCountry;
        anApplication.DBA_Name__c = anAccount.DBA_Name__c;
        anApplication.Seller_Name_1__c = anAccount.Amazon_Seller_Display_Name__c;
        anApplication.Seller_Name_2__c = anAccount.eBay_Seller_Display_Name__c;
        anApplication.Seller_Name_3__c = anAccount.Other_Seller_Display_Name__c;
        anApplication.Primary_Contact_First_Name__c = aContact.FirstName;
        anApplication.Primary_Contact_Last_Name__c = aContact.LastName;
        anApplication.Primary_Contact_Title__c = aContact.Title;
        anApplication.Primary_Contact_Phone__c = aContact.Phone;
        anApplication.Primary_Contact_Email__c = aContact.Email;
        
        application.Account__c = anAccount.id;
        application.Opportunity__c = anOpportunity.id;
        //application.Do_you_give_us_permission_to_text__c = 'Yes';
    }
    
    /** Attachments 
     */
     
    public Attachment attachment {
        get {
            if (attachment == null) {
                attachment = new Attachment();
            }
            return attachment;
        }
        set;
    }
     
    /** End attachments
     */
     
      public List<IntegrationMethodWrapper> fetchIntegrationMethods(string sSelectedIntegrationChannel){
        List<IntegrationMethodWrapper> lstIntegrationMethodList = new List<IntegrationMethodWrapper>();
        if(sSelectedIntegrationChannel=='Direct'){
            set<string> setIntegrationMethodDirect = new set<string>();
            List<IntegrationMethodDirectMapping__c> lstIntegrationMethodDirectMapping = IntegrationMethodDirectMapping__c.getAll().values();
            if(lstIntegrationMethodDirectMapping!=null && lstIntegrationMethodDirectMapping.size()>0){
                for(IntegrationMethodDirectMapping__c oIntegrationMethodDirectMapping:lstIntegrationMethodDirectMapping){
                    if(oIntegrationMethodDirectMapping.IsActive__c){
                        setIntegrationMethodDirect.add(oIntegrationMethodDirectMapping.MethodName__c);
                    }
                }
            }
            for( Schema.PicklistEntry f : Account.Integration_Method__c.getDescribe().getPicklistValues()){
                string sValue = f.getValue();
                if(setIntegrationMethodDirect.contains(sValue)){
            lstIntegrationMethodList.add(new IntegrationMethodWrapper(null,sValue));
                }
            }
        }
        else if((sSelectedIntegrationChannel=='Partner')||(sSelectedIntegrationChannel=='Partner')){
            //The we would query Accounts which are of Channel partner record type.And the partner type field will be Future Service partner and their partner onboarding status field will be Live and pilot.
            for(Account oAccount : [Select Id,Name From Account Where RecordType.DeveloperName ='Partner_Account' and Partner_Type__c='Full Service Partner' and (Partner_Onboarding_Status__c = 'Live' or Partner_Onboarding_Status__c = 'Pilot' ) ORDER BY Name ASC]){
                lstIntegrationMethodList.add(new IntegrationMethodWrapper(oAccount.Id,oAccount.Name));
            }
             lstIntegrationMethodList.add(new IntegrationMethodWrapper('Other','Other'));
        }
        else{
            lstIntegrationMethodList.add(new IntegrationMethodWrapper('','None'));
        }       
        System.debug('@Developer --> lstIntegrationMethodList :' + lstIntegrationMethodList);
        return lstIntegrationMethodList;
    }
    
}
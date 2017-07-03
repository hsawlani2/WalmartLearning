public class BD2Controller {

    public BD2Controller bdCon { get{return this;} }

    //public WrapperClass wrapList {get; set;}
    
    public Lead oLead { get;set; }
    public Application__c oApplication{get;set;}
    public Boolean isApplicationCreated {get;set;}
    public Boolean isPartner{get;set;}
    public String attachmntid{get;set;}
    public list<SelectOption> lstPrimaryCategory {get;set;}
    public list<SelectOption> lstSecondaryCategory {get;set;}
    public list<SelectOption> lstTertiaryCategory {get;set;}
    public ApplicationCategories__c oPrimaryCategory {get;set;}
    public ApplicationCategories__c oSecondaryCategory {get;set;}
    public ApplicationCategories__c oTertiaryCategory {get;set;}
    public ApplicationCategories__c oOtherCategory {get;set;}
    public integer currentstep{get;set;}
    public integer currentstepsaved{get;set;}
    public boolean bSameasprimary{get;set;}
    public string sTechnicalConfirmEmail{get;set;}
    public string sSecondaryExt{get;set;}
    
    public boolean bShippingUsps{get;set;}
    public boolean bShippingUps{get;set;}
    public boolean bShippingDhl{get;set;}
    public boolean bShippingFba{get;set;}
    public boolean bShippingFedex{get;set;}
    public boolean bShippingOther{get;set;}
    
    public boolean bIndependentSellerReviewsGoogleSites{get;set;}
    public boolean bIndependentSellerReviewsApproved{get;set;}
    public boolean bIndependentSellerReviewsRating{get;set;}
    public boolean bIndependentSellerReviewsPilot{get;set;}
    public boolean bIndependentSellerReviewsOther{get;set;}
    
    
    public boolean bSellerTypeBrand{get;set;}
    public boolean bSellerTypeManufacturer{get;set;}
    public boolean bSellerTypeRetailer{get;set;}
    public boolean bSellerTypeDistributor{get;set;}
    public boolean bSellerTypeLiquidator{get;set;}
    public boolean bSellerTypeDropshipper{get;set;}
    public boolean bSellerTypeImporter{get;set;}
    public boolean bSellerTypeEtailer{get;set;}

    public boolean bCurrentSellingRelationshipWalmartStores{get;set;}
    public boolean bCurrentSellingRelationshipWalmartCom{get;set;}
    public boolean bCurrentSellingRelationshipWalmartWalmartComDSV{get;set;}
    public boolean bCurrentSellingRelationshipWalmartJetCom{get;set;}
    public boolean bCurrentSellingRelationshipWalmartNone{get;set;}

    public String iPercentageOfSKUsWithUPCCodes{get;set;}
    public String iPercentageOfSalesFromRefurbishedItems{get;set;}
    public String iPercentageOfSalesFromUsedItems{get;set;}
    
    public String iAmazonFulfillmentPerc{get;set;}
    public String iSKUDropshippedPerc{get;set;} 
    public String iSKUOwnedPerc{get;set;} 
    
    public String sonlineoffline {get;set;}

    // Added by Shapoor 20170326 to support MarketplaceEmailError message. //
    public String userErrorMessage {get;set;}
    /*
    Own_No_of_Active_SKUs__c
    Own_Annual_Sales__c
    Own_Average_Sales_Per_Order__c
    Amazon_No_of_Active_SKUs__c
    Amazon_Annual_Sales__c
    Amazon_Average_Sales_Per_Order__c
    Ebay_No_of_Active_SKUs__c
    Ebay_Annual_Sales__c
    Ebay_Average_Sales_Per_Order__c
    Other_No_of_Active_SKUs__c
    Other_Annual_Sales__c
    Other_Average_Sales_Per_Order__c
    Amazon_Perc_Positive_Ratings_12_mos__c
    Ebay_Perc_Positive_Ratings_12_mos__c
    Other_Perc_Positive_Ratings_12_mos__c
    */
    
    public string sOwnNoofActiveSKUs {get;set;} 
    public string sOwnAnnualSales {get;set;} 
    public string sOwnAverageSalesPerOrder {get;set;} 
    public string sAmazonNoofActiveSKUs {get;set;} 
    public string sAmazonAnnualSales {get;set;} 
    public string sAmazonAverageSalesPerOrder {get;set;} 
    public string sEbayNoofActiveSKUs {get;set;} 
    public string sEbayAnnualSales {get;set;} 
    public string sEbayAverageSalesPerOrder {get;set;} 
    public string sOtherNoofActiveSKUs {get;set;} 
    public string sOtherAnnualSales {get;set;} 
    public string sOtherAverageSalesPerOrder {get;set;} 
    public string sAmazonPercPositiveRatings12mos {get;set;} 
    public string sEbayPercPositiveRatings12mos {get;set;} 
    public string sOtherPercPositiveRatings12mos {get;set;} 


    public boolean bSellingFragrances{get;set;}
    public boolean bSellingLuxuryBrands{get;set;}
    public boolean bSellingMobile{get;set;}
    public boolean bSellingNA{get;set;}
    public boolean bSellingSoftware{get;set;}
    
    public map<string,string> mapIntegrationMethodIndirect;
    public map<string,string> mapSpecialitypartners;
    private map<Id,string> mapCategoryIdWiseName;
    public list<SelectOption> lstLeadSource{get;set;}
    public list<SelectOption> lstChannelPartner{get;set;}
    public boolean bUserAndLeadValidated{get;set;}
    private Id OtherCategoryId;
    
    public string sOldLeadId{get;set;}
    public string sOldApplicationlink{get;set;}
    public string sOldLeadEmail{get;set;}
    public boolean bEmailValidationError{get;set;}
    public boolean bEmailValidationUserError{get;set;}
    public boolean bEmailValidationLeadError{get;set;}
    public list<string> lstInvalidDBANames{get;set;}
    public BD2Controller(){
                    //system.debug('@developer -->start loading: '+ Datetime.now());
        currentstep = 0; //primary contact
        isApplicationCreated = false;
        isPartner = false;
        String PartnerID = ApexPages.currentPage().getParameters().get('id');
        if(PartnerID != null)
        {
            isPartner = true;
            List<Application__c> app = new List<Application__c>([Select id,(Select id from Attachments) from Application__c where Account__c =: PartnerID]);
            if(app != null && app.size() > 0 && app[0].Attachments != null && app[0].Attachments.size() > 0)
                attachmntid = app[0].Attachments[0].id;
        }
        bSameasprimary = false;
        String sToken = ApexPages.currentPage().getParameters().get('Token');
        bShippingUsps = false;
        bShippingUps = false;
        bShippingDhl = false;
        bShippingFba = false;
        bShippingFedex = false;
        bShippingOther = false;
        
        bIndependentSellerReviewsGoogleSites = false;
        bIndependentSellerReviewsApproved = false;
        bIndependentSellerReviewsRating = false;
        bIndependentSellerReviewsPilot = false;
        bIndependentSellerReviewsOther = false;


        bSellerTypeBrand = false ;
        bSellerTypeManufacturer = false;
        bSellerTypeRetailer = false;
        bSellerTypeDistributor = false;
        bSellerTypeLiquidator = false;
        bSellerTypeDropshipper = false;
        bSellerTypeImporter = false;
        bSellerTypeEtailer = false;

        bCurrentSellingRelationshipWalmartStores = false;
           bCurrentSellingRelationshipWalmartCom = false;
        bCurrentSellingRelationshipWalmartWalmartComDSV = false;
        bCurrentSellingRelationshipWalmartJetCom = false;
        bCurrentSellingRelationshipWalmartNone = false;

        //iPercentageOfSKUsWithUPCCodes = 0;
        //iPercentageOfSalesFromRefurbishedItems = 0;
        //iPercentageOfSalesFromUsedItems = 0 ;

        bSellingFragrances = false;
        bSellingLuxuryBrands = false;
        bSellingMobile = false;
        bSellingNA = false;
        bSellingSoftware = false;
                    
        if(sToken!=null){
            List<Application__c> lstApplication = [Select Lead__r.firstName,Lead__r.lastName,Lead__r.title,Lead__r.Email,Lead__r.TimeZone__c,Lead__r.Phone,Lead__r.MobilePhone,Lead__r.et4ae5__HasOptedOutOfMobile__c,Lead__r.Account_Legal_Name__c,Lead__r.Website,Lead__r.AnnualRevenue,Lead__r.Category__c,Lead__r.LeadSource,Lead__r.Channel__c,Lead__r.Extension__c, Lead__r.Id, Lead__c,Lead__r.Other_Lead_Source__c,Lead__r.Channel_Partner__c, Id, CurrentStep__c, Legal_Company_Name__c,Tax_ID__c,State_of_Incorporation__c,Year_Company_Founded__c,Legal_Address_Line_1__c,City_Town__c,Country__c,State_Province_Region__c,Postal_Zip_Code__c,X12months_sales_revenue_online_offline__c,X12_mo_YTD_sales_revenue__c,DBA_Name__c,Legal_Address_Line_2__c,Perc_SKUs_with_UPC_Code__c, Perc_sales_from_refurbished_items__c,Perc_Sales_from_Used_Items__c,Top_Selling_Brands__c,Top_Selling_Products__c,Top_Keyword_Searches__c,Own_Store_URL__c,Own_No_of_Active_SKUs__c,Own_Annual_Sales__c,Own_Average_Sales_Per_Order__c,Own_independent_reviews__c,Own_No_of_Years__c,Amazon_Store_URL__c,Amazon_Seller_Name__c, Amazon_No_of_Active_SKUs__c,Amazon_Annual_Sales__c,Amazon_Average_Sales_Per_Order__c,Amazon_No_of_Reviews_12_mos__c,Amazon_Perc_Positive_Ratings_12_mos__c,Amazon_No_of_Years__c,Ebay_Store_URL__c,Ebay_Seller_Name__c,Ebay_No_of_Active_SKUs__c,Ebay_Annual_Sales__c,Ebay_Average_Sales_Per_Order__c,Ebay_No_of_Reviews_12_mos__c, Ebay_Perc_Positive_Ratings_12_mos__c,Ebay_No_of_Years__c,Other_Store_URL__c,Other_Seller_Name__c,Other_No_of_Active_SKUs__c,Other_Annual_Sales__c,Other_Average_Sales_Per_Order__c,Other_No_of_Reviews_12_mos__c,Other_Perc_Positive_Ratings_12_mos__c,Other_No_of_Years__c,Other_Marketplace__c,Percentage_Drop_Ship__c,Perc_of_assortment_owned_v_drop__c, Amazon_Fulfillment_Perc__c,US_warehouse_address1__c,US_Warehouse_City__c,US_Warehouse_Zip__c,Business_days_to_pick_pack_ship__c,Current_Shipping_Methods__c,customer_support_availability__c,Customer_return_policy__c,current_selling_relationship_with_walmar__c,Preferred_integration_General__c,Preferred_integration_Specific__c,Preferred_integration_Specific_Id__c,SpecialitypartnerIds__c, US_Warehouse_Suite__c,Secondary_Contact_First_Name__c,Secondary_Contact_Last_Name__c,Secondary_Contact_Email__c,Secondary_Contact_Phone__c,Secondary_Contact_Mobile__c,Permission_to_text__c,Seller_Type__c,special_items_sold__c,US_Warehouse_State__c,Percentage_Owned__c, BusinessInformationCompleted__c,EcommerceCompleted__c,ProductAssortmentCompleted__c,OperationsCompleted__c,TechnicalContactCompleted__c,Amazon_Webstore_NA__c,Ebay_Webstore_NA__c,Other_Webstore_NA__c,Own_Webstore_NA__c,Same_as_Primary_Contact__c,Secondary_Contact_Ext__c,Application_Completed__c,SuggestedanewPartner__c, 
                    (Select Id, Category__c,Category_Annual_Revenue__c,Total_Number_of_SKU_s__c,No_of_SKU_s_to_be_sold_at_Walmart__c, Category_Type__c From ApplicationCategories__r) 
                    From Application__c Where id =:sToken];

            if(lstApplication!=null && lstApplication.size()>0){
                for(Application__c oTempApp:lstApplication){
                    oApplication = oTempApp;
                    //currentstep =  integer.valueOf(oApplication.CurrentStep__c);
                    currentstepsaved = currentstep;
                    oLead = oTempApp.Lead__r;
                    isApplicationCreated = true;
                    iPercentageOfSKUsWithUPCCodes = String.valueOf(Integer.valueOf(oTempApp.Perc_SKUs_with_UPC_Code__c));

                    iPercentageOfSalesFromRefurbishedItems = String.valueOf(Integer.valueOf(oTempApp.Perc_sales_from_refurbished_items__c));

                    iPercentageOfSalesFromUsedItems = String.valueOf(Integer.valueOf(oTempApp.Perc_Sales_from_Used_Items__c));

                    iAmazonFulfillmentPerc = String.valueOf(Integer.valueOf(oTempApp.Amazon_Fulfillment_Perc__c));

                    iSKUDropshippedPerc = String.valueOf(Integer.valueOf(oTempApp.Percentage_Drop_Ship__c));

                    iSKUOwnedPerc = String.valueOf(Integer.valueOf(oTempApp.Percentage_Owned__c));

                    sonlineoffline =  String.valueOf(Integer.valueOf(oTempApp.X12months_sales_revenue_online_offline__c));

                    sOwnNoofActiveSKUs                  =  String.valueOf(Integer.valueOf(oTempApp.Own_No_of_Active_SKUs__c)); 
                    sOwnAnnualSales                     =  String.valueOf(Integer.valueOf(oTempApp.Own_Annual_Sales__c)); 
                    sOwnAverageSalesPerOrder            =  String.valueOf(Integer.valueOf(oTempApp.Own_Average_Sales_Per_Order__c)); 
                    sAmazonNoofActiveSKUs               =  String.valueOf(Integer.valueOf(oTempApp.Amazon_No_of_Active_SKUs__c)); 
                    sAmazonAnnualSales                  =  String.valueOf(Integer.valueOf(oTempApp.Amazon_Annual_Sales__c)); 
                    sAmazonAverageSalesPerOrder         =  String.valueOf(Integer.valueOf(oTempApp.Amazon_Average_Sales_Per_Order__c)); 
                    sEbayNoofActiveSKUs                 =  String.valueOf(Integer.valueOf(oTempApp.Ebay_No_of_Active_SKUs__c)); 
                    sEbayAnnualSales                    =  String.valueOf(Integer.valueOf(oTempApp.Ebay_Annual_Sales__c)); 
                    sEbayAverageSalesPerOrder           =  String.valueOf(Integer.valueOf(oTempApp.Ebay_Average_Sales_Per_Order__c)); 
                    sOtherNoofActiveSKUs                =  String.valueOf(Integer.valueOf(oTempApp.Other_No_of_Active_SKUs__c)); 
                    sOtherAnnualSales                   =  String.valueOf(Integer.valueOf(oTempApp.Other_Annual_Sales__c)); 
                    sOtherAverageSalesPerOrder          =  String.valueOf(Integer.valueOf(oTempApp.Other_Average_Sales_Per_Order__c)); 
                    sAmazonPercPositiveRatings12mos     =  String.valueOf(Integer.valueOf(oTempApp.Amazon_Perc_Positive_Ratings_12_mos__c)); 
                    sEbayPercPositiveRatings12mos       =  String.valueOf(Integer.valueOf(oTempApp.Ebay_Perc_Positive_Ratings_12_mos__c)); 
                    sOtherPercPositiveRatings12mos      =  String.valueOf(Integer.valueOf(oTempApp.Other_Perc_Positive_Ratings_12_mos__c)); 

                    string sCurrentShippingMethods = oTempApp.Current_Shipping_Methods__c;
                    if(sCurrentShippingMethods!=null && sCurrentShippingMethods!=''){
                        list<string> lstShippingMethods = sCurrentShippingMethods.split(';');
                        for(string sMethod:lstShippingMethods){
                            if(sMethod=='UPS'){
                                bShippingUps = true;
                            }
                            else if(sMethod=='USPS'){
                                bShippingUsps = true;
                            }
                            else if(sMethod=='FBA'){
                                bShippingFba = true;
                            }
                            else if(sMethod=='FEDEX'){
                                bShippingFedex = true;
                            }
                            else if(sMethod=='DHL'){
                                bShippingDhl = true;
                            }
                            else if(sMethod=='Other'){
                                bShippingOther = true;
                            }
                        }
                    }
                    
                    string sIndependentSellerReviews = oTempApp.Own_independent_reviews__c;
                    if(sIndependentSellerReviews!=null && sIndependentSellerReviews!=''){
                        list<string> lstIndependentSellerReviews = sIndependentSellerReviews.split(';');
                        for(string sMethod:lstIndependentSellerReviews){
                            if(sMethod == 'Google Trusted Sites'){
                            bIndependentSellerReviewsGoogleSites = true;
                            }
                            else if(sMethod=='Shopper Approved'){
                                bIndependentSellerReviewsApproved = true;
                            }
                            else if(sMethod=='Reseller Ratings'){
                                bIndependentSellerReviewsRating = true;
                            }
                            else if(sMethod=='Trust Pilot'){
                                bIndependentSellerReviewsPilot = true;
                            }
                            else if(sMethod=='Other'){
                                bIndependentSellerReviewsOther = true;
                            }
                            
                        }
                    }
                    
                    
                    string sCurrentSellerType = oTempApp.Seller_Type__c;
                    if(sCurrentSellerType!=null && sCurrentSellerType!=''){
                        list<string> lstsCurrentSellerType = sCurrentSellerType.split(';');
                        for(string sMethod:lstsCurrentSellerType){
                            if(sMethod=='Brand'){
                                bSellerTypeBrand = true;
                            }
                            else if(sMethod=='Manufacturer'){
                                bSellerTypeManufacturer = true;
                            }
                            else if(sMethod=='Retailer'){
                                bSellerTypeRetailer = true;
                            }
                            else if(sMethod=='Distributor'){
                                bSellerTypeDistributor = true;
                            }
                            else if(sMethod=='Liquidator'){
                                bSellerTypeLiquidator = true;
                            }
                            else if(sMethod=='Drop-shipper'){
                                bSellerTypeDropshipper = true;
                            }
                                else if(sMethod=='Importer'){
                                bSellerTypeImporter = true;
                            }
                                else if(sMethod=='Etailer(pure play)'){
                                bSellerTypeEtailer = true;
                            }
                        }
                    }
                    
                    string sCurrentSellingRelationship = oTempApp.current_selling_relationship_with_walmar__c;
                    if(sCurrentSellingRelationship != null && sCurrentSellingRelationship != ''){
                        list<string> lstsCurrentsSellingRelationship = sCurrentSellingRelationship.split(';');
                        for(string sMethod:lstsCurrentsSellingRelationship){
                            if(sMethod=='Walmart Stores'){
                                bCurrentSellingRelationshipWalmartStores = true;
                            }
                            else if(sMethod=='Walmart.com Supplier'){
                                bCurrentSellingRelationshipWalmartCom = true;
                            }
                            else if(sMethod=='Walmart.com DSV'){
                                bCurrentSellingRelationshipWalmartWalmartComDSV = true;
                            }
                            else if(sMethod=='Walmart.com DSV'){
                                bCurrentSellingRelationshipWalmartWalmartComDSV = true;
                            }
                            else if(sMethod=='Jet.com'){
                                bCurrentSellingRelationshipWalmartJetCom = true;
                            }
                            else if(sMethod=='None'){
                                bCurrentSellingRelationshipWalmartNone = true;
                            }
                        }
                    }
                    
                    string sSellingSpecial = oTempApp.special_items_sold__c;
                    if(sSellingSpecial!=null && sSellingSpecial!=''){
                        list<string> lstSellingSpecial = sSellingSpecial.split(';');
                        for(string sSelling:lstSellingSpecial){
                            if(sSelling=='Fragrances'){
                                bSellingFragrances = true;
                            }
                            else if(sSelling=='Luxury Brands'){
                                bSellingLuxuryBrands = true;
                            }
                            else if(sSelling=='Cell Phones & Accessories'){
                                bSellingMobile = true;
                            }
                            else if(sSelling == 'Software'){
                                bSellingSoftware = true;
                            }
                            else if(sSelling=='NA'){
                                bSellingNA = true;
                            }
                        }
                    }
                    
                    
                    
                    if(oTempApp.ApplicationCategories__r!=null ){
                        for(ApplicationCategories__c oApplicationCategories:oTempApp.ApplicationCategories__r){
                            if(oApplicationCategories.Category_Type__c=='Primary'){
                                oPrimaryCategory = oApplicationCategories;
                            }
                            else if(oApplicationCategories.Category_Type__c=='Secondary'){
                                oSecondaryCategory = oApplicationCategories;
                            }
                            else if(oApplicationCategories.Category_Type__c=='Tertiary'){
                                oTertiaryCategory = oApplicationCategories;
                            }
                            else if(oApplicationCategories.Category_Type__c=='Other'){
                                oOtherCategory = oApplicationCategories;
                            }
                        }
                    }
                }
            } 
         else{
            //invalid token.
         }   
            
        }
        
        //query the value of current step from application. new value cannot be less than current value
        if(oLead==null){
            oLead = new Lead();
            oLead.Channel_Partner__c = PartnerID;
            oLead.LeadSource = 'Solution Providers';
        }
        if(oApplication==null){
            oApplication = new Application__c();
            oApplication.customer_support_availability__c = 'Yes';
        }
        SetCurrentStep();
        mapCategoryIdWiseName = new map<Id,string>();
        
        lstPrimaryCategory = new list<SelectOption>();
        lstSecondaryCategory = new list<SelectOption>();
        lstTertiaryCategory = new list<SelectOption>();
        SelectOption oSelectOption = new SelectOption('','--None--');
        lstPrimaryCategory.add(oSelectOption);
        lstSecondaryCategory.add(oSelectOption);
        lstTertiaryCategory.add(oSelectOption);
        
        for(Category__c oCategory:[Select Id,Name from Category__c Where Active__c = true order by Name]){
            if(oCategory.Name=='All Others'){
                OtherCategoryId = oCategory.Id;
            }
            else{
                lstPrimaryCategory.add(new SelectOption(oCategory.Id,oCategory.Name));
                lstSecondaryCategory.add(new SelectOption(oCategory.Id,oCategory.Name));
                lstTertiaryCategory.add(new SelectOption(oCategory.Id,oCategory.Name));
            }
            mapCategoryIdWiseName.put(oCategory.Id,oCategory.Name);
        }
        
        if(oPrimaryCategory==null){
            oPrimaryCategory = new ApplicationCategories__c();
        }
        if(oSecondaryCategory==null){
            oSecondaryCategory = new ApplicationCategories__c();
        }
        if(oTertiaryCategory==null){
            oTertiaryCategory = new ApplicationCategories__c();
        }
        if(oOtherCategory==null){
            oOtherCategory = new ApplicationCategories__c();
        }
        
        lstLeadSource = new List<SelectOption>();
        lstLeadSource.add(new SelectOption('','--None--'));
        lstLeadSource.add(new SelectOption('Article, Blog ','Article, Blog'));
        lstLeadSource.add(new SelectOption('Podcast','Podcast'));
        lstLeadSource.add(new SelectOption('Referral - Jet','Referral - Jet'));
        lstLeadSource.add(new SelectOption('Referral - Seller','Referral - Seller'));
        lstLeadSource.add(new SelectOption('Referral - Walmart','Referral - Walmart'));
        lstLeadSource.add(new SelectOption('Retailer Forum','Retailer Forum'));
        lstLeadSource.add(new SelectOption('Search Engine/Google','Search Engine/Google'));
        lstLeadSource.add(new SelectOption('Social Media','Social Media'));
        lstLeadSource.add(new SelectOption('Solution Providers','Solution Providers'));
        lstLeadSource.add(new SelectOption('Trade Associations','Trade Associations'));
        lstLeadSource.add(new SelectOption('Trade Shows - Catalyst','Trade Shows - Catalyst'));
        lstLeadSource.add(new SelectOption('Trade Shows - IRCE','Trade Shows - IRCE'));
        lstLeadSource.add(new SelectOption('Trade Shows - Shoptalk','Trade Shows - Shoptalk'));
        lstLeadSource.add(new SelectOption('Walmart.com Supplier Website','Walmart.com Supplier Website'));
        lstLeadSource.add(new SelectOption('Walmart Business Development','Walmart Business Development')); 
        lstLeadSource.add(new SelectOption('Other','Other'));

        lstChannelPartner = new List<SelectOption>();
        lstChannelPartner.add(new SelectOption('','--None--'));
        //Channel_Partner__c
        for(Account oAccount :[Select Id,RecordTypeId, Name From Account Where RecordType.DeveloperName='Partner_Account' and Type='Channel Partner']){
            lstChannelPartner.add(new SelectOption(oAccount.Id,oAccount.Name));
        }
        
        lstInvalidDBANames = new list<string>();
        for(DBAValidationSetting__c oDBAValidationSetting :DBAValidationSetting__c.getAll().values()){
          if(oDBAValidationSetting.IsActive__c){
            string sContent = oDBAValidationSetting.Content__c;
            if(sContent!=null && sContent!=''){
              sContent = sContent.toLowerCase();
            }
            lstInvalidDBANames.add(sContent);
          }
        }
        //system.debug('@developer -->load complete: '+ Datetime.now());
    }
    
    public PageReference CheckSubmission(){
        if(oApplication.Application_Completed__c){
            String pref = site.getPathPrefix();
            if(pref ==null ||pref==''){
                pref = '/apex';
            }
            return new pagereference(pref+'/MarketplaceApplicationSubmitted');
        }
        return null;
    }
    
    public PageReference CreateUpdateApplication(){
        if(currentstep==0){
            return createNewLead();
        }
        else if(currentstep==1){
            return createNewApplication();
        }
        else if(currentstep==2){
            return updateproductassortment();
        }
        else if(currentstep==3){
            return updateecommerce();
        }
        else if(currentstep==4){
            return updateoperations();
        }
        else if(currentstep==5){
            return updatetechnicalcontact();
        }
        return null;
    }
    /*public List<IntegrationMethodWrapper> fetchIntegrationMethods(string sSelectedIntegrationChannel){
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
        else if((sSelectedIntegrationChannel=='Partner')||(sSelectedIntegrationChannel=='Channel Aggregator')){
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
    }*/
    
    public list<SelectOption> getIndirectIntegrationMethod(){
        System.debug('@Developer --> getIndirectIntegrationMethod :');
        mapIntegrationMethodIndirect = new map<string,string>();
        list<SelectOption> lstOption = new list<SelectOption>();
        lstOption.add(new SelectOption('','- Please Select -'));
        for(IntegrationMethodWrapper imw : fetchIntegrationMethods('Partner')){
            lstOption.add(new SelectOption(imw.Id,imw.Name));
            mapIntegrationMethodIndirect.put(imw.Id,imw.Name);
        }
        return lstOption;
    }
    
    public list<SelectOption> getDirectIntegrationMethod(){
        System.debug('@Developer --> getDirectIntegrationMethod :');
        list<SelectOption> lstOption = new list<SelectOption>();
        lstOption.add(new SelectOption('','- Please Select -'));
        for(IntegrationMethodWrapper imw : fetchIntegrationMethods('Direct')){
            lstOption.add(new SelectOption(imw.Name,imw.Name));
        }
        return lstOption;
    }
    
    public list<SelectOption> getSpecialitypartnersList(){
        List<SelectOption> lstSpecialitypartners = new List<SelectOption>();
        mapSpecialitypartners = new map<string,string>();
        //lstSpecialitypartners.add(new SelectOption('','--None--'));
        for(Account oAccount : [Select Id,Name From Account Where RecordType.DeveloperName ='Partner_Account' and Partner_Type__c='Specialty Partner' and (Partner_Onboarding_Status__c = 'Live' or Partner_Onboarding_Status__c = 'Pilot')]){
                        lstSpecialitypartners.add(new SelectOption(oAccount.Id,oAccount.Name));
                        mapSpecialitypartners.put(oAccount.Id,oAccount.Name);
                        System.debug('@Developer --> oAccount.Id :'+oAccount.Id+',oAccount.Name:'+oAccount.Name);
        }
        return lstSpecialitypartners;
    }
    
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
        else if((sSelectedIntegrationChannel=='Partner')||(sSelectedIntegrationChannel=='Channel Aggregator')){
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
    
    private void SetCurrentStep(){
        integer nTempStep = GetCurrentStep(currentstep);
        if(nTempStep==-1){
            nTempStep = GetCurrentStep(-1);
        }
        if(nTempStep!=-1){
            currentstep = nTempStep;
        }
    }
    private integer GetCurrentStep(integer nCurrentStep){
        integer nTempStep = -1;
        if(oApplication.Id == null){
            nTempStep = 0;
        }
        else if(nCurrentStep<1 && oApplication.BusinessInformationCompleted__c!=true){
            nTempStep = 1 ;
        }
        else if(nCurrentStep<2 && oApplication.ProductAssortmentCompleted__c != true){
            nTempStep = 2;
        }
        else if(nCurrentStep<3 && oApplication.EcommerceCompleted__c != true){
            nTempStep = 3;
        }
        else if(nCurrentStep<4 && oApplication.OperationsCompleted__c != true){
            nTempStep = 4;
        }
        else if(nCurrentStep<5 && oApplication.TechnicalContactCompleted__c != true){
            nTempStep = 5;
        }
        
        return nTempStep;
    }
    
    public PageReference redirecttohome() {
        return new PageReference('https://marketplace.walmart.com/');
    }
    
    public PageReference redirecttologin() {
        return new PageReference('https://seller.walmart.com');
    }
    
    public PageReference createNewLead() {
        system.debug('@developer -->createNewLead : '+ Date.today());
        if(bUserAndLeadValidated == false){
         return null;
        }
        if(oApplication.CurrentStep__c==null || oApplication.CurrentStep__c<1){
            oApplication.CurrentStep__c = 1;
        }
        
        if(oLead.Id==null){
             Id idMpRecordType;     
            for(recordtype rt:[select id,developername from recordtype where sobjecttype='Lead' and developername='MP_Lead' limit 1]){      
            idMpRecordType = rt.Id;     
            }
            oLead.recordTypeId = idMpRecordType;
            oLead.Company = oLead.Account_Legal_Name__c;
            oLead.Webtolead__c = true;
            //system.debug('@developer -->createNewLead before insert lead: '+ Datetime.now());
            insert oLead;
            //system.debug('@developer -->createNewLead after insert lead: '+ Datetime.now());
            if(oApplication.Id==null){
                if(oLead.Id!=null){
                    oApplication.Lead__c = oLead.Id;
                    oApplication.Primary_Contact_Email__c = oLead.Email;
                    oApplication.Primary_Contact_First_Name__c = oLead.FirstName;
                    oApplication.Primary_Contact_Last_Name__c = oLead.LastName;
                    oApplication.Legal_Company_Name__c = oLead.Company;
                    oApplication.Primary_Contact_Title__c = oLead.title;
                    oApplication.Primary_Contact_Phone__c = oLead.Phone;
                    oApplication.Primary_Contact_Phone_Extension__c = oLead.Extension__c;
                    oApplication.Primary_Contact_Mobile_Phone__c = oLead.MobilePhone;
                    oApplication.Website__c = oLead.Website;
                    oApplication.X12_mo_YTD_sales_revenue__c = oLead.AnnualRevenue;
                    if(oLead.et4ae5__HasOptedOutOfMobile__c){
                        oApplication.Do_you_give_us_permission_to_text__c = 'Yes';
                    }
                    else{
                        oApplication.Do_you_give_us_permission_to_text__c = 'No';
                    }
                    oApplication.How_did_you_hear_about_Marketplace__c = oLead.LeadSource;
                    oApplication.Country__c = 'United States';
                    
                }
                //system.debug('@developer -->createNewLead before insert application: '+ Datetime.now());
                insert oApplication;
                //system.debug('@developer -->createNewLead after insert application: '+ Datetime.now());
            }
            else{
                update oApplication;
            }
            SetCurrentStep();
            system.debug('@developer -->currentstep : '+ currentstep);
            system.debug('@developer -->oApplication.Id : '+ oApplication.Id);
        }
        isApplicationCreated = true;
        return null;
        }
        public PageReference createNewApplication() {
            system.debug('..11.. '+oApplication);
            
            if(sonlineoffline!=null && sonlineoffline!=''){
                sonlineoffline = sonlineoffline.replace('$','');
                sonlineoffline = sonlineoffline.replaceAll(',','');
            }
            
            oApplication.X12months_sales_revenue_online_offline__c = long.valueOf(sonlineoffline);
            string sSellerType = '';
            if(bSellerTypeBrand){
                if(sSellerType!=''){
                    sSellerType+=';';
                }
                sSellerType+='Brand';
            }
            
            if(bSellerTypeManufacturer){
                if(sSellerType!=''){
                    sSellerType+=';';
                }
                sSellerType+='Manufacturer';
            }
            
            if(bSellerTypeRetailer){
                if(sSellerType!=''){
                    sSellerType+=';';
                }
                sSellerType+='Retailer';
            }
            
            if(bSellerTypeDistributor){
                if(sSellerType!=''){
                    sSellerType+=';';
                }
                sSellerType+='Distributor';
            }
            
            if(bSellerTypeLiquidator){
                if(sSellerType!=''){
                    sSellerType+=';';
                }
                sSellerType+='Liquidator';
            }
            
            if(bSellerTypeDropshipper){
                if(sSellerType!=''){
                    sSellerType+=';';
                }
                sSellerType+='Drop-shipper';
            }
            if(bSellerTypeImporter){
                if(sSellerType!=''){
                    sSellerType+=';';
                }
                sSellerType+='Importer';
            }
            if(bSellerTypeEtailer){
                if(sSellerType!=''){
                    sSellerType+=';';
                }
                sSellerType+='Etailer(pure play)';
            }
           oApplication.Seller_Type__c = sSellerType;
            if(oApplication.Id!=null){
                oApplication.BusinessInformationCompleted__c = true;
                update oApplication;
                SetCurrentStep();
            }
            
            return null;
        }
          
        public PageReference updateproductassortment() {
            system.debug('..11.. '+oApplication);
            if(oApplication.Id!=null){
                oApplication.ProductAssortmentCompleted__c = true;
                iPercentageOfSKUsWithUPCCodes = iPercentageOfSKUsWithUPCCodes.replace('%',''); 
                oApplication.Perc_SKUs_with_UPC_Code__c = Integer.valueOf(iPercentageOfSKUsWithUPCCodes) ;
                
                iPercentageOfSalesFromRefurbishedItems = iPercentageOfSalesFromRefurbishedItems.replace('%','');
                oApplication.Perc_sales_from_refurbished_items__c = Integer.valueOf(iPercentageOfSalesFromRefurbishedItems) ;
              
                iPercentageOfSalesFromUsedItems = iPercentageOfSalesFromUsedItems.replace('%','');
                oApplication.Perc_Sales_from_Used_Items__c = Integer.valueOf(iPercentageOfSalesFromUsedItems) ;
                string sSelling = '';
                if(bSellingFragrances){
                    if(sSelling!=''){
                        sSelling+=';';
                    }
                    sSelling+='Fragrances';
                }
                if(bSellingLuxuryBrands){
                    if(sSelling!=''){
                        sSelling+=';';
                    }
                    sSelling+='Luxury Brands';
                }
                if(bSellingMobile){
                    if(sSelling!=''){
                        sSelling+=';';
                    }
                    sSelling+='Cell Phones & Accessories';
                }
                if(bSellingNA){
                    if(sSelling!=''){
                        sSelling+=';';
                    }
                    sSelling+='NA';
                }
                if(bSellingSoftware){
                    if(sSelling!=''){
                        sSelling+=';';
                    }
                    sSelling+='Software';
                }
                
                oApplication.special_items_sold__c = sSelling;
                //Top_Category__c
                
                string sTopCategoryName = '';
                if(oPrimaryCategory.Category__c!=null){
                    if(mapCategoryIdWiseName.containsKey(oPrimaryCategory.Category__c)){
                        sTopCategoryName = mapCategoryIdWiseName.get(oPrimaryCategory.Category__c);
                    }
                }
                oApplication.Top_Category__c = sTopCategoryName;
                
                update oApplication;
                //currentstep = 3;//ecommerce
                decimal nTotalRevenue = 0;
                if(oPrimaryCategory.Category__c!=null){
                    nTotalRevenue +=(oPrimaryCategory.Category_Annual_Revenue__c!=null)?oPrimaryCategory.Category_Annual_Revenue__c:0;
                }
                if(oSecondaryCategory.Category__c!=null){
                    nTotalRevenue +=(oSecondaryCategory.Category_Annual_Revenue__c!=null)?oSecondaryCategory.Category_Annual_Revenue__c:0;
                }
                if(oTertiaryCategory.Category__c!=null){
                    nTotalRevenue +=(oTertiaryCategory.Category_Annual_Revenue__c!=null)?oTertiaryCategory.Category_Annual_Revenue__c:0;
                }
                if(oOtherCategory.Category_Annual_Revenue__c!=null){
                    nTotalRevenue +=oOtherCategory.Category_Annual_Revenue__c;
                }
                //Percentage_of_Annual_Sales__c
                 
                if(oPrimaryCategory.Category__c!=null){
                    oPrimaryCategory.Application__c = oApplication.Id;
                    oPrimaryCategory.Category_Type__c= 'Primary';
                    decimal nPercent = 0;
                    if(nTotalRevenue>0 && oPrimaryCategory.Category_Annual_Revenue__c!=null){
                        nPercent = (oPrimaryCategory.Category_Annual_Revenue__c / nTotalRevenue) * 100;
                    }
                    oPrimaryCategory.Percentage_of_Annual_Sales__c = nPercent;
                    if(oPrimaryCategory.Id==null){
                        insert oPrimaryCategory;
                    }
                    else{
                        update oPrimaryCategory;
                    }
                }
                if(oSecondaryCategory.Category__c!=null){
                    oSecondaryCategory.Application__c = oApplication.Id;
                    oSecondaryCategory.Category_Type__c= 'Secondary';
                    decimal nPercent = 0;
                    if(nTotalRevenue>0 && oSecondaryCategory.Category_Annual_Revenue__c!=null){
                        nPercent = (oSecondaryCategory.Category_Annual_Revenue__c / nTotalRevenue) * 100;
                    }
                    oSecondaryCategory.Percentage_of_Annual_Sales__c = nPercent;
                    if(oSecondaryCategory.Id==null){
                        insert oSecondaryCategory;
                    }
                    else{
                        update oSecondaryCategory;
                    }
                }
                if(oTertiaryCategory.Category__c!=null){
                    oTertiaryCategory.Application__c = oApplication.Id;
                    oTertiaryCategory.Category_Type__c= 'Tertiary';
                    decimal nPercent = 0;
                    if(nTotalRevenue>0 && oTertiaryCategory.Category_Annual_Revenue__c!=null){
                        nPercent = (oTertiaryCategory.Category_Annual_Revenue__c / nTotalRevenue) * 100;
                    }
                    oTertiaryCategory.Percentage_of_Annual_Sales__c = nPercent;
                    if(oTertiaryCategory.Id==null){
                        insert oTertiaryCategory;
                    }
                    else{
                        update oTertiaryCategory;
                    }
                }
                
                decimal othercatAnnualRev = (oOtherCategory.Category_Annual_Revenue__c!=null)?oOtherCategory.Category_Annual_Revenue__c:0;
                decimal othercatNoofSKU = (oOtherCategory.No_of_SKU_s_to_be_sold_at_Walmart__c!=null)?oOtherCategory.No_of_SKU_s_to_be_sold_at_Walmart__c:0;
                decimal othercattotalsku = (oOtherCategory.Total_Number_of_SKU_s__c!=null)?oOtherCategory.Total_Number_of_SKU_s__c:0;
                
                if(othercatAnnualRev > 0 || othercatNoofSKU > 0|| othercattotalsku > 0){
                    oOtherCategory.Application__c = oApplication.Id;
                    oOtherCategory.Category_Type__c= 'Other';
                    decimal nPercent = 0;
                    if(nTotalRevenue>0 && oOtherCategory.Category_Annual_Revenue__c!=null){
                        nPercent = (oOtherCategory.Category_Annual_Revenue__c / nTotalRevenue) * 100;
                    }
                    oOtherCategory.Percentage_of_Annual_Sales__c = nPercent;
                    if(OtherCategoryId!=null){
                        oOtherCategory.Category__c = OtherCategoryId;
                    }
                    if(oOtherCategory.Id==null){
                        insert oOtherCategory;
                    }
                    else{
                        update oOtherCategory;
                    }
                }
                SetCurrentStep();
            }
            
            return null;
          }
          
    public PageReference updateecommerce() {
        system.debug('..11.. '+oApplication);

        string sSellerReviews ='';

        if(bIndependentSellerReviewsGoogleSites){
            if(sSellerReviews!=''){
                sSellerReviews+=';';
            }
            sSellerReviews+='Google Trusted Sites';
        }

        if(bIndependentSellerReviewsApproved){
            if(sSellerReviews!=''){
                sSellerReviews+=';';
            }
            sSellerReviews+='Shopper Approved';
        }

        if(bIndependentSellerReviewsRating){
            if(sSellerReviews!=''){
                sSellerReviews+=';';
            }
            sSellerReviews+='Reseller Ratings';
        }

        if(bIndependentSellerReviewsPilot){
            if(sSellerReviews!=''){
                sSellerReviews+=';';
            }
            sSellerReviews+='Trust Pilot';
        }

        if(bIndependentSellerReviewsOther){
            if(sSellerReviews!=''){
                sSellerReviews+=';';
            }
            sSellerReviews+='Other';
        }

        oApplication.Own_independent_reviews__c = sSellerReviews;

        if(sOwnNoofActiveSKUs!=null && sOwnNoofActiveSKUs!=''){
         sOwnNoofActiveSKUs = sOwnNoofActiveSKUs.replace('$','');
            sOwnNoofActiveSKUs = sOwnNoofActiveSKUs.replace('%','');
            sOwnNoofActiveSKUs = sOwnNoofActiveSKUs.replaceAll(',','');
        }

        if(sOwnAnnualSales!=null && sOwnAnnualSales!=''){
         sOwnAnnualSales = sOwnAnnualSales.replace('$','');
            sOwnAnnualSales = sOwnAnnualSales.replace('%','');
            sOwnAnnualSales = sOwnAnnualSales.replaceAll(',','');
        }

        if(sOwnAverageSalesPerOrder!=null && sOwnAverageSalesPerOrder!=''){
         sOwnAverageSalesPerOrder = sOwnAverageSalesPerOrder.replace('$','');
            sOwnAverageSalesPerOrder = sOwnAverageSalesPerOrder.replace('%','');
            sOwnAverageSalesPerOrder = sOwnAverageSalesPerOrder.replaceAll(',','');
        }

        if(sAmazonNoofActiveSKUs!=null && sAmazonNoofActiveSKUs!=''){
         sAmazonNoofActiveSKUs = sAmazonNoofActiveSKUs.replace('$','');
            sAmazonNoofActiveSKUs = sAmazonNoofActiveSKUs.replace('%','');
            sAmazonNoofActiveSKUs = sAmazonNoofActiveSKUs.replaceAll(',','');
        }

        if(sAmazonAnnualSales!=null && sAmazonAnnualSales!=''){
         sAmazonAnnualSales = sAmazonAnnualSales.replace('$','');
            sAmazonAnnualSales = sAmazonAnnualSales.replace('%','');
            sAmazonAnnualSales = sAmazonAnnualSales.replaceAll(',','');
        }

        if(sAmazonAverageSalesPerOrder!=null && sAmazonAverageSalesPerOrder!=''){
         sAmazonAverageSalesPerOrder = sAmazonAverageSalesPerOrder.replace('$','');
            sAmazonAverageSalesPerOrder = sAmazonAverageSalesPerOrder.replace('%','');
            sAmazonAverageSalesPerOrder = sAmazonAverageSalesPerOrder.replaceAll(',','');
        }

        if(sEbayNoofActiveSKUs!=null && sEbayNoofActiveSKUs!=''){
         sEbayNoofActiveSKUs = sEbayNoofActiveSKUs.replace('$','');
            sEbayNoofActiveSKUs = sEbayNoofActiveSKUs.replace('%','');
            sEbayNoofActiveSKUs = sEbayNoofActiveSKUs.replaceAll(',','');
        }

        if(sEbayAnnualSales!=null && sEbayAnnualSales!=''){
         sEbayAnnualSales = sEbayAnnualSales.replace('$','');
            sEbayAnnualSales = sEbayAnnualSales.replace('%','');
            sEbayAnnualSales = sEbayAnnualSales.replaceAll(',','');
        }

        if(sEbayAverageSalesPerOrder!=null && sEbayAverageSalesPerOrder!=''){
         sEbayAverageSalesPerOrder = sEbayAverageSalesPerOrder.replace('$','');
            sEbayAverageSalesPerOrder = sEbayAverageSalesPerOrder.replace('%','');
            sEbayAverageSalesPerOrder = sEbayAverageSalesPerOrder.replaceAll(',','');
        }

        if(sOtherNoofActiveSKUs!=null && sOtherNoofActiveSKUs!=''){
         sOtherNoofActiveSKUs = sOtherNoofActiveSKUs.replace('$','');
            sOtherNoofActiveSKUs = sOtherNoofActiveSKUs.replace('%','');
            sOtherNoofActiveSKUs = sOtherNoofActiveSKUs.replaceAll(',','');
        }

        if(sOtherAnnualSales!=null && sOtherAnnualSales!=''){
         sOtherAnnualSales = sOtherAnnualSales.replace('$','');
            sOtherAnnualSales = sOtherAnnualSales.replace('%','');
            sOtherAnnualSales = sOtherAnnualSales.replaceAll(',','');
        }

        if(sOtherAverageSalesPerOrder!=null && sOtherAverageSalesPerOrder!=''){
         sOtherAverageSalesPerOrder = sOtherAverageSalesPerOrder.replace('$','');
            sOtherAverageSalesPerOrder = sOtherAverageSalesPerOrder.replace('%','');
            sOtherAverageSalesPerOrder = sOtherAverageSalesPerOrder.replaceAll(',','');
        }

        if(sAmazonPercPositiveRatings12mos!=null && sAmazonPercPositiveRatings12mos!=''){
         sAmazonPercPositiveRatings12mos = sAmazonPercPositiveRatings12mos.replace('$','');
            sAmazonPercPositiveRatings12mos = sAmazonPercPositiveRatings12mos.replace('%','');
            sAmazonPercPositiveRatings12mos = sAmazonPercPositiveRatings12mos.replaceAll(',','');
        }

        if(sEbayPercPositiveRatings12mos!=null && sEbayPercPositiveRatings12mos!=''){
         sEbayPercPositiveRatings12mos = sEbayPercPositiveRatings12mos.replace('$','');
            sEbayPercPositiveRatings12mos = sEbayPercPositiveRatings12mos.replace('%','');
            sEbayPercPositiveRatings12mos = sEbayPercPositiveRatings12mos.replaceAll(',','');
        }

        if(sOtherPercPositiveRatings12mos!=null && sOtherPercPositiveRatings12mos!=''){
         sOtherPercPositiveRatings12mos = sOtherPercPositiveRatings12mos.replace('$','');
            sOtherPercPositiveRatings12mos = sOtherPercPositiveRatings12mos.replace('%','');
            sOtherPercPositiveRatings12mos = sOtherPercPositiveRatings12mos.replaceAll(',','');
        }

        oApplication.Own_No_of_Active_SKUs__c                  = Integer.valueOf(sOwnNoofActiveSKUs);
        oApplication.Own_Annual_Sales__c                       = Integer.valueOf(sOwnAnnualSales);
        oApplication.Own_Average_Sales_Per_Order__c            = Integer.valueOf(sOwnAverageSalesPerOrder);
        oApplication.Amazon_No_of_Active_SKUs__c               = Integer.valueOf(sAmazonNoofActiveSKUs);
        oApplication.Amazon_Annual_Sales__c                    = Integer.valueOf(sAmazonAnnualSales);
        oApplication.Amazon_Average_Sales_Per_Order__c         = Integer.valueOf(sAmazonAverageSalesPerOrder);
        oApplication.Ebay_No_of_Active_SKUs__c                 = Integer.valueOf(sEbayNoofActiveSKUs);
        oApplication.Ebay_Annual_Sales__c                      = Integer.valueOf(sEbayAnnualSales);
        oApplication.Ebay_Average_Sales_Per_Order__c           = Integer.valueOf(sEbayAverageSalesPerOrder);
        oApplication.Other_No_of_Active_SKUs__c                = Integer.valueOf(sOtherNoofActiveSKUs);
        oApplication.Other_Annual_Sales__c                     = Integer.valueOf(sOtherAnnualSales);
        oApplication.Other_Average_Sales_Per_Order__c          = Integer.valueOf(sOtherAverageSalesPerOrder);
        oApplication.Amazon_Perc_Positive_Ratings_12_mos__c    = Integer.valueOf(sAmazonPercPositiveRatings12mos);
        oApplication.Ebay_Perc_Positive_Ratings_12_mos__c      = Integer.valueOf(sEbayPercPositiveRatings12mos);
        oApplication.Other_Perc_Positive_Ratings_12_mos__c     = Integer.valueOf(sOtherPercPositiveRatings12mos);

        if(oApplication.Id!=null){
            oApplication.EcommerceCompleted__c = true;
            update oApplication;
            //currentstep = 4;//operations
            SetCurrentStep();
        }
        return null;
    }
          
    public PageReference updateoperations() {
        system.debug('@developer --> updateoperations oApplication:'+oApplication);

        string sShippingMethods='';
        if(bShippingUps){
            if(sShippingMethods!=''){
                sShippingMethods+=';';
            }
            sShippingMethods+='UPS';
        }

        if(bShippingUsps){
            if(sShippingMethods!=''){
                sShippingMethods+=';';
            }
            sShippingMethods+='USPS';
        }

        if(bShippingFba){
            if(sShippingMethods!=''){
                sShippingMethods+=';';
            }
            sShippingMethods+='FBA';
        }

        if(bShippingFedex){
            if(sShippingMethods!=''){
                sShippingMethods+=';';
            }
            sShippingMethods+='FEDEX';
        }

        if(bShippingDhl){
            if(sShippingMethods!=''){
                sShippingMethods+=';';
            }
            sShippingMethods+='DHL';
        }

        if(bShippingOther){
            if(sShippingMethods!=''){
                sShippingMethods+=';';
            }
            sShippingMethods+='Other';
        }

        string sSellingRelationshipWalmartStores = '';
        if(bCurrentSellingRelationshipWalmartStores){
            if(sSellingRelationshipWalmartStores!=''){
                sSellingRelationshipWalmartStores+=';';
            }
            sSellingRelationshipWalmartStores+='Walmart Stores';
        }

        if(bCurrentSellingRelationshipWalmartCom){
            if(sSellingRelationshipWalmartStores!=''){
                sSellingRelationshipWalmartStores+=';';
            }
            sSellingRelationshipWalmartStores+='Walmart.com Supplier';
        }

        if(bCurrentSellingRelationshipWalmartWalmartComDSV){
            if(sSellingRelationshipWalmartStores!=''){
                sSellingRelationshipWalmartStores+=';';
            }
            sSellingRelationshipWalmartStores+='Walmart.com DSV';
        }

        if(bCurrentSellingRelationshipWalmartJetCom){
            if(sSellingRelationshipWalmartStores!=''){
                sSellingRelationshipWalmartStores+=';';
            }
            sSellingRelationshipWalmartStores+='Jet.com';
        }

        if(bCurrentSellingRelationshipWalmartNone){
            if(sSellingRelationshipWalmartStores!=''){
                sSellingRelationshipWalmartStores+=';';
            }
            sSellingRelationshipWalmartStores+='None';
        }

        oApplication.current_selling_relationship_with_walmar__c = sSellingRelationshipWalmartStores;
        oApplication.Current_Shipping_Methods__c = sShippingMethods;

        iAmazonFulfillmentPerc = iAmazonFulfillmentPerc.replace('%',''); 
        oApplication.Amazon_Fulfillment_Perc__c = Integer.valueOf(iAmazonFulfillmentPerc);

        iSKUDropshippedPerc = iSKUDropshippedPerc.replace('%',''); 
        oApplication.Percentage_Drop_Ship__c= Integer.valueOf(iSKUDropshippedPerc);

        iSKUOwnedPerc = iSKUOwnedPerc.replace('%','');
        oApplication.Percentage_Owned__c  = Integer.valueOf(iSKUOwnedPerc);


        System.debug('@Developer --> oApplication.SpecialitypartnerIds__c :'+oApplication.SpecialitypartnerIds__c);
        if(oApplication.Preferred_integration_General__c!=null && oApplication.Preferred_integration_General__c=='Partner'){
            if(oApplication.Preferred_integration_Specific_Id__c!=null && mapIntegrationMethodIndirect.containsKey(oApplication.Preferred_integration_Specific_Id__c)){
                oApplication.Preferred_integration_Specific__c = mapIntegrationMethodIndirect.get(oApplication.Preferred_integration_Specific_Id__c);
            }
        }
        else{
            oApplication.Preferred_integration_Specific_Id__c = null;
        }
        string sSpecialitypartnerNames;
        if(oApplication.SpecialitypartnerIds__c!=null && oApplication.SpecialitypartnerIds__c!=''){
            if(oApplication.SpecialitypartnerIds__c.startsWith('[')){
                                                        oApplication.SpecialitypartnerIds__c = oApplication.SpecialitypartnerIds__c.substring(1);
                                                }
            if(oApplication.SpecialitypartnerIds__c.endsWith(']')){
                                                        oApplication.SpecialitypartnerIds__c = oApplication.SpecialitypartnerIds__c.left(oApplication.SpecialitypartnerIds__c.length()-1);
                                                }
            oApplication.SpecialitypartnerIds__c =oApplication.SpecialitypartnerIds__c.replace(' ','');
                                                for(string sId : oApplication.SpecialitypartnerIds__c.split(',')){
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
        oApplication.Specialitypartner__c = sSpecialitypartnerNames;

        if(oApplication.Id!=null){
            oApplication.OperationsCompleted__c = true;
            update oApplication;
            //currentstep = 5;//technical contact
            SetCurrentStep();
        }
        return null;
    }

    public PageReference updatetechnicalcontact() {
        system.debug('@developer --> updatetechnicalcontact oApplication:'+oApplication);
        if(oApplication.Id!=null){
            oApplication.TechnicalContactCompleted__c = true;
            update oApplication;
            //currentstep = 5;//technical contact
            SetCurrentStep();
        }

        //here check if all tabs are filled. if yes then enable apply now and save application. otherwise send to the tab which is not filled
        return null;
    }

    public PageReference applynow() {
        if(oApplication.Id!=null){
            oApplication.Application_Completed__c = true;
            update oApplication;
        }
        //return new PageReference('/'+oApplication.Id);
        //return new PageReference('https://www.walmart.com/');
        return null;
    }

    public pagereference saveRecord(){
      //  system.debug('...111.. '+wrapList);
        return null;
    }
    
    public pagereference sendOldApplicationLink(){
        bEmailValidationError = true;
        bEmailValidationLeadError = true;
        if(sOldLeadEmail!=null && sOldLeadEmail!=''){
          Id IdApplication;
          if(sOldApplicationlink==null || sOldApplicationlink==''){
            Lead oLead;
            for(Lead oTempLead :[Select Id,Email,FirstName,LastName,Company,ApplicationSent__c From lead where id =:sOldLeadId]){
                oLead = oTempLead;
            }
            oApplication = new Application__c();
           oApplication.Primary_Contact_Email__c = oLead.Email;
           oApplication.Primary_Contact_First_Name__c = oLead.FirstName;
           oApplication.Primary_Contact_Last_Name__c = oLead.LastName;
           oApplication.Legal_Company_Name__c = oLead.Company;
           oApplication.Lead__c = oLead.Id;
           /*if(!oLead.ApplicationSent__c){
             oApplication.ApplicationSent__c = true;
           }*/
           insert oApplication;
            sOldApplicationlink = Site.getBaseUrl() + '?token=' + oApplication.Id;
            IdApplication = oApplication.Id;
          }
          else{
            for(Application__c oApplication:[Select id From Application__c Where Lead__c=:sOldLeadId limit 1]){
              IdApplication = oApplication.Id;
            }
          }
          BD2_0_custom_Metadata__mdt bdSettings = [select id, From_Address_Name_to_use__c, Email_Template_Developer_Name__c from BD2_0_custom_Metadata__mdt Where DeveloperName='Default_Setup'];
          String userWholeName = bdSettings.From_Address_Name_to_use__c;
          String emailTemplateName = bdSettings.Email_Template_Developer_Name__c;
          Id emailTemplateId;
                    
          for(EmailTemplate oET : [Select Id From EmailTemplate Where DeveloperName = :emailTemplateName]){
              emailTemplateId = oET.Id;
          }
          list<Messaging.SingleEmailMessage> lstMail = new list<Messaging.SingleEmailMessage>();
          Messaging.SingleEmailMessage oSingleEmailMessage = Messaging.renderStoredEmailTemplate(emailTemplateId,sOldLeadId,IdApplication);
          string sSubject = oSingleEmailMessage.getSubject();
          string sHtmlBody = oSingleEmailMessage.getHtmlBody();
          oSingleEmailMessage.setTargetObjectId(sOldLeadId);
          oSingleEmailMessage.setSubject(sSubject);
          oSingleEmailMessage.setHtmlBody(sHtmlBody);
          //oSingleEmailMessage.setTemplateId(emailTemplateId);
          //oSingleEmailMessage.setWhatId(AppId);    
          oSingleEmailMessage.setSenderDisplayName(userWholeName);
          oSingleEmailMessage.setSaveAsActivity(true);  
     
          //System.debug('@Developer --> oSingleEmailMessage :' + oSingleEmailMessage);
          
          lstMail.add(oSingleEmailMessage);
          
          if(lstMail.size() > 0){
              Messaging.sendEmail(lstMail);
          }
        }
        return null;
    }
    
    public pagereference ShowEmailValidationUserError(){
      bEmailValidationError = true;
      bEmailValidationUserError = true;
      return null;
    }
}
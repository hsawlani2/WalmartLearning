/**
 * Extension class for the intermediate page for Channel Partners to 
 * choose the option of creating self or for Seller
 * 
 * @see         newCaseSellerSelection VF page
 * @author      Cloud Sherpas
 * @createddate 31-Mar-2016
 */ 
public with sharing class CaseSellerSelectionExtension {
    
    public Case caseRecord { get; set; }
    public List<SelectOption> sellerOptions;
    public List<SelectOption> sellerList;
    public String selectedOption { get; set; }
    public String selectedRecordType { get; set; }
    public String sellerId { get; set; }
    public boolean profileCheck{get;set;}
    
    // default constructor
    public CaseSellerSelectionExtension(ApexPages.StandardController stdController) {
        caseRecord = (Case)stdController.getRecord();
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        profileCheck = (profileName == WalmartConstants.SUPPLIER_COMMUNITY_CHANNEL_PARTNER_PROFILE)? false:true;
        buildSellerOptions();
        buildSellerList();
        
        // initialize the value of the selected record type
        selectedRecordType = WalmartConstants.OPERATION_CASE_RECORD_TYPE_NAME.replace(' ', '_');
    }
    
    /**
     * Build the dropdown list for the list of sellers
     * UPDATE: This method is currently NOT in use.
     */
     private void buildSellerList() {
         sellerList = new List<SelectOption>();
         // why the need for the where clause?
         // because the channel partner account itself is visible to the CCP user, so we need to exlude that.
         // question is, can cases be created for prospect accounts as well?
         String mprecordType='MP_Account';
         for (Account anAccount : [SELECT Id, Name FROM Account WHERE Type=:WalmartConstants.ACCOUNT_TYPE_SELLER AND RecordType.DeveloperName=:mprecordType ORDER BY Name]) {
             sellerList.add(new SelectOption(anAccount.Id, anAccount.Name));
         }
         
         // set the initial value of the picklist
         if (sellerList.size() > 0) {
             sellerId = sellerList.get(0).getValue();
         }
     }
    
    /**
     * Private helper method to build the Options available on the VF page
     */ 
    private void buildSellerOptions() {
        sellerOptions = new List<SelectOption>(); 
        
        // the enable-ity of the next option depends on availability of associated seller accounts
        // the association is via the PartnerJoin junction object
        Boolean isSellerCaseDisabled = false;
        String sellerOptionLabel = 'Create for Seller';
        User sellerDetails = [SELECT AccountId FROM User WHERE Id = :UserInfo.getUserId() limit 1];
        system.debug('..sellerdetails.. '+sellerDetails.AccountId);
        Integer recordCount = [SELECT COUNT() FROM Partner_Join__c WHERE Channel_Partner__c=:sellerDetails.AccountId];
        if (recordCount == 0) {
            system.debug('...recordCount.. '+recordCount);
            isSellerCaseDisabled = true;
            sellerOptionLabel = 'Create for Seller (No sellers available)';
        }
        
        sellerOptions.add(new SelectOption('seller', sellerOptionLabel, isSellerCaseDisabled));
        
        sellerOptions.add(new SelectOption('self','Create for Self'));
        
        selectedOption = 'seller';
    }
    
    public List<SelectOption> getSellerOptions() {
        return sellerOptions;
    }
    
    /**
     * UPDATE: This method is currently NOT in use.
     */
    public List<SelectOption> getSellerList() {
        return sellerList;
    }
    
    public Boolean getShouldDisplaySellerOptions() {
        return selectedOption == 'seller';
    }
    
    public Boolean getShouldDisplayRecordSelectionOptions() {
        return selectedOption == 'self';
    }
    
    public List<SelectOption> getRecordTypeOptions() {
        List<SelectOption> aSelectOptions = new List<SelectOption>();
        
        Id partnerUserId = [SELECT AccountId FROM User WHERE Id = :UserInfo.getUserId() limit 1].AccountId;
        system.debug('..partnerUserId '+partnerUserId);
        string liveStatus = [SELECT Partner_Onboarding_Status__c FROM Account where Id =: partnerUserId].Partner_Onboarding_Status__c;
        
        if(liveStatus != 'Live'){
            //aSelectOptions.add(new SelectOption(WalmartConstants.OPERATION_CASE_RECORD_TYPE_NAME.replace(' ', '_'), 'Operations',true));
            SelectOption so1 = new SelectOption(WalmartConstants.OPERATION_CASE_RECORD_TYPE_NAME.replace(' ', '_'),'<span title="Your Account\'s current status allows creating On-boarding cases only">Operations</span>',true);
            so1.setEscapeItem(false);

            aSelectOptions.add(so1);

            aSelectOptions.add(new SelectOption(WalmartConstants.ONBOARDING_CASE_RECORD_TYPE_NAME.replace(' ', '_'), 'Onboarding'));
            
            selectedRecordType = WalmartConstants.ONBOARDING_CASE_RECORD_TYPE_NAME.replace(' ', '_'); 
        }else{
            aSelectOptions.add(new SelectOption(WalmartConstants.OPERATION_CASE_RECORD_TYPE_NAME.replace(' ', '_'), 'Operations'));
            aSelectOptions.add(new SelectOption(WalmartConstants.ONBOARDING_CASE_RECORD_TYPE_NAME.replace(' ', '_'), 'Onboarding'));
        }
        
        return aSelectOptions;
    }
    
    
    /**
     * Method is called from the VF page to continue to the CaseCreationForm VF page.
     * The parameters will depend on what the channel partner chose, whether 
     * creating  a case for a seller account or for itself.
     * 
     * @return PageReference to the newCaseCreationForm with the determined parameters.
     */
    public PageReference continueForm() {
        
        User sellerDetails = [SELECT AccountId, ContactId FROM User WHERE Id = :UserInfo.getUserId() limit 1];
        Id caseAccountId = sellerDetails.AccountId;
        Id caseContactId = sellerDetails.ContactId;
        String recordTypeName = null;
        
        Boolean isSellerCase = selectedOption == 'seller';
        system.debug('isseller case.. '+recordTypeName+ ' ..is seller .. '+isSellerCase);
        
        if (isSellerCase) {
            // caseRecord.In_Reference_to_Seller__c = sellerId;
            if (caseRecord.In_Reference_to_Seller__c != null) {
                caseAccountId = caseRecord.In_Reference_to_Seller__c;    
            }
            else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please select a seller account.'));
                return null;
            }
        }
        else {
            // if self
            // because we are setting this explictly as a helper method parameter, the record type will not need to be
            // computed in the helper method anymore.
            recordTypeName = selectedRecordType.replace('_', ' ');
        }
        
        system.debug('...selectedRecordType.. '+selectedRecordType);
        
        if(profileCheck){
            return CaseCRUDHelper.createCaseCreationFormURL(caseAccountId, caseContactId, false, null, isSellerCase, recordTypeName);
        }else{
            string cspSelection;
            if(selectedRecordType == WalmartConstants.ONBOARDING_CASE_RECORD_TYPE_NAME){
                cspSelection = 'Onboarding';
            }else{
                cspSelection = 'Operations';
            }
            return CaseCRUDHelper.createSupplierFormURL(caseAccountId, caseContactId, false, null, false, null,cspSelection);
        }
        
    }
    
    /**
     * Navigates back to the Home page of Case. 
     * 
     * @return reference to the case home page
     */ 
    public PageReference cancel() {
        if(profileCheck){
           return new PageReference('/500/o');
        }
        else{
            
             return new PageReference('/500/o');
        }
    }

}
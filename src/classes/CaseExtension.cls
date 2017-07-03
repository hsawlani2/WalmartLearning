/**
 * Extension class to support overridden New button. The class takes
 * care of redirecting the user based on their profile:
 * 1. If Community User - to new case creation VF page
 * 2. If Internal Support User - to operation or onboarding standard creation page based on their profile
 * (skipping record type selection page)
 * 3. For all other users - to record type selection page
 * 
 * @see newCaseCreation VF page
 * @author      Cloud Sherpas
 * @createddate 26-Feb-2016
 */ 
public class CaseExtension {
    
    public String SELLER_COMMUNITY_CASE;
    public String SELLER_COMMUNITY_ONBOARDING_CASE;
    public String SUPPLIER_COMMUNITY_CASE;
    
    public Boolean isFollowUpCase;
    public String parentCaseNumber;
    
    private Case caseRecord;
    
    // default contructor
    public CaseExtension(ApexPages.StandardController stdController) {
        SELLER_COMMUNITY_CASE = [SELECT Id 
                                 FROM RecordType 
                                 WHERE Name = :WalmartConstants.OPERATION_CASE_RECORD_TYPE_NAME limit 1].Id;
        
        SELLER_COMMUNITY_ONBOARDING_CASE = [SELECT Id 
                                            FROM RecordType 
                                            WHERE Name = :WalmartConstants.ONBOARDING_CASE_RECORD_TYPE_NAME limit 1].Id;
        
        SUPPLIER_COMMUNITY_CASE = [SELECT Id 
                                            FROM RecordType 
                                            WHERE Name = :WalmartConstants.SUPPLIER_CASE_RECORD_TYPE_NAME limit 1].Id;                                    
        
        // for creation of follow up cases
        String isFollowUpCaseParam = ApexPages.currentPage().getParameters().get('isFollowUpCase');
        isFollowUpCase = (isFollowUpCaseParam == null ? false : true);
        if(isFollowUpCase) {
            parentCaseNumber = ApexPages.currentPage().getParameters().get('parentCaseNumber');
        }
        
        caseRecord = (Case)stdController.getRecord();
    }
    
    
    /**
     * Method to redirect the flow on New case creation
     * to Seller/Support View to either Onboarding or Operations Case view
     * The Seller View redirection depends on:
     * - If Seller Onboarding Status is Live on Site & Ops Ready, the page shown is for Operations case creation
     * - For all other scenarios, the page shown is for Onboarding case creation
     * 
     * For Internal Support Users, the appropriate page is displayed, without record type selection page
     * based on their profile.
     * 
     * @return page reference to the case detail page
     */ 
    public PageReference verifyUserAndRedirect() {
        PageReference pageRef;
        String profileName = [Select Id, Name from Profile where Id = :UserInfo.getProfileId()].Name;
        
        System.debug('<<< profile: ' + profileName);
        
        // redirect for Community User        
        if(WalmartConstants.SELLER_COMMUNITY_USER_PROFILE_NAME == profileName) {

            User sellerDetails = [SELECT AccountId, ContactId FROM User WHERE Id = :UserInfo.getUserId() limit 1];
            Id accountId = sellerDetails.AccountId;
            Id contactId = sellerDetails.ContactId;
            
            return CaseCRUDHelper.createCaseCreationFormURL(accountId, contactId, isFollowUpCase, parentCaseNumber, false, null);
            
        } else if (WalmartConstants.SELLER_COMMUNITY_CHANNEL_PARTNER_PROFILE_NAME == profileName) {
            /*
             * 1. Verify if the incoming flow is for creating Follow Up Case, if yes then invoke the
             * CaseCRUDHelper.createCaseCreationFormURL() directly from here by passing required attributes
             * 
             * 2. If it's for a new Case, then redirect the flow to the seller selection page
             */  
            system.debug('isfollowupcase*****' +isFollowUpCase);
             if (isFollowUpCase)
             {
                 User sellerDetails = [SELECT AccountId, ContactId FROM User WHERE Id = :UserInfo.getUserId() limit 1];
                 Id accountId = sellerDetails.AccountId;
                 Id contactId = sellerDetails.ContactId;
                 
                 // For follow-up cases initiated by the channel partner, its possible that the case was for a seller account
                 // If so, we must re-reference the new follow up case with the seller account based on the parent
                 Case parentCase = [SELECT Id, In_Reference_to_Seller__c, CaseNumber FROM Case WHERE CaseNumber =:parentCaseNumber];
                 Boolean isSellerCase = false;
                 if (parentCase.In_Reference_to_Seller__c != null) {
                     caseRecord.In_Reference_to_Seller__c = parentCase.In_Reference_to_Seller__c;
                     accountId = parentCase.In_Reference_to_Seller__c;
                     isSellerCase = true;
                 }
                 
                 return CaseCRUDHelper.createCaseCreationFormURL(accountId, contactId, isFollowUpCase, parentCaseNumber, isSellerCase, null);
             }
             else {
                 return Page.newCaseSellerSelection;
             }
        }else if (WalmartConstants.SUPPLIER_COMMUNITY_USER_PROFILE_NAME == profileName){
            User supplierDetails = [SELECT AccountId, ContactId FROM User WHERE Id = :UserInfo.getUserId() limit 1];
            Id accountId = supplierDetails.AccountId;
            Id contactId = supplierDetails.ContactId;
            
            system.debug('..supplier Details.. '+supplierDetails);
            
            return CaseCRUDHelper.createSupplierFormURL(accountId, contactId, isFollowUpCase, parentCaseNumber, false, null,null);
        }else if(WalmartConstants.SUPPLIER_COMMUNITY_CHANNEL_PARTNER_PROFILE == profileName){
            
            if (isFollowUpCase) {
                 User sellerDetails = [SELECT AccountId, ContactId FROM User WHERE Id = :UserInfo.getUserId() limit 1];
                 Id accountId = sellerDetails.AccountId;
                 Id contactId = sellerDetails.ContactId;
                 
                 // For follow-up cases initiated by the channel partner, its possible that the case was for a seller account
                 // If so, we must re-reference the new follow up case with the seller account based on the parent
                 Case parentCase = [SELECT Id, In_Reference_to_Seller__c, CaseNumber FROM Case WHERE CaseNumber =:parentCaseNumber];
                 Boolean isSellerCase = false;
                 /*
                 if (parentCase.In_Reference_to_Seller__c != null) {
                     caseRecord.In_Reference_to_Seller__c = parentCase.In_Reference_to_Seller__c;
                     accountId = parentCase.In_Reference_to_Seller__c;
                     isSellerCase = true;
                 }
                 */
                 
                 return CaseCRUDHelper.createSupplierFormURL(accountId, contactId, isFollowUpCase, parentCaseNumber, isSellerCase, null,null);
             }
             else {
                 return Page.newCaseSellerSelection;
             }
        }
        
        // redirect for Internal Users
        // redirect to the respective record type creation screen based on profiles
        if(CaseUtility.getOperationProfileNames().contains(profileName)) {
            
            // Operations cases - operation profiles should be redirected to respective creation screen directly
            pageRef = new PageReference('/500/e?nooverride=1&retURL=%2F500%2Fo&RecordType=' + SELLER_COMMUNITY_CASE + '&ent=Case');
        } else if(CaseUtility.getOnboardingProfileNames().contains(profileName)) { 
            
            // Onboarding cases - onboarding profiles should be redirected to respective creation screen directly
            pageRef = new PageReference('/500/e?nooverride=1&retURL=%2F500%2Fo&RecordType=' + SELLER_COMMUNITY_ONBOARDING_CASE + '&ent=Case');
            //pageRef = new PageReference('/console#%2F500%2Fe?nooverride=1&retURL=%2F500%2Fo&RecordType=' + SELLER_COMMUNITY_ONBOARDING_CASE + '&nooverride=1&ent=Case|');
        }else if(CaseUtility.getSupplierProfileNames().contains(profileName)){ 
            
            // Supplier Cases
            pageRef = new PageReference('/500/e?nooverride=1&retURL=%2F500%2Fo&RecordType=' + SUPPLIER_COMMUNITY_CASE + '&ent=Case');
        } 
        else {
            
            // for sys admins and all other profiles to record type selection page
            pageRef = new PageReference('/setup/ui/recordtypeselect.jsp?ent=Case&nooverride=1&save_new_url=%2F500%2Fe');
        }
        
        return pageRef;        
    }
}
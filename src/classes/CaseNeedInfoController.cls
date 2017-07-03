/**
 * Controller class to handle the Need Info scenario
 * 
 * @author      Cloud Sherpas
 * @createddate 4-Feb-2016
 */ 
public class CaseNeedInfoController {
    
    public String sellerComments {get; set;}
    public Boolean isCaseAlreadyInNeedInfo {get; set;}
    public Boolean hideCommentBlock {get; set;}
    public Boolean isEditAllowed {get; set;}
    public String recordType {get; set;}
    public String noEditMessage {get; set;}
    public Boolean isSupplier {get; set;}
    
    private Id caseId;
    private Case caseRecord;
    private Boolean isError = false;
    private String communityURL;
    
    /**
     * Default Constructor. The caseId is sent on the button click
     */ 
    public CaseNeedInfoController() {
        caseId = ApexPages.currentPage().getParameters().get('caseId');
        List<Case> caseList = [select Id, ContactId, OwnerId, RecordTypeId, Info_Received__c, Comments_for_Need_Info__c, Status 
                      from Case where Id = :caseId limit 1];
        if (caseList.size() == 0) {
            System.debug('<<< No matching cases found. exiting preemptively.');
            return;
        }
        caseRecord = caseList.get(0);
        
        isEditAllowed = true;
        
        // 1. cross profiles cannot use need info
        String userProfileName = [Select Id, Name from Profile where Id = :UserInfo.getProfileId()].Name;
        String recordTypeName = [select Name from RecordType where Id = :caseRecord.RecordTypeId limit 1].Name;
        
        // According to the corresponding unit test results, its impossible to reach the next two blocks
        // of conditionals. Cases of certain record types won't be even fetched from SOQL if done by
        // certain types of User profiles. Example: Onboarding case record types can't be fetched by
        // Operation user profiles.
        
        // onboarding case and operation profile
        if(recordTypeName == WalmartConstants.ONBOARDING_CASE_RECORD_TYPE_NAME
           && CaseUtility.getOperationProfileNames().contains(userProfileName)) {
               isEditAllowed = false;
               noEditMessage = 'You cannot edit an Onboarding Case record!';
        }
        
        // operation case and operation profile
        if(recordTypeName == WalmartConstants.OPERATION_CASE_RECORD_TYPE_NAME
           && CaseUtility.getOnboardingProfileNames().contains(userProfileName)) {
               isEditAllowed = false;
               noEditMessage = 'You cannot edit an Operation Case record!';
        }        

        
        // 2. check if the case owner is still, queue then block else it will fail on VR
        List<QueueSobject> queueList 
            = [SELECT Id FROM QueueSobject WHERE QueueId = :caseRecord.OwnerId];
        if(queueList.size() > 0) {
               System.debug('<<< Case is in a Queue');
               isEditAllowed = false;
               noEditMessage = 'The Case is still assigned to Queue. Please assign an Owner and try again!';
        }
        
        
        // 3. if editable, then proceed
        if(isEditAllowed) {
            // cannot trigger another email on same status
            // use to show hide respective section
            if(caseRecord.Status == 'Need Info' && caseRecord.Info_Received__c == true) {
                isCaseAlreadyInNeedInfo = true;
            } else {
                isCaseAlreadyInNeedInfo = false;
            }
            
            if(CaseUtility.getSupplierProfileNames().contains(userProfileName)){
                String communityId = [SELECT Id FROM Network where Name = :WalmartConstants.SUPPLIER_COMMUNITY_NAME limit 1].Id;
                communityURL = Network.getLoginURL(communityId);
                communityURL = communityURL.removeEnd('login');
                communityURL += caseRecord.Id;
            }else{
            // create the URL to the Case record to be used in the email template
            String communityId = [SELECT Id FROM Network where Name = :WalmartConstants.SELLER_COMMUNITY_NAME limit 1].Id;
            system.debug('community Idss.. '+communityId);
            communityURL = Network.getLoginURL(communityId);
            communityURL = communityURL.removeEnd('login');
            communityURL += caseRecord.Id;
            system.debug('community url.. '+communityURL);
            }
        }
        
        if(CaseUtility.getSupplierRecordTypeNames().contains(recordTypeName)){
            isSupplier = true;
        }else{
            isSupplier = false;
        }
    }
    

    /**
     * Controller Method.
     * 
     * @see #sendEmailOnNeedInfo()
     * @return page reference to the VF page with success/error message
     */ 
    public PageReference requestInfoFromSeller() {
        
        // if all good, then proceed
        sendEmailOnNeedInfo();
        if(!isError) {
            hideCommentBlock = true;
            
            if(isSupplier){
                Apexpages.addMessage(
                    new Apexpages.Message(
                        ApexPages.Severity.INFO, 
                        'An email has been sent to the Supplier requesting more information.'));
            }else{
                Apexpages.addMessage(
                    new Apexpages.Message(
                        ApexPages.Severity.INFO, 
                        'An email has been sent to the Seller requesting more information.'));
            }
            
        } else {
            Apexpages.addMessage(
                new Apexpages.Message(
                    ApexPages.Severity.ERROR, 
                    'There was an error processing your request, please contact your System Administrator for details.'));
        }
        return null;
    }
    
    
    /**
     * This method:
     * 1. Inserts the description entered on the VF
     * 2. Sends Email to Seller with details
     * 3. Takes care of blocking Case Comment email being fired
     * 4. Changes Case Status to Need Info
     */ 
    private void sendEmailOnNeedInfo() {
        
        try {
            /*
             * 1. Retrieve the Contact to whom the email will be sent
             * 2. Retrieve the Org Wide Email address to be set in From address
             * 3. Retrieve the Need Info Email Template
             */ 
            String userProfileName = [Select Id, Name from Profile where Id = :UserInfo.getProfileId()].Name;
            Contact seller = [select Id, Email from Contact where Id = :caseRecord.ContactId];
            OrgWideEmailAddress fromEmail = [select Id, Address, DisplayName from OrgWideEmailAddress 
                                             where displayname = 'Walmart Marketplace Support' limit 1];
            
            EmailTemplate emailTemplate = new EmailTemplate();                                 
            
            if(CaseUtility.getSupplierProfileNames().contains(userProfileName)){
                emailTemplate = [SELECT Id 
                                           FROM EmailTemplate WHERE Name = :WalmartConstants.SUPPLIER_NEED_INFO_EMAIL_TEMPLATE];
                system.debug('..supplier profile.. '+emailTemplate);
            }else{
            emailTemplate = [SELECT Id 
                                           FROM EmailTemplate WHERE Name = :WalmartConstants.NEED_INFO_EMAIL_TEMPLATE];
            }
    
            /* Perform Case Operations */
            // change the status of case to Need Info 
            caseRecord.Status = 'Need Info';
            // mark this flag to true, so as Case Comments workflow is not fired
            caseRecord.Status_Changed_to_Need_Info__c = true;

            caseRecord.Comments_for_Need_Info__c = sellerComments;
            caseRecord.Community_URL__c = communityURL;
            
            // mark this flag to false, referred in trigger, so that validation does not fire
            CaseCRUDHelper.NEED_INFO_EDITED_FROM_UI = false;
            
            update caseRecord;
            
                
            /* Perform Case Comment Operations */
            // insert the case comment as captured in description
            CaseComment caseComment = new CaseComment(ParentId = caseId, CommentBody = sellerComments);

            // mark this case comment public so that this is available to Seller
            caseComment.IsPublished = true;

            insert caseComment;
            
            /* Trigger Email */
            Messaging.reserveSingleEmailCapacity(2);
            Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();
            //String[] toAddresses = new String[] {seller.Email};
                
            //emailMsg.setToAddresses(toAddresses);
            emailMsg.setOrgWideEmailAddressId(fromEmail.Id);
            emailMsg.setTemplateId(emailTemplate.Id);
            emailMsg.setTargetObjectId(seller.Id);
            emailMsg.setWhatId(caseRecord.Id);
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { emailMsg });
    
            // once the email is successfully sent, change the flag for status change
            // on need info to false, so as regular Case Comment workflows can then be fired
            caseRecord.Status_Changed_to_Need_Info__c = false;
            update caseRecord;
        } catch (Exception e) {
            system.debug(LoggingLevel.ERROR, 'Error sending email - ' + e.getStackTraceString());
            isError = true;
        } 
    }


    /**
     * Method to redirect the page back to Case details page
     * 
     * @return page reference to the case detail page
     */ 
    public PageReference back() {
        PageReference pageRef = new PageReference('/' + caseId);
        pageRef.setRedirect(true);
        return pageRef;
    }
}
/**
 * Controller class to handle the Need Info scenario
 * 
 * @author		Cloud Sherpas
 * @createddate	4-Feb-2016
 */ 
public class CaseController {
    
    public String sellerComments {get; set;}
    public Boolean isCaseAlreadyInNeedInfo {get; set;}
    public Boolean hideCommentBlock {get; set;}
    
    private static String NEED_INFO_EMAIL_TEMPLATE = 'Notify Seller on Case Status change to Need Info';
    private static String SELLER_COMMUNITY_NAME = 'Walmart Seller Community';
    private Id caseId;
    private Case caseRecord;
    private Boolean isError = false;
    private String communityURL;
    
    /**
     * Default Constructor. The caseId is sent on the button click
     */ 
    public CaseController() {
        caseId = ApexPages.currentPage().getParameters().get('caseId');
        caseRecord = [select Id, ContactId, Info_Received__c, Comments_for_Need_Info__c, Status 
                      from Case where Id = :caseId limit 1];

        // cannot trigger another email on same status
        // use to show hide respective section
        if(caseRecord.Status == 'Need Info' && caseRecord.Info_Received__c == true) {
		       isCaseAlreadyInNeedInfo = true;
        } else {
            isCaseAlreadyInNeedInfo = false;
        }
        
        // create the URL to the Case record to be used in the email template
        String communityId = [SELECT Id FROM Network where Name = :SELLER_COMMUNITY_NAME limit 1].Id;
        communityURL = Network.getLoginURL(communityId);
        communityURL = communityURL.removeEnd('login');
        communityURL += caseRecord.Id;
    }
    

    /**
     * Controller Method.
	 * 
	 * @see #sendEmailOnNeedInfo()
	 * @return page reference to the VF page with success/error message
     */ 
    public PageReference requestInfoFromSeller() {
        
        sendEmailOnNeedInfo();
        if(!isError) {
            hideCommentBlock = true;
            
            Apexpages.addMessage(
                new Apexpages.Message(
                    ApexPages.Severity.INFO, 
                    'An email has been sent to the Seller requesting more information.'));
            
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
            Contact seller = [select Id, Email from Contact where Id = :caseRecord.ContactId];
            OrgWideEmailAddress fromEmail = [select Id, Address, DisplayName from OrgWideEmailAddress limit 1];
            EmailTemplate emailTemplate = [SELECT Id 
                                           FROM EmailTemplate WHERE Name = :NEED_INFO_EMAIL_TEMPLATE];
            
    
            /* Perform Case Operations */
            // change the status of case to Need Info 
            caseRecord.Status = 'Need Info';
            // mark this flag to true, so as Case Comments workflow is not fired
            caseRecord.Status_Changed_to_Need_Info__c = true;

            caseRecord.Comments_for_Need_Info__c = sellerComments;
            caseRecord.Community_URL__c = communityURL;
            
            // mark this flag to false, referred in trigger, so that validation does not fire
            CaseTriggerHelper.NEED_INFO_EDITED_FROM_UI = false;
            
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
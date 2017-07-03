/**
 * Helper class for operations related to Case CRUD operations.
 * 
 * @author		Cloud Sherpas
 * @createddate	10-Mar-2016
 */ 
public class CaseCommentCRUDHelper {

    /**
     * Helper method to handle comments to/from Seller<-->JIRA. The method does the following:
     * JIRA to Seller:
     * 1. Marks the incoming comments from JIRA as Public if #pub# is present, in all other cases, marks it as Private.
     * 2. Trims the extra JIRA comments related to JIRA project, issue, etc.
     * 
     * Seller to JIRA:
     * 1. Adds #JIRA if the comment is made by Seller and it needs to go to JIRA
     * 
     * @param comment	the case comment record
     */ 
    public static void handleSellerAndJIRAComments(CaseComment comment) {
        
        String profileName = [Select Id, Name from Profile where Id = :UserInfo.getProfileId()].Name;
        //system.debug('Profile - ' + profileName);
        //system.debug('Actual Comments - ' + comment.CommentBody);
        
        
        /* JIRA to Seller:
         * 
         * The comment body whenever commented from JIRA is in the form of:
         * <#pub#> (if the comment is to be marked public)
         * <the actual comment> followed by
         * -MPSUPPORT-IssueId -JIRA username
         * 
         * The extra -MPSUPPORT related text should be taken off while saving this on comment
         * so that this information is not visible to the Seller if the comment is made public.
         * Doing this also removes it from Support User's view too as the behavior should be in sync.
         */ 
        if(WalmartConstants.INTEGRATION_ADMINISTRATOR_PROFILE_NAME == profileName) {
            String incomingComments = comment.CommentBody;
            
            JIRA_CONFIG__c jiraConfig = JIRA_CONFIG__c.getValues('CONFIG');
            //system.debug('INCOMING COMMENTS - ' + incomingComments);
            //system.debug('PUB IDENTIFIER - ' + jiraConfig.Public_Comment_Identifier__c);
            
            // verify if the comment needs to be public or not
            if(incomingComments.startsWith(jiraConfig.Public_Comment_Identifier__c)) {
                
                // if public, it will be preceeded by #pub#, take it off
                incomingComments = incomingComments.split(jiraConfig.Public_Comment_Identifier__c).get(1);
                
                // make the comments public
                comment.IsPublished = true;
            }
            
            // take off the -MPSUPPORT text
            incomingComments = incomingComments.split('-' + jiraConfig.Project_Name__c).get(0);
            comment.CommentBody = incomingComments;
            //system.debug('FINAL COMMENT - ' + incomingComments);
        }
        
        
        /* Seller to JIRA:
         * 
         * Check if there is a related JIRA issue, if yes, prefix #JIRA tag in the comment,
         * so that this is picked by zAgile to be sent on the related issues
         * on the Case record
         */ 
        if(WalmartConstants.SELLER_COMMUNITY_USER_PROFILE_NAME == profileName
          	|| WalmartConstants.SELLER_COMMUNITY_CHANNEL_PARTNER_PROFILE_NAME == profileName) {
            List<zsfjira__ZIssue_Case__c> records = 
                [SELECT zsfjira__ZIssueId__c FROM zsfjira__ZIssue_Case__c WHERE zsfjira__CaseId__c = :comment.ParentId];
            if(records.size() > 0) { // signifies that there is a related JIRA issue
                comment.CommentBody = '#JIRA ' + comment.CommentBody;
            }
        }
    }
}
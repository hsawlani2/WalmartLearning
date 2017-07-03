/**
 * Helper class for operations related to File Attachments.
 * 
 * @author      Cloud Sherpas
 * @createddate 26-Feb-2016
 */ 
public class FileAttachmentHelper {

    
    /**
     * A helper method to get the blacklisted extension from the
     * custom setting
     * 
     * @return set of all file extensions blacklisted in the custom setting
     */ 
    private static Set<String> getBlackListedExtensions() {
        Set<String> blackListedExtns = new Set<String>();
        List<ATTACHMENT_BLACKLISTED_EXTENSIONS__c> blackListedExtensions 
            = ATTACHMENT_BLACKLISTED_EXTENSIONS__c.getAll().values();
        for(ATTACHMENT_BLACKLISTED_EXTENSIONS__c extensionName : blackListedExtensions) {
            blackListedExtns.add(extensionName.Name);
        }
        System.debug('<<< blacklisted extensions: ' + blackListedExtns);
        return blackListedExtns;
    }
    
    
    /**
     * A helper method to return the maximum attachment size allowed as defined in the
     * custom setting
     * 
     * @return the number defined in the CS
     */ 
    private static Double getMaximumAttachmentFileSize() {
        return ATTACHMENT_MAXIMUM_SIZE_LIMIT__c.getInstance('MAX_SIZE_LIMIT').MAX_SIZE_IN_MB__c;
    }
    
    
    /**
     * Method to verify the file being attached and restrict based on blacklisted extension
     * or maximum file size allowed.
     * 
     * If the file attachment is restricted, an error is displayed to the user.
     * 
     * @param attachmentmentFile the file being attached
     */ 
    public static boolean verifyAndRestrictUnwantedAttachment(Attachment attachmentFile) {
        
        /*
         * 1. Retrieve the file extension
         * 2. Verify the extension from the blacklisted types Custom Settings
         * 3. Verify the file size limit < 10 MB as defined in Custom Settings
         */
         
        String fileName = attachmentFile.Name;
        Integer fileLength = attachmentFile.Body.size(); // this is in bytes
        String fileExtension = fileName.substringAfterLast('.');
        
        Set<String> blackListedExtns = getBlackListedExtensions();
        // verify blacklisted files
        if(blackListedExtns.contains(fileExtension.toUpperCase())) {
            attachmentFile.addError('A .' + fileExtension + ' file type is not allowed for attachments!');
            return false;
        }
        
        // block > 10 MB attachment
        if(fileLength > (1000000 * getMaximumAttachmentFileSize())) {
            attachmentFile.addError('Files less than ' + getMaximumAttachmentFileSize() + ' MB only can be attached!');
            return false;
        }
        
        return true;
    }
    
    
    /**
     * Method to verify the file being attached from Chatter Comment
     * and restrict based on blacklisted extension maximum file size allowed.
     * 
     * If the file attachment is restricted, an error is displayed to the user.
     *  
     * @param comment the feed comment record in consideration
     */ 
    public static boolean verifyAndRestrictUnwantedChatterAttachment(FeedComment comment) {
        boolean isValidAttachment = true;
        // first get the ContentVersion
        ContentVersion contentVersion;
        List<ContentVersion> contentVersionList = [SELECT ContentDocumentId, ContentSize, FileExtension, FileType 
                                         FROM ContentVersion 
                                         WHERE Id = :comment.RelatedRecordId limit 1];
        if(contentVersionList.size() == 0) {
            return false;
        } else {
            contentVersion = contentVersionList.get(0);
        }
        
        String fileExt = contentVersion.FileExtension;
        Set<String> blacklistedExtns = getBlackListedExtensions();
        
        if(blackListedExtns.contains(fileExt.toUpperCase())) {
            isValidAttachment = false;
            comment.addError('A .' + fileExt + ' file type is not allowed for attachments!');
        }
        
        // block > 10 MB attachment
        if(contentVersion.ContentSize > (1000000 * getMaximumAttachmentFileSize())) {
            isValidAttachment = false;
            comment.addError('Files less than ' + getMaximumAttachmentFileSize() + ' MB only can be attached!');
        }
        
        return isValidAttachment;
    }
    
    
    /**
     * Method to send attachment from Seller directly to JIRA if there is
     * an associated JIRA issue with the Case.
     * 
     * This is a future method implementation as there will be a callout made
     * to JIRA from SF.
     * 
     * @param attachmentId  the attachment to be sent to JIRA
     */ 
    @future (callout = true)
    public static void sendAttachmentToJIRA(String attachmentId) {
        Attachment attachmentRecord = [SELECT Id, Name, ParentId FROM Attachment where Id = :attachmentId limit 1 ];
        Id caseId = attachmentRecord.ParentId;
        
        String jiraKey = JIRAUtility.getRelatedJIRAIssueKey(caseId);
        
        // call the attachment method
        Map<String, Object> response = new Map<String, Object>();
        try {
            response = 
                zsfjira.ZSendAttachmentsController.sendAttachmentsWithSelectedIssuesV2(
                    attachmentId, new List<String> {jiraKey});
        } catch (Exception e) {
            // consume, do not block
            system.debug(LoggingLevel.ERROR, 'Error sending attachment to JIRA - ' + e.getStackTraceString());
            system.debug(LoggingLevel.ERROR, 'Error sending attachment to JIRA. Response Details - ' 
                         + response.get('status') + '::'
                         + response.get('message'));
        }
    }
}
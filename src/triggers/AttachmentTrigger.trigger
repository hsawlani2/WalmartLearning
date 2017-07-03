/**
 * Trigger on Attachment to:
 * 1. Restrict Blacklisted files uploads
 * 2. Restrict file size > 10 MB for uploads
 * 
 * @author		Cloud Sherpas
 * @createddate	24-Feb-2016
 */ 
trigger AttachmentTrigger on Attachment (before insert, after insert) {

    if(Trigger.isBefore && Trigger.isInsert) {
        FileAttachmentHelper.verifyAndRestrictUnwantedAttachment(Trigger.new[0]);
    }
    
    
    if(Trigger.isAfter && Trigger.isInsert) {
        //String profileName = [Select Id, Name from Profile where Id = :UserInfo.getProfileId()].Name;
        //if(WalmartConstants.SELLER_COMMUNITY_USER_PROFILE_NAME == profileName) {
        FileAttachmentHelper.sendAttachmentToJIRA(Trigger.new[0].Id);
        //}
    }
}
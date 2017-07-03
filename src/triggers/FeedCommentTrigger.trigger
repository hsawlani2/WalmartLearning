/**
 * Trigger on FeedComment when attaching a file from Chatter Comment "Attach File" option to:
 * 1. Restrict Blacklisted files uploads
 * 2. Restrict file size > 10 MB for uploads
 * 
 * @author		Cloud Sherpas
 * @createddate	09-Mar-2016
 */ 
trigger FeedCommentTrigger on FeedComment (before insert) {
    
    if(Trigger.isBefore && Trigger.isInsert) {
        FeedComment comment = Trigger.new[0];
        FileAttachmentHelper.verifyAndRestrictUnwantedChatterAttachment(comment);
    }
}
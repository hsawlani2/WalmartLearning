global class CaseFeedCommentSyncUtils {
 
    final static String COMMENTINSERT = 'FeedItem2Case';
    final static String FEEDREMOVAL = 'CaseCommentFeedItemDeletion';
    final static String FEEDINSERT = 'FeedItemfromCase';
 
    global class SyncParameter{
        @InvocableVariable(Label = 'Sync Type'
                          Description = 'Indicates Feed sync or feed item removal'
                           Required = true)
        global String syncType;
 
        @InvocableVariable(Label = 'Feed Body'
                          Description = 'Body of the chatter post')
        global String feedBody;
 
        @InvocableVariable(Label = 'Parent Id'
                          Description = 'Id of parent record, feed item or case comment'
                           Required = true)
        global String parentId;
 
    }
 
    @InvocableMethod
    global static void chatterFeedToCaseComment(List<SyncParameter> syncParams){
        if(syncParams[0].syncType == COMMENTINSERT){
            String feedBody = syncParams[0].feedBody;
            String parentId = syncParams[0].parentId;
            String profileid = UserInfo.getProfileId();
            system.debug('Profile id' + profileid);
            Boolean duplicatecheck = false;
            if(feedBody.contains('Comment from Agent'))
                duplicatecheck = true;
            CaseComment cc = feedBody != null && parentId != null ?
                    new CaseComment(CommentBody = feedBody + + '\n\n' + ' Case Comment from Feed', ParentId = parentId)
                    : null;
     
                if(cc != null && duplicatecheck == false){
                    try{
                        insert cc;
                    }catch(Exception caseCommentInsEx){
                        system.debug(LoggingLevel.ERROR, 'Case Comment Insert Error: ' + caseCommentInsEx.getMessage());
                    }
                }
        }
        // inserting feedpost from Comment
        if(syncParams[0].syncType == FEEDINSERT){
            String feedBody = syncParams[0].feedBody;
            String parentId = syncParams[0].parentId;
            String profileid = UserInfo.getProfileId();
            system.debug('Profile id' + profileid);
            /*
            FeedItem fditem = new FeedItem();
            fditem.Body = 'This is from feeditem';
            fditem.ParentId = '5005B000001F8OZ';
            insert fditem;
            */
            FeedItem cc = feedBody != null && parentId != null ?
                new FeedItem(Body = feedBody + + '\n\n' + 'Comment from Agent', ParentId = parentId)
                : null;
 
            if(cc != null){
                try{
                    insert cc;
                }catch(Exception caseCommentInsEx){
                    system.debug(LoggingLevel.ERROR, 'Case Comment Insert Error: ' + caseCommentInsEx.getMessage());
                }
            }
        }
    } 
 
}
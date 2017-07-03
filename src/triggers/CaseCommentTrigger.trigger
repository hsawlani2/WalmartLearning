/**
 * Trigger on CaseComment
 * 
 * @author      Cloud Sherpas
 * @createddate 10-Mar-2016
 */ 
trigger CaseCommentTrigger on CaseComment (before insert,after insert,after update) {

    if(Trigger.isBefore && Trigger.isInsert) {
        CaseCommentCRUDHelper.handleSellerAndJIRAComments(Trigger.new[0]);
    }
    
     if(Trigger.isAfter){
         if(Trigger.isInsert || Trigger.isupdate){
        Autoclosemilestone.CompleteFirstResponse(Trigger.new);
    }
    }
}
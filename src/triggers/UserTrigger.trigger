/**
 * Trigger on the User sObject.
 * 
 * @see UserTriggerHandler
 * @author Accenture
 */
trigger UserTrigger on User (after insert) {
    
    // we only support after insert right now, so no need to wrap in a conditiona
    List<Id> userIds = new List<Id>();
    for (User aUser : Trigger.new) {
        userIds.add(aUser.Id);
    }
    UserTriggerHandler.grantReadAccessToPartnerJoinRecords(userIds);

}
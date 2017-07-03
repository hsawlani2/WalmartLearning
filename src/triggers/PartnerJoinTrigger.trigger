/**
 * Trigger on the PartnerJoin junction object that should mainly update CCP read access to seller account records.
 * 
 * @see PartnerJoinTriggerHandler
 * @author Cloud Sherpas
 * @createddate 31-03-2016
 */
trigger PartnerJoinTrigger on Partner_Join__c (after insert, after update, after delete) {
    
    PartnerJoinTriggerHandler handler = new PartnerJoinTriggerHandler();
    
    if (Trigger.isInsert) {
        handler.grantReadAccess(Trigger.new);
    }
    else if (Trigger.isUpdate) {
        handler.revokeReadAccess(Trigger.old);
        handler.grantReadAccess(Trigger.new);
    }
    else if (Trigger.isDelete) {
        handler.revokeReadAccess(Trigger.old);
    }

}
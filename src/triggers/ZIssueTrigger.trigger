/**
 * Trigger to facilitate State Transition between SF and JIRA 
 * through zAgile ZIssue__c.
 * 
 * The operation implemented here is only after update as during
 * auto-creation, the details would have been copied. The ongoing
 * updates on state transition is required on existing issue/case.
 * 
 * @author      Cloud Sherpas
 * @createddate 22-Mar-2016
 */ 
trigger ZIssueTrigger on zsfjira__ZIssue__c (after update,before insert) {
    
    system.debug('..zissue.. '+trigger.new);
    if(Trigger.isUpdate && Trigger.isAfter) {

        /* 
         * Stop Cyclic loop for Status Updates.
         * Consider the scenario:
         * 1. Case status was updated from SF and a callout was made to update JIRA status as well (from CaseTrigger)
         * 2. As soon as JIRA Status gets updated, zIssue gets updated as well
         * 3. As zIssue gets updated, the flow gets into this trigger again and it will attempt to
         * update Case Status again thus causing infinite loop
         * 4. After Trigger still needs to be invoked for Case Status when the flow is coming in from JIRA
         * 
         * To stop the infinite loop:
         * *** Do not update Case status if zIssue status is same as that of the Case that is linked to. ***
         * 
         * There may be a scenario when Case Status and zIssue Status are not in sync, but that won't be a problem here.
         * If a JIRA Status update callout was made and it failed or it was never made based on returned
         * transition id, then in that case this trigger will never be
         * invoked, thus there's no need to worry about any disconnect in Case vs. zIssue status'.
         */
        Case relatedCase = JIRAUtility.getRelatedCaseDetails(Trigger.new[0].Id);
        if(JIRAUtility.getSFEquivalentCaseStatus(Trigger.new[0].zsfjira__Status__c) == relatedCase.Status) {
            // do nothing, return
            system.debug('[SFJIRAIntegrationTrigger]Returning to block cyclic call ...');
            return;
        }
        
        // in all other scenarios, proceed to below
        // fetch the profile name to identify is update is made from JIRA or SF
        String profileName = [Select Id, Name from Profile where Id = :UserInfo.getProfileId()].Name;

        
        // update done from JIRA, so no update back from SF to JIRA should be done
        if(WalmartConstants.INTEGRATION_ADMINISTRATOR_PROFILE_NAME == profileName) {
            system.debug('[SFJIRAIntegrationTrigger]Updating Case Status as received from JIRA ...');
            /* 
             * Stop Cyclic loop:
             * Similarly, once Case status is updated through this flow, then it should
             * not again call the Rest API to update JIRA Status during the Case updates.
             * As the flow is in the same execution context, handle it using the FLAG value
             * which is referred in CaseTrigger.
             */ 
            SFJIRAIntegrationHelper.UPDATE_JIRA_STATUS = false;
            SFJIRAIntegrationHelper.updateCaseStatus(Trigger.new[0]);
        }
    }
}
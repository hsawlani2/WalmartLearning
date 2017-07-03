/**
 * Trigger on Case
 * 
 * @author      Cloud Sherpas
 * @createddate 4-Feb-2016
 */ 
trigger CaseTrigger on Case (before update, after update, before insert, after insert) {
    
    String profileName = [Select Id, Name from Profile where Id = :UserInfo.getProfileId()].Name;
    
    if(Trigger.isBefore && Trigger.isUpdate) {
        for(Case updatedCase:Trigger.New)
        {
            // restrict Need Info edit from UI
            if(CaseCRUDHelper.NEED_INFO_EDITED_FROM_UI) {
                if(Trigger.oldMap.get(updatedCase.Id).Status != WalmartConstants.SF_NEED_INFO 
                    && updatedCase.Status == WalmartConstants.SF_NEED_INFO) {
                    
                        updatedCase.addError('Status cannot be changed to Need Info!'
                                            + ' To request info from Seller, please use the Need Info button');
                }
            }
            
            // restrict Edit for cross profiles updating cross record types
            CaseCRUDHelper.verifyProfileAndRestrictEdits(updatedCase, profileName,Trigger.oldMap.get(updatedCase.Id));
        }
        Case caseRecord = Trigger.new[0];
        if(!caseRecord.Jira_Already_Created__c){
            system.debug('inside.. before jira creation..');
            CaseCRUDHelper.runCaseAssignmentRules(caseRecord);
        }
        Autoclosemilestone.CloseResolution(Trigger.New);  
        Autoclosemilestone.Closemilestone(Trigger.New);    
    }

    
    /* 
     * SF to JIRA Status Updates.
     * 
     * The below callout should be only made if the Case Status was updated in SF.
     * It should not be invokved if the Case was updated as a result of JIRA
     * status update done directly in JIRA or on any other Case updates.
     * 
     * The flag is set in the ZIssueTrigger specifying that no JIRA callout should be made.
     * Default flag value is TRUE which determines the callout should be made. 
     * 
     * @see ZIssueTrigger
     * @see SFJIRAIntegrationHelper
     */ 
    if(Trigger.isAfter && Trigger.isUpdate) {
        for(Case updatedCase:Trigger.New)
        {
            system.debug('[CaseTrigger] After update called for... ' + updatedCase.Id + '...new status' + updatedCase.Status);
            if(SFJIRAIntegrationHelper.UPDATE_JIRA_STATUS) {
                system.debug('[CaseTrigger] Before calling SFJIRAIntegrationHelper.updateJIRAStatus...');
                SFJIRAIntegrationHelper.updateJIRAStatus(
                    updatedCase.Id, 
                    Trigger.oldMap.get(updatedCase.Id).Status, updatedCase.Status, 
                    updatedCase.Comments_for_need_info__c);
            }
            system.debug('[CaseTrigger] After calling SFJIRAIntegrationHelper.updateJIRAStatus...');
        }
       
         
        
            
        
    }
    
    
    
    // Phase 3B - Custom Case Assignment Rules
    // OOTB Assignment Rules no more effective for Seller Community Case Types
    if(Trigger.isBefore && Trigger.isInsert) {

        // evaluate the Case based on the assignment rules as defined in 
        // the case rule assignment object
        Case incomingCase = Trigger.new[0];
        
        CaseCRUDHelper.runCaseAssignmentRules(incomingCase);
        CaseCRUDHelper.Redirect_resolutionlEmail(Trigger.New,Trigger.OldMap);
    }
    
    // send notification email to the Integration Lead
    if(Trigger.isAfter && Trigger.isInsert) {
        Case caseRecord = Trigger.new[0];
        CaseCRUDHelper.sendCaseAssignmentEmail(caseRecord);
        
    }
    
    
    
}
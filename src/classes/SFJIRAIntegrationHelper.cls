/**
 * A helper class to facilitate State Transition (currently)
 * between SF and JIRA through zAgile
 * 
 * @author      Cloud Sherpas
 * @createddate 22-Mar-2016
 */ 
public class SFJIRAIntegrationHelper {

    /**
     * Marker variable which determines if update on JIRA status from SF
     * should be invoked or not.
     * This variable is set from SFJIRAIntegrationTrigger to block JIRA callouts
     * when the status updates are done from JIRA to SF to stop cyclic calls.
     * When the status is changed in SF, JIRA callouts should be made.
     */ 
    public static Boolean UPDATE_JIRA_STATUS = true;
    
    
    /**
     * Helper method which takes care of looking up the related Case for a JIRA Issue
     * and update the Status on the Case based on the incoming JIRA Issue's Status
     * 
     * @param issue the JIRA issue being updated from JIRA as stored in zAgile
     */ 
    public static void updateCaseStatus(zsfjira__ZIssue__c issue) {
        
        Id zIssueId = issue.Id;
        List<zsfjira__ZIssue__c> issueList = 
            [SELECT Id, zsfjira__IssueKey__c, zsfjira__Status__c, 
             (SELECT zsfjira__CaseId__r.CaseNumber FROM zsfjira__ZIssue_Case__r)
             FROM zsfjira__ZIssue__c WHERE Id =:zIssueId limit 1];
        
        zsfjira__ZIssue__c issueDetails;
        zsfjira__ZIssue_Case__c relatedCase;
        if(!issueList.isEmpty()) {
            issueDetails = issueList.get(0);
            
            // get the related case, assumption is: only 1 case per issue
            relatedCase = issueDetails.zsfjira__ZIssue_Case__r.get(0);
        }
        
        // get the case to be udpated
        if(relatedCase != null) {
            Case caseRecord = 
                [select Id, CaseNumber, Status from Case where Id = :relatedCase.zsfjira__CaseId__c limit 1];
            
            system.debug('Case Details - ' + caseRecord.CaseNumber);
            system.debug('JIRA Status - ' + issueDetails.zsfjira__Status__c);
            
            // make Case status updates
            if(issueDetails.zsfjira__Status__c == WalmartConstants.JIRA_NEW) {
                caseRecord.Status = WalmartConstants.SF_NEW;
            }
            
            if(issueDetails.zsfjira__Status__c == WalmartConstants.JIRA_WORK_IN_PROGRESS) {
                   caseRecord.Status = WalmartConstants.SF_WORK_IN_PROGRESS;
            }
            
            if(issueDetails.zsfjira__Status__c == WalmartConstants.JIRA_READY_TO_START) {
                caseRecord.Status = WalmartConstants.SF_READY_TO_START;
            }
            
            if(issueDetails.zsfjira__Status__c == WalmartConstants.JIRA_READY_FOR_REVIEW) {
                caseRecord.Status = WalmartConstants.SF_RESOLVED;
            }
            
            if(issueDetails.zsfjira__Status__c == WalmartConstants.JIRA_NEED_INFO) {
                // mark this flag else validation rule will be fired
                CaseCRUDHelper.NEED_INFO_EDITED_FROM_UI = false;
                caseRecord.Status = WalmartConstants.SF_NEED_INFO;
            }
            
            
            if(issueDetails.zsfjira__Status__c == WalmartConstants.JIRA_DONE) {
                caseRecord.Status = WalmartConstants.SF_CLOSED;
            }
            
            update caseRecord;
        }
    }
    
    
    /**
     * A method which takes care of updating the JIRA Transition by making JIRA API callout
     * whenever a Case's status is changed in Salesforce 
     * 
     * @param caseId    the case id representing the case record being updated
     */
    @future (callout = true)
    public static void updateJIRAStatus(String caseId, String oldStatus, String newStatus, String commentsForNeedInfo) {
        
        system.debug('[SFJIRAIntegrationHelper]Update JIRA Status method invoked.');
        system.debug('[SFJIRAIntegrationHelper]Case Old Status - ' + oldStatus);
        system.debug('[SFJIRAIntegrationHelper]Case New Status - ' + newStatus);
        
        // should not be fired if it was a general update and not status change updates
        if(newStatus == oldStatus) {
            system.debug('[SFJIRAIntegrationHelper]No Status change, not making JIRA callouts.');
            return;
        }
        
        String transitionId = JIRAUtility.getTransitionId(oldStatus, newStatus);
        
        // invoke a JIRA callout only if there was a transition id returned
        if(transitionId != null) { 
            system.debug('[SFJIRAIntegrationHelper]Attempting to update JIRA Status with transition id - ' + transitionId);
            
            JIRA_CONFIG__c jiraConfig = JIRA_CONFIG__c.getValues('CONFIG');
            String jiraIssueKey = JIRAUtility.getRelatedJIRAIssueKey(caseId);
            Boolean isNeedInfo = (newStatus == WalmartConstants.SF_NEED_INFO ? true : false);
            
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            Http http = new Http();
            
            Blob headerValue = Blob.valueOf(jiraConfig.UserName__c + ':' + jiraConfig.Password__c);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader);
            req.setHeader('Content-Type','application/json');
            
            String endpoint = jiraConfig.URL__c + '/rest/api/2/issue/' + jiraIssueKey + '/transitions';
            
            req.setMethod('POST');
            req.setEndpoint(endpoint);
            
            if(isNeedInfo) { // need info needs comments too
                req.setBody(
                    '{\"update\": {\"comment\": [{\"add\": {\"body\": \"' + commentsForNeedInfo + '\"}}]},'
                    + '\"transition\": {\"id\": \"' + transitionId + '\"}}');                
            } else {
                req.setBody('{ \"transition\": {\"id\": \"' + transitionId + '\"}}');    
            }
            
            system.debug('[SFJIRAIntegrationHelper]Request - ' + req.getBody());
            system.debug('SFJIRA Request.. '+req);
            try {
                if(!Test.isRunningTest()) {
                    res = http.send(req);
                }
                system.debug('[SFJIRAIntegrationHelper]Response - ' + res.toString());
            } catch(System.CalloutException e) {
                System.debug('[SFJIRAIntegrationHelper]Error updating JIRA Status - ' + res.toString());
            }            
        }
    }
}
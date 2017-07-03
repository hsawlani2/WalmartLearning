/**
 * A utility class to help with JIRA related operations.
 * 
 * @author      Cloud Sherpas
 * @createddate 24-Mar-2016
 */ 
public class JIRAUtility {

    
    /* The map which contains the transition ids based on case status. The key of the map is constructed
     * as oldStatus::newStatus, so while getting the transition id for particular status, construct the
     * key and pass it accordingly.
     */
    private static Map<String, String> transitionIdMap = new Map<String, String>();
    
    // sort of init block, populating the transitionIdMap
    static {
        transitionIdMap.put(WalmartConstants.SF_NEW + '::' + WalmartConstants.SF_NEED_INFO, '401');
        transitionIdMap.put(WalmartConstants.SF_NEW + '::' + WalmartConstants.SF_WORK_IN_PROGRESS, '481');
        transitionIdMap.put(WalmartConstants.SF_NEW + '::' + WalmartConstants.SF_READY_TO_START, '421');
        transitionIdMap.put(WalmartConstants.SF_NEW + '::' + WalmartConstants.SF_CLOSED, '351');
        
        transitionIdMap.put(WalmartConstants.SF_WORK_IN_PROGRESS + '::' + WalmartConstants.SF_RESOLVED, '361');
        transitionIdMap.put(WalmartConstants.SF_WORK_IN_PROGRESS + '::' + WalmartConstants.SF_READY_TO_START, '441');
        transitionIdMap.put(WalmartConstants.SF_WORK_IN_PROGRESS + '::' + WalmartConstants.SF_NEED_INFO, '451');
        transitionIdMap.put(WalmartConstants.SF_WORK_IN_PROGRESS + '::' + WalmartConstants.SF_NEW, '331');
        transitionIdMap.put(WalmartConstants.SF_WORK_IN_PROGRESS + '::' + WalmartConstants.SF_CLOSED, '351');
        
        transitionIdMap.put(WalmartConstants.SF_RESOLVED + '::' + WalmartConstants.SF_WORK_IN_PROGRESS, '371');
        transitionIdMap.put(WalmartConstants.SF_RESOLVED + '::' + WalmartConstants.SF_CLOSED, '351');

        transitionIdMap.put(WalmartConstants.SF_CLOSED + '::' + WalmartConstants.SF_WORK_IN_PROGRESS, '381');

        transitionIdMap.put(WalmartConstants.SF_NEED_INFO + '::' + WalmartConstants.SF_NEW, '461');
        transitionIdMap.put(WalmartConstants.SF_NEED_INFO + '::' + WalmartConstants.SF_WORK_IN_PROGRESS, '471');
         transitionIdMap.put(WalmartConstants.SF_NEED_INFO + '::' + WalmartConstants.SF_READY_TO_START, '501');

        transitionIdMap.put(WalmartConstants.SF_READY_TO_START + '::' + WalmartConstants.SF_WORK_IN_PROGRESS, '411');
        transitionIdMap.put(WalmartConstants.SF_READY_TO_START + '::' + WalmartConstants.SF_NEW, '431');
        transitionIdMap.put(WalmartConstants.SF_READY_TO_START + '::' + WalmartConstants.SF_NEED_INFO, '491');
    }
    

    /**
     * Helper method to retrieve the related JIRA Issue Key from zAgile record based
     * on the Case.
     * 
     * Assumption is: there's always a 1:1 relationship between Case to JIRA Issue
     * 
     * @param caseId    the case for which the related issue is to be fetched
     * @return the JIRA issue key as stored in zAgile records
     */ 
    public static String getRelatedJIRAIssueKey(String caseId) {
        
        system.debug('Looking up JIRA Issue for Case Id - ' + caseId);
        String jiraKey;
        // get the associated issue id
        zsfjira__ZIssue_Case__c zIssueCase;
        List<zsfjira__ZIssue_Case__c> zIssueCaseList = 
            [SELECT zsfjira__ZIssueId__c FROM zsfjira__ZIssue_Case__c WHERE zsfjira__CaseId__c = :caseId limit 1];
        if(zIssueCaseList.size() > 0) {
            zIssueCase = zIssueCaseList.get(0);
            
            // now get the JIRA Issue key
            List<zsfjira__ZIssue__c> zIssueList = 
                [SELECT Id, zsfjira__IssueId__c, zsfjira__IssueKey__c FROM zsfjira__ZIssue__c WHERE Id = :zIssueCase.zsfjira__ZIssueId__c limit 1];
            if(zIssueList.size() > 0) {
                jiraKey = (zIssueList.get(0)).zsfjira__IssueKey__c;
                system.debug('Found Related JIRA Issue - ' + jiraKey);
            }
        }
        return jiraKey;
    }
    
    
    /**
     * Helper method to retrieve the related JIRA Issue Status from zAgile record based
     * on the Case.
     * 
     * Assumption is: there's always a 1:1 relationship between Case to JIRA Issue
     * 
     * @param caseId    the case for which the related issue is to be fetched
     * @return the JIRA issue status as stored in zAgile records
     */ 
    public static String getRelatedJIRAIssueStatus(String caseId) {
        
        system.debug('Looking up JIRA Issue Status for Case Id - ' + caseId);
        String jiraStatus;
        // get the associated issue id
        zsfjira__ZIssue_Case__c zIssueCase;
        List<zsfjira__ZIssue_Case__c> zIssueCaseList = 
            [SELECT zsfjira__ZIssueId__c FROM zsfjira__ZIssue_Case__c WHERE zsfjira__CaseId__c = :caseId limit 1];
        if(zIssueCaseList.size() > 0) {
            zIssueCase = zIssueCaseList.get(0);
            
            // now get the JIRA Issue key
            List<zsfjira__ZIssue__c> zIssueList = 
                [SELECT Id, zsfjira__IssueId__c, zsfjira__IssueKey__c, zsfjira__Status__c
                 FROM zsfjira__ZIssue__c WHERE Id = :zIssueCase.zsfjira__ZIssueId__c limit 1];
            if(zIssueList.size() > 0) {
                jiraStatus = (zIssueList.get(0)).zsfjira__Status__c;
                system.debug('Found Related JIRA Issue - ' + (zIssueList.get(0)).zsfjira__IssueKey__c 
                             + ' with Status as - ' + jiraStatus);
            }
        }
        return jiraStatus;
    }
    
    
    /**
     * A helper method to return the SF Case status values viz., New, WIP, Resolved, Closed
     * based on the equivalent JIRA issue status'. E.g., Work in Progress in JIRA ~ WIP in SF.
     * 
     * @param jiraStatus
     */ 
    public static String getSFEquivalentCaseStatus(String jiraStatus) {
        String caseStatus;

        if(WalmartConstants.JIRA_NEW == jiraStatus) {
            caseStatus = WalmartConstants.SF_NEW;
        }

        if(WalmartConstants.JIRA_WORK_IN_PROGRESS == jiraStatus) {
            caseStatus = WalmartConstants.SF_WORK_IN_PROGRESS;
        }

        if(WalmartConstants.JIRA_READY_TO_START == jiraStatus) {
            caseStatus = WalmartConstants.SF_READY_TO_START;
        }

        if(WalmartConstants.JIRA_READY_FOR_REVIEW == jiraStatus) {
            caseStatus = WalmartConstants.SF_RESOLVED;
        }
        
        if(WalmartConstants.JIRA_DONE == jiraStatus) {
            caseStatus = WalmartConstants.SF_CLOSED;
        }

        return caseStatus;
    }
    
    
    /**
     * Method to return the related case record details associated with
     * the JIRA Issue.
     * 
     * It is assumed that there is always 1-1 relationship between
     * Case and JIRA Issue
     * 
     * @param zIssueId  the zIssueRecord id
     * @return associated case record details
     */ 
    public static Case getRelatedCaseDetails(Id zIssueId) {

        // get the list of zIssues
        List<zsfjira__ZIssue__c> issueList = 
            [SELECT Id, zsfjira__IssueKey__c, zsfjira__Status__c, 
             (SELECT zsfjira__CaseId__r.CaseNumber FROM zsfjira__ZIssue_Case__r)
             FROM zsfjira__ZIssue__c WHERE Id =:zIssueId limit 1];
        
        zsfjira__ZIssue__c issueDetails;
        zsfjira__ZIssue_Case__c relatedCase;
        
        // from the list, get the zIssueCase details
        if(!issueList.isEmpty()) {
            issueDetails = issueList.get(0);
            
            // get the related case, assumption is: only 1 case per issue
            relatedCase = issueDetails.zsfjira__ZIssue_Case__r.get(0);
        }
        
        // get the case details now
        Case caseRecord;
        if(relatedCase != null) {
            caseRecord = 
                [select Id, CaseNumber, Status from Case where Id = :relatedCase.zsfjira__CaseId__c limit 1];
        }
        return caseRecord;
    }
    
    
    /**
     * A helper method to return the correct transition id based on the Case's old vs. new status.
     * 
     * Below is the available transition ids in JIRA based on the Case old vs. current status
     * 
     * Old Status       -->         Current Status      Issue Update Status (and the respective Transition Id in JIRA)
     * New              -->         Need Info           Need Info (401)
     * New              -->         WIP                 WIP (481)
     * New              -->         Ready to Start      Ready to Start (421)
     * New              -->         Closed              Done (351)
     * WIP              -->         Resolved            Ready for Review (361)
     * WIP              -->         Ready to Start      Ready to Start (441)
     * WIP              -->         Need Info           Need Info (451)
     * WIP              -->         New                 Return to New (331)
     * WIP              -->         Closed              Done (351)
     * Resolved         -->         WIP                 Back to WIP (371)
     * Resolved         -->         Closed              Done (351)
     * Closed           -->         WIP                 Return to WIP (381)
     * Need Info        -->         New                 Return to New (461)
     * Need Info        -->         WIP                 Return to WIP (471)
     * Need Info        -->         Ready to Start      Ready to Start (501)
     * Ready to Start   -->         WIP                 Work in Progress (411)
     * Ready to Start   -->         New                 Return to New (431)
     * Ready to Start   -->         Need Info           Need Info(491)
     * 
     *
     * @param oldCaseStatus the previous case status
     * @param newCaseStatus the current case status
     * @return the appropriate transition id based on the JIRA compatibility
     */ 
    public static String getTransitionId(String oldCaseStatus, String newCaseStatus) {
        return transitionIdMap.get(oldCaseStatus + '::' + newCaseStatus);
    }
}
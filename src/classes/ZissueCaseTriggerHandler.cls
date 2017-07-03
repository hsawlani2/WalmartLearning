public class ZissueCaseTriggerHandler {
     public static void afterInsert(list<zsfjira__ZIssue_Case__c> lstzissue){
        List<Case> caseList = new List<Case>();
        List<zsfjira__ZIssue__c> zissueList = new List<zsfjira__ZIssue__c>();
        List<Id> caseIds = new List<Id>();
        List<Id> zissueIds = new List<Id>();
        Map<String, zsfjira__ZIssue_Case__c > caseZissueMap = new Map<String, zsfjira__ZIssue_Case__c>();
        Map<Id,zsfjira__ZIssue__c > Zissuemap = new Map<Id,zsfjira__ZIssue__c >();
        
        List<Case> updateList = new List<Case>();
        
        for(zsfjira__ZIssue_Case__c z:lstzissue){
            caseIds.add(z.zsfjira__CaseId__c);
            zissueIds.add(z.zsfjira__ZIssueId__c);
            caseZissueMap.put(z.zsfjira__CaseId__c,z);
        }

        caseList = [SELECT Id,Jira_Ticket__c FROM CASE WHERE ID IN: caseIds];
        zissueList = [SELECT Id,Name,zsfjira__IssueKey__c FROM zsfjira__ZIssue__c WHERE ID IN:zissueIds];
        
        for(zsfjira__ZIssue__c zissue:zissueList ){
        Zissuemap.put(zissue.Id,zissue );
               }

        for(CASE c:caseList){
            system.debug('case id:'+c.id);
            if(c.Jira_Ticket__c == null){
                if(caseZissueMap.containskey(c.Id)){
                    zsfjira__ZIssue_Case__c zissue=caseZissueMap.get(c.Id);
                    
                    zsfjira__ZIssue__c zsfjira = Zissuemap.get(zissue.zsfjira__ZIssueId__c);
                    
                    if(zsfjira.Name!= null){
                    c.Jira_Ticket__c = zsfjira.Name; 
                    updateList.add(c);
                    }
                }

            }
            
        }
        if(updateList.size()>0){
            update updateList;
        }
        
    }

 
}
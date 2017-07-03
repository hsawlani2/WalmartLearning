trigger ZissueCaseTrigger on zsfjira__ZIssue_Case__c (after insert) {
    
    if(Trigger.isInsert && Trigger.isAfter) {
    /*
        if(Trigger.isInsert && Trigger.isAfter){
        for(zsfjira__ZIssue_Case__c zs : Trigger.New){
            if(zs.zsfjira__CaseId__r.Sub_Category_2__c == null || zs.zsfjira__CaseId__r.Sub_Category_3__c == null){
                zs.addError('Sub Category 2 and Sub Category 3 can not be none.');
            }
        }
    }
    */
         SFJIRAIntegrationHelper.UPDATE_JIRA_STATUS = false;
         ZissueCaseTriggerHandler.afterInsert(Trigger.new);


     }

}
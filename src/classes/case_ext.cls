public without sharing class case_ext {

    public Id caseId{get;set;}
    public String caseComment{get;set;}
    public String successMessage{get;set;}
    private case reopenedCase{get;set;}
    public case_ext(ApexPages.StandardController controller) {
        caseId = apexpages.currentpage().getparameters().get('id');
        reopenedCase = new Case(Id = caseId);    
    }
    public void validateComment(){
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'You must explain why you are reopening this case'));
    }
    public pagereference saveReopen(){
           System.debug('caseComment===>'+caseComment);
            reopenedCase = new Case(Id = caseId);
            system.debug('###reopenedCase'+reopenedCase);
            reopenedCase.Status = 'WIP';
            list<zsfjira__ZIssue_Case__c> allZIssueCases=new list<zsfjira__ZIssue_Case__c>();
            /*if(caseId!=null){
                allZIssueCases= [SELECT zsfjira__CaseId__c,zsfjira__ZIssueId__c FROM zsfjira__ZIssue_Case__c where zsfjira__CaseId__c=:caseId];
            }*/
            update reopenedCase;
           system.debug('###22reopenedCase'+reopenedCase);
            CaseComment casecomm = new CaseComment();
            /*If(allZIssueCases!=null && !allZIssueCases.isEmpty()){
                casecomm.CommentBody = 'JIRA# '+caseComment;
            }
            else{
                casecomm.CommentBody = caseComment;    
            }*/
            casecomm.CommentBody = caseComment; 
            casecomm.ParentId = caseId;
            insert casecomm;
            
             Pagereference caseStd =new ApexPages.StandardController(reopenedCase).view(); //new pagereference('/'+reopenedCase.Id);
             //Pagereference caseStd =new pagereference('/cases/'+caseId);
             caseStd.setRedirect(false);
            return caseStd;
   }
    
     public pagereference cancelReopen(){
        try{ 
            Pagereference caseStd =new PageReference('/cases'+'/'+caseId); 
            caseStd.setRedirect(true);
            return caseStd; 
        }
        catch(Exception ex){
            ApexPages.addMessages(ex);
        }   
        return null;
    }
    
        

}
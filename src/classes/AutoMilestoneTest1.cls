@isTest
Private class AutoMilestoneTest1 {

    static testMethod void CompleteFirstResponse(){
      
          //system.debug('Milestone:'+[Select Name, Id From MilestoneType]);
            //system.debug('User:'+UserInfo.getUserType());
        List<Account> acts = new List<Account>();
        Account myAcc = new Account(Name='TestAct', phone='1001231234');
        acts.add(myAcc);
        
        Account busAcc = new Account(Name = 'TestForMS', phone='4567890999');
        acts.add(busAcc);
        insert acts;
        
        Contact cont = new Contact(FirstName = 'Test', LastName = 'LastName', phone='4567890999',
        accountid = busAcc.id);
        insert(cont);
        
        Id contactId = cont.Id;
        Entitlement entl = new Entitlement(Name='Onboarding Team', AccountId=busAcc.Id,StartDate=Date.valueof(System.now().addDays(-2)), 
        EndDate=Date.valueof(System.now().addYears(2)));
        insert entl;
        
        List<SlaProcess> lstEntitlementProcess = [SELECT Id, Name FROM SlaProcess WHERE Name='Onboarding Team' and IsActive = true LIMIT 1];
            if (lstEntitlementProcess.size()>0)
            {
                entl.SlaProcessId = lstEntitlementProcess[0].id;
                update entl;        
            }
        
        String entlId;
        if (entl != null)
        entlId = entl.Id;
        
        List<Case> cases = new List<Case>{};
        Id RecId;
        for(recordtype orecordtype:[SELECT Id, developername FROM recordtype where developername='Seller_Community_Onboarding_Case']){
            RecId = orecordtype.Id;
        }
        
        if (entlId != null){
        Case c;
        c = new Case(Subject = 'Test Case with Entitlement ',
        EntitlementId = entlId, ContactId = contactId,SlaStartDate=system.today(),recordtypeid=RecId);
        cases.add(c);
        c = new Case(Subject = 'Test Case with Entitlement ',
        EntitlementId = entlId, ContactId = contactId,SlaStartDate=system.today(),Status = 'Resolved',recordtypeid=RecId);
        cases.add(c);
        c = new Case(Subject = 'Test Case with Entitlement ',
        EntitlementId = entlId, ContactId = contactId,SlaStartDate=system.today(),Status = 'Closed',recordtypeid=RecId);
        cases.add(c);
        }
        
        if (cases.isEmpty()==false){
            insert cases;
            List<Id> caseIds = new List<Id>();
                for (Case cL : cases){
                    caseIds.add(cL.Id);
                }
            
            
            list<CaseComment>lstComment = new list<CaseComment>();
                CaseComment oCaseComment;
                oCaseComment = new CaseComment();
                oCaseComment.CommentBody = 'Test';
                oCaseComment.IsPublished = true;
                oCaseComment.ParentId = cases[0].Id;
                lstComment.add(oCaseComment);
                insert lstComment;
                
        }
   }
}
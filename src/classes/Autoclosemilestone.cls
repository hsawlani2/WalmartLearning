public class Autoclosemilestone{
  public static Id getMilestoneTypeId(string sMileStoneTypeName){
    map<string,Id> mapNameWiseType = new map<string,Id>();
    for(MilestoneType oMilestoneType : [Select Name, Id From MilestoneType]){
      mapNameWiseType.put(oMilestoneType.Name,oMilestoneType.Id);
    }
    string sId;
    if(mapNameWiseType.containsKey(sMileStoneTypeName)){
      sId = mapNameWiseType.get(sMileStoneTypeName);
    }
    return sId;
  }
  
  public static void CompleteFirstResponse( list<casecomment> lstCasecomment)   {
    if (UserInfo.getUserType() == 'Standard'){
      DateTime completionDate = System.now();
      List<Id> caseIds = new List<Id>();
      for (CaseComment cc : lstCasecomment){
        if(cc.IsPublished == true)
        caseIds.add(cc.ParentId);
        system.debug('caseid'+caseIds);
      }
      if (caseIds.isEmpty() == false){
        List<Case> caseList = [Select c.Id, c.ContactId, c.Contact.Email,c.OwnerId, c.Status,c.EntitlementId, c.SlaStartDate,c.SlaExitDate From Case c Where c.Id IN :caseIds];
        if (caseList.isEmpty() == false){
          List<Id> updateCases = new List<Id>();
          for (Case caseObj:caseList) {
            if ((caseObj.EntitlementId != null)&&(caseObj.SlaStartDate <= completionDate)&&(caseObj.SlaStartDate != null)&&(caseObj.SlaExitDate == null))
              updateCases.add(caseObj.Id);
            system.debug('updateCases'+updateCases);
          }
          
          if(updateCases.isEmpty() == false){
            //milestoneUtils.completeMilestone(updateCases,'557V000000000LyIAI', completionDate);
            string sMilestoneTypeId = getMilestoneTypeId('First Response Time');
            milestoneUtils.completeMilestone(updateCases,sMilestoneTypeId, completionDate);
          }
          
        }
      }
    }
    
    
    
  }
  
  public static void CloseResolution( list<case> lstCase){
    if (UserInfo.getUserType() == 'Standard'){
      DateTime completionDate = System.now();
      List<Id> updateCases = new List<Id>();
      for (Case c : lstCase){
        if (((c.Status == 'Resolved'))&&((c.SlaStartDate<= completionDate)&&(c.SlaExitDate == null)))
          updateCases.add(c.Id);
      }
      if (updateCases.isEmpty() == false){
        //milestoneUtils.completeMilestone(updateCases, '557V000000000M3', completionDate);
        string sMilestoneTypeId = getMilestoneTypeId('Resolution Time');
        milestoneUtils.completeMilestone(updateCases, sMilestoneTypeId, completionDate);
      }
    }
    
    
  }
  
  public static void Closemilestone( list<case> lstCase){
    if (UserInfo.getUserType() == 'Standard'){
      DateTime completionDate = System.now();
      List<Id> updateCases = new List<Id>();
      for (Case c : lstCase){
        if (((c.Status == 'Closed'))&&((c.SlaStartDate<= completionDate)&&(c.SlaExitDate == null)))
          updateCases.add(c.Id);
      }
      if (updateCases.isEmpty() == false){
        
          string sResolutionMilestoneTypeId = getMilestoneTypeId('Resolution Time');
        milestoneUtils.completeMilestone(updateCases, sResolutionMilestoneTypeId, completionDate);
          
          completionDate = System.now();
        //milestoneUtils.completeMilestone(updateCases, '557V000000000M8', completionDate);
        string sMilestoneTypeId = getMilestoneTypeId('Total Ticket Life');
        milestoneUtils.completeMilestone(updateCases, sMilestoneTypeId, completionDate);
        
      }
    }
    
    
  }
  
  
}
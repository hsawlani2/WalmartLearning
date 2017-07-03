global class WebServiceHelper {
    webservice static string sendapplication(string leadId){
                    String sResult = '';
                    Lead oLead;
                    for(Lead oTempLead :[Select Id,Webtolead__c,ApplicationSent__c,Status,Email,FirstName,LastName,Company,(Select Id,ApplicationSent__c From Applications__r) From lead where id =:leadId]){
                        oLead = oTempLead;
                    }

                if(oLead.Webtolead__c){
                    if(oLead.ApplicationSent__c){
                        sResult = 'false|The email has been sent already';
                        return sResult;
                    }
                    else {
                        oLead.ApplicationSent__c= true;
                        update oLead;
                        
                        Application__c oApplication;
                        for(Application__c oTempApplication: oLead.Applications__r){
                            oApplication = oTempApplication;
                        }
                        
                        oApplication.ApplicationSent__c = true;
                        update oApplication; 
                        
                        //send email here
                        sendemail('First_Email',oLead.Id,oApplication.Id);
                        sResult = 'true';
                    }
                }
                else{
                    
                    if(oLead.Status=='Prospect'){
                        Application__c oApplication;
                        if(oLead.Applications__r!=null && oLead.Applications__r.size()>0){
                            for(Application__c oTempApplication:oLead.Applications__r){
                                oApplication = oTempApplication;
                            }
                        }
                        else{
                            oApplication = new Application__c();
                         oApplication.Primary_Contact_Email__c = oLead.Email;
                         oApplication.Primary_Contact_First_Name__c = oLead.FirstName;
                         oApplication.Primary_Contact_Last_Name__c = oLead.LastName;
                         oApplication.Legal_Company_Name__c = oLead.Company;
                         oApplication.Lead__c = oLead.Id;
                         if(!oLead.ApplicationSent__c){
                         	oApplication.ApplicationSent__c = true;
                         }
                         insert oApplication;
                        }
                        if(!oLead.ApplicationSent__c){
                            
                            oLead.ApplicationSent__c= true;
                            update oLead;
                            
                            oApplication.ApplicationSent__c = true;
                            update oApplication;
                            
                            sendemail('First_Email',oLead.Id,oApplication.Id);
                            sResult = 'true';
                        }
                        else{
                            sResult = 'false|The email has been sent already';
                            return sResult;
                        }
                    }
                    else {
                    	 sResult ='false| Application can be sent only to a Prospect';
                    	 return sResult;
                    }


                } 
                    return sResult;
    }
    
    private static void sendemail(string sTemplate,Id leadId,Id AppId){

        String userName = UserInfo.getUserName();
        User activeUser = [Select Email, Name  From User where Username = : userName limit 1];
        String userEmail = activeUser.Email;
        String userWholeName = activeUser.Name;

        Id emailTemplateId;
                    
                    for(EmailTemplate oET : [Select Id From EmailTemplate Where DeveloperName = :sTemplate limit 1]){
                        emailTemplateId = oET.Id;
                    }
                    
                    list<Messaging.SingleEmailMessage> lstMail = new list<Messaging.SingleEmailMessage>();
                    Messaging.SingleEmailMessage oSingleEmailMessage = Messaging.renderStoredEmailTemplate(emailTemplateId,leadId,AppId);
                    string sSubject = oSingleEmailMessage.getSubject();
                    string sHtmlBody = oSingleEmailMessage.getHtmlBody();
                    oSingleEmailMessage.setTargetObjectId(leadId);
                    oSingleEmailMessage.setSubject(sSubject);
                    oSingleEmailMessage.setHtmlBody(sHtmlBody);
                    //oSingleEmailMessage.setTemplateId(emailTemplateId);
                    //oSingleEmailMessage.setWhatId(AppId);    
                    oSingleEmailMessage.setSenderDisplayName(userWholeName);
                    oSingleEmailMessage.setSaveAsActivity(true);  
               
                    System.debug('@Developer --> oSingleEmailMessage :' + oSingleEmailMessage);
                    
                    lstMail.add(oSingleEmailMessage);
                    
                    if(lstMail.size() > 0){
                        Messaging.sendEmail(lstMail);
                    }
    }
    
    webservice static string convertlead(string leadId){
    	String sResult = '';
    	string sMessage ='You cannot convert a lead which is tied to application.';
    	string sSucessUrl = '/lead/leadconvert.jsp?retURL=%2F'+leadId+'&id='+leadId+'&common.udd.actions.ActionsUtilORIG_URI=%2Flead%2Fleadconvert.jsp';
    	sResult = 'true|'+sSucessUrl;
    	list<Application__c> lstApplications = [Select Id From Application__c Where Lead__c=:leadId];
    	if(lstApplications!=null && lstApplications.size()>0){
    		sResult = 'false|'+sMessage;
    	}
    	return sResult;
    }
     
    webservice static string checkUser(string emailAddress){
    	 String sResult = '';
    	 sResult = 'true|';
    	 string sMessage = System.Label.userValidationError;
    	 /*User oUser;
      for(User oTempUser : [select id from User where Profile.Name = 'Seller Community User' AND Email =:emailAddress]){
        oUser = oTempUser;
      }
      if(oUser != null){
       sResult = 'false|'+sMessage;   
      }*/
      Lead oLead = new Lead();
    	 oLead.Email = emailAddress;
      BDDedupController userDedupAction = new BDDedupController('DuplicateUserCheckAction');
      List<SObject> matchedDuplicateRows = userDedupAction.executeNew(oLead, User.getSobjectType(), null);
      if(matchedDuplicateRows.size()>0){
      	sResult = 'false|'+sMessage;
      }
      
      	 
    	 return sResult;
    }
      webservice static string checkLead(string emailAddress){
    	 String sResult = '';
    	 sResult = 'true|';
    	 string sMessage = System.Label.leadValidationError;
    	 string sApplicationLink ='';
    	 string sMatchedLeadId ='';
    	 Lead oLead = new Lead();
    	 oLead.Email = emailAddress;
    	 BDDedupController leadDedupAction = new BDDedupController('DuplicateLeadCheckAction');
    		List<SObject> matchedDuplicateRows = leadDedupAction.executeNew(oLead, Lead.getSobjectType(), null);
						if(matchedDuplicateRows!=null && matchedDuplicateRows.size()>0){
							//Generate Link after Lead Check.
        BDDedupController appLinkGnrtAction = new BDDedupController('ApplicationLinkGenerationAction');
        List<SObject> matchedApplicationRows = appLinkGnrtAction.executeNew(oLead, Lead.getSobjectType(), matchedDuplicateRows);
        if(matchedApplicationRows!=null && matchedApplicationRows.size()>0){
        	sApplicationLink = appLinkGnrtAction.actionStatus;
        }
        for(SObject oObj:matchedDuplicateRows){
			    		sMatchedLeadId = string.valueOf(oObj.get('Id'));
			    	}
        sResult = 'false|'+sMessage+'|'+sApplicationLink+'|'+sMatchedLeadId;
						}
    	 
    	 return sResult;
    }
}
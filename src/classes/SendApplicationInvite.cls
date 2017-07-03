global class SendApplicationInvite {
    
    webservice static void sendApplicationInvite(String opportunity, String contactId) {
        
        String userName = UserInfo.getUserName();
        User activeUser = [Select Email, Name  From User where Username = : userName limit 1];
        String userEmail = activeUser.Email;
        String userWholeName = activeUser.Name;
       
        List<EmailTemplate> templateList = [Select Id from EmailTemplate where name = 'Invite to Apply Email (Tier 1/2/3)' AND IsActive = true];
        
        Opportunity theOpp = [SELECT Application_Sent__c FROM Opportunity WHERE Id =:opportunity];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(contactId);
        
        if (templateList.size() > 0) {
            mail.setTemplateId(templateList[0].Id);    
        }
        mail.setReplyTo(userEmail);
        mail.setSenderDisplayName(userWholeName);
        mail.setWhatId(opportunity);
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setSaveAsActivity(true); 
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
        theOpp.Application_Sent__c = true;
        update theOpp;
    }

}
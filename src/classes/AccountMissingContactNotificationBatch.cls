global class AccountMissingContactNotificationBatch implements Database.batchable<sObject>, Database.Stateful{
    global set<string> accountIdSet;
    global map<Id, Account> accountmap;
    
    global AccountMissingContactNotificationBatch(){
        accountIdSet = new set<string>();
        accountMap   = new map<Id, Account>();
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        string accountType = 'Seller';
        date createdDate = system.today().addYears(-1);
        
        if(Test.isRunningTest())
            createdDate = system.today();
        
        String mprecordType='MP_Account';       
        string query = ' select Id, Name, Customer_Service_Email__c, Missing_Contact_Email_Sent__c, '+
                       ' Last_Email_Sent__c, Primary_Contact__c, Primary_Contact__r.Email, OwnerId, Owner.Email, '+
                       ' (select Id, Email, Contact_Type__c '+
                       ' from Contacts) '+
                       ' from Account where RecordType.DeveloperName=:mprecordType';
        
        system.debug('accountIdSet :::::'+ accountIdSet);
        
        if(accountIdSet != null && accountIdSet.size() > 0)
            query += ' and id in : accountIdSet order by Name';
        else{
            query += ' and Type =: accountType'+
                     ' and CreatedDate =: createdDate'+
                     ' order by Name';
        }
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext info, list<Account> scope) {
        map<string, Contact_Types__c> contactTypes = Contact_Types__c.getAll();  // fetching teh custom setting the data ...
        
        for(Account acc : scope){
                           
            set<string> conEmails = new set<string>();
            set<string> conTypes  = new set<string>();
            string contactId;
            for(Contact c : acc.Contacts){
                if(c.Contact_Type__c != null)
                    conTypes.addAll(c.Contact_Type__c.split(';'));
                if(c.Email != null){
                    conEmails.add(c.Email);
                    contactId = c.Id;
                }
            }
            
            if(contactId == null)
                contactId = acc.Primary_Contact__c;
            
            list<string> templist = checkContactTyeps(contactTypes.Keyset(), conTypes);
            
            if(templist != null && 
               templist.size() > 0 && 
              (acc.Customer_Service_Email__c != null || acc.Primary_Contact__r.Email != null))
            {
                sendEmail(acc, conEmails, contactId);
                
                
                accountMap.put(acc.Id, new Account(Id = acc.Id));
            }
        }
    }
    
    
    /*******************************************************************************************************
    * @description checking for the missing contact_type
    * @param 
    * @return the describe field result for the given field
    * @example
    * list<AccountModel> a = new list<AccountModel>();
    */
    private list<string> checkContactTyeps(set<string> orgValues, set<string> avlValues){
        list<string> templist = new list<string>();
        for(string s : orgValues){
            if(!avlValues.contains(s)){
                templist.add(s);
            }
        }
        return templist;
    }
    
    
    /*******************************************************************************************************
    * @description checking for the missing contact_type
    * @param 
    * @return the describe field result for the given field
    * @example
    * List<AccountModel> a = new List<AccountModel>();
    */
    private void sendEmail(Account acc, set<string> toEmailList, string contactId){
        string emailTemplateId;
        
        list<EmailTemplate> emailTemplateList = [select id, Name from EmailTemplate where DeveloperName = 'Missing_Contact_Notification_Template'];
        if(emailTemplateList.size() > 0)
            emailTemplateId = emailTemplateList[0].Id;
                   
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        
        list<string> toEmails = new list<string>();
        list<string> ccEmails = new list<string>();
        
        if(acc.Customer_Service_Email__c != null)
            toEmails.add(acc.Customer_Service_Email__c);
            
        if(acc.Primary_Contact__r.Email != null)
            toEmails.add(acc.Primary_Contact__r.Email);
        
        toEmails.addAll(toEmailList);
        
        msg.setToAddresses(toEmails);
        //msg.setCCAddresses(new list<string>{acc.Owner.Email});
        msg.setTargetObjectId(contactId);
        msg.setWhatId(acc.Id);
        msg.setTemplateId(emailTemplateId);
        msg.setSaveAsActivity(false);
               
        emails.add(msg);
        
        //Send all emails in the master list
        if(!Test.isRunningTest()){
            Messaging.sendEmail(emails);
        }    
    }
    
    
    global void finish(Database.BatchableContext info) {}
}
/*******************************************************************************************************
    * @name WalmartMissingContactsCntrl
    *     
*/
public class WalmartMissingContactsCntrl{

    public list<list<AccountModal>> accModListofList {get;set;}
    public list<SelectOption> contactTypeList {get;set;}
    public string selAccId {get;set;}
    public integer accCount {get;set;}
    public integer missingAddressCount {get;set;}
    public integer missingCTCount {get;set;}
    
    public integer singleEmailMax {get;set;}
    public integer singleEmailRemaining {get;set;}
    
    public integer pageSize {get;set;}
    public integer pageNumber {get;set;}
    public integer totalRecords {get;set;}
    
    public string accName {get;set;}
    public string startWith {get;set;}
    public string missingContactTypes {get;set;}
    
    public integer emailSentCount {get;set;}
    
    private string emailTemplateId;


    public WalmartMissingContactsCntrl(){
        pageNumber = 0;
        pageSize = integer.valueOf(Label.MissingContactPageSize);
        
        contactTypeList = new list<SelectOption>();
        accModListofList = new list<list<AccountModal>>();
        
        accModListofList = getAccounts();
        
        list<EmailTemplate> emailTemplateList = [select id, Name from EmailTemplate where DeveloperName = 'Missing_Contact_Notification_Template'];
        if(emailTemplateList.size() > 0)
            emailTemplateId = emailTemplateList[0].Id;
    }
        
    /*******************************************************************************************************
    * @description Return list of the all Account modals
    * @param 
    * @return the describe field result for the given field
    * @example
    * List<AccountModal> a = new List<AccountModal>();
    */
    private list<list<AccountModal>> getAccounts(){
        integer min = pageNumber * pageSize;
        integer max = (pageNumber+1)*pageSize;
        
        missingCTCount = missingAddressCount = accCount = 0;
        contactTypeList = new list<SelectOption>();
        
        Map<String, Contact_Types__c> contactTypes = Contact_Types__c.getAll();  // fetching teh custom setting the data ...
        
        contactTypeList.add(new SelectOption('', '-Select Contact Type-'));
        for(Contact_Types__c ct : contactTypes.values())
        {
            contactTypeList.add(new SelectOption(ct.Name, ct.Name));
        }
        
        accModListofList = new list<list<AccountModal>>();
        
        List<AccountModal> accModelList = new List<AccountModal>();    
        
        integer counter = 0;
        string mprecordType='MP_Account';     
        string type = 'Seller';
        string onboardingStatus = 'Live on Site';
        string platform = 'GMP';
        string nameStr, name;
        
        string query = ' select Id, Name, Customer_Service_Email__c, Missing_Contact_Email_Sent__c, '+
                       ' BillingCountryCode, BillingStreet, BillingCity, BillingStateCode, BillingPostalCode, '+
                       ' Last_Email_Sent__c, Primary_Contact__c, Primary_Contact__r.Email, OwnerId, Owner.Email, '+
                       ' (select Id, Email, Contact_Type__c '+
                       ' from Contacts) '+
                       ' from Account '+
                       ' where Type =: type '+
                       ' and Seller_Onboarding_Status__c =: onboardingStatus '+
                       ' and RecordType.DeveloperName =: mprecordType '+
                       ' and Active__c = true '+
                       ' and Platform__c =: platform ';
               
               if(accName != null && accName.trim().length() > 0){
                   name = '%' + accName + '%';
                   query += ' and Name like : name'; 
               }
               if(startWith !=  null && startWith != 'All'){
                   nameStr = startWith + '%';
                   query += ' and Name like : nameStr';        
               }
               
               query += ' order by Name limit 50000 ';
        
        totalRecords = 0;
        for(Account acc : database.query(query)){
            
            totalRecords++;
                           
            Set<String> conEmails = new Set<String>();
            Set<String> conTypes  = new Set<String>();
            string contactId;
            for(Contact c : acc.Contacts){
                if(c.Contact_Type__c != null)
                    conTypes.addAll(c.Contact_Type__c.split(';'));
                if(c.Email != null){
                    conEmails.add(c.Email);
                    contactId = c.Id;
                }
            }
            
            if(missingContactTypes != null && missingContactTypes.trim().length() > 0 && conTypes.contains(missingContactTypes))
                continue;
            
            if(contactId == null)
                contactId = acc.Primary_Contact__c;
            
            List<String> tempList = checkContactTyeps(contactTypes.KeySet(), conTypes);
            
            boolean isLAMissing = false;
            
            if(acc.BillingCountryCode == null || acc.BillingStreet == null || acc.BillingCity == null || acc.BillingStateCode == null || acc.BillingPostalCode == null)
                isLAMissing = true;
                
            if((tempList != null && tempList.size() > 0) || isLAMissing)
            {
                if(counter >= min && counter < max){
                    accCount = accCount + 1;
                    
                    if(isLAMissing)
                        missingAddressCount++;
                        
                    if(tempList != null && tempList.size() > 0)
                        missingCTCount++;
                    
                    accModelList.add(new AccountModal(acc.Id, 
                                                      acc.Name,
                                                      acc.Customer_Service_Email__c,
                                                      acc.Primary_Contact__r.Email,
                                                      isLAMissing,
                                                      tempList, 
                                                      conEmails, 
                                                      acc.Missing_Contact_Email_Sent__c, 
                                                      acc.Last_Email_Sent__c,
                                                      false,
                                                      contactId));
                    if(accModelList.size() > 499){
                        accModListofList.add(accModelList);
                        accModelList = new list<AccountModal>();
                    }
                }
                else if(counter >= max){
                    break;
                }
                counter++;
            }
        }
        
        totalRecords = (totalRecords/pageSize);
        //totalRecords = totalRecords + 1;
        
        if(accModelList.size() > 0)
            accModListofList.add(accModelList);
            
        return accModListofList;
    }
    
    
    /*******************************************************************************************************
    * @description checking for the missing contact_type
    * @param 
    * @return the describe field result for the given field
    * @example
    * List<AccountModal> a = new List<AccountModal>();
    */
    public void next(){
        if(pageNumber < totalRecords){
            pageNumber = pageNumber + 1;
            accModListofList = getAccounts();
        }
    }
    
    
    /*******************************************************************************************************
    * @description checking for the missing contact_type
    * @param 
    * @return the describe field result for the given field
    * @example
    * List<AccountModal> a = new List<AccountModal>();
    */
    public void prev(){
        if(pageNumber != 0){
            pageNumber = (pageNumber - 1);
            accModListofList = getAccounts();
        }
    }
    
    /*******************************************************************************************************
    * @description checking for the missing contact_type
    * @param 
    * @return the describe field result for the given field
    * @example
    * List<AccountModal> a = new List<AccountModal>();
    */
    public void callStartWith(){
        pageNumber = 0;
        accModListofList = getAccounts();
    }
    

    /*******************************************************************************************************
    * @description checking for the missing contact_type
    * @param 
    * @return the describe field result for the given field
    * @example
    * List<AccountModal> a = new List<AccountModal>();
    */
    private List<String> checkContactTyeps(Set<String> orgValues, Set<String> avlValues){
        List<String> tempList = new List<String>();
        for(String s : orgValues){
            if(!avlValues.contains(s)){
                tempList.add(s);
            }
        }
        return tempList;
    }
    


    /*******************************************************************************************************
    * @description checking for the missing contact_type
    * @param 
    * @return the describe field result for the given field
    * @example
    * List<AccountModal> a = new List<AccountModal>();
    */
    public void SendAction(){
        try{
            if(selAccId != null && selAccId.length() > 14){
                string conId;
                
                list<Contact> contactList = [select id from Contact where Name = 'DoNotDelete' limit 1];
                
                if(contactList.size() > 0)
                    conId = contactList[0].Id;
                    
                set<string> accountIds = new set<string>();
                map<id, Account> accountMap = new map<id, Account>();
                
                for(List<AccountModal> accModList : accModListofList){
                    for(AccountModal a : accModList){
                        if(a.accId == selAccId && a.isHasEmail){
                            accountIds.add(a.accId);
                        }
                    }
                }
                
                accountMap = new map<id, Account>([select Id, Name, Customer_Service_Email__c, Missing_Contact_Email_Sent__c, 
                                                   Last_Email_Sent__c, Primary_Contact__c, Primary_Contact__r.Email, OwnerId, Owner.Email
                                                   from Account 
                                                   Where Type = 'Seller'
                                                   and Seller_Onboarding_Status__c = 'Live on Site'
                                                   AND Platform__c = 'GMP'
                                                   and Id in : accountIds]);
                
                Account account = new Account();
                for(List<AccountModal> accModList : accModListofList){
                    for(AccountModal a : accModList){
                        if(a.accId == selAccId && a.isHasEmail){
                            account = new Account(Id = a.accId);
                            sendEmail(accountMap.get(a.accId), a.conEmails, (a.contactId != null ? a.contactId : conId));
                            break;
                        }
                    }
                }
                account.Missing_Contact_Email_Sent__c = true;
                account.Last_Email_Sent__c = datetime.now();
                
                if(account.Id != null)
                    update account;
                
                accModListofList = getAccounts();
            }
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        selAccId = '';    
    }
    
    
    
    /*******************************************************************************************************
    * @description check the org single email limit
    * @param 
    * @return the describe field result for the given field
    * @example
    */
    public void fetchSingleEmailLimit()
    {
        CheckOrganizationLimits.LimitResponseWrapper limits = CheckOrganizationLimits.CheckLimits();
        
        if(limits != null){
            singleEmailMax = limits.SingleEmail.Max;
            singleEmailRemaining = limits.SingleEmail.Remaining;
        }
    }
    
    
    /*******************************************************************************************************
    * @description checking for the missing contact_type
    * @param 
    * @return the describe field result for the given field
    * @example
    * List<AccountModal> a = new List<AccountModal>();
    */
    public void SendAllAction(){
        try{
            list<Account> accounts = new list<Account>();
            set<string> accountIdSet = new set<string>();
            emailSentCount = 0;
            
            for(List<AccountModal> accModList : accModListofList){
                for(AccountModal a : accModList){
                    if(a.isChecked && a.isHasEmail){
                        accounts.add(new Account(Id = a.accId,
                                                 Missing_Contact_Email_Sent__c = true,
                                                 Last_Email_Sent__c = datetime.now()));
                        
                        accountIdSet.add(a.accId);
                        emailSentCount++;
                    }
                }
            }
            
            if(accountIdSet.size() > 0){
                AccountMissingContactNotificationBatch cntrl = new AccountMissingContactNotificationBatch();
                cntrl.accountIdSet.addAll(accountIdSet);
                
                Database.ExecuteBatch(cntrl, 10);
            }
            
            if(accounts.size() > 0)
                update accounts;
            
            accModListofList = getAccounts();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, emailSentCount+' accounts notified successfully!'));
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        selAccId = '';    
    }
    
    

    /*******************************************************************************************************
    * @description checking for the missing contact_type
    * @param 
    * @return the describe field result for the given field
    * @example
    * List<AccountModal> a = new List<AccountModal>();
    */
    private void sendEmail(Account acc, List<String> toEmailList, string contactId){       
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        
        list<string> toEmails = new list<string>();
        list<string> ccEmails = new list<string>();
        
        if(acc.Customer_Service_Email__c != null)
            toEmails.add(acc.Customer_Service_Email__c);
            
        if(acc.Primary_Contact__r.Email != null)
            toEmails.add(acc.Primary_Contact__r.Email);
        
        for(string email : toEmailList)
        {
            toEmails.add(email);
        }
        
        msg.setToAddresses(toEmails);
        msg.setCCAddresses(new list<string>{acc.Owner.Email});
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

    

    /*******************************************************************************************************
    * @description checking for the missing contact_type
    * @param 
    * @return the describe field result for the given field
    * @example
    * List<AccountModal> a = new List<AccountModal>();
    */
    public class AccountModal{
        public string accId            {get;set;}
        public string accName          {get;set;}
        public string customerSerEmail {get;set;}
        public string contactEmail {get;set;}
        public string  contactType    {get;set;}
        public string contactId       {get;set;}
        public boolean isHasEmail     {get;set;}
        public boolean lastEmailSent  {get;set;}
        public datetime lastEmailDate {get;set;}
        public string lastEmailString {get;set;}
        public boolean isChecked      {get;set;}
        public boolean isLAMissing {get;set;}
        
        private list<string> conEmails {get;set;}
        
        public AccountModal(string accId, 
                            string accName,
                            string customerSerEmail,
                            string contactEmail,
                            boolean isLAMissing,
                            List<String> cType, 
                            Set<String> emls, 
                            boolean lastEmailSent, 
                            datetime lastEmailDate,
                            boolean isChecked,
                            string contactId){
                            
            this.accId = accId;
            this.accName = accName;
            contactType = String.join(cType, ' ,');
            conEmails   = new List<String>();
            conEmails.addAll(emls);
            isHasEmail  = (customerSerEmail != null || contactEmail != null) ? true : false;
            
            this.lastEmailSent = lastEmailSent;
            this.lastEmailDate = lastEmailDate;
            
            this.isChecked     = isChecked;
            this.contactId     = contactId;
            
            if(this.lastEmailDate != null)
                lastEmailString = this.lastEmailDate.format('MM/dd/yyyy HH:mm a', 'PST');
                
            this.isLAMissing = isLAMissing;
        }
    }
}
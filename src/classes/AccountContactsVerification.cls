public class AccountContactsVerification
{
    
    private string accountId;
    
    public string accountName {get;set;}
    public string mendatoryContactTypes {get;set;}
    public integer selectedIndex {get;set;}
    public list<SelectOption> contactTypes {get;set;}
    public list<string> contactTypeList    {get;set;}
    public list<ContactWrapper> contactWrapperList {get;set;}
    public set<string> deleteContactIdSet {get;set;}
    
    public Account account {get;set;}
    
    public AccountContactsVerification()
    {
        initVariables();
        init();
    }
    
    private void initVariables()
    {  String mprecordType='MP_Account';
    recordtype rec = [select Id from recordtype where DeveloperName=:mprecordType limit 1];
        accountId = ApexPages.currentPage().getParameters().get('ac');
        
        if(accountId != null)
            accountName = [select Name from Account where id =: accountId AND RecordType.DeveloperName=:mprecordType limit 1].Name;
        
        contactTypes = new list<SelectOption>();
        contactTypeList = new list<string>();
        contactWrapperList = new list<ContactWrapper>();
        account = new Account();
        account.recordtypeID= rec.ID;
        mendatoryContactTypes = '';
        deleteContactIdSet = new set<string>();
        
        queryAccounts();
    }
    
    private void init()
    {
        contactTypes = contactTypeOptions();
        set<string> missingContactTypeSet = new set<string>();
        set<string> availableContactTypeSet = new set<string>();
        
        for(Contact_Types__c ct : getRequiredContactTypes()){
            mendatoryContactTypes += ct.Name+ ', ';
            missingContactTypeSet.add(ct.Name);
        }
        
        for(Contact c : queryContacts()){
            contactWrapperList.add(new ContactWrapper(c.Id, c.FirstName, c.LastName, c.Email, c.Phone, c.Contact_Type__c, c.Active__c));
            if(c.Contact_Type__c != null)
                availableContactTypeSet.addAll(c.Contact_Type__c.split(';'));
        }
        
        for(string ct : missingContactTypeSet){
            if(!availableContactTypeSet.contains(ct))
                contactWrapperList.add(new ContactWrapper(null, null, null, null, null, ct, false));
        }
        
        mendatoryContactTypes = mendatoryContactTypes.removeEnd(', ');
    }
    
    private void queryAccounts()
    {   String mprecordType='MP_Account';
        list<Account> accountList = [select id, BillingCountryCode, BillingStreet, BillingCity, BillingStateCode, BillingPostalCode
                                     from Account
                                     where Id =: accountId AND RecordType.DeveloperName=:mprecordType];
        if(accountList.size() > 0){
            account.BillingCountryCode = accountList[0].BillingCountryCode;
            account.BillingStreet      = accountList[0].BillingStreet;
            account.BillingCity        = accountList[0].BillingCity;
            account.BillingStateCode   = accountList[0].BillingStateCode;
            account.BillingPostalCode  = accountList[0].BillingPostalCode;
        }
    }
    
    private list<Contact> queryContacts()
    {
        return [select id, FirstName, LastName, Email, Phone, Contact_Type__c, Active__c
                from Contact
                where AccountId =: accountId
                and AccountId != null];
    }
    
    private list<Contact_Types__c> getRequiredContactTypes(){
        return Contact_Types__c.getAll().values();
    }
    
    public list<SelectOption> contactTypeOptions() {
        list<SelectOption> options = new list<SelectOption> ();
        contactTypeList = new list<string>();
        
        Schema.DescribeFieldResult fieldResult = Contact.Contact_Type__c.getDescribe();
        list<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        //options.add(new SelectOption('','-None-'));
        for (Schema.PicklistEntry f: ple) {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
            contactTypeList.add(f.getValue());
        }
        return options;
    }
    
    public void addNewContact(){
        contactWrapperList.add(new ContactWrapper(null, null, null, null, null, null, false));
    }
    
    public void removeContact()
    {
        system.debug('selectedIndex :::::' + selectedIndex);
        if(contactWrapperList.size() > 0)
        {
            list<ContactWrapper> tempList = new list<ContactWrapper>();
            integer index = 0;
            
            for(ContactWrapper c : contactWrapperList){
                if(index != selectedIndex)
                    tempList.add(c);
                else if(c.contactId != null)
                    deleteContactIdSet.add(c.contactId);
                
                index++;
            }
            
            contactWrapperList = new list<ContactWrapper>();
            contactWrapperList.addAll(tempList);
        }
    }
    
    public void saveContacts(){
        if(contactWrapperList.size() > 0)
        {
            list<Contact> contactUpsertList = new list<Contact>();
            list<Contact_Types__c> contactTypesList = getRequiredContactTypes();
            set<string> contactTypeSet = new set<string>();
            
            for(ContactWrapper c : contactWrapperList)
            {
                string contactType = '';
                if(c.type != null)
                    contactType = c.type;
                    
                contactUpsertList.add(new Contact(id = c.contactId,
                                                  FirstName = c.firstName,
                                                  LastNAme = c.lastName,
                                                  Email = c.email,
                                                  Phone = c.phone,
                                                  Contact_Type__c = contactType.replace(',',';'),
                                                  AccountId = accountId,
                                                  Active__c = c.isActive));
                
                if(c.type != null){
                    if(c.isActive)
                        contactTypeSet.addAll(contactType.split(','));
                    
                    c.type = c.type.replace(',',';');
                }
            }
            
            if(contactUpsertList.size() > 0 && contactTypesList.size() > 0){
                boolean isValid = true;
                string missingContactTypes = '';
                for(Contact_Types__c ct : contactTypesList)
                {
                    if(!contactTypeSet.contains(ct.Name)){
                        isValid = false;
                        missingContactTypes += ct.Name + ', ';
                    }
                }
                
                if(isValid){
                    try{
                        account.Id = accountId;
                        update account;
                        
                        upsert contactUpsertList;
                        
                        if(deleteContactIdSet.size() > 0)
                        {
                            list<Contact> deleteContactList = new list<Contact>();
                            for(string conId : deleteContactIdSet){
                                deleteContactList.add(new Contact(Id = conId));
                            }
                            
                            if(deleteContactList.size() > 0)
                                delete deleteContactList;
                        }
                        
                        account.Id = null;
                        
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Thank You. Contacts saved successfully.'));
                    }catch(Exception ex){
                        if(ex.getMessage().contains('Your attempt to delete') && ex.getMessage().contains('DELETE_FAILED, ')){
                            list<string> messageList = ex.getMessage().split('DELETE_FAILED, ');
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error : '+ messageList[1] +'. If you want to inactivate the user, please check the “active” checkbox off.'));
                        }else
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error : '+ex.getMessage()));
                    }
                }
                else{
                    missingContactTypes = missingContactTypes.removeEnd(', ');
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error : One or more required contact types is missing or inactive. You must assign at least one person to [' + missingContactTypes+']'));
                }
            }
        }
    }
    
    public class ContactWrapper
    {
        public string contactId {get;set;}
        public string firstName {get;set;}
        public string lastName  {get;set;}
        public string email     {get;set;}
        public string phone     {get;set;}
        public string type      {get;set;}
        public boolean isActive {get;set;}
        
        public ContactWrapper(string contactId,
                              string firstName,
                              string lastName,
                              string email,
                              string phone,
                              string type,
                              boolean isActive)
        {
            this.contactId = contactId;
            this.firstName = firstName;
            this.lastName  = lastName;
            this.email     = email;
            this.phone     = phone;
            this.type      = type;
            this.isActive  = isActive;
            
            if(this.phone != null)
                this.phone = this.phone.replace('(','').replace(')','').replace(' ','').replace('-','');
        }
    }
}
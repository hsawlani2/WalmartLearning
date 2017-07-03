/*
 ** Class:  SendCaseEmailController
 ** Description: Controller for the SendCaseEmail custom Visual Force page. 
 */
public with sharing class SendCaseEmailController {

    public String addlRecipients {
        get;
        set;
    }
    
    public Case ourCase {
        get;
        set;
    }
    
    public EmailMessage emailMsg {
        get;
        private set;
    }
    
    public boolean showEmail {get;set;}
    public boolean showArticle {get;set;}
    public boolean showBcc {get;set;}
    
    public string foldersId {get;set;}
    public string templateId {get;set;}
    
    public list<SelectOption> fromOptions {get;set;}

    private OrgWideEmailAddress sender = null;

    private static final String SUPPORT_EMAIL_ADDRESS = 'support@somewhere.com';
    private static final String SUPPORT_NAME = 'Support Email';
    private map<string, string> emailAddressMap;
    private String recordTypeName;
    
    Map<Id,List<EmailTemplate>> etempFolder = new Map<Id,List<EmailTemplate>>();
    
    public SendCaseEmailController(ApexPages.StandardController controller) {
        ourCase = (Case) controller.getRecord();
        
        recordTypeName = [select Name from RecordType where Id = :ourCase.RecordTypeId limit 1].Name;
        
        showBcc = showEmail = false;
        showArticle = true;
        
        // create our EmailMessage 
        emailMsg = new EmailMessage();
        emailAddressMap = new map<string, string>();

        fromOptions = new list<SelectOption>();
        fromOptions.add(new SelectOption(UserInfo.getUserId(), UserInfo.getName()+' <'+UserInfo.getUserEmail()+'>'));
        for(OrgWideEmailAddress o : [select Id, DisplayName, Address from OrgWideEmailAddress])
        {
             if(CaseUtility.getSupplierRecordTypeNames().contains(recordTypeName)){
                if(o.Address == 'supcase@walmart.com')
                    emailMsg.FromAddress = o.Id;
             }else{
                if(o.Address == 'sellercareteam@walmart.com')
                    emailMsg.FromAddress = o.Id;
             }
            
                
            fromOptions.add(new SelectOption(o.Id, o.DisplayName+' <'+o.Address+'>'));
            emailAddressMap.put(o.Id, o.Address);
        }
        
        String qryString = 'SELECT Id, title, UrlName, LastPublishedDate,LastModifiedById FROM KnowledgeArticleVersion WHERE (PublishStatus = \'online\' and Language = \'en_US\')';
        List<KnowledgeArticleVersion> articleList= Database.query(qryString);
        maxSize = articleList.size() ;
        
        ourCase = [select id, CaseNumber, ContactEmail, ContactId, Subject from Case where id =: ourCase.Id];
        
        emailMsg.ToAddress = ourCase.ContactEmail;
        emailMsg.BccAddress = UserInfo.getUserEmail();
        emailMsg.ParentId = ourCase.Id;
        emailMsg.Subject = 'RE: Case ' + ourCase.CaseNumber + ' created - Subject: ' + ourCase.Subject;
        
        searchstring = ourCase.Subject;
    }
    
    public void showHideEmail(){
        if(showEmail) showEmail = false; else showEmail = true;
    }
    
    public void showHideArticle(){
        if(showArticle) showArticle = false; else showArticle = true;
    }
    
    public void showHideBcc(){
        if(showBcc) showBcc = false; else showBcc = true;
    }

    public Attachment attachment {
        get {
            if (attachment == null) {
                attachment = new Attachment();
            }
            return attachment;
        }
        set;        
 
 
    }
    
    
    public list<SelectOption> getEmailFolders(){
        Map<Id,string> folderName = new Map<Id,string>();
        list<SelectOption> options = new list<SelectOption>();
        options.add(new SelectOption('', '--Select EmailTemplate--'));
        List<EmailTemplate> emailList = [SELECT Id, DeveloperName, FolderId, Folder.Name FROM EmailTemplate];
        
        for(EmailTemplate et : emailList){
            etempFolder.put(et.FolderId,new List<EmailTemplate>());
            folderName.put(et.FolderId,et.Folder.Name);
            
            system.debug('...folder name.. '+et.Folder.Name);
            
        }
        
        for(Id foldId : folderName.keyset()){
            if(folderName.get(foldId) != null ){
                options.add(new SelectOption(foldId, folderName.get(foldId)));
            } 
        }
        
       /*
        for(EmailTemplate emailTemplate : [select Id, Name, BrandTemplateId
                                           from EmailTemplate 
                                           order by Name
                                           limit 1000]){
            
            options.add(new SelectOption(emailTemplate.Id, emailTemplate.Name));                                   
        }
        */
        
        return options;
    }
    
    public PageReference actionTemplates(){
        list<SelectOption> selectlist = getEmailTemplates();
        return null;
    }
    
    public list<SelectOption> getEmailTemplates(){
        system.debug('..email folder id.. '+foldersId);
        list<SelectOption> options = new list<SelectOption>();
        for(EmailTemplate emailTemplate : [select Id, Name, BrandTemplateId
                                           from EmailTemplate where FolderId=: FoldersId AND IsActive = TRUE
                                           order by Name
                                           limit 1000]){
            
            options.add(new SelectOption(emailTemplate.Id, emailTemplate.Name));                                   
        }
        system.debug('..email templatess... '+options);
        return options;
    }

    // send email message per the attributes specified by user.
    public void send() {
        try {
            // now create our SingleEmailMessage to send out.
            Messaging.SingleEmailMessage singleEmailMsg = new Messaging.SingleEmailMessage();

            // concatenate all Bcc Addresses
            if (emailMsg.BccAddress != null && emailMsg.BccAddress != '') {
                singleEmailMsg.setBccAddresses(emailMsg.BccAddress.split(';'));
            }

            // concatenate all CC Addresses
            if (emailMsg.CcAddress != null && emailMsg.CcAddress != '') {
                singleEmailMsg.setCcAddresses(emailMsg.CcAddress.split(';'));
            }
            
            if(emailMsg.FromAddress != null && !emailMsg.FromAddress.startsWith('005'))
                singleEmailMsg.setOrgWideEmailAddressId(emailMsg.FromAddress);
            
            emailMsg.FromAddress = emailAddressMap.get(emailMsg.FromAddress);

            singleEmailMsg.setSubject(emailMsg.Subject);
            singleEmailMsg.setPlainTextBody(emailMsg.TextBody);

            // now add additional recipients
            String[] addlToAddresses = null;
            if (addlRecipients != null && addlRecipients != '') {
                addlToAddresses = addlRecipients.split(';');
            }
            
            list<String > lstToAddresses = null;
            if (addlToAddresses != null) {
                lstToAddresses = new list<String > (addlToAddresses);
            } else {
                lstToAddresses = new list<String > ();
            }
            
            lstToAddresses.add(emailMsg.ToAddress);
            singleEmailMsg.setToAddresses(lstToAddresses);
            
            emailMsg.ToAddress += (addlRecipients != null ? ';' + addlRecipients :'');

            list<Messaging.EmailFileAttachment> fileAttachments = new list<Messaging.EmailFileAttachment>();
            
            /*if (attachment.Body != null) {
                Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
                emailAttachment.setBody(attachment.Body);
                emailAttachment.setFileName(attachment.Name);
                fileAttachments.add(emailAttachment);
            }*/
            
            list<Attachment> attachList = new list<Attachment>();
            list<CaseArticle> caseArticleList = new list<CaseArticle>();
            
            if(articleList != null)
            {
                for(ArticleWrapper a : articleList){
                    PageReference pdf =  new PageReference('/knowledge/articlePrintableView.apexp?id='+a.articleId);
                    pdf.setRedirect(true);
            
                    // Take the PDF content
                    Blob b = pdf.getContentAsPDF();
                    
                    // Create the email attachment
                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                    efa.setFileName(a.articleName+'.pdf');
                    efa.setBody(b);
                    
                    attachList.add(new Attachment(Name = a.articleName+'.pdf',
                                                  Body = b));
                                                  
                    caseArticleList.add(new CaseArticle(CaseId = ourCase.Id,
                                                        KnowledgeArticleId = a.articleId));
                    
                    fileAttachments.add(efa);
                }
            }
            
            if(fileAttachments.size() > 0)
                singleEmailMsg.setFileAttachments(fileAttachments);
            
            list<Messaging.SendEmailResult > results = Messaging.sendEmail(new list<Messaging.SingleEmailMessage > {singleEmailMsg});

            if (results[0].success) {
                insert emailMsg;
                
                if (attachList.size() > 0) {
                    for(Attachment attachment : attachList){
                        attachment.parentId = emailMsg.Id;
                    }
                    
                    insert attachList;
                    database.insert(caseArticleList, false);
                }

                PageReference pgRef = new PageReference('/' + ourCase.Id);
                pgRef.setRedirect(true);
            } else {
                String errorMsg = 'Error sending Email Message. Details = ' + results.get(0).getErrors()[0].getMessage();
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg));
            }
        } catch (Exception e) {
            String errorMsg = 'Exception thrown trying to send Email Message. Details = ' + e;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg));
        }
    }

    // cancel creation of emailMessage. 
    public PageReference cancel() {
        // no need to do anything - just return to calling page.
        PageReference pgRef = new PageReference('/' + ourCase.Id);
        pgRef.setRedirect(true);
        return pgRef;
    }

    // populate our Email Message Template from the database, filling merge fields with
    // values from our Case object. Then store resulting template in EmailMessage for
    // display to end-user who is free to edit it before sending.
    public void populateTemplate() {
        // we need to perform the merge for this email template before displaying to end-user.
        EmailTemplate emailTemplate = [select Body, HtmlValue, Subject,
                                       DeveloperName, BrandTemplateId
                                       from EmailTemplate 
                                       where id =: templateId 
                                       limit 1];

        // construct dummy email to have Salesforce merge BrandTemplate (HTML letterhead) with our email
        Messaging.SingleEmailMessage dummyEmailMsg = new Messaging.SingleEmailMessage();
        dummyEmailMsg.setTemplateId(emailTemplate.Id);
        // This ensures that sending this email is not saved as an activity for the targetObjectId. 
        dummyEmailMsg.setSaveAsActivity(false);

        // send dummy email to populate HTML letterhead in our EmailMessage object's html body.
        String[] toAddresses = new String[] { UserInfo.getUserEmail() };
        dummyEmailMsg.setToAddresses(toAddresses);
        dummyEmailMsg.setReplyTo(SUPPORT_EMAIL_ADDRESS);
        
        Savepoint sp = Database.setSavepoint();
        
        recordtype rec = [select id from recordtype where developername='MP_Account']; 
        Account dummyAcct = new Account(Name = 'dummy account',Type='Seller',RecordtypeID=rec.ID);
        insert dummyAcct;

        Contact dummyContact = new Contact(AccountId = dummyAcct.Id);
        dummyContact.FirstName = 'First';
        dummyContact.LastName = 'Last';
        dummyContact.Email = 'nobody@nowhere.com';
        insert dummyContact;
        
        if(ourCase.ContactId == null || ourCase.ContactEmail == null)
            dummyEmailMsg.setTargetObjectId(dummyContact.Id);
        else
            dummyEmailMsg.setTargetObjectId(ourCase.ContactId);
            
        dummyEmailMsg.setWhatId(ourCase.Id);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { dummyEmailMsg });
        // now rollback our changes.
        Database.rollback(sp);

        // now populate our fields with values from SingleEmailMessage.
        emailMsg.BccAddress = UserInfo.getUserEmail();
        emailMsg.Subject = dummyEmailMsg.getSubject();
        emailMsg.TextBody = dummyEmailMsg.getPlainTextBody();
        emailMsg.CcAddress = '';
    }
    
    //Page Size
    private Static Final Integer PAGE_NUMBER = 10;
    
    //Keeps track of current page & max size of article list
    Integer currentPage = 1;
    Integer maxSize = 1;
    public String searchstring { get; set; }
    
    // Returns whether we need to see previous button or not
    public boolean getPrevRequired() {
        return currentPage > 1;
    }
    
    // Returns whether we need to see next button or not
    public boolean getNextRequired() {
        return currentPage * PAGE_NUMBER < maxSize;
    }
    
    //Returns current page number 
    public Decimal getCurrentPageNumber() {
        return this.currentPage;
    }
    
    //action for next click
    public PageReference next() {
        if (maxSize > this.currentPage * PAGE_NUMBER) {
            this.currentPage = this.currentPage + 1;
        }
        return null;
    }
    
    //action for previous click
    public PageReference previous() {
        if (this.currentPage > 1)
            this.currentPage = this.currentPage - 1;
        return null;
    }
    
    public list<ArticleWrapper> articleList {get;set;}
    public string articleId {get;set;}
    public string articleName {get;set;}
    public integer removeIndex {get;set;}
    
    public void addArticle()
    {    
        if(articleList == null)
            articleList = new list<ArticleWrapper>();
        
        if(articleId != null && articleName != null)
        {
            articleList.add(new ArticleWrapper(articleId, articleName));
        }
    }
    
    public void removeArticle()
    {
        if(articleList.size() > 0 && removeIndex != null)
            articleList.remove(removeIndex);
    }
    
    //Article Wrapper
    public class ArticleWrapper
    {
        public string articleId {get;set;}
        public string articleName {get;set;}
        
        public ArticleWrapper(string articleId, string articleName){
            this.articleId = articleId;
            this.articleName = articleName;
        }
    }
}
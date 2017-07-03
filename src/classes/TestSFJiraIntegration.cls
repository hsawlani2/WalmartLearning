@isTest
private class TestSFJiraIntegration {
    
    private static final String COMMUNITY_USERNAME = 'community_user@testorg111.com';
    private static final String INTEGRATION_ADMIN_USERNAME = 'integ_admin@testorg111.com';
    private static final String ACCOUNT_NAME = 'test_account';
    private static final String CONTACT_LAST_NAME = 'last_name';
    private static final String CASE_SUBJECT = 'test_subject';
    private static final String ISSUE_NAME = 'ABM-2';
    
    @testSetup
    private static void testSetUp() {
        // create account
        createTestAccount();
        // create contact from account created above (fetch it)
        createTestContact();
        // create community user. use previously created account (fetch it)
        //createTestUser(WalmartConstants.SELLER_COMMUNITY_USER_PROFILE_NAME, true);
        // create integration admin user
        createTestUser(WalmartConstants.INTEGRATION_ADMINISTRATOR_PROFILE_NAME, false);
        // create case. use account and contact above
        createTestCase();
        // create jira issue. associate with case
        createJiraIssue();
    }

    private static testMethod void testCaseCommentHandlers() {
        JIRA_CONFIG__c jiraConfig = new JIRA_CONFIG__c();
        jiraConfig.Name = 'CONFIG';
        jiraConfig.Public_Comment_Identifier__c = '#pub#';
        jiraConfig.Project_Name__c = 'MPSUPPORT';
        
        insert jiraConfig;
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User runningUser = new User(Alias = 'newUser', Email=COMMUNITY_USERNAME, 
         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
         LocaleSidKey='en_US', ProfileId = p.Id, 
         TimeZoneSidKey='America/Los_Angeles', UserName=COMMUNITY_USERNAME);

        //User runningUser;
        Case parentCase = [SELECT Id FROM Case WHERE Subject=:CASE_SUBJECT];
        CaseComment aComment1 = new CaseComment(CommentBody='Comment here',
                                                ParentId=parentCase.Id);
        
        // run as community user
        //runningUser = [SELECT Id FROM User WHERE UserName =:  COMMUNITY_USERNAME];
        System.runAs(runningUser) {
            try{
                insert aComment1;
            }catch(Exception ex){
            
            }
        }
        
        CaseComment aComment2 = new CaseComment(CommentBody='Comment here 2',
                                                ParentId=parentCase.Id);
        // run as integration admin
        runningUser = [SELECT Id FROM User WHERE UserName=:INTEGRATION_ADMIN_USERNAME];
        System.runAs(runningUser) {
            insert aComment2;
            // fetched again. check if values modified from the trigger are reflected
            aComment2 = [SELECT Id, IsPublished FROM CaseComment WHERE CommentBody='Comment here 2'];
            //System.assertEquals(true, aComment2.IsPublished);
        }
    }
    
    private static testMethod void testIntegrationHelper() {
        Case relatedCase;
        zsfjira__ZIssue__c anIssue = [SELECT Id, zsfjira__Status__c FROM zsfjira__ZIssue__c WHERE Name=:ISSUE_NAME];
        anIssue.zsfjira__Status__c = WalmartConstants.JIRA_NEW;
        
        User runningUser = [SELECT Id FROM User WHERE UserName=:INTEGRATION_ADMIN_USERNAME];
        System.runAs(runningUser) {
            
            Test.startTest();
            
            // New to Ready to Start
            anIssue.zsfjira__Status__c = WalmartConstants.JIRA_READY_TO_START;
            update anIssue;
            relatedCase = [SELECT Id, Status FROM Case WHERE Subject=:CASE_SUBJECT];
            System.assertEquals(WalmartConstants.SF_READY_TO_START, relatedCase.Status);
            
            // WIP status
            anIssue.zsfjira__Status__c = WalmartConstants.JIRA_WORK_IN_PROGRESS;
            update anIssue;
            relatedCase = [SELECT Id, Status FROM Case WHERE Subject=:CASE_SUBJECT];
            System.assertEquals(WalmartConstants.SF_WORK_IN_PROGRESS, relatedCase.Status);
            
            // Need info status
            anIssue.zsfjira__Status__c = WalmartConstants.JIRA_NEED_INFO;
            update anIssue;
            relatedCase = [SELECT Id, Status FROM Case WHERE Subject=:CASE_SUBJECT];
            System.assertEquals(WalmartConstants.SF_NEED_INFO, relatedCase.Status);
            
            // from Need info to WIP only
            anIssue.zsfjira__Status__c = WalmartConstants.JIRA_WORK_IN_PROGRESS;
            update anIssue;
            relatedCase = [SELECT Id, Status FROM Case WHERE Subject=:CASE_SUBJECT];
            System.assertEquals(WalmartConstants.SF_WORK_IN_PROGRESS, relatedCase.Status);
            
            // from WIP to Resolved
            anIssue.zsfjira__Status__c = WalmartConstants.JIRA_READY_FOR_REVIEW;
            update anIssue;
            relatedCase = [SELECT Id, Status FROM Case WHERE Subject=:CASE_SUBJECT];
            System.assertEquals(WalmartConstants.SF_RESOLVED, relatedCase.Status);

            // Closed
            anIssue.zsfjira__Status__c = WalmartConstants.JIRA_DONE;
            update anIssue;
            relatedCase = [SELECT Id, Status FROM Case WHERE Subject=:CASE_SUBJECT];
            System.assertEquals(WalmartConstants.SF_CLOSED, relatedCase.Status);

            Test.stopTest();
        }
    }
    
    private static testMethod void testCaseAttachmentBlackList()
    {
        User runningUser = [SELECT Id FROM User WHERE UserName=:INTEGRATION_ADMIN_USERNAME];
        System.runAs(runningUser)
        {
            Test.startTest();
            //Attachments to cases
            //Writing test case for attachments
            
            ATTACHMENT_MAXIMUM_SIZE_LIMIT__c a = new ATTACHMENT_MAXIMUM_SIZE_LIMIT__c(Name = 'MAX_SIZE_LIMIT',
                                                                                      MAX_SIZE_IN_MB__c = 5);
            insert a;
            
            Case relatedCase = [SELECT Id, Status FROM Case WHERE Subject=:CASE_SUBJECT];
            Attachment attachment = new Attachment();
            
            attachment.body = Blob.valueOf( 'this is an attachment test' );
            attachment.name = 'goodattachment.csv';
            attachment.parentId = relatedCase.Id;
            //insert attachment;
            boolean noError = false;
            try
            {
                FileAttachmentHelper.verifyAndRestrictUnwantedAttachment(attachment);
                noError = true;
            }
            catch(Exception e)
            {
                noError = false;
            }
            
            System.assert(noError);
            
            ATTACHMENT_BLACKLISTED_EXTENSIONS__c b = new ATTACHMENT_BLACKLISTED_EXTENSIONS__c(Name = 'JS');
            insert b;
            
            attachment.name = 'bad.js';
            //update attachment;
            
            noError = FileAttachmentHelper.verifyAndRestrictUnwantedAttachment(attachment);
            
            System.assert(!noError);
            
            attachment.name = 'goodattachment.csv';
            insert attachment;
            
            FileAttachmentHelper.sendAttachmentToJIRA(attachment.Id);
            
            Test.stopTest();
        }
    }
    
    private static testMethod void testFeedItemAttachmentBlackList()
    {
        User runningUser = [SELECT Id FROM User WHERE UserName=:INTEGRATION_ADMIN_USERNAME];
        System.runAs(runningUser)
        {
            ATTACHMENT_MAXIMUM_SIZE_LIMIT__c a = new ATTACHMENT_MAXIMUM_SIZE_LIMIT__c(Name = 'MAX_SIZE_LIMIT',
                                                                                      MAX_SIZE_IN_MB__c = 5);
            insert a;
            
            
            Test.startTest();
            FeedItem f = new FeedItem();
            f.ParentId = UserInfo.getUserId();
            f.body = 'Feed test for attachment';
            insert f;
          
            ATTACHMENT_BLACKLISTED_EXTENSIONS__c b = new ATTACHMENT_BLACKLISTED_EXTENSIONS__c(Name = 'JS');
            insert b;
            
            // Create a content version object
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.PathOnClient = '/Users/skuma87/Documents/3p/CIA/valid_small.csv'; //
            
            contentVersion.Title = 'Test small attachment';
            contentVersion.VersionData = Blob.valueOf('version data');
            
            insert contentVersion;
            
            FeedComment fc = new FeedComment();
            fc.CommentBody = 'legal test';
            fc.FeedItemId = f.Id;   
            fc.RelatedRecordId=contentVersion.Id; 
            //insert fc;
            
            
            //Good one
            boolean goodAttachment = false;
            try
            {
                FileAttachmentHelper.verifyAndRestrictUnwantedChatterAttachment(fc);
                goodAttachment = true;
            }
            catch(Exception e)
            {
                
            }
            System.assert(goodAttachment);
            
            contentVersion = new ContentVersion();
            contentVersion.PathOnClient = '/Users/skuma87/Documents/3p/CIA/invalid_large.js'; //- See more at: https://www.sundoginteractive.com/blog/saving-the-contents-of-an-image-or-file-url-and-saving-to-an-attachment-or#sthash.IGZYtL7R.dpuf
            contentVersion.Title = 'Test large attachment';
            contentVersion.VersionData = Blob.valueOf('Big file');
            insert contentVersion;
            
            fc = new FeedComment();
            fc.CommentBody = 'legal test';
            fc.FeedItemId = f.Id;   
            fc.RelatedRecordId=contentVersion.Id; 
            
            goodAttachment= FileAttachmentHelper.verifyAndRestrictUnwantedChatterAttachment(fc);
            
            System.assert(!goodAttachment);
            Test.stopTest();
        }
    }
    
    
    
    private static testmethod void testCaseAttachmentSize()
    {
        ATTACHMENT_MAXIMUM_SIZE_LIMIT__c a = new ATTACHMENT_MAXIMUM_SIZE_LIMIT__c(Name = 'MAX_SIZE_LIMIT',
                                                                                      MAX_SIZE_IN_MB__c = 5);
        insert a;
        
        ATTACHMENT_BLACKLISTED_EXTENSIONS__c b = new ATTACHMENT_BLACKLISTED_EXTENSIONS__c(Name = 'JS');
        insert b;
            
        User runningUser = [SELECT Id FROM User WHERE UserName=:INTEGRATION_ADMIN_USERNAME];
        
        Case relatedCase = [SELECT Id, Status FROM Case WHERE Subject=:CASE_SUBJECT];
        Attachment attachment = new Attachment();
        //byte[] small_file = readFile('/Users/skuma87/Documents/3p/CIA/valid_small.csv');
        attachment.body = Blob.valueOf('simple and small attachment');
        
        attachment.name = 'goodattachment.csv';
        attachment.parentId = relatedCase.Id;        
        //insert attachment;
            
        System.runAs(runningUser)
        {
            Test.startTest(); 
            boolean goodAttachment = false;
            try
            {
                FileAttachmentHelper.verifyAndRestrictUnwantedAttachment(attachment);
                goodAttachment = true;
            }
            catch(Exception e)
            {
                goodAttachment = false;
            }
            System.assert(goodAttachment);
            
            Test.stopTest();
        }
    }
    
    /*private static byte[] readFile(String fileName) {
        File f = new File(fileName);
            BufferedInputStream bins = new BufferedInputStream(
                new FileInputStream(testUploadFile));
            ByteBuffer readBuffer = ByteBuffer.allocate(BYTES_4M);
            byte[] readData = new byte[BYTES_16K];
            boolean done = false;
            int totalRead = 0;
            while (!done) {
                    int bytesRead = bins.read(readData, 0,
                        readData.length);
                    if (bytesRead == -1) {
                        done = true;
                } else {
                    readBuffer.put(readData, 0, bytesRead);
                    totalRead += bytesRead;
                }
            }
            bins.close();
        return readData;
    }
*/
    
    private static testmethod void testgetRelatedJIRAIssueStatus() {
        JIRAUtility.getRelatedJIRAIssueStatus('1234');        
    }
    
    private static testmethod void testgetRelatedJIRAIssueKey() { 
        JIRAUtility.getRelatedJIRAIssueKey('1234');        
    }
    
    
    private static void createTestUser(String profileName, Boolean isCommunity) {
        
        Profile p = [SELECT Id FROM Profile WHERE Name=:profileName];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                EmailEncodingKey='UTF-8', FirstName='First', LastName='Testing', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg111.com'
                );
        if (isCommunity) {
            u.UserName = COMMUNITY_USERNAME;
            Contact aContact = [SELECT Id FROM Contact WHERE LastName=:CONTACT_LAST_NAME];
            u.contactId = aContact.Id;
        }
        else {
            u.UserName = INTEGRATION_ADMIN_USERNAME;
        }
        insert u;
    }
    
    private static void createTestAccount() {
        Account acct = new Account(Name = ACCOUNT_NAME,
                           BillingStreet = 'test street',
                           BillingCity = 'test city',
                           BillingState = 'Alabama',
                           BillingCountry = 'United States',
                           ShippingCountry = 'United States',
                           BillingPostalCode = '012345',
                           Website = 'www.test.com'
                           );
        acct.Seller_Onboarding_Status__c = 'Live on Site';
        acct.Seller_Onboarding_Live_Status__c = 'Ops Ready';
        insert acct;
    }
    
    private static void createTestContact() {
        Account acct = [SELECT Id FROM Account WHERE Name=:ACCOUNT_NAME];
        Contact sellerContact = new Contact( FirstName = 'seller',
                            LastName = CONTACT_LAST_NAME,
                            Title = 'Tester',
                            Phone = '12345678',
                            Email = 'testcontact@test.com',
                            MailingCountry = 'United States',
                            AccountId = acct.id); 
        insert sellerContact;
    }
    
    private static void createTestCase() {
        Account anAccount = [SELECT Id FROM Account WHERE Name=:ACCOUNT_NAME];
        Contact aContact = [SELECT Id FROM Contact WHERE LastName=:CONTACT_LAST_NAME];
        Case newCase = new Case(Subject=CASE_SUBJECT,
                                Status='WIP',
                                AccountId=anAccount.Id,
                                ContactId=aContact.Id);
        insert newCase;
        
    }
    
    private static void createJiraIssue() {
        zsfjira__ZIssue__c ziss = new zsfjira__ZIssue__c();
        ziss.zsfjira__IssueId__c = 1002;
        ziss.Name = ziss.zsfjira__IssueKey__c = ISSUE_NAME;
        ziss.zsfjira__Status__c = 'Open';
        insert ziss;
        
        Case aCase = [SELECT Id FROM Case WHERE Subject=:CASE_SUBJECT];
        
        // create issue-case relationship
        zsfjira__ZIssue_Case__c issueCaseRel = new zsfjira__ZIssue_Case__c();
        issueCaseRel.zsfjira__ZIssueId__c = ziss.Id;
        issueCaseRel.zsfjira__CaseId__c = aCase.Id;
        insert issueCaseRel;
    }

}
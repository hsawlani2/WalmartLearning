@isTest
private class TestCaseHelpers {

    @testSetup static void setupTestData() {
        Account acct = new Account();
        acct.Name = 'Test Account Data';
        insert acct;
        
        ATTACHMENT_MAXIMUM_SIZE_LIMIT__c amsl = new ATTACHMENT_MAXIMUM_SIZE_LIMIT__c();
        amsl.Name = 'MAX_SIZE_LIMIT';
        amsl.MAX_SIZE_IN_MB__c = 3;
        insert amsl;
        
          
        ATTACHMENT_BLACKLISTED_EXTENSIONS__c docx = new ATTACHMENT_BLACKLISTED_EXTENSIONS__c();
        docx.Name = 'DOCX';
        docx.File_Extension_Type__c = 'Microsoft office document';
        insert docx;
        
        ATTACHMENT_BLACKLISTED_EXTENSIONS__c exefiles = new ATTACHMENT_BLACKLISTED_EXTENSIONS__c();
        exefiles.Name = 'EXE';
        exefiles.File_Extension_Type__c = 'Executable file';
        insert exefiles;

    }

    private static testMethod void testCommentAttachments() {
        ContentVersion cv = new ContentVersion(
        pathonclient = 'sampledoc.exe',
        versionData = EncodingUtil.base64Decode('SampleImageFile')
        );
        insert cv; 
        
        
        FeedItem f = new FeedItem();
        f.ParentId = UserInfo.getUserId();
        f.body = 'test';
        insert f;

        FeedComment fc = new FeedComment();
        fc.CommentBody = 'Test Comment Bod';
        fc.FeedItemId = f.Id; 
        fc.relatedRecordId = cv.id;
        
        try {
            insert fc;        
            System.assert(false, 'Should have failed');
        }
        catch (Exception e) {
            System.assert(e.getMessage().contains('file type is not allowed for attachments'), 'Should contain error message');
        }
    }
    
    private static testMethod void testCommentNoAttachment() {
        FeedItem f = new FeedItem();
        f.ParentId = UserInfo.getUserId();
        f.body = 'test';
        insert f;

        FeedComment fc = new FeedComment();
        fc.CommentBody = 'Test Comment Bod';
        fc.FeedItemId = f.Id; 
        
        try {
            insert fc;        
        }
        catch (Exception e) {
            System.assert(false, 'Should have succeeded');
        }
    }
    
    
    private static testMethod void testAttachments() 
    {
        String acctName = 'Test Account Data';
        Account accnt= [SELECT Id FROM Account WHERE Name = :acctName];
        
        Attachment attach = new Attachment();    
        attach.Name = 'UnitTestAttachment.txt';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.Body = bodyBlob;
        attach.ParentId = accnt.Id;
        
        try {
            insert attach;
        }
        catch (Exception e) {
            System.assert(false, 'Should have succeeded');
        }
     
    }
    
     private static testMethod void testAttachmentsExtUpper() 
    {
        System.debug('<<< Starting testAttachmentsExtUpper');
        String acctName = 'Test Account Data';
        Account accnt= [SELECT Id FROM Account WHERE Name = :acctName];
        
        Attachment attach = new Attachment();    
        attach.Name = 'UnitTestAttachment.docx';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.Body = bodyBlob;
        attach.ParentId = accnt.Id;
        
        try {
            insert attach;
            System.assert(false, 'Should have failed');
        }
        catch (Exception e) {
            System.assert(e.getMessage().contains('file type is not allowed for attachments!'), 'Should contain error message');
        }
    }
    
    private static testMethod void testCasesHomePage() {
        
        PKB_TOKEN_COOKIE_TIMEOUT_HOURS__c timeOutSetting = new PKB_TOKEN_COOKIE_TIMEOUT_HOURS__c(Name='Default', TIMEOUT_HOURS__c=4);
        insert timeOutSetting;
        KNOWLEDGEBASE_URL__c urlSetting = new KNOWLEDGEBASE_URL__c(Name='Default', KB_URL__c='http://someweb.com/');
        insert urlSetting;
        
        HomePageVFComponentController aController = new HomePageVFComponentController();
        System.assert(String.isNotBlank(aController.kbURL), 'Must not be blank');
           
    }
    
    

}
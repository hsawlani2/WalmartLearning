/**
 * @description Test class for CaseController class
 * @author Josephine Del Mundo
 * @date 09.FEB.2016
 */    
@isTest
private class TestCaseNeedInfoController{ 
    
    private static Account acct;
    private static Contact sellerContact;
    private static Case caseRec;
    private static Case caseRecTrigger;
   
   
   /**
    * @description method to test on page load 
    *               when case record status is Need Info 
    *               and Infor received is true
    * @author Josephine Del Mundo
    * @date 09.FEB.2016
    */
    private static testMethod void testControllerMethod() {
        JIRA_CONFIG__c jiraConfig = new JIRA_CONFIG__c();
        jiraConfig.Name = 'CONFIG';
        jiraConfig.URL__c = 'test.com';
        jiraConfig.UserName__c = 'test';
        jiraConfig.Password__c = 'test';
        
        insert jiraConfig;
        
        acct = new Account(Name = 'test Acc',
                           BillingStreet = 'test street',
                           BillingCity = 'test city',
                           BillingState = 'Alabama',
                           BillingCountry = 'United States',
                           ShippingCountry = 'United States',
                           BillingPostalCode = '012345',
                           Website = 'www.test.com');
        insert acct;
        
        sellerContact = new Contact( FirstName = 'seller',
                            LastName = 'contact',
                            Title = 'Tester',
                            Phone = '12345678',
                            Email = 'testcontact@test.com',
                            MailingCountry = 'United States',
                            AccountId = acct.id); 
        insert sellerContact;
        
        // Create case records
        caseRec = new Case(Status = 'WIP',
                           Subject = 'testCase', 
                           AccountId = acct.Id, ContactId = sellerContact.Id);
        insert caseRec; 

        
        Test.setCurrentPageReference(new PageReference('Page.caseNeedInfo')); 
        ApexPages.currentPage().getParameters().put('caseId', caseRec.Id);

        Test.startTest();
        CaseNeedInfoController controller = new CaseNeedInfoController();
        controller.sellerComments = 'Test Comments';
        controller.requestInfoFromSeller();
        controller.back();
        Test.StopTest();
    }
    
    private static testMethod void testErrors() {
        createTestCustomSettings();
        User aUser = createTestUser('Seller Community Support Manager');
        Case aCase = createTestCase(WalmartConstants.ONBOARDING_CASE_RECORD_TYPE_NAME, null, false);
        System.runAs(aUser) {
            Test.setCurrentPage(Page.caseNeedInfo); 
            ApexPages.currentPage().getParameters().put('caseId', aCase.Id);
            
            Test.startTest();
            CaseNeedInfoController controller = new CaseNeedInfoController();
            controller.requestInfoFromSeller();
            Test.stopTest();
            
            // @see CaseNeedInfoController, line 39
            // System.assertEquals(false, controller.isEditAllowed);
            
        }
    }
    
    private static testMethod void testControllerWithCaseInfo() {
        System.debug('<<< Beginning testControllerWithOwner');
        createTestCustomSettings();
        User aUser = createTestUser('Seller Community Support Manager');
        insert aUser;
        Case aCase = createTestCase(WalmartConstants.ONBOARDING_CASE_RECORD_TYPE_NAME, aUser, true);
        Test.setCurrentPage(Page.caseNeedInfo); 
        ApexPages.currentPage().getParameters().put('caseId', aCase.Id);
            
        Test.startTest();
        CaseNeedInfoController controller = new CaseNeedInfoController();
        Test.stopTest();
        
         System.assertEquals(true, controller.isCaseAlreadyInNeedInfo);//Commented by Ashok Panbuchelvam
    }
    
    private static testMethod void testControllerWithNoCaseInfo() {
        System.debug('<<< Beginning testControllerWithOwner');
        createTestCustomSettings();
        User aUser = createTestUser('Seller Community Support Manager');
        insert aUser;
        Case aCase = createTestCase(WalmartConstants.ONBOARDING_CASE_RECORD_TYPE_NAME, aUser, false);
        Test.setCurrentPage(Page.caseNeedInfo); 
        ApexPages.currentPage().getParameters().put('caseId', aCase.Id);
            
        Test.startTest();
        CaseNeedInfoController controller = new CaseNeedInfoController();
        Test.stopTest();
        
        System.assertEquals(false, controller.isCaseAlreadyInNeedInfo); // Commented by Ashok Panbuchelvam
    }

   /**
    * @description method to test on caseTrigger
    * @author Josephine Del Mundo
    * @date 09.FEB.2016
    */
    private static testMethod void testCaseTrigger(){
        
        acct = new Account(Name = 'test Acc',
                           BillingStreet = 'test street',
                           BillingCity = 'test city',
                           BillingState = 'Alabama',
                           BillingCountry = 'United States',
                           ShippingCountry = 'United States',
                           BillingPostalCode = '012345',
                           Website = 'www.test.com');
        insert acct;
        
        sellerContact = new Contact( FirstName = 'seller',
                            LastName = 'contact',
                            Title = 'Tester',
                            Phone = '12345678',
                            Email = 'testcontact@test.com',
                            MailingCountry = 'United States',
                            AccountId = acct.id); 
        insert sellerContact;
        
        caseRecTrigger = new Case(Status = 'WIP', Subject = 'testCase', AccountId=acct.id, ContactId=sellerContact.Id);
        insert caseRecTrigger; 
        
        caseRecTrigger.Status = 'Need Info';
        try {
            update caseRecTrigger;
        } catch (Exception e) {
            // ignore
        }
    }
    
    private static Case createTestCase(String recordTypeName, User integrationEngineer, Boolean hasCaseInfo) {
        
        Id recordTypeId = [SELECT Id 
                            FROM RecordType 
                            WHERE Name = :recordTypeName limit 1].Id;
        
        acct = new Account(Name = 'test Acc',
                           BillingStreet = 'test street',
                           BillingCity = 'test city',
                           BillingState = 'Alabama',
                           BillingCountry = 'United States',
                           ShippingCountry = 'United States',
                           BillingPostalCode = '012345',
                           Website = 'www.test.com'
                           );
        if (integrationEngineer != null) {
            acct.Integration_Engineer__c = integrationEngineer.Id;
        }
        insert acct;
        
        sellerContact = new Contact( FirstName = 'seller',
                            LastName = 'contact',
                            Title = 'Tester',
                            Phone = '12345678',
                            Email = 'testcontact@test.com',
                            MailingCountry = 'United States',
                            AccountId = acct.id); 
        insert sellerContact;
        
        // Create case records
        Case aCase = new Case(Status = 'WIP',
                           Subject = 'testCase', 
                           AccountId = acct.Id, ContactId = sellerContact.Id, recordTypeId = recordTypeId);
        if (hasCaseInfo) {
            aCase.Status = 'Need Info';
            aCase.Info_Received__c = true;
        }
        insert aCase; 
        return aCase;
    }
    
    
    private static User createTestUser(String profileName) {
        
        Profile p = [SELECT Id FROM Profile WHERE Name=:profileName];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg111.com'
                );
                
        return u;
    }
    
    private static void createTestCustomSettings() {
        OPERATION_PROFILE_NAMES__c operationsSetting = new OPERATION_PROFILE_NAMES__c(Name='Seller Community Support Manager');
        insert operationsSetting;
        
        ONBOARDING_PROFILE_NAMES__c onboardingSetting = new ONBOARDING_PROFILE_NAMES__c(Name='Operations Team (onboarding)');
        insert onboardingSetting;
    }
}
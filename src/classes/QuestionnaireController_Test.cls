@isTest
private class QuestionnaireController_Test {


    @testSetup static void setupTestData() {
        Account accnt = new Account();
        accnt.Name = 'Test Account Data';
        insert accnt;

        Contact cont = new Contact();
        cont.FirstName='Test';
        cont.LastName='Test';
        cont.AccountId= accnt.Id;
        insert cont;
        
        cont = [SELECT Id FROM Contact WHERE FirstName = 'Test'];
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity Data';
        opp.AccountId= accnt.Id;
        opp.StageName = 'Opportunity';
        opp.CloseDate = Date.today();
        
        opp.Primary_Contact__c = cont.Id;
        
        insert opp;
        
        Account accntNew = new Account();
        accntNew.Name = 'Test New Account';
        insert accntNew;
    
        DataBuilder.createCategoryList();
        Application_Seller_Link_Test.setUpTestData();
    }

    private static testMethod void testInitDirectSellerParam() {
         //Test existing Direct Seller param
        String directSellerName = 'Test Account Data';
        Account ac = [SELECT Name FROM Account WHERE Name = :directSellerName];

        ApexPages.currentPage().getParameters().put('account_id', ac.Id);
        
        QuestionnaireController controller = new QuestionnaireController();
        System.assert(controller.application != null, 'Success!');
        
        System.assert(controller.qCon != null, 'Must not be null');
    }
    

    private static testMethod void testInitBlockedDirectSeller() {
         //Test existing Direct Seller without Contact and Opportunity
        String directSellerName = 'Test New Account';
        Account ac = [SELECT Name FROM Account WHERE Name = :directSellerName];

        ApexPages.currentPage().getParameters().put('account_id', ac.Id);
        
        QuestionnaireController controller = new QuestionnaireController();
        System.assert(controller.application != null, 'Success!');
    }
    
    private static testMethod void testInitDirectSellerParamNotExist() {
        //Test Direct Seller param not exist
        String channelPartnerId = '0014B000004SZ4r';
        ApexPages.currentPage().getParameters().put('account_id', channelPartnerId);
        QuestionnaireController controllerChannel = new QuestionnaireController();
        System.assert(controllerChannel.isApplicationBlocked == true, 'Success!');
       
    }

    private static testMethod void testInitChannelPartnerParam() {
        //Test Channel partner param
        String channelPartnerName = 'Test Account Data';
        Account ac = [SELECT Name FROM Account WHERE Name = :channelPartnerName];

        ApexPages.currentPage().getParameters().put('cId', ac.Id);
        QuestionnaireController controllerChannel = new QuestionnaireController();
        System.assert(controllerChannel.application != null, 'Success!');
    }

    private static testMethod void testInitChannelPartnerParamNotExist() {
        //Test Channel partner param not exist
        String channelPartnerId = '0014B000004SZ4r';
        ApexPages.currentPage().getParameters().put('cId', channelPartnerId);
        QuestionnaireController controllerChannel = new QuestionnaireController();
        System.assert(controllerChannel.isApplicationBlocked == true, 'Success!');
       
    }
    
    private static testMethod void testInitNonExistingParam() {
        //Test empty param
        QuestionnaireController controllerNonExisting = new QuestionnaireController();
        System.assert(controllerNonExisting.isApplicationBlocked == true, 'Success!');
    }
    
    private static testMethod void testSavingApplication() {
         //Test saving application
        String directSellerName = 'Test Account Data';
        Account ac = [SELECT Name FROM Account WHERE Name = :directSellerName];
        
        PageReference pageRef = Page.seller_questionnaire_main;
        Test.setCurrentPageReference(pageRef); 
        ApexPages.currentPage().getParameters().put('account_id', ac.Id);
        
        QuestionnaireController controller = new QuestionnaireController();
        
        controller.application.Primary_Contact_Email__c = 'test@test.com';
        controller.application.Primary_Contact_First_Name__c = 'First';
        controller.application.Primary_Contact_Last_Name__c = 'Last';
        controller.application.Legal_Company_Name__c = 'Testing Company Name';
        controller.application.Other_Marketplace__c = 'Testing Other Marketplace Name';
        controller.taxID = '99-9999999';
        
        controller.selectedCategories = ApplicationCategoryData_Test.createTestData(controller.categoryList).serialize();
        
        //add attachment name and body
        Blob attachmentBody = Blob.valueOf('Test Data');
        controller.attachment.Name = 'Test Attachment for Parent';
        controller.attachment.Body = attachmentBody;
     
        
        Test.startTest();
        controller.saveApplicationData();
        Test.stopTest();
        
        Application__c app =  [SELECT Primary_Contact_Email__c, Other_Marketplace__c, Tax_ID__c FROM Application__c WHERE Id = :controller.application.Id];
        
        System.assertEquals(app.Primary_Contact_Email__c, controller.application.Primary_Contact_Email__c, 'Success!!');
        System.assertEquals(app.Other_Marketplace__c, controller.application.Other_Marketplace__c, 'Success!!');     
        System.assert(app.Tax_ID__c.equals('99-9999999'), 'Tax ID must be equal');
    }
    
    private static testMethod void testSavingApplicationNoCategory() {
         //Test saving application
        String directSellerName = 'Test Account Data';
        Account ac = [SELECT Name FROM Account WHERE Name = :directSellerName];
        
        PageReference pageRef = Page.seller_questionnaire_main;
        Test.setCurrentPageReference(pageRef); 
        ApexPages.currentPage().getParameters().put('account_id', ac.Id);
        
        QuestionnaireController controller = new QuestionnaireController();
        
        Test.startTest();
        controller.saveApplicationData();
        Test.stopTest();
    }
    
    private static testMethod void testSavingFulfillmentProviders() {
        String directSellerName = 'Test Account Data';
        Account ac = [SELECT Name FROM Account WHERE Name = :directSellerName];
        
        PageReference pageRef = Page.seller_questionnaire_main;
        Test.setCurrentPageReference(pageRef); 
        ApexPages.currentPage().getParameters().put('account_id', ac.Id);
        
        QuestionnaireController controller = new QuestionnaireController();
        
        controller.application.Fulfillment_Service_Provider_1__c = 'Amazon.com';
        controller.application.Percentage_of_Total_Orders_Shipped_1__c = 0.67;
        
        controller.application.Fulfillment_Service_Provider_2__c = 'Ebay.com';
        controller.application.Percentage_of_Total_Orders_Shipped_2__c = 0.25;
        
        controller.application.Fulfillment_Service_Provider_3__c = 'Others.com';
        controller.application.Percentage_of_Total_Orders_Shipped_3__c = 0.5;
        
        controller.application.Fulfillment_Service_Provider_4__c = '.com';
        controller.application.Percentage_of_Total_Orders_Shipped_4__c = 0.75;
        
        Test.startTest();
        controller.saveApplicationData();
        Test.stopTest();
        
        //System.assertEquals(0.67, controller.application.Amazon_Fulfillment_Perc__c);
        System.assertEquals(0.50, controller.application.Others_Fulfillment_Perc__c);
    }
    
    private static testMethod void testMarketplaceOptions() {
        QuestionnaireController qCon = new QuestionnaireController();
        List<SelectOption> options = qCon.allMarketplaceSelectionOptions;
        System.assert(options.size() > 0, 'Should not be empty');
    }
    
    private static testMethod void testCategoriesPage() {
        
        QuestionnaireController qCon = new QuestionnaireController();
        
        System.assert(qCon.categoriesPage1.size() > 0, 'Should not be empty');
        System.assert(qCon.categoriesPage2.size() > 0, 'Should not be empty');
        System.assert(qCon.categoriesPage3.size() > 0, 'Should not be empty');
    }
    

}
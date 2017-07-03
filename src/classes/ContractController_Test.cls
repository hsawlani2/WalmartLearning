@isTest
private class ContractController_Test {
    
    private static final String TEST_FIRST = 'Test_first';
    private static final String TEST_LAST = 'Test_last';
    private static final String TEST_TITLE = 'Test_title';
    private static final String FICTITIOUS_ID = '0014B000004qa4Q';

    private static testMethod void testInitHappy() {
        String accountId = buildContractReadyTestData(true, true, true, true);
        PageReference pageRef = Page.seller_contract;
        Test.setCurrentPageReference(pageRef); 
        System.currentPageReference().getParameters().put(ContractController.ACCT_PARAM, accountId);
        ContractController cController = new ContractController();
        System.assert(cController.isApplicationBlocked == false, 'Must not be blocked');
        
        System.assert(cController.cCon != null, 'There should be an instance created');
    }
    
    private static testMethod void testMissingParameter() {
        PageReference pageRef = Page.seller_contract;
        Test.setCurrentPageReference(pageRef); 
        ContractController cController = new ContractController();
        System.assert(cController.isApplicationBlocked == true, 'Must be blocked');
    }
    
    private static testMethod void testFictitiousAccount() {
        PageReference pageRef = Page.seller_contract;
        Test.setCurrentPageReference(pageRef); 
        System.currentPageReference().getParameters().put(ContractController.ACCT_PARAM, FICTITIOUS_ID);
        ContractController cController = new ContractController();
        System.assert(cController.isApplicationBlocked == true, 'Must be blocked');
    }
    
    private static testMethod void testInitMissingOppOrContact() {
        String accountId = buildContractReadyTestData(true, false, false, false);
        PageReference pageRef = Page.seller_contract;
        Test.setCurrentPageReference(pageRef); 
        System.currentPageReference().getParameters().put(ContractController.ACCT_PARAM, accountId);
        ContractController cController = new ContractController();
        System.assert(cController.isApplicationBlocked == true, 'Must be blocked');
    }

    private static testMethod void testInitMissingApplication() {
        String accountId = buildContractReadyTestData(true, true, true, false);
        PageReference pageRef = Page.seller_contract;
        Test.setCurrentPageReference(pageRef); 
        System.currentPageReference().getParameters().put(ContractController.ACCT_PARAM, accountId);
        ContractController cController = new ContractController();
        System.assert(cController.isApplicationBlocked == true, 'Must be blocked');
    }
    
    private static testMethod void testSaveContract() {
        String accountId = buildContractReadyTestData(true, true, true, true);
        PageReference pageRef = Page.seller_contract;
        Test.setCurrentPageReference(pageRef); 
        System.currentPageReference().getParameters().put(ContractController.ACCT_PARAM, accountId);
        ContractController cController = new ContractController();
        
        PageReference pr = cController.saveContract();
        System.assert(cController.isApplicationCompleted, 'Application shouldve been completed');
        System.assert(pr.getParameters().get(ApplicationFormUtils.MESSAGE_CODE).equals(ApplicationFormUtils.CONTRACT_SUCCESS_CODE), 'Should be equal');
    }

    // Returns ID of account
    private static String buildContractReadyTestData(Boolean createAccount, Boolean createContact, Boolean createOpp, Boolean createApp) {
        
        Application_Settings__c csAS = new Application_Settings__c(Name = 'Default', Current_Contract_Version__c='1.0');
        insert csAS;
        
        String accountId = null;
        String oppId = null;
        Contact con = null;
        
        if (createAccount) {
            String acctName = 'Test account';
            Account anAccount = DataBuilder.createAccount(acctName);
            insert anAccount;
            Account anAccountFromDB = [SELECT Id, Name FROM Account WHERE Name = :acctName];
            
            System.assert(anAccountFromDB.Id != null, 'Should not be null');
            accountId = anAccountFromDB.Id;
        }
        
        if (createContact) {
            con = new Contact(LastName=TEST_LAST, FirstName=TEST_FIRST, Title=TEST_TITLE, AccountId=accountId);
            insert con;
            con = [SELECT Id, FirstName, LastName, Title, Email, Phone FROM Contact WHERE LastName=:TEST_LAST];
        }
        
        if (createOpp) {
            String oppName = 'Test_opp';
            Opportunity opp = new Opportunity(AccountId=accountId, Name=oppName, StageName=ContractController.OPP_STAGE_NAME, CloseDate=Date.today(), Primary_Contact__c=con.Id);
            insert opp;
            
            Opportunity oppFromDB = [SELECT Id FROM Opportunity WHERE Name=:oppName];
            System.assert(oppFromDB.Id != null, 'Should not be null');
            oppId = oppFromDB.Id;
        }
        
        if (createApp) {
            Application__c app = new Application__c(Account__c=accountId, Opportunity__c=oppId, Primary_Contact_First_Name__c=con.FirstName, 
            Primary_Contact_Last_Name__c=con.LastName, Primary_Contact_Title__c=con.Title, Primary_Contact_Email__c='Emailtest@test.com', 
            Legal_Company_Name__c='Test company');
            insert app;
        }
        
        return accountId;
        
    }

}
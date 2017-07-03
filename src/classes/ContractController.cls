public class ContractController {
    
    public Application__c application { get; set; }
    private Opportunity opportunity { get; set; }
    
    public String companyName { get; set; }
    public String contactName { get; set; }
    public String contactTitle { get; set; }
    public String contactPhone { get; set; }
    public String contactEmail { get; set; }
    
    // Flag is turned on when no matching Opportunities are found.
    // This means that either the Opportunity is past the 'Opportunity' Stage or there are problems with the get parameters.
    // We'll show an error dialog that blocks the user from proceeding.
    public Boolean isApplicationBlocked { get; set; }
    
    // A flag than is turned on after the form is submitted and saved.
    // When this is turned on, the dialog will be displayed the moment the page reloads.
    public Boolean isApplicationCompleted { get; set; }
    
    public ContractController cCon { get { return this; } }
    
    // This flag allows us to fetch Opportunities that are outside the correct Stage Name
    private Boolean testMode = false;
    
    public final static String ACCT_PARAM = 'account_id';
    public final static String OPP_STAGE_NAME = 'Awaiting Contract';
    
    public ContractController() {
        
        isApplicationBlocked = false;
        String accountId = ApexPages.currentPage().getParameters().get(ACCT_PARAM);
        System.debug('\n\nLQ: Began contract path with account id ' + accountId + '\n');
        if (accountId != null) {
            initializeUsingAccountId(accountId);
        }
        else if (!testMode) {
            System.debug('missing accountId');
            isApplicationBlocked = true;
        }
        
    }
    
    private void initializeUsingAccountId(String accountId) {
        Account anAccount = ApplicationFormUtils.fetchAccount(accountId, testMode);
        if (anAccount != null) {
            // fetch opportunity now
            opportunity = ApplicationFormUtils.fetchOpportunity(anAccount.Id, OPP_STAGE_NAME, !testMode, false, true);
            Contact aContact = ApplicationFormUtils.fetchContact(opportunity);
            
            if (opportunity != null && aContact != null) {
                application = ApplicationFormUtils.fetchApplicationWithOpportunity(opportunity.Id);
                if (application == null) {
                    // At this point application record should be already there!
                    system.debug('missing application ');
                    isApplicationBlocked = true;
                }
                else {
                    companyName = anAccount.Name;
                    contactName = aContact.Name;
                    contactTitle = aContact.Title;
                    contactPhone = aContact.Phone;
                    contactEmail = aContact.Email;
                }
            }
            else {
                system.debug('missing contact and/or opportunity ');
                isApplicationBlocked = true;
            }
        }
        else {
            System.debug('missing account! ' + accountId);
            isApplicationBlocked = true;
        }
    }
    
    public PageReference saveContract() {
        String messageCode = ApplicationFormUtils.ERROR_CODE;
        if (application != null && application.Id != null) {
            application.Contract_Acknowledgement_Acceptance__c = DateTime.now();
            System.debug('\n\nLQ: Saving contract ' + application.Contract_Acknowledgement_Acceptance__c + '\n');
            
            // also update Opportunity
            opportunity.Contract_Acknowledged_by_Name__c = contactName;
            opportunity.Contract_Acknowledged_by_Title__c = contactTitle;
            opportunity.Contract_Acknowledgement_Acceptance__c = application.Contract_Acknowledgement_Acceptance__c;
            opportunity.Version_no__c = Application_Settings__c.getInstance('Default').Current_Contract_Version__c;
            
            try {
                update application;
                update opportunity;
            }
            catch (DMLException e) {
                System.debug('Error encountered! ' + e.getMessage());
                // Show an error during save
            } finally {
                // Any finally clauses?
            }
            
            isApplicationCompleted = true;
            messageCode = ApplicationFormUtils.CONTRACT_SUCCESS_CODE;
        }
        else {
            System.debug('\n\nLQ: Not saving anything: application is not inserted yet! \n');
        }
        PageReference pr = Page.FormSaveSuccess;
        pr.getParameters().put(ApplicationFormUtils.MESSAGE_CODE, messageCode);
        return pr;
    }

}
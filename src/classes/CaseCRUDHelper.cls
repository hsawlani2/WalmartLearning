/**
 * Helper class for operations related to Case CRUD operations.
 * 
 * @author      Cloud Sherpas
 * @createddate 4-Feb-2016
 */ 
public class CaseCRUDHelper {
    
    /*
     * A marker variable used to communicate between CaseController and the trigger.
     * 
     * This variable is used as a thread communication mechanism to
     * communicate with the trigger on Case update scenarios to 
     * allow the Case status to be changed to Need Info whenever the
     * flow is triggered from the VF page.
     * 
     * In all other scenarios, this flag being true, the Status cannot
     * be changed to Need Info if a User tries to change it from
     * the UI.
     */ 
    public static Boolean NEED_INFO_EDITED_FROM_UI = true;
    
    /* Record types */
    private static String SELLER_COMMUNITY_CASE;
    private static String SELLER_COMMUNITY_ONBOARDING_CASE;
    private static String SUPPLIER_COMMUNITY_CASE;
    
    static {
        SELLER_COMMUNITY_CASE = [SELECT Id 
                                 FROM RecordType 
                                 WHERE Name = :WalmartConstants.OPERATION_CASE_RECORD_TYPE_NAME limit 1].Id;
        
        SELLER_COMMUNITY_ONBOARDING_CASE = [SELECT Id 
                                            FROM RecordType 
                                            WHERE Name = :WalmartConstants.ONBOARDING_CASE_RECORD_TYPE_NAME limit 1].Id;
        
        SUPPLIER_COMMUNITY_CASE = [SELECT Id 
                                            FROM RecordType 
                                            WHERE Name = :WalmartConstants.SUPPLIER_CASE_RECORD_TYPE_NAME limit 1].Id;                                    
    }

    
    /**
     * The method overrides the OOTB Case Assignment Rules.
     * 
     * This method takes care of looking up the appropriate assignment
     * rule as defined in the rule engine based on the input on the Case on:
     * Issue Category, Sub Cat 1-3, Case Priority and additionally Account Tier.
     * 
     * Based on the rule as fetched, the Action on the Case is determined and
     * appropriately the respective action is taken
     * 
     * @see CaseAssignmentRuleEngine
     * 
     * @param incomingCase      the Case being created
     */ 
    public static void runCaseAssignmentRules(Case incomingCase) {
        If(incomingCase.RecordTypeId == SUPPLIER_COMMUNITY_CASE){
            CaseAssignmentRuleEngine.runSupplierCaseAssignmentRules(incomingCase);
        }else{
            CaseAssignmentRuleEngine.runCaseAssignmentRules(incomingCase);
        }
        
    }
    
    
    /**
     * A method to verify the Support User profile and restrict edits on the
     * case types that they do not support.
     * 
     * E.g., A operation support user should not be able to edit onboarding case and vice-versa
     * 
     * @caseRecord      the record in consideration
     * @userProfileName the profile name of the support user
     */ 
    public static void verifyProfileAndRestrictEdits(Case caseRecord, String userProfileName,Case oldCaseRecord) {

        String recordTypeName = [select Name from RecordType where Id = :caseRecord.RecordTypeId limit 1].Name;
        // onboarding case and operation profile
        if(recordTypeName == WalmartConstants.ONBOARDING_CASE_RECORD_TYPE_NAME
           && CaseUtility.getOperationProfileNames().contains(userProfileName)) {
            caseRecord.addError('You cannot edit an Onboarding Case record!');       
        }

        // operation case and onboarding profile
        if(recordTypeName == WalmartConstants.OPERATION_CASE_RECORD_TYPE_NAME
           && CaseUtility.getOnboardingProfileNames().contains(userProfileName)) {
            caseRecord.addError('You cannot edit an Operation Case record!');       
        }
        
        String userObj = [SELECT UserRole.Name from User where Id =: UserInfo.getUserId()].UserRole.Name;
        UserRecordAccess  userRecordObj = [SELECT RecordId, HasEditAccess,MaxAccessLevel FROM UserRecordAccess WHERE UserId =: UserInfo.getUserId() AND RecordId = :caseRecord.Id];
        system.debug('..userob.. '+userObj + '.. record access.. '+userRecordObj+ '.. case Idss.. '+caseRecord.RecordTypeId);
        if(!userRecordObj.HasEditAccess && userObj != WalmartConstants.SOCKM_HELPDESK_MANAGER && userObj != WalmartConstants.SOCKM_HELPDESK_USER && caseRecord.ownerId != oldCaseRecord.ownerId){
            caseRecord.addError('You cannot edit this Case record!');
        }
    }


    
    /**
     * Helper method to create the deflection record during the new case creation flow on
     * the Seller Community.
     * 
     * @param originalCaseRecordType    the case record type (Operations or Onboarding)
     * @param contactId                 the contact id/user id creating the case
     * @param accountId                 the account for which the case was being created
     */ 
    public static Id createCaseDeflectionRecord(String originalCaseRecordType, Id contactId, Id accountId) {
        
        Case_Initiation__c deflection;
        try {
            deflection = 
                new Case_Initiation__c(
                    Account__c = accountId, 
                    Contact__c = contactId, 
                    Deflected__c = true,
                    Case_Type__c = 
                        (originalCaseRecordType == WalmartConstants.OPERATION_CASE_RECORD_TYPE_NAME 
                            ? WalmartConstants.OPERATION_DEFLECTION : WalmartConstants.ONBOARDING_DEFLECTION)
                );
            
            insert deflection;
        } catch (Exception e) {
            // consume, as it should not restrict case creation flow
            system.debug(LoggingLevel.ERROR, 'Error creation deflection record!' + e.getStackTraceString());
        }
        return (deflection != null) ? deflection.Id : null;
    }
    
    
    /**
     * Helper method to update the deflection record that was created during the new case creation flow,
     * if the Seller went ahead and created the case in the flow.
     * 
     * - The Deflected field is set to false which categorizes that the case was created.
     * - The Case number is updated on the record with the case that was created
     * 
     * @param deflectionRecordId    the record to be updated
     */ 
    public static void updateDeflectionRecord(Id deflectionRecordId, Id caseId, String caseSubject) {
        system.debug('..deflection Id.. '+deflectionRecordId);
        try {
            Case_Initiation__c deflectionRecord = [select Deflected__c, Case__c,Case_Subject__c
                                                   from Case_Initiation__c where id = :deflectionRecordId limit 1];
            deflectionRecord.Deflected__c = false;
            deflectionRecord.Case__c = caseId;
            deflectionRecord.Case_Subject__c = caseSubject;
            
            update deflectionRecord;
        } catch (Exception e) {
            // consume, as it should not restrict case creation flow
            system.debug(LoggingLevel.ERROR, 'Error updating deflection record!' + e.getStackTraceString());
        }
        
    }


    /**
     * Helper method to send case assignment notification if the case was assigned
     * to Integration lead.
     * 
     * @param caseRecord    the case record in consideration
     */ 
    public static void sendCaseAssignmentEmail(Case caseRecord) {
        
        try {
            // only for Onboarding case types
            Id onboardingRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(
                WalmartConstants.ONBOARDING_CASE_RECORD_TYPE_NAME).getRecordTypeId();
            
            if(caseRecord.RecordTypeId == onboardingRecordTypeId) {
                Id ONBOARDING_QUEUE = 
                    [SELECT QueueId FROM QueueSobject WHERE Queue.Name = :WalmartConstants.ONBOARDING_QUEUE_NAME limit 1].QueueId;
                
                // if the owner is queue, then do nothing
                if(caseRecord.OwnerId == ONBOARDING_QUEUE) {
                    return;
                }
                
                // else send email to Integration Lead
                //OrgWideEmailAddress fromEmail = [select Id, Address, DisplayName from OrgWideEmailAddress limit 1];
                EmailTemplate emailTemplate = [SELECT Id 
                                               FROM EmailTemplate WHERE Name = :WalmartConstants.CASE_ASSIGNMENT_TEMPLATE];
                /* Trigger Email */
                Messaging.reserveSingleEmailCapacity(2);
                Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();
                
                // As mentioned in http://salesforce.stackexchange.com/a/1840 , WhatId cannot be set if the targetObjectId is not a contact.
                // Let's use the solution specified there, i.e. create a temporary contact to use here
                User user = [select email, firstName, lastName from User where id = :caseRecord.OwnerId];
                Contact tempContact = new Contact(email = user.email, firstName = user.firstName, lastName = user.lastName);
                insert tempContact;
                
                emailMsg.setSenderDisplayName('Case Notification');
                emailMsg.setSaveAsActivity(false);
                emailMsg.setTemplateId(emailTemplate.Id);
                emailMsg.setTargetObjectId(tempContact.Id);
                emailMsg.setWhatId(caseRecord.Id);
                
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { emailMsg });        
                
                // delete the temporary contact
                delete tempContact;
            }
        } catch (Exception e) {
            system.debug(LoggingLevel.ERROR, 
                         'Error sending case assignment notification to Integraiton Lead - ' + e.getStackTraceString());
        }
    }
    
    
    /**
     * Method which creates the request parameter for the new case creation based on the
     * user type, account status, etc. to help render the respective case creation form.
     * 
     * @param accountId         the account for which the case is being created
     * @param contactId         the contact on the account
     * @param parentCaseNumber  the parent case number if the flow is from follow up case
     * @param isCPCaseForSeller a parameter to identify if the Channel Partner is creating case for self or seller
     * @param theRecordTypeName the record type can be explicitly stated by the caller. if this is the case, the record type does not need to be computed.
     * 
     * @return the page reference to the new case creation form
     */ 
    public static PageReference createCaseCreationFormURL(
        Id accountId, Id contactId, Boolean isFollowUpCase, String parentCaseNumber, Boolean isCPCaseForSeller, String theRecordTypeName) {
        
        PageReference pageRef;
        String recordTypeId;
        String recordTypeName;
        
        // If the record type name has been passed as a parameter, e.g. when channel partner selected 
        // a record type manually (for when creating a case for self)
        if (theRecordTypeName != null) {
            recordTypeName = theRecordTypeName;
            recordTypeId = recordTypeName == WalmartConstants.OPERATION_CASE_RECORD_TYPE_NAME ? SELLER_COMMUNITY_CASE : SELLER_COMMUNITY_ONBOARDING_CASE;
        }
        else {
            // if the record type is not explicitly stated, we will determine the record type to use based on the logic below.
        
            // this will never fail, because every community user will be associated with
            // an account, hence no need to have a list implementation here
            Account accountDetails = 
                [SELECT Seller_Onboarding_Status__c, Seller_Onboarding_Live_Status__c, Type 
                FROM Account WHERE Id =:accountId limit 1];
            String onboardingStatus = accountDetails.Seller_Onboarding_Status__c;
            String onboardingLiveStatus = accountDetails.Seller_Onboarding_Live_Status__c;
        
            // now based on onboarding status and onboarding live status, make a decision
            // to redirect the user to either onboarding or operation case page layout
            if((WalmartConstants.SELLER_ONBOARDING_LIVE_ON_SITE == onboardingStatus 
                && WalmartConstants.SELLER_ONBOARDING_LIVE_ON_SITE_OPS_READY == onboardingLiveStatus)) { // operations case
                
                recordTypeName = WalmartConstants.OPERATION_CASE_RECORD_TYPE_NAME;
                recordTypeId = SELLER_COMMUNITY_CASE;

            } else { // in all other scenarios - onboarding case
            
                recordTypeName = WalmartConstants.ONBOARDING_CASE_RECORD_TYPE_NAME;
                recordTypeId = SELLER_COMMUNITY_ONBOARDING_CASE;
            }
        }
        
        // create the deflection record
        Id deflectionRecordId =
                CaseCRUDHelper.createCaseDeflectionRecord(
                    recordTypeName, 
                    contactId, accountId);
        return new PageReference(
          '/newCaseCreationForm?deflectionRecordId=' + deflectionRecordId 
          + '&recordTypeId=' + recordTypeId
          + '&recordTypeName=' + recordTypeName
          + '&contactId=' + contactId
          + '&accountId=' + accountId
          + '&isFollowUpCase=' + isFollowUpCase
          + '&parentCaseNumber=' + parentCaseNumber
          + '&isCPCaseForSeller=' + isCPCaseForSeller); 
    }
    
     /**
     * Method which creates the request parameter for the new Supplier case creation based on the
     * user type, account status, etc. to help render the respective case creation form.
     * 
     * @param accountId         the account for which the case is being created
     * @param contactId         the contact on the account
     * @param parentCaseNumber  the parent case number if the flow is from follow up case
     * @param isCPCaseForSeller a parameter to identify if the Channel Partner is creating case for self or seller
     * @param theRecordTypeName the record type can be explicitly stated by the caller. if this is the case, the record type does not need to be computed.
     * 
     * @return the page reference to the new case creation form
     */ 
    public static PageReference createSupplierFormURL(
        Id accountId, Id contactId, Boolean isFollowUpCase, String parentCaseNumber, Boolean isCPCaseForSeller, String theRecordTypeName, string cspSelectionType) {
        
        PageReference pageRef;
        String recordTypeId;
        String recordTypeName;
        
            recordTypeName = theRecordTypeName;
            recordTypeId = SUPPLIER_COMMUNITY_CASE;
        
        // create the deflection record
        Id deflectionRecordId =
                CaseCRUDHelper.createSupplierCaseDeflectionRecord(
                    recordTypeName, 
                    contactId, accountId);
        
        return new PageReference(
          '/newCaseCreationForm?deflectionRecordId=' + deflectionRecordId
          + '&recordTypeId=' + recordTypeId
          + '&recordTypeName=' + recordTypeName
          + '&contactId=' + contactId
          + '&accountId=' + accountId
          + '&isFollowUpCase=' + isFollowUpCase
          + '&parentCaseNumber=' + parentCaseNumber
          + '&isCPCaseForSeller=' + isCPCaseForSeller
          + '&isCSPSelected='+cspSelectionType); 
    }
    
    /**
     * Helper method to create the deflection record during the new case creation flow on
     * the Supplier Community.
     * 
     * @param originalCaseRecordType    the case record type
     * @param contactId                 the contact id/user id creating the case
     * @param accountId                 the account for which the case was being created
     */ 
    public static Id createSupplierCaseDeflectionRecord(String originalCaseRecordType, Id contactId, Id accountId) {
        
        Case_Initiation__c deflection;
        try {
            deflection = 
                new Case_Initiation__c(
                    Account__c = accountId, 
                    Contact__c = contactId, 
                    Deflected__c = true,
                    Case_Type__c = WalmartConstants.SUPPLIER_DEFLECTION
                   );
            
            insert deflection;
        } catch (Exception e) {
            // consume, as it should not restrict case creation flow
            system.debug(LoggingLevel.ERROR, 'Error creation deflection record!' + e.getStackTraceString());
        }
        return (deflection != null) ? deflection.Id : null;
    }           
    
   /* Method to update the checkbox field redirect_email on case based on data in metadata  Case Setting */
   
    public static void Redirect_resolutionlEmail(List<Case> newCaseList,map<id,Case> oldCaseMap){ 
        Set<String> IssueCategory = new Set<String>();
        Set<String> SubCategory = new Set<String>();
        
       for(Case_Setting_Metadata__mdt metadatarecord : [Select Qualified_Issue_Category__c,Qualified_Sub_Category__c from Case_Setting_Metadata__mdt]){      // Retrive the data from custom metadata 
            IssueCategory.add(metadatarecord.Qualified_Issue_Category__c);
            SubCategory.add(metadatarecord.Qualified_Sub_Category__c);
        }
        
        for(Case cases : newCaseList){
            if((oldCaseMap != null && (oldCaseMap.get(cases.id).Issue_Category__c != cases.Issue_Category__c || oldCaseMap.get(cases.id).Sub_Category_1__c != cases.Sub_Category_1__c))||(oldCaseMap == null))
            {
                
                     if(IssueCategory.contains(cases.Issue_Category__c) && SubCategory.contains(cases.Sub_Category_1__c))
                    {
                        cases.Redirect_Email__c= true;
                    }
                    else
                    {
                        cases.Redirect_Email__c= false;
                   }
                }
            }
        }
           
}
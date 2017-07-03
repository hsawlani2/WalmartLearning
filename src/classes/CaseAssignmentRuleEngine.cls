/**
 * This class contains the core logic of fetching the assignment rules
 * as defined in the Case Assignment Rule object to prioritize the tickets
 * through P1 - P4 and create corresponding JIRA Issue.
 * 
 * @author      Cloud Sherpas
 * @createddate 3-Mar-2016
 */ 
public class CaseAssignmentRuleEngine {
    
    /* Queue Ids based on the Queue Names */
    @TestVisible  private static Id ONBOARDING_QUEUE;
    @TestVisible  private static Id L1_SUPPORT_QUEUE;
    @TestVisible  private static Id L2_SUPPORT_QUEUE;
    @TestVisible  private static Id DSV_SUPPLIER_QUEUE;
    /* Record Type */
    @TestVisible  private static Id ONBOARDING_CASE_RECORD_TYPE;
        
    
    /**
     * A private helper method to initialize the Queue Ids, Record Type Ids.
     * The Ids are later used to assign the respective owners based on the case assignment rules.
     */ 
    private static void init() {
        
        // record type id
        ONBOARDING_CASE_RECORD_TYPE = CaseUtility.getRecordTypeId(WalmartConstants.ONBOARDING_CASE_RECORD_TYPE_NAME);
        
        // fetch Queue Ids for assignments
        ONBOARDING_QUEUE = CaseUtility.getQueueId(WalmartConstants.ONBOARDING_QUEUE_NAME);
        L1_SUPPORT_QUEUE = CaseUtility.getQueueId(WalmartConstants.L1_SUPPORT_QUEUE_NAME);
        L2_SUPPORT_QUEUE = CaseUtility.getQueueId(WalmartConstants.L2_SUPPORT_QUEUE_NAME);
        
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
     * @param incomingCase      the Case being created 
     */ 
    public static void runCaseAssignmentRules(Case incomingCase) {
        system.debug('incomingCase :::::'+ incomingCase);
        // initialize required queue ids and record type ids
        init();

        // cannot get accountId directly -- https://help.salesforce.com/HTViewSolution?id=000221321&language=en_US
        String accountId = [SELECT Id, AccountId from Contact where Id = :incomingCase.ContactId limit 1].AccountId;
        
        // now get the account. there will be always one available because we have the id above, 
        // so use directly without using list
        Account acct = [SELECT Tier__c, Integration_Engineer__c, Seller_Onboarding_Status__c, Seller_Liaison__c, Type,Partner_Onboarding_Status__c  
                        from Account where Id = :accountId limit 1];
        
        String accountTier;
        // if a Case is being created by CP, the tier has to be 1 always !!
        if(acct.Type == WalmartConstants.ACCOUNT_TYPE_CHANNEL_PARTNER) {
            accountTier = '1';
        } else {
            accountTier = acct.Tier__c;
        }
        
        Entitlement OnboardingEntitlement;
        for(Entitlement Entitlement1 :[SELECT Id,Name FROM Entitlement WHERE Name = 'Onboarding Team' limit 1]){
        OnboardingEntitlement = Entitlement1;
        }
         
         
        // Onboarding Case: the owner of all onboarding case should be the respective account's integration lead
        if(incomingCase.RecordTypeId == ONBOARDING_CASE_RECORD_TYPE) {
           
             if(OnboardingEntitlement != null){
            incomingCase.EntitlementId = OnboardingEntitlement.Id;
            }
             // if integration lead is not available (just in case)
          if(acct.Type == WalmartConstants.ACCOUNT_TYPE_CHANNEL_PARTNER) {
              if(incomingCase.In_Reference_to_Seller__c != null){
               Account acct1 = [SELECT Tier__c, Integration_Engineer__c,Seller_Onboarding_Status__c ,Seller_Liaison__c, Type from Account where Id = :incomingCase.In_Reference_to_Seller__c limit 1];
                  if(acct1.Integration_Engineer__c != null && 
                     acct1.Seller_Onboarding_Status__c != 'Pre Seller Setup' &&
                     acct1.Seller_Onboarding_Status__c != 'Seller Setup')
                    {
                      incomingCase.OwnerId = acct1.Integration_Engineer__c;
             //  Prasan       incomingCase.Seller_Liaison__c = acct1.Seller_Liaison__c;
             //  Prasan       incomingCase.Send_Email_to_Seller__c = true;
                    }
                  else if(acct1.Seller_Liaison__c != null && 
                          (acct1.Seller_Onboarding_Status__c == 'Pre Seller Setup' ||
                           acct1.Seller_Onboarding_Status__c == 'Seller Setup')){
                      
                      incomingCase.OwnerId = acct1.Seller_Liaison__c;
                  }
                  else{
                      incomingCase.OwnerId = ONBOARDING_QUEUE;
                  }      
              }
              else{
                      if(acct.Integration_Engineer__c != null && 
                       acct.Partner_Onboarding_Status__c == 'Development' ||    
                       acct.Partner_Onboarding_Status__c == 'Pilot' ||   
                       acct.Partner_Onboarding_Status__c =='Live')
                    {
                        incomingCase.OwnerId = acct.Integration_Engineer__c;
               // Prasan        incomingCase.Seller_Liaison__c = acct.Seller_Liaison__c;
               // Prasan        incomingCase.Send_Email_to_Seller__c = true;
                    }
                  /*  else if(acct.Seller_Liaison__c != null && 
                            (acct.Seller_Onboarding_Status__c == 'Pre Seller Setup' ||
                             acct.Seller_Onboarding_Status__c == 'Seller Setup')){
                        
                        incomingCase.OwnerId = acct.Seller_Liaison__c;
                    }*/
                    else{
                        incomingCase.OwnerId = ONBOARDING_QUEUE;
                    }
              }
          }
          else{
              system.debug(incomingCase.RecordTypeId + '4:::::'+ ONBOARDING_CASE_RECORD_TYPE);
            if(acct.Integration_Engineer__c != null && 
               acct.Seller_Onboarding_Status__c != 'Pre Seller Setup' &&
               acct.Seller_Onboarding_Status__c != 'Seller Setup')
            {
                incomingCase.OwnerId = acct.Integration_Engineer__c;
         // Prasan      incomingCase.Seller_Liaison__c = acct.Seller_Liaison__c;
         // Prasan       incomingCase.Send_Email_to_Seller__c = true;
            }
            else if(acct.Seller_Liaison__c != null && 
                    (acct.Seller_Onboarding_Status__c == 'Pre Seller Setup' ||
                     acct.Seller_Onboarding_Status__c == 'Seller Setup')){
                
                incomingCase.OwnerId = acct.Seller_Liaison__c;
            }
            else{
                incomingCase.OwnerId = ONBOARDING_QUEUE;
            }
            
            /*if(acct.Integration_Engineer__c == null) {
                incomingCase.OwnerId = ONBOARDING_QUEUE;
            } else {
                incomingCase.OwnerId = acct.Integration_Engineer__c;
            }*/
          } 
            return;
        }
        
        
            system.debug('..Jira creation.. '+incomingCase);
        // Operations Case: fetch the assignment rule based on the input on the incoming Case
        List<Case_Assignment_Rule__c> ruleEngineRecs = 
            [SELECT JIRA_Priority__c,JIRA_Project__c
             FROM  Case_Assignment_Rule__c
             WHERE Account_Tier__c = :accountTier
             AND Issue_category__c = :incomingCase.Issue_Category__c
             AND Sub_Category_1__c = :incomingCase.Sub_Category_1__c
             AND Sub_Category_2__c = :incomingCase.Sub_Category_2__c
             AND Sub_Category_3__c = :incomingCase.Sub_Category_3__c
             LIMIT 1
            ];
        
        /* 
         * If the above query did not return any results, that would mean
         * there was no EXACT match found based on the inputs. 
         * 
         * Then try again with the Account Tier as null, as there may be a 
         * Rule Entry with no Account Tier mentioned but all other inputs set
         */
        if(ruleEngineRecs.isEmpty()) {
            ruleEngineRecs = 
                [SELECT JIRA_Priority__c,JIRA_Project__c
                 FROM  Case_Assignment_Rule__c
                 WHERE Account_Tier__c = null
                 AND Issue_category__c = :incomingCase.Issue_Category__c
                 AND Sub_Category_1__c = :incomingCase.Sub_Category_1__c
                 AND Sub_Category_2__c = :incomingCase.Sub_Category_2__c
                 AND Sub_Category_3__c = :incomingCase.Sub_Category_3__c
                 LIMIT 1
                ];
        }
        
        /* 
         * In current situation, assignment rules are only used to auto create JIRA issue
         * if there is an assignment rule found:
         * - a JIRA issue is created along with with priority as determined from rule
         * - the case gets assigned to L2
         * 
         * if there is no assignment rule found:
         * - default to L1 queue
         */
        Boolean isL2Case = false;
        Case_Assignment_Rule__c rule;
        if(!ruleEngineRecs.isEmpty()) {
            rule = ruleEngineRecs.get(0);
            incomingCase.OwnerId = L2_SUPPORT_QUEUE;
            incomingCase.Priority = rule.JIRA_Priority__c;
            incomingCase.Jira_Already_Created__c = true;
            
            /* JIRA AUTO CREATION */
            // auto create JIRA Issue. this field is configured in zAgile configuration
            // for auto creation based on scenario
            incomingCase.Auto_Create_JIRA_Issue__c = true;
            
            isL2Case = true;
            
            /* Jira Project field is used to create Jira ticket in respective Jira board */
            incomingCase.JIRA_Project__c = rule.JIRA_Project__c;
            
            system.debug('..Jira creation.. '+incomingCase);
        } 
        
        if(!isL2Case) { // default to L1 Queue
            incomingCase.OwnerId = L1_SUPPORT_QUEUE;
            // do not touch the priority here for failure
        }  
           
    }
    
    
    public static void runSupplierCaseAssignmentRules(Case incomingCase) {
        
        //Assign the Entitlement for the Supplier Team
        Entitlement SupplierEntitlement;
        for(Entitlement Entitlement2 :[SELECT Id,Name FROM Entitlement WHERE Name = 'Supplier Team' limit 1]){
        SupplierEntitlement = Entitlement2;
        }   
        if(SupplierEntitlement != null){
            incomingCase.EntitlementId = SupplierEntitlement.Id;
            }
        
        string profileName = [SELECT Name from Profile where Id =: Userinfo.getProfileId()].Name;
        
        if(CaseUtility.getSupplierProfileforCaseAssignmentRules().contains(profileName)){
        
        // Supplier Case: fetch the assignment rule based on the input on the incoming Case
        List<Case_Assignment_Rule__c> ruleEngineRecs = 
            [SELECT Id,JIRA_Priority__c,JIRA_Project__c, (SELECT Queue_Name__c,DSV_Supplier_Onboarding_Status__c from Case_Assignment_Owners__r)
             FROM  Case_Assignment_Rule__c
             WHERE Issue_category__c = :incomingCase.Issue_Category__c
             AND Sub_Category_1__c = :incomingCase.Sub_Category_1__c
             LIMIT 1
            ];
            
        string queueOnStatus;
        /*
        system.debug(' .. incomingCase.. '+incomingCase.CSP_Selection_Type__c+' contact id.. '+incomingCase.ContactId);
        if(incomingCase.CSP_Selection_Type__c != null){
            queueOnStatus = incomingCase.CSP_Selection_Type__c;
        }else if(incomingCase.CSP_Selection_Type__c == null){
        */
            string accCaseStatus = [SELECT Account.DSV_Supplier_Onboarding_Status__c from Contact where Id =: incomingCase.ContactId].Account.DSV_Supplier_Onboarding_Status__c;
            system.debug('..accstatus. '+accCaseStatus);
            if(accCaseStatus  != null){
                queueOnStatus = 'Operations';
            }else{
                queueOnStatus = 'Onboarding';
            }
       // }
        system.debug('.. queuestatus.. '+queueOnStatus);
        
        Case_Assignment_Rule__c rule;
        if(!ruleEngineRecs.isEmpty()) {
            rule = ruleEngineRecs.get(0);
            
            if(rule.Case_Assignment_Owners__r.size() == 1){
                if(rule.Case_Assignment_Owners__r[0].Queue_Name__c != null){
                    Id caseQueueId = CaseUtility.getQueueId(rule.Case_Assignment_Owners__r[0].Queue_Name__c);
                    incomingCase.OwnerId = caseQueueId;
                }else{
                    Id caseQueueId = CaseUtility.getQueueId(WalmartConstants.SUPPLIER_HELPDESK_QUEUE_NAME );
                    incomingCase.OwnerId = caseQueueId;
                }
            }else if(rule.Case_Assignment_Owners__r.size() == 2){
                Map<String,String> ownerOnStatus = new Map<String,String>();
                for(Case_Assignment_Owner__c ca : rule.Case_Assignment_Owners__r){
                    ownerOnStatus.put(ca.DSV_Supplier_Onboarding_Status__c,ca.Queue_Name__c);
                }
                system.debug('..ownerOnStatus... '+ownerOnStatus+' ..map.. '+ownerOnStatus.get(queueOnStatus));
                Id caseQueueId = CaseUtility.getQueueId(ownerOnStatus.get(queueOnStatus));
                incomingCase.OwnerId = caseQueueId;
            }else{
                Id caseQueueId = CaseUtility.getQueueId(WalmartConstants.SUPPLIER_HELPDESK_QUEUE_NAME );
                incomingCase.OwnerId = caseQueueId;
            }
            
            if(rule.JIRA_Project__c != null){
                incomingCase.Priority = rule.JIRA_Priority__c;
                incomingCase.Auto_Create_JIRA_Issue__c = true;
                incomingCase.JIRA_Project__c = rule.JIRA_Project__c;
            }
            
            /*
            DSV_SUPPLIER_QUEUE = CaseUtility.getQueueId(WalmartConstants.DSV_SUPPLIER_QUEUE_NAME);
            system.debug('..inside.. '+incomingCase.OwnerId+ ' .. dfddd.. '+DSV_SUPPLIER_QUEUE);
            if(incomingCase.OwnerId == DSV_SUPPLIER_QUEUE){
                system.debug('..inside.. ');
                incomingCase.Priority = rule.JIRA_Priority__c;
                incomingCase.Auto_Create_JIRA_Issue__c = true;
                incomingCase.JIRA_Project__c = WalmartConstants.ONEP_SUPPORT_BOARD;
            }
            */
            
        }else{
            Id caseQueueId = CaseUtility.getQueueId(WalmartConstants.SUPPLIER_HELPDESK_QUEUE_NAME );
            incomingCase.OwnerId = caseQueueId;
        }
        } 
    }
}
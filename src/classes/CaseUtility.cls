/**
 * A utility class which contains helper methods to assist different
 * classes utilized during the case CRUD operations.
 * 
 * @author      Cloud Sherpas
 * @createddate 08-Mar-2016
 */ 
public class CaseUtility {

    /**
     * Returns the set of profile names as defined in OPERATION_PROFILE_NAMES__c custom setting
     * 
     * @return set of operation profile names
     */ 
    public static Set<String> getOperationProfileNames() {
        List<OPERATION_PROFILE_NAMES__c> opProfileNames = OPERATION_PROFILE_NAMES__c.getAll().values();
        Set<String> operationProfileNames = new Set<String>();
        
        for(OPERATION_PROFILE_NAMES__c pName : opProfileNames) {
            operationProfileNames.add(pName.Name);
        }
        return operationProfileNames;
    }
    
    
    /**
     * Returns the set of profile names as defined in ONBOARDING_PROFILE_NAMES__c custom setting
     * 
     * @return set of onboarding profile names
     */ 
    public static Set<String> getOnboardingProfileNames() {
        List<ONBOARDING_PROFILE_NAMES__c> onProfileNames = ONBOARDING_PROFILE_NAMES__c.getAll().values();
        Set<String> onboardingProfileNames = new Set<String>();

        for(ONBOARDING_PROFILE_NAMES__c pName : onProfileNames) {
            onboardingProfileNames.add(pName.Name);
        }
        return onboardingProfileNames;
    }
    
    
    /**
     * Returns the set of profile names as defined in SUPPLIER_PROFILE_NAMES__c custom setting
     * 
     * @return set of Supplier profile names
     */ 
    public static Set<String> getSupplierProfileNames() {
        List<SUPPLIER_PROFILE_NAMES__c> suppProfileNames = SUPPLIER_PROFILE_NAMES__c.getAll().values();
        Set<String> supplierProfileNames = new Set<String>();

        for(SUPPLIER_PROFILE_NAMES__c pName : suppProfileNames) {
            supplierProfileNames.add(pName.Name);
        }
        return supplierProfileNames;
    }
    
    
    /**
     * Returns the set of profile names as defined in SOCKM_Record_Type__c custom setting
     * 
     * @return set of Supplier record type names
     */ 
    public static Set<String> getSupplierRecordTypeNames() {
        List<SOCKM_Record_Type__c> suppRecordTypeNames = SOCKM_Record_Type__c.getAll().values();
        Set<String> supplierRecordTypeNames = new Set<String>();

        for(SOCKM_Record_Type__c pName : suppRecordTypeNames) {
            supplierRecordTypeNames.add(pName.Name);
        }
        return supplierRecordTypeNames;
    }
    
    
    /**
     * A helper method to return the record type id based on the record
     * type name
     * 
     * @param recordTypeName    the name of the record type
     * @return the record type id 
     */ 
    public static Id getRecordTypeId(String recordTypeName) {
        return Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
    }


    /**
     * A helper method to return the queue id for a queue name
     * 
     * @param queueName the name of the record type
     * @return the queue id
     */ 
    public static Id getQueueId(String queueName) {
        Id queueId = [SELECT QueueId FROM QueueSobject WHERE Queue.Name = :queueName limit 1].QueueId;
        return queueId;
    }
    
    
     /**
     * Returns the set of profile names as defined in RUN_SUPPLIER_CASE_ASSIGNMENT_RULE__c custom setting
     * 
     * @return set of Supplier profile names
     */ 
    public static Set<String> getSupplierProfileforCaseAssignmentRules() {
        List<RUN_SUPPLIER_CASE_ASSIGNMENT_RULE__c> suppProfileNames = RUN_SUPPLIER_CASE_ASSIGNMENT_RULE__c.getAll().values();
        Set<String> supplierProfileNames = new Set<String>();

        for(RUN_SUPPLIER_CASE_ASSIGNMENT_RULE__c pName : suppProfileNames) {
            supplierProfileNames.add(pName.Name);
        }
        return supplierProfileNames;
    }
}
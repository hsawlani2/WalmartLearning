public class WalmartConstants {

    /* Profile Names Used on CaseComment and Case Triggers*/
    public static String SELLER_COMMUNITY_USER_PROFILE_NAME = 'Seller Community User';
    public static String INTEGRATION_ADMINISTRATOR_PROFILE_NAME = 'Integration Administrator';
    public static String SELLER_COMMUNITY_CHANNEL_PARTNER_PROFILE_NAME = 'Seller Community Channel Partner';
    public static String SUPPLIER_COMMUNITY_USER_PROFILE_NAME= 'Supplier Community User';
    public static String SUPPLIER_COMMUNITY_CHANNEL_PARTNER_PROFILE= 'Supplier Community Channel Partner';
    public static String KNOWLEDGE_SITE_GUEST_PROF = 'Walmart Partner Knowledge Base Profile';
    
    /* Seller Onboarding Status */
    public static String SELLER_ONBOARDING_LIVE_ON_SITE = 'Live on Site';
    public static String SELLER_ONBOARDING_LIVE_ON_SITE_OPS_READY = 'Ops Ready';

    /* Queue Names */
    public static String L1_SUPPORT_QUEUE_NAME = 'Seller Community L1 Support Queue';
    public static String L2_SUPPORT_QUEUE_NAME = 'Seller Community L2 Support Queue';
    public static String ONBOARDING_QUEUE_NAME = 'Seller Community Onboarding Queue';
    public static String SUPPLIER_HELPDESK_QUEUE_NAME = 'Supplier Business Helpdesk';
    public static String DSV_SUPPLIER_QUEUE_NAME = 'Supplier Community DSV Supplier Support';
    
    /* SOCKM Help Desk Role */
    public static String SOCKM_HELPDESK_MANAGER = 'Supplier Help Desk Manager';
    public static String SOCKM_HELPDESK_USER = 'Supplier Help Desk User';
    
    /* Record Type Names */
    public static String OPERATION_CASE_RECORD_TYPE_NAME = 'Seller Community Case';
    public static String ONBOARDING_CASE_RECORD_TYPE_NAME = 'Seller Community Onboarding Case';
    public static String SUPPLIER_CASE_RECORD_TYPE_NAME = 'Supplier Open Case';
    
    /* Knowledge related constants */
    public final static String DEFAULT_LANG = 'en_US';
    public final static String DEFAULT_STATUS = 'online';
    public final static String KAV_EXT = '__kav';
    public final static String KB_TYPE = 'Lifecycle:Suppliers';
    public final static String KB_TYPE_SELLERS = 'Lifecycle:Marketplace';
    
    /* KB Category Visibility*/
    public static String SUPPLIER_CATEGORY= 'Supplier';
    
    /* Deflection Types */
    public static String OPERATION_DEFLECTION = 'Operations Case';
    public static String ONBOARDING_DEFLECTION = 'Onboarding Case';
    public static String SUPPLIER_DEFLECTION = 'Supplier Case';
    
    /* Used in CaseNeedInfoController */
    public static String NEED_INFO_EMAIL_TEMPLATE = 'Notify Seller on Case Status change to Need Info';
    public static String SELLER_COMMUNITY_NAME = 'Walmart Seller Community';
    public static String SUPPLIER_NEED_INFO_EMAIL_TEMPLATE = 'Notify Support on Case Status change to Need Info';
    public static String SUPPLIER_COMMUNITY_NAME = 'Supplier Customer Community';
    
    /* The JIRA Project Name: If the project name changes in future, make sure to update this.
     * This is used in CaseComment triggers to split the extra project names to be displayed to
     * Sellers.
     */
    public static String JIRA_PROJECT_NAME = 'MPSUPPORT';

    /* Used in CaseAssignmentRuleEngine */
    public static String CASE_ASSIGNMENT_TEMPLATE = 'Notify Support User on Case Assignment';
    
    /* Account Type */
    public static String ACCOUNT_TYPE_CHANNEL_PARTNER = 'Channel Partner';
    public static String ACCOUNT_TYPE_SELLER = 'Seller';
    
    /* JIRA Issue Status */
    public static String JIRA_WORK_IN_PROGRESS = 'Work In Progress';
    public static String JIRA_READY_FOR_REVIEW = 'Ready for Review';
    public static String JIRA_READY_TO_START = 'Ready to Start';
    public static String JIRA_NEED_INFO = 'Need Info';
    public static String JIRA_DONE = 'Done';
    public static String JIRA_NEW = 'New';


    /* Case Status */
    public static String SF_WORK_IN_PROGRESS = 'WIP';
    public static String SF_RESOLVED = 'Resolved';
    public static String SF_CLOSED = 'Closed';
    public static String SF_NEED_INFO = 'Need Info';
    public static String SF_NEW = 'New';
    public static String SF_READY_TO_START = 'Ready to Start';
    
    /* Jira Board Name */
    
    public static String ONEP_SUPPORT_BOARD= 'ONEPSUPP';
    public static String MP_SUPPORT_BOARD= 'MPSUPPORT';
}
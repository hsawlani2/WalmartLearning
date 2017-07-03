public class ApplicationFormUtils {
    
    public static String MESSAGE_CODE = 'code';
    public static String FORM_SUCCESS_CODE = 'form_success';
    public static String CONTRACT_SUCCESS_CODE = 'contract_success';
    public static String ERROR_CODE = 'error';
    public static String ERROR_DETAILS = 'errorDetails';
    
    public static String getUserAgent() {
        return ApexPages.currentPage().getHeaders().get('USER-AGENT');
    }
    
    public static Account fetchAccount(String accountId, Boolean isTest) {
        String query = 'SELECT ' +  join(accountFields(),',') + ' FROM Account WHERE Id = \'' + accountId + '\'';
        if (!isTest) {
            query += ' AND On_hold__c = false AND Blocked__c = false';
        }
        List<Account> resultList = Database.query(query);
        if (resultList.size() > 0) {
            return resultList.get(0);
        }
        return null;
    }
    
    // TODO: Enforce stage name here
    public static Opportunity fetchOpportunity(String accountId, String stageName, Boolean requireStage, Boolean blockApplicationComplete, Boolean blockContractComplete) {
        String query = 'SELECT ' + join(opportunityFields(),',') + ' FROM Opportunity WHERE AccountId = \'' + accountId + '\'';
        if (requireStage) {
            query += ' AND StageName = \'' + stageName + '\'';
        }
        if (blockApplicationComplete) {
            query += ' AND Application_Completed__c = false';
        }
        if (blockContractComplete) {
            query += ' AND Contract_Acknowledgement_Acceptance__c = null';
        }
        List<Opportunity> resultList = Database.query(query);

        if (resultList.size() > 0) {
            return resultList.get(0);
        }
        return null;
    }
    
    public static Contact fetchContact(Opportunity theOpportunity) {
        if (theOpportunity != null) {
            String query = 'SELECT ' + join(contactFields(), ',') + ' FROM Contact WHERE Id = \'' + theOpportunity.Primary_Contact__c + '\'';
            List<Contact> resultList = Database.query(query);
            if (resultList.size() > 0) {
                return resultList.get(0);
            }
        }
        return null;
    }
    
    public static Application__c fetchApplicationWithOpportunity(String opportunityId) {
        String query = 'SELECT ' + join(applicationFields(), ',') + ' FROM Application__c WHERE Opportunity__c = \'' + opportunityId + '\'';
        List<Application__c> resultList = Database.query(query);
        if (resultList.size() > 0) {
            return resultList.get(0);
        }
        return null;
    }
    
    private static List<String> accountFields() {
        return new List<String> {
            'Amazon_Seller_Display_Name__c',
            'Amazon_Seller_URL__c',
            'AnnualRevenue',
            'BillingCity',
            'BillingCountry',
            'BillingPostalCode',
            'BillingState',
            'BillingStreet',
            'DBA_Name__c',
            'eBay_Seller_Display_Name__c',
            'eBay_Seller_URL__c',
            'Id',
            'Name',
            'Other_Marketplace__c',
            'Other_Seller_Display_Name__c',
            'Other_Seller_URL__c',
            'Tax_ID__c',
            'Website',
            'Year_Company_Founded__c'
        };
    }
    
    private static List<String> opportunityFields() {
        return new List<String> {
            'AccountId',
            'Amazon_FBA__c',
            'Amount',
            'Drop_Ship__c',
            'Id',
            'Owned_vs_Drop_Ship__c',
            'Primary_Contact__c',
            'Variant_Items__c',
            'StageName'
        };
    }
    
    private static List<String> contactFields() {
        return new List<String> {
            'AccountId',
            'Email',
            'FirstName',
            'Id',
            'LastName',
            'Name',
            'Phone',
            'Title'
        };
    }
    
    private static List<String> applicationFields() {
        return new List<String> {
            'Account__c',
            'Additional_Comments__c',
            'Amazon_Annual_Sales__c',
            'Amazon_Average_Sales_Per_Order__c',
            'Amazon_No_of_Active_SKUs__c',
            'Amazon_No_of_Reviews_12_mos__c',
            'Amazon_No_of_Years__c',
            'Amazon_Perc_Positive_Ratings_12_mos__c',
            'Amazon_Seller_Name__c',
            'Amazon_Store_URL__c',
            'Application_URL__c',
            'No_of_days_you_will_start_integration__c',
            'Business_days_to_pick_pack_ship__c',
            'Categories__c',
            'City_Town__c',
            'Contract_Acknowledged_by_Name__c',
            'Contract_Acknowledged_by_Title__c',
            'Contract_Acknowledgement_Acceptance__c',
            'Country__c',
            'Customer_return_policy__c',
            'DBA_Name__c',
            'Depend_on_3rd_Party_Logistics__c',
            'Do_not_Sell_on_Marketplaces__c',
            'Ebay_Annual_Sales__c',
            'Ebay_Average_Sales_Per_Order__c',
            'Ebay_No_of_Active_SKUs__c',
            'Ebay_No_of_Reviews_12_mos__c',
            'Ebay_No_of_Years__c',
            'Ebay_Perc_Positive_Ratings_12_mos__c',
            'Ebay_Seller_Name__c',
            'Ebay_Store_URL__c',
            'Free_Shipping__c',
            'Fulfillment_Perc_Shipped_1__c',
            'Fulfillment_Perc_Shipped_2__c',
            'Fulfillment_Perc_Shipped_3__c',
            'Fulfillment_Perc_Shipped_4__c',
            'Fulfillment_Perc_Shipped_5__c',
            'Fulfillment_Service_Provider_1__c',
            'Fulfillment_Service_Provider_2__c',
            'Fulfillment_Service_Provider_3__c',
            'Fulfillment_Service_Provider_4__c',
            'Fulfillment_Service_Provider_5__c',
            'How_did_you_hear_about_Marketplace__c',
            'Id',
            'Legal_Address_Line_1__c',
            'Legal_Address_Line_2__c',
            'Legal_Company_Name__c',
            'Marketplace_Other__c',
            'Marketplace_selections__c',
            'Opportunity__c',
            'Other_Annual_Sales__c',
            'Other_Average_Sales_Per_Order__c',
            'Other_Business_Name__c',
            'Other_Marketplace__c',
            'Other_No_of_Active_SKUs__c',
            'Other_No_of_Reviews_12_mos__c',
            'Other_No_of_Years__c',
            'Other_Perc_Positive_Ratings_12_mos__c',
            'Other_Seller_Name__c',
            'Other_Specifics__c',
            'Other_Store_URL__c',
            'Percentage_Drop_Ship__c',
            'Percentage_of_assortment_variant_items__c',
            'Percentage_of_orders_refunded__c',
            'Percentage_of_Total_Orders_Shipped_1__c',
            'Percentage_of_Total_Orders_Shipped_2__c',
            'Percentage_of_Total_Orders_Shipped_3__c',
            'Percentage_of_Total_Orders_Shipped_4__c',
            'Percentage_of_Total_Orders_Shipped_5__c',
            'Percentage_orders_falling_out_window__c',
            'Percentage_Owned__c',
            'Perc_active_listings_win_the_buy_box__c',
            'Perc_assortment_has_Free_Shipping__c',
            'Perc_buy_box_within_first_two_pages__c',
            'Perc_of_assortment_owned_v_drop__c',
            'Postal_Zip_Code__c',
            'Preferred_integration_General__c',
            'Preferred_integration_Specific__c',
            'Preferred_integration__c',
            'Pre_fulfillment_cancellation_rate__c',
            'Primary_Contact_Email__c',
            'Primary_Contact_First_Name__c',
            'Primary_Contact_Last_Name__c',
            'Primary_Contact_Phone_Extension__c',
            'Primary_Contact_Phone__c',
            'Primary_Contact_Title__c',
            'Seller_Name_1__c',
            'Seller_Name_2__c',
            'Seller_Name_3__c',
            'Selling_on_any_other_Marketplace__c',
            'State_of_Incorporation__c',
            'State_Province_Region__c',
            'Tax_ID__c',
            'Third_Party_integration_specifics__c',
            'Top_Category__c',
            'Version_no__c',
            'Website__c',
            'X12_mo_YTD_sales_revenue__c',
            'Year_Company_Founded__c',
            'Do_you_give_us_permission_to_text__c'
        };
    }
    
    private static String join(List<String> strings, String c) {
        if (strings == null || strings.isEmpty()) return null;

        String sep = (isBlank(c) ? ',' : c);
        Integer i, size;
        String s = strings[0];

        size = strings.size();
        for (i = 1; i < size; i++) {
            s += (sep + strings[i]);
        }
        return s;
    }
    
    public static Boolean isBlank(String s) {
        return ( s == null || s == '');
    }

}
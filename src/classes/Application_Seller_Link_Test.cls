/****************************************************************************/
/* Test Class for Application_Seller_Link.                                  */
/* Cloud Sherpas January 2016 - dcheung                                     */
/****************************************************************************/
@isTest
public class Application_Seller_Link_Test {
    
    private static final String DEFAULT_OPP_STAGE = 'Opportunity';
    private static final Integer OPP_CLOSE_DATE_LAPSED_DAYS = 10;
    private static final String AMAZON_PROVIDERS = 'Amazon.com,Amazon,Amazon FBA,FBA';

    private static testMethod void test() {
        
        setUpTestData();
           
        //Insert Account
        Account acctPartner = new Account(Name = 'Walmart Channel Partner ACME', 
                                          BillingCountry = 'United States',
                                          BillingStreet = '915 Broadway',
                                          BillingCity = 'New York',
                                          BillingState = 'New York',
                                          BillingPostalCode = '10010'
                                          ); 
        insert acctPartner;
        

        Account acctSeller = new Account(Name = 'Big Dave Needs to Sell Something', 
                                         BillingCountry = 'United States',
                                         BillingStreet = '915 Broadway',
                                         BillingCity = 'New York',
                                         BillingState = 'New York',
                                         BillingPostalCode = '10010'
                                         ); 
        insert acctSeller;

        // Insert Opportunity
        Opportunity opp = new Opportunity(AccountId=acctSeller.Id, Name=acctSeller.Name, CloseDate = Date.today().addDays(OPP_CLOSE_DATE_LAPSED_DAYS), StageName=DEFAULT_OPP_STAGE);
        insert opp;

        // Insert Application with Account & opportunity
        Application__c app = new Application__c(Account__c=acctSeller.Id, 
                                                Opportunity__c=opp.Id, 
                                                Amazon_Annual_Sales__c=3000000,
                                                Amazon_Average_Sales_Per_Order__c=30,
                                                Amazon_Seller_Name__c='Dave\'s Mega Burger',
                                                DBA_Name__c='Dave\'s Mega ACME',
                                                Legal_Company_Name__c='Dave\'s Mega ACME',
                                                Legal_Address_Line_1__c='915 Broadway',
                                                State_Province_Region__c='New York',
                                                Postal_Zip_Code__c='10010',
                                                Country__c='United States', 
                                                Tax_ID__c='222-222-220',
                                                Other_Seller_Name__c='Other seller name',
                                                Percentage_of_Total_Orders_Shipped_1__c=10,
                                                Primary_Contact_First_Name__c='Correy',
                                                Primary_Contact_Last_Name__c='Walker',
                                                Primary_Contact_Email__c='correy@fitbit.com'
                                               );
        insert app; 

        // Insert Application with no Account & opportunity
        Application__c app2 = new Application__c(Account__c=null, 
                                                 Opportunity__c=null, 
                                                 Amazon_Annual_Sales__c=3000000,
                                                 Amazon_Average_Sales_Per_Order__c=30,
                                                 Amazon_Seller_Name__c='Dave\'s Mega Burger',
                                                 DBA_Name__c='Dave\'s Mega ACME',
                                                 Legal_Company_Name__c='Dave\'s Mega ACME UNITED',
                                                 Legal_Address_Line_1__c='915 Broadway',
                                                 State_Province_Region__c='New York',
                                                 Postal_Zip_Code__c='10010',
                                                 Country__c='United States', 
                                                 Tax_ID__c='222-222-229',
                                                 Percentage_of_Total_Orders_Shipped_1__c=10,
                                                 Primary_Contact_First_Name__c='Correy',
                                                 Primary_Contact_Last_Name__c='Walker',
                                                 Primary_Contact_Email__c='correy@fitbitwalker.com' 
                                               );
        insert app2; 
      
        test.startTest();
        
        Application_Seller_Link.link(app.Id, null);
        Application_Seller_Link.link(app2.Id, acctPartner.Id);
        
        test.stopTest();
        
        Account acct = [SELECT Name, Other_Seller_Display_Name__c, Latest_Application_ID__c FROM Account WHERE Id = :acctSeller.Id];
        //System.assertEquals('Dave\'s Mega ACME', acct.Name); 
        //System.assertEquals('Other seller name', acct.Other_Seller_Display_Name__c);
        //System.assert(acct.Latest_Application_ID__c != null, 'Should not be null');
        
        Account acct2 = [SELECT Latest_Application_ID__c FROM Account WHERE Channel_Partner__c =: acctPartner.Id];
        System.assert(acct2.Latest_Application_ID__c != null, 'Should not be null');

        Application__c app3 = [SELECT Account__r.Name FROM Application__c WHERE Id = :app2.Id];
        System.assertEquals('Dave\'s Mega ACME UNITED', app3.Account__r.Name); 
        
    }
    
    public static testMethod void testLinkWithContact() {
        
        System.debug('beginning test testLinkWithContact');
        
        setUpTestData();
        
        Account acctSeller = new Account(Name = 'Big Dave Needs to Sell Something', 
                                         BillingCountry = 'United States',
                                         BillingStreet = '915 Broadway',
                                         BillingCity = 'New York',
                                         BillingState = 'New York',
                                         BillingPostalCode = '10010'
                                         ); 
        insert acctSeller;
        acctSeller = [SELECT Id, Name FROM Account WHERE Name = 'Big Dave Needs to Sell Something'];
        
        Contact aContact = DataBuilder.createContact(acctSeller.Id);
        insert aContact;
        
        // Insert Opportunity
        Opportunity opp = new Opportunity(AccountId=acctSeller.Id, Name=acctSeller.Name, CloseDate = Date.today().addDays(OPP_CLOSE_DATE_LAPSED_DAYS), StageName=DEFAULT_OPP_STAGE);
        insert opp;
        opp = [SELECT Id FROM Opportunity WHERE Name=:acctSeller.Name];
        
        // Insert Application with Account & opportunity
        Application__c app = new Application__c(Account__c=acctSeller.Id, 
                                                Opportunity__c=opp.Id, 
                                                Amazon_Annual_Sales__c=3000000,
                                                Amazon_Average_Sales_Per_Order__c=30,
                                                Amazon_Seller_Name__c='Dave\'s Mega Burger',
                                                DBA_Name__c='Dave\'s Mega ACME',
                                                Legal_Company_Name__c='Dave\'s Mega ACME',
                                                Legal_Address_Line_1__c='915 Broadway',
                                                State_Province_Region__c='New York',
                                                Postal_Zip_Code__c='10010',
                                                Country__c='United States', 
                                                Tax_ID__c='222-222-220',
                                                Other_Seller_Name__c='Other seller name',
                                                Percentage_of_Total_Orders_Shipped_1__c=10,
                                                Primary_Contact_First_Name__c='Correy',
                                                Primary_Contact_Last_Name__c='Walker',
                                                Primary_Contact_Email__c='correy@fitbitwalker.com'
                                               );
        insert app; 
        
        test.startTest();
        
        Application_Seller_Link.link(app.Id, null);
        
        test.stopTest();
        
        Opportunity fetchedOpp = [SELECT Id, Primary_Contact__c FROM Opportunity WHERE Id = :opp.Id];
        if(fetchedOpp.Primary_Contact__c!= Null){
            Contact fetchedContact = [SELECT FirstName, LastName FROM Contact WHERE Id = :fetchedOpp.Primary_Contact__c];
            System.assertEquals(fetchedContact.FirstName, 'Correy');
            System.assertEquals(fetchedContact.LastName, 'Walker');
        }
    }
    
    public static void setUpTestData() {
        
        Object_Field_Map__c csOFM;
        List<Object_Field_Map__c> ofmList = new List<Object_Field_Map__c>();
        
        //Insert Custom Settings
        Application_Settings__c csAS = new Application_Settings__c(Name = 'Default', Opportunity_Close_Laspe_Days__c=OPP_CLOSE_DATE_LAPSED_DAYS, Opportunity_Stage__c=DEFAULT_OPP_STAGE);
        csAS.Amazon_Fulfillment_Providers__c = AMAZON_PROVIDERS;
        insert csAS;
        
        csOFM = new Object_Field_Map__c(Name='Application_Account_F001',
                                        Source_Object__c='Application__c',
                                        Source_Field__c='DBA_Name__c',
                                        Target_Object__c='Account',
                                        Target_Field__c='DBA_Name__c',
                                        IsActive__c=true
                                        );
        ofmList.add(csOFM);                                                    

        csOFM = new Object_Field_Map__c(Name='Application_Account_F002',
                                        Source_Object__c='Application__c',
                                        Source_Field__c='Legal_Address_Line_1__c',
                                        Target_Object__c='Account',
                                        Target_Field__c='BillingStreet',
                                        IsActive__c=true
                                        );
        ofmList.add(csOFM);                                                    

        csOFM = new Object_Field_Map__c(Name='Application_Account_F003',
                                        Source_Object__c='Application__c',
                                        Source_Field__c='State_Province_Region__c',
                                        Target_Object__c='Account',
                                        Target_Field__c='BillingState',
                                        IsActive__c=true
                                        );
        ofmList.add(csOFM);                                                    

        csOFM = new Object_Field_Map__c(Name='Application_Account_F004',
                                        Source_Object__c='Application__c',
                                        Source_Field__c='Country__c',
                                        Target_Object__c='Account',
                                        Target_Field__c='BillingCountry',
                                        IsActive__c=true
                                        );
        ofmList.add(csOFM);                                                    

        csOFM = new Object_Field_Map__c(Name='Application_Account_F005',
                                        Source_Object__c='Application__c',
                                        Source_Field__c='Legal_Company_Name__c',
                                        Target_Object__c='Account',
                                        Target_Field__c='Name',
                                        IsActive__c=true
                                        );
        ofmList.add(csOFM);                                                    

        csOFM = new Object_Field_Map__c(Name='Application_Account_F006',
                                        Source_Object__c='Application__c',
                                        Source_Field__c='Tax_ID__c',
                                        Target_Object__c='Account',
                                        Target_Field__c='Tax_ID__c',
                                        IsActive__c=true
                                        );
        ofmList.add(csOFM);   
        
        csOFM = new Object_Field_Map__c(Name='Application_Account_F007',
                                        Source_Object__c='Application__c',
                                        Source_Field__c='Other_Seller_Name__c',
                                        Target_Object__c='Account',
                                        Target_Field__c='Other_Seller_Display_Name__c',
                                        IsActive__c=true
                                        );
        ofmList.add(csOFM);   

        csOFM = new Object_Field_Map__c(Name='Application_Opportunity_F001',
                                        Source_Object__c='Application__c',
                                        Source_Field__c='Percentage_of_Total_Orders_Shipped_1__c',
                                        Target_Object__c='Opportunity',
                                        Target_Field__c='Percentage_of_Total_Orders_Shipped_1__c',
                                        IsActive__c=true
                                        );
        ofmList.add(csOFM);                                                    

        csOFM = new Object_Field_Map__c(Name='Application_Contact_F001',
                                        Source_Object__c='Application__c',
                                        Source_Field__c='Primary_Contact_First_Name__c',
                                        Target_Object__c='Contact',
                                        Target_Field__c='FirstName',
                                        IsActive__c=true
                                        );
        ofmList.add(csOFM);                                                    

        csOFM = new Object_Field_Map__c(Name='Application_Contact_F002',
                                        Source_Object__c='Application__c',
                                        Source_Field__c='Primary_Contact_Last_Name__c',
                                        Target_Object__c='Contact',
                                        Target_Field__c='LastName',
                                        IsActive__c=true
                                        );
        ofmList.add(csOFM);                                                    

        csOFM = new Object_Field_Map__c(Name='Application_Contact_F003',
                                        Source_Object__c='Application__c',
                                        Source_Field__c='Primary_Contact_Email__c',
                                        Target_Object__c='Contact',
                                        Target_Field__c='Email',
                                        IsActive__c=true
                                        );
        ofmList.add(csOFM);                                                    

        insert ofmList;
        
    }
}
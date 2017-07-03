public class WM_Onboarding_Seller_contrll {
    public Application__c app{get;set;}
    public String TotalSKU{get;set;} //Projected SKU’s on Walmart
    public String LaunchSKU{get;set;} //Launch SKU’s on Walmart
    public contactwrap con{get;set;}
    public Application__c appl;
    public string datetext{get;set;} //OBD Start Date
    public string errorcolor{get;set;}
    public boolean buttondisable{get;set;}
    public String valerror{get;set;}
    public List<SelectOption> Partners{get;set;}
    public string integerationmethod{get;set;}
    private map<String,string> Accountname;
    
    public WM_Onboarding_Seller_contrll(){
        try{
            app = new application__c();
            valerror = 'none';
            String Appid = ApexPages.currentPage().getParameters().get('Token');
            system.debug('Application id' + Appid);
            Partners = new List<SelectOption>();
            Accountname = new map<String,String>();
            if(Appid != '' && Appid != null)
            {
                appl = [Select id,Account__r.Total_SKUs_in_Pipeline__c,Account__c,Account__r.Integration_Channel__c,Account__r.Integration_Method__c,Account__r.Catalog_Size__c,Account__r.Launch_SKU_s__c from application__c where id =: Appid];
                system.debug('Application' + appl);
                app.Preferred_integration_General__c = appl.Account__r.Integration_Channel__c;
                app.Preferred_integration_Specific__c = appl.Account__r.Integration_Method__c;
                if(app.Preferred_integration_General__c == 'Direct')
                    integerationmethod = appl.Account__r.Integration_Method__c;
                TotalSKU =  String.ValueOf(appl.Account__r.Catalog_Size__c);
                LaunchSKU = (appl.Account__r.Launch_SKU_s__c != null ? String.ValueOf(appl.Account__r.Launch_SKU_s__c.setscale(0)) : ''); //String.ValueOf(appl.Account__r.Launch_SKU_s__c.setscale(0));
                Contact conn = [Select id,firstname,lastname,Title,Email,Phone,AccountId,Contact_Type__c from contact where AccountId = : appl.Account__c and Contact_Type__c includes ('Marketplace Business Manager') Order By createddate Limit 1];
                Partners.add(new SelectOption('','--None--'));
                for(Account acc : [Select id,name from Account where  RecordType.DeveloperName ='Partner_Account' and Partner_Type__c='Full Service Partner' and (Partner_Onboarding_Status__c = 'Live' or Partner_Onboarding_Status__c = 'Pilot') ORDER BY NAME ASC])
                {
                    SelectOption accoption = new SelectOption(acc.name,acc.name);
                    Partners.add(accoption);
                    Accountname.put(acc.name,acc.id);
                }
                con = new contactwrap(conn);
                system.debug('Contact ' + con);
                buttondisable = true;
                errorcolor = '';
            }else{
                errorcolor = 'red';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'URL being used is wrong.'));
                buttondisable = false;
            }
        }catch(Exception e){
            errorcolor = 'red';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Something went wrong. Please contact the administrator'));
        }
    }
    
    public class contactwrap{
        
        public String firstname{get;set;}
        public String lastname{get;set;}
        public String email{get;set;}     
        public String Title{get;set;}
        public String Phone{get;set;}
        public Contact relcon{get;set;}
        
        public contactwrap(Contact c){
            firstname = c.firstname;
            lastname = c.lastname;
            email = c.email;
            Title = c.Title;
            Phone = c.Phone;
            relcon = c;
        }
    }
    
    // method to save all the data 
    public void submit11(){
        try{
            system.debug('Date' + datetext);
            system.debug(ApexPages.currentPage().getParameters().get('Startdate'));
            Date obdstart = Date.valueOf(ApexPages.currentPage().getParameters().get('Startdate'));
            Boolean contactexists = false;
            system.debug('Contact from page ' + con);
            if((Decimal.ValueOf(TotalSKU)*0.1) > Decimal.ValueOf(LaunchSKU)){
                valerror = 'block';
            }
            if(valerror == 'none')
            {
                for(Contact conexts : [Select Contact_Type__c,id,firstname,lastname,Title,Email,Phone,Extension__c,MobilePhone,Permission_to_text_for_notification__c from contact where AccountId = : appl.Account__c]){
                    if(conexts.firstname == con.firstname && conexts.lastname == con.lastname && conexts.email == con.email)
                    {
                        contactexists = true;
                        break;
                    }
                }
                system.debug('Contact ' + contactexists);
                if(!contactexists)
                {
                    //cnn.id = null;
                    system.debug('Contact ' + con);
                    contact cnn = con.relcon;
                    cnn.firstname = con.firstname;
                    cnn.lastname = con.lastname;
                    cnn.email = con.email;
                    cnn.phone = con.phone;
                    cnn.id = null;
                    cnn.Contact_Type__c = 'IT/Technical';
                    cnn.Title = con.title;
                    insert cnn;
                }
                Application__c app = new Application__c(id=appl.id,Primary_Contact_Email__c = con.email,Primary_Contact_First_Name__c = con.firstname,Primary_Contact_Last_Name__c = con.lastname,Primary_Contact_Title__c=con.title);
                Account acc = new Account(id=appl.Account__c,OBD_Start_Date__c = obdstart,Starting_SKU_Count__c = Decimal.ValueOf(TotalSKU),Launch_SKU_s__c = Decimal.ValueOf(LaunchSKU),Integration_Channel__c = ApexPages.currentPage().getParameters().get('Intgrationmethod'),Integration_Method__c = ApexPages.currentPage().getParameters().get('Integrationspecific'));
                if(acc.Integration_Channel__c == 'Partner')
                    acc.IntegrationMethodId__c = Accountname.get(acc.Integration_Method__c);
                system.debug('Account before --- ' + acc);
                update acc;
                system.debug('Account after --- ' + acc);
                app.id = appl.id;
                update app;
                //return null;
                errorcolor = 'green';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Details Submitted. You will get the information shortly. Thanks for contacting.'));
            }
        }catch(Exception e){
            errorcolor = 'red';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Something went wrong.Please contact the admin.'));
        }
        
    }
    public void submitweek(){
        try{
            Date obdstart = Date.valueOf(ApexPages.currentPage().getParameters().get('Startdate'));
            Account acc = new Account(id=appl.Account__c,OBD_Start_Date__c = obdstart);
            update acc;
            errorcolor = 'green';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Details Submitted. You will get the information shortly. Thanks for contacting.'));
        }catch(Exception e){
            errorcolor = 'red';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Something went wrong.Please contact the admin.'));
        }
    }
}
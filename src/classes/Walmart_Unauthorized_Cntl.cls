public Class Walmart_Unauthorized_Cntl{

String chosenCategoryLabel;
    
    public Walmart_Unauthorized_Cntl(){
        Map<String, Cookie> siteCookies = new Map<String, Cookie>();
        siteCookies = ApexPages.currentPage().getCookies();
        Cookie selectedCategoryCookie = siteCookies.get('FullyQualifiedCategory');
        Cookie chosenCategoryCookie = siteCookies.get('ChosenCategory');
        system.debug('DDDDDDDDDDDDD' + chosenCategoryCookie);
        if(chosenCategoryCookie != null){
          chosenCategoryLabel = chosenCategoryCookie.getValue();          
        }
    }
    
    /************** method to set the Organization cache with the IP address of the user and the landing page *******/
    public pagereference redirecttoarticle(){
        
        /************ Preparing the landing URL from the current url *****************/
        String starturl = ApexPages.CurrentPage().getParameters().get('startURL');
        String finalurl = starturl.remove(starturl.split('/')[1]).removestart('/'); 
        system.debug('url where redirect should happen ' + finalurl);
        system.debug('Current page url' + starturl);
        
        /******************* Get the IP for the User ***************/
        string ReturnValue = '';  
        // True-Client-IP has the value when the request is coming via the caching integration.
        ReturnValue = ApexPages.currentPage().getHeaders().get('True-Client-IP');
        // X-Salesforce-SIP has the value when no caching integration or via secure URL.
        if (ReturnValue == '' || ReturnValue == null) {
         ReturnValue = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
        } // get IP address when no caching (sandbox, dev, secure urls)
        if (ReturnValue == '' || ReturnValue == null) {
         ReturnValue = ApexPages.currentPage().getHeaders().get('X-Forwarded-For');
        } // get IP address from standard header if proxy in use
        
        ReturnValue = 'BC' + ReturnValue.replace('.','A');
        
        /*********** putting value in Org Cache ***********/
        Cache.OrgPartition orgPart = Cache.Org.getPartition('local.Default1');
        orgPart.put(ReturnValue, finalurl);
        
        //fetching the login Url from the label
        String LandingURl = '';//Label.Walmart_Login_Link;
        String categoryselected = chosenCategoryLabel + '__c';
        Account_Setting_Metadata__mdt asMdt = [SELECT Matching_Login_URL__c FROM Account_Setting_Metadata__mdt  where Matching_Configured_Data_Category__c = :categoryselected LIMIT 1];
        if(asMdt != null)
        {
            LandingURl = asMdt.Matching_Login_URL__c;
        }
        else
            LandingURl = null;
        
        return new pagereference(LandingURl);
    }
}
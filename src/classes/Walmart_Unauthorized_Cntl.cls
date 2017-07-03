public Class Walmart_Unauthorized_Cntl{
    
    public Walmart_Unauthorized_Cntl(){
    
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
        String LandingURl = Label.Walmart_Login_Link;
        
        return new pagereference(LandingURl);
    }
}
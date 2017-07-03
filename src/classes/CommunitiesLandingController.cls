/**
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 */
public with sharing class CommunitiesLandingController {
    
    // Code we will invoke on page load.
    public PageReference forwardToStartPage() {
        
        /************* retrieving IP Address of the user ***********/
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
        system.debug('User IP Address ' + ReturnValue);
        ReturnValue = 'BC' + ReturnValue.replace('.','A');
        system.debug('Key value ' + ReturnValue);
        
        /******************* Putting user IP address and landing url info in Organization Cache **********/
        Cache.OrgPartition orgPart = Cache.Org.getPartition('local.Default1');
        system.debug('Get value from cache ' + orgPart.getKeys());
        system.debug('value from catche ' + orgPart.get(ReturnValue));
        
        if(orgPart.contains(ReturnValue) && orgPart.get(ReturnValue) != 'null')// checking if the cache has the landing url corresponing to the User IP address
        {
            String redirecttopage = (String)orgPart.get(ReturnValue); // getting teh landing url from cache
            orgPart.put(ReturnValue,'null'); // setting the value for IP address as null so that It should not behave as it is again and again
            return new pagereference(redirecttopage);
        }
        return Network.communitiesLanding(); // if there is no value corresponding to the IP address then land on the community standard landing page.
    }
    
    public CommunitiesLandingController() {}
}
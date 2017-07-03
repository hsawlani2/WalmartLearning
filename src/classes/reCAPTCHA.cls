public class reCAPTCHA {

    /* Configuration */

    // The API endpoint for the reCAPTCHA service
    private static String baseUrl = 'https://www.google.com/recaptcha/api/verify'; 

    // The keys you get by signing up for reCAPTCHA for your domain
    private static String privateKey = '6LcBQRkUAAAAAP-6GWJMHGz3ISStkItNedZJw__b';
    public String publicKey { 
        get { return '6LcBQRkUAAAAAFKlRtvfZoAm3J1DanM42MVJcBPy'; }
    } 

    /* Implementation */
    
    // Simple form fields for the example form
    public String myName { get; set; }
    public String myEmail { get; set; }
    
    // Create properties for the non-VF component input fields generated
    // by the reCAPTCHA JavaScript.
    public String challenge { 
        get {
            return ApexPages.currentPage().getParameters().get('recaptcha_challenge_field');
        }
    }
    public String response  { 
        get {
            return ApexPages.currentPage().getParameters().get('g-recaptcha-response');
        }
    }
    
    // Whether the submission has passed reCAPTCHA validation or not
    public Boolean verified { get; private set; }
    
    public reCAPTCHA() {
        this.verified = false;
    }
    
    public PageReference verify() {
        System.debug('reCAPTCHA verification attempt');
        system.debug('...11. '+ApexPages.currentPage().getParameters().get('g-recaptcha-response'));
        // On first page load, form is empty, so no request to make yet
        if (response == null ) { 
            System.debug('reCAPTCHA verification attempt with empty form');
            return null; 
        }
                    
        HttpResponse r = makeRequest(baseUrl,
            'privatekey=' + privateKey + 
            '&response='  + response
        );
        
        if ( r!= null ) {
            this.verified = (r.getBody().startsWithIgnoreCase('true'));
        }
        
        if(this.verified) {
        System.debug('reCAPTCHA verification attempt');

            // If they pass verification, you might do something interesting here
            // Or simply return a PageReference to the "next" page
            return null;
        }
        else {
            // stay on page to re-try reCAPTCHA
            return null; 
        }
    }

    public PageReference reset() {
        return null; 
    }   

    /* Private helper methods */
    
    private static HttpResponse makeRequest(string url, string body)  {
        HttpResponse response = null;
        HttpRequest req = new HttpRequest();   
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setBody (body);
        try {
            Http http = new Http();
            response = http.send(req);
            System.debug('reCAPTCHA response: ' + response);
            System.debug('reCAPTCHA body: ' + response.getBody());
        } catch(System.Exception e) {
            System.debug('ERROR: ' + e);
        }
        //return response;
        system.debug('response... '+response);
        return null;
    }   
        
    private String remoteHost { 
        get { 
            String ret = '127.0.0.1';
            // also could use x-original-remote-host 
            Map<String, String> hdrs = ApexPages.currentPage().getHeaders();
            if (hdrs.get('x-original-remote-addr')!= null)
                ret =  hdrs.get('x-original-remote-addr');
            else if (hdrs.get('X-Salesforce-SIP')!= null)
                ret =  hdrs.get('X-Salesforce-SIP');
            return ret;
        }
    }
}
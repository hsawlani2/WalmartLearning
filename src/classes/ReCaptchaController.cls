public class ReCaptchaController {
    // Simple form fields for the example form
    public String myfName { get; set; }
    public String mylName { get; set; }

    public String myEmail { get; set; }
    private static String baseUrl = 'https://www.google.com/recaptcha/api/siteverify';
    
    private static String secret = '6LcBQRkUAAAAAP-6GWJMHGz3ISStkItNedZJw__b';
    
    public String sitekey {
        get { return '6LcBQRkUAAAAAFKlRtvfZoAm3J1DanM42MVJcBPy'; }
    }
    public String response  { 
        get { return ApexPages.currentPage().getParameters().get('g-recaptcha-response'); }
    }
    
    // this method is called when the button is clicked
    public PageReference doVerify () {
        String responseBody = makeRequest(baseUrl,
                'secret=' + secret +
                '&response='+ response
        );
        String success = getValueFromJson(responseBody, 'success');
        if(success.equalsIgnoreCase('true')){
            Contact con = new COntact( LastName = mylName, FirstName= myfname, email=myemail);
            try{
                insert con;
                pagereference p = new pagereference('/'+con.id);
                return p;
                }
            Catch(exception e){
                ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error while creating contact');
                ApexPages.addMessage(errorMsg);
                return null;
            }
        }else{
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please verify the captcha');
            ApexPages.addMessage(errorMsg);
            return null;
        }
        
    }
    
    /**
     * Make request to verify captcha
     * @return      response message from google
     */
    private static String makeRequest(string url, string body)  {
        HttpResponse response = null;
        HttpRequest req = new HttpRequest();   
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setBody (body);
        
        try {
            Http http = new Http();
            response = http.send(req);
            return response.getBody();
        } catch(System.Exception e) {
            System.debug('ERROR: ' + e);
        }
        return '{"success":false}';
    }   
    
    /**
     * to get value of the given json string
     * @params      
     *  - strJson       json string given
     *  - field         json key to get the value from
     * @return          string value
     */
    public static string getValueFromJson ( String strJson, String field ){
        JSONParser parser = JSON.createParser(strJson);
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)) {
                if(parser.getText() == field){
                    // Get the value.
                    parser.nextToken();
                    return parser.getText();
                }
            }
        }
        return null;
    }
}
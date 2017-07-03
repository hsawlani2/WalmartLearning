/**
 * @Author: Sairah Hadjinoor
 * @Copyright: Cloud Sherpas.  This code is customized to suite Walmart requirements.
 * @Description: This class is a JSON parser for getuserInfo method(see WalmartOpenId.cls)
 * @History: First created by shadjinoor on 3/17/2016
 *           03/24/2016 - shadjinoor code clean up 
 * */
public with sharing class WalmartUserInfoMap {
    public static String testUserInfoJSON ='{  \"status\": \"OK\",  \"header\": {    \"headerAttributes\": {}  },  \"errors\": [],  \"payload\": {    \"loginId\": \"gsmtesting12345678.90@gmail.com\",    \"email\": \"gsmtesting12345678.90@gmail.com\",    \"firstName\": \"Jagadeesh babu\",    \"lastName\": \"Lokaiah\",    \"uuid\": \"dba9603c-46b2-44bc-8b19-ad8cec6a205a\",    \"orgId\": \"cd8920b2-629f-4e81-a731-8b671711d0ec\",    \"partnerId\": \"721407\",    \"authToken\": null,    \"partnerType\": \"SELLER\"  }}';

    public WalmartUserInfoMap() {
        
    }

    public static void consumeObject(JSONParser parser) {
        Integer depth = 0;
        do {
            JSONToken curr = parser.getCurrentToken();
            if (curr == JSONToken.START_OBJECT || 
                curr == JSONToken.START_ARRAY) {
                depth++;
            } else if (curr == JSONToken.END_OBJECT ||
                curr == JSONToken.END_ARRAY) {
                depth--;
            }
        } while (depth > 0 && parser.nextToken() != null);
    }

    public String status {get;set;} 
    public Payload payload {get;set;} 

    public WalmartUserInfoMap(JSONParser parser) {
        while (parser.nextToken() != JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                System.debug('@@parser.getCurrentToken() '+parser.getCurrentToken());
                String text = parser.getText();
                System.debug('@@text '+text);
                if (parser.nextToken() != JSONToken.VALUE_NULL) {
                    if (text == 'status') {
                        status = parser.getText();
                    } else if (text == 'payload') {
                        payload = new Payload(parser);
                    } else {
                        System.debug(LoggingLevel.WARN, 'Root consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    public class Payload {
        public String loginId {get;set;} 
        public String firstName {get;set;} 
        public String lastName {get;set;} 
        public String uuid {get;set;} 
        public String sellerId {get;set;} 
        public String orgId {get;set;}
        public String partnerId {get;set;} 
        public String partnerType {get;set;} 

        public Payload(){

        }

        public Payload(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'loginId') {
                            loginId = parser.getText();
                        } else if (text == 'firstName') {
                            firstName = parser.getText();
                        } else if (text == 'lastName') {
                            lastName = parser.getText(); 
                        } else if (text == 'uuid') {
                            uuid = parser.getText();
                        } else if (text == 'orgId') {
                            orgId = parser.getText();
                        } else if (text == 'partnerId') {
                            partnerId = parser.getText();
                        } else if (text == 'partnerType') {
                            partnerType = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Payload consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    
    public static WalmartUserInfoMap parse(String json) {
        return new WalmartUserInfoMap(System.JSON.createParser(json));
    }
}
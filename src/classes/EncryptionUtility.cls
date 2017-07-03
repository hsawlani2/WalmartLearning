/**
 * This class provides encryption and decryption methods to be used for passing parameters
 * between the community and the public knowledge base
 * 
 * @author          Cloud Sherpas
 * @datecreated     3/16/2016
 */
public class EncryptionUtility {
    
    // Will the key of community and public knowledge base be the same? Or do we need to store it as some kind of record in SFDC?
    private static Blob AES_KEY = Blob.valueOf('380db410e8b11fa9');
    private static final Long FOUR_HOURS = 1000 * 60 * (Integer)PKB_TOKEN_COOKIE_TIMEOUT_HOURS__c.getInstance('Default').TIMEOUT_HOURS__c; // 4 hours in milliseconds 
    
    /**
     * Used by the Community to generate an encrypted key
     * @return the encrypted current time (in millis)
     */
    public static String createEncryptedString(Boolean urlEncode) {
        String timeNowString = String.valueOf(DateTime.now().getTime());
        System.debug('<<< on encryption: ' + timeNowString);
        return encryptString(timeNowString, urlEncode);
    }
    
    public static String createEncryptedString() {
        return createEncryptedString(true);
    }
    
    /**
     * Used by the PKB to check if the passed encrypted key is valid and has not expired yet. 
     * The token is expired if more than four hours have passed.
     * @return true if it matches, false otherwise
     */
    public static Boolean isAccessAllowed(String encryptedKey) {
        String decrypted = decryptString(encryptedKey);
        Boolean isAllowed = false;
        if (String.isNotBlank(decrypted)) {
            // assume that this is a datetime string
            System.debug('<<< decrypted : ' + decrypted);
            try {
                DateTime timeStamp = DateTime.newInstance(Long.valueOf(decrypted));    
                Long timeNowMillis = DateTime.now().getTime();
                if (timeNowMillis - timeStamp.getTime() < FOUR_HOURS) {
                    System.debug('<<< timestamp is less than four hours. allowing access');
                    isAllowed = true;
                }
                else {
                    System.debug('<<< timestamp is more than four hours ago. restricting access ');
                }
            }
            catch (Exception e) {
                System.debug('<<< error occured while parsing ' + e);
            }
        }
        return isAllowed;
    }
    
    
    /**
     * Private helper methods
     */
    
    private static String encryptString(String toEncrypt, Boolean urlEncode) {
        Blob data = Blob.valueOf(toEncrypt);
        Blob encrypted = Crypto.encryptWithManagedIV('AES128', AES_KEY, data);
        String base64Encoded = EncodingUtil.base64Encode(encrypted);
        System.debug('<<< base64 encoded: ' + base64Encoded + ' length: ' + base64Encoded.length());
        if (urlEncode) {
            String urlEncoded = EncodingUtil.urlEncode(base64Encoded, 'UTF-8');
            System.debug('<<< url-encoded: ' + urlEncoded);
            return urlEncoded;    
        }
        return base64Encoded;
    }
    
    // We don't have to decode this 
    private static String decryptString(String toDecrypt) {
        System.debug('<<< incoming string: ' + toDecrypt);
        String decryptedString = '';
        try {
            Blob nonHex = EncodingUtil.base64Decode(toDecrypt);
            Blob decrypted = Crypto.decryptWithManagedIV('AES128', AES_KEY, nonHex);
            decryptedString = decrypted.toString();
        }
        catch (Exception e) {
            System.debug('<<< Error decrypting: ' + e);
        }
        return decryptedString;
    }
    
    

}
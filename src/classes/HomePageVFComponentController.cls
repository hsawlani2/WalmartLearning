/**
 * A custom controller for the VF pages used as custom
 * home page component.
 * 
 * @author      Cloud Sherpas
 * @createddate 16-Mar-2016
 */ 
public class HomePageVFComponentController {
    
    private String authToken;
    
    public HomePageVFComponentController() {
        authToken = EncryptionUtility.createEncryptedString();
    }
    /**
     * Used by the VF page to know the base URL of the KB along with the auth token for banner article access.
     * 
     * @return base url of the KB
     */
    public String kbURL {
        get {
            String profileName = [Select Id, Name from Profile where Id = :UserInfo.getProfileId()].Name;
            Cookie SellerUsernm = new Cookie('SellerUser','SessionId','/',-1, false);
            ApexPages.currentPage().setCookies(new Cookie[]{SellerUsernm});
            system.debug('available cookies' + ApexPages.currentPage().getCookies());
            if(WalmartConstants.SUPPLIER_COMMUNITY_USER_PROFILE_NAME == profileName){
                return KNOWLEDGEBASE_URL__c.getInstance('Default').KB_URL__c + '?token=' + authToken + '&c=Lifecycle:Suppliers';
            }else{
                //return KNOWLEDGEBASE_URL__c.getInstance('Default').KB_URL__c + '?token=' + authToken + '&c=Lifecycle:Marketplace';
                return 'cases/apex/walmart_pkb_Home?c=Lifecycle:Marketplace';
            }
        }
    }

}
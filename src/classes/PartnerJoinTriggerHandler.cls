/**
 * Handler for the PartnerJoinTrigger, which mainly updates the read access of CCP users to seller accounts.
 * CCP users are Channel partners, and they have a many-to-many relationship with seller accounts,
 * hence the need for the PartnerJoin junction object.
 * 
 * @see PartnerJoinTriggerHandler
 * @author Cloud Sherpas
 * @createddate 31-03-2016
 */
public class PartnerJoinTriggerHandler {
    
    List<UserSeller> userSellerList;
    Set<Id> channelPartnerIDs;
    Set<Id> sellerIDs;
    
    /** 
     * Grant read access of seller account records to Channel partner CCP users 
     * 
     * @param insertedRecords new junction object records that were inserted
     */
    public void grantReadAccess(List<Partner_Join__c> objectList) {
        
        populateUserSellerList(objectList);
        
        // iterate through the userSellerList to create read access sharing rules
        List<AccountShare> readAccessList = new List<AccountShare>();
            // avoid inserting sharing rules that are already present in the database
            // 7. Inner loop to allow us to find equivalent User IDs
        for (UserSeller aMapping : userSellerList) {
            for (Id aUserId : aMapping.userIdList) {
                AccountShare sharingRule = new AccountShare();
                sharingRule.AccountId = aMapping.sellerId;
                sharingRule.UserOrGroupId = aUserId;
                sharingRule.RowCause = 'Manual';
                sharingRule.AccountAccessLevel = 'Read';
                sharingRule.OpportunityAccessLevel = 'Read';
                readAccessList.add(sharingRule);
            }
        }
        
        // Insert the sharing rules.. if we managed to collect any
        if (!readAccessList.isEmpty()) {
            try {
                insert readAccessList;    
            }
            catch (Exception e) {
                System.debug('Error setting permissions : ' + e.getMessage());
            }
        }
        
    }
    
    /** 
     * Revoke read access of seller account records from Channel partner CCP users
     * 
     * @param deletedRecords junction object records that were deleted
     */
    public void revokeReadAccess(List<Partner_Join__c> objectList) {
        
        populateUserSellerList(objectList);
        
        // 5. Have a list of sharing rules to delete
        List<AccountShare> rulesToDelete = new List<AccountShare>();
        // 6. Query existing sharing rules that matches the seller Ids what we found and iterate through them
        for (AccountShare sharingRule : [SELECT AccountId, UserOrGroupId FROM AccountShare WHERE AccountId IN :sellerIds]) {
            
            // 7. Inner loop to allow us to find equivalent User IDs
            for (UserSeller aMapping : userSellerList) {
                for (Id aUserId : aMapping.userIdList) {
                    if (aUserId == sharingRule.UserOrGroupId && aMapping.sellerId == sharingRule.AccountId) {
                        rulesToDelete.add(sharingRule);
                    }
                }
            }
        }
        // 7. Delete the sharing rules we found
        if (!rulesToDelete.isEmpty()) {
            try {
                delete rulesToDelete;
            }
            catch (Exception e) {
                System.debug('Error revoking permissions: ' + e.getMessage());
            }
        }
    }
    
    private void populateUserSellerList(List<Partner_Join__c> objectList) {
        
        // (re)initialize the collections that we'll use
        userSellerList = new List<UserSeller>();
        channelPartnerIDs = new Set<Id>();
        sellerIDs = new Set<Id>();
        
        for (Partner_Join__c junctionRecord : objectList) {
            if (junctionRecord.Channel_Partner__c != null && junctionRecord.Seller__c != null) {
                
                // create the wrapper object and set the initial attributes; the User Id will be set in the next block
                UserSeller aMapping = new UserSeller();
                aMapping.channelPartnerId = junctionRecord.Channel_Partner__c;
                aMapping.sellerId = junctionRecord.Seller__c;
                userSellerList.add(aMapping);
                
                // also add the account ID to the list                        
                channelPartnerIDs.add(junctionRecord.Channel_Partner__c);    
                sellerIds.add(junctionRecord.Seller__c);
            }
        }
        
        // 3. Invoke the SOQL query to fetch the Users that are related
        for (User aUser : [SELECT Id, AccountId FROM User WHERE AccountId IN :channelPartnerIDs]) {
            
            // 4. lets have an inner loop to look for the channel partner Ids that we looked for
            // if we find an object matching the channel partner ID, we assign the User ID: this is the final info that we need
            for (UserSeller aMapping : userSellerList) {
                if (aMapping.channelPartnerId == aUser.AccountId) {
                    List<Id> aUserList = aMapping.userIdList;
                    if (aUserList == null) {
                        aUserList = new List<Id>();
                    }
                    aUserList.add(aUser.Id);
                    aMapping.userIdList = aUserList;
                }
            }
        }
        
    }
    
    
    /**
     * Inner class that associates a User ID with a Seller ID (Account)
     */
    private class UserSeller {
        Id channelPartnerId { get; set; }
        Id sellerId { get; set; }
        List<Id> userIdList { get; set; }
        
        UserSeller() {
            userIdList = new List<Id>();
        }
    }

}
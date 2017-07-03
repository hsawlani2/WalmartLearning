/**
 * Trigger handler on the User sObject.
 * 
 * @see UserTrigger
 * @author Accenture
 */
public class UserTriggerHandler {
    
    // CRITICAL: @future fixes 'DML operation on setup object is not permitted after you have updated a non-setup object' errors
    // Source: https://developer.salesforce.com/forums/?id=906F00000008wAZIAY
    @future
    public static void grantReadAccessToPartnerJoinRecords(List<Id> userIds) {
        
        System.debug('<<< Trigger performed on ' + userIds.size() + ' records');
        
        List<User> fetchedUsers = [SELECT Id, AccountId, ProfileId FROM User WHERE Id IN :userIds];
        
        // Addtional logic: we prematurely end the method when no CCP users are set up
        Id channelProfileId = [SELECT Id FROM Profile WHERE Name = :WalmartConstants.SELLER_COMMUNITY_CHANNEL_PARTNER_PROFILE_NAME].Id;
        
        // Identify first if the user is a channel partner, by retrieving its account ID.
        // We can't determine if the account ID is a channel partner here yet, hence the list is raw
        Map<Id, List<Id>> accountUserListMapRaw = new Map<Id, List<Id>>();
        for (User aUser : fetchedUsers) {
            if (aUser.AccountId != null && aUser.profileId == channelProfileId) {
                List<Id> acctUserList = accountUserListMapRaw.get(aUser.AccountId);
                // if non has been created yet, create it
                if (acctUserList == null) {
                    acctUserList = new List<Id>();
                }
                acctUserList.add(aUser.Id);
                accountUserListMapRaw.put(aUser.AccountId, acctUserList);
            }
        }
        
        // Determine which accounts are channel partners, put them in a new map, now filtered
       /* Map<Id, List<Id>> accountUserMapFiltered = new Map<Id, List<Id>>();
        String mprecordType='MP_Account';
        for (Account acctRecord : [SELECT Id, Type FROM Account WHERE Id IN :accountUserListMapRaw.keySet()AND RecordType.DeveloperName=: mprecordType]) {
            if (acctRecord.Type == WalmartConstants.ACCOUNT_TYPE_CHANNEL_PARTNER) {
                accountUserMapFiltered.put(acctRecord.Id, accountUserListMapRaw.get(acctRecord.Id));
            }
        }*/
        
        Map<Id, List<Id>> accountUserMapFiltered = new Map<Id, List<Id>>();
        String mprecordType='MP_Account';
        String channelpartner='Partner_Account';
        for (Account acctRecord : [SELECT Id, Type FROM Account WHERE Id IN :accountUserListMapRaw.keySet()AND (RecordType.DeveloperName=: mprecordType OR RecordType.DeveloperName=: channelpartner)  ]) {
            if (acctRecord.Type == WalmartConstants.ACCOUNT_TYPE_CHANNEL_PARTNER) {
                accountUserMapFiltered.put(acctRecord.Id, accountUserListMapRaw.get(acctRecord.Id));
            }
        }
        
        // Count users to add (just for the debug message below)
        Integer usersToAdd = 0;
        for (List<Id> aUserList : accountUserMapFiltered.values()) {
            for (Id anId : aUserList) {
                usersToAdd++;
            }
        }
        
        System.debug('<<< ' + usersToAdd + ' of these Users are channel partners');
        
        // Query all partner join records that are associated with these channel partner accounts
        List<AccountShare> readAccessList = new List<AccountShare>();
        for (Partner_Join__c aJunctionRecord : [SELECT Id, Seller__c, Channel_Partner__c FROM Partner_Join__c WHERE Channel_Partner__c IN :accountUserMapFiltered.keySet()]) {
            
            for (Id aUserId : accountUserMapFiltered.get(aJunctionRecord.Channel_Partner__c)) {
                AccountShare sharingRule = new AccountShare();
                sharingRule.AccountId = aJunctionRecord.Seller__c;
                sharingRule.UserOrGroupId = aUserId;
                sharingRule.RowCause = 'Manual';
                sharingRule.AccountAccessLevel = 'Read';
                sharingRule.OpportunityAccessLevel = 'Read';
                readAccessList.add(sharingRule);    
            }
        }
        
        System.debug('<<< UserTrigger: Granting read access to ' + readAccessList.size() + ' records');
        
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

}
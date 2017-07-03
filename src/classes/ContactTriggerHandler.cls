public class ContactTriggerHandler {
    
    public void afterInsert(List<Contact> theContactList) {
        populateAccountPrimaryContact(theContactList);
    }
    
    public void populateAccountPrimaryContact(List<Contact> conList){
        List<Account> accList = new List<Account>();
        Map<Id, Id> accMap = new Map<Id, Id>();
        
        for(Contact con : conList){
            if(!accMap.containsKey(con.AccountId)){
                accMap.put(con.AccountId, con.Id);
            }
        }
        
        accList = [Select Id, Primary_Contact__c from Account where Id in :accMap.keySet()];
        
        if(!accList.isEmpty()){
            for(Account acc : accList){
                if(String.isEmpty(acc.Primary_Contact__c)){
                    acc.Primary_Contact__c = accMap.get(acc.Id);
                }
            }
            
            update accList;
        }
    }

}
/*************************************************************************************************************************************************************
File Name : WalOpportunityTriggerHandler
Purpose   : Automate the inventory status records based on buyer and account id.
Version   : Draft

************************************************************************************************************************************************************/
public class WalOpportunityTriggerHandler{
    
    public static void createInventoryStaus(list<Opportunity> opportunityList,Map<Id,Opportunity> oldOpptyMap,boolean insertFlag,boolean updateFlag){
        
        list<Id> oppIdList = new List<Id>();
        //Stores all the account ids related to opportunity
        list<Id> oppAccIds=new list<Id>();
        string OPTY1PRECTYPE='1P Opportunity';
        //map to store the Account RHID list based on buyer and account id
        map<string,List<Account_RHID__c>> buyerAccountRHIDMap=new map<string,List<Account_RHID__c>>();
        Id ONEPRECTYPEID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPTY1PRECTYPE).getRecordTypeId();
        for(Opportunity eachOpp: opportunityList){
           oppIdList.add(eachOpp.Id);
           if(ONEPRECTYPEID.equals(eachOpp.RecordTypeId)){
               if(insertFlag && eachOpp.Buyer2__c!=null){
                   buyerAccountRHIDMap.put(eachOpp.AccountId+''+eachOpp.Buyer2__c,new List<Account_RHID__c>());
                   oppAccIds.add(eachOpp.AccountId);
               }
               if(updateFlag && eachOpp.Buyer2__c!=null && eachOpp.Buyer2__c!=oldOpptyMap.get(eachOpp.id).Buyer2__c){
                   buyerAccountRHIDMap.put(eachOpp.AccountId+''+eachOpp.Buyer2__c,new List<Account_RHID__c>());
                   oppAccIds.add(eachOpp.AccountId);               
               }
           } 
        }
        
        //Searching Account RHID records based on buyer and account id
        for(Account_RHID__c eachAccountRHID : [SELECT Id,Account__c,RHID_Name__r.Buyer2__c FROM Account_RHID__c  WHERE Account__c IN: oppAccIds]){
            if(buyerAccountRHIDMap.get(eachAccountRHID.Account__c+''+eachAccountRHID.RHID_Name__r.Buyer2__c)!=null){
                buyerAccountRHIDMap.get(eachAccountRHID.Account__c+''+eachAccountRHID.RHID_Name__r.Buyer2__c).add(eachAccountRHID);
            }
            
        }
        
        Map<Id,Set<Id>> oppItemMap = new Map<Id,Set<Id>>();
        //system.debug('..map.. '+);
        List<Opportunity> oppList = [Select Id, (Select Id,Account_RHID__c from Inventory_Status__r) from Opportunity where Id IN : oppIdList];
        For(Opportunity opp : oppList){
            if(opp.Inventory_Status__r.size() > 0)
            {
                oppItemMap.put(opp.Id,new Set<Id>());
                for(Item_Status__c itm : opp.Inventory_Status__r){
                    oppItemMap.get(opp.Id).add(itm.Account_RHID__c);
                }
            }
            
        }
        
        //Stores inventory status records
        list<Item_Status__c> itemStatuslist =new list<Item_Status__c>();
        for(Opportunity eachOpp: opportunityList){
            if(buyerAccountRHIDMap.get(eachOpp.AccountId+''+eachOpp.Buyer2__c)!=null){
                for(Account_RHID__c eachAccountRHID : buyerAccountRHIDMap.get(eachOpp.AccountId+''+eachOpp.Buyer2__c) ){
                    system.debug('..111. '+eachAccountRHID.Id+'.. 222. '+oppItemMap.get(eachOpp.Id));
                    
                    if(oppItemMap.get(eachOpp.Id) == null){
                        Item_Status__c eachItem=new Item_Status__c();
                    eachItem.Account_RHID__c=eachAccountRHID.Id;
                    eachItem.Opportunity__c=eachOpp.Id;
                   
                   itemStatuslist.add(eachItem);
                    }else{
                    if(!oppItemMap.get(eachOpp.Id).contains(eachAccountRHID.Id)){
                        Item_Status__c eachItem=new Item_Status__c();
                        eachItem.Account_RHID__c=eachAccountRHID.Id;
                        eachItem.Opportunity__c=eachOpp.Id;
                   
                        itemStatuslist.add(eachItem);
                   
                    }
                  }
                }
            }
        }
        //inserting inventory status records
        if(itemStatuslist!=null && !itemStatuslist.isEmpty()){
            Database.SaveResult[] itemStatuslistResult = Database.insert(itemStatuslist, false);
            for (Database.SaveResult sr : itemStatuslistResult ) {
                if (sr.isSuccess()) {
                    system.debug('Successfully inserted inventory status record with Id=========>' + sr.getId());
                }
                else {
                    for(Database.Error err : sr.getErrors()){
                        System.debug('Following error has occurred while inserting inventory status record');
                        System.debug('Error Message=====>'+err.getMessage());
                    }
                }
            }
        }
    }
}
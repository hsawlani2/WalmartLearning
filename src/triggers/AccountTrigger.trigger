trigger AccountTrigger on Account (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    AccountTriggerHandler handler = new AccountTriggerHandler();
    
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            handler.beforeInsert(trigger.new);
        }
        if(Trigger.isUpdate){
            List<Account> sellerAccounts = new List<Account>();
            List<Account> partnerAccounts = new List<Account>();
            for(Account acct : trigger.new){
                if(acct.RecordTypeID == '012610000002gtz'){
                    sellerAccounts.add(acct);
                }
                if(acct.RecordTypeID == '012610000002hXk'){
                    partnerAccounts.add(acct);
                }
            }
            if(sellerAccounts.size() > 0){
                handler.beforeUpdate(sellerAccounts,trigger.oldMap);
            }
            if(partnerAccounts.size() > 0){
                handler.beforeUpdatePartners(partnerAccounts, trigger.newMap);
            }
        }
    }
    
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            handler.updateContactType(trigger.new, trigger.oldMap);
        }
        if(Trigger.isUpdate){
             handler.afterUpdate(trigger.newMap,trigger.oldMap);
             handler.updateContactType(trigger.new, trigger.oldMap);
        }
    }

}
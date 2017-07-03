trigger OpportunityTrigger on Opportunity (before insert, before update,  after insert, after update) {
    
    OpportunityTriggerHandler handler = new OpportunityTriggerHandler();
   
    SupplyChainSetupClass supplyObj = new SupplyChainSetupClass();
    
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            handler.afterInsert(trigger.new);
        }
        if(Trigger.isUpdate){
               //logic moved to account after update trigger
           // handler.afterUpdate(trigger.newMap,trigger.oldMap);
           handler.afterUpdate(trigger.new,trigger.oldMap);
           
        }
    }
    //Ashok
   if(trigger.isBefore){
        //if(trigger.isInsert){
        //    handler.beforeInsert(trigger.new);
        //}
        if(trigger.isUpdate ||trigger.isInsert){
            supplyObj.Supplychainupdate(Trigger.new);
            for(Opportunity opp : Trigger.new){
                if(opp.Active_DSV_Contracts__c != null){
                    opp.Active_DSV_Contracts_new__c  = opp.Active_DSV_Contracts__c;
                }
                if(opp.Active_OWNED_Contracts__c != null){
                    opp.Active_OWNED_Contracts_new__c = opp.Active_OWNED_Contracts__c;
                }
            }
        }
        
         if(trigger.isUpdate){
            handler.beforeUpdate(trigger.new,trigger.oldMap);
        }
    }
    //Chinmaya
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        WalOpportunityTriggerHandler.createInventoryStaus(trigger.new,trigger.oldMap,Trigger.isInsert,Trigger.isUpdate);    
    }

}
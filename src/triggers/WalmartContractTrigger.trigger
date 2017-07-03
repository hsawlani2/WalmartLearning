trigger WalmartContractTrigger on Contract__c (After Insert) {
    if(Trigger.isAfter && Trigger.isInsert){
        WalmartContractHandler.updateOpportunity(Trigger.New);    
    }
}
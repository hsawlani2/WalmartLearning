trigger ContactTrigger on Contact (before insert, before update, before delete, after insert, after update, after delete) {
    ContactTriggerHandler conTrig = new ContactTriggerHandler();
    
    if(trigger.isInsert){
        if(trigger.isBefore){
            
        }
        if(trigger.isAfter){
            conTrig.afterInsert(trigger.new);
        }
    }
    if(trigger.isUpdate){
        if(trigger.isBefore){
            
        }
        if(trigger.isAfter){
            
        }
    }
}
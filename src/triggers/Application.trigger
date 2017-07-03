trigger Application on Application__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    if(trigger.isBefore){
        System.debug('@Developer -->trigger.isBefore:' );
        if(trigger.isInsert){
            System.debug('@Developer -->trigger.isInsert:' );
        }         
        if(trigger.isUpdate){
            System.debug('@Developer -->trigger.isUpdate:' );
             ApplicationHandler.beforeUpdate(trigger.new,trigger.oldMap);
        }         
        if(trigger.isDelete){
            System.debug('@Developer -->trigger.isDelete:' );
        }
    }
    else if(trigger.isAfter){
        System.debug('@Developer -->trigger.isAfter:' );
        if(trigger.isInsert){
         //   System.debug('@Developer -->trigger.isInsert:' );
         //   ApplicationHandler.afterInsert(trigger.new);
        }         
        if(trigger.isUpdate){
           ApplicationHandler.AfterUpdate(trigger.new,trigger.oldMap);
        }         
        if(trigger.isDelete){
            System.debug('@Developer -->trigger.isDelete:' );
        }         
        if(trigger.isUnDelete){
            System.debug('@Developer -->trigger.isUnDelete:' );
        }
    }
}
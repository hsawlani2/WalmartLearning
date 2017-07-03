trigger TestTrigger on Account (before insert,before update) {

    for(account a:trigger.new){
        system.debug('Ankit new'+trigger.new);
        system.debug('Ankit old'+trigger.old);
    }
}
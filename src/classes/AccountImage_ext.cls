public class AccountImage_ext {
    public application__c App{get;set;}
    
    public AccountImage_ext (){
    App = [Select id,Preferred_integration_General__c,Logo__c from application__c where id = 'a065B000002Nilj'];
    }
}
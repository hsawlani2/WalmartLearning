@isTest
private class ContactTriggerHandler_Test {
    @testSetup
    public static void setup(){
        Account acc = new Account();
        Contact con = new Contact();
        
        acc.Name = 'Comfort Service Industry';
        insert acc;
        
        con.FirstName = 'Toto';
        con.LastName = 'McArthur';
        con.AccountId = acc.Id;
        insert con;
    }
    
	private static testMethod void test() {
        List<Contact> conList = [select Id from Contact where LastName = 'McArthur'];
	}

}
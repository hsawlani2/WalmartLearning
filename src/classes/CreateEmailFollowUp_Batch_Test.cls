@isTest
private class CreateEmailFollowUp_Batch_Test {

	private static testMethod void test() {
	    
	    Integer numTasks = 17;
	    
	    String userId = createUser();
	    createTasks(createAccounts(userId, numTasks));
	    
	    Test.startTest();
	    CreateEmailFollowUp_Batch aJob = new CreateEmailFollowUp_Batch();
	    aJob.setCustomReference(DateTime.now().addDays(7)); // set the batch reference date to run 7 days from now
	    Database.executeBatch(aJob);
	    Test.stopTest();
	    
	    Integer fetchedFollowups = [SELECT count() FROM Task WHERE Subject=:CreateEmailFollowUp_Batch.FOLLOW_UP_SUBJECT];
	    System.assert(fetchedFollowups == numTasks, 'Follow up tasks created should be equal expected: ' + numTasks + ' actual: ' + fetchedFollowups);
	}
	
	private static String createUser() {
	    Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduse1r@testorg.com');
	    insert u;
	    
	    User fetchedU = [Select Id FROM User WHERE Email='standarduser1@testorg.com'];
	    return fetchedU.Id;
	}
	
	private static List<Account> createAccounts(String anOwnerId, Integer numAccounts) {
	    List<Account> testAccounts = new List<Account>();
	    for (Integer i = 0; i < numAccounts; i++) {
	        String accountName = 'TestAccount'+i;
	        testAccounts.add(new Account(Name=accountName, OwnerId=anOwnerId));
	    }
	    if (!testAccounts.isEmpty()) {
	        insert testAccounts;
	    }
	    List<Account> fetchedAccounts = [SELECT Id FROM Account WHERE OwnerId=:anOwnerId];
	    return fetchedAccounts;
	}
	
	private static List<Task> createTasks(List<Account> accountList) {
	    List<Task> taskList = new List<Task>();
	    for (Account anAccount : accountList) {
	        taskList.add(new Task(
	            Subject=CreateEmailFollowUp_Batch.TASK_SUBJECT, 
	            Status=CreateEmailFollowUp_Batch.TASK_STATUS, 
	            WhatId=anAccount.Id
	            ));
	    }
	    if (!taskList.isEmpty()) {
	        insert taskList;
	    }
	    List<Task> fetchedTasks = [SELECT Id FROM Task WHERE Subject='Email: Walmart.com Marketplace Seller - Invitation to Apply'];
	    return fetchedTasks;
	}

}
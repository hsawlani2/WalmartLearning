global class CreateEmailFollowUp_Batch implements Database.Batchable<sObject> {
    
    public static final String TASK_SUBJECT = 'Email: Walmart.com Marketplace Seller - Invitation to Apply';
    public static final String TASK_STATUS = 'Completed';
    public static final Integer DAY_THRESHOLD = -7; // seven days ago
    public static final String FOLLOW_UP_SUBJECT = 'Application Invitation sent: 7-day reminder';
    public static final String FOLLOW_UP_COMMENT = 'This potential seller was invited to apply 7 days ago but has still not completed their application Please follow up with the potential seller to see if they need any assistance.';
    
    private DateTime customReference;
    
    global void setCustomReference(DateTime theReferenceDate) {
        customReference = theReferenceDate;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT AccountId,Id,Account.OwnerId,CreatedDate
            FROM Task 
            WHERE Subject = :TASK_SUBJECT AND Status = :TASK_STATUS AND Account.Latest_Application_Completed__c = NULL 
        ]);    
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        
        DateTime referenceDate = DateTime.now();
        if (customReference != null) {
            referenceDate = customReference;
        }
        
        List<Task> tasksToInsert = new List<Task>();
        for (sObject anObj : scope) {
			Task aTask = (Task)anObj;
			// System.debug('\n\n<<< task: ' + aTask.Id);
			// System.debug('\n\n<<< task created date : ' + aTask.CreatedDate);
			
			// Check if the task's created date was 7 days ago.
			DateTime sevenDaysAgo = referenceDate.addDays(DAY_THRESHOLD);
			// System.debug('\n<<< reference date: ' + sevenDaysAgo);
			if (aTask.CreatedDate.isSameDay(sevenDaysAgo)) {
			    
			    // System.debug('\n<<<< creating follow up');
			    // Create the follow up task
			    tasksToInsert.add(createFollowUpTask(aTask.AccountId, aTask.Account.OwnerId));
			}
        }
        if (!tasksToInsert.isEmpty()) {
            System.debug('\n\n<<< inserting follow ups: ' + tasksToInsert.size());
            insert tasksToInsert;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
		
	}
	
    private Task createFollowUpTask(String accountId, String ownerId) {
        
        // Due date is tomorrow
        DateTime dueDate = DateTime.now();
        if (customReference != null) {
            dueDate = customReference;
        }
        dueDate.addDays(1);
        
        Task aTask = new Task(
            Subject = FOLLOW_UP_SUBJECT,
            Description = FOLLOW_UP_COMMENT,
            OwnerId = ownerId,
            WhatId = accountId,
            ActivityDate = dueDate.date()
            );
        return aTask;
    }

}
@isTest
private class LeadtoFutureLead_Test {

    static testMethod void test() {
       
       List<Lead> leadList = new List<Lead>();
       
   
       

       for (Integer i=0;i<51;i++) {
           
          if(i<20){
            Lead le = new Lead();
          
            le.lastname = 'TestAcc' + String.valueof(i);
            le.Status ='LEAD';
            le.Title = 'XXX'+String.valueof(i);
            le.Company= 'ABS'+String.valueof(i);
            le.Phone = '111-222-333';
            le.Email= 'test@test.com';
            leadList.add(le);
          } 
     
       }
        insert leadList;

       Test.startTest();
       //List<lead> leadList1 = [SELECT Id,LastModifiedDate,Name,Status FROM Lead WHERE LastModifiedDate >= N_DAYS_AGO:45 AND Status = 'LEAD' limit 45000];
       LeadtoFutureLeadBatch c = new LeadtoFutureLeadBatch();
       Database.QueryLocator ql = c.start(null);
       c.execute(null,leadList);
       c.Finish(null);
       Test.stopTest();
    }
}
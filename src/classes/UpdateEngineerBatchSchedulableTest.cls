@isTest

Private class UpdateEngineerBatchSchedulableTest{
          public static String CRON_EXP = '0 0 0 15 5 ? 2021';

         static testMethod void testschedule() {

          Test.StartTest();
          UpdateEngineerMappingBatchSchedulable sf = new UpdateEngineerMappingBatchSchedulable ();
          
          System.schedule('ScheduleApexClassTest',CRON_EXP,sf);
          Test.stopTest();
          }
}
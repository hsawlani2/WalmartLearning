@isTest
public class CaseTimeControllerTest{
 public static testMethod void unitTest(){
     string duration='5';
     String comments='good';
     User user = [select Id from User where id !=: UserInfo.getUserId() and IsActive = true and Profile.Name = 'System Administrator' limit 1];
   Account acc = new Account(Name='Tes Acc', Type='Seller', Customer_Service_Email__c='test@test.com',Seller_Onboarding_Status__c='Seller Setup');
   insert acc;  
      Contact con = new Contact(LastName='Test Con', AccountId=acc.Id, Contact_Type__c = 'Test');
       insert con;
      Case newCase = new Case(AccountId = acc.Id, ContactId = con.Id, RecordTypeId = '0125B0000000CUG');
      insert newCase;
     
      Session_Time__c session = new Session_Time__c();
        session.Case__c = newCase.Id;
        session.Date__c = System.now();
        session.Duration__c = Integer.valueOf(duration);
        session.Agent__c = user.Id;
        session.Type__c = 'Manual';
        session.Comments__c = comments;
     	
        insert session;
     system.debug('session..'+session);
     
        ApexPages.StandardController sc = new ApexPages.standardController(newCase);
        CaseTimeController obj = new CaseTimeController(sc);
        PageReference cas = obj.recordManualSession();
    }
 public static testMethod void unitTest1(){
     string duration1;
     Integer duration=5;
     String comments='good';
   Account acc = new Account(Name='Tes Acc', Type='Seller', Customer_Service_Email__c='test@test.com',Seller_Onboarding_Status__c='Seller Setup');
   insert acc;  
      Contact con = new Contact(LastName='Test Con', AccountId=acc.Id, Contact_Type__c = 'Test');
       insert con;
      Case newCase = new Case(AccountId = acc.Id, ContactId = con.Id, RecordTypeId = '0125B0000000CUG');
      insert newCase;
      Session_Time__c session = new Session_Time__c();
        session.Case__c = newCase.Id;
        session.Date__c = System.now();
        session.Duration__c = duration;
        session.Agent__c = UserINFO.getUserId();
        session.Type__c = 'Manual';
        session.Comments__c = comments;
     
        insert session;
        string caseId = (String)newCase.Id;
        ApexPages.StandardController sc = new ApexPages.standardController(newCase);
        CaseTimeController obj = new CaseTimeController(sc);
        CaseTimeController.recordSession(caseId,duration1);
        Decimal cumulative = obj.cumulativeTime;
        Boolean isclosed = obj.isClosedCase;
        List<Session_Time__c> SessionTime = obj.sessions;
        List<Session_Time__c> SessionTime1 = obj.manualSessions;
    }
}
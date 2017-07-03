@isTest
public class WalOpportunityTriggerHandlerTest{
    static testMethod void TestWalOpportunityTriggerHandler() {
        test.startTest();
        List<Account> accList = TestUtilityClass.createAccount(1);
        List<Department__c> depList = TestUtilityClass.createDepartment(1);
        //User users = TestUtilityClass.createUsers();
        Buyer__c Buyers = TestUtilityClass.createBuyer();
        RHID__c rhidTest = TestUtilityClass.createRHID(Buyers.Id);
        Account_RHID__c accRhidTest = TestUtilityClass.createAccount_RHID(accList[0].Id, rhidTest.Id);
        Account_Department__c accDep = TestUtilityClass.createAccDepartment(accList[0].Id, depList[0].Id);
        Opportunity testOpp = TestUtilityClass.createOpp(accList[0].Id, 'DSV', accDep.Id, Buyers.Id);
        Opportunity testOpp1 = TestUtilityClass.createOpp(accList[0].Id, 'OWNED', accDep.Id, Buyers.Id);
        Opportunity testOpp2 = TestUtilityClass.createOpp(accList[0].Id, 'BOTH', accDep.Id, Buyers.Id);
        test.stopTest();
    }
}
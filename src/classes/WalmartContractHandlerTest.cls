@isTest
public class WalmartContractHandlerTest{
    static testMethod void TestWalmartContractHandler() {
        test.startTest();
        List<Account> accList = TestUtilityClass.createAccount(1);
        List<Department__c> depList = TestUtilityClass.createDepartment(1);
        Account_Department__c accDep = TestUtilityClass.createAccDepartment(accList[0].Id, depList[0].Id);
        Opportunity testOpp = TestUtilityClass.createOpp(accList[0].Id, 'DSV', accDep.Id);
        Opportunity testOpp1 = TestUtilityClass.createOpp(accList[0].Id, 'OWNED', accDep.Id);
        Opportunity testOpp2 = TestUtilityClass.createOpp(accList[0].Id, 'BOTH', accDep.Id);
        Contract__c con = TestUtilityClass.createAccContract(accDep.Id, 'DSV');
        Contract__c con1 = TestUtilityClass.createAccContract(accDep.Id, 'VENDOR');
        accDep.Active_DSV_Contracts__c = 2;
        accDep.Active_OWNED_Contracts__c = 2;
        update accDep;
        Contract__c con3 = TestUtilityClass.createAccContract(accDep.Id, 'DSV');
        Contract__c con4 = TestUtilityClass.createAccContract(accDep.Id, 'VENDOR');
        test.stopTest();
    }
}
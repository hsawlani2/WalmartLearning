@isTest
private class AccountUpdateTrigger_Test
{
    private static final String ACCOUNT_PREFIX = 'ACCT-';
    private static final String CONTACT_PREFIX = 'CONTACT-';
    private static final String OPP_PREFIX = 'OPP-';
    private static final Integer ARR_SIZE = 100;

    @testSetup
    private static void setUpAccountsWRecordTypes() {
        List<Account> accountList = new List<Account>();
        Map<ID, RecordType> rtMap = new Map<ID, RecordType>([Select Id, DeveloperName, SObjectType from RecordType Where SObjectType = 'Account']);
        for (Integer i = 0; i < ARR_SIZE; i++) {
            if(i<ARR_SIZE/2){
                accountList.add(new Account(Name=ACCOUNT_PREFIX+i, RecordTypeId=rtMap.get('012610000002gtz').Id));  //Seller Account RecordType            
            } else{
                accountList.add(new Account(Name=ACCOUNT_PREFIX+i, RecordTypeId=rtMap.get('012610000002gtu').Id));  //Supplier Account RecordType
            }
        }
        accountList.add(new Account(Name=ACCOUNT_PREFIX+(ARR_SIZE), RecordTypeId=rtMap.get('012610000002hXk').Id));  //Partner Account RecordType
        insert accountList;
        List<Account> accountListResult = [SELECT id, name, KB_Category_Visibility__c, RecordTypeId, Partner_Space__c FROM Account];
        System.assertEquals(ARR_SIZE+1, accountListResult.size());
        for(Account acctRow : accountListResult){
            if (acctRow.Name == 'ACCT-0') {
                System.assertEquals('Seller', acctRow.KB_Category_Visibility__c);
            }
            if (acctRow.Name == 'ACCT-' + (ARR_SIZE/2)){
                System.assertEquals('Supplier', acctRow.KB_Category_Visibility__c);
            }
            if (acctRow.Name == 'ACCT-' + (ARR_SIZE)){
                System.assertEquals('Seller', acctRow.KB_Category_Visibility__c);
            }
        }
    }

    /*  
    Scenario: ARR_SIZE # of accounts with specific record types as part of testSetup.  Update the same Accounts.
    Result: The updated partner account should have the appropriate value loaded in the KB_Category_Visibility__c field,
    Result: based on its' Partner_Space__c field value.  Includes test for null Partner_Space__c value and expect error.
    */
    @isTest
    private static void updateSupplierAccountUsingPartnerSpaceField(){
        List<Account> resultList = [SELECT id, name, KB_Category_Visibility__c, RecordTypeId, Partner_Space__c FROM Account];
        List<Account> acctsToUpdate = new List<Account>();
        System.assertEquals(ARR_SIZE+1, resultList.size());

        for (Account acctRow : resultList){
            if (acctRow.KB_Category_Visibility__c == 'Seller') {
                acctRow.Partner_Space__c = '1P Supplier';
                acctRow.RecordTypeId = '012610000002hXk'; //Partner RecordType
            }
            if (acctRow.KB_Category_Visibility__c == 'Supplier'){
                acctRow.Partner_Space__c = 'Marketplace';
                acctRow.RecordTypeId = '012610000002hXk'; //Partner RecordType
            }
            if (acctRow.Name == 'ACCT-' + (ARR_SIZE)){
                acctRow.Partner_Space__c = '';
            }
            acctsToUpdate.add(acctRow);
        }
        Try{
            List<Database.SaveResult> updatedResultList = Database.Update(acctsToUpdate, FALSE);
        }
        catch(Exception e){
            System.debug(LoggingLevel.WARN, '*****Debug threw an Exception => ' + e);
            System.assert(e.getMessage().contains('This field can not be empty when Partner Account Record Type is used.'));
        }
        Test.startTest();
        System.debug(LoggingLevel.WARN, '*****Debug page messages => ' + ApexPages.getMessages());
        List<Account> resultListAfterUpdate = [SELECT id, name, KB_Category_Visibility__c, RecordTypeId, Partner_Space__c 
                        FROM Account Where RecordTypeId = '012610000002hXk'];
        System.assertEquals(ARR_SIZE+1, resultListAfterUpdate.size());
        for(Account acctRow : resultListAfterUpdate){
            System.debug(LoggingLevel.WARN, '*****Debug acctRow => ' + acctRow);
            if(acctRow.RecordTypeId == '012610000002hXk'){
                if(acctRow.Partner_Space__c == '1P Supplier'){
                    System.assertEquals('Supplier', acctRow.KB_Category_Visibility__c);
                }else {
                    System.assertEquals('Seller', acctRow.KB_Category_Visibility__c);
                }
            }
        }
        Test.stopTest();
    }

    /*  
    Scenario: ARR_SIZE # of accounts with specific record types as part of testSetup.  Update the same Accounts.
    Result: The updated partner account should have the appropriate value loaded in the KB_Category_Visibility__c field,
    Result: based on its' Partner_Space__c field value.  Includes test for null Partner_Space__c value and expect error.
    */
    @isTest
    private static void updateSupplierAccountUsingEmptyPartnerSpaceField(){
        List<Account> resultList = [SELECT id, name, KB_Category_Visibility__c, RecordTypeId, Partner_Space__c FROM Account];
        System.assertEquals(ARR_SIZE+1, resultList.size());
        for (Integer i=0; i < resultList.size() ; i++){
            resultList[i].Partner_Space__c = '';
            resultList[i].RecordTypeId = '012610000002hXk'; //Partner RecordType
        }
        Try{
            List<Database.SaveResult> updatedResultList = Database.Update(resultList, FALSE);
        }
        catch(Exception e){
            System.assert(e.getMessage().contains('This field can not be empty when Partner Account Record Type is used.'));
        }
        System.debug(LoggingLevel.WARN, '*****Debug page messages => ' + ApexPages.getMessages());
        System.assertEquals(1, ApexPages.getMessages().size());
        List<Account> resultListAfterUpdate = [SELECT id, name, KB_Category_Visibility__c, RecordTypeId, Partner_Space__c FROM Account];
        for(Account acctRow : resultListAfterUpdate){
            System.debug(LoggingLevel.WARN, '*****Debug acctRow => ' + acctRow);
            if(acctRow.RecordTypeId == '012610000002hXk'){
                if(acctRow.Partner_Space__c == '1P Supplier'){
                    System.assertEquals('Supplier', acctRow.KB_Category_Visibility__c);
                }else {
                    System.assertEquals('Seller', acctRow.KB_Category_Visibility__c);
                }
            }
        }
    }

    //TODO: Add a test for multiple values in the Partner Space field.
    /*  
    Scenario: ARR_SIZE # of accounts with specific record types as part of testSetup.  Update with Multiple Partner Space values.
    Result: The updated partner account should have the appropriate value loaded in the KB_Category_Visibility__c field,
    Result: based on its' Partner_Space__c field value.
    */
    @isTest
    private static void updateSupplierAccountUsingMultipleValuesInPartnerSpaceField(){
        List<Account> resultList = [SELECT id, name, KB_Category_Visibility__c, RecordTypeId, Partner_Space__c FROM Account];
        System.assertEquals(ARR_SIZE+1, resultList.size());
        for (Integer i=0; i < resultList.size() ; i++){
            resultList[i].Partner_Space__c = 'Marketplace; 1P Supplier';
            resultList[i].RecordTypeId = '012610000002hXk'; //Partner RecordType
        }
        Try{
            List<Database.SaveResult> updatedResultList = Database.Update(resultList, FALSE);
        }
        catch(Exception e){
            System.assert(e.getMessage().contains('This field can not be empty when Partner Account Record Type is used.'));
        }
        System.debug(LoggingLevel.WARN, '*****Debug page messages => ' + ApexPages.getMessages());
        System.assertEquals(0, ApexPages.getMessages().size());
        List<Account> resultListAfterUpdate = [SELECT id, name, KB_Category_Visibility__c, RecordTypeId, Partner_Space__c 
        				FROM Account WHERE RecordTypeId = '012610000002hXk'];
        System.assertEquals(ARR_SIZE+1, resultListAfterUpdate.size());
        for(Account acctRow : resultListAfterUpdate){
            System.debug(LoggingLevel.WARN, '*****Debug acctRow => ' + acctRow);
            if(acctRow.RecordTypeId == '012610000002hXk'){
                System.assertEquals('Seller;Supplier', acctRow.KB_Category_Visibility__c);
            }
        }
    }

}
/**
 * AUTHOR       : Lennard Santos(Cloud Sherpas)
 * DESCRIPTION  : Data Utility class primarily used for building data on test classes
 * HISTORY      : 03.MAR.2014 - Created (LSantos)
 * */
@isTest
public class walmartDataUtility {
    /**
     * AUTHOR       : Lennard Santos(Cloud Sherpas)
     * DESCRIPTION  : method for building user data.
     * PARAM        : String userName(Username), Id usrProfileId(Profile Id)
     * RETURN       : User
     * HISTORY      : 03.MAR.2014 - Created (LSantos)
     **/
    public static User buildTestUser(String userName, Id profileId){
        User usr = new User();
            usr.Lastname = 'Testuser';
            usr.Alias='TUser99';
            usr.ProfileId = profileId;
            usr.emailencodingkey = 'UTF-8';
            usr.languagelocalekey = 'en_US';
            usr.localesidkey = 'en_US';
            usr.timezonesidkey = 'America/Los_Angeles';
            usr.email = 'testUser001@walmart.com';
            usr.username = userName;
        return usr;                                 
    }
    /**
     * AUTHOR       : Lennard Santos(Cloud Sherpas)
     * DESCRIPTION  : method for building account data.
     * PARAM        : String accName(Account Name)
     * RETURN       : Account
     * HISTORY      : 03.MAR.2014 - Created (LSantos)
     **/
    public static Account buildTestAccount(string accName){
         String mprecordType='MP_Account';
        recordtype rec = [select Id from recordtype where DeveloperName=:mprecordType limit 1];
        Account acc = new Account(
            Name = accName
        );
        acc.RecordTypeID=rec.ID;
        return acc;
    }
    /**
     * AUTHOR       : Lennard Santos(Cloud Sherpas)
     * DESCRIPTION  : method for building contact data.
     * PARAM        : String fName(Contact FirstName),String lName(Contact LastName), Id acctId(Account Id)
     * RETURN       : Contact
     * HISTORY      : 03.MAR.2014 - Created (LSantos)
     **/
    public static Contact buildTestContact(String fName, String lName, Id acctId){
        Contact contactData = new Contact(
            FirstName = fName,
            LastName = lName,
            AccountId = acctId,
            Email = 'walmart@email.org'
        );
        
        return contactData;
    }
}
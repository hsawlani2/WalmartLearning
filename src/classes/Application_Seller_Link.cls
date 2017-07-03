/****************************************************************************/
/* Handles the creation or update of Seller account, contact, opportunity.  */
/* Cloud Sherpas January 2016 - dcheung                                     */
/* There are 2 possible Seller Application flows                            */
/* 1) Application link was sent directly to the prpspective seller, the     */
/*    application would then have look up values to Account & Opportunity   */
/* 2) Application link was forwarded to the prpspective seller from a       */ 
/*    Channel Partner, the Account and Opportunity lookup values are null   */ 
/****************************************************************************/
public class Application_Seller_Link {
    
    @future
    public static void link(String applicationId, String partnerId) {
       
       Account acct;
       Contact cont;
       Opportunity opp;
       Application__c app;    
       
       List<Account> acctList = new List<Account>();
       List<Contact> contList = new List<Contact>();
       List<Opportunity> oppList = new List<Opportunity>();
       
       String appFields;
       String acctFields;
       String contFields;
       String oppFields;
       Object_Field_Map__c ofm;

       Set<String> appSet = new Set<String>();
       Set<String> acctSet = new Set<String>();
       Set<String> contSet = new Set<String>();
       Set<String> oppSet = new Set<String>();
       
       List<Object_Field_Map__c> acctFieldMap = new List<Object_Field_Map__c>();
       List<Object_Field_Map__c> contFieldMap = new List<Object_Field_Map__c>();
       List<Object_Field_Map__c> oppFieldMap = new List<Object_Field_Map__c>();
       Boolean insertAccount = false;
       Boolean insertContact = false;
       Boolean insertOpportunity = false;
       String defaultOppStage;
       Integer oppCloseDateLaspeDays;
       
       // Get default opportunity stage name;
       defaultOppStage = Application_Settings__c.getInstance('Default').Opportunity_Stage__c; 
       oppCloseDateLaspeDays = Integer.ValueOf(Application_Settings__c.getInstance('Default').Opportunity_Close_Laspe_Days__c);
       
       // Get Field mapping
       Map<String, Object_Field_Map__c> fieldMap = Object_Field_Map__c.getAll();
       
       for (String fieldkey: fieldMap.keySet()) {
            ofm = fieldMap.get(fieldkey); 
            // Get application record fields
            if (ofm.Source_Object__c=='Application__c' && ofm.IsActive__c==true) {
                if (ofm.Source_Field__c!=null) {
                    appSet.add(ofm.Source_Field__c);                
                }
                
                // Get Account, Contact, Opportunity field mappinngs and place into separate lists 
                if (ofm.Target_Object__c=='Account') {
                    acctFieldMap.add(ofm); 
                } else if (ofm.Target_Object__c=='Contact') {
                    contFieldMap.add(ofm); 
                } else if (ofm.Target_Object__c=='Opportunity') {               
                    oppFieldMap.add(ofm); 
                }
            }
       }
       
       // Normalize application fields.
       appFields = normalizeFieldNames(appSet);
       
       // Get Application 
       app = Database.query('SELECT Id, Account__c, Opportunity__c, '+appFields+' FROM Application__c WHERE Id =\''+applicationId+'\'');
       
       if (app==null) {
           // Do nothing, we can't located the application.
       } else {
          //**********************************************************************************//
          // Link to Account                                                                  //
          //**********************************************************************************//
          // Normalize account field names.
          for (Object_Field_Map__c ofm2 :acctFieldMap) {
               if (ofm2.Default_Value__c==null) {
                   acctSet.add(ofm2.Target_Field__c);
               }
          }
          // acctSet.add('Primary_Contact__c');
          acctFields = normalizeFieldNames(acctSet);
          
          System.debug('Fields: ' + acctFields);

          // Get the seller account record
          // WE-206 Removed logic to make sure application forms are created everytime
        //   if (app.Account__c == null) { 
        //       acctList = Database.query('SELECT Id, '+acctFields+' FROM Account WHERE Tax_ID__c =\''+app.Tax_ID__c+'\'');
        //   } 
        if (app.Account__c != null) {
            String mprecordType='MP_Account';
            acctList = Database.query('SELECT Id, '+acctFields+' FROM Account WHERE Id =\''+app.Account__c+'\'AND  RecordType.DeveloperName=:mprecordType');
        }
          
          if (acctList.size()==0) {
              // Create the account
              RecordType rec = [SELECT Id FROM Recordtype WHERE developername =:'MP_Account' LIMIT 1];
              acct = new Account(Name='Temp Seller Name');
              acct.recordtypeId = rec.Id;
              insertAccount = true;
          } else {
              acct = acctList[0];
          }
          
          // Set the values for the account fields
          setFieldValues(app, acct, acctFieldMap);  

          // Link account to channel partner account.             
          if (partnerId!=null) {
              acct.Channel_Partner__c = partnerId;
          }
           
          acct.Latest_Application_ID__c = applicationId;
           
          if (insertAccount) {
              insert acct;
              // Link application to account  
              app.Account__c = acct.Id;
          } else {
              update acct;
          }       
          
          //**********************************************************************************//
          // Link to Contact                                                                  //
          //**********************************************************************************//
          // Normalize contact field names.
          for (Object_Field_Map__c ofm2 :contFieldMap) {
               if (ofm2.Default_Value__c==null) {
                   contSet.add(ofm2.Target_Field__c);
               }
          }
          contFields = normalizeFieldNames(contSet);
          
          // refetch the Account
          String mprecordType='MP_Account';
          acct = [SELECT Id, Name, Primary_Contact__c FROM Account WHERE Id=:acct.Id AND RecordType.DeveloperName=:mprecordType];
          
          // Get the seller contact record
          if (insertAccount) {
              cont = new Contact(AccountId=acct.Id, FirstName='Unknown', LastName='Unknown');
              insertContact = true;
              
          } else {
              
              if (acct.Primary_Contact__c != null) {
                contList = Database.query('SELECT Id, '+contFields+' FROM Contact WHERE Id =\''+acct.Primary_Contact__c+'\'');
              }
              if (contList.size() == 0) {
                  cont = new Contact(AccountId=acct.Id, FirstName='Unknown', LastName='Unknown');
                  insertContact = true;
                  
              } else {
                  cont = contList[0];
              }
          }    
          
          // Set the values for the contact fields
          setFieldValues(app, cont, contFieldMap);      
           
          if (insertContact) {
              insert cont; 
          } else {
              update cont;
          }

          //**********************************************************************************//
          // Link to Opportunity                                                              //
          //**********************************************************************************//
          // Normalize contact field names.
          for (Object_Field_Map__c ofm2 :oppFieldMap) {
               if (ofm2.Default_Value__c==null) {
                   oppSet.add(ofm2.Target_Field__c);
               }
          }
          oppFields = normalizeFieldNames(oppSet);

          // Get the seller opportunity record
          if (insertAccount) {
              opp = new Opportunity(AccountId=acct.Id, Name=acct.Name, StageName=defaultOppStage);
              insertOpportunity = true;
          } else {
              oppList = Database.query('SELECT Id, '+oppFields+' FROM Opportunity WHERE AccountId = \''+acct.Id+'\' AND StageName = \''+defaultOppStage+'\'');
              if (oppList.size() == 0) {
                  opp = new Opportunity(AccountId=acct.Id, Name=acct.Name, StageName=defaultOppStage);
                  insertOpportunity = true;
              } else {
                  opp = oppList[0]; 
              }
          }    
          
          // Set the values for the Opportunity fields
          setFieldValues(app, opp, oppFieldMap);    
          
          // Set Opportunity Close Date
          opp.CloseDate = Date.today().addDays(oppCloseDateLaspeDays);
          opp.Latest_Application_ID__c = applicationId;
           
          if (insertOpportunity) {
              insert opp; 
              // Link application to opprtunity  
              app.Opportunity__c = opp.Id;
          } else {
              update opp;
          }
          
          //**********************************************************************************//
          // Update Application to link to Account & Opportunity                              //
          //**********************************************************************************//
          if (insertAccount || insertOpportunity) {
              update app;
          }
          
       }    
    }   
    
    private static void setFieldValues(Sobject sourceObj, Sobject targetObj, List<Object_Field_Map__c> ofmList) {
        
        List<SObject> relatedObjList;
        
        for (Object_Field_Map__c ofm :ofmList) {
            
             if (ofm.Default_Value__c == null) { 
                 // Target field values are not mapped to source field values.
                 if (ofm.Source_Related_Object__c == null) { 
                     if (ofm.Append_To_Target__c) {
                         // Append to value that has already been placed into the target field.
                         if (targetObj.get(ofm.Target_Field__c)==null) {
                             targetObj.put(ofm.Target_Field__c, sourceObj.get(ofm.Source_Field__c));              
                         } else {
                             targetObj.put(ofm.Target_Field__c, targetObj.get(ofm.Target_Field__c)+' '+sourceObj.get(ofm.Source_Field__c));               
                         }
                     } else {
                         targetObj.put(ofm.Target_Field__c, sourceObj.get(ofm.Source_Field__c));              
                     }    
                 } else {
                     // The soruce value is dervived from a relationship query. 
                     relatedObjList = sourceObj.getSObjects(ofm.Source_Related_Object__c); 
                     targetObj.put(ofm.Target_Field__c, relatedObjList[0].get(ofm.Source_Related_Field__c));              
                 }    
             } else {
                 // Target fields are not mapped but rather requires to set to default values.
                 if (ofm.Default_Value_Type__c == 'boolean') {
                     targetObj.put(ofm.Target_Field__c, Boolean.valueOf(ofm.Default_Value__c));               
                 } else if (ofm.Default_Value_Type__c == 'decimal') {
                     targetObj.put(ofm.Target_Field__c, decimal.valueOf(ofm.Default_Value__c));               
                 } else {
                     targetObj.put(ofm.Target_Field__c, (string)ofm.Default_Value__c);                
                 }   
             }    
        }
    }
    
    private static String normalizeFieldNames(Set<String> thisSet) {
       String outString;  
  
       for (String thisField :thisSet){
            if (outString==null){
                outString = thisField;
            } else {
                outString += ','+thisField;
            }
       }        
       
       return outString;    
    } 
}
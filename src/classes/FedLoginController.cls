public class FedLoginController {
   public Blob csvFileBody{get;set;}
   public string csvAsString{get;set;}
 
   
   public FedLoginController(){
   
   }
  
   public void importCSVFile(){
       try
       {
           csvAsString = csvFileBody.toString();
           String[] csvFileLines = csvAsString.split('\n'); 
           Map<String, String> emailToFedIdMap = new Map<String, String>();

           for(Integer i=1;i<csvFileLines.size();i++)
           {
               string[] csvRecordData = csvFileLines[i].split(',');
               emailToFedIdMap.put(csvRecordData[0], csvRecordData[1]);
           }
               
           List<User> userList = Database.query('Select Email From User'); 
           for(User walmartUser : userList) 
           { 
               String fedId = emailToFedIdMap.get(walmartUser.Email); 
               if(fedId!=null && !String.isEmpty(fedId))
                   walmartUser.FederationIdentifier = fedId; 
           } 
           update userList;
           ApexPages.Message successMessage = new ApexPages.Message(ApexPages.severity.INFO,'Upload completed without any failure.');
           ApexPages.addMessage(successMessage);

        }
        catch (Exception e)
        {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while mapping email to fed id in User object' + e.getMessage());
            ApexPages.addMessage(errorMessage);
        }  
    }
}
@isTest
public class FedLoginControllerTests {

    public static testMethod void testFedLoginController() {

         
        FedLoginController controller = new FedLoginController();
        String csvStr =  'email,fedid\n' + 'skumar3@walmartlabs.com,skuma87';
       
        //"skumar3@walmartlabs.comskuma87";
        // + "\n" + "GKhandelwal1@walmartlabs.com,gkhan3";
        controller.csvFileBody = Blob.valueOf(csvStr);
        test.starttest(); 
        //controller.importCSVFile(); 
        test.stoptest();
           
        // Verify that the success page displays
        
        String query = 'select Email, FederationIdentifier from User where Email = \'skumar3@walmartlabs.com\'';
        List<User> users = Database.query(query);
        
        System.assertEquals('skuma87', users.get(0).FederationIdentifier);
        
    }
}
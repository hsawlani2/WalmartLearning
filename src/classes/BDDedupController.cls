/**
 * This is Context class in a Strategy pattern used to dynamically select the correct dedup action.
 * 
 * @author: Shapoor Hashemi
 * @createdDate: 2/27/2017
 *
 *
 */

public without sharing class BDDedupController {
    public class ApplicationException extends Exception {}
    private Actionable work;
    private List<SObject> duplicateRows = new List<SObject>();

    public String actionStatus { get; private set;}

    public static final Map<String, Actionable> actionMap;

    static{
        // Retrieve comma delimited list of Application Settings from "Application_Settings__C" Custom Setting
        Application_Settings__C appSettings = Application_Settings__C.getInstance('Default');

        // Populate a List Collection of strategy names e.g., DuplicateLeadCheckAction, ApplicationLinkGenerationAction, etc
        List<String> actionName = new List<String>(appSettings.Ordered_Actions__C.deleteWhitespace().split(','));
        actionMap = new Map<String,Actionable>();
        for(String name : actionName){
            system.debug('test:'+name +'|' );
            try{
             system.debug('test1234:'+name +'|' );
            actionMap.put(name, (Actionable)Type.forName(name).newInstance());
             system.debug('test1234:'+name +'|' );
            }
            catch (exception ex) {
                 system.debug('test123'+ ex.getmessage());
            
            }
        }
    }

    public BDDedupController(String workName) {
        if(!actionMap.containsKey(workName)) throw new ApplicationException(workName);
        work = actionMap.get(workName);
        system.debug('workload'+ work);
    }   

    //Added 3/2.  In order to support the multiple scenarios.  We'll do the message processing in the client.
    public List<SObject> executeNew(SObject record, Schema.SObjectType targetObjType, List<SObject> identifiedDups){
        //System.debug(LoggingLevel.WARN, '***** Value of duplicateRows before executeNew => ' + duplicateRows);
        //System.debug(LoggingLevel.WARN, '***** Value of record before executeNew=> ' + record);
        duplicateRows = work.execute(record, targetObjType, identifiedDups);
        //System.debug(LoggingLevel.WARN, '***** Value of duplicateRows after executeNew => ' + duplicateRows);
        actionStatus = work.retrieveExecuteResponseMessage();
        return duplicateRows;
    }
}
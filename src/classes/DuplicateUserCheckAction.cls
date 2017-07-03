/**
 * This concrete class is part of the Strategy pattern used by the User DeDup process for Business Development.
 * 
 * @author: Shapoor Hashemi
 * @createdDate: 3/3/2017
 *
 *
 */

public with sharing class DuplicateUserCheckAction implements Actionable{

	private List<SObject> matchedObjList = new List<SObject>();
	private String successMessage = 'OK.  We found no duplicates.';
	private String matchedMessage = 'Your email is already in use as a user in our system. Please try registering with a different email.';

	public DuplicateUserCheckAction() {
	}

	public List<SObject> execute(SObject rec, Schema.SObjectType targetObjType, List<SObject> recList){
		if(rec.getSObjectType() == Lead.SObjectType){
			String query = 'Select Id, Email' +
								' From ' + String.valueOf(targetObjType) + ' Where Email = \'' + string.valueOf(rec.get('email')) + '\'';
			System.debug(LoggingLevel.WARN, '***** Value of query => ' + query);
	        matchedObjList = Database.query(query);
			//System.debug(logginglevel.WARN, '***** What is size of matchedObjList => ' + matchedObjList.size());
		}
		return matchedObjList;
	}

	public List<Sobject> execute(SObject record, Schema.SObjectType targetObjType){
		return null;
	}

	public String retrieveExecuteResponseMessage(){
		return matchedObjList.size() > 0 ? matchedMessage : successMessage;
	}
}
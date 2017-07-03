/**
 * This concrete class is part of the Strategy pattern used by the DeDup process for Business Development.
 * 
 * @author: Shapoor Hashemi
 * @createdDate: 2/27/2017
 *
 *
 */

public without sharing class DuplicateLeadCheckAction implements Actionable{

	private SObject masterObj;
	private List<SObject> matchedObjList = new List<SObject>();
	private String successMessage = 'OK.  We found no duplicates.';
	private String matchedMessage = 'Your email already exists in our registration database.\n To avoid duplication, please click "Cancel" and check your email for a link to continue with the existing entry. Otherwise, please click "Continue".';

	public DuplicateLeadCheckAction() {
	}

	//Added 3/2/17.  This is the signature to use for Prod.
	public List<SObject> execute(SObject rec, Schema.SObjectType targetObjType, List<SObject> recList){
		this.masterObj = rec;
		if(rec.getSObjectType() == Lead.SObjectType){
			String query = 'Select Id, Email, Status, LastModifiedDate, ' +
								'(Select Id, Account__c, Opportunity__c, Primary_Contact_Email__c, Tax_ID__c, Lead__c From Applications__r) ' +
								' From ' + String.valueOf(targetObjType) + ' Where Email = \'' + string.valueOf(rec.get('email')) + '\' and RecordType.DeveloperName=\'MP_Lead\'';
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
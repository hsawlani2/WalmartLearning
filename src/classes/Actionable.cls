public interface Actionable {

	//Define the method signature to be implemented in classes that implements the interface
	//Example method
	//List<SObject> execute(SObject rec);
	List<SObject> execute(SObject rec, Schema.SObjectType targetObjType);
	List<SObject> execute(SObject rec, Schema.SObjectType targetObjType, List<SObject> recList);
	String retrieveExecuteResponseMessage();

}
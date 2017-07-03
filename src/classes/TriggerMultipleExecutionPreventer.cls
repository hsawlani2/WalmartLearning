public class TriggerMultipleExecutionPreventer {
	private set<string> setTriggerAlreadyExecuting = new set<string>();
	public static TriggerMultipleExecutionPreventer self {get; private set;}
	static {
		self = new TriggerMultipleExecutionPreventer();
	}
	public boolean hasTriggerExecutionStarted(string sTriggerName) {
		boolean bTriggerExecutionStarted = false;
		if(sTriggerName!=null && sTriggerName!=''){
			sTriggerName=sTriggerName.tolowercase();
			bTriggerExecutionStarted = setTriggerAlreadyExecuting.contains(sTriggerName);
		}
		return bTriggerExecutionStarted;
	}
	public void setTriggerExecutionStarted(string sTriggerName) {
		if(sTriggerName!=null && sTriggerName!=''){
			sTriggerName=sTriggerName.tolowercase();
			setTriggerAlreadyExecuting.add(sTriggerName);
		}
	}
	public void removeTriggerExecutionStarted(string sTriggerName) {
		if(sTriggerName!=null && sTriggerName!=''){
			sTriggerName=sTriggerName.tolowercase();
			if(setTriggerAlreadyExecuting.contains(sTriggerName)){
				setTriggerAlreadyExecuting.remove(sTriggerName);
			}
		}
	}
	
	public void removeAllTriggerExecutionStarted() {
				setTriggerAlreadyExecuting.clear();
	}
	
	private TriggerMultipleExecutionPreventer() {
		System.debug('@Developer -->TriggerMultipleExecutionPreventer:' );
	}
}
/**
 * A marker class used to communicate between CaseController and the trigger
 * 
 * @author		Cloud Sherpas
 * @createddate	4-Feb-2016
 */ 
public class CaseTriggerHelper {
	/*
	 * This variable is used as a thread communication mechanism to
	 * communicate with the trigger on Case update scenarios to 
	 * allow the Case status to be changed to Need Info whenever the
	 * flow is triggered from the VF page.
	 * 
	 * In all other scenarios, this flag being true, the Status cannot
	 * be changed to Need Info if a User tries to change it from
	 * the UI.
	 */ 
    public static Boolean NEED_INFO_EDITED_FROM_UI = true;
}
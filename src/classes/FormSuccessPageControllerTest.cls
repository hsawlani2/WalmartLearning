@isTest
private class FormSuccessPageControllerTest {

	private static testMethod void test() {
	    
	    // Test application form path
	    PageReference pageRef = Page.FormSaveSuccess;
	    Test.setCurrentPageReference(pageRef); 
        System.currentPageReference().getParameters().put(ApplicationFormUtils.MESSAGE_CODE, ApplicationFormUtils.FORM_SUCCESS_CODE);
        FormSuccessPageController controller = new FormSuccessPageController();
        System.assert(controller.pageTitle == Label.ApplicationCompleteTitle, 'title should be correct');
        System.assert(controller.pageMessage == Label.ApplicationCompletedMessage, 'message should be correct');
        
        // Test contract form path
        pageRef = Page.FormSaveSuccess;
	    Test.setCurrentPageReference(pageRef); 
        System.currentPageReference().getParameters().put(ApplicationFormUtils.MESSAGE_CODE, ApplicationFormUtils.CONTRACT_SUCCESS_CODE);
        controller = new FormSuccessPageController();
        System.assert(controller.pageTitle == Label.ApplicationCompleteTitle, 'title should be correct');
        System.assert(controller.pageMessage == Label.ContractSuccessMessage, 'message should be correct');
        
        // Test error path
        pageRef = Page.FormSaveSuccess;
	    Test.setCurrentPageReference(pageRef); 
        System.currentPageReference().getParameters().put(ApplicationFormUtils.MESSAGE_CODE, ApplicationFormUtils.ERROR_CODE);
        controller = new FormSuccessPageController();
        System.assert(controller.pageTitle == Label.ApplicationErrorTitle, 'title should be correct');
        System.assert(controller.pageMessage == Label.ApplicationErrorMessage, 'message should be correct');
        
        // Assert existence of instance
        System.assert(controller.pCon != null, 'Should not be null');

	}

}
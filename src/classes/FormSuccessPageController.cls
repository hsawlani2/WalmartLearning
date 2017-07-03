public class FormSuccessPageController {
    
    public FormSuccessPageController pCon { get { return this; } }
    
    public FormSuccessPageController() {
        
    }
    
    public String pageTitle {
        get {
            if (isContractPath() || isApplicationPath()) {
                return Label.ApplicationCompleteTitle;    
            }
            return Label.ApplicationErrorTitle;
        }
    }
    
    public String pageMessage {
        get {
            if (isContractPath()) {
                return Label.ContractSuccessMessage;
            }
            else if (isApplicationPath()) {
                return Label.ApplicationCompletedMessage;
            }
            return Label.ApplicationErrorMessage;
        }
    }
    
    public String pageErrorDetails {
        get {
            String code = ApexPages.currentPage().getParameters().get(ApplicationFormUtils.MESSAGE_CODE);
            if (ApplicationFormUtils.ERROR_CODE.equals(code)) {
                return ApexPages.currentPage().getParameters().get(ApplicationFormUtils.ERROR_DETAILS);
            }
            return '';
        }
    }
    
    private Boolean isContractPath() {
        String code = ApexPages.currentPage().getParameters().get(ApplicationFormUtils.MESSAGE_CODE);
        return code.equals(ApplicationFormUtils.CONTRACT_SUCCESS_CODE);
    }
    
    private Boolean isApplicationPath() {
        String code = ApexPages.currentPage().getParameters().get(ApplicationFormUtils.MESSAGE_CODE);
        return code.equals(ApplicationFormUtils.FORM_SUCCESS_CODE);
    }

}
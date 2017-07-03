({
	doInit : function(component, event, helper) {
        var action = component.get("c.getPartnerList");
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
            	component.set("v.attachementsId",response.getReturnValue());
                console.log("attach Idss.. "+component.get("v.attachementsId"));
            }
        });
        $A.enqueueAction(action);
	},
    
    selectedPartner : function(component,event,helper){
        console.log("..clicked... ");
        var selectedItem = event.currentTarget;
        var recId = selectedItem.dataset.record;
        console.log('currentTarget.name is '+recId);
        console.log('selectedItem is '+selectedItem);
        $A.util.toggleClass(selectedItem, 'thumbnail selected');
    }
    
})
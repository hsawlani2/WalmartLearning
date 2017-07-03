({
	doInit : function(component, event, helper) {
        var testhml = '<div>test the div</div>';
        component.set("v.HTMLTest",testhml);
		var action = component.get("c.getFieldMEmebers");
		action.setParams({
						"FieldsetAPIName" : "Contact_Info"	
						});
		var self = this;
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var stringItems = response.getReturnValue();
                console.log(stringItems);
                console.log('doinit of the form component');
                component.set("v.FieldList",stringItems);
            }
        });
        $A.enqueueAction(action);
	}
})
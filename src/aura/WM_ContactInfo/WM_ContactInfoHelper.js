({
	configMap: {
        'anytype': { componentDef: 'ui:inputText', attributes: {} },
        'base64': { componentDef: 'ui:inputText', attributes: {} },
        'boolean': {componentDef: 'ui:inputCheckbox', attributes: {} },
        'combobox': { componentDef: 'ui:inputText', attributes: {} },
        'currency': { componentDef: 'ui:inputText', attributes: {} },
        'datacategorygroupreference': { componentDef: 'ui:inputText', attributes: {} },
        'date': {
            componentDef: 'ui:inputDate',
            attributes: {
                displayDatePicker: true
            }
        },
        'datetime': { componentDef: 'ui:inputDateTime', attributes: {} },
        'double': { componentDef: 'ui:inputNumber', attributes: {} },
        'email': { componentDef: 'ui:inputEmail', attributes: {} },
        'encryptedstring': { componentDef: 'ui:inputText', attributes: {} },
        'id': { componentDef: 'ui:inputText', attributes: {} },
        'integer': { componentDef: 'ui:inputNumber', attributes: {} },
        'multipicklist': { componentDef: 'ui:inputText', attributes: {} },
        'percent': { componentDef: 'ui:inputNumber', attributes: {} },
        'phone': { componentDef: 'ui:inputPhone', attributes: {} },
        'picklist': { componentDef: 'ui:inputText', attributes: {} },
        'reference': { componentDef: 'ui:inputText', attributes: {} },
        'string': { componentDef: 'ui:inputText', attributes: {} },
        'textarea': { componentDef: 'ui:inputText', attributes: {} },
        'time': { componentDef: 'ui:inputDateTime', attributes: {} },
        'url': { componentDef: 'ui:inputText', attributes: {} }
    },
    
    FetchTabDetails : function(component,event,helper){
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
			this.createForm(component,stringItems);
        }
        });
        $A.enqueueAction(action);
	},
	
	createForm: function(cmp,fieldset) {
        console.log('FieldSetFormHelper.createForm');
        var fields = fieldset;
        //var obj = cmp.get('v.record');
        var inputDesc = [];
        var fieldPaths = [];
        for (var i = 0; i < fields.length; i++) {
            var field = fields[i];
            var config = this.configMap[field.FieldType.toLowerCase()];
            if (config) {
                config.attributes.label = field.FieldLabel;
                config.attributes.required = field.FieldRequired;
                //config.attributes.value = obj[field.fieldPath];
                config.attributes.fieldPath = field.APIName;
                config.attributes.class = 'slds-input';
                inputDesc.push([
                    config.componentDef,
                    config.attributes
                ]);
                fieldPaths.push(field.APIName);
            } else {
                console.log('type ' + field.type.toLowerCase() + ' not supported');
            }
        }
		console.log(inputDesc);
        $A.createComponents(inputDesc, function(cmps,status, errorMessage) {
            console.log('createComponents');
			console.log(cmps);
			console.log(status);
            var inputToField = {};
            /*for (var i = 0; i < fieldPaths.length; i++) {
                cmps[i].addHandler('change', cmp, 'c.handleValueChange');
                inputToField[cmps[i].getGlobalId()] = fieldPaths[i];
            }*/
            cmp.get('v.TabBody');
            cmp.set('v.TabBody', cmps); // commenting this line just to check the form ui
            //cmp.set('v.inputToField', inputToField);
        });
    }
})
toolbuilder
buildMethodFinderInterfaceWith: builder in: frame
	| methodFinderPanel checkboxVerticalOffset methodFinderButton methodFinderCheckbox |

	checkboxVerticalOffset := 0.5.
	
	methodFinderPanel := builder pluggablePanelSpec new.
	methodFinderPanel
		model: self;
		children: OrderedCollection new;
		frame: frame.
	
	methodFinderButton := builder pluggableButtonSpec new.
	methodFinderButton
		model: self;
		label: 'Example Filter';
		action: #openMethodFinder;
		frame: (0.0@0.0 corner: 1.0@checkboxVerticalOffset).
	methodFinderPanel children add: methodFinderButton.
	
	methodFinderCheckbox := builder pluggableCheckBoxSpec new.
	methodFinderCheckbox
		model: self;
		label: #methodFinderLabel;
		state: #useMethodFinder;
		color: self windowColorToUse;
		action: #toggleMethodFinder;
		frame: (0.0@checkboxVerticalOffset corner: 1.0@1.0).
	methodFinderPanel children add: methodFinderCheckbox.

	^ methodFinderPanel
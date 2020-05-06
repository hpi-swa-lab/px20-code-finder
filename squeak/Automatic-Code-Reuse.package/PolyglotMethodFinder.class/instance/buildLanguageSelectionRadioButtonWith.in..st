toolbuilder
buildLanguageSelectionRadioButtonWith: builder in: frame
	"Build dynamic number of radiobuttons for the language selection with a ToolBuilder implementation"
	| languagePanel button model |
	
	languagePanel := builder pluggablePanelSpec new.
	languagePanel
		model: self;
		layout: #horizontal;
		children: OrderedCollection new;
		frame: frame.
		
	Polyglot availableLanguages do: [:languageId |
		button := builder pluggableCheckBoxSpec new.
		model := (DynamicRadioButtonModel newFor: self with: languageId).
		self radioButtons add: model.
		button
			model: model;
			label: #label;
			state: #state;
			color: self windowColorToUse;
			action: #action.
		languagePanel children add: button.
	].	
	
	^ languagePanel.
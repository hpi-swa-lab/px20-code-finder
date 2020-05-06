toolbuilder
buildLanguageSelectionWith: builder in: frame
	"Build the dynamic number of checkboxes for the language selection with a ToolBuilder implementation."
	| languagePanel button |

	languagePanel := builder pluggablePanelSpec new.
	languagePanel
		model: self;
		layout: #horizontal;
		children: OrderedCollection new;
		frame: frame.
		
	Polyglot availableLanguages do: [:languageId |
		button := builder pluggableCheckBoxSpec new.
		button
			model: (DynamicCheckboxModel newFor: self with: languageId);
			label: #label;
			state: #state;
			color: self windowColorToUse;
			action: #action.
		languagePanel children add: button.
	].

	^ languagePanel
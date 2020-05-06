language icons
snippetIconAt: anIndex
	"Returns the language icon for the snippet at the passed index. These icons are displayed in the list view on the left (ListSpec)."
	^ Polyglot iconFor: (self codeBlockList at: anIndex) snippet_language
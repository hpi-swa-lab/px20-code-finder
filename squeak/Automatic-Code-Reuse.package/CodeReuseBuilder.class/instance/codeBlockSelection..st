accessing
codeBlockSelection: anIndex
	"When this setter is called, the user clicked on a different code snippet in the list view. As a result the contents of the displayed code snippet 
	have to change (and the language of the selected code snippet)."
	codeBlockSelection := anIndex.
	self changed: #codeBlockSelection.
	self codeBlockList isEmpty
	ifFalse: [
		self selectedCodeSnippet: (self codeBlockList at: anIndex).
		self pcStyler changeLanguage: self fullDisplayLanguage.
	] ifTrue: [ self selectedCodeSnippet: nil. ].
	self
		changed: #fullDisplaySource;
		changed: #fullDisplayLanguage.
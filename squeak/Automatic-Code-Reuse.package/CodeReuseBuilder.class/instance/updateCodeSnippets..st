helper-methods
updateCodeSnippets: aQuery
	| codeSnippets |
	codeSnippets := self useMethodFinder
		ifTrue: [ aQuery select_method_finder_snippets: self methodFinder selection with: self methodFinder input with: self methodFinder output ]
		ifFalse: [ aQuery select_valid_snippets ].
	"codeSnippets size isZero ifTrue: [
		codeSnippets := aQuery code_snippets.
	]."
	self codeBlockList: OrderedCollection new.
	1 to: codeSnippets size do: [:index | 
		self codeBlockList add: (codeSnippets at: index).
	].
	self changed: #headerList.
	"We set this index anyway to ensure that any changes are rendered, but keep a selection if the user selected a different snippet."
	self codeBlockSelection > self codeBlockList size
		ifTrue: [ self codeBlockSelection: 1. ]
		ifFalse: [ self codeBlockSelection: self codeBlockSelection.].
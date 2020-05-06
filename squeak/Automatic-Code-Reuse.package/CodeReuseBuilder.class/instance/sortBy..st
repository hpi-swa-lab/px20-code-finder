sorting
sortBy: aBlock
	"Sort the code snippets by a custom block. The element of the current selection is saved and after sorting it is selected again."
	| selection |
	self codeBlockList isEmpty
		ifTrue: [ ^ self ].
	selection := self codeBlockList at: self codeBlockSelection.
	self codeBlockList: (self codeBlockList sort: aBlock).
	self changed: #headerList.
	self codeBlockSelection: (self codeBlockList indexOf: selection).
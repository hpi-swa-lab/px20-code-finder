accessing
codeBlockList
	^ codeBlockList ifNil: [ codeBlockList := OrderedCollection new ]
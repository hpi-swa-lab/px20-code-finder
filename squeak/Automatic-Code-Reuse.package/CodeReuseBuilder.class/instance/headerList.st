helper-methods
headerList
	"Returns the first line for each code snippet. These will be displayed in the list view on the left."
	^ self codeBlockList collect: [:codeSnippet | 
		codeSnippet header asString
	]
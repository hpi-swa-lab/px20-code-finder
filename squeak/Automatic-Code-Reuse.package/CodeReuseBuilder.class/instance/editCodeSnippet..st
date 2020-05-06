helper-methods
editCodeSnippet: aCodeSnippet
	"This method is called when the user edits and saves the currently displayed code snippets. It uses the set_code function from the python object to normalize the
	newlines in the text. If the first line is edited, the displayed header text (in the list view on the left) is also changed."
	self selectedCodeSnippet
		ifNotNil: [ self selectedCodeSnippet set_code: aCodeSnippet asString. ].
	self changed: #headerList
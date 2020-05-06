helper-methods
fullDisplayLanguage
	"If there is a code snippet selected, returns the programming language its written in. Otherwise returns an empty string"
	^ self selectedCodeSnippet
		ifNil: [ '' ]
		ifNotNil: [ self selectedCodeSnippet snippet_language ]
helper-methods
fullDisplaySource
	"If there is a code snippet selected, returns the full source code of it. Otherwise returns an empty string"
	^ self selectedCodeSnippet
		ifNil: [ '' ]
		ifNotNil: [ self selectedCodeSnippet code ]
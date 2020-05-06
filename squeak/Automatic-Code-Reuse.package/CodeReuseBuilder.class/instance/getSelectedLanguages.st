language selection
getSelectedLanguages
	"Returns the lowercase names of the languages selected by the user."
	| selected |
	selected := OrderedCollection new.
	self languageSelection keysAndValuesDo: [:languageId :selection|
		selection ifTrue: [
			selected add: (Polyglot languageNameOf: languageId) asLowercase
		].
	].
	^ selected
instance creation
newFor: anObject with: aLanguage
	| model |
	model := self new.
	^ model
		codeReuseBuilder: anObject;
		languageId: aLanguage;
		yourself
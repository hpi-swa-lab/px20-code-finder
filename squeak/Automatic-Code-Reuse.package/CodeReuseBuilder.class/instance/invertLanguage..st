language selection
invertLanguage: aLanguageId
	"Inverts the selection of the checkbox for a language. This method is called by instances of DynamicCheckboxModel when the user clicks on a checkbox."
	| oldValue |
	oldValue := self languageSelection at: aLanguageId.
	^ self languageSelection at: aLanguageId put: oldValue not
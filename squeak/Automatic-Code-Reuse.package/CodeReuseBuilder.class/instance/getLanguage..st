language selection
getLanguage: aLanguageId
	"Returns a boolean whether the given language is selected by the user. Returns true if the checkbox of the language is checked."
	^ self languageSelection at: aLanguageId	
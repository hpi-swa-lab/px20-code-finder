languageSelection
selectSingleLanguage: aLanguageId
	"Inverts the selection of the checkbox for a language and disables all others. This method is called by instances of DynamicRadioButtonModel when the user clicks on a checkbox."
	self radioButtons
		do: [ :model | model state: (model languageId == aLanguageId) ].
		
	
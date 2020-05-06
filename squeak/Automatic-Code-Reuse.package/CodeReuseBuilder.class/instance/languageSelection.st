accessing
languageSelection
	languageSelection ifNil: [
		languageSelection := Dictionary new.
		Polyglot availableLanguages do: [:languageId |
			languageSelection at: languageId put: true
		].
	].
	
	^ languageSelection
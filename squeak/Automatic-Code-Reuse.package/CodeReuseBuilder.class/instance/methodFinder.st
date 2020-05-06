accessing
methodFinder
	^ methodFinder ifNil: [ methodFinder := PolyglotMethodFinder newFrom: self ]
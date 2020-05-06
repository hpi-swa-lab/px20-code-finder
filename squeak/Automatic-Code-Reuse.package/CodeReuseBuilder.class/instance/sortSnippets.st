actions
sortSnippets
	self sortMenu ifNil: [
		self sortMenu: MenuMorph new.
		self sortMenu add: 'Sort by answer score' action: [ self sortByScore ].
		"self sortMenu add: 'Sort by execution time' action: [ self sortByExecutionTime ]."
		self sortMenu add: 'Sort by source lines of code' action: [ self sortBySLOC ].
		self sortMenu add: 'Sort by initial order' action: [ self sortByIndex ].
	].
	self sortMenu openAsTool.
actions
chooseSnippetAction
	"This action is executed when the button on the bottom right is clicked. The callback set on instance creation is used and it gets the three parameters: the parent object,
	the language of the code snippet, and the source code of the code snippet."
	self selectedCodeSnippet ifNil: [ ^ self. ].
	(self fullDisplayLanguage notNil and: [ self fullDisplaySource notNil ]) ifTrue: [
		self	parentCallback value: self parentObject value: self fullDisplayLanguage value: self selectedCodeSnippet code_with_license.
	]
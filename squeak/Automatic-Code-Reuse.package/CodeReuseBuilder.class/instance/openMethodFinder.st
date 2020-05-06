actions
openMethodFinder
	self methodFinderWindow 
		ifNil: [self methodFinderWindow: (self methodFinder buildWith: MorphicToolBuilder new)].
	self methodFinderWindow openInWorld.
	"Ensure that the selection is initialized by getting the current selection.
	If something is selected it stays selected and if nothing is selected, the first radio button will be selected."
	self methodFinder selection.
	self
		useMethodFinder: true;
		changed: #useMethodFinder.
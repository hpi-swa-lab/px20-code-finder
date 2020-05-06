instance creation
newFor: aParentObject withCallback: aBlock withLabel: aLabel
	| reuse |
	reuse := self new.
	^ reuse
		parentObject: aParentObject;
		parentCallback: aBlock;
		addSnippetButtonLabel: aLabel;
		yourself
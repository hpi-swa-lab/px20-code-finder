toolbuilder
buildWith: builder
	"Builds the PolyglotMethodFinder UI with a ToolBuilder implementation."
	| window codeSpecYOffset |
	
	codeSpecYOffset := 0.12.
	
	window := builder pluggableWindowSpec new
		model: self;
		children: OrderedCollection new;
		label: 'Example Filter';
		yourself.
		
	window children add: (self buildLanguageSelectionRadioButtonWith: builder in: (0@0 corner: 1.0@codeSpecYOffset)).
	window children add: (self buildCodeSpecWith: builder in: (0@codeSpecYOffset corner: 1.0@1.0)).
		
	^ builder build: window
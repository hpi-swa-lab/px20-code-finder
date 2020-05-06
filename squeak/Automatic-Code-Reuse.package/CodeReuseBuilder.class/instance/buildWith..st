toolbuilder
buildWith: builder
	"Builds the whole AutomaticCodeReuse UI with a ToolBuilder implementation."
	| window searchBoxOffset |

	searchBoxOffset := 0.12.
	
	window := builder pluggableWindowSpec new
		model: self;
		children: OrderedCollection new;
		label: 'Polyglot Code Finder';
		yourself.
	window children add: (self buildSearchWith: builder in: (0@0 corner: 1.0@searchBoxOffset)).
	window children add: (self buildResultWith: builder in: (0@searchBoxOffset corner: 1.0@1.0)).
	
	^ builder build: window
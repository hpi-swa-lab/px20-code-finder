toolbuilder
buildCodeSpecWith: builder in: frame
	"Build the code specs"
	| codePanel inputCodePane outputCodePane |
	
	codePanel := builder pluggablePanelSpec new.
	codePanel
		model: self;
		children: OrderedCollection new;
		frame: frame.
		
	self pcStyler: PCTextStyler new.	
	inputCodePane := PCPluggableCodeSpec new.
	inputCodePane
		model: self;
		readOnly: false;
		getText: #input;
		setText: #input:;
		editText: #input:;
		indicateUnacceptedChanges: false;
		styler: self pcStyler;
		frame: (0.0@0.0 corner: 1.0@0.5).
	codePanel children add: inputCodePane.
	
	outputCodePane := PCPluggableCodeSpec new.
	outputCodePane
		model: self;
		readOnly: false;
		getText: #output;
		setText: #output:;
		editText: #output:;
		indicateUnacceptedChanges: false;
		styler: self pcStyler;
		frame: (0.0@0.5 corner: 1.0@1.0).
	codePanel children add: outputCodePane.
	
	^ codePanel.
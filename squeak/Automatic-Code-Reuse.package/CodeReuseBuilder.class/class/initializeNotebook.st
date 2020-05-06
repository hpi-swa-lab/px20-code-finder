initialization
initializeNotebook
	"Add instance variables and method to the PolyglotNotebook to add support for the Polyglot Code Finder.
	The block closure will throw an error if the instance variables are already defined. We use that as a sign that it was already initialized"
	[
	"Add instance variables codeReuseBuilder and codeReuseWindow."
	PolyglotNotebook addInstVarName: 'codeReuseBuilder'.
	PolyglotNotebook compile: 'codeReuseBuilder
	^ codeReuseBuilder'.
	PolyglotNotebook compile: 'codeReuseBuilder: aBuilder
	codeReuseBuilder := aBuilder'.
	
	PolyglotNotebook addInstVarName: 'codeReuseWindow'.
	PolyglotNotebook compile: 'codeReuseWindow
	^ codeReuseWindow'.
	PolyglotNotebook compile: 'codeReuseWindow: aWindow
	codeReuseWindow := aWindow'.
	
	"Modify ToolBuilder method to add the search button."
	PolyglotNotebook compile: 'buildSwitchesWith: builder
	"Build the instance/comment/class switch"

	| panelSpec r a l s reuse |
	panelSpec := builder pluggablePanelSpec new
		layout: #horizontal;
		spacing: -1;
		children: OrderedCollection new;
		yourself.

	r := builder pluggableButtonSpec new.
	r 
			model: self;
			"horizontalResizing: #shrinkWrap;"
			label: ''Run all'';
			help: ''Run all code cells''; 
			action: #actionRunAll.

	a := builder pluggableButtonSpec new.
	a 
			model: self;
			label: ''Add cell'';
			help: ''Add a new code cell'';
			action: #actionAddCell.
			
	l := builder pluggableButtonSpec new.
	l 
			model: self;
			label: ''Load'';
			help: ''Load notebook from .ipynb file'';
			action: #actionLoad.
	s := builder pluggableButtonSpec new.
	s 
			model: self;
			label: ''Save'';
			help: ''Save notebook in .ipynb file'';
			action: #actionSave.
			
	reuse := builder pluggableButtonSpec new.
	reuse 
			model: self;
			label: ''Search'';
			help: ''Open the Automatic Code Reuse Tool'';
			action: #actionCodeReuse.
			
	panelSpec children addAll: {
		r.
		"builder pluggableSpacerSpec new."
		a.
		l.
		s.
		reuse.
	}.
	
	panelSpec frame: (LayoutFrame new
		leftFraction: 0 offset: 0;
		topFraction: 0 offset: 0;
		rightFraction: 1 offset: 0;
		bottomFraction: 0 offset: self buttonHeight).

	^panelSpec'.
	] on: Error do: [:e | ].
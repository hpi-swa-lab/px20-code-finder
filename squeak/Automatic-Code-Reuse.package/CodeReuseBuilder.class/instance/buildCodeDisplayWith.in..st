toolbuilder
buildCodeDisplayWith: builder in: frame
	"Build the display of the selected code snippet (using the PolyCode Editor) and the polyglot workspace with a ToolBuilder implementation."
	| codePanel fullTextDisplay insertButton verticalOffset2 verticalOffset1 embeddedWorkspace |
	verticalOffset1 := 0.5.
	verticalOffset2 := 0.93.
	
	codePanel := builder pluggablePanelSpec new.
	codePanel
		model: self;
		children: OrderedCollection new;
		frame: frame.

	self pcStyler: PCTextStyler new.
	fullTextDisplay := PCPluggableCodeSpec new.
	fullTextDisplay
		model: self;
		readOnly: false;
		getText: #fullDisplaySource;
		setText: #editCodeSnippet:;
		styler: self pcStyler;
		frame: (0.0@0.0 corner: 1.0@verticalOffset1).
	codePanel children add: fullTextDisplay.
	
	embeddedWorkspace := (CodeReuseWorkspace newFrom: self) buildCodePaneWith: builder.
	embeddedWorkspace frame: (0.0@verticalOffset1 corner: 1.0@verticalOffset2).
	codePanel children add: embeddedWorkspace.

	insertButton := builder pluggableButtonSpec new.
	insertButton
		model: self;
		label: self addSnippetButtonLabel;
		action: #chooseSnippetAction;
		frame: (0.0@verticalOffset2 corner: 1.0@1.0).
	codePanel children add: insertButton.

	^ codePanel
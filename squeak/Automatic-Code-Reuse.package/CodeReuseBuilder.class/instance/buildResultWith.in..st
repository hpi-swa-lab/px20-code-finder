toolbuilder
buildResultWith: builder in: frame
	"Build the result view consisting of the list of snippets and the selected snippet with a ToolBuilder implementation."
	| resultPanel codeDisplayPanel codeList verticalOffset horizontalOffset sortButton queryStatus |
	
	verticalOffset := 0.93.
	horizontalOffset := 0.15.
	
	resultPanel := builder pluggablePanelSpec new.
	resultPanel
		model: self;
		children: OrderedCollection new;
		frame: frame.
	
	codeList := builder pluggableListSpec new.
	codeList
		model: self;
		getIndex: #codeBlockSelection;
		setIndex: #codeBlockSelection:;
		list: #headerList;
		icon: #snippetIconAt:;
		autoDeselect: false;
		frame: (0.0@0.0 corner: 0.5@verticalOffset).
	resultPanel children add: codeList.
	
	sortButton := builder pluggableButtonSpec new.
	sortButton
		model: self;
		label: 'Sort';
		action: #sortSnippets;
		frame: (0.0@verticalOffset corner: horizontalOffset@1.0).
	resultPanel children add: sortButton.
	
	queryStatus := builder pluggableTextSpec new.
	queryStatus
		model: self;
		readOnly: true;
		getText: #queryStatus;
		indicateUnacceptedChanges: false;
		help: 'Query status';
		frame: (horizontalOffset@verticalOffset corner: 0.5@1.0).
	resultPanel children add: queryStatus.
	
	codeDisplayPanel := self buildCodeDisplayWith: builder in: (0.5@0.0 corner: 1.0@1.0).
	resultPanel children add: codeDisplayPanel.

	^ resultPanel
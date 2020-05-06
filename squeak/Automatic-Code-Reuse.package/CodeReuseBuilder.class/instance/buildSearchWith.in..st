toolbuilder
buildSearchWith: builder in: frame
	"Build the search field, button and the language selection with a ToolBuilder implementation."
	| searchPanel searchField checkboxVerticalOffset queryHorizontalOffset searchFieldHorizontalOffset queryButton |

	checkboxVerticalOffset := 0.5.
	queryHorizontalOffset := 0.2.
	searchFieldHorizontalOffset := 0.75.
	
	searchPanel := builder pluggablePanelSpec new.
	searchPanel
		model: self;
		children: OrderedCollection new;
		frame: frame.

	searchField := builder pluggableInputFieldSpec new.
	searchField
		model: self;
		setText: #query:;
		editText: #query:;
		help: 'Enter your query here...';
		indicateUnacceptedChanges: false;
		frame: (0.0@0.0 corner: searchFieldHorizontalOffset@checkboxVerticalOffset).
	searchPanel children add: searchField.
	
	searchPanel children add: (self buildMethodFinderInterfaceWith: builder in: (searchFieldHorizontalOffset@0.0 corner: 1.0@1.0)).

	searchPanel children add: (self buildLanguageSelectionWith: builder in: (queryHorizontalOffset@checkboxVerticalOffset corner: searchFieldHorizontalOffset@1.0)).

	queryButton := builder pluggableButtonSpec new.
	queryButton
		model: self;
		label: 'Search';
		action: #executeQueryAction;
		frame: (0.0@checkboxVerticalOffset corner: queryHorizontalOffset@1.0).
	searchPanel children add: queryButton.

	^ searchPanel
A CodeReuseBuilder is the model for the code reuse UI. It allows a user to search stackoverflow for a keyword (e.g. 'quick sort') and in multiple languages.
The user will then the queried results as code snippets and be able to edit them and execute them with sample data.
If the CodeReuseBuilder was openend by another object, such as the PolyglotNotebook, it can also add these code snippets as new cells to a notebook.
It uses a polyglot "backend". The path to it has to be set in the preferences (should be a clone of this repository: https://github.com/hpi-swa-lab/pp19-5-automatic-code-reuse).

Instance Variables
	addSnippetButtonLabel:	The label that will be displayed on the button to choose a snippet (e.g. 'Add as new cell' for the PolyglotNotebook).
	codeBlockList:				Collection of the code snippets returned by a query. These snippets are python objects.
	codeBlockSelection:		The index of the currently selected list item (used by the PluggableList).
	languageSelection:			Dictionary pointing from language id to a boolean, indicating if the checkbox for this language is checked.
	parentCallback:				The callback block set by the object that created this CodeReuseBuilder instance. This will be executed if the button on the bottom right is clicked.
								This callback should somehow use the selected code snipets.
								It should also accept the three parameters: the parent object, the language id of the code snippet, and the source code of the code snippet.
	parentObject:				The object that created this CodeReuseBuilder instance. This could be an instance of a PolyglotNotebook.
	pcStyler:					This styler is used to syntax highlight the source code of the selected code snippet.
	query:						The keywords typed in the user in the search bar.
	selectedCodeSnippet:		The current code snippet selected by the user.

addSnippetButtonLabel
	- Accessor method for the button label. Default is 'Add snippet'

codeBlockList
	- Accessor method for the code snippets. Default is an empty collection.

codeBlockSelection
	- Accessor method for the index of the selected code snippet. Default is 1 (the first snippet).

languageSelection
	- Accessor method for the Dictionary of language ids and whether they are selected. Default is a Dictionary with all available languages set to true. 

parentCallback
	- Accessor method with no side effect.

parentObject
	- Accessor method with no side effect.

pcStyler
	- Accessor method with no side effect.

query
	- Accessor method for the user input in the search field. The setter casts the passed object to a string, since the input can be passed as Text. It is used by the PluggableInputField to pass the value of the field.

selectedCodeSnippet
	- Accessor method with no side effect.

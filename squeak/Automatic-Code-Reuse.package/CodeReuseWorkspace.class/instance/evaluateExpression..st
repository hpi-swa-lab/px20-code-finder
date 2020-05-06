actions
evaluateExpression: selection
	"This method is called, when the contents of the workspace are evaluated (e.g., via 'run it' or 'print it'). Here we want to execute the snippet as well as the testing
	code written by the user. The code of the user is appended to the snippet, so that it can use the functions defined in the snippet. The used polyglot API method 
	executes the snippet in an isolated context, so that defined variables, constants, functions, etc. do not appear in the global polyglot scope."
	^ Polyglot
		eval: self codeReuseBuilder fullDisplayLanguage
		string: (self codeReuseBuilder fullDisplaySource, String cr, selection)
		inInnerContext: false
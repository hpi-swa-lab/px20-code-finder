actions
executeQueryAction
	"This action is executed when clicking the search button. It used the polyglot backend to query stackoverflow for the search query and creates 
	code snippets from the query result. These snippets are stored in the variable codeBlockList."
	| rubyCommand query tags |
	(self query isNil or: [self getSelectedLanguages isEmpty]) ifTrue: [
		^ self.
	].
	rubyCommand := 'require ''', self projectPath, 'code_importer/codesources/stackoverflow/stackoverflow_query'''.
	tags := self getSelectedLanguages collect: [:language | '"', language, '"'].
	rubyCommand := rubyCommand, '; StackoverflowQuery.new(''', self query, ''', [', tags asCommaString, '])'.
	query := Polyglot eval: 'ruby' string: rubyCommand.
	query initialize_squeak_callback: self.
	self queryStatus: query status asString.
	query query.
	[
		[(Delay forMilliseconds: 2000) wait. query query_step] whileTrue.
		self queryStatus: query status asString.
	] fork.
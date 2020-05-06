helper-methods
projectPath
	"The path to the polyglot backend project on disk. This path should be set in the Squeak preferences. The returned path is guaranteed to end with a slash."
	| path |
	path := self class codeReuseProjectPath.
	(path endsWith: '/') ifFalse: [ path := path, '/' ].
	^ path
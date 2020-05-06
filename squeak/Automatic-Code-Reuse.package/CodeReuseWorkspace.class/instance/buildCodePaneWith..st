toolbuilder
buildCodePaneWith: builder
	| textSpec |
	textSpec := super buildCodePaneWith: builder.
	textSpec indicateUnacceptedChanges: false.
	^ textSpec
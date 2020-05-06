*Automatic-Code-Reuse
actionCodeReuse
	self codeReuseBuilder ifNil: [
		self codeReuseBuilder: (CodeReuseBuilder newFor: self withCallback: [:parent :language :code | parent cellContainer addCodeCellFor: language with: code] withLabel: 'Insert as new cell').
		self codeReuseWindow: (self codeReuseBuilder buildWith: MorphicToolBuilder new).
	].
	self codeReuseWindow openInWorld	
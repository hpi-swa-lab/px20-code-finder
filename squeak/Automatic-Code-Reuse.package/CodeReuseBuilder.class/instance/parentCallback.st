accessing
parentCallback
	^ parentCallback ifNil: [ parentCallback := [:parent :language :code | Clipboard clipboardText: code] ]
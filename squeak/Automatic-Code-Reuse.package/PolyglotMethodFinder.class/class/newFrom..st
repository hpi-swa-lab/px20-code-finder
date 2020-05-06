instance creation
newFrom: aCodeReuseBuilder

	| instance |
	instance := self new.
	instance codeReuseBuilder: aCodeReuseBuilder.
	^ instance.
Extension { #name : 'FamixJavaMethod' }

{ #category : '*Model-JDKStubs-Fixer' }
FamixJavaMethod >> replaceParentTypeWith: aFamixTWithMethods [

	| oldParentType |
	oldParentType := self parentType.

	oldParentType methods
		remove: self
		ifAbsent: [ Error signal: 'Should not happen.' ].

	aFamixTWithMethods methods addLast: self
]

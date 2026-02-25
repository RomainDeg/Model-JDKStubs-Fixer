Extension { #name : 'FamixTWithInheritances' }

{ #category : '*Model-JDKStubs-Fixer' }
FamixTWithInheritances >> replaceSuperclassWith: aFamixTWithInheritances [

	| toRemove inheritance |
	toRemove := self superInheritances anyOne. "only one"

	"removing inheritance"
	self superInheritances
		remove: toRemove
		ifAbsent: [ Error signal: 'Should not happen.' ].
	self mooseModel remove: toRemove.

	"new inheritance"
	inheritance := self mooseModel newInheritance.
	inheritance
		subclass: self;
		superclass: aFamixTWithInheritances.
	self addSuperInheritance: inheritance.
	1 halt
]

Extension { #name : 'FamixTWithInheritances' }

{ #category : '*Model-JDKStubs-Fixer' }
FamixTWithInheritances >> replaceSuperclassWith: aFamixTWithInheritances [

	| toRemove inheritance superclass |
	toRemove := self superInheritances anyOne. "only one"

	"removing inheritance"
	superclass := toRemove superclass.
	self superInheritances
		remove: toRemove
		ifAbsent: [ Error signal: 'Should not happen.' ].

	"remove from subclass"
	superclass subInheritances
		remove: toRemove
		ifAbsent: [ Error signal: 'Should not happen.' ].

	"remove from model"
	self mooseModel remove: toRemove.

	"new inheritance"
	inheritance := self mooseModel newInheritance.
	inheritance
		subclass: self;
		superclass: aFamixTWithInheritances.
	self addSuperInheritance: inheritance.

]

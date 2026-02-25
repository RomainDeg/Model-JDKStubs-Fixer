Class {
	#name : 'ModelJDKFixer',
	#superclass : 'Object',
	#instVars : [
		'jdkModel',
		'modelToFix',
		'listTaMere'
	],
	#category : 'Model-JDKStubs-Fixer',
	#package : 'Model-JDKStubs-Fixer'
}

{ #category : 'as yet unclassified' }
ModelJDKFixer >> fix [
	| classesToFix correspondingClasses |
	classesToFix := self selectClassesToFix.
	correspondingClasses := self getClassesInJDKMatching: classesToFix.
	
	self fixClasses: correspondingClasses.
	1halt.
]

{ #category : 'as yet unclassified' }
ModelJDKFixer >> fixClass: anAssociation [

	| classToFix modelClass realSuperclass |
	classToFix := anAssociation value.
	modelClass := anAssociation key.

	realSuperclass := (modelToFix allUsing: FamixTWithInheritances)
		                  detect: [ :e |
		                  e mooseName = modelClass superclass mooseName ]
		                  ifNone: [ nil ].

	classToFix superInheritances size > 2 ifTrue: [
		1 halt "on verra j'vois pas dans le futur moi" ].

	realSuperclass
		ifNil: [ 1 halt "we'll see if it happens" ]
		ifNotNil: [ 1halt. classToFix replaceSuperclassWith: realSuperclass ]
]

{ #category : 'as yet unclassified' }
ModelJDKFixer >> fixClasses: aCollection [ 
	aCollection associationsDo: [ :c | self fixClass: c ]
]

{ #category : 'as yet unclassified' }
ModelJDKFixer >> getClassesInJDKMatching: aMooseGroup [

	| dict current |
	dict := Dictionary new.
	aMooseGroup do: [ :e |
			current := e.
			(jdkModel allUsing: FamixTWithInheritances)
				detect: [ :ee | e mooseName = ee mooseName ]
				ifFound: [ :ee | dict at: ee put: current ]
				ifNone: [ listTaMere add: current ] ].


	^ dict
]

{ #category : 'initialization' }
ModelJDKFixer >> initialize [ 

	listTaMere := OrderedCollection new.
]

{ #category : 'accessing' }
ModelJDKFixer >> jdkModel [

	^ jdkModel
]

{ #category : 'accessing' }
ModelJDKFixer >> jdkModel: anObject [

	jdkModel := anObject
]

{ #category : 'accessing' }
ModelJDKFixer >> modelToFix [

	^ modelToFix
]

{ #category : 'accessing' }
ModelJDKFixer >> modelToFix: anObject [

	modelToFix := anObject
]

{ #category : 'as yet unclassified' }
ModelJDKFixer >> selectClassesToFix [

	| potentialClassesToFix |
	potentialClassesToFix := self selectPotentialClassesToFix.
	^ potentialClassesToFix select: [ :c |
			  (jdkModel allUsing: FamixTWithInheritances)
				  detect: [ :cc | cc mooseName = c mooseName ]
				  ifFound: [ :cc |
						  cc superInheritances size = c superInheritances size and: [
								  cc superInheritances anySatisfy: [ :sc |
										  c superInheritances noneSatisfy: [ :scc |
											  sc superclass mooseName = scc superclass mooseName ] ] ] ]
				  ifNone: [ true ] ]
]

{ #category : 'as yet unclassified' }
ModelJDKFixer >> selectPotentialClassesToFix [

	^ (modelToFix allUsing: FamixTWithInheritances) select: [ :e |
		  e isStub and: [ e mooseName beginsWith: 'java' ] ]
]

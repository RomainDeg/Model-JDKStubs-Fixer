Class {
	#name : 'ModelJDKFixer',
	#superclass : 'Object',
	#instVars : [
		'jdkModel',
		'modelToFix',
		'classesWithoutEquivalents'
	],
	#category : 'Model-JDKStubs-Fixer',
	#package : 'Model-JDKStubs-Fixer'
}

{ #category : 'as yet unclassified' }
ModelJDKFixer >> fix [
	| classesToFix correspondingClasses methodsToFix |
	classesToFix := self selectClassesToFix.
	correspondingClasses := self getClassesInJDKMatching: classesToFix.
	methodsToFix := self selectMethodsToFix.
	
	1halt.
	self fixClasses: correspondingClasses.
	self fixMethods: methodsToFix.
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
		ifNotNil: [ classToFix replaceSuperclassWith: realSuperclass ]
]

{ #category : 'as yet unclassified' }
ModelJDKFixer >> fixClasses: aCollection [ 
	aCollection associationsDo: [ :c | self fixClass: c ]
]

{ #category : 'as yet unclassified' }
ModelJDKFixer >> fixMethod: methodToFix [

	| jdkEquivalentParentType jdkEquivalentMethod newParentType |
	jdkEquivalentParentType := jdkModel entityNamed:
		                           methodToFix parentType mooseName.

	jdkEquivalentParentType allSuperclassesDo: [ :sc |
			| found |
			found := false.
			found ifFalse: [
					sc methods
						detect: [ :m |
							m name = methodToFix name and: [
								m isImplementationOf: methodToFix ] ]
						ifFound: [ :m |
								found := true.
								jdkEquivalentMethod := m ]
						ifNone: [ "next" ] ] ].

	jdkEquivalentMethod ifNil: [
			1 halt.
			^ self "dommage je suppose" ].

	newParentType := modelToFix entityNamed:
		                 jdkEquivalentMethod parentType mooseName.
	methodToFix replaceParentTypeWith: newParentType
]

{ #category : 'as yet unclassified' }
ModelJDKFixer >> fixMethods: aCollection [ 
	aCollection do: [ :m | self fixMethod: m ]
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
				ifNone: [ classesWithoutEquivalents add: current ] ].


	^ dict
]

{ #category : 'initialization' }
ModelJDKFixer >> initialize [ 

	classesWithoutEquivalents := OrderedCollection new.
]

{ #category : 'as yet unclassified' }
ModelJDKFixer >> javaTopLevelPackages [
"returns java top level packages, excluding those found in the model to fix which are not stubs (org is commonly used, for example)"

	^ { 'com'. 'java'. 'javax'. 'jdk'. 'org' } select: [ :p |
			  modelToFix rootEntities
				  detect: [ :rt |
				  rt class = FamixJavaPackage and: [ rt name = p ] ]
				  ifFound: [ :pp | pp isStub ]
				  ifNone: [ false ] ]
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
ModelJDKFixer >> selectMethodsToFix [

	| potentialMethodsToFix |
	potentialMethodsToFix := self selectPotentialMethodsToFix.
	^ potentialMethodsToFix select: [ :c |
			  (jdkModel allMethods)
				  detect: [ :cc | cc mooseName = c mooseName ]
				  ifFound: [ :cc | false ]
				  ifNone: [ true ] ]
]

{ #category : 'as yet unclassified' }
ModelJDKFixer >> selectPotentialClassesToFix [

	^ (modelToFix allUsing: FamixTWithInheritances) select: [ :e |
		  e isStub and: [ e mooseName beginsWith: 'java' ] ]
]

{ #category : 'as yet unclassified' }
ModelJDKFixer >> selectPotentialMethodsToFix [
	| javaPackages |
	javaPackages := self javaTopLevelPackages.

	^ modelToFix allMethods select: [ :e |
			  e isStub and: [
					  | mooseName |
					  mooseName := e mooseName.
					  javaPackages anySatisfy: [ :packageName |
						  mooseName beginsWith: packageName ] ] ]
]

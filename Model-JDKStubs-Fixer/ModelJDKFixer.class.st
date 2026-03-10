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
ModelJDKFixer >> fixEntityTypingsWithoutSource [
	"Some entity typings are typing nothing. That's funny, but not for me, so we're killing those."

	| entitiesToKill |
	entitiesToKill := modelToFix select: [ :e |
		                  e class = FamixJavaEntityTyping and: [
			                  e source isNil ] ].

	entitiesToKill do: [ :e |
			| target |
			target := e target.
			target incomingTypings remove: e ifAbsent: [ "wtf" ].
			modelToFix silentlyRemove: e ]
]

{ #category : 'as yet unclassified' }
ModelJDKFixer >> fixForBridgeExpOnModel: model [ 

	modelToFix := model.
	self fixOrderOfMethodsWhenBothDefinedAndStubExists.
	self fixVisibilityOfInterfaceMethods 
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
ModelJDKFixer >> fixMethods: methods inClass: class [

	| methodsToFix sortingBlock indexesDict sortedIndexes |
	"what matters to us is the invocations, so we'll work with that"
	sortingBlock := [ :a :b |
		                a isStub not
			                ifTrue: [ true ]
			                ifFalse: [
					                b isStub not
						                ifTrue: [ false ]
						                ifFalse: [
								                a incomingInvocations size
								                > b incomingInvocations size
									                ifTrue: [ true ]
									                ifFalse: [
										                a incomingInvocations first mooseName
										                > b incomingInvocations first mooseName ] ] ] ].

	methodsToFix := methods sorted: sortingBlock.

	indexesDict := Dictionary new.
	methodsToFix do: [ :m |
		indexesDict at: m put: (class methods collector indexOf: m) ].
	1haltIf: [ indexesDict values isSorted not ].
	sortedIndexes := indexesDict values sorted.

	"last will be swapped by the other operations?"
	methodsToFix allButLast doWithIndex: [ :m :i |
			class methods collector
				swap: (indexesDict at: m)
				with: (sortedIndexes at: i) ]
]

{ #category : 'as yet unclassified' }
ModelJDKFixer >> fixOrderOfMethodsInClass: classes [

	| bag |
	bag := Bag newFrom: (classes methods collect: #mooseName).
	
	bag sortedCounts
	
]

{ #category : 'as yet unclassified' }
ModelJDKFixer >> fixOrderOfMethodsInClasses: classes [

	| methodsNameToFix methodsToFix |
	methodsNameToFix := ((Bag newFrom:
		                      (classes methods collect: #mooseName))
		                     sortedCounts select: [ :assoc | assoc key >= 2 ])
		                    collect: #value.
	methodsToFix := OrderedCollection new.
	methodsNameToFix do: [ :name |
			| col |
			methodsToFix add:
				(classes methods select: [ :m | m mooseName = name ]) ].

	methodsToFix do: [ :m | self fixMethods: m inClass: classes ]
]

{ #category : 'as yet unclassified' }
ModelJDKFixer >> fixOrderOfMethodsWhenBothDefinedAndStubExists [
	"Some MODEL classes have SEVERAL methods with the SAME MOOSENAME, SEVERAL stubs and the other being a MODEL method.
As always, it's a VerveineJ bug, and as always, I don't want to work on this **** (I eventually will anyway).
This method swaps the orders of the array holding those methods, so that you always get first the defined method, second the stub.
It's not ideal, but it fixes my current ordeal and it's super easy to implement, so it'll do."

	| classesToFix |
	classesToFix := modelToFix allModelClasses select: [ :c |
			                | b |
			                c methods
				                ifNotEmpty: [
						                b := Bag newFrom:
							                     (c methods collect: #mooseName).
						                b sortedCounts first key >= 2 ]
				                ifEmpty: [ false ] ].

	1 halt.
	classesToFix do: [ :c |  self fixOrderOfMethodsInClasses: c ]
]

{ #category : 'as yet unclassified' }
ModelJDKFixer >> fixVisibilityOfInterfaceMethods [
	"I hate VVJ and JDT and everything in between these things.
	With that said, this method makes every method from an interface which isn't static or default an abstract method (per Java specification, I'd paste a link right there if I still gave a fuck.
	Also, if a method isn't public, it has package visibility."

	| methodsToFix |
	methodsToFix := (modelToFix select: [ :e |
		                 e class = FamixJavaInterface ]) flatCollect: [ :i |
		                i methods ].

	methodsToFix do: [ :m |
			(m isClassSide or: [ m kind isNotNil and: [ m kind = 'default' ] ])
				ifFalse: [ m isAbstract: true ].
			m sourceAnchor ifNotNil: [
					| explicit |
					explicit := false.
					{ 'public'. 'private'. 'protected' } do: [ :v |
							(m sourceAnchor beginsWith: v) ifTrue: [
									explicit := true.
									m visibility: v ].
							explicit ifFalse: [ m visibility: 'public' ] ] ] ]
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

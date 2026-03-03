"
A ModelJDKFixerTest is a test class for testing the behavior of ModelJDKFixer
"
Class {
	#name : 'ModelJDKFixerTest',
	#superclass : 'TestCase',
	#instVars : [
		'jdkModel',
		'userModel',
		'fixer'
	],
	#category : 'Model-JDKStubs-Fixer-Tests',
	#package : 'Model-JDKStubs-Fixer-Tests'
}

{ #category : 'as yet unclassified' }
ModelJDKFixerTest >> createFakeJDKModel [

	| packages temp1 temp2 model superclass userClass inheritance method |
	model := FamixJavaModel new.

	"adding resources for method fixing"
	packages := OrderedCollection new.
	temp1 := model newPackageNamed: 'java'.
	temp2 := model newPackageNamed: 'util'.
	temp2 parentPackage: temp1.

	superclass := model newClassNamed: 'Hashtable'.
	superclass typeContainer: temp2.
	userClass := model newClassNamed: 'Properties'.

	inheritance := model newInheritance.
	inheritance
		subclass: userClass;
		superclass: superclass.

	method := model newMethodNamed: 'keys'.
	method parentType: superclass.
	
	userClass := model newClassNamed: 'Enumeration'.
	userClass typeContainer: temp2.
	
	method typing: model newEntityTyping.
	method typing declaredType: userClass.

	"adding resources for class fixing"
	temp2 := model newPackageNamed: 'lang'.
	temp2 parentPackage: temp1.
	temp1 := model newPackageNamed: 'reflect'.
	temp1 parentPackage: temp2.

	superclass := model newClassNamed: 'AccessibleObject'.
	superclass typeContainer: temp1.
	userClass := model newClassNamed: 'Method'.
	userClass typeContainer: temp1.

	inheritance := model newInheritance.
	inheritance
		subclass: userClass;
		superclass: superclass.

	^ model
]

{ #category : 'as yet unclassified' }
ModelJDKFixerTest >> createUserModel [

	| packages temp1 temp2 model superclass userClass inheritance method |
	model := FamixJavaModel new.

	"adding resources for method fixing"
	packages := OrderedCollection new.
	temp1 := model newPackageNamed: 'java'.
	temp2 := model newPackageNamed: 'util'.
	temp2 parentPackage: temp1.

	superclass := model newClassNamed: 'Hashtable'.
	superclass typeContainer: temp2.
	userClass := model newClassNamed: 'Properties'.

	inheritance := model newInheritance.
	inheritance
		subclass: userClass;
		superclass: superclass.

	method := model newMethodNamed: 'keys'.
	method parentType: userClass.
	
	userClass := model newClassNamed: 'Enumeration'.
	userClass typeContainer: temp2.
	
	method typing: model newEntityTyping.
	method typing declaredType: userClass.
	
	"adding resources for class fixing"
	temp2 := model newPackageNamed: 'lang'.
	temp2 parentPackage: temp1.
	temp1 := model newPackageNamed: 'reflect'.
	temp1 parentPackage: temp2.

	superclass := model newClassNamed: 'Executable'.
	superclass typeContainer: temp1.
	userClass := model newClassNamed: 'Method'.
	userClass typeContainer: temp1.

	inheritance := model newInheritance.
	inheritance
		subclass: userClass;
		superclass: superclass.
		
	superclass := model newClassNamed: 'AccessibleObject'.
	superclass typeContainer: temp1.
		
	^ model
]

{ #category : 'tests' }
ModelJDKFixerTest >> setUp [

	jdkModel := self createFakeJDKModel.
	userModel := self createUserModel.
	fixer := ModelJDKFixer new.
	fixer
		modelToFix: userModel;
		jdkModel: jdkModel
]

{ #category : 'tests' }
ModelJDKFixerTest >> testFixClass [

	| amountOfInheritance association userModelInheritance userModelSubclass |
	amountOfInheritance := userModel allInheritanceDefinitions size.
	userModelInheritance := userModel allInheritanceDefinitions detect: [
		                        :i | i source name = 'Method' ].
	userModelSubclass := userModelInheritance subclass.

	self
		assert: userModelInheritance superclass mooseName
		equals: 'java.lang.reflect.Executable'.

	association := (jdkModel allModelClasses detect: [ :e |
		                e name = 'Method' ])
	               ->
	               (userModel allModelClasses detect: [ :e |
		                e name = 'Method' ]).
	fixer fixClass: association.

	self assert: userModelInheritance superclass isNil.
	self assert: userModelInheritance subclass isNil.

	self
		assert: userModel allInheritanceDefinitions size
		equals: amountOfInheritance.
	self
		deny: userModel allInheritanceDefinitions anyOne
		equals: userModelInheritance.
	userModelInheritance := userModel allInheritanceDefinitions detect: [
		                        :i | i source name = 'Method' ].
	self
		assert: userModelInheritance superclass mooseName
		equals: 'java.lang.reflect.AccessibleObject'.
	self assert: userModelInheritance subclass equals: userModelSubclass
]

{ #category : 'tests' }
ModelJDKFixerTest >> testFixMethod [

	| methodToFix wrongParentType goodParentType  |
	methodToFix := userModel allMethods detect: [ :m | m name = 'keys' ].
	wrongParentType := methodToFix parentType.
	goodParentType := wrongParentType superclass.

	self assert: wrongParentType methods isNotEmpty.
	self assert: goodParentType methods isEmpty.
	self assert: methodToFix parentType equals: wrongParentType.

	fixer fixMethod: methodToFix.

	self assert: wrongParentType methods isEmpty.
	self assert: goodParentType methods isNotEmpty.
	self assert: methodToFix parentType equals: goodParentType.
]

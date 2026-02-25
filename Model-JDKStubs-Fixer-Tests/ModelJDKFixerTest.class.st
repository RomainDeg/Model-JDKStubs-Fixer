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

	| packages temp1 temp2 model superclass userClass inheritance |
	model := FamixJavaModel new.

	packages := OrderedCollection new.
	temp1 := model newPackageNamed: 'java'.
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

	| packages temp1 temp2 model superclass userClass inheritance |
	model := FamixJavaModel new.

	packages := OrderedCollection new.
	temp1 := model newPackageNamed: 'java'.
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

	| association userModelInheritance userModelSubclass |
	self assert: userModel allInheritanceDefinitions size equals: 1.
	userModelInheritance := userModel allInheritanceDefinitions anyOne.
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

	self assert: userModelInheritance subclass isNil.

	self assert: userModel allInheritanceDefinitions size equals: 1.
	self
		deny: userModel allInheritanceDefinitions anyOne
		equals: userModelInheritance.
	userModelInheritance := userModel allInheritanceDefinitions anyOne.
	self
		assert: userModelInheritance superclass mooseName
		equals: 'java.lang.reflect.AccessibleObject'.
]

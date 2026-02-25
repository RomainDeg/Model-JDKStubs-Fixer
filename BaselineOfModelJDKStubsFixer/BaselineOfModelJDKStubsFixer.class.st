Class {
	#name : 'BaselineOfModelJDKStubsFixer',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfModelJDKStubsFixer',
	#package : 'BaselineOfModelJDKStubsFixer'
}

{ #category : 'baselines' }
BaselineOfModelJDKStubsFixer >> baseline: spec [

	<baseline>
	spec for: #common do: [ spec package: 'Model-JDKStubs-Fixer' ]
]

{ #category : 'baselines' }
BaselineOfModelJDKStubsFixer >> mooseTestResourcesJavaModels: spec [

	spec baseline: 'MooseTestResourcesJavaModels' with: [
			spec repository:
				'github://RomainDeg/Moose-TestResources-JavaModels:main/src' ]
]

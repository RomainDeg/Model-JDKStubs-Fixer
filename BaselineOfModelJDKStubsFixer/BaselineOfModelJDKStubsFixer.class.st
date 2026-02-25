Class {
	#name : 'BaselineOfModelJDKStubsFixer',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfModelJDKStubsFixer',
	#package : 'BaselineOfModelJDKStubsFixer'
}

{ #category : 'baselines' }
BaselineOfModelJDKStubsFixer >> baseline: spec [

	<baseline>
	spec for: #common do: [
			spec
				package: 'Model-JDKStubs-Fixer';
				package: 'Model-JDKStubs-Fixer-Tests'
				with: [ spec requires: #( 'Model-JDKStubs-Fixer' ) ] ]
]

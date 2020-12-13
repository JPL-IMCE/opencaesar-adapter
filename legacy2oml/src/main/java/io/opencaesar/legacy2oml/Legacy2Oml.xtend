package io.opencaesar.legacy2oml

import gov.nasa.jpl.imce.oml.model.bundles.Bundle
import gov.nasa.jpl.imce.oml.model.bundles.BundledTerminologyAxiom
import gov.nasa.jpl.imce.oml.model.common.AnnotationProperty
import gov.nasa.jpl.imce.oml.model.common.AnnotationPropertyValue
import gov.nasa.jpl.imce.oml.model.common.Extent
import gov.nasa.jpl.imce.oml.model.common.LiteralBoolean
import gov.nasa.jpl.imce.oml.model.common.LiteralDateTime
import gov.nasa.jpl.imce.oml.model.common.LiteralDecimal
import gov.nasa.jpl.imce.oml.model.common.LiteralFloat
import gov.nasa.jpl.imce.oml.model.common.LiteralQuotedString
import gov.nasa.jpl.imce.oml.model.common.LiteralRational
import gov.nasa.jpl.imce.oml.model.common.LiteralRawString
import gov.nasa.jpl.imce.oml.model.common.LiteralReal
import gov.nasa.jpl.imce.oml.model.common.LiteralURI
import gov.nasa.jpl.imce.oml.model.common.LiteralUUID
import gov.nasa.jpl.imce.oml.model.common.LiteralValue
import gov.nasa.jpl.imce.oml.model.common.Module
import gov.nasa.jpl.imce.oml.model.datatypes.PositiveIntegerValue
import gov.nasa.jpl.imce.oml.model.descriptions.ConceptInstance
import gov.nasa.jpl.imce.oml.model.descriptions.DescriptionBox
import gov.nasa.jpl.imce.oml.model.descriptions.DescriptionBoxExtendsClosedWorldDefinitions
import gov.nasa.jpl.imce.oml.model.descriptions.DescriptionBoxRefinement
import gov.nasa.jpl.imce.oml.model.descriptions.ReifiedRelationshipInstance
import gov.nasa.jpl.imce.oml.model.descriptions.ReifiedRelationshipInstanceDomain
import gov.nasa.jpl.imce.oml.model.descriptions.ReifiedRelationshipInstanceRange
import gov.nasa.jpl.imce.oml.model.descriptions.SingletonInstanceScalarDataPropertyValue
import gov.nasa.jpl.imce.oml.model.graphs.TerminologyGraph
import gov.nasa.jpl.imce.oml.model.graphs.TerminologyNestingAxiom
import gov.nasa.jpl.imce.oml.model.terminologies.Aspect
import gov.nasa.jpl.imce.oml.model.terminologies.AspectSpecializationAxiom
import gov.nasa.jpl.imce.oml.model.terminologies.BinaryScalarRestriction
import gov.nasa.jpl.imce.oml.model.terminologies.CardinalityRestrictedAspect
import gov.nasa.jpl.imce.oml.model.terminologies.CardinalityRestrictedConcept
import gov.nasa.jpl.imce.oml.model.terminologies.CardinalityRestrictedReifiedRelationship
import gov.nasa.jpl.imce.oml.model.terminologies.CardinalityRestrictionKind
import gov.nasa.jpl.imce.oml.model.terminologies.ChainRule
import gov.nasa.jpl.imce.oml.model.terminologies.Concept
import gov.nasa.jpl.imce.oml.model.terminologies.ConceptSpecializationAxiom
import gov.nasa.jpl.imce.oml.model.terminologies.DataRange
import gov.nasa.jpl.imce.oml.model.terminologies.Entity
import gov.nasa.jpl.imce.oml.model.terminologies.EntityExistentialRestrictionAxiom
import gov.nasa.jpl.imce.oml.model.terminologies.EntityScalarDataProperty
import gov.nasa.jpl.imce.oml.model.terminologies.EntityScalarDataPropertyParticularRestrictionAxiom
import gov.nasa.jpl.imce.oml.model.terminologies.EntityStructuredDataProperty
import gov.nasa.jpl.imce.oml.model.terminologies.EntityUniversalRestrictionAxiom
import gov.nasa.jpl.imce.oml.model.terminologies.ForwardProperty
import gov.nasa.jpl.imce.oml.model.terminologies.IRIScalarRestriction
import gov.nasa.jpl.imce.oml.model.terminologies.InverseProperty
import gov.nasa.jpl.imce.oml.model.terminologies.NumericScalarRestriction
import gov.nasa.jpl.imce.oml.model.terminologies.PlainLiteralScalarRestriction
import gov.nasa.jpl.imce.oml.model.terminologies.ReifiedRelationship
import gov.nasa.jpl.imce.oml.model.terminologies.ReifiedRelationshipRestriction
import gov.nasa.jpl.imce.oml.model.terminologies.ReifiedRelationshipSpecializationAxiom
import gov.nasa.jpl.imce.oml.model.terminologies.RestrictableRelationship
import gov.nasa.jpl.imce.oml.model.terminologies.RuleBodySegment
import gov.nasa.jpl.imce.oml.model.terminologies.Scalar
import gov.nasa.jpl.imce.oml.model.terminologies.ScalarDataProperty
import gov.nasa.jpl.imce.oml.model.terminologies.ScalarOneOfLiteralAxiom
import gov.nasa.jpl.imce.oml.model.terminologies.ScalarOneOfRestriction
import gov.nasa.jpl.imce.oml.model.terminologies.SegmentPredicate
import gov.nasa.jpl.imce.oml.model.terminologies.StringScalarRestriction
import gov.nasa.jpl.imce.oml.model.terminologies.Structure
import gov.nasa.jpl.imce.oml.model.terminologies.StructuredDataProperty
import gov.nasa.jpl.imce.oml.model.terminologies.SubDataPropertyOfAxiom
import gov.nasa.jpl.imce.oml.model.terminologies.SubObjectPropertyOfAxiom
import gov.nasa.jpl.imce.oml.model.terminologies.SynonymScalarRestriction
import gov.nasa.jpl.imce.oml.model.terminologies.TerminologyExtensionAxiom
import gov.nasa.jpl.imce.oml.model.terminologies.TimeScalarRestriction
import gov.nasa.jpl.imce.oml.model.terminologies.UnreifiedRelationship
import io.opencaesar.oml.Description
import io.opencaesar.oml.Literal
import io.opencaesar.oml.Ontology
import io.opencaesar.oml.Predicate
import io.opencaesar.oml.RangeRestrictionKind
import io.opencaesar.oml.SeparatorKind
import io.opencaesar.oml.Vocabulary
import io.opencaesar.oml.VocabularyBundle
import io.opencaesar.oml.util.OmlWriter
import java.math.BigDecimal
import java.util.ArrayList
import java.util.Collections
import java.util.regex.Pattern
import org.apache.log4j.LogManager
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource

class Legacy2Oml {

	public static val BUILT_IN_ONTOLOGIES = #[
		'http://imce.jpl.nasa.gov/oml/oml'
	]

	val OmlWriter oml	
	val Resource inputResource 
	val URI outputResourceURI
	
	val LOGGER = LogManager.getLogger(Legacy2Oml)
	
	new(Resource inputResource, URI outputResourceURI, OmlWriter oml) {
		this.inputResource = inputResource
		this.outputResourceURI = outputResourceURI
		this.oml = oml
	}
	
	def Ontology run() {
		val module = inputResource.contents.filter(Extent).head.modules.head
		val ontology = module.toOntology()
		module.eAllContents.forEach[addToOntology(ontology)]
		return ontology
	}
		
	def dispatch Ontology toOntology(Module module) {
		// do nothing
	}

	def dispatch Vocabulary toOntology(TerminologyGraph graph) {
		oml.createVocabulary(outputResourceURI, graph.convertIri, graph.convertSeparator, graph.convertName)
	}

	def dispatch VocabularyBundle toOntology(Bundle bundle) {
		oml.createVocabularyBundle(outputResourceURI, bundle.convertIri, bundle.convertSeparator, bundle.convertName)
	}

	def dispatch Description toOntology(DescriptionBox box) {
		oml.createDescription(outputResourceURI, box.convertIri, box.convertSeparator, box.convertName)
	}

	def dispatch void addToOntology(EObject input, Ontology ontology) {
		if (!(input instanceof LiteralValue ||
			  input instanceof RuleBodySegment ||
			  input instanceof SegmentPredicate ||
			  input instanceof ForwardProperty ||
			  input instanceof InverseProperty ||
			  input instanceof ScalarOneOfLiteralAxiom ||
			  input instanceof ReifiedRelationshipInstanceDomain ||
			  input instanceof ReifiedRelationshipInstanceRange ||
			  input instanceof TerminologyNestingAxiom ||
			  input instanceof CardinalityRestrictedAspect ||
			  input instanceof CardinalityRestrictedConcept ||
			  input instanceof CardinalityRestrictedReifiedRelationship)) {
			LOGGER.error("Unhandled: "+input)
		}
	}
	
	def dispatch void addToOntology(Aspect input, Vocabulary vocabulary) {
		oml.addAspect(vocabulary, input.getName())
	}

	def dispatch void addToOntology(Concept input, Vocabulary vocabulary) {
		oml.addConcept(vocabulary, input.getName())
	}

	def dispatch void addToOntology(ReifiedRelationship input, Vocabulary vocabulary) {
		val relationship = oml.addRelationEntity(vocabulary, input.getName(), input.source.iri, input.target.iri, 
			input.isIsFunctional, input.isIsInverseFunctional, input.isSymmetric, input.isAsymmetric, input.isReflexive, input.isIrreflexive, input.isTransitive)
		oml.addForwardRelation(relationship, input.forwardProperty.getName)
		if ( input.inverseProperty !== null) {
			oml.addReverseRelation(relationship, input.inverseProperty.getName)
		}
	}

	def dispatch void addToOntology(ReifiedRelationshipRestriction input, Vocabulary vocabulary) {
		val relationship = oml.addRelationEntity(vocabulary, input.getName(), input.source.iri, input.target.iri, 
			false, false, false, false, false, false, false)
		oml.addForwardRelation(relationship, input.unreifiedName)
	}

	def dispatch void addToOntology(UnreifiedRelationship input, Vocabulary vocabulary) {
		val relationship = oml.addRelationEntity(vocabulary, input.reifiedName, input.source.iri, input.target.iri, input.isIsFunctional,
			input.isIsInverseFunctional, input.isSymmetric, input.isAsymmetric, input.isReflexive, input.isIrreflexive, input.isTransitive)
		oml.addForwardRelation(relationship, input.getName())
	}

	def dispatch void addToOntology(Structure input, Vocabulary vocabulary) {
		oml.addStructure(vocabulary, input.getName)
	}

	def dispatch void addToOntology(Scalar input, Vocabulary vocabulary) {
		oml.addFacetedScalar(vocabulary, input.getName, null, null, null, null, null, null, null, null, null)
	}

	def dispatch void addToOntology(SynonymScalarRestriction input, Vocabulary vocabulary) {
		oml.addFacetedScalar(vocabulary, input.getName, null, null, null, null, null, null, null, null, null)
		oml.addSpecializationAxiom(vocabulary, input.iri, input.restrictedRange.iri)
	}

	def dispatch void addToOntology(BinaryScalarRestriction input, Vocabulary vocabulary) {
		val length = if (input.length.notNull) { input.length.convert }
		val minLength = if (input.minLength.notNull) { input.minLength.convert }
		val maxLength = if (input.maxLength.notNull) { input.maxLength.convert }
		oml.addFacetedScalar(vocabulary, input.getName, length, minLength, maxLength, null, null, null, null, null, null)
		oml.addSpecializationAxiom(vocabulary, input.iri, input.restrictedRange.iri)
	}

	def dispatch void addToOntology(IRIScalarRestriction input, Vocabulary vocabulary) {
		val length = if (input.length.notNull) { input.length.convert }
		val minLength = if (input.minLength.notNull) { input.minLength.convert }
		val maxLength = if (input.maxLength.notNull) { input.maxLength.convert }
		val pattern = if (input.pattern !== null) { input.pattern.value.substring(1, input.pattern.value.length-1) }
		oml.addFacetedScalar(vocabulary, input.getName, length, minLength, maxLength, pattern, null, null, null, null, null)
		oml.addSpecializationAxiom(vocabulary, input.iri, input.restrictedRange.iri)
	}

	def dispatch void addToOntology(PlainLiteralScalarRestriction input, Vocabulary vocabulary) {
		val length = if (input.length.notNull) { input.length.convert }
		val minLength = if (input.minLength.notNull) { input.minLength.convert }
		val maxLength = if (input.maxLength.notNull) { input.maxLength.convert }
		val pattern = if (input.pattern !== null) { input.pattern.value.substring(1, input.pattern.value.length-1) }
		val language = if (input.langRange !== null) { input.langRange.value }
		oml.addFacetedScalar(vocabulary, input.getName, length, minLength, maxLength, pattern, language, null, null, null, null)
		oml.addSpecializationAxiom(vocabulary, input.iri, input.restrictedRange.iri)
	}

	def dispatch void addToOntology(StringScalarRestriction input, Vocabulary vocabulary) {
		val length = if (input.length.notNull) { input.length.convert }
		val minLength = if (input.minLength.notNull) { input.minLength.convert }
		val maxLength = if (input.maxLength.notNull) { input.maxLength.convert }
		val pattern = if (input.pattern !== null) { input.pattern.value.substring(1, input.pattern.value.length-1) }
		oml.addFacetedScalar(vocabulary, input.getName, length, minLength, maxLength, pattern, null, null, null, null, null)
		oml.addSpecializationAxiom(vocabulary, input.iri, input.restrictedRange.iri)
	}

	def dispatch void addToOntology(NumericScalarRestriction input, Vocabulary vocabulary) {
		val minInclusive = if (input.minInclusive !== null) { input.minInclusive.convertToLiteral(null, vocabulary) }
		val minExclusive = if (input.minExclusive !== null) { input.minExclusive.convertToLiteral(null, vocabulary) }
		val maxInclusive = if (input.maxInclusive !== null) { input.maxInclusive.convertToLiteral(null, vocabulary) }
		val maxExclusive = if (input.maxExclusive !== null) { input.maxExclusive.convertToLiteral(null, vocabulary) }
		oml.addFacetedScalar(vocabulary, input.getName, null, null, null, null, null, minInclusive, minExclusive, maxInclusive, maxExclusive)
		oml.addSpecializationAxiom(vocabulary, input.iri, input.restrictedRange.iri)
	}

	def dispatch void addToOntology(TimeScalarRestriction input, Vocabulary vocabulary) {
		val minInclusive = if (input.minInclusive !== null) { input.minInclusive.convertToLiteral(null, vocabulary) }
		val minExclusive = if (input.minExclusive !== null) { input.minExclusive.convertToLiteral(null, vocabulary) }
		val maxInclusive = if (input.maxInclusive !== null) { input.maxInclusive.convertToLiteral(null, vocabulary) }
		val maxExclusive = if (input.maxExclusive !== null) { input.maxExclusive.convertToLiteral(null, vocabulary) }
		oml.addFacetedScalar(vocabulary, input.getName, null, null, null, null, null, minInclusive, minExclusive, maxInclusive, maxExclusive)
		oml.addSpecializationAxiom(vocabulary, input.iri, input.restrictedRange.iri)
	}

	def dispatch void addToOntology(ScalarOneOfRestriction input, Vocabulary vocabulary) {
		val literals = input.tbox.boxStatements.filter(ScalarOneOfLiteralAxiom).filter[axiom == input].map[value.convertToLiteral(valueType, vocabulary)]
		oml.addEnumeratedScalar(vocabulary, input.getName, literals)
		oml.addSpecializationAxiom(vocabulary, input.iri, input.restrictedRange.iri)
	}
	
	def dispatch void addToOntology(EntityStructuredDataProperty input, Vocabulary vocabulary) {
		oml.addStructuredProperty(vocabulary, input.getName, input.domain.iri, input.range.iri, input.isIdentityCriteria)
		if (input.isIsIdentityCriteria) {
			// this is currently not supported in openCAESAR OML
		}
	}

	def dispatch void addToOntology(StructuredDataProperty input, Vocabulary vocabulary) {
		oml.addStructuredProperty(vocabulary, input.getName, input.domain.iri, input.range.iri, false)
	}

	def dispatch void addToOntology(EntityScalarDataProperty input, Vocabulary vocabulary) {
		oml.addScalarProperty(vocabulary, input.getName, input.domain.iri, input.range.iri, input.isIdentityCriteria)
		/* 
		if (input.isIsIdentityCriteria) {
			oml.addKeyAxiom(vocabulary, input.domain.iri, Collections.singleton(input.iri))
		}*/
	}

	def dispatch void addToOntology(ScalarDataProperty input, Vocabulary vocabulary) {
		oml.addScalarProperty(vocabulary, input.getName, input.domain.iri, input.range.iri, false)
	}

	def dispatch void addToOntology(AnnotationProperty input, Vocabulary vocabulary) {
		oml.addAnnotationProperty(vocabulary, input.abbrevIRI.split(':').get(1))
	}

	def dispatch void addToOntology(ConceptInstance input, Description description) {
		oml.addConceptInstance(description, input.getName)
		oml.addConceptTypeAssertion(description, input.iri, input.singletonConceptClassifier.iri)
	}

	def dispatch void addToOntology(ReifiedRelationshipInstance input, Description description) {
		val domain = input.getDescriptionBox.reifiedRelationshipInstanceDomains.findFirst[reifiedRelationshipInstance == input].domain
		val range = input.getDescriptionBox.reifiedRelationshipInstanceRanges.findFirst[reifiedRelationshipInstance == input].range
		oml.addRelationInstance(description, input.getName, Collections.singletonList(domain.iri), Collections.singletonList(range.iri))
		oml.addRelationTypeAssertion(description, input.iri, input.singletonConceptualRelationshipClassifier.iri)
	}

	def dispatch void addToOntology(TerminologyExtensionAxiom input, Vocabulary vocabulary) {
		var importedIri = input.extendedTerminology.getIri
		if (importedIri.endsWith('/')) {
			importedIri = importedIri.substring(0, importedIri.length-1)
		}
		if (isBuiltInOntology(importedIri)) {
			val indirectImports = input.extendedTerminology.boxAxioms.filter(TerminologyExtensionAxiom)
			indirectImports.forEach[addToOntology(it, vocabulary)]
		} else {
			oml.addVocabularyExtension(vocabulary, importedIri, null)
		}
	}

	def dispatch void addToOntology(TerminologyExtensionAxiom input, VocabularyBundle bundle) {
		var importedIri = input.extendedTerminology.getIri
		if (importedIri.endsWith('/')) {
			importedIri = importedIri.substring(0, importedIri.length-1)
		}
		if (input.extendedTerminology instanceof TerminologyGraph) {
			oml.addVocabularyBundleInclusion(bundle, importedIri, null)
		} else {
			oml.addVocabularyBundleExtension(bundle, importedIri, null)
		}
	}
		
	def dispatch void addToOntology(BundledTerminologyAxiom input, VocabularyBundle bundle) {
		var importedIri = input.bundledTerminology.getIri
		if (importedIri.endsWith('/')) {
			importedIri = importedIri.substring(0, importedIri.length-1)
		}
		oml.addVocabularyBundleInclusion(bundle, importedIri, null)
	}

	def dispatch void addToOntology(DescriptionBoxExtendsClosedWorldDefinitions input, Description description) {
		val importedURI = input.closedWorldDefinitions?.eResource?.URI?.trimExtension
		if (importedURI !== null) {
			val importingURI = inputResource.URI
			val String relativePath = importedURI.deresolve(importingURI, true, true, true).toString
			oml.addDescriptionUsage(description, relativePath+'.'+Legacy2OmlApp.OML, null)
		}
	}

	def dispatch void addToOntology(DescriptionBoxRefinement input, Description description) {
		val importedURI = input.refinedDescriptionBox?.eResource?.URI?.trimExtension
		if (importedURI !== null) {
			val importingURI = inputResource.URI
			val String relativePath = importedURI.deresolve(importingURI, true, true, true).toString
			oml.addDescriptionExtension(description, relativePath+'.'+Legacy2OmlApp.OMLXMI, null)
		}
	}

	def dispatch void addToOntology(ConceptSpecializationAxiom input, Vocabulary vocabulary) {
		if (input.superConcept instanceof CardinalityRestrictedConcept) {
			val restriction = input.superConcept as CardinalityRestrictedConcept
			val axiom = oml.addRelationCardinalityRestrictionAxiom(vocabulary, input.subConcept.iri, restriction.restrictedRelationship.iri, restriction.restrictionKind.convert, restriction.restrictedCardinality.convert, restriction.restrictedRange.iri)
			restriction.annotations.forEach[oml.addAnnotation(vocabulary, axiom, property.getIri, value.convertToLiteral(null, vocabulary))]
		} else {
			val axiom = oml.addSpecializationAxiom(vocabulary, input.subConcept.iri, input.superConcept.iri)
			input.annotations.forEach[oml.addAnnotation(vocabulary, axiom, property.getIri, value.convertToLiteral(null, vocabulary))]
		}
	}

	def dispatch void addToOntology(AspectSpecializationAxiom input, Vocabulary vocabulary) {
		if (input.superAspect instanceof CardinalityRestrictedAspect) {
			val restriction = input.superAspect as CardinalityRestrictedAspect
			val axiom = oml.addRelationCardinalityRestrictionAxiom(vocabulary, input.subEntity.iri, restriction.restrictedRelationship.iri, restriction.restrictionKind.convert, restriction.restrictedCardinality.convert, restriction.restrictedRange.iri)
			restriction.annotations.forEach[oml.addAnnotation(vocabulary, axiom, property.getIri, value.convertToLiteral(null, vocabulary))]
		} else {
			val axiom = oml.addSpecializationAxiom(vocabulary, input.subEntity.iri, input.superAspect.iri)
			input.annotations.forEach[oml.addAnnotation(vocabulary, axiom, property.getIri, value.convertToLiteral(null, vocabulary))]
		}
	}

	def dispatch void addToOntology(ReifiedRelationshipSpecializationAxiom input, Vocabulary vocabulary) {
		if (input.superRelationship instanceof CardinalityRestrictedReifiedRelationship) {
			val restriction = input.superRelationship as CardinalityRestrictedReifiedRelationship
			val axiom = oml.addRelationCardinalityRestrictionAxiom(vocabulary, input.subRelationship.iri, restriction.restrictedRelationship.iri, restriction.restrictionKind.convert, restriction.restrictedCardinality.convert, restriction.restrictedRange.iri)
			restriction.annotations.forEach[oml.addAnnotation(vocabulary, axiom, property.getIri, value.convertToLiteral(null, vocabulary))]
		} else {
			val axiom = oml.addSpecializationAxiom(vocabulary, input.subRelationship.iri, input.superRelationship.iri)
			input.annotations.forEach[oml.addAnnotation(vocabulary, axiom, property.getIri, value.convertToLiteral(null, vocabulary))]
		}
	}
	
	def dispatch void addToOntology(SubDataPropertyOfAxiom input, Vocabulary vocabulary) {
		val axiom = oml.addSpecializationAxiom(vocabulary, input.subProperty.iri, input.superProperty.iri)
		input.annotations.forEach[oml.addAnnotation(vocabulary, axiom, property.getIri, value.convertToLiteral(null, vocabulary))]
	}

	def dispatch void addToOntology(SubObjectPropertyOfAxiom input, Vocabulary vocabulary) {
		val axiom = oml.addSpecializationAxiom(vocabulary, input.subProperty.reifiedIri, input.superProperty.reifiedIri)
		input.annotations.forEach[oml.addAnnotation(vocabulary, axiom, property.getIri, value.convertToLiteral(null, vocabulary))]
	}

	def dispatch void addToOntology(EntityUniversalRestrictionAxiom input, Vocabulary vocabulary) {
		val axiom = oml.addRelationRangeRestrictionAxiom(vocabulary, input.restrictedDomain.iri, input.restrictedRelationship.iri, input.restrictedRange.iri, RangeRestrictionKind.ALL)
		input.annotations.forEach[oml.addAnnotation(vocabulary, axiom, property.getIri, value.convertToLiteral(null, vocabulary))]
	}

	def dispatch void addToOntology(EntityExistentialRestrictionAxiom input, Vocabulary vocabulary) {
		val axiom = oml.addRelationRangeRestrictionAxiom(vocabulary, input.restrictedDomain.iri, input.restrictedRelationship.iri, input.restrictedRange.iri, RangeRestrictionKind.SOME)
		input.annotations.forEach[oml.addAnnotation(vocabulary, axiom, property.getIri, value.convertToLiteral(null, vocabulary))]
	}

	def dispatch void addToOntology(EntityScalarDataPropertyParticularRestrictionAxiom input, Vocabulary vocabulary) {
		val axiom = oml.addScalarPropertyValueRestrictionAxiom(vocabulary, input.restrictedEntity.iri, input.scalarProperty.iri, input.literalValue.convertToLiteral(input.valueType, vocabulary))
		input.annotations.forEach[oml.addAnnotation(vocabulary, axiom, property.getIri, value.convertToLiteral(null, vocabulary))]
	}

	def dispatch void addToOntology(SingletonInstanceScalarDataPropertyValue input, Description description) {
		val axiom = oml.addScalarPropertyValueAssertion(description, input.singletonInstance.iri, input.scalarDataProperty.iri, input.scalarPropertyValue.convertToLiteral(input.valueType, description))
		input.annotations.forEach[oml.addAnnotation(description, axiom, property.getIri, value.convertToLiteral(null, description))]
	}

	def dispatch void addToOntology(AnnotationPropertyValue input, Ontology ontology) {
		var propertyIri = input.property.getIri
		
		// some annotation properties are not defined in their own terminolog boxes
		if (!propertyIri.contains(input.property.module.getIri)) {
			// in this case, treat them as if they are defined in their adopted terminology boxes
			propertyIri = input.property.module.convertIri + input.property.module.convertSeparator + input.property.abbrevIRI.split(':').get(1)
		}
		
		if (input.subject instanceof Module) {
			if (propertyIri != "http://purl.org/dc/elements/1.1/identifier") {
				oml.addAnnotation(ontology, propertyIri, input.value.convertToLiteral(null, ontology))
			}
		} else if (input.subject instanceof CardinalityRestrictedAspect ||
			input.subject instanceof CardinalityRestrictedConcept ||
			input.subject instanceof CardinalityRestrictedReifiedRelationship) {
			// ignore this annotation since it will be added to the cardinality restrictions axioms
		} else if (input.subject instanceof gov.nasa.jpl.imce.oml.model.common.Resource) {
			if(propertyIri == "http://imce.jpl.nasa.gov/oml/oml#hasReificationLabel") {
				oml.addAnnotation(ontology, (input.subject as ReifiedRelationship).iri, "http://www.w3.org/2000/01/rdf-schema#label", input.value.convertToLiteral(null, ontology))
			} else if (propertyIri == "http://imce.jpl.nasa.gov/oml/oml#hasPropertyLabel") {
				oml.addAnnotation(ontology, (input.subject as ReifiedRelationship).forwardProperty.iri, "http://www.w3.org/2000/01/rdf-schema#label", input.value.convertToLiteral(null, ontology))
			} else if (propertyIri == "http://imce.jpl.nasa.gov/oml/oml#hasInverseLabel")  {
				oml.addAnnotation(ontology, (input.subject as ReifiedRelationship).inverseProperty.iri, "http://www.w3.org/2000/01/rdf-schema#label", input.value.convertToLiteral(null, ontology))
			} else if ((propertyIri == "http://purl.org/dc/elements/1.1/description" ||
				propertyIri == "http://www.w3.org/2000/01/rdf-schema#comment") &&
				input.subject instanceof ReifiedRelationship) {
				// in OML1 the some annotations on reified relationships are mapped in OWL to ones on the forward relation  
				oml.addAnnotation(ontology, (input.subject as ReifiedRelationship).forwardProperty.iri, propertyIri, input.value.convertToLiteral(null, ontology))
			} else { 
				oml.addAnnotation(ontology, (input.subject as gov.nasa.jpl.imce.oml.model.common.Resource).iri, propertyIri, input.value.convertToLiteral(null, ontology))
			}
		}
	}

	def dispatch void addToOntology(ChainRule input, Vocabulary vocabulary) {
		var i = 1
		var j = i+1
		val antecedent = new ArrayList<Predicate>
		var segment = input.firstSegment 
		while (segment !== null) {
			val predicate = segment.predicate
			if (predicate.predicate !== null) {
				if (predicate.predicate instanceof Entity) {
					antecedent += oml.createEntityPredicate(vocabulary, predicate.predicate.iri, 'x'+i)
				} else if (predicate.predicate instanceof RestrictableRelationship) {
					antecedent += oml.createRelationPredicate(vocabulary, predicate.predicate.iri, 'x'+i, 'x'+j)
					i = j
					j = j+1
				}
			} else if (predicate.unreifiedRelationshipInverse !== null) {
				antecedent += oml.createRelationPredicate(vocabulary, predicate.predicate.iri, 'x'+j, 'x'+i)
				i = j
				j = j+1
			} else if (predicate.reifiedRelationshipSource !== null) {
				antecedent += oml.createRelationEntityPredicate(vocabulary, predicate.reifiedRelationshipSource.iri, 'x'+j, 'x'+i, 'x'+(j+1))
				i = j
				j = j+2
			} else if (predicate.reifiedRelationshipInverseSource !== null) {
				antecedent += oml.createRelationEntityPredicate(vocabulary, predicate.reifiedRelationshipInverseSource.iri, 'x'+i, 'x'+j, 'x'+(j+1))
				i = j
				j = j+2
			} else if (predicate.reifiedRelationshipTarget !== null) {
				antecedent += oml.createRelationEntityPredicate(vocabulary, predicate.reifiedRelationshipTarget.iri, 'x'+(j+1), 'x'+i, 'x'+j)
				i = j
				j = j+2
			} else if (predicate.reifiedRelationshipInverseTarget !== null) {
				antecedent += oml.createRelationEntityPredicate(vocabulary, predicate.reifiedRelationshipInverseTarget.iri, 'x'+(j+1), 'x'+j, 'x'+i)
				i = j
				j = j+2
			}
			segment = segment.nextSegment
		}
		val consequent = Collections.singletonList(oml.createRelationPredicate(vocabulary, input.head.iri, 'x1', 'x'+i))
		oml.addRule(vocabulary, input.getName, consequent, antecedent)		
	}
		
	def dispatch Literal convertToLiteral(LiteralValue value, DataRange dataRange, Ontology ontology) {
		// do nothing
	}

	def dispatch Literal convertToLiteral(LiteralBoolean value, DataRange dataRange, Ontology ontology) {
		oml.createBooleanLiteral(ontology, value.bool)
	}
	
	def dispatch Literal convertToLiteral(LiteralDateTime value, DataRange dataRange, Ontology ontology) {
		oml.createQuotedLiteral(ontology, value.dateTime.value, dataRange?.iri, null)
	}

	def dispatch Literal convertToLiteral(LiteralQuotedString value, DataRange dataRange, Ontology ontology) {
		oml.createQuotedLiteral(ontology, value.string.toString() ?: "", dataRange?.iri, null)
	}

	static val pattern = Pattern.compile('''"(\\"|\n|\r|[^"]+?)",?''')
	
	def dispatch Literal convertToLiteral(LiteralRawString value, DataRange dataRange, Ontology ontology) {
		var v = value.string.toString()
		if (v !== null) {
			if (v.startsWith("[\"")) {// when strings have quotes, they get encoded as array of strings
	    		val matcher = pattern.matcher(v)
				var t = ""
	    		while (matcher.find()) {
			        var group = matcher.group(1)
			        group = group.replaceAll("\\\\n", "\n").replaceAll("\\\\t", "\t")
		        	t += group
	    		}
				v = t
			} else {
		        v = v.replaceAll("\\\\n", "\n").replaceAll("\\\\t", "\t")
			}
		}
		oml.createQuotedLiteral(ontology, v ?: "", dataRange?.iri, null)
	}

	def dispatch Literal convertToLiteral(LiteralUUID value, DataRange dataRange, Ontology ontology) {
		oml.createQuotedLiteral(ontology, value.uuid.toString() ?: "", dataRange?.iri, null)
	}

	def dispatch Literal convertToLiteral(LiteralURI value, DataRange dataRange, Ontology ontology) {
		oml.createQuotedLiteral(ontology, value.uri.toString() ?: "", dataRange?.iri, null)
	}

	def dispatch Literal convertToLiteral(LiteralReal value, DataRange dataRange, Ontology ontology) {
		oml.createDoubleLiteral(ontology, Double.valueOf(value.real.value))
	}

	def dispatch Literal convertToLiteral(LiteralRational value, DataRange dataRange, Ontology ontology) {
		oml.createQuotedLiteral(ontology, value.rational.value ?: "", dataRange?.iri, null)
	}

	def dispatch Literal convertToLiteral(LiteralFloat value, DataRange dataRange, Ontology ontology) {
		oml.createDoubleLiteral(ontology, Double.valueOf(value.float.value))
	}

	def dispatch Literal convertToLiteral(LiteralDecimal value, DataRange dataRange, Ontology ontology) {
		val decimalValue = value.decimal.value
		try {
			val longValue = Long.valueOf(decimalValue)
			if (longValue >= -2147483648l && longValue < 2147483648l) {
				oml.createIntegerLiteral(ontology, Integer.valueOf(decimalValue))
			} else if (longValue >= 2147483648l && longValue < 4294967296l) {
				oml.createQuotedLiteral(ontology, decimalValue, dataRange?.iri?:"http://www.w3.org/2001/XMLSchema#unsignedInt", null)
			} else {
				oml.createQuotedLiteral(ontology, decimalValue, dataRange?.iri?:"http://www.w3.org/2001/XMLSchema#long", null)
			}
		} catch (NumberFormatException e) {
			if (decimalValue.contains('.')) {
				oml.createDecimalLiteral(ontology, new BigDecimal(decimalValue))
			} else {
				oml.createQuotedLiteral(ontology, decimalValue, dataRange?.iri?:"http://www.w3.org/2001/XMLSchema#unsignedLong", null)
			}
		}
	}

	def String convertIri(Module module) {
		switch(module.getIri) {
			case "http://purl.org/dc/elements/1.1/": "http://purl.org/dc/elements/1.1"		
			default: module.getIri
		}
	}
	
	def convertSeparator(Module module) {
		switch(module.getIri) {
			case "http://purl.org/dc/elements/1.1/": SeparatorKind.SLASH
			default: SeparatorKind.HASH
		}
	}

	def String convertName(Module module) {
		val name = module.annotations.findFirst[property.getIri == "http://purl.org/dc/elements/1.1/identifier"]?.value?.value
		if (name !== null) {
			return name
		}
		switch(module.getIri) {
			case "http://purl.org/dc/elements/1.1/": "dc"		
			case "http://www.w3.org/1999/02/22-rdf-syntax-ns": "rdf"		
			case "http://www.w3.org/2000/01/rdf-schema": "rdfs"		
			case "http://www.w3.org/2001/XMLSchema": "xsd"		
			default: URI.createURI(module.getIri).lastSegment
		}
	}

	def getReifiedIri(UnreifiedRelationship relationship) {
		relationship.moduleContext.iri()+'#'+relationship.reifiedName
	}

	def getReifiedName(UnreifiedRelationship relationship) {
		relationship.getName.toFirstUpper+'_'
	}

	def getUnreifiedName(ReifiedRelationshipRestriction relationship) {
		relationship.getName.toFirstLower+'_'
	}
	
	def notNull(PositiveIntegerValue value) {
		return value !== null && value.value != 'null'
	}
	
	def convert(PositiveIntegerValue value) {
		return Long.valueOf(value.value)
	}

	def convert(CardinalityRestrictionKind kind) {
		switch (kind) {
			case CardinalityRestrictionKind.EXACT:
				return io.opencaesar.oml.CardinalityRestrictionKind.EXACTLY
			case CardinalityRestrictionKind.MAX:
				return io.opencaesar.oml.CardinalityRestrictionKind.MAX
			case CardinalityRestrictionKind.MIN:
				return io.opencaesar.oml.CardinalityRestrictionKind.MIN
		}
	}

	private def trimExtension(URI uri) {
		var trimmed = uri.trimFileExtension
		if (trimmed.toFileString.endsWith('/')) {
			val s = trimmed.toFileString
			trimmed = URI.createFileURI(s.substring(0, s.length-1))
		}
		return trimmed
	}

	static def isBuiltInOntology(String iri) {
		BUILT_IN_ONTOLOGIES.contains(iri)
	}
}
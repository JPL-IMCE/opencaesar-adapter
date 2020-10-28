package io.opencaesar.legacy2oml

import com.beust.jcommander.IParameterValidator
import com.beust.jcommander.JCommander
import com.beust.jcommander.Parameter
import com.beust.jcommander.ParameterException
import com.google.common.io.CharStreams
import gov.nasa.jpl.imce.oml.dsl.linking.OMLLinkingService
import gov.nasa.jpl.imce.oml.model.common.Extent
import gov.nasa.jpl.imce.oml.model.descriptions.DescriptionBox
import gov.nasa.jpl.imce.oml.model.extensions.OMLExtensions
import gov.nasa.jpl.imce.oml.zip.OMLZipResource
import gov.nasa.jpl.imce.oml.zip.OMLZipResourceSet
import io.opencaesar.oml.Description
import io.opencaesar.oml.SeparatorKind
import io.opencaesar.oml.dsl.OmlStandaloneSetup
import io.opencaesar.oml.util.OmlWriter
import io.opencaesar.oml.util.OmlXMIResourceFactory
import java.io.BufferedReader
import java.io.File
import java.io.FileReader
import java.io.FileWriter
import java.io.IOException
import java.io.InputStreamReader
import java.nio.file.Paths
import java.util.ArrayList
import java.util.Collection
import java.util.Collections
import org.apache.log4j.AppenderSkeleton
import org.apache.log4j.Level
import org.apache.log4j.LogManager
import org.eclipse.emf.common.util.URI
import org.eclipse.xtext.resource.XtextResourceSet

class Legacy2OmlApp {

	package static val OML = 'oml'
	package static val OMLXMI = "omlxmi"
	package static val OMLZIP = "omlzip"

	@Parameter(
		names=#["--input-catalog-path","-i"],
		description="Path to the input legacy OML catalog (Required)",
		validateWith=InputCatalogPath,
		required=true,
		order=2)
	String inputCatalogPath

	@Parameter(
		names=#["--output-catalog-path","-o"],
		description="Path to the output openCAESAR OML catalog (Required)",
		validateWith=OutputCatalogPath,
		required=false,
		order=3)
	String outputCatalogPath

	@Parameter(
		names=#["--output-description-bundle-iri","-b"],
		description="Iri of an OML2 description bundle",
		required=false,
		order=4)
	String outputDescriptionBundleIri = null

	@Parameter(
		names=#["--debug", "-d"],
		description="Shows debug logging statements",
		order=5)
	boolean debug

	@Parameter(
		names=#["--help","-h"],
		description="Displays summary of options",
		help=true,
		order=6) 
	boolean help

	val LOGGER = LogManager.getLogger(Legacy2OmlApp)

	/*
	 * The main method
	 */
	def static void main(String ... args) {
		val app = new Legacy2OmlApp
		val builder = JCommander.newBuilder().addObject(app).build()
		builder.parse(args)
		if (app.help) {
			builder.usage()
			return
		}
		if (app.debug) {
			val appender = LogManager.getRootLogger.getAppender("stdout")
			(appender as AppenderSkeleton).setThreshold(Level.DEBUG)
		}
		app.run()
	}

	/*
	 * The run method
	 */
	def void run() {
		LOGGER.info("=================================================================")
		LOGGER.info("                        S T A R T")
		LOGGER.info("                   Legacy Oml to Oml " + getAppVersion)
		LOGGER.info("=================================================================")
		LOGGER.info("Input Catalog= " + inputCatalogPath)
		LOGGER.info("Output Catalog= " + outputCatalogPath)

		// create the input resource set
		OMLZipResourceSet.doSetup()
		val inputResourceSet = new XtextResourceSet()

		// load the OML1 catalog in the resource set (IMPORTANT)
		val catalogManager = OMLExtensions.getOrCreateCatalogManager(inputResourceSet)
		catalogManager.ignoreMissingProperties = true
		catalogManager.useStaticCatalog = false
		val inputCatalog = OMLExtensions.getCatalog(inputResourceSet)
		val inputCatalogURL = new File(inputCatalogPath).toURI().toURL();
		inputCatalog.parseCatalog(inputCatalogURL)

		// find the input paths supported by the catalog
		val inputCatalogFile = new File(inputCatalogPath)
		val inputFolder = inputCatalogFile.parentFile
		val inputFolderPath = inputFolder.absolutePath
		var inputFiles = collectOMLFiles(inputFolder)

		// Mixed mode: sort the file such that OML files are first before OMLZIP
		inputFiles = inputFiles.sortBy[it.fileExtension]
	    // Mixed mode: initialize  the oml spec tables
	    val omlTables = OMLZipResource.getOrInitializeOMLSpecificationTables(inputResourceSet)

		// load the input models and resolve their references
		for (inputFile : inputFiles) {
			val inputURI = URI.createFileURI(inputFile.absolutePath)
			LOGGER.info("Reading: " + inputURI)
			val inputResource = inputResourceSet.getResource(inputURI, true)
			if (inputResource !== null) {
				// Mixed mode: get the modules and queue them
				val modules = (inputResource.contents.get(0) as Extent).modules
				modules.forEach[omlTables.queueModule(it)]
			}
		}

		// Mixed mode: clear the caches
	    OMLZipResource.clearOMLSpecificationTables(inputResourceSet)
    	OMLLinkingService.clearCache(inputResourceSet)
    	OMLLinkingService.initializeCache(inputResourceSet)

		// load the Oml registries here after the input have been read (since extension "oml" is used by both)
		OmlStandaloneSetup.doSetup
		OmlXMIResourceFactory.register
		val outputResourceSet = new XtextResourceSet

		// output resources
		val outputCatalogFile = new File(outputCatalogPath)
		val outputFolder = outputCatalogFile.parentFile
		val outputFolderPath = outputFolder.absolutePath

		// create the Oml writer
		val writer = new OmlWriter(outputResourceSet)
		writer.start

		val descriptions = new ArrayList<Description>

		// do the actual transformation
		for (inputFile : inputFiles) {
			val inputURI = URI.createFileURI(inputFile.absolutePath)
			val inputResource = inputResourceSet.getResource(inputURI, true)
			val inputIri = (inputResource.contents.get(0) as Extent).modules.get(0).getIri
			if (inputResource !== null && !Legacy2Oml.isBuiltInOntology(inputIri)) {
				var relativePath = inputFolder.toPath().normalize().relativize(inputFile.toPath())
				relativePath = Paths.get(outputFolderPath + File.separator + relativePath.toString).normalize
				var outputResourceURI = URI.createFileURI(relativePath.toString).trimFileExtension
				if (outputResourceURI.toFileString.endsWith(File.separator)) {
					val s = outputResourceURI.toFileString
					outputResourceURI = URI.createFileURI(s.substring(0, s.length - 1))
				}
				val root = inputResource.contents.get(0)
				if (root instanceof Extent) {
					if (root.modules.head instanceof DescriptionBox) {
						outputResourceURI = URI.createFileURI(outputResourceURI.toFileString+'.'+OMLXMI)
					} else {
						outputResourceURI = URI.createFileURI(outputResourceURI.toFileString+'.'+ OML)
					}
				}
				LOGGER.info("Creating: " + outputResourceURI)
				val ontology = new Legacy2Oml(inputResource, outputResourceURI, writer).run
				if (ontology instanceof Description) {
					descriptions.add(ontology)
				}
				
			}
		}

		// create a bundle of all descriptions in the output folder
		if (!descriptions.empty && outputDescriptionBundleIri !== null) {
			var path = inputCatalog.resolveURI(outputDescriptionBundleIri)
			path = path.replaceFirst(inputFolderPath, outputFolderPath)
			val uri = URI.createURI(path)
			LOGGER.info("Creating: " + uri.appendFileExtension(OMLXMI))
			val bundle = writer.createDescriptionBundle(uri.appendFileExtension(OMLXMI), outputDescriptionBundleIri, SeparatorKind.HASH, uri.lastSegment)
			descriptions.forEach[it| writer.addDescriptionBundleInclusion(bundle, it.iri+'.'+OMLXMI, null)]
		}

		// copy the catalog file (and other nested catalog files) before the writer can finish 
		// this is because the finish process may use these catalogs
		val catalogFiles = collectCatalogFiles(inputFolder)
		for (catalogFile : catalogFiles) {
			val outputCatalog = catalogFile.path.replaceFirst(inputFolderPath, outputFolderPath).replace('oml.catalog.xml', 'catalog.xml')
			LOGGER.info("Saving: " + outputCatalog)
			copyCatalog(catalogFile, new File(outputCatalog))
		}

		// finish the Oml writer
		LOGGER.info("Finishing the creation of all models")
		writer.finish

		// save the output resources here instead of calling writer.save in order to log
		for (outputResource : outputResourceSet.resources) {
			if (outputResource.URI.fileExtension == OML || 
				outputResource.URI.fileExtension == OMLXMI) {
				LOGGER.info("Saving: " + outputResource.URI)
				outputResource.save(Collections.EMPTY_MAP)
			}
		}

		LOGGER.info("=================================================================")
		LOGGER.info("                          E N D")
		LOGGER.info("=================================================================")
	}

	private def Collection<File> collectOMLFiles(File f) {
		val omlFiles = new ArrayList
		if (f.isDirectory) {
			for (file : f.listFiles()) {
				if (file.isFile) {
					if (getFileExtension(file) == OML || getFileExtension(file) == OMLZIP) {
						omlFiles.add(file)
					}
				} else if (file.isDirectory) {
					omlFiles.addAll(collectOMLFiles(file))
				}
			}
		} else if (getFileExtension(f) == OML || getFileExtension(f) == OMLZIP) {
			omlFiles += f
		} else {
			var tryFile = new File(f.path+'.'+OML)
			if (tryFile.exists) {
				omlFiles += tryFile
			} else {
				tryFile = new File(f.path+'.'+OMLZIP)
				if (tryFile.exists) {
					omlFiles += tryFile
				}
			}
		}
		return omlFiles
	}

	def Collection<File> collectCatalogFiles(File directory) {
		val catalogFiles = new ArrayList<File>
		for (file : directory.listFiles()) {
			if (file.isFile) {
				if (file.name == 'oml.catalog.xml') {
					catalogFiles.add(file)
				}
			} else if (file.isDirectory) {
				catalogFiles.addAll(collectCatalogFiles(file))
			}
		}
		return catalogFiles
	}

	private def String getFileExtension(File file) {
		val fileName = file.getName()
		if (fileName.lastIndexOf(".") != -1)
			return fileName.substring(fileName.lastIndexOf(".") + 1)
		else
			return ""
	}

	/**
	 * Get application version id from properties file.
	 * @return version string from build.properties or UNKNOWN
	 */
	private def String getAppVersion() {
		var version = "UNKNOWN"
		try {
			val input = Thread.currentThread().getContextClassLoader().getResourceAsStream("version.txt")
			val reader = new InputStreamReader(input)
			version = CharStreams.toString(reader);
		} catch (IOException e) {
			val errorMsg = "Could not read version.txt file." + e
			LOGGER.error(errorMsg, e)
		}
		version
	}

	private static def copyCatalog(File originalCatalog, File newCatalog) {
		originalCatalog.parentFile.mkdirs
		var oldContent = ""
		var BufferedReader reader = null
		var FileWriter writer = null

		try {
			reader = new BufferedReader(new FileReader(originalCatalog))
			var line = reader.readLine()
			while (line !== null) {
				oldContent = oldContent + line + System.lineSeparator()
				line = reader.readLine()
			}
			val newContent = oldContent.replaceAll('file:', '')
			writer = new FileWriter(newCatalog)
			writer.write(newContent)
		} catch (IOException e) {
			e.printStackTrace()
		} finally {
			try {
				// Closing the resources
				reader.close()
				writer.close()
			} catch (IOException e) {
				e.printStackTrace()
			}
		}
	}

	static class InputCatalogPath implements IParameterValidator {
		override validate(String name, String value) throws ParameterException {
			val file = new File(value)
			if (!file.name.endsWith('catalog.xml')) {
				throw new ParameterException("Parameter " + name + " should be a valid legacy OML catalog path")
			}
		}
	}

	static class OutputCatalogPath implements IParameterValidator {
		override validate(String name, String value) throws ParameterException {
			val file = new File(value)
			if (!file.name.endsWith('catalog.xml')) {
				throw new ParameterException("Parameter " + name + " should be a valid legacy OML catalog path")
			}
			val directory = file.parentFile
			if (!directory.exists) {
				val created = directory.mkdirs
				if (!created) {
					throw new ParameterException("Parameter " + name + " should be a valid openCAESAR catalog path")
				}
			}
		}
	}

}

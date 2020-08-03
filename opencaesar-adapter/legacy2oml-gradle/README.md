# Legacy to OML

[ ![Download](https://api.bintray.com/packages/jpl-imce/opencaesar-adapter/legacy2oml-gradle/images/download.svg) ](https://bintray.com/jpl-imce/opencaesar-adapter/legacy2oml-gradle/_latestVersion)

A tool to translate ontologies from Legacy OML to openCAESAR OML

## Run as Gradle Task
In a build.gradle script, use:
```
buildscript {
    repositories {
		maven { url 'https://dl.bintray.com/jpl-imce/opencaesar-adapter' }
        mavenCentral()
        jcenter()
    }
    dependencies {
		classpath 'io.opencaesar.legacy:legacy2oml-gradle:+'
    }
}
task legacy2oml(type:Legacy2OmlTask) {
	inputCatalogPath = file('path/to/input/legacy/oml/catalog.xml') [Required]
	outputCatalogPath = file('path/to/output/opencaesar/oml/catalog.xml') [Required]
	descriptionBundleIri = 'iri-of-opencaesar-description-bundle' [Optional]
}
```
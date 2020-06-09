# adapters.opencaesar

[![Build Status](https://travis-ci.org/JPL-IMCE/opencaesar-adapter.svg?branch=master)](https://travis-ci.org/JPL-IMCE/opencaesar-adapter)
[ ![Download](https://api.bintray.com/packages/jpl-imce/opencaesar-adapter/legacy2oml/images/download.svg) ](https://bintray.com/jpl-imce/opencaesar-adapter/legacy2oml/_latestVersion)

Adapter from legacy OML to OpenCAESAR OML

## Documentation

The documentation of the mapping is provided [here](docs/Legacy-to-New-OML-Mapping.md)

## Clone
```
    git clone https://github.com/jpl-imce/opencaesar-adapter.git
    cd opencaesar-adapter
```
      
## Build
Requirements: java 8 
```
    cd legacy2oml
    ./gradlew clean build
```

## Run as CLI

MacOS/Linux:
```
    ./gradlew run --args="-i path/to/legacy/oml/folder -c path/to/legacy/oml/catalog -o path/to/opencaesar/oml/folder"
```
Windows:
```
    gradlew.bat run --args="-i path/to/legacy/oml/folder -c path/to/legacy/oml/catalog -o path/to/opencaesar/oml/folder"
```

Add the "-b description-bundle-iri" parameter to additionally generate a description bundle importing all descriptions.

Run with -h to see other parameter options.

## Run from Gradle

Install it in your local maven repo
```
    ./gradlew install
```
In a gradle.build script, add the following:
```
buildscript {
	repositories {
		mavenLocal()
		maven { url 'https://dl.bintray.com/jpl-imce/opencaesar-adapter' }
		maven { url 'https://dl.bintray.com/opencaesar/oml' }
		maven { url 'https://dl.bintray.com/jpl-imce/gov.nasa.jpl.imce.oml' }
	}
	dependencies {
		classpath 'io.opencaesar.legacy:legacy2oml:+'
	}
}

apply plugin: 'io.opencaesar.legacy2oml'

legacy2oml {
	inputPath = 'path/to/legacy/oml/folder'
	catalogPath = 'path/to/legacy/oml/catalog'
	outputPath = 'path/to/opencaesar/oml/folder'
	//descriptionBundleIri = 'http://europa.jpl.nasa.gov/bundle/system'
}

task build {
	dependsOn generateOml
}

task clean(type: Delete) {
	delete 'path/to/opencaesar/oml/folder'
}
```



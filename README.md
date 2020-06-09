# adapters.opencaesar
Adapter from legacy OML to OpenCAESAR Oml

[![Build Status](https://cae-jenkins2.jpl.nasa.gov/buildStatus/icon?job=IMCE%2Fgov.nasa.jpl.imce.caesar.adapter.opencaesar%2Fmaster)](https://cae-jenkins2.jpl.nasa.gov/job/IMCE/job/gov.nasa.jpl.imce.caesar.adapter.opencaesar/job/master/)

## Documentation

The documentation of the mapping is provided [here](https://github.jpl.nasa.gov/imce-caesar/adapters.opencaesar/blob/master/docs/Legacy-to-New-OML-Mapping.md)

## Clone
```
    git clone https://github.jpl.nasa.gov/imce-caesar/adapters.opencaesar.git
    cd adapters.opencaesar
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



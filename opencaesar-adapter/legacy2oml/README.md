# Legacy to OML

[ ![Download](https://api.bintray.com/packages/jpl-imce/opencaesar-adapter/legacy2oml/images/download.svg) ](https://bintray.com/jpl-imce/opencaesar-adapter/legacy2oml/_latestVersion)

A tool to translate ontologies from Legacy OML to openCAESAR OML

## Run as CLI

MacOS/Linux:
```
    ./gradlew run --args="-i path/to/legacy/oml/folder -c path/to/legacy/oml/catalog -o path/to/opencaesar/oml/folder"
```
Windows:
```
    gradlew.bat run --args="-i path/to/legacy/oml/folder -c path/to/legacy/oml/catalog -o path/to/opencaesar/oml/folder"
```
Args:
```
--input-catalog-path | -i path/to/input/legacy/oml/catalog.xml [Required]
--output-catalog-path | -o path/to/output/opencaesar/oml/catalog.xml [Required]
--output-description-bundle-iri | -b iri-of-opencaesar-description-bundle [Optional]
```

## [Run as Gradle Task](../legacy2oml-gradle/README.md)
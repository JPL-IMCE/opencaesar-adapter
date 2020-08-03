package io.opencaesar.legacy2oml

import java.util.ArrayList
import org.gradle.api.DefaultTask
import org.gradle.api.tasks.TaskAction

class Legacy2OmlTask extends DefaultTask {

	public var String inputCatalogPath

	public var String outputCatalogPath

	public var String descriptionBundleIri
	
    @TaskAction
    def run() {
        val args = new ArrayList
        if (inputCatalogPath !== null) {
		    args += #["-i", inputCatalogPath]
        }
        if (outputCatalogPath !== null) {
		    args += #["-o", outputCatalogPath]
        }
	    if (descriptionBundleIri !== null) {
		    args += #["-b", descriptionBundleIri]
	    }
        Legacy2OmlApp.main(args)
	}
    
}
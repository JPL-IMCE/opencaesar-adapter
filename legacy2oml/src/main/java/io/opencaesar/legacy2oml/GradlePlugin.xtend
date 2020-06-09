package io.opencaesar.legacy2oml

import java.util.ArrayList
import org.gradle.api.Plugin
import org.gradle.api.Project

class GradlePlugin implements Plugin<Project> {
	
    override apply(Project project) {
    	val ^extension = project.extensions.create('legacy2oml', Oml2OwlExtension)
        project.getTasks().create("generateOml").doLast [
	        val args = new ArrayList
		    args += #["-i", project.file(^extension.inputPath).absolutePath]
		    args += #["-c", project.file(^extension.catalogPath).absolutePath]
		    args += #["-o", project.file(^extension.outputPath).absolutePath]
		    if (^extension.descriptionBundleIri !== null) {
			    args += #["-b", ^extension.descriptionBundleIri]
		    }
	        App.main(args)
        ]
   }
    
}

class Oml2OwlExtension {
	public var String inputPath
	public var String catalogPath
	public var String outputPath
	public var String descriptionBundleIri
}
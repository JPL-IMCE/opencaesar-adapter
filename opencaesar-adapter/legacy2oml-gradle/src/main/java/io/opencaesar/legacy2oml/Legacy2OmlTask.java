package io.opencaesar.legacy2oml;

import java.util.ArrayList;
import java.util.List;

import org.gradle.api.DefaultTask;
import org.gradle.api.tasks.TaskAction;
import org.gradle.api.tasks.TaskExecutionException;

public class Legacy2OmlTask extends DefaultTask {

	public String inputCatalogPath;

	public String outputCatalogPath;

	public String outputDescriptionBundleIri;
	
    @TaskAction
    public void run() {
		List<String> args = new ArrayList<String>();
        if (inputCatalogPath != null) {
			args.add("-i");
			args.add(inputCatalogPath);
        }
        if (outputCatalogPath != null) {
			args.add("-o");
			args.add(outputCatalogPath);
        }
	    if (outputDescriptionBundleIri != null) {
			args.add("-b");
			args.add(outputDescriptionBundleIri);
	    }
	    try {
        	Legacy2OmlApp.main(args.toArray(new String[0]));
		} catch (Exception e) {
			throw new TaskExecutionException(this, e);
		}
	}
    
}
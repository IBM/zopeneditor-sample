@groovy.transform.BaseScript com.ibm.dbb.groovy.ScriptLoader baseScript
import com.ibm.dbb.repository.*
import com.ibm.dbb.dependency.*
import com.ibm.dbb.build.*
import groovy.transform.*
import groovy.json.JsonSlurper

// define script properties
@Field BuildProperties props = BuildProperties.getInstance()

def listFiles(String dir, String includeFileList, String excludeFileList) {
	List<String> fileList = []

	def files = new FileNameFinder().getFileNames(dir, includeFileList, excludeFileList)
		files.each { file ->
			fileList << file
	}
	
	return fileList
}

/*
 * createDependencyResolver - Creates a dependency resolver using resolution rules declared
 * in a file property.
 */
def createDependencyResolver(String buildFile, String sourceDir, String rules) {
	// create a dependency resolver for the build file
	DependencyResolver resolver = new DependencyResolver().sourceDir(sourceDir)
														  .file(buildFile)
														  .scanner(new DependencyScanner())
	
	// add resolution rules for buildFile
	if (rules) {
		JsonSlurper slurper = new groovy.json.JsonSlurper()
		List jsonRules = slurper.parseText(rules)
		if (jsonRules) {
			jsonRules.each { jsonRule ->
				ResolutionRule resolutionRule = new ResolutionRule()
				resolutionRule.library(jsonRule.library)
				resolutionRule.lname(jsonRule.lname)
				resolutionRule.category(jsonRule.category)
				if (jsonRule.searchPath) {
					jsonRule.searchPath.each { jsonPath ->
						DependencyPath dependencyPath = new DependencyPath()
						dependencyPath.collection(jsonPath.collection)
						dependencyPath.sourceDir(jsonPath.sourceDir)
						dependencyPath.directory(jsonPath.directory)
						resolutionRule.path(dependencyPath)
					}
				}
				resolver.rule(resolutionRule)
			}
		}
	}
	
	return resolver
}

def updateBuildResult(Map args) {
	// args : errorMsg, logs[logName:logFile], client:repoClient
	
	if (args.client) {
		def buildResult = args.client.getBuildResult(props.projectBuildGroup, props.projectBuildLabel)
		if (!buildResult) {
			println "*! No build result found for BuildGroup '${props.projectBuildGroup}' and BuildLabel '${props.projectBuildLabel}'"
			return
		}
		
		// add error message
		if (args.errorMsg) {
			buildResult.setStatus(buildResult.ERROR)
			buildResult.addProperty("error", args.errorMsg)

		}
		
		// add logs
		if (args.logs) {
			args.logs.each { logName, logFile ->
				if (logFile)
					buildResult.addAttachment(logName, new FileInputStream(logFile))
			}
		}
		
		// save result
		buildResult.save()
	}
}



/*
 * isCICS - tests to see if the program is a CICS program. If the logical file is false, then
 * check to see if there is a file property.
 */
def isCICS(LogicalFile logicalFile) {
	boolean isCICS = logicalFile.isCICS()
	if (!isCICS) {
		String cicsFlag = props.getFileProperty('isCICS', logicalFile.getFile())
		if (cicsFlag)
			isCICS = cicsFlag.toBoolean()
	}
	
	return isCICS
}

/*
 * isSQL - tests to see if the program is an SQL program. If the logical file is false, then
 * check to see if there is a file property.
 */
def isSQL(LogicalFile logicalFile) {
	boolean isSQL = logicalFile.isSQL()
	if (!isSQL) {
		String sqlFlag = props.getFileProperty('isSQL', logicalFile.getFile())
		if (sqlFlag)
			isSQL = sqlFlag.toBoolean()
	}
	
	return isSQL
}

/*
 * isDLI - tests to see if the program is a DL/I program. If the logical file is false, then
 * check to see if there is a file property.
 */
def isDLI(LogicalFile logicalFile) {
	boolean isDLI = logicalFile.isDLI()
	if (!isDLI) {
		String dliFlag = props.getFileProperty('isDLI', logicalFile.getFile())
		if (dliFlag)
			isDLI = dliFlag.toBoolean()
	}
	
	return isDLI
}

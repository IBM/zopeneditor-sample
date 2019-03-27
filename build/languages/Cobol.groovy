@groovy.transform.BaseScript com.ibm.dbb.groovy.ScriptLoader baseScript
import com.ibm.dbb.repository.*
import com.ibm.dbb.dependency.*
import com.ibm.dbb.build.*
import groovy.transform.*


// define script properties
@Field BuildProperties props = BuildProperties.getInstance()
@Field HashSet<String> copiedFileCache = new HashSet<String>()
@Field def buildUtils= loadScript(new File("${props.relengDir}/utilities/BuildUtilities.groovy"))

@Field RepositoryClient repositoryClient

println("** Building files mapped to ${this.class.getName()}.groovy script")

// verify required build properties
verifyBuildProperties()

// sort the build list based on build file rank
List<String> sortedList = sortBuildList(argMap.buildList)

// iterate through build list
sortedList.each { buildFile ->
	println "*** Building file ${props.project}/$buildFile"

	// copy build file and dependency files to data sets
	String rules = props.getFileProperty('cobolResolutionRules', buildFile)
	DependencyResolver dependencyResolver = buildUtils.createDependencyResolver(buildFile, props.project, rules)
    copySourceFiles(buildFile, dependencyResolver)

	// create mvs commands
	LogicalFile logicalFile = dependencyResolver.getLogicalFile()
	String member = CopyToPDS.createMemberName(buildFile)
	File logFile = new File("${props.outDir}/${member}.log")
	MVSExec compile = createCompileCommand(buildFile, logicalFile, member, logFile)
	MVSExec linkEdit = createLinkEditCommand(buildFile, logicalFile, member, logFile)

	// execute mvs commands in a mvs job
	MVSJob job = new MVSJob()
	job.start()

	// compile the cobol program
	int rc = compile.execute()

	if (rc > props.cobolCompileMaxRC.toInteger()) {
		String errorMsg = "*! The compile return code (${rc}) for ${buildFile} exceeded the maximum return code allowed (${props.cobolCompileMaxRC})"
		println(errorMsg)
		props.error = "true"
		buildUtils.updateBuildResult(errorMsg:errorMsg,logs:["${member}.log":logFile],client:getRepositoryClient())
	}
	else {
	// if this program needs to be link edited . . .
		String needsLinking = props.getFileProperty('cobolLinkEdit', buildFile)
		if (needsLinking.toBoolean()) {
			rc = linkEdit.execute()

			if (rc > props.cobolLinkEditMaxRC.toInteger()) {
				String errorMsg = "*! The link edit return code (${rc}) for ${buildFile} exceeded the maximum return code allowed (${props.cobolCompileMaxRC})"
				println(errorMsg)
				props.error = "true"
				buildUtils.updateBuildResult(errorMsg:errorMsg,logs:["${member}.log":logFile],client:getRepositoryClient())
			}
			else {
				// process load module for static link dependencies
				saveStaticLinkDependencies(buildFile, props.cobolLoadPDS, logicalFile)
			}
		}

	}


	// clean up passed DD statements
	job.stop()
}

// end script


//********************************************************************
//* Method definitions
//********************************************************************

/*
 * verifyBuildProperties - verify that required build properties exist
 */
def verifyBuildProperties() {
	String[] buildProps = ['project','hlq','outDir',
		                   'cobolSrcPDS','cobolCpyPDS','cobolObjPDS','cobolLoadPDS','cobolDBRMPDS',
		                   'cobolCompileCICSParms','cobolCompileSQLParms','cobolCompileErrorPrefixParms',
                           'cobolCompiler','cobolLinkEditor','cobolTempOptions','projectOutputsCollectionName',
						   'SDFHCOB','SDFHLOAD','SDSNLOAD','SCEELKED']

	buildProps.each { buildProp ->
		assert props."$buildProp" : "Missing build property $buildProp"
	}

}

/*
 * copySourceFiles - copies both the program being built and the program
 * dependencies from USS directories to data sets for compilation and link edit
 */
def copySourceFiles(String buildFile, DependencyResolver dependencyResolver) {
	String buildFileLoc = "${props.project}/$buildFile"

	// only copy the build file once
	if (!copiedFileCache.contains(buildFileLoc)) {
		copiedFileCache.add(buildFileLoc)
		new CopyToPDS().file(new File(buildFileLoc))
		               .dataset(props.cobolSrcPDS)
					   .member(CopyToPDS.createMemberName(buildFile))
					   .execute()
	}

	// resolve the logical dependencies to physical files to copy to data sets
	List<PhysicalDependency> physicalDependencies = dependencyResolver.resolve()
	physicalDependencies.each { physicalDependency ->
		if (physicalDependency.isResolved()) {
			String physicalDependencyLoc = "${physicalDependency.getSourceDir()}/${physicalDependency.getFile()}"

			// only copy the dependency file once per script invocation
			if (!copiedFileCache.contains(physicalDependencyLoc)) {
				copiedFileCache.add(physicalDependencyLoc)
				new CopyToPDS().file(new File(physicalDependencyLoc))
							   .dataset(props.cobolCpyPDS)
							   .member(CopyToPDS.createMemberName(physicalDependency.getFile()))
							   .execute()
			}
		}
	}
}


/*
 * createCobolParms - Builds up the COBOL compiler parameter list from build and file properties
 */
def createCobolParms(String buildFile, LogicalFile logicalFile) {
	def parameters = props.getFileProperty('cobolCompileParms', buildFile) ?: ""

	if (buildUtils.isCICS(logicalFile))
		parameters = "$parameters,${props.cobolCompileCICSParms}"

	if (buildUtils.isSQL(logicalFile))
		parameters = "$parameters,${props.cobolCompileSQLParms}"

	if (props.errPrefix)
		parameters = "$parameters,${props.cobolCompileErrorPrefixParms}"

	if (parameters.startsWith("'"))
		parameters = parameters.drop(1)

	return parameters
}

/*
 * createCompileCommand - creates a MVSExec command for compiling the COBOL program (buildFile)
 */
def createCompileCommand(String buildFile, LogicalFile logicalFile, String member, File logFile) {
	String parameters = createCobolParms(buildFile, logicalFile)

	// define the MVSExec command to compile the program
	MVSExec compile = new MVSExec().file(buildFile).pgm(props.cobolCompiler).parm(parameters)

	// add DD statements to the compile command
	compile.dd(new DDStatement().name("SYSIN").dsn("${props.cobolSrcPDS}($member)").options('shr').report(true))
	compile.dd(new DDStatement().name("SYSPRINT").options(props.cobolTempOptions))
	compile.dd(new DDStatement().name("SYSMDECK").options(props.cobolTempOptions))
	[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17].each { num ->
		compile.dd(new DDStatement().name("SYSUT$num").options(props.cobolTempOptions))
	}

	// Write SYSLIN to temporary dataset if performing link edit
	String doLinkEdit = props.getFileProperty('cobolLinkEdit', buildFile)
	if (doLinkEdit && doLinkEdit.toBoolean())
		compile.dd(new DDStatement().name("SYSLIN").dsn("&&TEMPOBJ").options(props.cobolTempOptions).pass(true))
	else
		compile.dd(new DDStatement().name("SYSLIN").dsn("${props.cobolObjPDS}($member)").options('shr').output(true))

	// add a syslib to the compile command with bms output copybook and optional CICS concatenation
	compile.dd(new DDStatement().name("SYSLIB").dsn(props.cobolCpyPDS).options("shr"))
	// compile.dd(new DDStatement().dsn(props.bmsCpyPDS).options("shr"))
	if (buildUtils.isCICS(logicalFile))
		compile.dd(new DDStatement().dsn(props.SDFHCOB).options("shr"))

	// add a tasklib to the compile command with optional CICS, DB2, and IDz concatenations
	String compilerVer = props.getFileProperty('cobolCompilerVersion', buildFile)
	compile.dd(new DDStatement().name("TASKLIB").dsn(props."SIGYCOMP_$compilerVer").options("shr"))
	if (buildUtils.isCICS(logicalFile))
		compile.dd(new DDStatement().dsn(props.SDFHLOAD).options("shr"))
	if (buildUtils.isSQL(logicalFile))
		compile.dd(new DDStatement().dsn(props.SDSNLOAD).options("shr"))
	if (props.SFELLOAD)
		compile.dd(new DDStatement().dsn(props.SFELLOAD).options("shr"))

	// add optional DBRMLIB if build file contains DB2 code
	if (buildUtils.isSQL(logicalFile))
		compile.dd(new DDStatement().name("DBRMLIB").dsn("$props.cobolDBRMPDS($member)").options('shr').output(true).deployType('DBRM'))

	// add IDz User Build Error Feedback DDs
	if (props.errPrefix) {
		compile.dd(new DDStatement().name("SYSADATA").options("DUMMY"))
		compile.dd(new DDStatement().name("SYSXMLSD").dsn("${props.hlq}.${props.errPrefix}.SYSXMLSD.XML").options('mod keep'))
	}

	// add a copy command to the compile command to copy the SYSPRINT from the temporary dataset to an HFS log file

	compile.copy(new CopyToHFS().ddName("SYSPRINT").file(logFile).hfsEncoding(props.logEncoding))

	return compile
}


/*
 * createLinkEditCommand - creates a MVSExec xommand for link editing the COBOL object module produced by the compile
 */
def createLinkEditCommand(String buildFile, LogicalFile logicalFile, String member, File logFile) {
	String parameters = props.getFileProperty('cobolLinkEditParms', buildFile)

	// define the MVSExec command to link edit the program
	MVSExec linkedit = new MVSExec().file(buildFile).pgm(props.cobolLinkEditor).parm(parameters)

	// add DD statements to the linkedit command
	linkedit.dd(new DDStatement().name("SYSLMOD").dsn("${props.cobolLoadPDS}($member)").options('shr').output(true).deployType('LOAD'))
	linkedit.dd(new DDStatement().name("SYSPRINT").options(props.cobolTempOptions))
	linkedit.dd(new DDStatement().name("SYSUT1").options(props.cobolTempOptions))

	// add a syslib to the compile command with optional CICS concatenation
	linkedit.dd(new DDStatement().name("SYSLIB").dsn(props.cobolObjPDS).options("shr"))
	linkedit.dd(new DDStatement().dsn(props.SCEELKED).options("shr"))
    if (buildUtils.isCICS(logicalFile))
		linkedit.dd(new DDStatement().dsn(props.SDFHLOAD).options("shr"))

	// add a copy command to the linkedit command to append the SYSPRINT from the temporary dataset to the HFS log file
	linkedit.copy(new CopyToHFS().ddName("SYSPRINT").file(logFile).hfsEncoding(props.logEncoding).append(true))

	return linkedit
}

/*
 * saveStaticLinkDependencies - Scan the load module to determine LINK dependencies. Impact resolver can use
 * these to determine that this file gets rebuilt if a LINK dependency changes.
 */
def saveStaticLinkDependencies(String buildFile, String loadPDS, LogicalFile logicalFile) {
	// only scan the load module if load module scanning turned on and there is a repository connection
	if (props.cobolScanLoadModule.toBoolean() && getRepositoryClient()) {
		LinkEditScanner scanner = new LinkEditScanner()
		LogicalFile scannerLogicalFile = scanner.scan(buildFile, loadPDS)

		// overwrite original logicalDependencies with load module dependencies
		logicalFile.setLogicalDependencies(scannerLogicalFile.getLogicalDependencies())

		// create the outputs collection if needed.
		if (!repositoryClient.collectionExists("${props.projectOutputsCollectionName}")) {
			repositoryClient.createCollection("${props.projectOutputsCollectionName}")
		}

		// Store logical file and indirect dependencies to the outputs collection
		repositoryClient.saveLogicalFile("${props.projectOutputsCollectionName}", logicalFile );
	}
}


def sortBuildList(List<String> buildList) {
	List<String> sortedList = []
	TreeMap<Integer,List<String>> rankings = new TreeMap<Integer,List<String>>()
	List<String> unranked = new ArrayList<String>()

	// sort buildFiles by rank
	buildList.each { buildFile ->
		String rank = props.getFileProperty('cobolFileBuildRank', buildFile)
		if (rank) {
			Integer rankNum = rank.toInteger()
			List<String> ranking = rankings.get(rankNum)
			if (!ranking) {
				ranking = new ArrayList<String>()
				rankings.put(rankNum,ranking)
			}
			ranking << buildFile
		}
		else {
			unranked << buildFile
		}
	}

	// loop through rank keys adding sub lists (TreeMap automatically sorts keySet)
	rankings.keySet().each { key ->
		List<String> ranking = rankings.get(key)
		if (ranking)
			sortedList.addAll(ranking)
	}

	// finally add unranked buildFiles
	sortedList.addAll(unranked)

	return sortedList
}

def getRepositoryClient() {
	if (!repositoryClient && props."dbb.RepositoryClient.url")
		repositoryClient = new RepositoryClient().forceSSLTrusted(true)

	return repositoryClient
}

@groovy.transform.BaseScript com.ibm.dbb.groovy.ScriptLoader baseScript
import com.ibm.dbb.repository.*
import com.ibm.dbb.dependency.*
import com.ibm.dbb.build.*
import com.ibm.dbb.build.report.*
import com.ibm.dbb.build.html.*
import groovy.util.*
import groovy.transform.*
import groovy.time.*


// define script properties
@Field BuildProperties props = BuildProperties.getInstance()
@Field def gitUtils= loadScript(new File("utilities/GitUtilities.groovy"))
@Field def buildUtils= loadScript(new File("utilities/BuildUtilities.groovy"))

// start time message
def startTime = new Date()
props.startTime = startTime.format("yyyyMMdd.hhmmss.mmm")
println("** Build start at $props.startTime")

// parse incoming options and arguments
def opts = parseArgs(args)

// build properties initial set
populateBuildProperties(opts)

// verify required build properties
verifyBuildProperties()

// initialize build
initializeBuildProcess()

// create build list
List<String> buildList = createBuildList(opts)

// run the build process
def processCounter = 0
if (buildList.size() == 0)
	println("** No files in build list.  Nothing to build.")
else {
	println("** Invoking build scripts according to build order: ${props.buildOrder}")
	String[] buildOrder = props.buildOrder.split(',')
	buildOrder.each { script ->
		// Use the ScriptMappings class to get the files mapped to the build script
		def buildFiles = ScriptMappings.getMappedList(script, buildList)
		runScript(new File("languages/${script}"), ['buildList':buildFiles])
		processCounter = processCounter + buildFiles.size()
	}
}

// store results and print final messages
finalizeBuildProcess(start:startTime, count:processCounter)

// if error signal process error for Jenkins to record failed build
if (props.error)
	System.exit(1)
// end script


//********************************************************************
//* Method definitions
//********************************************************************

def parseArgs(String[] arguments) {
	String usage = 'build.groovy [options] buildfile'
	String header =  '''buildFile (optional):  Relative path of the file in the project to build. If file
    is *.txt then assumed to be buildlist file containing a list of files to build. If buildfile omitted then incremental build 
    is performed.
	'''
	
	def cli = new CliBuilder(usage:usage,header:header)
	// sandbox arguments 
	cli.w(longOpt:'workDir', args:1, required:true, 'Absolute path to the build output directory')
	cli.q(longOpt:'hlq', args:1, required:true, 'High level qualifier for partition data sets')
	
	// project arguments
	cli.proj(longOpt:'project', args:1, required:true, 'Project directory name')
	cli.enc(longOpt:'logEncoding', args:1, 'Encoding of output logs. Default is EBCDIC')
	cli.f(longOpt:'fullBuild', 'Flag indicating to build all programs in project')
	cli.c(longOpt:'scanBuild', 'Flag indicating to only scan files in project')
	
	// web application credentials (overrides build.properties)
	cli.r(longOpt:'url', args:1, 'DBB repository URL')
	cli.i(longOpt:'id', args:1, 'DBB repository id')
	cli.pw(longOpt:'pw', args:1,  'DBB password')
	cli.pf(longOpt:'pwFile', args:1, 'Absolute or relative (from sourceDir) path to file containing DBB password')
	
	// IDz/ZOD User build options
	cli.u(longOpt:'userBuild', 'Flag indicating running a user build')
	cli.err(longOpt:'errPrefix', args:1, 'Unique id used for IDz error message datasets')
	
	// utility options
	cli.h(longOpt:'help', 'Prints this message')

	def opts = cli.parse(arguments)
	if (opts.h) { // if help option used, print usage and exit
		 cli.usage()
		System.exit(0)
	}

return opts
}


def populateBuildProperties(opts) {
	
	// set required command line arguments
	props.workDir = opts.w
	props.hlq = opts.q
	props.project = opts.proj
	
	// load all property files in project/conf
	String projectConf = "${props.project}/build/conf"
	propFiles = buildUtils.listFiles(projectConf, '**/*.properties', null)
	propFiles.each { propFile ->
		props.load(new File(propFile))
	}
	
	// set optional command line arguments
	if (opts.enc) props.logEncoding = opts.enc
	if (opts.f) props.fullBuild = 'true'
	if (opts.c) props.scanBuild = 'true'
	if (opts.err) props.errPrefix = opts.err
	if (opts.u) props.userBuild = 'true'
	
	// override default properties 
	if (opts.r) props.'dbb.RepositoryClient.url' = opts.r
	if (opts.i) props.'dbb.RepositoryClient.userId' = opts.i
	if (opts.pw) props.'dbb.RepositoryClient.password' = opts.pw
	if (opts.pf) props.'dbb.RepositoryClient.passwordFile' = opts.pf
	
	// set calculated properties
	props.relengDir = getScriptDir()
	props.projectName = new File(props.project).getName()
	
	String currentBranch = gitUtils.getCurrentGitBranch(props.project)
	props.projectBuildGroup = "${props.projectName}_${currentBranch}" as String
	props.projectBuildLabel = "build.${props.startTime}" as String
	props.projectCollectionName = "${props.projectName}_${currentBranch}" as String
	props.projectOutputsCollectionName = "${props.projectName}_${currentBranch}_outputs" as String
	props.outDir = "${props.workDir}/${props.projectBuildLabel}" as String
	
	println(props.list())
}

/*
 * verifyBuildProperties - verify that required build properties exist
 */
def verifyBuildProperties() {
	String[] buildProps = ['projectName','project','hlq','workDir', 'buildOrder']
	
	buildProps.each { buildProp ->
		assert props."$buildProp" : "Missing build property $buildProp"
	}
	
}

def initializeBuildProcess() {
	// create the work directory (build output)
	new File(props.outDir).mkdirs()
	println("** Build output located at ${props.outDir}")
	
	// create build data sets required by each language script
	['assembler','bms','cobol','linkedit','pli'].each { lang ->
		if (props."${lang}SrcDatasets")
			createDatasets(props."${lang}SrcDatasets".split(','), props."${lang}SrcOptions")
		
		if (props."${lang}LoadDatasets")
			createDatasets(props."${lang}LoadDatasets".split(','), props."${lang}LoadOptions")
	}
	
	// create a repository client for this script
	if (props."dbb.RepositoryClient.url") {
		repositoryClient = new RepositoryClient().forceSSLTrusted(true)
	}

	// initialize build report
	BuildReportFactory.createDefaultReport()

	// initialize build result (requires repository connection)
	if (repositoryClient) {
		def buildResult = repositoryClient.createBuildResult(props.projectBuildGroup, props.projectBuildLabel)
		buildResult.setState(buildResult.PROCESSING)
		buildResult.save()
		props.buildResultUrl = buildResult.getUrl()
		println("** Build result created at ${props.buildResultUrl}")
	}

}

def createDatasets(String[] datasets, String options) {
	if (datasets && options) {
		datasets.each { dataset ->
			new CreatePDS().dataset(dataset.trim()).options(options.trim()).create()
		}
	}
}

/*
* createBuildList - creates the list of programs to build. Four scenarios are supported:
*   - full build : Builds all programs in project. Use script option --fullBuild
*   - single program : Builds one program. Provide a build file argument.
*   - program list : Builds a list of programs from a text file. Provide a *.txt build file argument.
*   - incremental build : Builds impacted programs from changed files.  Leave off build file.
*/
def createBuildList(opts) {
	List<String> buildList = []
	
	// check for full build
	if (props.fullBuild) {
		List<String> fileList = buildUtils.listFiles(props.project, '**/*.*', props.excludeFileList)	
		
		// need to convert to relative files
		File project = new File(props.project)
		fileList.each { file ->
			buildList << project.toURI().relativize(new File(file).toURI()).getPath()
		}	
	}
	// check if a build file argument exists
	else if (opts.arguments()) {
		println "Building '$opts.arguments()[0]"
		if (opts.arguments()[0].endsWith(".txt")) {
			buildList = new File(opts.arguments()[0]) as List<String>
		}
		else {
			buildList = [opts.arguments()[0].trim()]
		}
	}
	// else perform incremental build i.e. impact analysis to get buildList
	else {
		println "*** Need to implement incremental build!"
	}
	
	return buildList
}

def finalizeBuildProcess(Map args) {
	// generate build report
	def jsonOutputFile = new File("${props.outDir}/BuildReport.json")
	def htmlOutputFile = new File("${props.outDir}/BuildReport.html")

	// create build report data file
	def buildReportEncoding = "UTF-8"
	def buildReport = BuildReportFactory.getBuildReport()
	buildReport.save(jsonOutputFile, buildReportEncoding)

	// create build report html file
	def htmlTemplate = null  // Use default HTML template.
	def css = null       // Use default theme.
	def renderScript = null  // Use default rendering.
	def transformer = HtmlTransformer.getInstance()
	transformer.transform(jsonOutputFile, htmlTemplate, css, renderScript, htmlOutputFile, buildReportEncoding)
	
	// update build result
	if (repositoryClient) {
		def buildResult = repositoryClient.getBuildResult(props.projectBuildGroup, props.projectBuildLabel) 
		buildResult.setBuildReport(new FileInputStream(htmlOutputFile))
		buildResult.setBuildReportData(new FileInputStream(jsonOutputFile))
		buildResult.setProperty("filesProcessed", String.valueOf(args.count))
		buildResult.setState(buildResult.COMPLETE)
		buildResult.save()
	}
	
	// print end build message
	def endTime = new Date()
	def duration = TimeCategory.minus(endTime, args.start)
	def state = (props.error) ? "ERROR" : "CLEAN"
	println("** Build ended at $endTime")
	println("** Build State : $state")
	println("** Total files processed : ${args.count}")
	println("** Total build time  : $duration\n")
}




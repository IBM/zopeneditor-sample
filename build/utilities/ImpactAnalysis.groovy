@groovy.transform.BaseScript com.ibm.dbb.groovy.ScriptLoader baseScript
import com.ibm.dbb.repository.*
import com.ibm.dbb.dependency.*
import com.ibm.dbb.build.*
import groovy.util.*
import groovy.transform.*

// define script properties
@Field BuildProperties props = BuildProperties.getInstance()
@Field def gitUtils= loadScript(new File("GitUtilities.groovy"))
@Field def buildUtils= loadScript(new File("BuildUtilities.groovy"))
@Field File impactsFile = new File("${props.outDir}/impacts.txt")

// start message
println "** Starting impact analysis"

verifyInputs()

Map<String,String> lastBuildHashes = retrieveLastBuildHashes()

Map<String,String> currentHashes = retrieveCurrentHashes()

Map<String,String> currentBranches = retrieveCurrentBranches()

Map<String,List<String> changedFiles = calculateChangedFiles()

updateCollections(changedFiles, currentBranches)

List<String> buildList = calculateBuildList(changedFiles)

// write build list to file

println "** End impact analysis"



// end script


//********************************************************************
 //* Method definitions
 //********************************************************************

/*
 * verifyInputs - verify required build properties and passed arguments
 */
def verifyInputs() {
	String[] buildProps = ['projectName','project','hlq','workDir']
	
	buildProps.each { buildProp ->
		assert props."$buildProp" : "Missing build property $buildProp"
	}
	
}
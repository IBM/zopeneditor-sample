/*******************************************************************************
 * Licensed Materials - Property of IBM
 * (C) Copyright IBM Corporation 2021. All Rights Reserved.
 *
 * Note to U.S. Government Users Restricted Rights:
 * Use, duplication or disclosure restricted by GSA ADP Schedule
 * Contract with IBM Corp.
 *******************************************************************************/

@groovy.transform.BaseScript com.ibm.dbb.groovy.ScriptLoader baseScript
import com.ibm.dbb.build.*
import com.ibm.dbb.repository.*
import com.ibm.dbb.dependency.*
import groovy.util.*
import groovy.transform.*

@Field def runUtils= loadScript(new File("dbb-utilities.groovy"))

hlq        = args[0]  // user to run the jobs such as "IBMUSER"
sourceDir  = args[1]  // absolute path such as "/u/ibmuser/projects/zopeneditor-sample"

def loadPDS  = "${hlq}.SAMPLE.LOAD"
def custFile = "${hlq}.SAMPLE.CUSTFILE"
def tranFile = "${hlq}.SAMPLE.TRANFILE"
def custOut  = "${hlq}.SAMPLE.CUSTOUT"
def custRpt  = "${hlq}.SAMPLE.CUSTRPT"
def jclPDS   = "${hlq}.SAMPLE.JCL"

// Options (for dataset creation)
def pdsOptions = "cyl space(100,10) lrecl(80) dsorg(PO) recfm(F,B) blksize(32720) dsntype(library) msg(1) new"
def tranFileOptions = "tracks space(100,10) lrecl(80) dsorg(PS) recfm(F,B) blksize(32720) new"
def custFileOptions = "tracks space(100,10) dsorg(PS) recfm(V,B) lrecl(600) blksize(604) new"
def tempOptions     = "cyl space(5,5) unit(vio) new"
// Log Files:
File sys_output = new File("${sourceDir}/logs/sysout.out")
def custOut_path = "${sourceDir}/logs/custout.out"
def custRpt_path = "${sourceDir}/logs/custrpt.out"
def run_jcl = "${sourceDir}/groovy/RUN.jcl"
def debug_jcl = "${sourceDir}/groovy/DEBUG.jcl"
def sysprint_file = "${sourceDir}/logs/sysprint.out"

// Clean up / delete previous datasets
String[] datasets_delete = ["$custFile", "$tranFile", "$jclPDS"]
runUtils.deleteDatasets(datasets_delete)

// Create SAMPLE.TRANFILE , SAMPLE.CUSTFILE, SAMPLE.CUSTRPT, SAMPLE.CUSTOUT with appropriate options
Map dataset_map = ["$tranFile":"$tranFileOptions", "$custFile":"$custFileOptions", "$jclPDS":"$pdsOptions"]
runUtils.createDatasets(dataset_map)

// Copy sample customer file and transaction file
Map copy_map = ["${sourceDir}/RESOURCES/SAMPLE.CUSTFILE.txt":"${custFile}", "${sourceDir}/RESOURCES/SAMPLE.TRANFILE.txt":"${tranFile}"];
runUtils.copyHFStoSeq(copy_map)

//Copy JCL files over into jclPDS
new CopyToPDS().file(new File("${debug_jcl}")).dataset(jclPDS).execute()
new CopyToPDS().file(new File("${run_jcl}")).dataset(jclPDS).execute()

// ****** RUN SAM 1 ******* //

/*
// Submit JCL from file on HFS
JCLExec sam1 = new JCLExec()
println("** Executing RUN JCL **")
sam1.file(new File(run_jcl)).execute()
*/

// Submit JCL from dataset member
JCLExec sam1 = new JCLExec()
println("** Executing RUN JCL **")
sam1.dataset("$jclPDS").member('RUN').execute()

// Get Job data
println("** Getting Job results **")
def maxRC = sam1.getMaxRC()
def jobID = sam1.getSubmittedJobId()
def jobName = sam1.getSubmittedJobName()

// Save JCL Exec SYSOUT to sys_output file
sam1.saveOutput('SYSOUT', sys_output)

if (maxRC == "CC 0000")
    printf("** SUCCESS ** \n JobID: ${jobID} \n JobName: ${jobName} \n")
else {
    printf("** ERROR ** \n RC: ${maxRC} \n JobID: ${jobID} \n JobName: ${jobName} \n")
    System.exit(1)
}

// Copy output Datasets to HFS for displaying to console / log:
copy_map = ["${custOut_path}":"${custOut}", "${custRpt_path}": "${custRpt}"]
runUtils.copySeqtoHFS(copy_map)

//Print custRpt to the console
printf("\n** ${custRpt} or ${custRpt_path} **\n")
println(new File(custRpt_path).text)

@groovy.transform.BaseScript com.ibm.dbb.groovy.ScriptLoader baseScript
import com.ibm.dbb.repository.*
import com.ibm.dbb.dependency.*
import com.ibm.dbb.build.*

def getCurrentGitDirectory() {
	/*
	 * Returns the current Git directory
	 * Assumes that the command is executed somewhere within the Git directory
	 *
	 * @return String gitDirectory The current Git directory
	 */
	String cmd = "git rev-parse --show-toplevel"
	StringBuffer gitDirectory = new StringBuffer()
	StringBuffer gitError = new StringBuffer()
	
	Process process = cmd.execute()
	process.consumeProcessOutput(gitDirectory, gitError)
	process.waitForOrKill(1000)
	
	if (gitError) {
		println("Error executing Git command: $gitError")
	}
	
	return gitDirectory.toString().trim()
}

def getCurrentGitBranch(String project) {
	/*
	 * Returns the current Git branch
	 *
	 * @param  String gitDirectory  Directory where .git is located
	 * @return String gitBranch     The current Git branch
	 */
	
	String cmd = "git -C $project rev-parse --abbrev-ref HEAD"
	StringBuffer gitBranch = new StringBuffer()
	StringBuffer gitError = new StringBuffer()
	
	Process process = cmd.execute()
	process.consumeProcessOutput(gitBranch, gitError)
	process.waitForOrKill(1000)
	if (gitError) {
		println("Error executing Git command: $gitError")
	}
	return gitBranch.toString().trim()
}

def getGitLongHash(gitShortHash, gitDirectory=null) {
	/*
	 * Returns the current Git hash
	 *
	 * @param  String gitShortHash  Short hash (e.g e3c4b29)
	 * @param  String gitDirectory  Directory where .git is located
	 * @return String gitLongHash   Long version of short hash
	 */
	if (gitDirectory == null) {
		gitDirectory = getCurrentGitDirectory()
	}
	
	// build command to be executed
	String cmd = "git --git-dir=${gitDirectory}/.git rev-parse ${gitShortHash}"
	StringBuffer gitLongHash = new StringBuffer()
	StringBuffer gitError = new StringBuffer()
	
	Process process = cmd.execute()
	process.consumeProcessOutput(gitLongHash, gitError)
	process.waitForOrKill(1000)
	if (gitError) {
		print("Error executing Git command: $gitError")
	}
	return gitLongHash.toString().trim()
}

def getGitBranchStartHash(startGitBranch=null, endGitBranch=null, gitDirectory=null) {
	/*
	 * Returns the start hash of a Git branch
	 *
	 * @param  String startGitBranch  Start branch to compare to (e.g master)
	 * @param  String endGitBranch    End branch to compare to (e.g current_branch)
	 * @param  String gitDirectory    Directory where .git is located
	 * @return String returnHash      First commit hash of the endGitBranch
	 */
	
	if (gitDirectory == null) {
		gitDirectory = getCurrentGitDirectory()
	}
	if (startGitBranch == null) {
		println("** No start branch specified, using master.")
		startGitBranch = "master"
	}
	if (endGitBranch == null) {
		println("** No end branch specified, using current branch.")
		endGitBranch = getCurrentGitBranch()
	}
	
	// build command to be executed
	String cmd = "git --no-pager --git-dir=${gitDirectory}/.git log ${startGitBranch}..${endGitBranch} --oneline"
	StringBuffer gitHash = new StringBuffer()
	StringBuffer gitError = new StringBuffer()
	
	Process process = cmd.execute()
	process.consumeProcessOutput(gitHash, gitError)
	process.waitForOrKill(1000)
	if (gitError) {
		print("Error executing Git command: $gitError")
		return null
	}
	else {
		// get the long hash of the double parsed git log output
		String returnHash = getGitLongHash(gitHash.toString().split("\n").last().split(" ").first())
		return returnHash
	}
}
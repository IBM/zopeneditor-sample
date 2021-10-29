#!/bin/sh
###############################################################################
# Licensed Materials - Property of IBM
# (c) Copyright IBM Corporation 2021. All Rights Reserved.
#
# Note to U.S. Government Users Restricted Rights:
# Use, duplication or disclosure restricted by GSA ADP Schedule
# Contract with IBM Corp.
###############################################################################

## Use this script to prepare a IBM Dependency-Based Build build directory your USS home directory
## and to install the dbb-zappbuild sample repository that provides sample build scripts.
## It requires that Git is installed and available in the Path
## The variables below assume a default Wazi Sandbox. Replace with your values if needed.

set -e -x
WORK_DIR="/u/ibmuser/projects"    # WORK_DIR='parent workspace directory'
SAM_DIR="$WORK_DIR/zopeneditor-sample"
RESOURCES_DIR="$SAM_DIR/RESOURCES"
BUILD_DIR="$SAM_DIR/BUILD"
FILES_CMD=rse                    # for z/OSMF use "files"
JOBS_CMD=rse                     # for z/OSMF use "zos-jobs"
SSHPROFILE=""                    # to use a non-default profile use "--ssh-profile profileName"
FILESPROFILE=""                  # to use a non-default profile use "--rse-profile profileName"
DBB_ZAPPBUILD="https://github.com/IBM/dbb-zappbuild.git"

# Creates project folder and clones default DBB groovy scripts repo
source zowe/dbb-prepare-uss-folder.sh

# Create resources directory
echo "Creating directories ..."
zowe uss issue ssh "mkdir -p $RESOURCES_DIR;mkdir -p $SAM_DIR/COBOL;chmod a+rwx $RESOURCES_DIR $SAM_DIR/COBOL" $SSHPROFILE

# Upload local data files to USS folder created above
echo "Uploading source and resource files to USS"
zowe $FILES_CMD upload file-to-uss "COBOL/SAM1.cbl" "$SAM_DIR/COBOL/SAM1.cbl" $FILESPROFILE
zowe $FILES_CMD upload file-to-uss "COBOL/SAM2.cbl" "$SAM_DIR/COBOL/SAM2.cbl" $FILESPROFILE
zowe $FILES_CMD upload dir-to-uss "COPYBOOK" "$SAM_DIR/COPYBOOK" $FILESPROFILE
zowe $FILES_CMD upload file-to-uss "RESOURCES/SAMPLE.CUSTFILE.txt" "$RESOURCES_DIR/SAMPLE.CUSTFILE.txt" $FILESPROFILE
zowe $FILES_CMD upload file-to-uss "RESOURCES/SAMPLE.TRANFILE.txt" "$RESOURCES_DIR/SAMPLE.TRANFILE.txt" $FILESPROFILE

# Create build directory
echo "Creating $BUILD_DIR ..."
zowe uss issue ssh "mkdir -p $BUILD_DIR;chmod a+rwx $BUILD_DIR" $SSHPROFILE

# Upload local data files to USS folder created above
echo "Uploading Groovy and JCL files to run SAM to USS"
zowe $FILES_CMD upload file-to-uss "groovy/dbb-sam-build.groovy" "$BUILD_DIR/dbb-sam-build.groovy" $FILESPROFILE
zowe $FILES_CMD upload file-to-uss "groovy/dbb-sam-run.groovy" "$BUILD_DIR/dbb-sam-run.groovy" $FILESPROFILE
zowe $FILES_CMD upload file-to-uss "groovy/dbb-utilities.groovy" "$BUILD_DIR/dbb-utilities.groovy" $FILESPROFILE
zowe $FILES_CMD upload file-to-uss "groovy/RUN.jcl" "$BUILD_DIR/RUN.jcl" $FILESPROFILE
zowe $FILES_CMD upload file-to-uss "groovy/DEBUG.jcl" "$BUILD_DIR/DEBUG.jcl" $FILESPROFILE
echo "Finished uploading test data for the SAM application."

echo "Started full DBB build of SAM1 and SAM2."
zowe uss issue ssh "\$DBB_HOME/bin/groovyz -DBB_PERSONAL_DAEMON $BUILD_DIR/dbb-sam-build.groovy IBMUSER /u/ibmuser/projects/zopeneditor-sample" $SSHPROFILE
echo "Finished building SAM1 and SAM2."

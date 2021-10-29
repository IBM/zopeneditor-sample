#!/bin/sh
################################################################
# LICENSED MATERIALS - PROPERTY OF IBM
# "RESTRICTED MATERIALS OF IBM"
# (C) COPYRIGHT IBM CORPORATION 2021. ALL RIGHTS RESERVED
# US GOVERNMENT USERS RESTRICTED RIGHTS - USE, DUPLICATION,
# OR DISCLOSURE RESTRICTED BY GSA ADP SCHEDULE
# CONTRACT WITH IBM CORPORATION
################################################################

## Use this script to prepare a IBM Dependency-Based Build build directory your USS home directory
## and to install the dbb-zappbuild sample repository that provides sample build scripts.
## It requires that Git is installed and available in the Path
## The variables below assume a default Wazi Sandbox. Replace with your values if needed.

set -e -x
WORK_DIR="/u/ibmuser/projects"   # WORK_DIR='parent workspace directory'
FILES_CMD=rse                    # for z/OSMF use "files"
SSHPROFILE=""                    # to use a non-default profile use "--ssh-profile profileName"
FILESPROFILE=""                  # to use a non-default profile use "--rse-profile profileName"
DBB_ZAPPBUILD="https://github.com/IBM/dbb-zappbuild.git"

# Delete dbb files to start fresh
echo "Deleting $WORK_DIR to start fresh...."
zowe uss issue ssh "rm -rf $WORK_DIR" $SSHPROFILE

# Create working directory in order to clone dbb zappbuild repo
echo "Creating $WORK_DIR ..."
zowe uss issue ssh "mkdir -p $WORK_DIR;chmod a+rwx $WORK_DIR" $SSHPROFILE

# CD to working directory to clone repo
echo "Cloning dbb zappbuild repo..."
echo "Work_Dir -> $WORK_DIR"
zowe uss issue ssh "cd $WORK_DIR;git config --global http.sslVerify false;git clone $DBB_ZAPPBUILD;git config --global http.sslVerify true" $SSHPROFILE

# Copy the Sanbox datasets.properties file
echo "Installing the Sandbox datasets.properties file..."
zowe $FILES_CMD upload file-to-uss "application-conf/datasets-sandbox.properties" "$WORK_DIR/dbb-zappbuild/build-conf/datasets.properties" $FILESPROFILE

echo 'DBB Setup Finished'

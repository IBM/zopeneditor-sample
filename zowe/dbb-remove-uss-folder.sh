#!/bin/sh
###############################################################################
# Licensed Materials - Property of IBM
# (c) Copyright IBM Corporation 2021. All Rights Reserved.
#
# Note to U.S. Government Users Restricted Rights:
# Use, duplication or disclosure restricted by GSA ADP Schedule
# Contract with IBM Corp.
###############################################################################

## Use this script to remove the dbb-zappbuild repository in your USS home directory
## that was created using the dbb-install-zappbuild.sh script.

set -x
WORK_DIR="/u/ibmuser/projects"   # WORK_DIR='parent workspace directory'
FILES_CMD=rse                    # for z/OSMF use "files"
SSHPROFILE=""                    # to use a non-default profile use "--rse-proile profileName"

# Delete dbb files to start fresh
echo "Deleting $WORK_DIR...."
zowe uss issue ssh "rm -rf $WORK_DIR" $SSHPROFILE

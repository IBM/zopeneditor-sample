#!/bin/sh
################################################################
# LICENSED MATERIALS - PROPERTY OF IBM
# "RESTRICTED MATERIALS OF IBM"
# (C) COPYRIGHT IBM CORPORATION 2021. ALL RIGHTS RESERVED
# US GOVERNMENT USERS RESTRICTED RIGHTS - USE, DUPLICATION,
# OR DISCLOSURE RESTRICTED BY GSA ADP SCHEDULE
# CONTRACT WITH IBM CORPORATION
################################################################

## Use this script to remove the dbb-zappbuild repository in your USS home directory
## that was created using the dbb-install-zappbuild.sh script.

WORK_DIR="/u/ibmuser/projects"   # WORK_DIR='parent workspace directory'
FILES_CMD=rse                    # for z/OSMF use "files"
SSHPROFILE=""                    # to use a non-default profile use "--rse-proile profileName"

# Delete dbb files to start fresh
echo "Deleting $WORK_DIR...."
zowe uss issue ssh "rm -rf $WORK_DIR" $SSHPROFILE

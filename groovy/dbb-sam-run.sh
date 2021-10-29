#!/bin/bash
###############################################################################
# Licensed Materials - Property of IBM
# (c) Copyright IBM Corporation 2021. All Rights Reserved.
#
# Note to U.S. Government Users Restricted Rights:
# Use, duplication or disclosure restricted by GSA ADP Schedule
# Contract with IBM Corp.
###############################################################################

set -e -x
BUILD_DIR="/u/ibmuser/projects/zopeneditor-sample/BUILD"
SSHPROFILE="" # to use a non-default profile use "--ssh-profile profileName"

zowe uss issue ssh "\$DBB_HOME/bin/groovyz -DBB_PERSONAL_DAEMON $BUILD_DIR/dbb-sam-run.groovy IBMUSER /u/ibmuser/projects/zopeneditor-sample" $SSHPROFILE

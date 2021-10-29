#!/bin/sh
################################################################
# LICENSED MATERIALS - PROPERTY OF IBM
# "RESTRICTED MATERIALS OF IBM"
# (C) COPYRIGHT IBM CORPORATION 2020. ALL RIGHTS RESERVED
# US GOVERNMENT USERS RESTRICTED RIGHTS - USE, DUPLICATION,
# OR DISCLOSURE RESTRICTED BY GSA ADP SCHEDULE
# CONTRACT WITH IBM CORPORATION
################################################################

HLQ=IBMUSER
FILES_CMD=rse   # for z/OSMF use "files"
JOBS_CMD=rse    # for z/OSMF use "zos-jobs"
PROFILE=""      # to use a non-default profile use "--rse-proile profileName"

echo "Deleting data sets for SAM app.."
zowe ${FILES_CMD} delete data-set ${HLQ}.SAMPLE.COBOL $PROFILE
zowe ${FILES_CMD} delete data-set ${HLQ}.SAMPLE.COBCOPY $PROFILE
zowe ${FILES_CMD} delete data-set ${HLQ}.SAMPLE.COPYLIB $PROFILE
zowe ${FILES_CMD} delete data-set ${HLQ}.SAMPLE.CUSTFILE $PROFILE
zowe ${FILES_CMD} delete data-set ${HLQ}.SAMPLE.TRANFILE $PROFILE
zowe ${FILES_CMD} delete data-set ${HLQ}.SAMPLE.CUSTRPT $PROFILE
zowe ${FILES_CMD} delete data-set ${HLQ}.SAMPLE.CUSTOUT $PROFILE
zowe ${FILES_CMD} delete data-set ${HLQ}.SAMPLE.LOAD $PROFILE
zowe ${FILES_CMD} delete data-set ${HLQ}.SAMPLE.OBJ $PROFILE

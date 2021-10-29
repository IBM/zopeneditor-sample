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

echo "Submitted job to allocate data sets.."
zowe ${JOBS_CMD} submit local-file "JCL/ALLOCATE.jcl" $PROFILE
sleep 3s

echo "Copy my app to the created PDS.."
zowe ${FILES_CMD} upload dir-to-pds COBOL ${HLQ}.SAMPLE.COBOL $PROFILE
zowe ${FILES_CMD} upload dir-to-pds COPYBOOK ${HLQ}.SAMPLE.COBCOPY $PROFILE
zowe ${FILES_CMD} upload dir-to-pds COPYLIB ${HLQ}.SAMPLE.COPYLIB $PROFILE
zowe ${FILES_CMD} upload dir-to-pds COPYLIB-MVS ${HLQ}.SAMPLE.COPYLIB $PROFILE
zowe ${FILES_CMD} upload file-to-data-set RESOURCES/SAMPLE.CUSTFILE.txt ${HLQ}.SAMPLE.CUSTFILE $PROFILE
zowe ${FILES_CMD} upload file-to-data-set RESOURCES/SAMPLE.TRANFILE.txt ${HLQ}.SAMPLE.TRANFILE $PROFILE

echo "Compile and Run my app"
zowe ${JOBS_CMD} submit local-file "JCL/RUN.jcl" $PROFILE

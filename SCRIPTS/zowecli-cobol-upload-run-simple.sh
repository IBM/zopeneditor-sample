#!/bin/sh
################################################################
# LICENSED MATERIALS - PROPERTY OF IBM
# "RESTRICTED MATERIALS OF IBM"
# (C) COPYRIGHT IBM CORPORATION 2020. ALL RIGHTS RESERVED
# US GOVERNMENT USERS RESTRICTED RIGHTS - USE, DUPLICATION,
# OR DISCLOSURE RESTRICTED BY GSA ADP SCHEDULE
# CONTRACT WITH IBM CORPORATION
################################################################

HLC=IBMUSER
FILES_CMD=rse # files
JOBS_CMD=rse # zos-jobs

echo "Submitted job to allocate data sets.."
zowe ${JOBS_CMD} submit local-file "JCL/ALLOCATE.jcl"
sleep 3s

echo "Copy my app to the created PDS.."
zowe ${FILES_CMD} upload dir-to-pds COBOL ${HLC}.SAMPLE.COBOL
zowe ${FILES_CMD} upload dir-to-pds COPYBOOK ${HLC}.SAMPLE.COBCOPY
zowe ${FILES_CMD} upload file-to-data-set RESOURCES/SAMPLE.CUSTFILE ${HLC}.SAMPLE.CUSTFILE
zowe ${FILES_CMD} upload file-to-data-set RESOURCES/SAMPLE.TRANFILE ${HLC}.SAMPLE.TRANFILE

echo "Compile and Run my app"
zowe ${JOBS_CMD} submit local-file "JCL/RUN.jcl"

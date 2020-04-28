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

echo "Deleting data sets for SAM app.."
zowe ${FILES_CMD} delete data-set ${HLC}.SAMPLE.COBOL
zowe ${FILES_CMD} delete data-set ${HLC}.SAMPLE.COBCOPY
zowe ${FILES_CMD} delete data-set ${HLC}.SAMPLE.CUSTFILE
zowe ${FILES_CMD} delete data-set ${HLC}.SAMPLE.TRANFILE
zowe ${FILES_CMD} delete data-set ${HLC}.SAMPLE.CUSTRPT
zowe ${FILES_CMD} delete data-set ${HLC}.SAMPLE.CUSTOUT
zowe ${FILES_CMD} delete data-set ${HLC}.SAMPLE.LOAD
zowe ${FILES_CMD} delete data-set ${HLC}.SAMPLE.OBJ

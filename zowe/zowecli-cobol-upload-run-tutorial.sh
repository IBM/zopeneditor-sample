#!/bin/bash
################################################################
# LICENSED MATERIALS - PROPERTY OF IBM
# "RESTRICTED MATERIALS OF IBM"
# (C) COPYRIGHT IBM CORPORATION 2020, 2021. ALL RIGHTS RESERVED
# US GOVERNMENT USERS RESTRICTED RIGHTS - USE, DUPLICATION,
# OR DISCLOSURE RESTRICTED BY GSA ADP SCHEDULE
# CONTRACT WITH IBM CORPORATION
################################################################

set -e
HLQ=IBMUSER
FILES_CMD=rse   # for z/OSMF use "files"
JOBS_CMD=rse    # for z/OSMF use "zos-jobs"
PROFILE=""      # to use a non-default profile use "--rse-proile profileName"

echo "Started sample script that will allocate datasets, upload programs, execute JCL and download results."
# Submit ALLOCATE.jcl
alcjobid=$(zowe $JOBS_CMD submit local-file "./JCL/ALLOCATE.jcl" --rff jobid --rft string $PROFILE)
echo "Submitted job $alcjobid"
# Get jobid and check for completion of job
alcstatus="UNKNOWN"
while [[ "$alcstatus" != COMPLET* ]]; do
    echo "Checking status of job $alcjobid"
    alcstatus=$(zowe $JOBS_CMD view job-status-by-jobid "$alcjobid" --rff status --rft string $PROFILE)
    echo "Current status is $alcstatus"
    sleep 5s
done;

# Upload local files into the data sets created by the ALLOCATE.jcl
echo Uploading files to MVS
zowe $FILES_CMD upload dir-to-pds "./COBOL" "$HLQ.SAMPLE.COBOL" $PROFILE
zowe $FILES_CMD upload dir-to-pds "./COPYBOOK" "$HLQ.SAMPLE.COBCOPY"  $PROFILE
zowe $FILES_CMD upload dir-to-pds "./COPYLIB-MVS" "$HLQ.SAMPLE.COPYLIB"  $PROFILE
zowe $FILES_CMD upload dir-to-pds "./COPYLIB" "$HLQ.SAMPLE.COPYLIB"  $PROFILE
zowe $FILES_CMD upload file-to-data-set "./RESOURCES/SAMPLE.CUSTFILE.txt" "$HLQ.SAMPLE.CUSTFILE" $PROFILE
zowe $FILES_CMD upload file-to-data-set "./RESOURCES/SAMPLE.TRANFILE.txt" "$HLQ.SAMPLE.TRANFILE" $PROFILE
# Submit RUN.jcl
echo "Submitting job using local file JCL/RUN.jcl"
runjobid=$(zowe $JOBS_CMD submit local-file "./JCL/RUN.jcl" --rff jobid --rft string $PROFILE)
echo "Submitted job $runjobid"
runstatus="UNKNOWN"
while [[ "$runstatus" != COMPLET* ]]; do
    echo "Checking status of job $runjobid"
    runstatus=$(zowe $JOBS_CMD view job-status-by-jobid "$runjobid" --rff status --rft string  $PROFILE)
    echo "Current status is $runstatus"
    sleep 5s
done;
# Download the output datasets
echo "Execution finished. Downloading $HLQ.SAMPLE.CUSTOUT"
zowe $FILES_CMD download data-set "$HLQ.SAMPLE.CUSTOUT" $PROFILE
echo "Downloading $HLQ.SAMPLE.CUSTRPT"
zowe $FILES_CMD download data-set "$HLQ.SAMPLE.CUSTRPT" $PROFILE
echo "Finished."

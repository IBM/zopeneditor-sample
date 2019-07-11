#!/bin/sh
################################################################
# LICENSED MATERIALS - PROPERTY OF IBM
# "RESTRICTED MATERIALS OF IBM"
# (C) COPYRIGHT IBM CORPORATION 2019. ALL RIGHTS RESERVED
# US GOVERNMENT USERS RESTRICTED RIGHTS - USE, DUPLICATION,
# OR DISCLOSURE RESTRICTED BY GSA ADP SCHEDULE
# CONTRACT WITH IBM CORPORATION
################################################################

# THIS BUILD INCLUDES CALL FOR FULLBUILD (-f) MAY WANT TO TAKE IN DIFF TYPE OF BUILDS FROM USER

# get variables from arguments passed
GITBRANCH=$1
SCRIPT_DIR=$2
HLQ=$3
WORK_DIR=$4
APPLICATION=$5
OUT_DIR=$6

LOG_DIR=$OUT_DIR
if [[ ! -d $LOG_DIR ]]; then
    mkdir -p $LOG_DIR
    chmod a+rwx $LOG_DIR
fi
LOG_FILE="`date +%Y-%m-%d-%H-%M-%S`.log"
LOG_FILE=$LOG_DIR/$LOG_FILE
touch $LOG_FILE
chmod a+rw $LOG_FILE
echo `date +%Y-%m-%d-%H-%M-%S` | tee -a $LOG_FILE
if ! [ -x "$(command -v git)" ]; then
    echo 'Git is required remotely to proceed but is not installed or not on PATH. Aborting...' | tee -a $LOG_FILE
    exit
fi
cd $WORK_DIR/$APPLICATION
pwd | tee -a $LOG_FILE
echo git checkout $GITBRANCH | tee -a $LOG_FILE
OUTPUT=$(git checkout $GITBRANCH --progress 2>&1 | tee -a $LOG_FILE)
echo $OUTPUT
if [[ "$OUTPUT" == *error* ]]; then 
	echo 'There is a Git error, see log file. Aborting...' | tee -a $LOG_FILE
	exit
fi
cd $SCRIPT_DIR
pwd | tee -a $LOG_FILE
echo $DBB_HOME/bin/groovyz build.groovy -h $HLQ -w $WORK_DIR -a $APPLICATION -o $OUT_DIR -f | tee -a $LOG_FILE
$DBB_HOME/bin/groovyz build.groovy -h $HLQ -w $WORK_DIR -a $APPLICATION -o $OUT_DIR -f | tee -a $LOG_FILE

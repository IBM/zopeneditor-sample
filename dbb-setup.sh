#!/bin/sh
################################################################
# LICENSED MATERIALS - PROPERTY OF IBM
# "RESTRICTED MATERIALS OF IBM"
# (C) COPYRIGHT IBM CORPORATION 2019. ALL RIGHTS RESERVED
# US GOVERNMENT USERS RESTRICTED RIGHTS - USE, DUPLICATION,
# OR DISCLOSURE RESTRICTED BY GSA ADP SCHEDULE
# CONTRACT WITH IBM CORPORATION
################################################################

USER=$1
HOST=$2
PROJECT_DIR=$3
CLONE_URL=$4
# Check/create project directory on host
ssh $USER@$HOST PROJ=$PROJECT_DIR USER=$USER '
tsocmd "ALTUSER "${USER}" OMVS(PROGRAM(/var/rocket/bin/bash))"
if [[ ! -f ".bashrc" ]]; then
    ln -s .profile .bashrc
fi
if [[ ! -d "${PROJ}" ]]; then
    echo 'Setting up project folder.'
	mkdir -p "${PROJ}"
	cd "${PROJ}"
	git init
	git config --local receive.denyCurrentBranch updateInstead
fi
exit
'
# Check/set remote origin locally
REMOTE=$(git remote -v)
if  [[ "$REMOTE" != *"$USER@$HOST:$PROJECT_DIR"* ]]; then
    echo 'Setting up remote z/OS.'
    # git checkout master
    git remote remove zos
    git remote add zos $USER@$HOST:$PROJECT_DIR
    git push --set-upstream zos master
fi
# Look for zAppBuild on host, if not clone it from given CLONE_URL
# Copy dbb-branch-build.sh to zAppBuild on host if not already there
# Look for application-conf folder in project on host, if not there copy it from zAppBuild
# Then stage and commit the changes added to project directory
ssh $USER@$HOST PROJ=$PROJECT_DIR CLONE=$CLONE_URL '
ZAPP_DIR=$((find '$(pwd -P)' -name "zAppBuild") 2>&1)
if [[ $ZAPP_DIR == " " ]]; then
	OUTPUT=$(git clone "${CLONE}")
	echo $OUTPUT
    ZAPP_DIR=$((find "$(pwd -P)" -name "zAppBuild") 2>&1)
	if [[ "$OUTPUT" == *error* ]]; then
		echo 'There is a Git error. Aborting...'
	    exit
	fi
fi
SCRIPT='dbb-branch-build.sh'
FIND_SCRIPT=$((find "$(pwd -P)" -name "$SCRIPT") 2>&1)
if [[ $FIND_SCRIPT != *zAppBuild* ]]; then
    echo 'DBB branch build script is not in zAppBuild! Adding it now and making it executable.'
    cd "${PROJ}"
    cp $SCRIPT $ZAPP_DIR
    cd $ZAPP_DIR
    chmod +x $SCRIPT
fi
APP_CONF=$((find "$(pwd -P)" -name "application-conf") 2>&1)
if [[ $APP_CONF != *"${PROJ}"* ]]; then
    echo 'application-conf folder is not in project! Adding it now.'
    cd $ZAPP_DIR/application
    cp -r application-conf ~/"${PROJ}"
    cd ~/"${PROJ}"
    git add application-conf/
    git commit -m "application-conf"
fi
exit
'
# Pull changes from host to local and close out setup script.
git pull zos master
# Gather infor for "Start a Dependency Based Build" task.
OUTPUT=$(ssh $USER@$HOST 'find "$(pwd -P)" -name "zAppBuild"')
PROJ_PARENT=$(ssh $USER@$HOST 'cd '"${PROJECT_DIR}"'; cd ..; pwd')
if [[ $PROJECT_DIR == *"/"* ]]; then
    INDEX=$(echo `expr index "$PROJECT_DIR" /`)
    PROJ=${PROJECT_DIR}
    PROJ=$(echo ${PROJ:$INDEX})
fi
# Final Output for Setup.
echo -e '\nSetup is finished.'
echo 'Check Output for any errors.'
echo -e 'Please make configuration changes if needed before running "Start a Dependency Based Build" task.\n'
echo -e 'Copy and Paste the below "args" into the "Start a Dependency Based Build" task in tasks.json:\n'
echo '"'"${USER}"'@'"${HOST}"'",'
echo '"cd '"${OUTPUT}"'",'
echo '"./dbb-branch-build.sh",'
echo '"master",'
echo '"'"${OUTPUT}"'",'
echo '"'"${USER}"'",' | tr '[:lower:]' '[:upper:]'
echo '"'"${PROJ_PARENT}"'",'
echo '"'"${PROJ}"'",'
echo '"'"~/${PROJECT_DIR}"'/log"'

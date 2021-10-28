#!/bin/bash
################################################################
# LICENSED MATERIALS - PROPERTY OF IBM
# "RESTRICTED MATERIALS OF IBM"
# (C) COPYRIGHT IBM CORPORATION 2021. ALL RIGHTS RESERVED
# US GOVERNMENT USERS RESTRICTED RIGHTS - USE, DUPLICATION,
# OR DISCLOSURE RESTRICTED BY GSA ADP SCHEDULE
# CONTRACT WITH IBM CORPORATION
################################################################

TSOUSER=IBMUSER
PASSWORD=password
HOSTNAME=zos.mycompany.com             # z/OS host name
RSEPORT=6801                           # rse api port
RSEPROFILE=rseapi-profile              # rse profile name
ZOSMFPORT=443                          # z/OSMF api port
ZOSMFPROFILE=zosmf-profile             # z/OSMF profile name
SSHPORT=22                             # ssh port
SSHPROFILE=ssh-profile                 # ssh profile name

echo "Creating RSE profile and setting as default..."
set -x
zowe profiles create rse-profile ${RSEPROFILE} --host ${HOSTNAME} --port ${RSEPORT} --user ${TSOUSER} --pass ${PASSWORD} --bp rseapi --protocol https --reject-unauthorized false --ow
zowe profiles set rse ${RSEPROFILE}
set +x

echo "Creating z/OSMF profile and setting as default..."
set -x
zowe profiles create zosmf-profile ${ZOSMFPROFILE} --host ${HOSTNAME} --port ${ZOSMFPORT} --user ${TSOUSER} --pass ${PASSWORD} --reject-unauthorized false --ow
zowe profiles set zosmf ${ZOSMFPROFILE}
set +x

echo "Creating SSH profile and setting as default..."
set -x
zowe profiles create ssh-profile ${SSHPROFILE} --host ${HOSTNAME} --user ${TSOUSER} --pass ${PASSWORD} --port ${SSHPORT} --ow
zowe profiles set ssh ${SSHPROFILE}
set +x

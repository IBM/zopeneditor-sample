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
HOSTNAME=zos.mycompany.com             # zOS host name
RSEPORT=6801                           # rse api port
RSEPROFILE=rseapi-profile              # rse profileName
SSHPORT=22                             # ssh port
SSHPROFILE=ssh-profile                 # ssh profileName

echo "Creating RSE profile and setting as default..."
set -x
zowe profiles create rse-profile ${RSEPROFILE} --host ${HOSTNAME} --port ${RSEPORT} --user ${TSOUSER} --pass ${PASSWORD} --bp rseapi --protocol https --reject-unauthorized false
zowe profiles set rse ${RSEPROFILE}
set +x

echo "Creating SSH profile and setting as default..."
set -x
zowe profiles create ssh-profile ${SSHPROFILE} --host ${HOSTNAME} --user ${TSOUSER} --pass ${PASSWORD} --port ${SSHPORT}
zowe profiles set ssh ${SSHPROFILE}
set +x

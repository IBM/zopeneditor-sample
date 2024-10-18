//JCLINC JOB ,NOTIFY=&SYSUID,
//             MSGCLASS=H,MSGLEVEL=(1,1),REGION=144M
//*****************************************************************
//* LICENSED MATERIALS - PROPERTY OF IBM
//* "RESTRICTED MATERIALS OF IBM"
//* (C) COPYRIGHT IBM CORPORATION 2024. ALL RIGHTS RESERVED
//*
//*  US GOVERNMENT USERS RESTRICTED RIGHTS - USE, DUPLICATION,
//*  OR DISCLOSURE RESTRICTED BY GSA ADP SCHEDULE
//*  CONTRACT WITH IBM CORPORATION
//*
//***
//*
//* Sample to show how Z Opn Editor can resolve INCLUDE statements
//*
//*****************************************************************
//    SET HLQ='IBMUSER'
//    SET LIB='SAMPLE.JCL'
// JCLLIB ORDER=&HLQ..&LIB
// INCLUDE MEMBER=COMPILE
//*****************************************************************
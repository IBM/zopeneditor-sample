//IBMUSER JOB ,
// MSGCLASS=H,MSGLEVEL=(1,1),TIME=(,4),REGION=0M,COND=(16,LT)
//*****************************************************************
//* LICENSED MATERIALS - PROPERTY OF IBM
//* "RESTRICTED MATERIALS OF IBM"
//* (C) COPYRIGHT IBM CORPORATION 2024, 2025. ALL RIGHTS RESERVED
//*
//*  US GOVERNMENT USERS RESTRICTED RIGHTS - USE, DUPLICATION,
//*  OR DISCLOSURE RESTRICTED BY GSA ADP SCHEDULE
//*  CONTRACT WITH IBM CORPORATION
//*
//***
//*
//* Sample to show how Z Open Editor can resolve INCLUDE and 
//* PROC statements
//*
//*****************************************************************
//    SET HLQ='IBMUSER'
//    SET LIB='SAMPLE.JCL'
// JCLLIB ORDER=&HLQ..&LIB
// INCLUDE MEMBER=COMPSET
//*****************************************************************
//STEP1 EXEC PROC=COMPROC,
//    HLQ=&HLQ,CMPLLIB=&CMPLLIB,
//    UNIT1=&UNIT1,SPACE1=&SPACE1
//SAMALLC JOB ,NOTIFY=&SYSUID,
// MSGCLASS=H,MSGLEVEL=(1,1),REGION=144M
//****************************************************************
//* LICENSED MATERIALS - PROPERTY OF IBM
//* "RESTRICTED MATERIALS OF IBM"
//* (C) COPYRIGHT IBM CORPORATION 2021, 2024. ALL RIGHTS RESERVED
//*
//*  US GOVERNMENT USERS RESTRICTED RIGHTS - USE, DUPLICATION,
//*  OR DISCLOSURE RESTRICTED BY GSA ADP SCHEDULE
//*  CONTRACT WITH IBM CORPORATION
//*
//*
//* THE FOLLOWING HLQ SYMBOLIC MUST CONTAIN THE HIGH LEVEL
//* QUALIFIER UNDER WHICH THE SAMPLE DATASETS MAY RESIDE.
//*
//    SET HLQ='TSOUSER'       *TSO USER ID
//    SET BLK='BLKSIZE=32760' *LOADLIB BLKSIZE PARM
//*************************
//* CLEAN UP DATASETS
//*************************
//DELETE   EXEC PGM=IEFBR14
//SYSPRINT DD SYSOUT=*
//SYSOUT   DD SYSOUT=*
//SYSUDUMP DD SYSOUT=*
//DD1      DD DSN=&HLQ..SAMPLE.REXX,
//            DISP=(MOD,DELETE,DELETE),
//            UNIT=SYSDA,SPACE=(CYL,(0))
//DD2      DD DSN=&HLQ..SAMPLE.REXX.FILEIN1,
//            DISP=(MOD,DELETE,DELETE),
//            UNIT=SYSDA,SPACE=(CYL,(0))
//DD3      DD DSN=&HLQ..SAMPLE.REXX.FILEIN2,
//            DISP=(MOD,DELETE,DELETE),
//            UNIT=SYSDA,SPACE=(CYL,(0))
//DD4      DD DSN=&HLQ..SAMPLE.REXX.FILEOUT,
//            DISP=(MOD,DELETE,DELETE),
//            UNIT=SYSDA,SPACE=(CYL,(0))
//*
//*************************
//* ALLOCATE DATASETS
//*************************
//ALLOCAT EXEC PGM=IEFBR14,COND=(8,LT)
//SYSOUT   DD SYSOUT=*
//SYSPRINT DD SYSOUT=*
//SYSUDUMP DD SYSOUT=*
/*
//DD1      DD DSN=&HLQ..SAMPLE.REXX,
//            DISP=(NEW,CATLG),LRECL=80,RECFM=FB,DSORG=PO,
//            SPACE=(TRK,(100,10),RLSE),
//            BLKSIZE=32760,DSNTYPE=LIBRARY
/*
//DD2      DD DSN=&HLQ..SAMPLE.REXX.FILEIN1,
//            DISP=(NEW,CATLG),LRECL=80,RECFM=FB,DSORG=PS,
//            SPACE=(TRK,(100,10),RLSE),
//            BLKSIZE=32760
/*
//DD3      DD DSN=&HLQ..SAMPLE.REXX.FILEIN2,
//            DISP=(NEW,CATLG),LRECL=80,RECFM=FB,DSORG=PS,
//            SPACE=(TRK,(100,10),RLSE),
//            BLKSIZE=32760
//*
//DD4      DD DSN=&HLQ..SAMPLE.REXX.FILEOUT,
//            DISP=(NEW,CATLG),LRECL=80,RECFM=FB,DSORG=PS,
//            SPACE=(TRK,(100,10),RLSE),
//            BLKSIZE=32760
/*

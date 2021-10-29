//ZDERUN  JOB ,NOTIFY=&SYSUID,
// MSGCLASS=H,MSGLEVEL=(1,1),REGION=144M
//*****************************************************************
//* LICENSED MATERIALS - PROPERTY OF IBM
//* "RESTRICTED MATERIALS OF IBM"
//* (C) COPYRIGHT IBM CORPORATION 2018, 2019. ALL RIGHTS RESERVED
//*
//*  US GOVERNMENT USERS RESTRICTED RIGHTS - USE, DUPLICATION,
//*  OR DISCLOSURE RESTRICTED BY GSA ADP SCHEDULE
//*  CONTRACT WITH IBM CORPORATION
//*
//***
//*
//* THE FOLLOWING SYMBOLICS ARE PROVIDED TO ALLOW THE USER
//* EASILY CUSTOMIZE THE JCL TO YOUR SYSTEM.  THE ONLY SYMBOLIC
//* THAT HAS TO BE CHANGED IS THE 'HLQ' VALUE, WHICH MUST CONTAIN
//* THE HIGH LEVEL QUALIFIER UNDER WHICH THE SAMPLE DATASETS MAY
//* RESIDE.
//*
//* IT MIGHT ALSO BE NECESSARY TO UPDATE THE COBOL COMPILER LIBRARY
//* IF YOUR SYSTEM USES A DIFFERENT VERSION.
//*
//* THE LINK LIBRARY MAY NEED TO BE UPDATED IF YOUR SYSTEM HAS IT
//* INSTALLED UNDER A DIFFERENT DATASET NAME.
//*
//* THE SPACE1 AND SPACE2 VALUES SHOULD WORK AS THEY ARE BUT YOU
//* CAN ALSO CHANGE THEM AS NEEDED.
//*
//*****************************************************************
//    SET HLQ='IBMUSER'                       *TSO USER ID
//    SET CMPLLIB='IGY630.SIGYCOMP'           *COMPILER LIBRARY
//    SET LINKLIB='CEE.SCEELKED'              *LINK LIBRARY
//    SET SPACE1='SYSALLDA,SPACE=(CYL,(1,1))' *SPACE ALLOCATION
//    SET SPACE2='SYSALLDA,SPACE=(CYL,(1,1))' *SPACE ALLOCATION
//*
//***************************
//*                         *
//*  COMPILE SAM2          **
//*                         *
//***************************
//*
//CMPLSAM2 EXEC PGM=IGYCRCTL,PARM='LIST,MAP,NODYN'
//STEPLIB  DD DISP=SHR,DSN=&CMPLLIB
//SYSIN    DD DISP=SHR,DSN=&HLQ..SAMPLE.COBOL(SAM2)
//SYSLIB   DD DISP=SHR,DSN=&HLQ..SAMPLE.COBCOPY
//SYSLIN   DD DISP=OLD,DSN=&HLQ..SAMPLE.OBJ(SAM2)
//SYSPRINT DD SYSOUT=*
//SYSMDECK DD UNIT=&SPACE1
//SYSUT1   DD UNIT=&SPACE1
//SYSUT2   DD UNIT=&SPACE1
//SYSUT3   DD UNIT=&SPACE1
//SYSUT4   DD UNIT=&SPACE1
//SYSUT5   DD UNIT=&SPACE1
//SYSUT6   DD UNIT=&SPACE1
//SYSUT7   DD UNIT=&SPACE1
//SYSUT8   DD UNIT=&SPACE1
//SYSUT9   DD UNIT=&SPACE1
//SYSUT10  DD UNIT=&SPACE1
//SYSUT11  DD UNIT=&SPACE1
//SYSUT12  DD UNIT=&SPACE1
//SYSUT13  DD UNIT=&SPACE1
//SYSUT14  DD UNIT=&SPACE1
//SYSUT15  DD UNIT=&SPACE1
//*
//*
//***************************
//*                         *
//*  COMPILE SAM1          **
//*                         *
//***************************
//*
//CMPLSAM1 EXEC PGM=IGYCRCTL,PARM='LIST,MAP'
//STEPLIB  DD DISP=SHR,DSN=&CMPLLIB
//SYSIN    DD DISP=SHR,DSN=&HLQ..SAMPLE.COBOL(SAM1)
//SYSLIB   DD DISP=SHR,DSN=&HLQ..SAMPLE.COBCOPY
//MYFILE   DD DISP=SHR,DSN=&HLQ..SAMPLE.COPYLIB
//MYLIB    DD DISP=SHR,DSN=&HLQ..SAMPLE.COPYLIB
//SYSLIN   DD DISP=OLD,DSN=&HLQ..SAMPLE.OBJ(SAM1)
//SYSPRINT DD SYSOUT=*
//SYSMDECK DD UNIT=&SPACE1
//SYSUT1   DD UNIT=&SPACE1
//SYSUT2   DD UNIT=&SPACE1
//SYSUT3   DD UNIT=&SPACE1
//SYSUT4   DD UNIT=&SPACE1
//SYSUT5   DD UNIT=&SPACE1
//SYSUT6   DD UNIT=&SPACE1
//SYSUT7   DD UNIT=&SPACE1
//SYSUT8   DD UNIT=&SPACE1
//SYSUT9   DD UNIT=&SPACE1
//SYSUT10  DD UNIT=&SPACE1
//SYSUT11  DD UNIT=&SPACE1
//SYSUT12  DD UNIT=&SPACE1
//SYSUT13  DD UNIT=&SPACE1
//SYSUT14  DD UNIT=&SPACE1
//SYSUT15  DD UNIT=&SPACE1
//*
//***************************
//*                         *
//*  LINK SAM2              *
//*                         *
//***************************
//*
//LINKSAM2 EXEC PGM=IEWL,REGION=3000K
//SYSLMOD  DD  DISP=SHR,DSN=&HLQ..SAMPLE.LOAD
//SYSPRINT DD  SYSOUT=*
//SYSUT1   DD  UNIT=&SPACE2
//SYSLIB   DD  DISP=SHR,DSN=&LINKLIB
//OBJ      DD  DISP=SHR,DSN=&HLQ..SAMPLE.OBJ
//SYSLIN   DD *
     INCLUDE OBJ(SAM2)
     NAME SAM2(R)
/*
//*
//***************************
//*                         *
//*  LINK SAM1              *
//*                         *
//***************************
//*
//LINKSAM1 EXEC PGM=IEWL,REGION=3000K
//SYSLMOD  DD  DISP=SHR,DSN=&HLQ..SAMPLE.LOAD
//SYSPRINT DD  SYSOUT=*
//SYSUT1   DD  UNIT=&SPACE2
//SYSLIB   DD  DISP=SHR,DSN=&LINKLIB
//         DD  DISP=SHR,DSN=&HLQ..SAMPLE.LOAD
//OBJ      DD  DISP=SHR,DSN=&HLQ..SAMPLE.OBJ
//SYSLIN   DD *
     INCLUDE OBJ(SAM1)
     ENTRY SAM1
     NAME SAM1(R)
/*
//*************************
//* CLEAN UP
//*************************
//DELETE   EXEC PGM=IEFBR14
//SYSPRINT DD SYSOUT=*
//SYSOUT   DD SYSOUT=*
//SYSUDUMP DD SYSOUT=*
//DD1      DD DSN=&HLQ..SAMPLE.CUSTRPT,DISP=(MOD,DELETE,DELETE),
//            UNIT=SYSDA,SPACE=(CYL,(0))
//DD2      DD DSN=&HLQ..SAMPLE.CUSTOUT,DISP=(MOD,DELETE,DELETE),
//            UNIT=SYSDA,SPACE=(CYL,(0))
/*
//*************************
//* RUN SAM1
//*************************
//SAM1  EXEC   PGM=SAM1
//STEPLIB DD DSN=&HLQ..SAMPLE.LOAD,DISP=SHR
//*
//SYSOUT   DD SYSOUT=*
//SYSUDUMP DD SYSOUT=*
//*
//* INPUT CUSTOMER FILE
//CUSTFILE DD DISP=SHR,DSN=&HLQ..SAMPLE.CUSTFILE
//*
//* INPUT TRANSACTION FILE
//TRANFILE DD DISP=SHR,DSN=&HLQ..SAMPLE.TRANFILE
//*
//* NEW CUSTOMER FILE
//CUSTOUT  DD DSN=&HLQ..SAMPLE.CUSTOUT,
//    DISP=(NEW,CATLG),UNIT=SYSDA,SPACE=(TRK,(10,10),RLSE),
//    DSORG=PS,RECFM=VB,LRECL=600,BLKSIZE=604
//*
//* OUTPUT CUSTRPT FILE
//CUSTRPT  DD DSN=&HLQ..SAMPLE.CUSTRPT,
//    DISP=(NEW,CATLG),UNIT=SYSDA,SPACE=(TRK,(10,10),RLSE),
//    DSORG=PS,RECFM=FB,LRECL=133,BLKSIZE=0

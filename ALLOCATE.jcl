//ZOWEALLC JOB ,NOTIFY=&SYSUID,   
// MSGCLASS=H,MSGLEVEL=(1,1),TIME=(,4),REGION=144M  
//*
//* LICENSED MATERIALS - PROPERTY OF IBM
//* "RESTRICTED MATERIALS OF IBM"
//* (C) COPYRIGHT IBM CORPORATION 2018. ALL RIGHTS RESERVED
//*
//*  US GOVERNMENT USERS RESTRICTED RIGHTS - USE, DUPLICATION,
//*  OR DISCLOSURE RESTRICTED BY GSA ADP SCHEDULE
//*  CONTRACT WITH IBM CORPORATION
//*   
//*   
//*************************
//* CLEAN UP DATASETS
//*************************
//DELETE   EXEC PGM=IDCAMS           
//SYSPRINT DD  SYSOUT=*              
//SYSIN DD *                         
    DELETE HLQ.SAMPLE.OBJ     
    DELETE HLQ.SAMPLE.LOAD    
    DELETE HLQ.SAMPLE.COBOL   
    DELETE HLQ.SAMPLE.COPYLIB 
    DELETE HLQ.SAMPLE.TRANFILE
    DELETE HLQ.SAMPLE.CUSTFILE
    DELETE HLQ.SAMPLE.SYSDEBUG
/* 
//*************************
//* ALLOCATE DATASETS
//*************************   
//STEP001 EXEC PGM=IDCAMS,COND=(8,LT)                                   
//SYSPRINT DD SYSOUT=*                                         
//INPUT    DD DISP=(,CATLG,DELETE),LRECL=80,RECFM=FB,DSORG=PO,       
//            SPACE=(TRK,(100,10),RLSE),DSN=HLQ.SAMPLE.OBJ,
//            BLKSIZE=(32720),DSNTYPE=LIBRARY
//SYSIN    DD DUMMY                                                       
//*       
//STEP002 EXEC PGM=IDCAMS                                     
//SYSPRINT DD SYSOUT=*                                         
//INPUT    DD DISP=(,CATLG,DELETE),LRECL=0,RECFM=U,DSORG=PO,       
//            SPACE=(TRK,(100,10),RLSE),DSN=HLQ.SAMPLE.LOAD,
//            BLKSIZE=(32720),DSNTYPE=LIBRARY
//SYSIN    DD DUMMY                                               
//*    
//STEP003 EXEC PGM=IDCAMS                                     
//SYSPRINT DD SYSOUT=*                                         
//INPUT    DD DISP=(,CATLG,DELETE),LRECL=80,RECFM=FB,DSORG=PO,       
//            SPACE=(TRK,(100,10),RLSE),DSN=HLQ.SAMPLE.COBOL,
//            BLKSIZE=(32720),DSNTYPE=LIBRARY
//SYSIN    DD DUMMY                                              
//*  
//STEP004 EXEC PGM=IDCAMS                                     
//SYSPRINT DD SYSOUT=*                                         
//INPUT    DD DISP=(,CATLG,DELETE),LRECL=80,RECFM=FB,DSORG=PO,       
//            SPACE=(TRK,(100,10),RLSE),DSN=HLQ.SAMPLE.COPYLIB,
//            BLKSIZE=(32720),DSNTYPE=LIBRARY
//SYSIN    DD DUMMY                                            
//*       
//STEP005 EXEC PGM=IDCAMS                                     
//SYSPRINT DD SYSOUT=*                                         
//INPUT    DD DISP=(,CATLG,DELETE),LRECL=80,RECFM=FB,DSORG=PS,         
//            SPACE=(TRK,(100,10),RLSE),DSN=HLQ.SAMPLE.TRANFILE,
//            BLKSIZE=(32720)
//SYSIN    DD DUMMY        
//*              
//STEP006 EXEC PGM=IDCAMS                                     
//SYSPRINT DD SYSOUT=*                                         
//INPUT    DD DISP=(,CATLG,DELETE),LRECL=600,RECFM=VB,DSORG=PS,        
//            SPACE=(TRK,(100,10),RLSE),DSN=HLQ.SAMPLE.CUSTFILE,
//            BLKSIZE=(604)
//SYSIN    DD DUMMY 
//*      
//STEP007 EXEC PGM=IDCAMS                                     
//SYSPRINT DD SYSOUT=*                                         
//INPUT    DD DISP=(,CATLG,DELETE),LRECL=1024,RECFM=FB,DSORG=PO,       
//            SPACE=(TRK,(100,10),RLSE),DSN=HLQ.SAMPLE.SYSDEBUG,
//            BLKSIZE=0,DSNTYPE=LIBRARY
//SYSIN    DD DUMMY                                            
//*                              
                                                            

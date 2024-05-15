****************************************************************
* LICENSED MATERIALS - PROPERTY OF IBM
* "RESTRICTED MATERIALS OF IBM"
* (C) COPYRIGHT IBM CORPORATION 2024. ALL RIGHTS RESERVED
* US GOVERNMENT USERS RESTRICTED RIGHTS - USE, DUPLICATION,
* OR DISCLOSURE RESTRICTED BY GSA ADP SCHEDULE
* CONTRACT WITH IBM CORPORATION
****************************************************************
         MACRO
&MGET    MGET  &INFILE,&RECORD
&MGET    LA    1,&INFILE
         LA    0,&RECORD
         L     15,48(0,1)
         BALR  14,15
         MEND
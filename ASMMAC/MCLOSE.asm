****************************************************************
* LICENSED MATERIALS - PROPERTY OF IBM
* "RESTRICTED MATERIALS OF IBM"
* (C) COPYRIGHT IBM CORPORATION 2024. ALL RIGHTS RESERVED
* US GOVERNMENT USERS RESTRICTED RIGHTS - USE, DUPLICATION,
* OR DISCLOSURE RESTRICTED BY GSA ADP SCHEDULE
* CONTRACT WITH IBM CORPORATION
****************************************************************
         MACRO
&MCL     MCLOSE  &FILE
.*                          CLOSE (FILENAME)
&MCL     BCR   0,0
         CNOP  0,4
         BAL   1,*+8
         DC    AL1(128)
         DC    AL3&FILE
         SVC   20
         MEND
****************************************************************
* LICENSED MATERIALS - PROPERTY OF IBM
* "RESTRICTED MATERIALS OF IBM"
* (C) COPYRIGHT IBM CORPORATION 2024. ALL RIGHTS RESERVED
* US GOVERNMENT USERS RESTRICTED RIGHTS - USE, DUPLICATION,
* OR DISCLOSURE RESTRICTED BY GSA ADP SCHEDULE
* CONTRACT WITH IBM CORPORATION
****************************************************************
         MACRO
&MOPEN   MOPEN &LIST
.*                OPEN (FILENAME,(OPTION))
.*                    OPTION=INPUT OR OUTPUT
         AIF ('&LIST(2)' EQ '(INPUT)').IN
         AIF ('&LIST(2)' EQ '(OUTPUT)').OUT
         MNOTE 9,'******** INCORRECT I/O OPTION. CHOSEN - &LIST(2).'
         MEXIT
.IN      ANOP
         CNOP 0,4
         BAL  1,*+8
         DC  AL1(128)
         DC  AL3(&LIST(1).)
         SVC 19
         MEXIT
.OUT     ANOP
         CNOP  0,4
         BAL  1,*+8
         DC   AL1(143)
         DC   AL3(&LIST(1).)
         SVC  19
         MEND
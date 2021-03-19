/****************************************************************/
/* LICENSED MATERIALS - PROPERTY OF IBM                         */
/* "RESTRICTED MATERIALS OF IBM"                                */
/* (C) COPYRIGHT IBM CORPORATION 2021. ALL RIGHTS RESERVED      */
/* US GOVERNMENT USERS RESTRICTED RIGHTS - USE, DUPLICATION,    */
/* OR DISCLOSURE RESTRICTED BY GSA ADP SCHEDULE                 */
/* CONTRACT WITH IBM CORPORATION                                */
/****************************************************************/

/***************************** REXX ********************************/
/* This exec uses EXECIO to successively append the records from   */
/* 'sample1.data' and then from 'sample2.data' to the end of the   */
/* data set 'all.sample.data'.  It illustrates the effect of       */
/* residual data in STEM variables.                                */
/*******************************************************************/

/* input file 1 */
"ALLOC FI(myindd1) DA('zowegpl.rexx.sample1.data') SHR REUSE"
/* input file 2 */
"ALLOC FI(myindd2) DA('zowegpl.rexx.sample2.data') SHR REUSE"

/* output append file */
"ALLOC FI(myoutdd) DA('zowegpl.rexx.all.sample.data') MOD REUSE"

/*******************************************************************/
/* Read all records from 'sample1.data' and append them to the     */
/* end of 'all.sample.data'.                                       */
/*******************************************************************/

exec_RC = 0                       /* Initialize exec return code   */

"EXECIO * DISKR myindd1 (STEM newvar. FINIS"  /* Read all records  */

IF rc = 0 THEN                  /* If read was successful          */
  DO

    CALL file1

  END
ELSE
  DO
    exec_RC = RC               /* Save exec return code         */
    SAY
    SAY "Error during 1st EXECIO  DISKR, return code is " RC
    SAY
  END

CALL file2

"EXECIO 0 DISKW myoutdd (FINIS"    /* Close output file            */

"FREE FI(myindd1)"
"FREE FI(myindd2)"
"FREE FI(myoutdd)"
 EXIT 0

 file1:
 SAY "-----------------------------------------------------"
 SAY newvar.0 "records have been read from 'sample1.data': "
 SAY
 DO i = 1 TO newvar.0        /* Loop through all records        */
   SAY newvar.i              /* Display the ith record          */
 END

 /* Write exactly the number of records read */
 "EXECIO" newvar.0 "DISKW myoutdd (STEM newvar."
 IF rc = 0 THEN              /* If write was successful         */
   DO
     SAY
     SAY newvar.0 "records were written to 'all.sample.data'"
   END
 ELSE
   DO
     exec_RC = RC         /* Save exec return code           */
     SAY
     SAY "Error during 1st EXECIO  DISKW, return code is " RC
     SAY
   END
 RETURN


 file2:
 IF exec_RC = 0 THEN        /* If no errors so far... continue */
   DO
   /***************************************************************/
   /* At this time, the stem variables newvar.0 through newvar.i  */
   /* will contain residual data from the previous EXECIO. We     */
   /* issue the "DROP newvar." instruction to clear these residual*/
   /* values from the stem.                                       */
   /***************************************************************/
   DROP newvar.               /* Set all stem variables to their
                                 uninitialized state              */
   /***************************************************************/
   /* Read all records from 'sample2.data' and append them to the */
   /* end of 'all.sample.data'.                                   */
   /***************************************************************/
   "EXECIO * DISKR myindd2 (STEM newvar. FINIS" /*Read all records*/
    IF rc = 0 THEN             /* If read was successful          */
     DO

       SAY
       SAY "-----------------------------------------------------"
       SAY newvar.0 "records have been read from 'sample2.data': "
       SAY
       DO i = 1 TO newvar.0    /* Loop through all records        */
         SAY newvar.i          /* Display the ith record          */
       END

       "EXECIO" newvar.0 "DISKW myoutdd (STEM newvar." /* Write
                                exactly the number of records read */
       IF rc = 0 THEN          /* If write was successful         */
        DO
          SAY
          SAY newvar.0 "records were written to 'all.sample.data'"
        END
       ELSE
         DO
           exec_RC = RC      /* Save exec return code          */
           SAY
           SAY "Error during 2nd EXECIO DISKW, return code is " RC
           SAY
         END
     END
   ELSE
     DO
       exec_RC = RC           /* Save exec return code         */
       SAY
       SAY "Error during 2nd EXECIO  DISKR, return code is " RC
       SAY
     END
 END
 RETURN

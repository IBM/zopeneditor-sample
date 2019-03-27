      ****************************************************************
      * LICENSED MATERIALS - PROPERTY OF IBM
      * "RESTRICTED MATERIALS OF IBM"
      * (C) COPYRIGHT IBM CORPORATION 2018, 2019. ALL RIGHTS RESERVED
      * US GOVERNMENT USERS RESTRICTED RIGHTS - USE, DUPLICATION,
      * OR DISCLOSURE RESTRICTED BY GSA ADP SCHEDULE
      * CONTRACT WITH IBM CORPORATION
      ****************************************************************
      * PROGRAM:  SAM1
      *
      * AUTHOR :  Doug Stout
      *
      * READS A SEQUENTIAL TRANSACTION FILE AND MAKES UPDATES
      * TO A SORTED SEQUENTIAL CUSTOMER FILE
      *
      * A GOOD CASE FOR DEBUGGING LAB - INDEED
      *
      * CAN BE MADE TO ABEND WITH BAD INPUT DATA FOR FAULT ANALYSIS LAB
      *****************************************************************
      *
      * Transaction file record descriptions:
      *    0    1    1    2    2    3    3    4    4    5    5    6    6
      *....5....0....5....0....5....0....5....0....5....0....5....0....5
      *
      * *  <== an asterisk in first column is a comment
      *UPDATE ---key---- -command-- field-name ss -----------value------
      *                  can be:                  valid formats:
      *                  REPLACE                  character_string______
      *                  ADD                      +99999999
      *                  SUBTRACT                 +99999999.99
      * (The "ss" field is a subscript, used for the MONTH field only)
      * DELETE ___key____  <== Delete Record
      * ADD    ___key____  <== Add a new blank record
      *
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. SAM1.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.

           SELECT CUSTOMER-FILE ASSIGN TO CUSTFILE
               ACCESS IS SEQUENTIAL
               FILE STATUS  IS  WS-CUSTFILE-STATUS.

           SELECT CUSTOMER-FILE-OUT ASSIGN TO CUSTOUT
               ACCESS IS SEQUENTIAL
               FILE STATUS  IS  WS-CUSTOUT-STATUS.

            SELECT TRANSACTION-FILE ASSIGN TO TRANFILE
                   FILE STATUS  IS  WS-TRANFILE-STATUS.

            SELECT REPORT-FILE      ASSIGN TO CUSTRPT
                   FILE STATUS  IS  WS-REPORT-STATUS.

      *****************************************************************
       DATA DIVISION.
       FILE SECTION.

       FD  CUSTOMER-FILE
           RECORDING MODE IS V
           RECORD IS VARYING FROM 20 TO 596 CHARACTERS.
       COPY CUSTCOPY REPLACING ==:TAG:== BY ==CUST==.

       FD  CUSTOMER-FILE-OUT
           RECORDING MODE IS V
           BLOCK CONTAINS 0 RECORDS
           RECORD IS VARYING FROM 20 TO 596 CHARACTERS.
       COPY CUSTCOPY REPLACING ==:TAG:== BY ==CSTOUT==.

       FD  TRANSACTION-FILE
           RECORDING MODE IS F.
       COPY TRANREC.

       FD  REPORT-FILE
           RECORDING MODE IS F.
       01  REPORT-RECORD              PIC X(132).

      *****************************************************************
       WORKING-STORAGE SECTION.
      *****************************************************************
      *
       01  SYSTEM-DATE-AND-TIME.
           05  CURRENT-DATE.
               10  CURRENT-YEAR            PIC 9(2).
               10  CURRENT-MONTH           PIC 9(2).
               10  CURRENT-DAY             PIC 9(2).
           05  CURRENT-TIME.
               10  CURRENT-HOUR            PIC 9(2).
               10  CURRENT-MINUTE          PIC 9(2).
               10  CURRENT-SECOND          PIC 9(2).
               10  CURRENT-HNDSEC          PIC 9(2).
      *
      * some comments
      * some more comments
      *
       01  WS-FIELDS.
           05  WS-CUSTFILE-STATUS      PIC X(2)  VALUE SPACES.
           05  WS-CUSTOUT-STATUS       PIC X(2)  VALUE SPACES.
           05  WS-TRANFILE-STATUS      PIC X(2)  VALUE SPACES.
           05  WS-REPORT-STATUS        PIC X(2)  VALUE SPACES.
           05  WS-TRAN-EOF             PIC X     VALUE SPACES.
           05  WS-TRAN-OK              PIC X     VALUE 'N'.
           05  WS-CUST-FILE-OK         PIC X     VALUE 'N'.
           05  WS-CUST-FILE-EOF        PIC X     VALUE 'N'.
           05  WS-TRAN-MSG             PIC X(50) VALUE SPACES.
           05  WS-PREV-TRAN-KEY        PIC X(13) VALUE LOW-VALUES.
           05  INCR-CUST-ID            PIC 9(5)  VALUE 0.
           05  START-CUST-ID           PIC 9(5)  VALUE 0.
           05  MAX-CUST-ID             PIC 9(5)  VALUE 0.
           05  SAM2                    PIC X(8)  VALUE 'SAM2'.
      *
      * some additional comments
      * some more additional comments
      *
       01  WORK-VARIABLES.
           05  I                     PIC S9(9)   COMP-3  VALUE +0.
           05  WORK-NUM              PIC S9(8)   COMP.
      *
       01  REPORT-TOTALS.
           05  NUM-TRAN-RECS         PIC S9(9)   COMP-3  VALUE +0.
           05  NUM-TRAN-ERRORS       PIC S9(9)   COMP-3  VALUE +0.
           05  NUM-ADD-REQUESTS      PIC S9(9)   COMP-3  VALUE +0.
           05  NUM-ADD-PROCESSED     PIC S9(9)   COMP-3  VALUE +0.
           05  NUM-UPDATE-REQUESTS   PIC S9(9)   COMP-3  VALUE +0.
           05  NUM-UPDATE-PROCESSED  PIC S9(9)   COMP-3  VALUE +0.
           05  NUM-DELETE-REQUESTS   PIC S9(9)   COMP-3  VALUE +0.
           05  NUM-DELETE-PROCESSED  PIC S9(9)   COMP-3  VALUE +0.
           05  NUM-CRUNCH-REQUESTS   PIC S9(9)   COMP-3  VALUE +0.
           05  NUM-CRUNCH-PROCESSED  PIC S9(9)   COMP-3  VALUE +0.
           05  NUM-RPTALL-REQUESTS   PIC S9(9)   COMP-3  VALUE +0.
           05  NUM-RPTALL-PROCESSED  PIC S9(9)   COMP-3  VALUE +0.
           05  NUM-GEN-REQUESTS      PIC S9(9)   COMP-3  VALUE +0.
           05  NUM-GEN-PROCESSED     PIC S9(9)   COMP-3  VALUE +0.

       COPY CUSTCOPY REPLACING ==:TAG:== BY ==WS-CUST==.

      *        *******************
      *            report lines
      *        *******************
       01  ERR-MSG-BAD-TRAN.
           05  FILLER PIC X(31)
                        VALUE 'Error Processing Transaction. '.
           05  ERR-MSG-DATA1              PIC X(35)  VALUE SPACES.
           05  ERR-MSG-DATA2              PIC X(66)  VALUE SPACES.
       01  ERR-MSG-BAD-TRAN-2.
           05  FILLER                     PIC X(21)  VALUE SPACES.
           05  ERR-MSG-DATA3              PIC X(80).
           05  FILLER                     PIC X(31)  VALUE SPACES.
       01  MSG-TRAN-SCALE-1.
           05  FILLER PIC X(21) VALUE SPACES.
           05  FILLER                     PIC X(35)
                          VALUE '         1    1    2    2    3    3'.
           05  FILLER                     PIC X(35)
                          VALUE '    4    4    5    5    6    6    7'.
           05  FILLER                     PIC X(41)  VALUE SPACES.
       01  MSG-TRAN-SCALE-2.
           05  FILLER PIC X(21) VALUE ' Transaction Record: '.
           05  FILLER                     PIC X(35)
                          VALUE '....5....0....5....0....5....0....5'.
           05  FILLER                     PIC X(35)
                          VALUE '....0....5....0....5....0....5....0'.
           05  FILLER                     PIC X(41)  VALUE SPACES.
       01 RPT-HEADER1.
           05  FILLER                     PIC X(40)
                     VALUE 'CUSTOMER FILE UPDATE REPORT       DATE: '.
           05  RPT-MM                     PIC 99.
           05  FILLER                     PIC X     VALUE '/'.
           05  RPT-DD                     PIC 99.
           05  FILLER                     PIC X     VALUE '/'.
           05  RPT-YY                     PIC 99.
           05  FILLER                     PIC X(20)
                          VALUE ' (mm/dd/yy)   TIME: '.
           05  RPT-HH                     PIC 99.
           05  FILLER                     PIC X     VALUE ':'.
           05  RPT-MIN                    PIC 99.
           05  FILLER                     PIC X     VALUE ':'.
           05  RPT-SS                     PIC 99.
           05  FILLER                     PIC X(55) VALUE SPACES.
       01  RPT-TRAN-DETAIL1.
           05  RPT-TRAN-MSG1      PIC X(31)
                        VALUE '       Transaction processed: '.
           05  RPT-TRAN-RECORD            PIC X(80)  VALUE SPACES.
           05  FILLER                     PIC X(21)  VALUE SPACES.
       01  RPT-STATS-HDR1.
           05  FILLER PIC X(26) VALUE 'Transaction Totals:       '.
           05  FILLER PIC X(107) VALUE SPACES.
       01  RPT-STATS-HDR2.
           05  FILLER PIC X(26) VALUE 'Transaction      Number of'.
           05  FILLER PIC X(28) VALUE '        Number        Number'.
           05  FILLER PIC X(79) VALUE SPACES.
       01  RPT-STATS-HDR3.
           05  FILLER PIC X(26) VALUE 'Type          Transactions'.
           05  FILLER PIC X(28) VALUE '     Processed      In Error'.
           05  FILLER PIC X(79) VALUE SPACES.
       01  RPT-STATS-HDR4.
           05  FILLER PIC X(26) VALUE '-----------   ------------'.
           05  FILLER PIC X(28) VALUE '   -----------   -----------'.
           05  FILLER PIC X(79) VALUE SPACES.
       01  RPT-STATS-DETAIL.
           05  RPT-TRAN            PIC X(10).
           05  FILLER              PIC X(4)     VALUE SPACES.
           05  RPT-NUM-TRANS       PIC ZZZ,ZZZ,ZZ9.
           05  FILLER              PIC X(3)     VALUE SPACES.
           05  RPT-NUM-TRAN-PROC   PIC ZZZ,ZZZ,ZZ9.
           05  FILLER              PIC X(3)     VALUE SPACES.
           05  RPT-NUM-TRAN-ERR    PIC ZZZ,ZZZ,ZZ9.
           05  FILLER              PIC X(80)   VALUE SPACES.


      *****************************************************************
       PROCEDURE DIVISION.
      *****************************************************************
       000-MAIN.
           ACCEPT CURRENT-DATE FROM DATE.
           ACCEPT CURRENT-TIME FROM TIME.
           DISPLAY 'SAM1 STARTED DATE = ' CURRENT-MONTH '/'
                  CURRENT-DAY '/' CURRENT-YEAR  '  (mm/dd/yy)'.
           DISPLAY '             TIME = ' CURRENT-HOUR ':'
                  CURRENT-MINUTE ':' CURRENT-SECOND.
      * TODO this is a task tag
           PERFORM 700-OPEN-FILES .
           PERFORM 800-INIT-REPORT .

           PERFORM 730-READ-CUSTOMER-FILE .
           PERFORM 100-PROCESS-TRANSACTIONS
                   UNTIL WS-TRAN-EOF = 'Y' .

           PERFORM 850-REPORT-TRAN-STATS .
           PERFORM 790-CLOSE-FILES .

           ACCEPT CURRENT-DATE FROM DATE.
           ACCEPT CURRENT-TIME FROM TIME.
           DISPLAY 'SAM1 STOPPED DATE = ' CURRENT-MONTH '/'
                  CURRENT-DAY '/' CURRENT-YEAR  '  (mm/dd/yy)'.
           DISPLAY '             TIME = ' CURRENT-HOUR ':'
                  CURRENT-MINUTE ':' CURRENT-SECOND.
           GOBACK .

       100-PROCESS-TRANSACTIONS.
           PERFORM 710-READ-TRAN-FILE.

           IF WS-TRAN-EOF NOT = 'Y'
               COMPUTE NUM-TRAN-RECS = NUM-TRAN-RECS + 1
               MOVE 'Y' TO WS-TRAN-OK
               IF TRAN-KEY < WS-PREV-TRAN-KEY AND TRAN-COMMENT NOT = '*'
                  MOVE 'TRANSACTION OUT OF SEQUENCE' TO ERR-MSG-DATA1
                  MOVE SPACES TO ERR-MSG-DATA2
                  PERFORM 299-REPORT-BAD-TRAN
               ELSE
                 EVALUATE TRAN-CODE
                    WHEN 'UPDATE'
                        PERFORM 200-PROCESS-UPDATE-TRAN
                    WHEN 'ADD   '
                        PERFORM 210-PROCESS-ADD-TRAN
                    WHEN 'DELETE'
                        PERFORM 220-PROCESS-DELETE-TRAN
                    WHEN OTHER
                        IF TRAN-COMMENT NOT = '*'
                          MOVE 'INVALID TRAN CODE:' TO ERR-MSG-DATA1
                          MOVE TRAN-CODE TO ERR-MSG-DATA2
                          PERFORM 299-REPORT-BAD-TRAN
                        END-IF
                 END-EVALUATE
               END-IF
               MOVE TRAN-KEY TO WS-PREV-TRAN-KEY
               IF WS-TRAN-OK = 'Y'
                   PERFORM 830-REPORT-TRAN-PROCESSED
               END-IF
           END-IF .


       200-PROCESS-UPDATE-TRAN.
           ADD +1 TO NUM-UPDATE-REQUESTS.
           PERFORM 720-POSITION-CUST-FILE.
           IF CUST-KEY NOT = TRAN-KEY OR WS-CUST-FILE-EOF = 'Y'
               MOVE 'NO MATCHING KEY:     ' TO ERR-MSG-DATA1
               MOVE TRAN-KEY  TO ERR-MSG-DATA2
               PERFORM 299-REPORT-BAD-TRAN
           ELSE
      *
      *        Subroutine SAM2 will apply an update to a customer record
      *
               CALL SAM2 USING CUST-REC, TRANSACTION-RECORD,
                                      WS-TRAN-OK, WS-TRAN-MSG
               IF WS-TRAN-OK NOT = 'Y'
                   MOVE WS-TRAN-MSG TO ERR-MSG-DATA1
                   MOVE SPACES      TO ERR-MSG-DATA2
                   PERFORM 299-REPORT-BAD-TRAN
               ELSE
                   ADD +1 TO NUM-UPDATE-PROCESSED
               END-IF
           END-IF .

       210-PROCESS-ADD-TRAN.
           ADD +1 TO NUM-ADD-REQUESTS .
           PERFORM 720-POSITION-CUST-FILE.
           IF CUST-KEY = TRAN-KEY
               MOVE 'DUPLICATE KEY:       ' TO ERR-MSG-DATA1
               MOVE TRAN-KEY  TO ERR-MSG-DATA2
               PERFORM 299-REPORT-BAD-TRAN
           ELSE
               MOVE SPACES TO WS-CUST-REC
               MOVE TRAN-KEY TO WS-CUST-KEY
               MOVE +0 TO WS-CUST-ACCT-BALANCE
               MOVE +0 TO WS-CUST-ORDERS-YTD
               PERFORM TEST AFTER VARYING I FROM 1 BY 1
                 UNTIL I > 12
                   MOVE +0 TO WS-CUST-MONTH(I)
               END-PERFORM
               PERFORM 740-WRITE-CUSTOUT-FILE
               ADD +1 TO NUM-ADD-PROCESSED
           END-IF .

       220-PROCESS-DELETE-TRAN.
           ADD +1 TO NUM-DELETE-REQUESTS.
           PERFORM 720-POSITION-CUST-FILE.
           IF CUST-KEY NOT = TRAN-KEY OR WS-CUST-FILE-EOF = 'Y'
               MOVE 'NO MATCHING KEY:     ' TO ERR-MSG-DATA1
               MOVE TRAN-KEY  TO ERR-MSG-DATA2
               PERFORM 299-REPORT-BAD-TRAN
           ELSE
               ADD +1 TO NUM-DELETE-PROCESSED
               PERFORM 730-READ-CUSTOMER-FILE
           END-IF .

       299-REPORT-BAD-TRAN.
           ADD +1 TO NUM-TRAN-ERRORS.
           MOVE 'N' TO WS-TRAN-OK.
           WRITE REPORT-RECORD FROM ERR-MSG-BAD-TRAN  AFTER 2.
           WRITE REPORT-RECORD FROM MSG-TRAN-SCALE-1.
           WRITE REPORT-RECORD FROM MSG-TRAN-SCALE-2.
           MOVE TRANSACTION-RECORD   TO ERR-MSG-DATA3.
           WRITE REPORT-RECORD FROM ERR-MSG-BAD-TRAN-2.

       700-OPEN-FILES.
           OPEN INPUT    TRANSACTION-FILE
                         CUSTOMER-FILE
                OUTPUT   CUSTOMER-FILE-OUT
                         REPORT-FILE .
           IF WS-CUSTFILE-STATUS NOT = '00'
             DISPLAY 'ERROR OPENING CUSTOMER INPUT FILE. RC:'
                     WS-CUSTFILE-STATUS
             DISPLAY 'Terminating Program due to File Error'
             MOVE 16 TO RETURN-CODE
             MOVE 'Y' TO WS-TRAN-EOF
           END-IF .
           IF WS-CUSTOUT-STATUS NOT = '00'
             DISPLAY 'ERROR OPENING CUSTOMER OUTPUT FILE. RC:'
                     WS-CUSTOUT-STATUS
             DISPLAY 'Terminating Program due to File Error'
             MOVE 16 TO RETURN-CODE
             MOVE 'Y' TO WS-TRAN-EOF
           END-IF .
           IF WS-TRANFILE-STATUS NOT = '00'
             DISPLAY 'ERROR OPENING TRAN FILE. RC:' WS-TRANFILE-STATUS
             DISPLAY 'Terminating Program due to File Error'
             MOVE 16 TO RETURN-CODE
             MOVE 'Y' TO WS-TRAN-EOF
           END-IF .
           IF WS-REPORT-STATUS NOT = '00'
             DISPLAY 'ERROR OPENING REPT FILE. RC:' WS-REPORT-STATUS
             DISPLAY 'Terminating Program due to File Error'
             MOVE 16 TO RETURN-CODE
             MOVE 'Y' TO WS-TRAN-EOF
           END-IF .


       710-READ-TRAN-FILE.
           READ TRANSACTION-FILE
             AT END MOVE 'Y' TO WS-TRAN-EOF .
           EVALUATE      WS-TRANFILE-STATUS
              WHEN '00'
                   CONTINUE
              WHEN '10'
                   MOVE 'Y' TO WS-TRAN-EOF
              WHEN OTHER
                  MOVE 'Error on tran file read.  Code:'
                              TO ERR-MSG-DATA1
                  MOVE WS-CUSTFILE-STATUS TO ERR-MSG-DATA2
                  PERFORM 299-REPORT-BAD-TRAN
                  MOVE 'Y' TO WS-TRAN-EOF
           END-EVALUATE .
           IF WS-TRAN-EOF = 'Y'
               PERFORM 721-COPY-RECORDS
                 UNTIL WS-CUST-FILE-EOF = 'Y'
           END-IF .

       720-POSITION-CUST-FILE.
           IF CUST-KEY < TRAN-KEY
               IF WS-CUST-FILE-EOF NOT = 'Y'
                   PERFORM 721-COPY-RECORDS
                     UNTIL CUST-KEY >= TRAN-KEY
                        OR WS-CUST-FILE-EOF = 'Y'
               END-IF
           END-IF .

       721-COPY-RECORDS.
           MOVE CUST-REC TO WS-CUST-REC .
           PERFORM 740-WRITE-CUSTOUT-FILE .
           PERFORM 730-READ-CUSTOMER-FILE .

       730-READ-CUSTOMER-FILE.
           READ CUSTOMER-FILE
             AT END MOVE 'Y' TO WS-CUST-FILE-EOF .
           EVALUATE WS-CUSTFILE-STATUS
              WHEN '00'
              WHEN '04'
                  CONTINUE
              WHEN '10'
                  MOVE 'Y' TO WS-CUST-FILE-EOF
              WHEN OTHER
                  MOVE 'Customer input File I/O Error on Read.  RC: '
                              TO ERR-MSG-DATA1
                  MOVE WS-CUSTFILE-STATUS TO ERR-MSG-DATA2
                  PERFORM 299-REPORT-BAD-TRAN
           END-EVALUATE .

       740-WRITE-CUSTOUT-FILE.
           IF WS-CUST-REC-TYPE = 'A'
               WRITE CSTOUT-REC FROM WS-CUST-REC
           ELSE
               MOVE WS-CUST-REC  TO  WS-CUST-CONTACT-REC
               WRITE CSTOUT-CONTACT-REC FROM WS-CUST-CONTACT-REC
           END-IF .
           EVALUATE WS-CUSTOUT-STATUS
              WHEN '00'
                  CONTINUE
              WHEN OTHER
                  MOVE 'CUSTOMER OUTPUT FILE I/O ERROR ON WRITE. RC: '
                              TO ERR-MSG-DATA1
                  MOVE WS-CUSTFILE-STATUS TO ERR-MSG-DATA2
                  PERFORM 299-REPORT-BAD-TRAN
           END-EVALUATE .

       790-CLOSE-FILES.
           CLOSE TRANSACTION-FILE .
           CLOSE REPORT-FILE .
           CLOSE CUSTOMER-FILE .

       800-INIT-REPORT.
           MOVE CURRENT-YEAR   TO RPT-YY.
           MOVE CURRENT-MONTH  TO RPT-MM.
           MOVE CURRENT-DAY    TO RPT-DD.
           MOVE CURRENT-HOUR   TO RPT-HH.
           MOVE CURRENT-MINUTE TO RPT-MIN.
           MOVE CURRENT-SECOND TO RPT-SS.
           WRITE REPORT-RECORD FROM RPT-HEADER1 AFTER PAGE.

       830-REPORT-TRAN-PROCESSED.
           MOVE TRANSACTION-RECORD TO RPT-TRAN-RECORD.
           IF TRAN-COMMENT = '*'
               MOVE SPACES TO RPT-TRAN-MSG1
           ELSE
               MOVE '       Transaction processed: ' to RPT-TRAN-MSG1
           END-IF.
           WRITE REPORT-RECORD FROM RPT-TRAN-DETAIL1.

       850-REPORT-TRAN-STATS.
           WRITE REPORT-RECORD FROM RPT-STATS-HDR1 AFTER 2.
           WRITE REPORT-RECORD FROM RPT-STATS-HDR2 AFTER 2.
           WRITE REPORT-RECORD FROM RPT-STATS-HDR3 AFTER 1.
           WRITE REPORT-RECORD FROM RPT-STATS-HDR4 AFTER 1.

           MOVE 'ADD    '            TO RPT-TRAN.
           MOVE NUM-ADD-REQUESTS     TO RPT-NUM-TRANS.
           MOVE NUM-ADD-PROCESSED    TO RPT-NUM-TRAN-PROC.
           COMPUTE RPT-NUM-TRAN-ERR =
                      NUM-ADD-REQUESTS  -  NUM-ADD-PROCESSED .
           WRITE REPORT-RECORD  FROM  RPT-STATS-DETAIL.

           MOVE 'DELETE '            TO RPT-TRAN.
           MOVE NUM-DELETE-REQUESTS  TO RPT-NUM-TRANS.
           MOVE NUM-DELETE-PROCESSED TO RPT-NUM-TRAN-PROC.
           COMPUTE RPT-NUM-TRAN-ERR =
                      NUM-DELETE-REQUESTS  -  NUM-DELETE-PROCESSED .
           WRITE REPORT-RECORD  FROM  RPT-STATS-DETAIL.

           MOVE 'UPDATE '            TO RPT-TRAN.
           MOVE NUM-UPDATE-REQUESTS  TO RPT-NUM-TRANS.
           MOVE NUM-UPDATE-PROCESSED TO RPT-NUM-TRAN-PROC.
           COMPUTE RPT-NUM-TRAN-ERR =
                      NUM-UPDATE-REQUESTS  -  NUM-UPDATE-PROCESSED .
           WRITE REPORT-RECORD  FROM  RPT-STATS-DETAIL.

      ****************************************************************
      * LICENSED MATERIALS - PROPERTY OF IBM
      * "RESTRICTED MATERIALS OF IBM"
      * (C) COPYRIGHT IBM CORPORATION 2018. ALL RIGHTS RESERVED
      * US GOVERNMENT USERS RESTRICTED RIGHTS - USE, DUPLICATION,
      * OR DISCLOSURE RESTRICTED BY GSA ADP SCHEDULE
      * CONTRACT WITH IBM CORPORATION
      ****************************************************************
      * PROGRAM:  SAM2
      *
      * AUTHOR :  Doug Stout
      *
      * SUBROUTINE TO PROCESS "UPDATE" TRANSACTIONS AGAINST CUST RECS
      *****************************************************************
      * Linkage:
      *      parameters:
      *        1: Customer Record    (passed)
      *        2: Transaction Record (passed)
      *        3: tran-ok flag       (returned)
      *              Return values:    Y  = transaction was processed
      *                                N  = error processing transaction
      *        4: message            (returned)
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. SAM2.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
      *****************************************************************
       DATA DIVISION.

       WORKING-STORAGE SECTION.
      *
       01  WS-FIELDS.
           05  WS-UPDATE-NUM        PIC S9(9)V99  COMP-3  VALUE +0.
           05  WS-UPDATE-NUM-NEG    PIC X         VALUE SPACES.
           05  TRAN-COUNT           PIC 9(5)      COMP-3  VALUE 0.
           05  LOOP-COUNT           PIC S9(8)     COMP    VALUE 0.
           05  WORK-SUM             PIC 9(16)             VALUE 0.
           05  MONTH-AVERAGE        PIC 9(16)             VALUE 0.
           05  MONTH-SUB            PIC 9(16)             VALUE 0.


       LINKAGE SECTION.

       COPY CUSTCOPY REPLACING ==:TAG:== BY ==CUST==.

       COPY TRANREC.

       01  TRAN-OK                         PIC X.
       01  TRAN-MSG                        PIC X(50).

      *****************************************************************
       PROCEDURE DIVISION USING CUST-REC,
                                TRANSACTION-RECORD,
                                TRAN-OK,
                                TRAN-MSG.

       000-MAIN.
           MOVE 'Y' TO TRAN-OK.
           MOVE SPACES TO TRAN-MSG.

           IF TRAN-CODE = 'CRUNCH '
               PERFORM 300-PROCESS-CPU-CRUNCH
           ELSE
               PERFORM 100-VALIDATE-TRAN
               IF TRAN-OK = 'Y'
                   PERFORM 200-PROCESS-TRAN
               END-IF
           END-IF .

           GOBACK.

       100-VALIDATE-TRAN.
           EVALUATE TRAN-CODE
               WHEN  'UPDATE '
                   CONTINUE
               WHEN OTHER
                   MOVE 'N' TO TRAN-OK
                   MOVE 'REQUEST TYPE IS INVALID' TO TRAN-MSG
           END-EVALUATE.
           EVALUATE TRAN-FIELD-NAME
               WHEN 'BALANCE '
               WHEN 'ORDERS  '
                   IF TRAN-UPDATE-NUM-HH  NOT NUMERIC
                       MOVE 0 TO TRAN-UPDATE-NUM-HH
                   END-IF
                   MOVE 'N' TO WS-UPDATE-NUM-NEG
                   IF TRAN-UPDATE-NUMX1 = '-'
                       MOVE 'Y' TO WS-UPDATE-NUM-NEG
                       MOVE '0' TO TRAN-UPDATE-NUMX1
                   END-IF
                   IF TRAN-UPDATE-NUMX1 = '+'
                       MOVE '0' TO TRAN-UPDATE-NUMX1
                   END-IF
                   IF TRAN-UPDATE-NUM NOT NUMERIC
                       MOVE 'N' TO TRAN-OK
                       MOVE 'DATA IS NOT NUMERIC' TO TRAN-MSG
                   ELSE
                       MOVE TRAN-UPDATE-NUM TO WS-UPDATE-NUM
                       IF WS-UPDATE-NUM-NEG = 'Y'
                           COMPUTE WS-UPDATE-NUM = WS-UPDATE-NUM * -1
                       END-IF
                   END-IF
           END-EVALUATE .
           EVALUATE TRAN-ACTION
               WHEN 'REPLACE '
               WHEN 'ADD     '
                   CONTINUE
               WHEN OTHER
                   MOVE 'N' TO TRAN-OK
                   MOVE 'INVALID ACTION CODE   ' TO TRAN-MSG
           END-EVALUATE.

       200-PROCESS-TRAN.
           EVALUATE TRAN-FIELD-NAME
               WHEN 'NAME    '
                   MOVE TRAN-UPDATE-DATA TO CUST-NAME
                   COMPUTE TRAN-COUNT = TRAN-COUNT + 1
               WHEN 'BALANCE '
                   EVALUATE TRAN-ACTION
                       WHEN 'REPLACE'
                           MOVE WS-UPDATE-NUM TO CUST-ACCT-BALANCE
                           COMPUTE TRAN-COUNT = TRAN-COUNT + 1
                       WHEN 'ADD     '
                           COMPUTE CUST-ACCT-BALANCE =
                             CUST-ACCT-BALANCE + WS-UPDATE-NUM
                           COMPUTE TRAN-COUNT = TRAN-COUNT + 1
                   END-EVALUATE
               WHEN 'ORDERS  '
                   EVALUATE TRAN-ACTION
                       WHEN 'REPLACE'
                           MOVE WS-UPDATE-NUM TO CUST-ORDERS-YTD
                           COMPUTE TRAN-COUNT = TRAN-COUNT + 1
                       WHEN 'ADD     '
                           COMPUTE CUST-ORDERS-YTD =
                             CUST-ORDERS-YTD + WS-UPDATE-NUM
                           COMPUTE TRAN-COUNT = TRAN-COUNT + 1
                   END-EVALUATE
               WHEN OTHER
                   MOVE 'N' TO TRAN-OK
                   MOVE 'FIELD NAME INVALID' TO TRAN-MSG
           END-EVALUATE.

       300-PROCESS-CPU-CRUNCH.
           MOVE 0 TO LOOP-COUNT.
           PERFORM 310-CRUNCH-LOOP
               UNTIL LOOP-COUNT > CRUNCH-CPU-LOOPS .

       310-CRUNCH-LOOP.
      *       CALUCLUATE AVERAGE OF ALL MONTHS
           MOVE 0 TO WORK-SUM.
           MOVE 1 TO MONTH-SUB.
           PERFORM VARYING MONTH-SUB FROM 1 BY 1 UNTIL (MONTH-SUB > 12)
             IF CUST-MONTH(MONTH-SUB) IS NOT NUMERIC
                 MOVE 0 TO CUST-MONTH(MONTH-SUB)
             END-IF
             COMPUTE WORK-SUM = WORK-SUM + CUST-MONTH(MONTH-SUB)
           END-PERFORM .
           COMPUTE MONTH-AVERAGE = WORK-SUM / 12 .
           COMPUTE LOOP-COUNT = LOOP-COUNT + 1.


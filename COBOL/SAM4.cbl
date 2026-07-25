      ****************************************************************
      * LICENSED MATERIALS - PROPERTY OF IBM
      * "RESTRICTED MATERIALS OF IBM"
      * (C) COPYRIGHT IBM CORPORATION 2026. ALL RIGHTS RESERVED
      * US GOVERNMENT USERS RESTRICTED RIGHTS - USE, DUPLICATION,
      * OR DISCLOSURE RESTRICTED BY GSA ADP SCHEDULE
      * CONTRACT WITH IBM CORPORATION
      ****************************************************************
      * PROGRAM:  SAM4
      *
      * TUTORIAL PROGRAM DEMONSTRATING STRING AND UNSTRING OPERATIONS
      *
      * STRING:   Concatenates multiple fields/literals into a single
      *           field with optional delimiters and padding control
      *
      * UNSTRING: Breaks a single field into multiple fields using
      *           specified delimiters
      *
      * This program provides practical examples of both operations
      * with descriptive DISPLAY statements showing inputs and outputs.
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. SAM4.
       ENVIRONMENT DIVISION.
      *****************************************************************
       DATA DIVISION.
       WORKING-STORAGE SECTION.
      *
       01 WS-STRING-DEMO.
        05 FIRST-NAME            PIC X(10) VALUE 'John'.
        05 LAST-NAME             PIC X(10) VALUE 'Smith'.
        05 STREET-ADDRESS        PIC X(20) VALUE '123 Main Street'.
        05 CITY                  PIC X(15) VALUE 'New York'.
        05 STATE                 PIC X(2) VALUE 'NY'.
        05 ZIP-CODE              PIC X(5) VALUE '10001'.

       01 WS-STRING-OUTPUT.
        05 FULL-NAME             PIC X(25) VALUE SPACES.
        05 FULL-ADDRESS          PIC X(60) VALUE SPACES.

       01 WS-UNSTRING-DEMO.
        05 DATE-INPUT            PIC X(20) VALUE '12/25/2025'.
        05 TIME-INPUT            PIC X(20) VALUE '14:30:45'.
        05 DELIMITED-DATA        PIC X(50)
           VALUE 'apple,orange,banana,grape'.

       01 WS-UNSTRING-OUTPUT.
        05 DATE-MONTH            PIC 9(2) VALUE 0.
        05 DATE-DAY              PIC 9(2) VALUE 0.
        05 DATE-YEAR             PIC 9(4) VALUE 0.
        05 TIME-HOUR             PIC 9(2) VALUE 0.
        05 TIME-MIN              PIC 9(2) VALUE 0.
        05 TIME-SEC              PIC 9(2) VALUE 0.
        05 FRUIT-1               PIC X(10) VALUE SPACES.
        05 FRUIT-2               PIC X(10) VALUE SPACES.
        05 FRUIT-3               PIC X(10) VALUE SPACES.
        05 FRUIT-4               PIC X(10) VALUE SPACES.

       01 WS-STRING-OPERATIONS.
        05 COMBINED-NAME         PIC X(40) VALUE SPACES.
        05 COMBINED-EMAIL        PIC X(50) VALUE SPACES.
        05 POINTER-VAR           PIC 9(3) VALUE 0.

      *
      *  Formatted display fields
      *
       01 DISPLAY-HEADER-1.
        05 FILLER                PIC X(65)
           VALUE '=' * 65.
       01 DISPLAY-HEADER-2.
        05 FILLER                PIC X(15) VALUE SPACES.
        05 FILLER                PIC X(35)
           VALUE 'STRING AND UNSTRING TUTORIAL'.
       01 DISPLAY-SECTION-SEP.
        05 FILLER                PIC X(65)
           VALUE '-' * 65.

      *****************************************************************
       PROCEDURE DIVISION.
      *****************************************************************
       000-MAIN.
           DISPLAY DISPLAY-HEADER-1.
           DISPLAY DISPLAY-HEADER-2.
           DISPLAY DISPLAY-HEADER-1.
           DISPLAY SPACES.

           PERFORM 100-DEMONSTRATE-STRING.
           DISPLAY SPACES.
           PERFORM 200-DEMONSTRATE-UNSTRING.
           DISPLAY SPACES.
           PERFORM 300-STRING-WITH-DELIMITERS.
           DISPLAY SPACES.
           PERFORM 400-COMPLEX-UNSTRING.

           DISPLAY DISPLAY-HEADER-1.
           DISPLAY 'Program SAM4 completed successfully.'.
           DISPLAY DISPLAY-HEADER-1.

           GOBACK.

      *****************************************************************
       100-DEMONSTRATE-STRING.
      *    Basic STRING operation - concatenate multiple fields
      *
           DISPLAY DISPLAY-SECTION-SEP.
           DISPLAY '100-DEMONSTRATE-STRING: Concatenating Fields'.
           DISPLAY DISPLAY-SECTION-SEP.
           DISPLAY SPACES.

           DISPLAY 'Input Data:'.
           DISPLAY '  FIRST-NAME  = "' FIRST-NAME '"'.
           DISPLAY '  LAST-NAME   = "' LAST-NAME '"'.
           DISPLAY SPACES.

           DISPLAY 'STRING Operation:'.
           DISPLAY '  FULL-NAME = FIRST-NAME DELIMITED BY SPACE'.
           DISPLAY '             " " DELIMITED BY SIZE'.
           DISPLAY '             LAST-NAME DELIMITED BY SPACE'.
           DISPLAY SPACES.

           STRING FIRST-NAME DELIMITED BY SPACE
             " " DELIMITED BY SIZE
             LAST-NAME DELIMITED BY SPACE
             INTO FULL-NAME
           END-STRING.

           DISPLAY 'Output:'.
           DISPLAY '  FULL-NAME   = "' FUNCTION TRIM(FULL-NAME) '"'.
           DISPLAY SPACES.

      *
       200-DEMONSTRATE-UNSTRING.
      *    Basic UNSTRING operation - split a field into multiple fields
      *
           DISPLAY DISPLAY-SECTION-SEP.
           DISPLAY '200-DEMONSTRATE-UNSTRING: Splitting Fields'.
           DISPLAY DISPLAY-SECTION-SEP.
           DISPLAY SPACES.

           DISPLAY 'Input Data:'.
           DISPLAY '  DATE-INPUT  = "' DATE-INPUT '"'.
           DISPLAY SPACES.

           DISPLAY 'UNSTRING Operation:'.
           DISPLAY '  Using "/" as delimiter to split MM/DD/YYYY'.
           DISPLAY SPACES.

           UNSTRING DATE-INPUT DELIMITED BY "/"
             INTO DATE-MONTH
                  DATE-DAY
                  DATE-YEAR
           END-UNSTRING.

           DISPLAY 'Output:'.
           DISPLAY '  DATE-MONTH  = ' DATE-MONTH.
           DISPLAY '  DATE-DAY    = ' DATE-DAY.
           DISPLAY '  DATE-YEAR   = ' DATE-YEAR.
           DISPLAY SPACES.

       300-STRING-WITH-DELIMITERS.
      *    STRING with multiple delimiters and size control
      *
           DISPLAY DISPLAY-SECTION-SEP.
           DISPLAY '300-STRING-WITH-DELIMITERS: Building Full Address'.
           DISPLAY DISPLAY-SECTION-SEP.
           DISPLAY SPACES.

           DISPLAY 'Input Data:'.
           DISPLAY '  STREET-ADDRESS = "' STREET-ADDRESS '"'.
           DISPLAY '  CITY           = "' CITY '"'.
           DISPLAY '  STATE          = "' STATE '"'.
           DISPLAY '  ZIP-CODE       = "' ZIP-CODE '"'.
           DISPLAY SPACES.

           DISPLAY 'STRING Operation with Comma Delimiters:'.
           DISPLAY SPACES.

           STRING STREET-ADDRESS DELIMITED BY SPACE
             ", " DELIMITED BY SIZE
             CITY DELIMITED BY SPACE
             ", " DELIMITED BY SIZE
             STATE DELIMITED BY SIZE
             " " DELIMITED BY SIZE
             ZIP-CODE DELIMITED BY SIZE
             INTO FULL-ADDRESS
           END-STRING.

           DISPLAY 'Output:'.
           DISPLAY '  FULL-ADDRESS = "'
             FUNCTION TRIM(FULL-ADDRESS) '"'.
           DISPLAY SPACES.

      *
       400-COMPLEX-UNSTRING.
      *    UNSTRING with comma delimiter - parsing list data
      *
           DISPLAY DISPLAY-SECTION-SEP.
           DISPLAY '400-COMPLEX-UNSTRING: Parsing Comma-Delimited Data'.
           DISPLAY DISPLAY-SECTION-SEP.
           DISPLAY SPACES.

           DISPLAY 'Input Data:'.
           DISPLAY '  DELIMITED-DATA = "'
             FUNCTION TRIM(DELIMITED-DATA) '"'.
           DISPLAY SPACES.

           DISPLAY 'UNSTRING Operation:'.
           DISPLAY '  Using "," as delimiter to split fruit list'.
           DISPLAY SPACES.

           UNSTRING DELIMITED-DATA DELIMITED BY ","
             INTO FRUIT-1
                  FRUIT-2
                  FRUIT-3
                  FRUIT-4
           END-UNSTRING.

           DISPLAY 'Output:'.
           DISPLAY '  FRUIT-1 = "' FUNCTION TRIM(FRUIT-1) '"'.
           DISPLAY '  FRUIT-2 = "' FUNCTION TRIM(FRUIT-2) '"'.
           DISPLAY '  FRUIT-3 = "' FUNCTION TRIM(FRUIT-3) '"'.
           DISPLAY '  FRUIT-4 = "' FUNCTION TRIM(FRUIT-4) '"'.
           DISPLAY SPACES.

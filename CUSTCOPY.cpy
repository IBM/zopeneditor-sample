      ****************************************************************
      * LICENSED MATERIALS - PROPERTY OF IBM
      * "RESTRICTED MATERIALS OF IBM"
      * (C) COPYRIGHT IBM CORPORATION 2018. ALL RIGHTS RESERVED
      * US GOVERNMENT USERS RESTRICTED RIGHTS - USE, DUPLICATION,
      * OR DISCLOSURE RESTRICTED BY GSA ADP SCHEDULE
      * CONTRACT WITH IBM CORPORATION
      ***++++++++++++++++++++++++++++++++++++++++++++++++++++
      *   SAMPLE COBOL COPYBOOK FOR IBM PD TOOLS WORKSHOPS
      *
      *   THE SAMPLE DATA DESCRIBED BY THIS COPY BOOK
      *       IS <USERID>.ADLAB.CUSTFILE
      *
      * xxxxxxx
      *   The following File Manager OPTION:
      *   6. COBOL compiler specifications
      *   must be set-up for this copybook version to work.
      *   See the example below:
      *
      *   COBOL REPLACE OPTIONS:
      *      FROM STRING                       TO STRING
      *   1. ==:TAG:==                      BY ==LAB==
      *
      *** +++++++++++++++++++++++++++++++++++++++++++++++++++
       01  :TAG:-REC.
           05  :TAG:-KEY.
               10  :TAG:-ID             PIC X(5).
               10  :TAG:-REC-TYPE       PIC X.
           05  :TAG:-NAME               PIC X(17).
      *****05  :TAG:-ACCT-BALANCE       PIC S9(7)V99  COMP-3.
           05  :TAG:-ACCT-BALANCE       PIC 9(7)V99.
      *****05  :TAG:-ORDERS-YTD         PIC S9(5)     COMP.
           05  :TAG:-ORDERS-YTD         PIC 9(5).
           05  :TAG:-ADDR               PIC X(20).
           05  :TAG:-CITY               PIC X(14).
           05  :TAG:-STATE              PIC X(02).
           05  :TAG:-COUNTRY            PIC X(11).
      *****05  :TAG:-MONTH              PIC S9(7)V99 COMP-3 OCCURS 12.
           05  :TAG:-MONTH              PIC 9(7)V99 OCCURS 12.
           05  :TAG:-OCCUPATION         PIC X(30).
           05  :TAG:-NOTES              PIC X(120).
           05  :TAG:-DATA-1             PIC X(05).
           05  :TAG:-DATA-2             PIC X(40).
       01  :TAG:-CONTACT-REC.
           05  :TAG:-CONTACT-KEY.
               10  :TAG:-CONTACT-ID        PIC X(5).
               10  :TAG:-CONTACT-REC-TYPE  PIC X.
           05  :TAG:-CONTACT-NAME       PIC X(17).
           05  :TAG:-DESCRIPTION        PIC X(10).
           05  :TAG:-CONTACT-INFO       PIC X(20).
           05  :TAG:-DATA-3             PIC X(05).
           05  :TAG:-DATA-4             PIC X(05).
           05  :TAG:-DATA-5             PIC X(05).
           05  :TAG:-DATA-6             PIC X.

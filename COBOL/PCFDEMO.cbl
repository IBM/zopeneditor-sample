      ****************************************************************
      * LICENSED MATERIALS - PROPERTY OF IBM
      * "RESTRICTED MATERIALS OF IBM"
      * (C) COPYRIGHT IBM CORPORATION 2026. ALL RIGHTS RESERVED
      * US GOVERNMENT USERS RESTRICTED RIGHTS - USE, DUPLICATION,
      * OR DISCLOSURE RESTRICTED BY GSA ADP SCHEDULE
      * CONTRACT WITH IBM CORPORATION
      ****************************************************************
      * This program is for demonstration purposes for the Program
      * Control Flow Browser.
       IDENTIFICATION DIVISION.
       PROGRAM-ID. PCF-EDGE-STYLES.


       PROCEDURE DIVISION.


       SETUP-PARA.
           DISPLAY 'Setup'.


       MAIN-PARA.
           PERFORM SHARED-PARA
           PERFORM SHARED-PARA
           GO TO GOTO-PARA.


       SHARED-PARA.
           DISPLAY 'Shared'.


       GOTO-PARA.
           DISPLAY 'Go To target'.
           STOP RUN.
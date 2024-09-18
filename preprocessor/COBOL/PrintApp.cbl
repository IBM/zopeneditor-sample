      ****************************************************************
      * LICENSED MATERIALS - PROPERTY OF IBM
      * "RESTRICTED MATERIALS OF IBM"
      * (C) COPYRIGHT IBM CORPORATION 2024. ALL RIGHTS RESERVED
      ****************************************************************

       +ID.
       Program-ID.  PRINTAPP.

       +DD.
       Working-Storage Section.
       01 Work-Parms.
          05 In-Len               pic S9(4) BINARY.
          05 Char-count           Pic 99 Value ZEROS.
          05 Out-Name             PIC X(100).

          Linkage Section.
       01 Recvd-Parms.
          05 In-name         Pic x(30).


       +PD using Recvd-Parms.
             MOVE spaces to Out-Name.

             +MV 0 to Char-count
             Inspect Function Reverse(In-Name)
                Tallying Char-count For Leading Spaces
             Compute In-Len = 30 - Char-count

             +MV 8 to Char-count

             MOVE "Thanks to " to Out-Name (1:10).
             MOVE In-name(1:In-Len) to Out-Name(11:In-Len)
             MOVE " for succeeding!" to Out-Name ((11 + In-Len):16).
             Display Out-name.
             Goback.
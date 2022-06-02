/**REXX*************************************************************************
* Licensed Materials - Property of IBM
* (C) Copyright IBM Corporation 2022. All Rights Reserved.
*
* Note to U.S. Government Users Restricted Rights:
* Use, duplication or disclosure restricted by GSA ADP Schedule
* Contract with IBM Corp.
********************************************************************************
* This file contains utility routines for the fibonacci sample program.
*******************************************************************************/

say "The compiler replaces an include control directive with its contents."

/*%INCLUDE REXXLIB(HELLO) */

/*******************************************************************************
 * Formats an index and value pair into a literal string.
*******************************************************************************/
format_fib:
    arg i, v
    return "f["i"] = "v

/* REXX                                                              */
/*                                                                   */
/* Licensed materials - Property of IBM                              */
/* 5724-T07 Copyright IBM Corp. 2011, 2016                           */
/* All rights reserved                                               */
/* US Government users restricted rights  -  Use, duplication or     */
/* disclosure restricted by GSA ADP schedule contract with IBM Corp. */
/*                                                                   */
/* IBM Developer for z Systems                                       */
/*===================================================================*/
/*                                                                   */
/* PROGRAM NAME:  FELRNPLI                                           */
/*                                                                   */
/* DESCRIPTIVE NAME:  Sample Rexx procedure to invoke the 390 PL/I   */
/*                    Compiler.  The PL/I macro facility is called   */
/*                    and the resulting expanded source is written   */
/*                    to SYSPUNCH.                                   */
/*                                                                   */
/* PURPOSE:  This module serves as a sample REXX procedure which can */
/*           be called from the Developer for z Systems              */
/*           client when the preprocessor framework is used.         */
/*                                                                   */
/* FUNCTION:  This module receives control as a result of            */
/*            setting the properties in the "Editor Configurations"  */
/*            tab of your properties group.                          */
/*                                                                   */
/*            The user specifies the location of this REXX script    */
/*            in the "REXX or CLIST Invoking Preprocessor:" entry    */
/*            field.  In this example:  MYHLQ.CLIST.CLIST(RUNPLI)    */
/*                                                                   */
/*            The framework requires that the 390 REXX execs         */
/*            read the input string from a sequential dataset that   */
/*            is allocated and written on the 390 by the client.     */
/*            The high level qualifier of the allocated dataset is   */
/*            specified by the user in the                           */
/*            "High Level Qualifier for Preprocessor Data:" entry    */
/*            field in the Preprocessor Editor Configurations tab    */
/*            of the property group.  The name of this sequential    */
/*            dataset is the only parameter passed to the REXX exec. */
/*            The following options are gathered by the client and   */
/*            written to the sequential file so that the REXX exec   */
/*            can read the options:                                  */
/*                                                                   */
/*            Output Data Set:                                       */
/*            The user specifies the location of the resulting       */
/*            output file for the preprocessor in the                */
/*            "Preprocessor Output Location:" entry field in the     */
/*            Editor Configurations tab.  This value is assigned to  */
/*            the SYSPUNCH card.                                     */
/*                                                                   */
/*            Compile Options:                                       */
/*            The user specifies compile options in the              */
/*            "Compile Options:" entry field of the property page.   */
/*                                                                   */
/*            SYSLIB:                                                */
/*            The user specifies the SYSLIB in the "Copy Libraries:" */
/*            or "Include Libraries:" entry field in the property    */
/*            page.                                                  */
/*                                                                   */
/*            Preprocessor Parameters:                               */
/*            The user is able to specify options that are specific  */
/*            to the invocation of his own preprocessor here.        */
/*            For example:                                           */
/*                                                                   */
/*            <SYSPRINT>USERID.MY.LISTING(MEMBER)</SYSPRINT>         */
/*                                                                   */
/*            This value was entered in the Preprocessor Parameters  */
/*            entry field, and from this value, a SYSPRINT           */
/*            allocate statement was created.                        */
/*                                                                   */
/*            For ease of parsing, the values are passed with        */
/*            surrounding XML style tags.                            */
/*                                                                   */
/* CUSTOMIZATION:  Variable "compiler_hlq" defines the default       */
/*                 high-level qualifier for the PL/I Compiler.       */
/*                                                                   */
/*====================================================================*/
trace o
Address TSO
parse arg optfile
compiler_hlq = "PLI"
compiler = compiler_hlq||".V6R1M0.SIBMZCMP(IBMZPLI)"
/*****************************************************/
/* Read options file written by the workbench        */
/*****************************************************/

 "ALLOC DA('"||optfile||"') F(indd) SHR REUSE"
 if rc <>  0 then do
   SAY "Allocate of" optfile " failed with RC" rc
   "FREE FILE(indd)"
   EXIT 8
 end
 "EXECIO * DISKR indd (STEM optfiledata. FINIS"
 if rc <>  0 then do
   SAY "Read of" optfile " failed with RC" rc
   "FREE FILE(indd)"
   EXIT 8
 end
 "FREE FILE(indd)"

 optfilestr=''
 do i = 1 to optfiledata.0
   optfilestr = optfilestr || optfiledata.i
 end
 optfilestr=EscapeSingleQuote(optfilestr)

/*****************************************************/
/*PARSE THROUGH INVOCATION STRING TO GET             */
/*SYSIN, SYSPUNCH, SYSXMLSD, AND SYSLIB              */
/*****************************************************/
 parse var optfilestr . '<PROGRAM>' sysinparm '</PROGRAM>' .
 parse var optfilestr . '<OUTPUT>' syspunchparm '</OUTPUT>' .
 parse var optfilestr . '<SYSLIB>' syslibparm '</SYSLIB>' .
 parse var optfilestr . '<SYSLIN>' syslinparm '</SYSLIN>' .
 parse var optfilestr . '<SYSPRINT>' sysprintparm '</SYSPRINT>' .
 parse var optfilestr . '<COMPILEOPTIONS>' optionsparm ,
                        '</COMPILEOPTIONS>' .
/*****************************************************/
/* set up compiler work datasets                     */
/*****************************************************/
 "ALLOCATE FILE(SYSUT1)CYLINDERS SPACE(1 1) UNIT(SYSALLDA)"
 if rc <> 0 then do
  "FREE FILE(SYSUT1)"
  "ALLOCATE FILE(SYSUT1)CYLINDERS SPACE(1 1) UNIT(SYSALLDA)"
  if rc <> 0 then do
    SAY "Allocation of SYSUT1 failed with RC" rc
    FREEUP()
    EXIT
  end
 end
 "ALLOCATE FILE(SYSUT2)CYLINDERS SPACE(1 1) UNIT(SYSALLDA)"
 if rc <> 0 then do
  "FREE FILE(SYSUT2)"
  "ALLOCATE FILE(SYSUT2)CYLINDERS SPACE(1 1) UNIT(SYSALLDA)"
  if rc <> 0 then do
    SAY "Allocation of SYSUT2 failed with RC" rc
    FREEUP()
    EXIT
  end
 end
 "ALLOCATE FILE(SYSUT3)CYLINDERS SPACE(1 1) UNIT(SYSALLDA)"
 if rc <> 0 then do
  "FREE FILE(SYSUT3)"
  "ALLOCATE FILE(SYSUT3)CYLINDERS SPACE(1 1) UNIT(SYSALLDA)"
  if rc <> 0 then do
    SAY "Allocation of SYSUT3 failed with RC" rc
    FREEUP()
    EXIT
  end
 end
 "ALLOCATE FILE(SYSUT4)CYLINDERS SPACE(1 1) UNIT(SYSALLDA)"
 if rc <> 0 then do
  "FREE FILE(SYSUT4)"
  "ALLOCATE FILE(SYSUT4)CYLINDERS SPACE(1 1) UNIT(SYSALLDA)"
  if rc <> 0 then do
    SAY "Allocation of SYSUT4 failed with RC" rc
    FREEUP()
    EXIT
  end
 end
 "ALLOCATE FILE(SYSUT5)CYLINDERS SPACE(1 1) UNIT(SYSALLDA)"
 if rc <> 0 then do
  "FREE FILE(SYSUT5)"
  "ALLOCATE FILE(SYSUT5)CYLINDERS SPACE(1 1) UNIT(SYSALLDA)"
  if rc <> 0 then do
    SAY "Allocation of SYSUT5 failed with RC" rc
    FREEUP()
    EXIT
  end
 end
 "ALLOCATE FILE(SYSUT6)CYLINDERS SPACE(1 1) UNIT(SYSALLDA)"
 if rc <> 0 then do
  "FREE FILE(SYSUT6)"
  "ALLOCATE FILE(SYSUT6)CYLINDERS SPACE(1 1) UNIT(SYSALLDA)"
  if rc <> 0 then do
    SAY "Allocation of SYSUT6 failed with RC" rc
    FREEUP()
    EXIT
  end
 end
 "ALLOCATE FILE(SYSUT7)CYLINDERS SPACE(1 1) UNIT(SYSALLDA)"
 if rc <> 0 then do
  "FREE FILE(SYSUT7)"
  "ALLOCATE FILE(SYSUT7)CYLINDERS SPACE(1 1) UNIT(SYSALLDA)"
  if rc <> 0 then do
    SAY "Allocation of SYSUT7 failed with RC" rc
    FREEUP()
    EXIT
  end
 end

/*****************************************************/
/* set up SYS* concatenation                         */
/*****************************************************/
 Allocated=''
 dscount=WORDS(syslibparm)
 if dscount > 0 then do
   complibs="'"||WORD(syslibparm,1)||"'"
   do i=2 to dscount
     complibs=complibs||",'"||WORD(syslibparm,i)||"'"
   end
   if complibs<>'' then do
    syslibAllocated = "true"
    "ALLOCATE DDNAME(SYSLIB) DSNAME("complibs") SHR REUSE"
    if rc <> 0 then
     do
      /**********************************/
      /*FREE IT AND TRY AGAIN           */
      /**********************************/
      "FREE FILE(SYSLIB)"
      "ALLOCATE DDNAME(SYSLIB) DSNAME("complibs") SHR REUSE"
      if rc <> 0 then
      do
        SAY "SYSLIB ALLOCATION FAILED" rc
        FREEUP()
        EXIT
      end
     end
    end
    end

 Allocated=Allocated SysAlloc('SYSIN',sysinparm,Allocated)
 Allocated=Allocated SysAlloc('SYSLIN',syslinparm,Allocated)
 Allocated=Allocated SysAlloc('SYSPUNCH',syspunchparm,Allocated)
 Allocated=Allocated SysAlloc('SYSPRINT',sysprintparm,Allocated)

/*****************************************************/
/* call compiler                                     */
/*****************************************************/
 OPTS = "OPTIONS,MACRO,MDECK" optionsparm
 SAY "> options=" OPTS
 SAY "> compiler=" compiler
 ADDRESS TSO "CALL '"||compiler||"'"||" '"||OPTS||"'"
 xRC=rc
 SAY "> RC="xRC
 if syslibAllocated = "true" then
  do
     "FREE FILE(SYSLIB)"
  end

 "FREE FILE(SYSUT1,SYSUT2,SYSUT3,SYSUT4,SYSUT5,SYSUT6,SYSUT7)"
 "FREE FILE("Allocated")"
EXIT xRC

/*===================================================================*/
SysAlloc: PROCEDURE
/*===================================================================*/
 arg DD,DSN,Allocated
 if DSN = '' then RETURN ''                         /* LEAVE ROUTINE */

 SAY "> DD" DD"="DSN
 "ALLOCATE DDNAME("DD") DSNAME('"DSN"') SHR REUSE"
 if rc <> 0 then
 do
   /**********************************/
   /*FREE IT AND TRY AGAIN           */
   /**********************************/
   "FREE FILE("DD")"
   "ALLOCATE DDNAME("DD") DSNAME('"DSN"') SHR REUSE"
   if rc <> 0 then
   do
     SAY "Allocate of" DD "failed with RC " rc
     "FREE FILE(SYSUT1,SYSUT2,SYSUT3,SYSUT4,SYSUT5,SYSUT6,SYSUT7)"
     if Allocated <> '' then "FREE FILE("Allocated")"
     EXIT 8
   end
 end
return DD    /* SysAlloc */
/*===================================================================*/
FREEUP: PROCEDURE
/*===================================================================*/
     "FREE FILE(SYSUT1,SYSUT2,SYSUT3,SYSUT4,SYSUT5,SYSUT6,SYSUT7)"
     "FREE FILE(SYSIN,SYSLIN,SYSPUNCH,SYSPRINT,SYSLIB)"
return     /* FREEUP */
/*===================================================================*/
EscapeSingleQuote: /*NO procedure*/  /* escape single quote character*/
/*===================================================================*/
 parse arg _Str
 _Start=1
 do while pos("'",_Str,_Start) > 0
   _Ptr=pos("'",_Str,_Start)
   _Str=insert("'",_Str,_Ptr-1)
   _Start=_Ptr+2
 end
return _Str   /* EscapeSingleQuote */
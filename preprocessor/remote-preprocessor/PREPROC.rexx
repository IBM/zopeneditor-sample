/* REXX */
/*
 * Licensed materials - Property of IBM
 * 5724-T07 Copyright IBM Corp. 2024, 2024
 * All rights reserved
 * US Government users restricted rights  -  Use, duplication or
 * disclosure restricted by GSA ADP schedule contract with IBM Corp.
 *
 * z/OS Explorer Extensions
 * Sample COBOL pre-processor.
 *
 *===================================================================
 */
SIGNAL ON NOVALUE
parse upper arg XmlFile

ExitRC=8  /* assume failure */

/*
 * Read options file written by the workbench
 */
if \_read(XmlFile) then exit ExitRC                 /* LEAVE PROGRAM */
/*
 * sample xmlFile content:
 *  <PROGRAM>userid.COBOL(member)</PROGRAM>
 *  <SYSLIB>userid.COBOL.COPYLIB</SYSLIB>
 *  <COMPILEOPTIONS></COMPILEOPTIONS>
 *  <OUTPUT>userid.EXPANDED.COBOL(member)</OUTPUT>
 */
XmlFileStr=''
do i=1 to Lines.0
  XmlFileStr=XmlFileStr || Lines.i
end    /* loop i */

/*
 * substitute keywords in source file
 */
if _read(_parseXml('PROGRAM'))
then do
  Count=0
  do i=1 to Lines.0
    Lines.i=_substitute('+ID','IDENTIFICATION DIVISION',Lines.i)
    Lines.i=_substitute('+ED','ENVIRONMENT DIVISION',Lines.i)
    Lines.i=_substitute('+DD','DATA DIVISION',Lines.i)
    Lines.i=_substitute('+PD','PROCEDURE DIVISION',Lines.i)
    Lines.i=_substitute('+MV','MOVE',Lines.i)
  end    /* loop i */
  say '>' Count 'substitutions done'

  if _write(_parseXml('OUTPUT')) then ExitRC=0
end    /* read successful */
exit ExitRC                                         /* LEAVE PROGRAM */


/*===================================================================
 * --- Read <DSN> and store in stem Lines.
 * Returns boolean indicating success (1) or failure (0)
 * Updates Lines.
 *
 * DSN: name of data set to read
 */
_read: PROCEDURE EXPOSE Lines.
parse upper arg DSN
say "> _read '"DSN"'"

"ALLOCATE FILE($$TEMP$$) REUSE DSN('"DSN"') SHR"
Success=(rc = 0)
if \Success
then say "ERROR Allocate of '"DSN"' failed with RC" rc
else do
  Lines.0=0          /* let SIGNAL ON NOVALUE know Lines. has values */
  "EXECIO * DISKR $$TEMP$$ (FINIS STEM Lines."
  Success=(rc = 0)
  if \Success then say "ERROR Read of '"DSN"' failed with RC" rc
  "FREE FILE($$TEMP$$)"                     /* ignore possible error */
  say '> _read' Lines.0 'lines read'
end    /* */
return Success    /* _read */

/*===================================================================
 * --- Write stem Lines. to <DSN>
 * Returns boolean indicating success (1) or failure (0)
 *
 * DSN : name of data set to read
 * Disp: (optional) disposition for allocation, default SHR
 */
_write: PROCEDURE EXPOSE Lines.
parse upper arg DSN,Disp
if Disp = '' then Disp='SHR'
say "> _write '"DSN"'" Disp

"ALLOCATE FILE($$TEMP$$) REUSE DSN('"DSN"')" Disp
if rc \= 0
then do
  say "ERROR Allocate of '"DSN"' failed with RC" rc
  return 0  /* FALSE */                             /* LEAVE ROUTINE */
end    /* */

cRC=listdsi("'"DSN"'")                        /* get max line length */
if cRC > 0
then do
  say 'ERROR listdsi' DSN 'RC' cRC 'RSN' SYSREASON
  say SYSMSGLVL2
  return 0  /* FALSE */                             /* LEAVE ROUTINE */
end    /* */

select
when pos('F',SYSRECFM) > 0 then MaxLine=SYSLRECL+1
when pos('V',SYSRECFM) > 0 then MaxLine=SYSLRECL-4+1
otherwise
  say 'ERROR' DSN 'RECFM' SYSRECFM 'is not supported'
  return 0  /* FALSE */                             /* LEAVE ROUTINE */
end    /* select */

if 0  /* 0/1: disable/enable debug mode */
then do
  say '. output' DSN':' SYSRECFM || SYSLRECL
  do T=0 to Lines.0; say '. line 'T'('length(Lines.T)')' Lines.T; end
end    /* debug */

Success=1  /* TRUE */                     /* trim to fit output file */
do T=1 to Lines.0
  parse var Lines.T Lines.T =(MaxLine) Cut
  if strip(Cut) \= ''
  then do
    say 'ERROR line' T 'has data beyond column' MaxLine-1': "'Cut'"'
    say Lines.T || Cut
    Success=0  /* FALSE */
  end    /* select */
end    /* loop T */
if \Success then return 0  /* FALSE */              /* LEAVE ROUTINE */

"EXECIO * DISKW $$TEMP$$ (FINIS STEM Lines."
Success=(rc = 0)
if \Success then say "ERROR Write of '"DSN"' failed with RC" rc
"FREE FILE($$TEMP$$)"                       /* ignore possible error */
say '> _write' Lines.0 'lines written'
return Success    /* _write */

/*===================================================================
 * --- Retrieve data enclosed in keyword tags from xmlFileStr
 * Returns data that was enclosed in keyword tags
 *
 * Key: name of <key></key> pair
 */
_parseXml: PROCEDURE EXPOSE XmlFileStr
parse arg Key
Start='<'Key'>'
Stop='</'Key'>'

parse var XmlFileStr (Start) Result (Stop)
say "> _parseXml" Key"='"Result"'"
return Result    /* _parseXml */

/*===================================================================
 * --- Substitute all occurances of one string with another
 * Returns input <Line> (string) with <Old> replaced by <New>
 * Increases Count for each substitution
 *
 * Old  : word/string to replace
 * New  : replacement word/string
 * Line : string to process
 * Start: (optional) starting position, default 1
 */
_substitute: PROCEDURE Expose Count
parse arg Old,New,Line,Start
parse value Start '1' with Start .               /* default: Start=1 */
/*say '> _substitute' Old','New','Line','Start */

Start=pos(Old,Line,Start)
do while Start > 0
  Count=Count+1
  /* substitute Old with New */
  Line=insert(New,delstr(Line,Start,length(Old)),Start-1)
  /*say '> _substitute (length' length(Line)')' Line*/      /* trace */

  /* start after New for next test */
  Start=pos(Old,Line,Start + length(New))
end    /* while */
return Line    /* _substitute */
 

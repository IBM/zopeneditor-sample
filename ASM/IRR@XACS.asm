DSNX@XAC TITLE 'RACF/DB2 External Security Module - Symbols'
*----------------------------------------------------------------------
* Global SET Symbols: See $SET for a description
*----------------------------------------------------------------------
              GBLC  &CLASSNMT,&CHAROPT,&CLASSOPT,&ERROROPT         @09C
              GBLA  &PCELLCT,&SCELLCT,&XAPLDBCK
&CLASSOPT     SETC  '2'     1 - Use Classification Model I
.*                              (One set of classes for EACH subsys)
.*                          2 - Use Classification Model II
.*                              (One set of classes for ALL subsys)
&CLASSNMT     SETC  'DSN'   DB2 Subsystem Name (Up to 4 chars)
&CHAROPT      SETC  '1'     One character suffix (0-9, #, @ or $)
&PCELLCT      SETA  50      Primary Cell Count
&SCELLCT      SETA  50      Secondary Cell Count
&ERROROPT     SETC  '1'     1 - Defer to DB2 authorization if      @L3A
.*                              exit abends, sets terminating      @09A
.*                              return code(12), or sets an        @09A
.*                              unexpected return code.            @09A
.*                          2 - Terminate DB2 if                   @09A
.*                              exit abends, sets terminating      @09A
.*                              return code(12), or sets an        @09A
.*                              unexpected return code.            @09A
*
&SERVICELEVEL SETC  'OA12836'  Release/APAR number (up to 7 chars) @0CC
*                               This symbol is for IBM use only.
              EJECT
         TITLE 'RACF/DB2 External Security Module - Prolog'
**********************************************************************
* $XACSDESC                                                          *
**********************************************************************
*                                                                    *
* $MOD(IRR@XACS) COMP(XXH00) PROD(RACF):                             *
*                                                                    *
*                                                                    *
*01* MODULE NAME:                                                    *
*      IRR@XACS                                                      *
*                                                                    *
*02*   CSECT NAME:                                                   *
*        DSNX@XAC                                                    *
*                                                                    *
*                                                                    *
*01* DESCRIPTIVE NAME:                                               *
*        RACF/DB2 Access Control Authorization Exit - Main Module    *
*                                                                    *
* *01* PROPRIETARY STATEMENT=                                         *
*  **PROPRIETARY_STATEMENT*********************************************
*                                                                     *
*                                                                     *
*   LICENSED MATERIALS - PROPERTY OF IBM                              *
*   THIS PART IS "RESTRICTED MATERIALS OF IBM"                        *
*   5647-A01 (C) COPYRIGHT IBM CORP. 1997, 2000                       *
*                                                                     *
*   STATUS= HRF7706                                                   *
*                                                                     *
*  **END_OF_PROPRIETARY_STATEMENT**************************************
*                                                                    *
*                                                                    *
*01* FUNCTION:                                                       *
*      Perform authorization checking for DB2 privileges.            *
*                                                                    *
*01* OPERATION:                                                      *
*    This routine is invoked by DB2 as the DB2/RACF Authorization    *
*    Exit and acts as the interface to DB2.  As a result, it must    *
*    have a CSECT name of DSNX@XAC.  This routine will either        *
*    process the request or invoke a subroutine based on the         *
*    requested function.  Authorization requests, XAPLFUNC=2, will   *
*    be handled by this routine.  Initialization and termination     *
*    requests, XAPLFUNC = 1|3, will be handled by IRR@XAC1.  The     *
*    details of intialization and termination are defined in module  *
*    prolog for IRR@XAC1.                                            *
*                                                                    *
*    For authorization requests, IRR@XACS is responsible for         *
*    implementing the authority checking.  This routine uses two     *
*    possible methods to determine access control:                   *
*                                                                    *
*         1) Implicit Privileges of Ownership                        *
*         2) RACF profiles for DB2 resource                          *
*                                                                    *
*    Both methods use the Authority Checking tables (IRR@TPRV,       *
*    IRR@TRUL and IRR@TRES) to determine the checks to perform.      *
*    When IRR@XACS is invoked, it will use the Privilege Table,      *
*    IRR@TPRV to locate the authority checking rules that apply to   *
*    the specified privilege.  The authority checking rules are      *
*    located in IRR@TRUL.  Each authority checking rule has an       *
*    associated resource table (IRR@TRES) entry.  The resource table *
*    entry defines:                                                  *
*                                                                    *
*         1) Whether to perform the implicit privilege check         *
*            (and if so, where to find object owner information)     *
*         2) RACF general resource class name to be used             *
*         3) RACF resource name to be used                           *
*                                                                    *
*    This routine will process each rule associated with the         *
*    privilege until access is allowed or all of the rules have      *
*    been exhausted.  As each rule is processed implicit privileges  *
*    will be checked before RACF profiles.                           *
*                                                                    *
*    For an illustration of the Authorization tables see IRR@TPRV.   *
*                                                                    *
*    NAVIGATION:                                                     *
*    ------------------------------------------------------------    *
*    To make it easier to navigate this module, the following        *
*    character strings can be used to locate specific sections:      *
*                                                                    *
*    $XACSDESC - IRR@XACS prolog   - Authorization                   *
*    $XACSCODE - IRR@XACS mainline                                   *
*    $FRRDESC  - DSNX@FRR prolog   - Authorization Recovery          *
*    $FRRCODE  - DSNX@FRR mainline                                   *
*    $XAC1DESC - IRR@XAC1 prolog   - Initialization/Termination      *
*    $XAC1CODE - IRR@XAC1 mainline                                   *
*    $XMSGDESC - IRR@XMSG prolog   - Messages                        *
*    $XMSGCODE - IRR@XMSG mainline                                   *
*    $TOBJDESC - IRR@TOBJ prolog   - Object Table                    *
*    $TOBJCODE - IRR@TOBJ mainline                                   *
*    $TPRVDESC - IRR@TPRV prolog   - Privilege Table                 *
*    $TPRVCODE - IRR@TPRV mainline                                   *
*    $TRULDESC - IRR@TRUL prolog   - Rule Table                      *
*    $TRULCODE - IRR@TRUL mainline                                   *
*    $TRESDESC - IRR@TRES prolog   - Resource Table                  *
*    $TRESCODE - IRR@TRES mainline                                   *
*    $DSECTS   - DSECT definitions - For all routines                *
*    $MACROS   - Executable macros - For all routines                *
*                                                                    *
*    ------------------------------------------------------------    *
*                                                                    *
*                                                                    *
*    $SET                                                            *
*    ------------------------------------------------------------    *
*      Contains variables used to control the settable options       *
*      for the RACF/DB2 External Security Module.                    *
*                                                                    *
*      1) &CLASSOPT - Classification Model                           *
*         Allowable Values:                                          *
*         1 - Use Classification Model I.                            *
*             > Requires one set of DB2 general resource classes for *
*               each DB2 subsystem.                                  *
*             > Subsystem name is part of class name                 *
*         2 - Use Classification Model II                            *
*             > All DB2 subsystems share the same set of general     *
*               resource classes.                                    *
*             > Subsystem name is part of resource name              *
*         Default Value: '2'                                         *
*                                                                    *
*      2) &CLASSNMT - Class Name Root (ONLY USED WHEN &CLASSOPT='2') *
*         Allowable Values: Must be 1-4 characters                   *
*         Default Value: 'DSN'                                       *
*                                                                    *
*      3) &CHAROPT - Class Name Suffix (Used when &CLASSOPT='1' or   *
*                    &CLASSOPT='2' and &CLASSNMT is not 'DSN')       *
*         Allowable Values: Must be 1 character                      *
*         Default Value: '1'                                         *
*                                                                    *
*      See BLD_CLASS macro for a description of how the class        *
*      names are built.                                              *
*                                                                    *
*      4) &PCELLCT - CPOOL primary cell count                        *
*         &SCELLCT - CPOOL secondary cell count                      *
*         The values are used by IRR@XAC1 to specify the primary     *
*         and secondary cell counts on the CPOOL macro.  The primary *
*         cell count is the initial number of cells pre-allocated    *
*         by IRR@XAC1.  The secondary cell count is the number of    *
*         additional cells to be obtained (automatically) by         *
*         DSNX@XAC when there are no cells available for a GET       *
*         request.                                                   *
*                                                                    *
*      5) &ERROROPT - Action to take on exit error conditions    @09A*
*         Allowable Values:                                      @09A*
*         1 - Defer to DB2                                       @09A*
*         2 - Terminate DB2 subsystem                            @09A*
*         Default Value: '1'                                     @09A*
*                                                                    *
*02*   RECOVERY OPERATION:                                           *
*        Authorization requests (XAPLFUNC=2) are protected by the    *
*        FRR DSNX@FRR.  The FRR records diagnostic information,      *
*        frees resources, and percolates.                            *
*                                                                    *
*        Diagnostic information is recorded using the SDWA and       *
*        an SVC DUMP.  The SVC dump takes a summary dump and         *
*        records a copy of the dynamic storage used by DSNX@XAC for  *
*        authorization requests, the module DSNX@XAC's static        *
*        storage, the EXPL, the EXPL Work Area, and the XAPL.        *
*        At cleanup, the cell used for dynamic storage is            *
*        freed and the Access List Entry (DU-AL) is deleted if an    *
*        entry was created.                                          *
*                                                                    *
*        If this module is customized, the diagnositic information   *
*        must be updated to reflect the change.                      *
*                                                                    *
*01* NOTES:                                                          *
*                                                                    *
*02*   DEPENDENCIES:                                                 *
*        None.                                                       *
*                                                                    *
*02*   CHARACTER CODE DEPENDENCIES:                                  *
*        None.                                                       *
*                                                                    *
*02*   RESTRICTIONS:                                                 *
*        None.                                                       *
*                                                                    *
*02*   REGISTER CONVENTIONS:                                         *
*        R0      - Reserve for system macros                         *
*        R1      - Reserve for system macros                         *
*        R2      - Return code register                              *
*        R3      - XAPL base register                                *
*        R4-R8   - Work register for subroutines                     *
*        R9      - RULENTRY base register                            *
*        R10     - RESENTRY base register                            *
*        R11     - Data register                                     *
*        R12     - Code register                                     *
*        R13     - Savearea register                                 *
*        R14-R15 - BAL registers                                     *
*                                                                    *
*02*   PATCH LABEL:                                                  *
*        PATCH                                                       *
*                                                                    *
*01* MODULE TYPE:                                                    *
*      CSECT                                                         *
*                                                                    *
*02*   PROCESSOR:                                                    *
*        High Level Assembler                                        *
*                                                                    *
*02*   MODULE SIZE:                                                  *
*        See External Symbol Dictionary                              *
*                                                                    *
*02*   ATTRIBUTES:                                                   *
*03*     LOCATION:       Private                                     *
*03*     STATE:          Supervisor                                  *
*03*     AMODE:          31                                          *
*03*     RMODE:          Any                                         *
*03*     KEY:            Caller (7)                                  *
*03*     MODE:           Task or SRB                                 *
*03*     ASC MODE:       Primary                                     *
*03*     TYPE:           Reentrant                                   *
*03*     SERIALIZATION:  None                                        *
*                                                                    *
*                                                                    *
*01* ENTRY POINT:                                                    *
*      DSNX@XAC                                                      *
*                                                                    *
*02*   PURPOSE:      See FUNCTION section above                      *
*03*     OPERATION:  See OPERATION section above                     *
*03*     ATTRIBUTES: See ATTRIBUTES section above                    *
*                                                                    *
*02*   LINKAGE:                                                      *
*        BALR                                                        *
*03*     ENTRY REGISTERS:   Standard                                 *
*          0    - Irrelevant                                         *
*          1    - Parameter List Address                             *
*          2-12 - Irrelevant                                         *
*          13   - Save area address                                  *
*          14   - Return address                                     *
*          15   - Entry Point address                                *
*03*     CALLER: DB2                                                 *
*                                                                    *
*01* INPUT:                                                          *
*                                                                    *
*                           EXPL (mapped     Work Area - 4096 bytes  *
*                           by DSNDEXPL)     (Mapped by WA_MAP)      *
*         +---------+      +---------+      +---------------------+  *
*    R1-->| EXPLPTR |----->| EXPLWA  |----->| WA_SAVE             |  *
*         |---------|      |---------|      |                     |  *
*     ----| XAPLPTR |      | EXPLWL  |      |---------------------|  *
*     |   +---------+      |---------|      | WA_CPID             |  *
*     |                    | EXPLRC1 |      |---------------------|  *
*     |                    |---------|      | WA_CSIZE            |  *
*     |                    | EXPLRC2 |      |---------------------|  *
*     |                    +---------+      | WA_DFTACEE          |  *
*     |                                     |---------------------|  *
*     |                                     | .      .      .     |  *
*     |                                     |                     |  *
*     |                                     +---------------------+  *
*     |     XAPL (mapped                                             *
*     |     by DSNDXAPL)                                             *
*     |    +----------+                                              *
*     ---->| XAPLCBID |    ** NOTE: The EXPL work area is used as    *
*          |----------|             a communication area between     *
*          | XAPLLEN  |             the initialization and           *
*          |----------|             authorization requests.          *
*          | XAPLEYE  |                                              *
*          |----------|                                              *
*          | ...      |                                              *
*          |----------|                                              *
*          | ...      |                                              *
*          |----------|                                              *
*          | ...      |                                              *
*          +----------+                                              *
*                                                                    *
*     In the case of the Create View, DBADM_T Check the XAPLREL2 @08A*
*  contains an address in the first 4 bytes that points to a     @08A*
*  structure as follows:                                         @08A*
*                                                                @08A*
*           XAPL (mapped                                         @08A*
*           by DSNDXAPL)                                         @08A*
*          +----------+                                          @08A*
*          | ...      |                                          @08A*
*          |----------|                                          @08A*
*          | XAPLREL2 |---->+----------+                         @08A*
*          |----------|    0| XAPLDBNP | Points to next structure@08A*
*          | ...      |     |----------|                         @08A*
*          +----------+    4| XAPLDBNM | Database name           @08A*
*                           |----------|                         @08A*
*                          C| XAPLDBDA | User has DBADM on       @08A*
*                           |          | this database??         @08A*
*                           |          | 'Y' yes, 'U' unknown,   @08A*
*                           |          | or 'N' no.              @08A*
*                           |----------|                         @08A*
*                          D| XAPLRSV5 | Reserved                @08A*
*                           +----------+                         @08A*
*                                                                @08A*
*                                                                    *
*01* OUTPUT: (XAPLFUNC=2 only, See IRR@XAC1 for XAPLFUNC=1|3)        *
*     EXPLRC1 - Return Code                                          *
*     EXPLRC2 - Reason Code                                          *
*        Return Code:                                                *
*        0  - Access allowed                                         *
*             Reason Code:                                           *
*             0  - Access allowed by RACF profiles                   *
*             13 - Access allowed by implicit privilege of ownership *
*             14 - Access allowed by implicit privilege of       @L1A*
*                  schema name equal to user ID                  @L1A*
*        4  - Cannot determine, perform DB2 Authorization checking   *
*             Reason Code:                                           *
*             11 - Unable to obtain default ACEE (and no input ACEE) *
*             14 - Unable to obtain ALET for cross memory ACEE       *
*             15 - Input privilege is not defined to exit            *
*             16 - No rules were found for input privilege           *
*        8  - Access denied                                          *
*             Reason Code:                                           *
*             0  - Access denied by RACF profiles                    *
*             17 - AUTOBIND requested: A manual BIND must be         *
*                  performed.                                    @L1A*
*     XAPLONWT - (UPDATE and REFERENCES table privileges)            *
*        ' ' - Requestor has privilege on whole table                *
*        '*' - Requestor has privilege on this column only           *
*     XAPLDIAG - Will contain return and reason codes from           *
*                RACROUTE REQUEST=FASTAUTH.  This area is mapped     *
*                by DIAGDSCT.                                        *
*     XAPLDBDA - Information required by DB2V7 from the exit     @08A*
*                routine for CRTVUAUT.  'Y' if user has          @08A*
*                DBADM on this database, 'U' if unknown or 'N'   @08A*
*                if not allowed.                                 @08A*
*                                                                    *
*                                                                    *
*01* EXIT NORMAL:                                                    *
*      BR 14 to caller                                               *
*                                                                    *
*02*   CONDITIONS:                                                   *
*        Successful completion of function                           *
*03*     EXIT REGISTERS:                                             *
*          0 - 15 - Restored to contents on entry                    *
*                                                                    *
*02*   RETURN CODES:                                                 *
*        (See OUTPUT)                                                *
*                                                                    *
*02*   WAIT STATE CODES:                                             *
*        None                                                        *
*                                                                    *
*01* EXIT ERROR:                                                     *
*      None.                                                         *
*                                                                    *
*02*   CONDITIONS:                                                   *
*        None                                                        *
*03*     EXIT REGISTERS:                                             *
*          N/A                                                       *
*                                                                    *
*02*   RETURN CODES:                                                 *
*        None.                                                       *
*                                                                    *
*02*   WAIT STATE CODES:                                             *
*        None                                                        *
*                                                                    *
*01* EXTERNAL REFERENCES:                                            *
*                                                                    *
*02*   ROUTINES:                                                     *
*        IRR@XAC1                                                    *
*                                                                    *
*02*   PANELS:                                                       *
*        None                                                        *
*                                                                    *
*02*   DIALOG VARIABLES:                                             *
*        None                                                        *
*                                                                    *
*02*   DATA AREAS:                                                   *
*        None                                                        *
*                                                                    *
*02*   CONTROL BLOCKS:                                               *
*    Macro Name   Description                                        *
*    ----------  -----------------------------------------           *
*     CVT         Communications Vector Table                        *
*     IHAACEE     RACF Accessor Environment Element                  *
*     IHASDWA     System Diagnostic Work Area                        *
*     IHAPSA      Prefixed Save Area                                 *
*                                                                    *
*01* TABLES:                                                         *
*    Name         Description                                        *
*    ----------  -----------------------------------------           *
*    IRR@TPRV     Privilege Table (mapped by PRVDSECT)               *
*    IRR@TRUL     Rule Table (mapped by RULDSECT)                    *
*    IRR@TRES     Resource Table (mapped by RULDSECT)                *
*                                                                    *
*                                                                    *
*01* MACROS:                                                         *
*                                                                    *
*02*   MAPPING:                                                      *
*    Macro Name   Description                                        *
*    ----------  ----------------------------------------            *
*    CVT         Communications Vector Table                         *
*    DSNDEXPL    DB2 Installation Exit parameter list                *
*    DSNDXAPL    DB2 Access Control Authorization Exit parm list     *
*    DSNXAPRV    DB2 Access Control Authorization Exit equates       *
*    ICHSAFP     SAF Router parameter list                           *
*    IHAACEE     RACF Accessor Environment Element                   *
*    IHAFRRS     Function Recovery Routine Stack                     *
*    IHAPSA      Prefixed Save Area                                  *
*    IHASDWA     System Diagnostic Work Area                         *
*                                                                    *
*02*   EXECUTABLE:                                                   *
*    Macro Name   Description                                        *
*    ----------  ----------------------------------------            *
*                                                                    *
*01* SERIALIZATION:                                                  *
*      None.                                                         *
*                                                                    *
*                                                                    *
*01* MESSAGES:                                                       *
*     (See IRR@XAC1)                                                 *
*                                                                    *
*                                                                    *
*01* ABEND CODES:                                                    *
*      This module issues no ABENDs.                                 *
*                                                                    *
*01* CHANGE ACTIVITY:                                                *
*                                                                    *
*    Flag Reason Release Date   Origin Description                   *
*    ------------------------------------------------------------    *
*    $L0=DB2      HRF2240 961023 PDM_J1:                             *
*    $00=OW26250  HRF2240 970327 PDM_J1: TRSQ PTM PT50062        @00A*
*    $01=OW26250  HRF2240 970327 PDM_J1: TRSQ PTM PT50063        @01A*
*    $02=OW26250  HRF2240 970415 PDAWS1: TRSQ PTM PT50060        @02A*
*    $03=OW26840  HRF2240 970415 PDM_J1: TRSQ PTM PT50067        @03A*
*    $04=OW29366  HRF2240 970915 PDM_J1: APAR OW29366            @04A*
*    $05=OW29367  HRF2240 970915 PDM_J1: APAR OW29367            @05A*
*    $06=OW36601  HRF2608 990301 PDAMH2: APAR OW36601            @06A*
*    $L1=OW38710  HRF2608 990425 PDMAN1: APAR OW38710            @L1A*
*    $L2=OW38710  HRF2608 990425 PDCRL1: APAR OW38710            @L2A*
*    $07=OW42534  HRF2608 000127 PDCGK1: APAR OW42534            @07A*
*    $08=OW45152  HRF7703 000620 PDJJP1: APAR OW45152            @08A*
*    $09=OW45152  HRF7703 010111 PDMAN1: APAR OW45152            @09A*
*    $0A=OW57072  HRF7703 021111 PDMAN1: APAR OW57072            @0AA*
*    $0B=OW57299  HRF7703 021231 PDMAN1: APAR OW57299            @0BA*
*    $L3=0A05967  HRF7708 040114 PDMAN1: APAR OA05967            @L3A*
*    $0C=OA12836  HRF7730 051026 PDAJB1: APAR OA12836            @0CA*
*                                                                    *
*01* CHANGE DESCRIPTIONS:                                            *
*    A000000-999999 Original code                                    *
*    C - Change ROUTCDE and DESC for messages IRR904I-IRR911I so @00A*
*        they do not appear in the list of messages requiring    @00A*
*        operator action.                                        @00A*
*    C - Changed the layout for messages IRR900A-IRR907I so they @01A*
*        are neatly formatted on the operator console. Also      @01A*
*        updated the text to use the correct wording.            @01A*
*    A - Provide more meaningful information in LOGSTR data and  @02A*
*        only save the resource name if the resource is to be    @02A*
*        audited.                                                @02A*
*    C - Bypass default ACEE creation and defer to DB2 when an   @03A*
*        input ACEE is not provided for authority checking.      @03A*
*    C - Remove ownership check for QUALAUT and CNVRTAUT         @04A*
*    C - Scan DB2 resource names back to front to prevent        @05A*
*        truncation of DB2 resource names containing blanks      @05A*
*    C - Database name is missing in the entity name for         @06A*
*        'USE' privilege of tablespaces.                         @06A*
*    A - Added support for new DB2 resources (schemas, distinct  @L1A*
*        types (UDT), functions (UDF), and stored procedures.    @L1A*
*        Also added the TRIGGER  (55) privilege for tables.  The @L1A*
*        new privileges that are introduced are ALTERIN (252),   @L1A
*        CREATEIN (261), DROPIN (262) and USAGE (263).           @L1A*
*    C - Added implicit ownership for BIND privilege (PLANS)     @L2A*
*        and BIND and COPY privileges (PACKAGES)                 @L2A*
*    A - Add logic to define a set of symbols if they have not   @07A*
*        been defined.                                           @07A*
*    A - Add logic to handle the passing of the database names   @08A*
*        in the XAPLREL2 field for the DBADM checks for CREATE   @08A*
*        VIEW.                                                   @08A*
*        Add JAR Object with USAGEAUTJ privilege code 263.       @08A*
*    A - Add support to for the &ERROROPT= keyword which allows  @09A*
*        an installation to tell the DB2 subsystem to terminate  @09A*
*        if a return code 12, an abend, or an unexpected         @09A*
*        return code is returned. This processing is only        @09A*
*        performed for DB2 Version 7 or later.                   @09A*
*    A - Correct the initialization of DBINFPTR so that the      @0AA*
*        creation of a VIEW on another VIEW works correctly.     @0AA*
*    A - Add support for XAPLTYPE=V for views and the associated @0BA*
*        XAPLPRIVs of ANYTBAUT(233), COMNTAUT(097),              @0BA*
*        DELETAUT(052), DROPAUT(073), INSRTAUT(051),             @0BA*
*        SELCTAUT(050), and UPDTEAUT(053).                       @0BA*
*    A-  Issue message IRR914I if this exit (which supports      @L3A*
*        DB2 versions less than 8) is invoked by a DB2 V8        @L3A*
*        environment. &ERROROPT has been reset to its correct    @L3A*
*        default value as well ('1', which is defer to DB2).     @L3A*
*    C-  Length included in msg irr908i is incorrect -- does     @0CA*
*        not include TRANSTAB.                                   @0CA*
*    CAUTION: check XACS_TOTAL_LEN and XACS_TOTAL_LEN1 when      @0CA*
*        adding code to this module.                             @0CA*
*
**********************************************************************
         EJECT
         TITLE 'RACF/DB2 External Security Module - DSECTS'
         PRINT OFF
*----------------------------------------------------------------------
* $DSECTS- Non-executable Macros
*      Contains the following:
*        1) Register Equates
*        2) Object Table DSECTS
*        3) Privilege Table DSECTS
*        4) Rule Table DSECTS
*        5) Resource Table DSECTS
*        6) EXPLWA DSECT
*        7) XAPLDIAG DSECT
*        8) FRR parameter DSECT
*
*----------------------------------------------------------------------
         MACRO
&NAME    REGS
*----------------------------------------------------------------------
*  EQUATES FOR REGISTERS
*----------------------------------------------------------------------
R0       EQU   0
R1       EQU   1
R2       EQU   2
R3       EQU   3
R4       EQU   4
R5       EQU   5
R6       EQU   6
R7       EQU   7
R8       EQU   8
R9       EQU   9
R10      EQU   10
R11      EQU   11
R12      EQU   12
R13      EQU   13                  SAVEAREA
R14      EQU   14
R15      EQU   15
         MEND
         MACRO
         OBJDSECT
***********************************************************************
*  Object Table DSECTS - mappings for IRR@TOBJ
***********************************************************************
         SPACE 1
OBJTABHD DSECT
OBJEYEC  DS   CL8
OBJFMID  DS   CL8
OBJDATE  DS   CL8
OBJTIME  DS   CL8
OBJNUM   DS   H                   Number of DB2 objects
         DS   CL2
OBJHDLEN EQU  *-OBJTABHD
*
OBJENTRY DSECT
OBJTYPE  DS   CL1                 One character object abbreviation
OBJABBRV DS   CL3                 Two character class abbreviation
OBJENTLN EQU  *-OBJENTRY
         MEND
*----------------------------------------------------------------------
         MACRO
         PRVDSECT
***********************************************************************
*  Privilege Table DSECTs - mappings for IRR@TPRV
***********************************************************************
         SPACE 1
PRVTABHD DSECT
PRVEYEC  DS   CL8
PRVFMID  DS   CL8
PRVDATE  DS   CL8
PRVTIME  DS   CL8
PRVTXNUM DS   1F
PRVTHDLN EQU  *-PRVTABHD
PRVINDEX DS   264F                                                 @L1A
PRVIDXLN EQU  L'PRVINDEX
*
PRVENTHD DSECT
PRVCODE  DS    1H                 Privilege code
PRVNAME  DS    CL8                Privilege name
PRVNUM   DS    1H                 Number of objects using privilege
PRVEHDLN EQU  *-PRVENTHD          Length of privilege entry header
PRVARRAY DS    0H                 Array of privilege Entries
*
PRVENTRY DSECT
PRVOBJT  DS    CL1                Object Type
         DS    CL3                reserved
PRVRULE@ DS    A                  Address of associated rule table
PRVENTLN EQU  *-PRVENTRY
         MEND
*----------------------------------------------------------------------
         MACRO
         RULDSECT
***********************************************************************
*  Rule Table DSECTs - mappings for IRR@TRUL
***********************************************************************
         SPACE 1
RULTABHD DSECT
RULEYEC  DS   CL8
RULFMID  DS   CL8
RULDATE  DS   CL8
RULTIME  DS   CL8
RULTHDLN EQU  *-RULTABHD
*
RULENTHD DSECT
RULPRIV  DS    1H                 Privilege Number
RULOBJT  DS    CL1                Object type
         DS    CL3
RULNUM   DS    1H                 Number of rules for this privilege
RULEHDLN EQU  *-RULENTHD
RULARRAY DS    0H
*
RULENTRY DSECT
RULRES@  DS    A                  Address of associated resource entry
RULENTLN EQU  *-RULENTRY
         MEND
*----------------------------------------------------------------------
         MACRO
         RESDSECT
***********************************************************************
*  Resource Table DSECTs - mappings for IRR@TRES
***********************************************************************
         SPACE 1
RESTABHD DSECT
RESEYEC  DS   CL8
RESFMID  DS   CL8
RESDATE  DS   CL8
RESTIME  DS   CL8
RESHDLEN EQU  *-RESTABHD
*
*
RESENTRY DSECT
         DS    0F
RESTYPE  DS    1H                   Resource Type
RESADM   EQU   1                    ADM class resource entry
RESOWN   EQU   2                    Object owner resource entry
RESOBJ   EQU   4                    Object class resource entry
RESCLASL DS    H                    Class Abbreviation length      @05A
RESCLASS DS    CL3                  Class Abbreviation
RESATTR  DS    XL1                  Access authority required
*                                   RACF entity name qualifiers    @05A
RESQ1    DS    0CL(RESQLEN)         First Object Name Qualifier    @05C
RESQ1OFF DS    Y                    First Object Qualifier Offset
RESQ1LEN DS    H                    First Object Qualifier Length
RESQ1LD  DS    Y                    Autodata: length desc offset   @05A
*
RESQ2    DS    0CL(RESQLEN)         Second Object Name Qualifier   @05C
RESQ2OFF DS    Y                    Second Object Qualifier Offset
RESQ2LEN DS    H                    Second Object Qualifier Length
RESQ2LD  DS    Y                    Autodata: length desc offset   @05A
*
RESCOL   DS    0CL(RESQLEN)         Column Qualifier               @05C
RESCOLOF DS    Y                    Column Qualifier Offset
RESCOLLN DS    H                    Column Qualifier Length
RESCOLLD DS    Y                    Autodata: length desc offset   @05A
*
RESOWNR  DS    0CL(RESQLEN)         Resource Owner information     @05C
RESOWNOF DS    Y                    Owner Offset
RESOWNLN DS    H                    Owner Length
RESOWNLD DS    Y                    Autodata: length desc offset   @05A
*
RESAUTHL DS    H                    Authority Qualifier Length     @05A
RESAUTH  DS    CL20                 Authority Qualifier
RESENTLN EQU  *-RESENTRY
*                                                                  @05A
RESQUAL  DSECT
RESQXOFF DS    Y                    XAPL: qualifier offset         @05A
RESQXLEN DS    H                    XAPL: qualifier length         @05A
RESQLDOF DS    Y                    Autodata: length desc offset   @05A
RESQLEN  EQU  *-RESQUAL                                            @05A
         MEND
*----------------------------------------------------------------------
         MACRO
         DIAGDSCT
***********************************************************************
*  XAPLDIAG Mapping for RACROUTE return codes
***********************************************************************
DIAGMAP  DSECT
DIAGSRET DS CL1
DIAGRRET DS CL1
DIAGRRSN DS CL2
DIAGMAPL EQU *-DIAGSRET
         MEND
*----------------------------------------------------------------------
         MACRO
         WADSCT
***********************************************************************
*  EXPL Work Area DSECT - Maps EXPLWA
*    The EXPL work area is used for communication between the different
*    functions of the Authorization Exit (Initialization, Termination
*    and Authorization).  The following information can be found in
*    the work area:
*       WA_SAVE    - Save area used by DSNX@XAC.  This save area is
*                    only used by DSNX@XAC for initialization and
*                    termination requests.
*       WA_CPID    - Contains the cell pool ID.  The cell pool provides
*                    a re-entrant workarea for authorization requests.
*                    The cell pool is created by IRR@XAC1 and cells
*                    are requested by DSNX@XAC.
*                    Set By:  IRR@XAC1
*                    Used By: DSNX@XAC
*       WA_CSIZE   - Contains the cell size.  This is the number of
*                    bytes needed by DSNX@XAC for each concurrent
*                    authorization request.
*                    Set By:  DSNX@XAC
*                    Used By: IRR@XAC1
*       WA_DFTACEE - Contains the default ACEE address.  IRR@XAC1
*                    creates a default ACEE to be used on authorization
*                    requests for which an ACEE has not been provided.
*                    Set By:  IRR@XAC1
*                    Used By: DSNX@XAC
*
***********************************************************************
WA_MAP     DSECT
WA_SAVE    DS 18F                   Save area for DSNX@XAC
WA_CPID    DS A                     Cell Pool ID
WA_CSIZE   DS A                     Cell Pool cell size
WA_DFTACEE DS A                     Default ACEE address
WA_LEN     EQU *-WA_MAP
           MEND
*----------------------------------------------------------------------
         MACRO
         FRRDSCT
***********************************************************************
*  FRRDSCT - Mapping for the 24-byte FRR parameter area.
***********************************************************************
FRR_PARMP     DSECT
FRR_EXPL      DS A
FRR_XAPL      DS A
FRR_CELLP     DS A
FRR_CODEP     DS A
              DS CL8
         MEND
         EJECT
         TITLE 'RACF/DB2 External Security Module - MACROS'
*----------------------------------------------------------------------
* $MACROS - Executable Macros
*      Contains the following executable macros:
*        1) PRIVILEGE - Generates Privilege Table entries
*        2) RULE      - Generates Rule Table entries
*        3) RESOURCE  - Generates Resource Table entries
*        4) BLD_CLASS - Builds a class name from class abbreviation
*        5) STRLEN    - Determine length of character string.      @05C
*                       Includes intermediate blank characters.    @05C
*        6) MOVEQUAL  - Move data from input parameter list to the @05A
*                       current resource name being built.         @05A
*
*      See individual macros for the macro syntax.
*----------------------------------------------------------------------
.*---------------------------------------------------------------------
.* PRIVILEGE Macro
.*   Generate an entry for the Privilege Table, IRR@TPRV.
.*   Entries are mapped by PRVDSECT.
.*
.*   Parameters:
.*     &PrvCode   - Required: Privilege Code being defined
.*                            (halfword decimal)
.*     &Object    - Required: List of objects for which privilege
.*                            applies (must use the one character
.*                            object type abbreviation)
.*     &PrvName   - Optional: Privilege Name being defined
.*                            (up to 8 characters)
.*---------------------------------------------------------------------
          MACRO
          PRIVILEGE &PRVCODE=,&PRVNAME=,&OBJECT=
.* Validate Required Parameters
          AIF   ('&PRVCODE' EQ '').NOPRVC
          AIF   ('&OBJECT' EQ '').NOOBJ
          AGO   .NOERRS
.*
.* MNOTES for error conditions
.NOPRVC   ANOP
          MNOTE 8,'MACRO''PRIVILEGE'' FAILED, PRVCODE= NOT SPECIFIED.'
          MEXIT
.NOOBJ    ANOP
          MNOTE 8,'MACRO''PRIVILEGE'' FAILED, OBJECT= NOT SPECIFIED.'
          MEXIT
.*
.* Required paramters are present, continue processing
.NOERRS   ANOP
PRIV&PRVCODE DS 0F
          DC    H'&PRVCODE'                Privilege Code
          AIF   ('&PRVNAME' EQ '').NONME
          DC    CL8'&PRVNAME'              Privilege Name
          AGO   .ENDNONME
.NONME    ANOP
          DC    CL8' '                     No Privilege Name
.ENDNONME ANOP
&NUM      SETA  N'&OBJECT
          DC    H'&NUM'                    Number of objects
*
.* Generate declare for each object type
&I        SETA  1
.NEXT     ANOP
          DC    CL1'&OBJECT(&I)'           Object Type
          DS    CL3                        reserved
          DC    A(RUL&OBJECT(&I).&PRVCODE) Address of Rule Table
&I        SETA  &I+1
          AIF   (&I LE &NUM).NEXT
*
*----------------------------------------------------------------------
          MEND
          EJECT
.*---------------------------------------------------------------------
.* Rule Macro
.*   Generate an entry for the Rule Table, IRR@TRUL.
.*   Entries are mapped by RULDSECT.
.*
.*   Parameters:
.*     &Priv      - Required: List of privilege codes for which rule
.*                            applies (must match a privilege defined
.*                            in IRR@TPRV)
.*     &Object    - Required: Object type associated with rule (Must
.*                            use the one character abbreviation)
.*     &Res       - Optional: List of resources to check for this rule
.*                            (must match a resource name in IRR@TRES)
.*
.*---------------------------------------------------------------------
          MACRO
          RULE &PRIV=,&OBJECT=,&RES=
.* Validate required parameters
          AIF   ('&PRIV' EQ '').NOPRIV
          AIF   ('&OBJECT' EQ '').NOOBJ
          AGO   .NOERRS
.* MNOTES for error conditions
.NOPRIV   ANOP
          MNOTE 8,'MACRO''RULE'' FAILED, PRIV= WAS NOT SPECIFIED.'
          MEXIT
.NOOBJ    ANOP
          MNOTE 8,'MACRO''RULE'' FAILED, OBJECT= WAS NOT SPECIFIED.'
          MEXIT
.* Create an entry statement for each privilege
.NOERRS   ANOP
&NUMPRIV  SETA  N'&PRIV
&NUMRES   SETA  N'&RES
RUL&OBJECT.&PRIV(1) DS  0F
&I        SETA  2
          AIF   (&I GT &NUMPRIV).HEADER
.* Create a label for each privilege
.NEXTPRV2 ANOP
RUL&OBJECT.&PRIV(&I) DS 0H
&I        SETA  &I+1
          AIF   (&I LE &NUMPRIV).NEXTPRV2
.* Generate entry header
.HEADER   ANOP
          DC    H'&PRIV(1)'          Privilege Code
          DC    CL1'&OBJECT'         Object Type
          DS    CL3                  reserved
          DC    H'&NUMRES'           Number of Rules
*
.* Generate declare for each resource
          AIF   (&NUMRES EQ 0).NORES
&I        SETA  1
.NEXTRES  ANOP
          DC    A(&RES(&I))          Resource Table Entry Address
&I        SETA  &I+1
          AIF   (&I LE &NUMRES).NEXTRES
.NORES    ANOP
          MEND
          EJECT
.*---------------------------------------------------------------------
.* RESOURCE Macro
.*   Generate an entry for the resource table, IRR@TRES.
.*   Entries are mapped by RESDSECT.
.*
.*   Parameters:
.*     &Name      - Required: Name of resource entry (max 8 characters)
.*                            (must match name used in rule table)
.*     &Authority - Optional: Name of DB2 Privilege
.*     &Class     - Optional: Name of DB2 general resource class
.*     &Object    - Optional: Name of XAPL field(s) containing object
.*                            qualifier
.*     &Column    - Optional: Name of XAPL field containing column name
.*     &Owner     - Optional: Name of XAPL field containing object
.*                            owner
.*     &Access    - Optional: RACF access authority required for this
.*                            resource (Default READ)
.*
.*---------------------------------------------------------------------
         MACRO
         RESOURCE &NAME=,&AUTHORITY=,&CLASS=,                          X
               &OBJECT=(,),&OWNER=,&COLUMN=,&ACCESS=
.* Validate required parameters
          AIF   ('&NAME' EQ '').NONAME
          AGO   .NOERRS
.* MNOTES for error conditions
.NONAME   ANOP
          MNOTE 8,'MACRO''RESOURCE'' FAILED, NAME= WAS NOT SPECIFIED.'
          MEXIT
.* No errors, generate the resource table entry
.NOERRS  ANOP
&NAME    DS    0F
.* Determine resource type
         AIF   ('&CLASS' EQ 'ADM').TYPEADM
         AIF   ('&CLASS' EQ '').TYPEOWN
         DC    H'4'                 Type: Object class resource entry
         AGO   .ENDTYPE
.TYPEADM ANOP
         DC    H'1'                 Type: ADM class resource entry
         AGO   .ENDTYPE
.TYPEOWN ANOP
         DC    H'2'                 Type: Owner resource entry
.ENDTYPE ANOP
.* Process class abbreviation
.CLASS   ANOP
         AIF   ('&CLASS' EQ '').NOCLASS
&LEN     SETA  K'&CLASS                                            @05A
         DC    H'&LEN'              Class Abbreviation length      @05A
         DC    CL3'&CLASS'          Class Abbreviation
         AGO   .ENDCLAS
.NOCLASS ANOP
         DC    H'0'                 No Class Abbreviation Length   @05A
         DC    CL3'   '             No Class Abbreviation
.ENDCLAS ANOP
.* Process Access Level
.ACCESS  ANOP
         AIF   ('&CLASS' EQ '').NOACC
         AIF   ('&ACCESS' EQ '').READ
         AIF   ('&ACCESS' EQ 'READ').READ
         AIF   ('&ACCESS' EQ 'UPDATE').UPDATE
         AIF   ('&ACCESS' EQ 'CONTROL').CONTROL
         AIF   ('&ACCESS' EQ 'ALTER').ALTER
.READ    ANOP
         DC    X'02'                READ access
         AGO   .ENDACC
.UPDATE  ANOP
         DC    X'04'                UPDATE access
         AGO   .ENDACC
.CONTROL ANOP
         DC    X'08'                CONTROL access
         AGO   .ENDACC
.ALTER   ANOP
         DC    X'80'                ALTER access
         AGO   .ENDACC
.NOACC   ANOP
         DC    X'00'                No access level                @05C
.ENDACC  ANOP
.*                                                                1@05D
.* Process first object qualifier
         AIF   ('&OBJECT(1)' EQ '').NOQUAL1
         DC    Y(&OBJECT(1)-XAPL)   First Object Qualifier Offset
&LEN     SETA  L'&OBJECT(1)
         DC    H'&LEN'              First Object Qualifier Length
&TEMP    SETC  '&OBJECT(1)'(5,*)    Strip off 'XAPL'               @05A
         DC    Y(LD$&TEMP-@DATD)    Length descriptor offset       @05A
         AGO   .ENDQ1
.NOQUAL1 ANOP
         DC    3H'0'                No First Qualifier             @05C
.ENDQ1   ANOP
.* Process second object qualifier
.QUAL2   ANOP
         AIF   ('&OBJECT(2)' EQ '').NOQUAL2
         DC    Y(&OBJECT(2)-XAPL)   Second Object Qualifier Offset
&LEN     SETA  L'&OBJECT(2)
         DC    H'&LEN'              Second Object Qualifier Length
&TEMP    SETC  '&OBJECT(2)'(5,*)    Strip off 'XAPL'               @05A
         DC    Y(LD$&TEMP-@DATD)    Length descriptor offset       @05A
         AGO   .ENDQ2
.NOQUAL2 ANOP
         DC    3H'0'                No Second Qualifier            @05C
.ENDQ2   ANOP
.* Process Column qualifier
.COLUMN  ANOP
         AIF   ('&COLUMN' EQ '').NOCOL
         DC    Y(&COLUMN-XAPL)      Column Qualifier Offset
&LEN     SETA  L'&COLUMN
         DC    H'&LEN'              Column Qualifier Length
&TEMP    SETC  '&COLUMN'(5,*)       Strip off 'XAPL'               @05A
         DC    Y(LD$&TEMP-@DATD)    Length descriptor offset       @05A
         AGO   .ENDCOL
.NOCOL   ANOP
         DC    3H'0'                No Column Qualifier            @05C
.ENDCOL  ANOP
.* Process Object Owner - NOT A QUALIFIER
.OWNER   ANOP
         AIF   ('&OWNER' EQ '').NOOWNER
         DC    Y(&OWNER-XAPL)       Object Owner Offset
&LEN     SETA  L'&OWNER
         DC    H'&LEN'              Object Owner Length
&TEMP    SETC  '&OWNER'(5,*)        Strip off 'XAPL'               @05A
         DC    Y(LD$&TEMP-@DATD)    Length descriptor offset       @05A
         AGO   .ENDOWN
.NOOWNER ANOP
         DC    3H'0'                No Owner Qualifier             @05C
.ENDOWN  ANOP
.* Process AUthority Qualifier
         AIF   ('&AUTHORITY' EQ '').NOAUTH
&AUTHL   SETA  K'&AUTHORITY         Length of operand              @05A
         DC    H'&AUTHL'            Authority Length               @L1C
         DC    CL20'&AUTHORITY'     Authority Qualifier
         AGO   .ENDAUTH
.NOAUTH  ANOP
         DC    H'0'                 No Authority Qualifier         @05A
         DC    CL20' '              No Authority Qualifier
.ENDAUTH ANOP
*
*----------------------------------------------------------------------
.EXIT    ANOP
         MEND
         EJECT
.*---------------------------------------------------------------------
.*
.* BLD_CLASS Macro:
.*   Construct RACF general resource class names according to the
.*   classification model being used:
.*
.*   For Classification Model I (&ClassOpt = 1):
.*
.*    prefix || XAPLGPAT || class_abbreviation || &CHAROPT
.*
.*    where,
.*        prefix             = M (except for ADM class)
.*        XAPLGPAT           = DB2 subsystem or data sharing group
.*        class_abbreviation = two or three character object type
.*                             abbreviation
.*        &CHAROPT           = Customer defined suffix character
.*
.*   For Classification Model II (&ClassOpt = 2):
.*
.*    prefix || &CLASSNMT || class_abbreviation || &CHAROPT
.*
.*    where,
.*        prefix             = M (except for ADM class)
.*        &CLASSNMT          = Customer defined class root
.*                             (Default value is 'DSN')
.*        class_abbreviation = two or three character object type
.*                             abbreviation
.*        &CHAROPT           = Customer defined suffix character
.*                             (Ignored if using default &CLASSNMT)
.*
.*
.*   Parameters:
.*     &ClassAbbr - (input)  Name of 3 byte field w/ class abbreviation
.*     &ClassName - (outupt) Name of 8 byte field to receive class name
.*     &SAVE      - (input)  Name of 72 byte register save area
.*
.*---------------------------------------------------------------------
         MACRO
         BLD_CLASS &ClassAbbr=,&ClassName=,&SAVE=
         GBLC  &CLASSOPT,&CLASSNMT,&CHAROPT,&RTNSUFX,&ERROROPT     @09C
.*---------------------------------------------------------------------
.* Parameter Validation:
.*---------------------------------------------------------------------
         AIF   ('&ClassName' EQ '').NOCLASS
         AIF   ('&ClassAbbr' EQ '').NOABBR
         AIF   ('&CLASSOPT' NE '1' AND '&CLASSOPT' NE '2').BADOPT
         AIF   ('&ERROROPT' NE '1' AND '&ERROROPT' NE '2').BADEOPT @09A
         AIF   ('&CLASSOPT' EQ '2' AND '&CLASSNMT' EQ '').BADNMT
         AGO   .BUILD
.* MNOTES for error conditions
.NOABBR  ANOP
         MNOTE 8,'MACRO''BLD_CLASS'' FAILED, CLASSABBR NOT SPECIFIED.'
         MEXIT
.NOCLASS ANOP
         MNOTE 8,'MACRO''BLD_CLASS'' FAILED, CLASSNAME NOT SPECIFIED.'
         MEXIT
.BADOPT  ANOP
         MNOTE 8,'MACRO''BLD_CLASS'' FAILED, CLASSOPT NOT VALID.'
         MEXIT
.BADEOPT ANOP                                                     @09A
         MNOTE 8,'ERROROPT NOT VALID.'                            @09A
         MEXIT                                                    @09A
.BADNMT  ANOP
         MNOTE 8,'MACRO''BLD_CLASS'' FAILED, CLASSNMT NOT SPECIFIED.'
         MEXIT
.BUILD   ANOP
*----------------------------------------------------------------------
* Build the class name
*----------------------------------------------------------------------
            B     BC&SYSNDX.A               Branch around declares
            AIF   ('&CLASSNMT' EQ '').NONMT
NMT&SYSNDX  DC    C'&CLASSNMT'              Declare for &CLASSNMT  @05C
.NONMT      ANOP
ADM&SYSNDX  DC    CL3'ADM'
BLS&SYSNDX  DC    CL8' '
            AIF   ('&CHAROPT' EQ '').NOSUF1
SUF&SYSNDX  DC    CL1'&CHAROPT'
.NOSUF1     ANOP
BC&SYSNDX.A DS    0H
            SPACE
            AIF   ('&SAVE' EQ '').NOSAVE1
            STM   R4,R6,&SAVE               Save work registers
.NOSAVE1    ANOP
            LA    R5,&ClassName             Get address of result area
*                                                                 4@05D
            MVC   0(L'&ClassName,R5),BLS&SYSNDX  Clear result area
*----------------------------------------------------------------------
* Class Prefix
*----------------------------------------------------------------------
            CLC   &CLASSABBR,ADM&SYSNDX     ADM class?
            BE    BC&SYSNDX.B               Yes, no prefix
            MVI   0(R5),C'M'                Move in prefix (M)
            LA    R5,1(,R5)                 Bump result area ptr   @05C
            LA    R6,2                      object class abbr len  @05A
            B     BC&SYSNDX.C               skip ADM class length  @05A
BC&SYSNDX.B DS    0H
            LA    R6,3                      ADM class abbr length  @05A
BC&SYSNDX.C DS    0H                                               @05A
            AIF   ('&CLASSOPT' NE '2').MODEL1
*----------------------------------------------------------------------
* Class Root - &CLASSNMT
*----------------------------------------------------------------------
            MVC   0(L'NMT&SYSNDX,R5),NMT&SYSNDX Move in &CLASSNMT value
            LA    R5,L'NMT&SYSNDX.(,R5)     Bump result area ptr   @05C
            AGO   .ABBR
*----------------------------------------------------------------------
* Class Root - XAPLGPAT
*----------------------------------------------------------------------
.MODEL1     ANOP
            MVC   0(L'XAPLGPAT,R5),XAPLGPAT Move in XAPLGPAT value
            AH    R5,LEN$GPAT&RTNSUFX       Get GPAT string length @05C
.ABBR       ANOP
*----------------------------------------------------------------------
* DB2 Object Abbreviation
*----------------------------------------------------------------------
            MVC   0(L'&ClassAbbr,R5),&ClassAbbr Copy class abbrev
            AR    R5,R6                     Bump result area ptr   @05C
.* Class Suffix - &CHAROPT
            AIF   ('&CLASSOPT' EQ '1').SUFFIX
.* Classification Model II
            AIF   ('&CLASSNMT' EQ 'DSN').NOSUFX
.SUFFIX     ANOP
*----------------------------------------------------------------------
* Class Suffix - &CHAROPT
*----------------------------------------------------------------------
            AIF   ('&CHAROPT' EQ '').NOSUFX
            MVC   0(L'SUF&SYSNDX,R5),SUF&SYSNDX
.NOSUFX     ANOP
            AIF   ('&SAVE' EQ '').NOSAVE2
            LM    R4,R6,&SAVE
.NOSAVE2    ANOP
         MEND
         EJECT
.*---------------------------------------------------------------------
.*
.* STRLEN Macro
.*   Calculate the length of a character string.  This macro will  @05C
.*   scan a character string buffer back to front until it finds   @05C
.*   the first non-blank/non-null character.                       @05A
.*
.*   Parameters:
.*     &BUF    - (input/reg)    Address of buffer with string      @05C
.*     &BUFLEN - (input/reg)    Length of buffer being scanned     @05C
.*               (output/reg)   Length of string                   @05C
.*
.*---------------------------------------------------------------------
         MACRO
         STRLEN   &BUF=,&BUFLEN=
.*---------------------------------------------------------------------
.*        Starting at the end of the character string buffer scan
.*        backwards to locate the first non-blank character.
.*-----------------------------------------------------------------@05C
            AR    &BUFLEN,&BUF              Start scan from EOB    @05C
            BCTR  &BUFLEN,0                 Point at last slot     @05C

SL&SYSNDX.A DS    0H                        scan for string end    @05C
            CLI   0(&BUFLEN),X'40'          Test current character @05C
            BE    SL&SYSNDX.N               blank, check next      @05C
            CLI   0(&BUFLEN),X'00'          Test current character @05C
            BNE   SL&SYSNDX.B               non-null/blank, quit   @05C
SL&SYSNDX.N DS    0H                                               @05C
            CR    &BUFLEN,&BUF              At start of string?    @05C
            BNH   SL&SYSNDX.C               Yes, quit...           @05C
            BCTR  &BUFLEN,0                 Decrement current ptr  @05C
            B     SL&SYSNDX.A               Check next character   @05C
SL&SYSNDX.B DS    0H                        Found end of string    @05C
            SR    &BUFLEN,&BUF              Calculate length       @05C
            LA    &BUFLEN,1(,&BUFLEN)       Adjust length          @05C
            B     SL&SYSNDX.D               Go store length        @05C
SL&SYSNDX.C DS    0H
            LA    &BUFLEN,0                 Found empty string     @05C
SL&SYSNDX.D DS    0H
         MEND
         EJECT
.*---------------------------------------------------------------------
.*
.* MOVEQUAL Macro
.*   Move a DB2 object qualifier from the input parameter list     @05A
.*   (XAPL) to the current resource name being built.              @05A
.*
.*   Parameters:
.*     &SRC    - (input/field) Name of qualifier to move.          @05A
.*               Specified as one of the qualifiers of the current @05A
.*               resource table entry (RESENTRY).                  @05A
.*     &DEST   - (input/reg)   Addr of resource name being built   @05A
.*     &REG    - (input/regs)  Specifies 3 work registers          @05A
.*
.*
.*---------------------------------------------------------------------
         MACRO
         MOVEQUAL  &SRC=,&DEST=,&REG=(,,)                          @05A
MQRES       USING  RESQUAL,&SRC             addr of qualifier defn @05A
            CLC    MQRES.RESQXLEN,ZEROH     Does qualifier exist?  @05A
            BE     MQ&SYSNDX.X              No, skip this qual     @05A
            LA     &REG(3),@DATD            Address of autodata    @05A
            AH     &REG(3),MQRES.RESQLDOF   Length desc offset     @05A
            LR     &REG(1),XAPLPTR          Address of XAPL        @05A
            AH     &REG(1),MQRES.RESQXOFF   Add offset into XAPL   @05A
            CLI    0(&REG(3)),X'00'         Was length calculated? @05A
            BNE    MQ&SYSNDX.A              Yes, skip calculation  @05A
            LH     &REG(2),MQRES.RESQXLEN   Length of XAPL field   @05A
            STRLEN BUF=&REG(1),BUFLEN=&REG(2)                      @05A
            STH    &REG(2),2(,&REG(3))      Store string length    @05A
            OI     0(&REG(3)),X'FF'         Indicate length stored @05A
MQ&SYSNDX.A DS     0H                                              @05A
            LH     &REG(2),2(,&REG(3))      Get string length      @05A
            CH     &REG(2),ZEROH            Any data to move?      @05A
            BE     MQ&SYSNDX.X              No, skip this qual     @05A
            BCTR   &REG(2),0                Decrement len for EX   @05A
            EX     &REG(2),MQ&SYSNDX.M      copy qualifier to      @05A
            AR     &DEST,&REG(2)            Bump result address    @05A
            LA     &DEST,1(,&DEST)          Adjust for BCTR        @05A
            MVI    0(&DEST),C'.'            Add period after qualifier
            LA     &DEST,1(,&DEST)          Bump result address    @05A
            B      MQ&SYSNDX.X              Branch around EX       @05A
MQ&SYSNDX.M MVC    0(0,&DEST),0(&REG(1))    Move: XAPL->resource   @05A
MQ&SYSNDX.X DS     0H                                              @05A
            DROP   MQRES                                           @05A
         MEND
         PRINT ON
         EJECT
         TITLE 'RACF/DB2 External Security Module - Main'
*----------------------------------------------------------------------
* $XACSCODE - DSNX@XAC Main Module
*----------------------------------------------------------------------
DSNX@XAC CSECT
         SPACE 3
*----------------------------------------------------------------------
* Registers
*----------------------------------------------------------------------
         REGS
         EJECT
RTN_CODE EQU   2
XAPLPTR  EQU   3
RULE_INDEX EQU 8
RULPTR   EQU   9
RESPTR   EQU   10
         EJECT
*----------------------------------------------------------------------
* Mapping Macros
*----------------------------------------------------------------------
         SPACE 3
         PRINT   GEN
         ICHSAFP
         EJECT
         DSNDXAPL
         EJECT
         DSNDEXPL              DB2 EXIT PARAMETER LIST
         EJECT
         DSNXAPRV
         EJECT
         PRVDSECT
         RULDSECT
         RESDSECT
         DIAGDSCT
         OBJDSECT              OBJECT TABLE DSECTS
         WADSCT
         EJECT
         IHASDWA
         EJECT
         IHAPSA
         EJECT
         IHAFRRS
         EJECT
         CVT DSECT=YES
         EJECT
         FRRDSCT
         EJECT
*------------------------------------------------------------------@08A
* We will set &XAPLDBCK to determine if we have the DB2V7          @08A
* parameter list.  If the XAPLDBNM field had been defined, than we @08A
* do have the V7 parameter list.                                   @08A
*------------------------------------------------------------------@08A
&XAPLDBCK     SETA  D'XAPLDBNM                                     @08A
*------------------------------------------------------------------@L3A
* We will set &XAPLV8   to determine if we have the DB2V8 or later @L3A
* parameter list.  If the XAPLDBSP field had been defined, than we @L3A
* do have the V8 parameter list.                                   @L3A
*------------------------------------------------------------------@L3A
&XAPLV8       SETA  D'XAPLDBSP                                     @L3A
         AIF   ('&XAPLV8' EQ '0').XAPLV7                           @L3A
  MNOTE 8,'The DB2 V8 DSNDXAPL may not be used with this module.'  @L3A
.XAPLV7  ANOP                                                      @L3A
*------------------------------------------------------------------@07A
* Add logic to define a set of symbols if they have not been       @07A
* defined.  This situation will occur if running with the macro    @07A
* libraries for DB2 release 510.                                   @07A
*------------------------------------------------------------------@07A
&LEN SETA  D'SCHEMA
         AIF   ('&LEN' NE '0').SKIPEQU
SCHEMA       EQU  C'M'   SCHEMA
UDT          EQU  C'E'   USER DEFINED DISTINCT TYPE
UDF          EQU  C'F'   USER DEFINED FUNCTION
SPROC        EQU  C'O'   STORED PROCEDURE
ALTINAUTM EQU  0252  ALTERIN
*                     XAPLOBJN - OBJECT NAME
*                     XAPLOWNQ - SCHEMA NAME
*                     XAPLREL1 - OBJECT OWNER
CHKEXECF  EQU  0064  EXECUTE
*                     XAPLOBJN - SPECIFIC FUNCTION NAME
*                     XAPLOWNQ - SCHEMA NAME
*                     XAPLREL1 - FUNCTION OWNER
*                     XAPLXBTS - FUNCTION RESOLUTION TIMESTAMP
COMNTAUTM EQU  0097  COMMENT ON
*                     XAPLOBJN - OBJECT NAME
*                     XAPLOWNQ - SCHEMA NAME
*                     XAPLREL1 - OBJECT OWNER
CREINAUTM EQU  0261  CREATEIN
*                     XAPLOBJN - SCHEMA NAME
DISPAUTO  EQU  0267  DISPLAY STORED PROCEDURE
*                     XAPLOBJN - STORED PROCEDURE NAME
*                     XAPLOWNQ - SCHEMA NAME
*                     XAPLREL1 - STORED PROCEDURE OWNER
DRPINAUTM EQU  0262  DROPIN
*                     XAPLOBJN - OBJECT NAME
*                     XAPLOWNQ - SCHEMA NAME
*                     XAPLREL1 - OBJECT OWNER
STPAUTO   EQU  0266  STOP STORED PROCEDURE
*                     XAPLOBJN - STORED PROCEDURE NAME
*                     XAPLOWNQ - SCHEMA NAME
*                     XAPLREL1 - STORED PROCEDURE OWNER
STRTAUTO  EQU  0265  START STORED PROCEDURE
*                     XAPLOBJN - STORED PROCEDURE NAME
*                     XAPLOWNQ - SCHEMA NAME
*                     XAPLREL1 - STORED PROCEDURE OWNER
.SKIPEQU ANOP
*----------------------------------------------------------------------
* Common Entry Linkage
*----------------------------------------------------------------------
DSNX@XAC CSECT
DSNX@XAC AMODE 31
DSNX@XAC RMODE ANY
         USING *,R15
         B     @PROLOG           BRANCH AROUND MODULE IDENTIFIER
@MAINENT DS    0H
         DC    CL8'DSNX@XAC'
         DC    CL8' &SERVICELEVEL'
         DC    CL8'&SYSDATE'
         DC    CL8'&SYSTIME'
         DROP  R15
@PROLOG  DS    0H
         STM   R14,R12,12(R13)         Save callers registers
         LR    R12,R15                 Load module address into R12
@PSTART  EQU   DSNX@XAC
         USING @PSTART,R12             Set up base register
         L     R6,0(R1)                Set EXPL addresses
         L     R3,4(R1)                Set XAPL addresses
         USING EXPL,R6                 Set up EXPL register
         USING XAPL,R3                 Set up XAPL register
         EJECT
*----------------------------------------------------------------------
*
*  MAINLINE:
*
*  Determine request type:
*  SELECT(XAPLFUNC)
*  WHEN(Initializaton or Termination)
*    - Call IRR@XAC1 to process request
*  WHEN(Authorization)
*    - Process the request
*  WHEN(XAPL is from a release less than DB2 V8)                  @L3A
*    - Call IRR@XAC1 to issue the IRR914I message                 @L3A
*  OTHERWISE Unknown function code
*    - Set EXPLRC1 to 12
*  Return to DB2
*
*----------------------------------------------------------------------
MAIN     DS    0H
*----------------------------------------------------------------------
* Determine Request Type:
*----------------------------------------------------------------------
         LH    R4,XAPLFUNC         Load reg with input function code
         LA    R5,XAPLACHK         Load reg with auth function code
         CR    R4,R5               Determine requested function
         BE    AuthRequest         Process authorization request
         LA    R5,XAPLINIT         Load reg with init function code
         CR    R4,R5               Determine requested function
         BE    InitRequest         Process initialization request
         LA    R5,XAPLTERM         Load reg with term function code
         CR    R4,R5               Determine requested function
         BE    TermRequest         Process termination request
*------------------------------------------------------------------@L3A
*     The XAPL changed  substantially between DB2 V7 and DB2 V8.   @L3A
*     If this version of DSNX@XAC is invoked with a DB2 V8         @L3A
*     XAPL, we need to set EXPLRC1 to 8 and EXPLRC2 to 10. We      @L3A
*     do this by checking the XAPLLVL now and then if it is        @L3A
*     downlevel, branching into the InitRequest routine to issue   @L3A
*     the IRR914I message, set EXPLRC1/EXPLRC2, and return to DB2. @L3A
*------------------------------------------------------------------@L3A
         CLC   XAPLLVL,DB2V8A      Check  the version of the XAPL  @L3A
         BNL   InitRequest         If the XAPL is from a DB2 V8    @L3A
*                                  or later environment, branch to @L3A
*                                  InitRequest to handle the error @L3A
*----------------------------------------------------------------------
* Unknown Function Code:
*----------------------------------------------------------------------
         LA    R4,RC_NOCALL        Not Init, Term or Auth... tell
         STH   R4,EXPLRC1          DB2 not to invoke exit again
         B     FINIS               Unknown function code, return to DB2
DB2V8A   DC    CL8'V8R1M0'         Located here to ensure          @L3A
*                                  addressability                  @L3A
InitRequest DS 0H
TermRequest DS 0H
*----------------------------------------------------------------------
* InitRequest/TermRequest:
* - Setup first 72 bytes of EXPLWA as save area for this module
* - Invoke IRR@XAC1
*----------------------------------------------------------------------
         L     R15,EXPLWA          Set up address for save area
         USING WA_MAP,R15
         ST    R13,WA_SAVE+4       Set save area back pointer
         ST    R15,8(,R13)         Set save area forward pointer
         LA    R13,WA_SAVE         Set save area for called rtns
         L     R14,@SIZDATD        Get size of DSNX@XAC autodata
         ST    R14,WA_CSIZE        Pass it to IRR@XAC1
         DROP  R15
         L     R15,XAC1            Get address of Init/Term routine
         BALR  R14,R15             Call Init/Term routine
*----------------------------------------------------------------------
* InitRequest/TermRequest Exit linkage:
* - Restore callers registers
* - Return to DB2
*----------------------------------------------------------------------
FINIS    DS    0H
         L     R13,4(,R13)
         LM    R14,R12,12(R13)
         BR    R14                 RETURN TO DB2
         EJECT
*----------------------------------------------------------------------
*  AuthRequest:
*
*  Complete entry linkage
*  - Add an FRR
*  - Obtain autodata using CPOOL cell (pre-allocated by IRR@XAC1)
*  - Setup save area for this module
*
*  Initialize variables and prepare ACEE for access checking
*  - CALL INIT
*
*  Check the user's access to the resource
*  - IF INIT was successful (there is a usable ACEE) THEN
*    DO
*    | Check to see if this is a AUTOBIND request. If it is, then  @L1A
*    |    set the return code to FAIL (8)  and the reason code to  @L1A
* <---    17 and return to the invoker.                            @L1A
*    | Call MATCH_CHECK to see if the operation should be allowed  @L1A
*    |   because the user ID is the same as the schema name        @L1A
*    |   then go to ALLOWED to set the return and reason code.     @L1A
*    | Locate the Rule Table that applies to the input privilege.
*    | - CALL GETRULES
*    | - IF a Rule Table was found THEN
*    |   DO
*    |   | - DO I = 1 to RULNUM WHILE(access is not allowed)
*    |   |   | - CALL IMPLICIT_CHECK
*    |   |   | - IF access is not allowed THEN
*    |   |   |   - CALL FASTAUTH_CHECK
*    |   |   END I = 1 TO RULNUM
*    |   |
*    |   | - IF access is denied (RTN_CODE=8) THEN
*    |   |   DO
*    |   |   | Redrive FASTAUTH w/MSGSUPP=NO and LOG=ASIS to allow
*    |   |   | requested auditing to occur.
*    |   |   | - CALL FASTAUTH_AUDIT
*    |   |   END access is denied
*    |   |   ELSE access is not denied (NOP)
*    |   END a rule table was found
*   END INIT was successful
*
*  Complete exit linkage
*  - Free the autodata
*  - Delete the FRR
*  - Restore the caller's save area
*
*  Return to DB2
*
*----------------------------------------------------------------------
         EJECT
AuthRequest DS    0H
         GBLC  &RTNSUFX                                            @05A
&RTNSUFX SETC  'XACS'                                              @05A
*----------------------------------------------------------------------
*  Complete entry linkage
*  - Add an FRR
*  - Obtain autodata using CPOOL cell (pre-allocated by IRR@XAC1)
*  - Setup save area for this module
*----------------------------------------------------------------------
         MODESET EXTKEY=ZERO,SAVEKEY=(2),WORKREG=8
         LR    R9,R2               Save savekey register
         SETFRR A,FRRAD=@FRR_RTN,PARMAD=(R5),EUT=YES,                  X
               MODE=(FULLXM),                                          X
               WRKREGS=(R7,R8)
         USING FRR_PARMP,R5
         ST    R6,FRR_EXPL         Save the address of the EXPL
         ST    R3,FRR_XAPL         Save the address of the XAPL
         ST    R12,FRR_CODEP       Save the Code Register
         EJECT
         L     R4,EXPLWA           Get address of EXPL work area
         USING WA_MAP,R4
         L     R7,WA_CPID          Obtain Cell Pool ID
         DROP  R4
         LR    R8,R3               Save XAPL address
***  Note: CPOOL will use registers 0-4 as work registers
         CPOOL GET,U,CPID=(R7),REGS=USE
         LR    R3,R8               Restore XAPL address
         LR    R11,R1              Store cell address in data reg
         USING @DATD,R11           Setup addressability to data
         ST    R11,FRR_CELLP       Save the CELL address
         LR    R2,R9               Restore savekey register
         MODESET KEYADDR=(2),WORKREG=8
         DROP  R5
         ST    R13,@SAVE+4         Set save area back pointer
         LA    R15,@SAVE
         ST    R15,8(,R13)         Set save area forward pointer
         LA    R13,@SAVE           Set save area for called rtns
         ST    R6,EXPLPTR          Save the address of the EXPL
         DROP  R6                  Drop EXPL
*----------------------------------------------------------------------
* Initialize variables
*----------------------------------------------------------------------
         BAL   R14,INIT            Initialize varibles and ACEE
         LTR   RTN_CODE,RTN_CODE   Was init successful?
         BNZ   INITFAIL            A usable ACEE was not found
*------------------------------------------------------------------@L1A
* Check for AUTOBIND                                               @L1A
*   - If this is an EXECUTE request for a function (UDF)           @L1A
*     and the AUTOBIND flag is ON (bit 6 in XAPLFLG1), then        @L1A
*     return to DB2 with a return code 8 (FAIL) and reason code    @L1A
*     17 (decimal).                                                @L1A
*------------------------------------------------------------------@L1A
         TM    XAPLFLG1,B'00100000' Is this an AUTOBIND?           @L1A
         BZ    NOT_AN_AUTOBIND      No? Continue...                @L1A
         LA    R4,CHKEXECF          If it is, is this an           @L1A
         CH    R4,XAPLPRIV          EXECUTE?                       @L1A
         BNE   NOT_AN_AUTOBIND      No? Continue...                @L1A
         CLI   XAPLTYPE,UDF         Are we executing a function?   @L1A
         BNE   NOT_AN_AUTOBIND      No? Contunue...                @L1A
IS_AN_AUTOBIND  EQU *               If we are here, then this is   @L1A
*                                   an AUTOBIND of a function (UDF)@L1A
         LA    RTN_CODE,RC_FAIL     Set the return code to FAIL    @L1A
         MVC   RSN_CODE,RSN_AUTOBIND Set the reason code to 17     @L1A
         BR    14                   And return to the invoker      @L1A
NOT_AN_AUTOBIND EQU *                                              @L1A
*----------------------------------------------------------------------
* Check to see of the current user ID matches the schema name      @L1A
*----------------------------------------------------------------------
         BAL   R14,MATCH_CHECK     No? Check schema_name=user ID   @L1A
         LTR   RTN_CODE,RTN_CODE   Was access allowed?             @L1A
         BZ    ALLOWED             Yes, no more checking required  @L1A
*----------------------------------------------------------------------
* Locate the Rule Table
*----------------------------------------------------------------------
         LA    RTN_CODE,0          Reset the return code           @L1A
         BAL   R14,GETRULES        On Return: RULPTR set to Rule Table
         LTR   RTN_CODE,RTN_CODE   Was a rule table found?
         BNZ   NORULETB            A rule table was not found
*----------------------------------------------------------------------
* Process the Rule Table
*----------------------------------------------------------------------
         USING RULENTHD,RULPTR
         LH    R7,RULNUM           Get the number of rules to process
         LTR   R7,R7               Are there any rules?
         BNZ   DORULES             Yes, process the rules
         LA    RTN_CODE,RC_DEFER   No, set return code
         MVC   RSN_CODE,RSN_NORULES
         B     SETEXPL             Set return codes in EXPL
DORULES  LA    RULPTR,RULARRAY     Get addr of first rule in array
         SLR   RULE_INDEX,RULE_INDEX Clear index register
         LA    RTN_CODE,RC_DEFER   Assume return code of defer
         USING RULENTRY,RULPTR
RULELOOP L     RESPTR,RULRES@(RULE_INDEX) Get addr of resource table
*                                  entry
         BAL   R14,IMPLICIT_CHECK  Check for implicit privilegs
         LTR   RTN_CODE,RTN_CODE   Was access allowed?
         BZ    ALLOWED             Yes, no more checking required
         AIF   ('&XAPLDBCK' EQ '0').SKIPDB1                        @08A
         TM    FLAGS2,CRTVUAUT_CHECK Do we have CRTVUAUT  priv     @08A
         BZ    DOFACHCK            No, then just do FastAuth check @08A
*----------------------------------------------------------------------
* We need to check the offset of the rule_index.  If it is 8, then
* we are checking the DBADM_T resource.
*------------------------------------------------------------------@08A
         LA    R5,8                Load offset of DBADM_T          @08A
         CR    R5,RULE_INDEX       Check if rule is DBADM_T rule   @08A
         BNE   DOFACHCK            No, not 4, do normal check      @08A
         TM    XAPLFLG1,B'00010000' Is DBADM allowed?              @08A
         BZ    ENDRULES            No? Skip this Rule              @08A
         OI    FLAGS2,DBADM_T_CHECK Turn DBADM_T_CHECK flag on     @08A
         CLI   FLAGS2,DBADM_T_CHECK+CRTVUAUT_CHECK                 @08A
         BNE   DOFACHCK            Just do FASTAUTH check          @08A
*----------------------------------------------------------------------
* Loop here if the Privilege code is 108 and the rulnum offset is 8
* meaning that we have the CRTVUAUT privilege and the DBADM_T resource
*------------------------------------------------------------------@08A
DBLOOP   L     R5,DBINFPTR                                         @08A
         LTR   R5,R5               Is R5 zero??                    @08A
         BZ    NORM                We are done, translate the RC   @08A
DOFACHCK DS    0H                                                  @08C
.SKIPDB1 ANOP                                                      @08A
         BAL   R14,FASTAUTH_CHECK  No, perform FASTAUTH checking
         AIF   ('&XAPLDBCK' EQ '0').SKIPDB2                        @08A
         CLI   FLAGS2,DBADM_T_CHECK+CRTVUAUT_CHECK                 @08A
         BNE   NORM                                                @08A
*----------------------------------------------------------------------
* The following section of code will set the output field of the   @08A
* XAPLDBS structure, XAPLDBDA.  If the RC from the FASTAUTH was    @08A
* 4 it will be set to 'U', if the rc was 0 it will be set to 'Y'.  @08A
*----------------------------------------------------------------------
         USING XAPLDBS,R5          Base database name structure    @08A
         CLC   DBA_CODE,RC_UNKNOWN Was return code a 4??           @08A
         BNE   NOTFOUR             Return code was not 4           @08A
         MVI   XAPLDBDA,C'U'       Access is unknown               @08A
         B     DOLOOP              Updated output, go to next DB   @08A
NOTFOUR  DS    0H                                                  @08A
         CLC   DBA_CODE,RC_ZERO    Was access allowed?             @08A
         BNE   DOLOOP              Skip setting XAPLDBDA           @08A
         MVI   XAPLDBDA,C'Y'       XAPLUCHK had DBADM on this DB   @08A
DOLOOP   MVC   DBINFPTR,XAPLDBNP   Set pointer to next entry       @08A
         DROP  R5                  drop USING R5                   @08A
         B     DBLOOP              Loop to check all DBNames       @08A
NORM     DS    0H                                                  @08A
.SKIPDB2 ANOP                                                      @08A
         LTR   RTN_CODE,RTN_CODE   Was access allowed?
         BZ    ALLOWED             Yes, no more checking required
         LA    RULE_INDEX,RULENTLN(RULE_INDEX) Bump index to next entry
         BCT   R7,RULELOOP         More entries, continue checking
*----------------------------------------------------------------------
* Translate FASTAUTH return code
*----------------------------------------------------------------------
         AIF   ('&XAPLDBCK' EQ '0').SKIPDB3                        @08A
ENDRULES DS    0H                  No More rules, translate RC     @08A
.SKIPDB3 ANOP                                                      @08A
         TR    FAST_RC_BYTE,RC_TABLE  Translate return code
         IC    RTN_CODE,FAST_RC_BYTE  Put RC in return code register
*----------------------------------------------------------------------
* Audit FASTAUTH failures
*----------------------------------------------------------------------
         LA    R4,RC_FAIL
         CLR   RTN_CODE,R4         Was accessed denied?
         BNE   NOFAIL              Access was not denied, skip audit
*----------------------------------------------------------------------
*        Suppress the auditing of QUALAUTs for schemas. Why?       @L1A
*        QUALAUTs for schemas check for authority to the SYSADM    @L1A
*        and SYSCTRL resources in the system authorities class     @L1A
*        (e.g. DSNADM). QUALAUTs are always followed another       @L1A
*        resource privilege check, which results in checks         @L1A
*        against a resource profile (e.g. <schema-name>.CREATEIN)  @L1A
*        and then by SYSADM and SYSCTRL checks in the class        @L1A
*        DSNADM. Without suppressing this auditing, we would see   @L1A
*        the audit records (and ICH408I messages) for the          @L1A
*        SYSCTRL and SYSADM checks, even if the user was able      @L1A
*        to complete the function because of an authority          @L1A
*        granted by one of the subsequent resource check. Note     @L1A
*        that if access is allowed by SYSADM or SYSCTRL on the     @L1A
*        QUALAUT check and auditing was requested (by the normal   @L1A
*        RACF methods for asking for auditing (e.g. AUDIT/GAUDIT   @L1A
*        on the profile, UAUDIT on the user) then an audit record  @L1A
*        is created.                                               @L1A
*----------------------------------------------------------------------
         LA    R4,QUALAUTT         Is this a QUALAUTH?             @L1A
         CH    R4,XAPLPRIV         check to see if this is QUALAUT @L1A
         BNE   GO_AUDIT            If not, go on to audit...       @L1A
         CLI   XAPLTYPE,SCHEMA     Is this QUALAUT on a schema?    @L1A
         BE    NOFAIL              If it is, then skip auditing    @L1A
         TM    FLAGS,AUDIT_SAVED   Was a resource saved?           @02A
         BNO   NOFAIL              No, skip audit                  @02A
GO_AUDIT EQU   *                   Time to cut an audit record     @L1A
         BAL   R14,FASTAUTH_AUDIT  Audit FASTAUTH failure
NOFAIL   DS    0H                  ELSE access was not denied (NOP)
NORULETB DS    0H                  ELSE a rule table wasn't found (NOP)
INITFAIL DS    0H                  ELSE INIT failed (NOP)
ALLOWED  DS    0H                  Access was allowed
         DROP  RULPTR
*----------------------------------------------------------------------
* Delete Access List Entry (DU-AL), If one was created
*----------------------------------------------------------------------
         TM    FLAGS,ALET_ADDED    Was ALET added to DU-AL?
         BNO   SETEXPL             No, skip delete processing
         MVC   ALESERVD(ALESERVSLEN),ALESERVS Copy static to dynamic
         ALESERV DELETE,           Delete ALET                         X
               CHKEAX=NO,          Don't check EAX authority           X
               ALET=FAST_ALET,     Address of ALET to be deleted       X
               RELATED=ASERV,                                          X
               MF=(E,ALESERVD)
*----------------------------------------------------------------------
* Place return and reason codes in the EXPL
*----------------------------------------------------------------------
SETEXPL  L     R4,EXPLPTR
         USING EXPL,R4
         STH   RTN_CODE,EXPLRC1
         MVC   EXPLRC2,RSN_CODE
*----------------------------------------------------------------------
* AuthRequest Exit Linkage:
* - Free autodata cell
* - Delete FRR
* - Restore callers registers
* - Return to DB2
*----------------------------------------------------------------------
         L     R13,4(,R13)         Restore caller's R13
         L     R4,EXPLWA           Get address of EXPL work area
         USING WA_MAP,R4
         L     R4,WA_CPID          Get autodata cell pool ID
         DROP  R4
         CPOOL FREE,CPID=(R4),CELL=(R11),REGS=USE
         MODESET EXTKEY=ZERO,SAVEKEY=(2),WORKREG=6
         SETFRR D,WRKREGS=(R4,R5)
         MODESET KEYADDR=(2),WORKREG=6
         LM    R14,R12,12(R13)     Restore caller's registers
         BR    R14                 RETURN TO DB2
         EJECT
*----------------------------------------------------------------------
*  INIT:
*     Initialize Variables:
*     - Set RTN_CODE to 0 (return code)
*     - Set RSN_CODE to 0 (reason code)
*     - If we are called for the CREATE VIEW privilege than do     @08A
*       some special setup.  Turn on the CRTVUAUT_CHECK flag and   @08A
*       then copy into DBINFPTR the first 4 bytes of the XAPLREL2  @08A
*       field which points to the database structure. If           @08A
*       they are all blanks than set them to zero.                 @08A
*     Prepare an ACEE for access checking:
*       IF an ACEE address was specified THEN
*       DO
*       | - Save the address for FASTAUTH
*       | - IF the ACEE is not in the HOME address space THEN
*       |   DO
*       |   | An ALET will be needed to allow FASTAUTH to access
*       |   | the ACEE.
*       |   | - Issue ALESERV to ADD an Access List entry for the
*       |   |   address space identified by XAPLSTKN
*       |   | - IF the ALET could not be found THEN
*       |   |   DO
*       |   |   | The input ACEE cannot be accessed, defer to DB2.
*       |   |   | - Set RTN_CODE to 4 (defer)
*       |   |   | - Set RSN_CODE to 14 (ALET could not be created)
* <---------------- Return to DB2
*       |   |   END the ALET could not be found
*       |   |   ELSE the ALET was found (NOP)
*       |   END the ACEE is not in the HOME address space.
*       |   ELSE the ACEE is already in the HOME address space (NOP)
*       END an ACEE address was specified
*       ELSE an ACEE address was not provided,
*       DO
*       | - The Initialization routine attempted to create and store
*       |   a default ACEE for this case.  Retrieve the default ACEE
*       |   from the EXPLWA work area.
*       | - IF there is no default ACEE THEN
*       |   DO
*       |   | There is no ACEE for authority checking, defer to DB2.
*       |   | - Set RTN_CODE to 4 (defer)
*       |   | - Set RSN_CODE to 11 (no ACEE)
* <------------ Return to DB2
*       |   END the default ACEE was not retrieved
*       END an ACEE address was not provided
*
*  INPUT:
*   None
*
*  OUTPUT:
*   FAST_ACEE - ACEE to be used for later FASTAUTH
*   FAST_ALET - ALET for ACEE
*   RTN_CODE  - Return Code (set to zero)
*   RSN_CODE  - Reason Code (set to zero)
*   XAPLDIAG  - XAPL Diagnostic Area (set to zero)
*   DIAGNEXT  - Next available XAPLDIAG slot (set to addr of XAPLDIAG)
*   FLAGS     - Flag Byte (cleared)
*   FLAGS2    - Flag Byte (cleared)                                @08A
*----------------------------------------------------------------------
         EJECT
INIT     DS    0H
         STM   R4,R8,IN_SAVE1      Save work registers
         ST    R14,IN_SAVE2        Save register 14
*----------------------------------------------------------------------
* Initialize Variables:
*----------------------------------------------------------------------
         LA    R4,0
         SLR   RTN_CODE,RTN_CODE   Init return code
         ST    R4,RSN_CODE         Init reason code
         STC   R4,FLAGS            Init boolean flags
         STC   R4,FLAGS2           Init boolean flags2             @08A
         ST    R4,FAST_RC          Init FASTAUTH return code string
         LA    R4,XAPLDIAG         Get address of XAPLDIAG
         ST    R4,DIAGNEXT         Initialize DIAGNEXT address
         MVI   XAPLDIAG,X'00'      Clear XAPLDIAG
         MVC   XAPLDIAG+1(L'XAPLDIAG-1),XAPLDIAG
         MVI   LOGSTR_DATA,X'40'   Clear LOGSTR area               @02A
         MVC   LOGSTR_DATA+1(L'LOGSTR_DATA-1),LOGSTR_DATA          @02A
         MVC   LOGSTR_SECNDRY_ID,NO  Init secondary id flag        @02A
         MVC   LOGSTR_USERTAB,NO     Init user table flag          @02A
         LA    R5,XAPLGPAT           Get buffer address            @05A
         LA    R6,L'XAPLGPAT         Get buffer length             @05A
         STRLEN BUF=R5,BUFLEN=R6     Calculate string              @05A
         STH   R6,LEN$GPAT&RTNSUFX   save length                   @05A
         SLR   R6,R6                 clear reg                     @05A
         ST    R6,LD$OBJN            clear XAPLOBJN length desc    @05A
         ST    R6,LD$OWNQ            clear XAPLOWNQ length desc    @05A
         ST    R6,LD$REL1            clear XAPLREL1 length desc    @05A
         ST    R6,LD$REL2            clear XAPLREL2 length desc    @05A
         AIF   ('&XAPLDBCK' EQ '0').SKIPDB4                        @08A
         LH    R6,XAPLPRIV           Load in privilege code        @08A
         C     R6,CRTVUAUT_PRIV      Is it code '108'              @08A
         BNE   DONECRTV              Skip setting flag & DBINFPTR  @08A
         OI    FLAGS2,CRTVUAUT_CHECK Set the CREATE VIEW bit       @08A
         MVC   DBINFPTR(4),XAPLREL2  SET DBINFPTR                  @08A
         CLC   DBINFPTR,BLANKS4      All Blanks, not initialized?? @08A
         BNE   DONECRTV              No, than set jump DONECRTV    @08A
         LA    R4,0                  Initialize R4 to zero         @0AA
         ST    R4,DBINFPTR           Yes, set to zero, no database @08A
         LA    R4,4                  Load R4 with 4                @08A
DONECRTV DS    0H                                                  @08A
.SKIPDB4 ANOP                                                      @08A
*----------------------------------------------------------------------
* Prepare the ACEE for use:
*----------------------------------------------------------------------
         L     R4,XAPLACEE         Get ACEE address
         LTR   R4,R4               Test for ACEE address
         BZ    NOACEE              ACEE does not exist
*----------------------------------------------------------------------
* An ACEE address was specified
*----------------------------------------------------------------------
         ST    R4,FAST_ACEE        Save the ACEE for FASTAUTH
         L     R4,XAPLSTKN         Get ACEE stoken
         LTR   R4,R4               Check if ACEE is in HOME
         BZ    ACEEHOME            ACEE is in HOME
*----------------------------------------------------------------------
* The ACEE address is not in the HOME address space
*----------------------------------------------------------------------
         L     R5,MINUS_ONE
         ST    R5,FAST_ALET        Start search at beginning of PASN-AL
         MVC   ALESERVD(ALESERVSLEN),ALESERVS Copy static to dynamic
         ALESERV ADD,              Add ACEE STOKEN to the current      X
               AL=WORKUNIT,        unit of work's DU-AL                X
               CHKEAX=NO,          Don't check EAX authority           X
               ALET=FAST_ALET,     Returned ALET                       X
               STOKEN=XAPLSTKN,    Input STOKEN                        X
               RELATED=ASERV,                                          X
               MF=(E,ALESERVD)
         LTR   R15,R15             Was the Access List entry added?
         BZ    GOTALET             Yes, we have the alet
*----------------------------------------------------------------------
* The Access List entry could not be added
*----------------------------------------------------------------------
         LA    RTN_CODE,RC_DEFER   Set return code to defer
         MVC   RSN_CODE,RSN_NOALET
         STC   R15,XAPLDIAG        Save ALESERV ret code in XAPL   @04C
         B     END_GOTALET         Return to DB2
*----------------------------------------------------------------------
* An ALET was found (NOP)
*----------------------------------------------------------------------
GOTALET     DS 0H
         OI FLAGS,ALET_ADDED       Indicate the ALET was added to DU-AL
END_GOTALET DS 0H
         B     END_ACEEHOME        Skip ACEE in HOME processing
*----------------------------------------------------------------------
* The ACEE is in the HOME address space
*----------------------------------------------------------------------
ACEEHOME     DS 0H
         LA  R4,HOME_ALET
         ST  R4,FAST_ALET          Indicate ACEE is in the HOME AS
END_ACEEHOME DS 0H
         B     END_NOACEE          Skip no ACEE address processing
             EJECT
*----------------------------------------------------------------------
* An ACEE address was not provided:
*----------------------------------------------------------------------
NOACEE   DS    0H
         L     R4,EXPLPTR          Get address of EXPL
         USING EXPL,R4             setup addressability to EXPL
         L     R4,EXPLWA           Get address of work area
         USING WA_MAP,R4           setup addressability to work area
         L     R4,WA_DFTACEE       Get the address of the default ACEE
         DROP  R4
         ST    R4,FAST_ACEE        Save address for FASTAUTH
         LTR   R4,R4               Is there a default ACEE?
         BNZ   GOTACEE             Yes, the ACEE was retrieved
*----------------------------------------------------------------------
* The default ACEE was not retrieved
*----------------------------------------------------------------------
         LA    RTN_CODE,RC_DEFER   Set return code to defer
         MVC   RSN_CODE,RSN_NODFT_ACEE Set rsn code to no default ACEE
         B     END_GOTACEE
*----------------------------------------------------------------------
* The default ACEE was retrieved
*----------------------------------------------------------------------
GOTACEE     DS  0H
         LA  R4,PRIM_ALET
         ST  R4,FAST_ALET          Indicate ACEE is in the Primary AS
END_GOTACEE DS  0H
END_NOACEE  DS  0H                 End - No ACEE address provided
         LM    R4,R8,IN_SAVE1      Restore work registers
         L     R14,IN_SAVE2        Restore BALR Register
END_INIT    BR  R14                Return to mainline
            EJECT
*----------------------------------------------------------------------
*  GETRULES:
*
*  The Rule Table defines the authority checking to be performed
*  for this privilege.  The Rule Table is located via the
*  Privilege Table entry.   The Privilege Table entry is located
*  by using the privilege code as an index into the Privilege
*  Table.
*
*  - Calculate the offset into the privilege index.
*    (XAPLPRIV * PRVIDXLN)
*  - Extract the privilege table entry address from privilege index
*  - IF the privilege table entry address is not zero THEN
*    DO I = 1 to number of objects sharing privilege
*    |  WHILE(XAPLTYPE <> PRVOBJ(I))
*    END I =1 to number of objects
*  - IF a matching object type was found THEN
*      Return PRVRUL@ to mainline
*  - IF the privilege entry address is zero OR
*       a matching object type was not found THEN
*    DO
*    | This means the input privilege code has not been defined
*    | in the authorization checking tables and this routine will
*    | defer to DB2.
*    | - Set RTN_CODE to 4 (defer)
*    | - Set RSN_CODE to 15 (undefined privilege code)
* <----- Return to DB2
*    END the privilege entry address is zero
*
*  INPUT:
*   None
*
*  OUTPUT:
*   RULPTR   - Address of Rule Table
*   RTN_CODE - Return Code
*   RSN_CODE - Reason Code
*
*----------------------------------------------------------------------
         EJECT
GETRULES DS    0H
         USING PRVENTRY,R9         Privilege Table entry
*----------------------------------------------------------------------
* Locate the Privilege Table Entry using Privilege Index
*----------------------------------------------------------------------
         L     R5,TPRV             Address of Privilege Table
         USING PRVTABHD,R5         Privilege Table header
         L     R6,PRVTXNUM         Get the requested privilege code
         CH    R6,XAPLPRIV         Is input greater than table size?
         BNH   PRVNTFND            Yes, the privilege is not defined
         LA    R4,PRVIDXLN         Length of Privilege Index entry
         MH    R4,XAPLPRIV         Caclulate offset into index
         LA    R5,PRVINDEX         Get the address of index
         DROP  R5
         AR    R5,R4               Addr of privilege index entry
         L     R5,0(R5)            Addr of Privilege Table entry header
         LTR   R5,R5               Is address zero?
         BZ    PRVNTFND            Yes, the privilege is no defined
*----------------------------------------------------------------------
* Privilege Table Entry address was not zero,
* locate the object type in the privilege entry
*----------------------------------------------------------------------
         USING PRVENTHD,R5         Privilege Table entry header
         LA    R9,PRVEHDLN(,R5)    Addr of first privilege table entry
         LH    R4,PRVNUM           Number of times to iterate
         LTR   R4,R4               Are there any entries
         BZ    PRVNTFND            No, the privilege is not defined
PRVLOOP  CLC   PRVOBJT,XAPLTYPE    Object type match input?
         BE    PRVFOUND            Yes, privilege was found
         LA    R9,PRVENTLN(R9)     Bump base register to next entry
         BCT   R4,PRVLOOP          More entries, continue checking
         B     PRVNTFND            All entries processed, no match
*----------------------------------------------------------------------
* The Rule Table was found, save its address in register 9
*----------------------------------------------------------------------
PRVFOUND L     RULPTR,PRVRULE@     Return the addr of the Rule Table
         B     PRVEND              Skip not found logic
*----------------------------------------------------------------------
* The Rule Table was not found, set return and reason codes
*----------------------------------------------------------------------
PRVNTFND LA    RTN_CODE,RC_DEFER   Set return code to defer
         MVC   RSN_CODE,RSN_UNDEF_PRV
PRVEND   DS    0H
         DROP  R5
         DROP  R9
END_GETRULES   BR    14            Return to mainline
         EJECT
*----------------------------------------------------------------------
*  IMPLICIT_CHECK:
*   IF the user's primary authorization id matches the object owner OR
*      the user's authorization id matches the object owner THEN
*   DO
*   | Allow access
*   | - Set RTN_CODE to 0 (allow access)
*   | - Set RSN_CODE to 13 (object owner)
*   | - Set XAPLONWT for UPDATE and REFERENCE privileges
* <---- Return to DB2
*   END the user owns the object
*
*  INPUT:
*   RESPTR   - Address of Resource Table Entry
*
*  OUTPUT:
*   RTN_CODE - Return Code
*   RSN_CODE - Reason Code
*   XAPLONWT - (UPDATE or REFERENCES)
*              ' ' - Privilege is on whole table
*              '*' - Privilege is this column only
*
*----------------------------------------------------------------------
IMPLICIT_CHECK     DS 0H
         USING  RESENTRY,RESPTR
         LH    R4,RESOWNOF         Find offset into XAPL of owner
         LTR   R4,R4               Is there an owner for this resource?
         BZ    NOTOWNER            No, skip the check
         AR    R4,XAPLPTR          Caclulate address of owner
*----------------------------------------------------------------------
* Does user's primary auth id match the object owner
*----------------------------------------------------------------------
         CLC   XAPLUPRM,0(R4)
         BE    OWNER
*----------------------------------------------------------------------
* Does user's auth check id match the object owner
*----------------------------------------------------------------------
         CLC   XAPLUCHK,0(R4)
         BNE   NOTOWNER
OWNER    LA    RTN_CODE,RC_ALLOW   Allow access
         MVC   RSN_CODE,RSN_OWNER
*----------------------------------------------------------------------
* Set XAPLONWT for UPDATE and REFERENCES authorities
*----------------------------------------------------------------------
         CLI   XAPLTYPE,TABLE      Is the object type = table?
         BNE   ENDONWT1            No, skip ONWT processing
         LA    R4,UPDTEAUTT        UPDATE Privilege code
         CH    R4,XAPLPRIV         Does XAPLPRIV = UPDATE?
         BE    SETONWT1            Yes, set XAPLONWT
         LA    R4,REFERAUTT        No, Check for REFERENCES
         CH    R4,XAPLPRIV         Does XAPLPRIV = REFRENCES?
         BNE   ENDONWT1            No, skip ONWT processing
SETONWT1 MVI   XAPLONWT,C' '       Indicate authority is on whole table
ENDONWT1 DS    0H                  Not UPDATE or REFERENCE privilege
NOTOWNER DS    0H
         DROP  RESPTR
END_IMPLICIT_CHECK BR    14        Return to mainline
         EJECT
*------------------------------------------------------------------@L1A
*  MATCH_CHECK:                                                    @L1A
*   IF the privilege code/object type is either:                   @L1A
*         COMMENT ON    Schema                                     @L1A
*         ALTERIN       Schema                                     @L1A
*         CREATEIN      Schema                                     @L1A
*         DROPIN        Schema                                     @L1A
*         START         UDF, SPROC                                 @L1A
*         STOP          UDF, SPROC                                 @L1A
*         DISPLAY       UDF, SPROC                                 @L1A
*   DO                                                             @L1A
*   | If the SCHEMA NAME (XAPLOWNQ for all cases except CREATEIN,  @L1A
*   | where the SCHEMA NAME is in XAPLOBJN) is equal to either     @L1A
*   | the primary user ID (XAPLUPRM) or current SQL ID (XAPLUCHK)  @L1A
*   | then                                                         @L1A
*   |  | Allow access                                              @L1A
*   |  | - Set RTN_CODE to 0 (allow access)                        @L1A
*   |  | - Set RSN_CODE to 14 (schema name = user ID)              @L1A
* <-|-- Return to DB2                                              @L1A
*   |  END                                                         @L1A
*   END the user MATCHes the SCHEMA                                @L1A
*                                                                  @L1A
*  INPUT:                                                          @L1A
*   XAPLACEE - Address of execution user ID                        @L1A
*   XAPLPRIV - Privilege code                                      @L1A
*   XAPLTYPE - Type of DB2 resource that is being checked          @L1A
*   XAPLOBJN - Schema name (CREATEIN privilege only)               @L1A
*   XAPLOWNQ - Schema name (other than for CREATEIN privilege)     @L1A
*                                                                  @L1A
*  OUTPUT:                                                         @L1A
*   RTN_CODE - Return Code                                         @L1A
*   RSN_CODE - Reason Code                                         @L1A
*                                                                  @L1A
*------------------------------------------------------------------@L1A
MATCH_CHECK        DS 0H                                           @L1A
*------------------------------------------------------------------@L1A
*------------------------------------------------------------------@L1A
             EJECT                                                 @L1A
*------------------------------------------------------------------@L1A
* Is this a check for a privilege on a schema? If it is,           @L1A
* then continue.  If it is not, then go to NO_SCHEMA_MATCH.        @L1A
*------------------------------------------------------------------@L1A
CHECK_TYPE     EQU  *                                              @L1A
         CLI   XAPLTYPE,SCHEMA     Is this a SCHEMA? If not, then  @L1A
         BNE   CHECK_TYPE_UDT      see if this is some other       @L1A
*                                  object type that requires a     @L1A
*                                  "user ID = schema name" check   @L1A
*------------------------------------------------------------------@L1A
* Now, check to see if this is any of the privilege codes that     @L1A
* require a "user ID =  schema name" (commonly called a            @L1A
* "match") check. The privilege codes are: COMMENT ON (097),       @L1A
* ALTERIN (252), CREATEIN (261), and DROPIN (262).                 @L1A
*                                                                  @L1A
*                              If the privilege code is any        @L1A
* of these, then go to CHECK_MATCH to see if the schema name       @L1A
* is the same as the user ID. If the privilege code is not one     @L1A
* of these values, then go on to see if a check is being           @L1A
* performed on a distinct type (UDT).                              @L1A
*------------------------------------------------------------------@L1A
CHECK_SCEHMA_PRIVCODE   EQU *                                      @L1A
         LA    R4,COMNTAUTM                                        @L1A
         CH    R4,XAPLPRIV                                         @L1A
         BE    CHECK_MATCH                                         @L1A
*
         LA    R4,ALTINAUTM                                        @L1A
         CH    R4,XAPLPRIV                                         @L1A
         BE    CHECK_MATCH                                         @L1A
*
         LA    R4,CREINAUTM                                        @L1A
         CH    R4,XAPLPRIV                                         @L1A
         BE    CHECK_MATCH_CREATEIN                                @L1A
*
         LA    R4,DRPINAUTM                                        @L1A
         CH    R4,XAPLPRIV                                         @L1A
         BE    CHECK_MATCH                                         @L1A
         B     NO_SCHEMA_MATCH                                     @L1A
*
CHECK_TYPE_UDT EQU *                                               @L1A
         CLI   XAPLTYPE,UDT                                        @L1A
         BE    CHECK_UDT_UDF_SPROC_PRIVCODE                        @L1A
         CLI   XAPLTYPE,UDF                                        @L1A
         BE    CHECK_UDT_UDF_SPROC_PRIVCODE                        @L1A
         CLI   XAPLTYPE,SPROC                                      @L1A
         BE    CHECK_UDT_UDF_SPROC_PRIVCODE                        @L1A
         B     NO_SCHEMA_MATCH                                     @L1A
*------------------------------------------------------------------@L1A
* User-defined functions (UDFs), and                               @L1A
* stored procedures (SPROCs) may both have the DISPLAY (267),      @L1A
* START (265) and STOP (266) privilege codes. At this point we     @L1A
* must be processing either a UDF or SPROC. We now check to        @L1A
* see if the PRIVCODE (XAPLPRIV) is either DISPLAY, START,         @L1A
* or STOP. If it is, then we check the schema name by branching    @L1A
* to CHECK_MATCH. If it is not, then we return by brancing to      @L1A
* NO_SCHEMA_MATCH.                                                 @L1A
*------------------------------------------------------------------@L1A
CHECK_UDT_UDF_SPROC_PRIVCODE   EQU *                               @L1A
         LA    R4,DISPAUTO                                         @L1A
         CH    R4,XAPLPRIV                                         @L1A
         BE    CHECK_MATCH                                         @L1A
*
         LA    R4,STRTAUTO                                         @L1A
         CH    R4,XAPLPRIV                                         @L1A
         BE    CHECK_MATCH                                         @L1A
*
         LA    R4,STPAUTO                                          @L1A
         CH    R4,XAPLPRIV                                         @L1A
         BE    CHECK_MATCH                                         @L1A
         B     NO_SCHEMA_MATCH                                     @L1A
*------------------------------------------------------------------@L1A
* CHECK_MATCH:                                                     @L1A
* See if the schema name is the same ("matches") the primary       @L1A
* authorization ID (XAPLUPRM) or SQL authorization ID (XAPLUCHK).  @L1A
* Set the return code to 0 (access allowed) and reason             @L1A
* code 17 (schema match) if the schema name matches either         @L1A
* XAPLUPRM or XAPLUCHK.                                            @L1A
*                                                                  @L1A
* The schema name is in XAPLOWNQ for COMMENT ON, ALTERIN, DROPIN,  @L1A
* START, STOP, and DISPLAY. The schema name is in XAPLOBJN for     @L1A
* CREATEIN.                                                        @L1A
*------------------------------------------------------------------@L1A
CHECK_MATCH    EQU   *                                             @L1A
         CLC   XAPLUCHK,XAPLOWNQ   Is the schema name = user ID?   @L1A
         BE    SCHEMA_MATCH        Yes? A match!                   @L1A
         B     NO_SCHEMA_MATCH     No? No match...                 @L1A
CHECK_MATCH_CREATEIN EQU   *       This is a CREATEIN check        @L1A
         CLC   XAPLUCHK,XAPLOBJN   Is the schema name = user ID?   @L1A
         BE    SCHEMA_MATCH        Yes? A match!                   @L1A
         B     NO_SCHEMA_MATCH     No? No match...                 @L1A
SCHEMA_MATCH   EQU   *                                             @L1A
         LA    RTN_CODE,RC_ALLOW   Allow access                    @L1A
         MVC   RSN_CODE,RSN_MATCH  Set the return code to 17       @L1A
         BR    14                  Return to mainline              @L1A
NO_SCHEMA_MATCH    EQU   *                                         @L1A
         LA    RTN_CODE,RC_FAIL    The schema name wasn't the      @L1A
*                                  same as the execution user ID   @L1A
END_MATCH_CHECK    BR    14        Return to mainline              @L1A
         EJECT                                                     @L1A
*----------------------------------------------------------------------
*  FASTAUTH_CHECK:
*   Determine if user has access via RACF profiles:
*     Check for blank class abbreviation in Resource Table Entry
*     (A blank means that no FASTAUTH authority checking should be
*     performed for this entry).  If a blank is found skip the
*     FASTAUTH check and return to mainline.
*   Otherwise...
*   - Build the class name by invoking the BLD_CLASS macro
*   - Build the resource name by invoking the BLD_RES macro
*   - IF processing the first rule THEN
*     DO
*     | Build the LOGSTR data consisting of:
*     | - LOGSTR len || XAPLSTCK || XAPLUCHK ||
*     |   Class Name || Resource Name
*     END processing the first rule
*   - ELSE not processing the first rule (NOP)
*   - Invoke RACROUTE REQUEST=FASTAUTH
*     w/ MSGSUPP=YES and LOG=NOFAIL
*   - IF FASTAUTH return code = 0 THEN
*     DO
*     | Allow access
*     | - Set RTN_CODE = 0 (allow access)
*     | - Set RSN_CODE = 0 (FASTAUTH)
*     | - Set XAPLONWT for UPDATE and REFERENCE privileges
* <------ Return to DB2
*     END FASTAUTH return code = 0
*     ELSE FASTAUTH return code <> 0
*     DO
*     | Continue processing
*     | - Save the FASTAUTH return and reason codes in
*     |   the next available XAPLDIAG slot.
*     | - IF FASTAUTH return code = 8 AND
*     |      This is first FASTAUTH return code = 8 THEN
*     |   DO
*     |   | - Save the class name
*     |   | - Save the resource name
*     |   END FASTAUTH return code = 8 ...
*     END FASTAUTH return code <> 0
*
*
*  INPUT:
*   RESPTR   - Address of Resource Table Entry
*
*  OUTPUT:
*   RTN_CODE - Return Code
*   RSN_CODE - Reason Code
*   XAPLONWT - (UPDATE or REFERENCES)
*              ' ' - Privilege is on whole table
*              '*' - Privilege is this column only
*   LOGSTR   - Sets LOGSTR data to be used by subsequent invocations
*              of FASTAUTH_CHECK
*   AUDIT    - Sets AUDIT data to be used by FASTAUTH_AUDIT routine
*----------------------------------------------------------------------
FASTAUTH_CHECK  DS 0H
         STM   R4,R8,FC_SAVE1          Save work registers
         ST    R14,FC_SAVE2            Save register 14
         USING  RESENTRY,RESPTR
*----------------------------------------------------------------------
* Build the class and resource names
*----------------------------------------------------------------------
         CLC   RESCLASS,NOCLASS        Is there a class abbreviation
         BE    NOFAST                  No, skip FASTAUTH checking
         TM    XAPLFLG1,USERTAB        Is this a user table?
         BNO   DOFAST1                 No, keep going
         CLC   SYS_CTRL,RESAUTH        Yes, Is SYS_CTRL being checked?
         BE    NOFAST                  Yes, skip FASTAUTH for SYS_CTRL
DOFAST1  DS    0H                      It is ok to do the FASTAUTH
         BLD_CLASS CLASSABBR=RESCLASS,                                 X
               CLASSNAME=FAST_CLASS    Build the Class Name
         BAL   R14,BLD_RES             Build the resource Name
*----------------------------------------------------------------------
* If it is the first rule in rule table, create FASTAUTH LOGSTR data
*----------------------------------------------------------------------
         TM    FLAGS,LOGSTR_SAVED      Was LOGSTR data already created?
         BO    DOFAST2                 Yes, go do FASTAUTH
         MVC   LOGSTR_TIME,XAPLSTCK
         MVC   LOGSTR_USER,XAPLUCHK
         MVC   LOGSTR_SUBSYSTEM,XAPLGPAT                           @02A
         MVC   LOGSTR_OBJTYPE,XAPLTYPE                             @02A
         MVC   LOGSTR_OBJNAME,XAPLOBJN                             @02A
         MVC   LOGSTR_OBJOWNER,XAPLOWNQ                            @02A
         MVC   LOGSTR_REL1,XAPLREL1                                @02A
         MVC   LOGSTR_REL2,XAPLREL2                                @02A
*----------------------------------------------------------------------
* Convert privilege into decimal and then EBCDIC readable form     @02A
*----------------------------------------------------------------------
         LH    R4,XAPLPRIV             Load privilege # into reg   @02A
         CVD   R4,PACKIN               convert priv to decimal     @02A
         UNPK  LOGSTR_PRIV,PACKIN      convert to EBCDIC           @02A
         OI    LOGSTR_PRIV+2,X'F0'     change sign byte            @02A
*----------------------------------------------------------------------
         MVC   LOGSTR_SOURCE,XAPLFROM                              @02A
         MVC   LOGSTR_CLASS,FAST_CLASS
         MVC   LOGSTR_ENTY,FAST_ENTY
         TM    XAPLFLG1,SECONDARY_ID   Check for secondary id      @02A
         BNO   CKTABBIT                No, keep going              @02A
         MVC   LOGSTR_SECNDRY_ID,YES   Indicate yes in LOGSTR data @02A
CKTABBIT TM    XAPLFLG1,USERTAB        Is this a user table?       @02A
         BNO   GETLENS                 No, keep going              @02A
         MVC   LOGSTR_USERTAB,YES      Indicate yes in LOGSTR data @02A
GETLENS  DS    0H                                                  @02A
         LH    R4,FAST_ENTL            Get the length of entity name
         LA    R5,LOGSTR_FIXL          Get length of fixed portion
         AR    R4,R5                   Calculate length of LOGSTR
         STC   R4,LOGSTR_LEN           Store length
         OI    FLAGS,LOGSTR_SAVED      Indicate LOGSTR data created
*----------------------------------------------------------------------
* Issue FASTAUTH to determine if user has access to the resource
*----------------------------------------------------------------------
DOFAST2  DS    0H
         SLR   R8,R8                   Clear register 8
         IC    R8,RESATTR              Get required access authority
         L     R4,FAST_ACEE            Get ACEE address
         LA    R5,FAST_ALET            Get ALET address
         MVC   FASTD(FASTSLEN),FASTS   Copy static to dynamic
         STM   R2,R5,RACROUTE_SA1      Save registers 2-5
         ST    R14,RACROUTE_SA2        Save register 14
*
         RACROUTE REQUEST=FASTAUTH,                                    X
               WORKA=RACROUTE_worka,                                   X
               REQSTOR=XAC,                                            X
               SUBSYS=XAPLGPAT,                                        X
               DECOUPL=YES,                                            X
               WKAREA=FAST_wkarea,                                     X
               ENTITY=FAST_ENTY,                                       X
               CLASS=FAST_CLASS,                                       X
               ACEE=(R4),                                              X
               ACEEALET=(R5),                                          X
               ATTR=(R8),                                              X
               LOG=NOFAIL,                                             X
               MSGSUPP=YES,                                            X
               LOGSTR=LOGSTR,                                          X
               RELEASE=2.4,                                            X
               MF=(E,FASTD)
*
         LM    R2,R5,RACROUTE_SA1      Restore registers 2-5
         L     R14,RACROUTE_SA2        Restore register 14
*----------------------------------------------------------------------
* Check return code from FASTAUTH
*----------------------------------------------------------------------
         ST    R15,DBA_CODE                                        @08A
         LTR   R15,R15
         BNZ   FASTFAIL
*----------------------------------------------------------------------
* FASTAUTH return code was zero!
*----------------------------------------------------------------------
         LA    RTN_CODE,RC_ALLOW   Allow access to resource
         MVC   RSN_CODE,RSN_FASTAUTH
*----------------------------------------------------------------------
* Set XAPLONWT for UPDATE and REFERENCES authorities
*----------------------------------------------------------------------
         CLI   XAPLTYPE,TABLE      Is the object type = table?
         BNE   ENDONWT2            No, skip ONWT processing
         LA    R4,UPDTEAUTT        UPDATE Privilege code
         CH    R4,XAPLPRIV         Does XAPLPRIV = UPDATE?
         BE    SETONWT2
         LA    R4,REFERAUTT        REFERENCES privilege code
         CH    R4,XAPLPRIV         Does XAPLPRIV = REFRENCES?
         BNE   ENDONWT2            No, skip ONWT processing
SETONWT2 LH    R4,RESCOLOF         Get column qualifier offset
         LTR   R4,R4               Does resource have column qualifier?
         BNZ   ONECOL              Yes, authority for a single column
         MVI   XAPLONWT,C' '       Authority is for ALL columns
         B     ENDONWT2
ONECOL   MVI   XAPLONWT,C'*'       Authority is for this column only
ENDONWT2 B     ENDFAIL             Skip FASTAUTH failure code
*----------------------------------------------------------------------
* FASTAUTH return code was not zero!
*----------------------------------------------------------------------
FASTFAIL DS    0H
*----------------------------------------------------------------------
* Save FASTAUTH return code for later translation
*----------------------------------------------------------------------
         LR    R4,R15                Get RACROUTE return code
         MH    R4,RESTYPE            Shift return code for object class
         SRL   R4,2                  Move RC into low order nibble
         O     R4,FAST_RC            Record the return code
         STC   R4,FAST_RC_BYTE       Save return code string
*----------------------------------------------------------------------
* Save FASTAUTH return code in XAPLDIAG
*----------------------------------------------------------------------
         L     R4,DIAGNEXT           Get address of next XAPLDIAG slot
         LA    R5,XAPLDIAG+L'XAPLDIAG Get XAPLDIAG ending address
         LA    R4,DIAGMAPL-1(R4)     Get current slot ending address
         CR    R4,R5                 Does slot fit in XAPLDIAG?
         BNL   DIAGFULL              No, no more room in XAPLDIAG
         L     R4,DIAGNEXT           Replace address of XAPLDIAG slot
         USING DIAGMAP,R4            Addressability to XAPLDIAG
         STC   R15,DIAGSRET          Store SAF Return code
         LA    R5,FASTD              Get address of SAFP
         USING SAFP,R5
         MVC   DIAGRRET(1),SAFPRRET+3 Store RACF return code
         MVC   DIAGRRSN(2),SAFPRREA+2 Store RACF reason code
         LA    R4,DIAGMAPL(R4)       Calculate address of next slot
         ST    R4,DIAGNEXT           Store address of next slot
         DROP  R4
DIAGFULL DS    0H                    No more room in XAPLDIAG
*----------------------------------------------------------------------
* Save first failing resource name (class & entity) for later auditing
*----------------------------------------------------------------------
         LA    R4,RC_FAIL
         CR    R15,R4               Did FASTAUTH return an 8?
         BNE   NOSAVRES             No, don't save resource name
         C     R4,SAFPRRET          Was RACF return code an 8?     @02A
         BNE   NOSAVRES             No, don't save resource name   @02A
         L     R4,AUDIT_FAILURE                                    @02A
         C     R4,SAFPRREA          Was RACF reason code a 4?      @02A
         BNE   NOSAVRES             No, don't save resource name   @02A
         DROP  R5                                                  @02A
         TM    FLAGS,AUDIT_SAVED    Was resource saved for auditing?
         BO    NOSAVRES             Yes, don't save another
         ST    R8,AUDIT_ATTR        Save requested access,
         MVC   AUDIT_CLASS,FAST_CLASS class and
         MVC   AUDIT_ENTX,FAST_ENTX   entity
         OI    FLAGS,AUDIT_SAVED    Indicate resource saved for audit
NOSAVRES DS    0H
ENDFAIL  DS    0H
NOFAST   DS    0H
         DROP  RESPTR               Resource entry base
         LM    R4,R8,FC_SAVE1       Restore work registers
         L     R14,FC_SAVE2         Restore register 14
END_FASTAUTH_CHECK BR 14            Return to mainline
*----------------------------------------------------------------------
*  BLD_RES
*   This routine builds the FASTAUTH resource name for a particular
*   DB2 resource.  It uses the Resource Entry to locate the components
*   of the resource name in the XAPL parameter list.  The resource
*   names are built as follows:
*
*   Classification Model I,
*      RESQ1OFF.RESQ2OFF.RESCOLOF.RESAUTH
*        where,
*          RESQ1OFF = Offset into XAPL of first object qualifier
*          RESQ2OFF = Offset into XAPL of second object qualifier
*          RESCOLOF = Offset into XAPL of column qualifier
*          RESAUTH  = Name of DB2 privilege
*
*   Classification Model II,
*      XAPLGPAT.RESQ1OFF.RESQ2OFF.RESCOLOF.RESAUTH
*        where,
*          XAPLGPAT = DB2 subsystem or data sharing group name
*          RESQ1OFF = Offset into XAPL of first object qualifier
*          RESQ2OFF = Offset into XAPL of second object qualifier
*          RESCOLOF = Offset into XAPL of column qualifier
*          RESAUTH  = Name of DB2 privilege
*
*   For either model RESQ1OFF, RESQ2OFF and RESCOLOF do not contain
*   the actual qualifier name.  Instead they are offsets used to
*   locate the qualifier in the XAPL.  If RESQ1LEN, RESQ2LEN or
*   REQCOLLN is zero then that qualifier is omitted from the resource
*   name.
*
*  INPUT:
*   RESPTR - Address of Resource Table Entry
*
*  OUTPUT:
*   FAST_ENTX - FASTAUTH resource name
*   RTN_CODE  - Return Code
*   RSN_CODE  - Reason Code
*----------------------------------------------------------------------
BLD_RES     DS    0H
            USING RESENTRY,RESPTR
*----------------------------------------------------------------------
* Build the resource name
*----------------------------------------------------------------------
            MVI   FAST_ENTY,X'40'           Set first char to blank
            MVC   FAST_ENTY+1(L'FAST_ENTY-1),FAST_ENTY Clear entity
*                                                                 1@05D
            LA    R5,FAST_ENTY              Load R5 with entity addr
*                                                                 3@05D
            AIF   ('&CLASSOPT' EQ '1').MODEL1
*----------------------------------------------------------------------
* Prefix Resource Name with DB2 subsystem name
*----------------------------------------------------------------------
            MVC   0(L'XAPLGPAT,R5),XAPLGPAT Move in DB2 subsystem
            AH    R5,LEN$GPAT&RTNSUFX       Bump result address    @05C
            MVI   0(R5),C'.'                Add period after qualifier
            LA    R5,1(,R5)                 Bump result address    @05C
.MODEL1     ANOP
*----------------------------------------------------------------------
* Use Resource Table entry to build object and authority qualifiers
*----------------------------------------------------------------------
            AIF   ('&XAPLDBCK' EQ '0').SKIPDB5                     @08A
            CLI   FLAGS2,CRTVUAUT_CHECK+DBADM_T_CHECK              @08A
            BNE   MOVEQ1                                           @08A
            L     R4,DBINFPTR                                      @08A
            USING XAPLDBS,R4                                       @08A
            MVI   XAPLDBDA,C'N'             Init to 'N'            @08A
            LA    R6,XAPLDBNM               Load the name          @08A
            LA    R7,8                      Set max len            @08A
            STRLEN   BUF=R6,BUFLEN=R7       Get the Length         @08A
            BCTR  R7,0                      Decrement len for EX   @08A
            EX    R7,MOVEDB                 copy qualifier to      @05A
            LA    R7,1(,R7)                 Adjust for BCTR        @08A
            AR    R5,R7                     Bumb the dest addr     @08A
            MVI   0(R5),C'.'                Add period after qual  @08A
            LA    R5,1(,R5)                 Bump result address    @08A
            DROP  R4                                               @08A
            B     MOVEQ2                                           @08A
MOVEDB      MVC   0(0,R5),0(R6)             Move: DBNAME           @08A
MOVEQ1      DS    0H                                               @08A
.SKIPDB5 ANOP                                                      @08A
            MOVEQUAL SRC=RESQ1,DEST=R5,REG=(R6,R7,R8)              @05C
            AIF   ('&XAPLDBCK' EQ '0').SKIPDB6                     @08A
MOVEQ2      DS    0H                                               @08A
.SKIPDB6 ANOP                                                      @08A
            MOVEQUAL SRC=RESQ2,DEST=R5,REG=(R6,R7,R8)              @05C
            MOVEQUAL SRC=RESCOL,DEST=R5,REG=(R6,R7,R8)             @05C
*                                                                30@05D
            MVC   0(L'RESAUTH,R5),RESAUTH   Authority Qaulifier
            AH    R5,RESAUTHL               Bump result address    @05C
*----------------------------------------------------------------------
* Store length of resource in second length field for entityx
*----------------------------------------------------------------------
            LA    R4,FAST_ENTY              Locate beginning
            SR    R5,R4                     Determine length
            STH   R5,FAST_ENTL              Store actual entity length
            L     R8,TRTAB                                         @08A
            BCTR  R5,0                      Decrement len for EX   @05A
            EX    R5,TRANSLATE              Translate blanks       @05A
            LA    R4,FAST_ENTYL             Get length of buffer
            STH   R4,FAST_BUFL              Store buffer length
            B     END_BLD_RES               Branch around EX       @05C
TRANSLATE   TR    0(0,R4),0(R8)             Blanks to underscores  @08C
            DROP  RESPTR                    Resource entry base
END_BLD_RES BR    14
            EJECT
*----------------------------------------------------------------------
*  FASTAUTH_AUDIT
*   Original FASTAUTHs performed in FASTAUTH_CHECK were done with
*   LOG=NOFAIL.  To ensure proper auditing occurs, FASTAUTH must be
*   issued again with LOG=ASIS.   The resource used will be the first
*   resource for which a RACROUTE return code 8 was received.
*
*  INPUT:
*   AUDIT - Saved Class Name, Resource Name and access authority
*           of failing request (saved by FASTAUTH_CHECK).
*
*  OUTPUT:
*   none.
*----------------------------------------------------------------------
FASTAUTH_AUDIT     DS 0H
         L     R8,AUDIT_ATTR           Get saved access authority
         L     R4,FAST_ACEE            Get saved ACEE address
         LA    R5,FAST_ALET            Get saved ALET address
         MVC   FASTD(FASTSLEN),FASTS   Copy static to dynamic
         STM   R2,R5,RACROUTE_SA1      Save registers 2-5
         ST    R14,RACROUTE_SA2        Save register 14
*
FASTAUDIT RACROUTE REQUEST=FASTAUTH,                                   X
               WORKA=RACROUTE_worka,                                   X
               REQSTOR=XAC,                                            X
               SUBSYS=XAPLGPAT,                                        X
               DECOUPL=YES,                                            X
               WKAREA=FAST_wkarea,                                     X
               ENTITY=AUDIT_ENTY,      Use saved ENTITYX               X
               CLASS=AUDIT_CLASS,      Use saved class name            X
               ACEE=(R4),                                              X
               ACEEALET=(R5),                                          X
               ATTR=(R8),              Use saved access authority      X
               LOG=ASIS,               Perform requested logging       X
               LOGSTR=LOGSTR,          Use original LOGSTR data        X
               RELEASE=2.4,                                            X
               MF=(E,FASTD)
*
NOAUDIT  DS    0H
         LM    R2,R5,RACROUTE_SA1      Restore registers 2-5
         L     R14,RACROUTE_SA2        Restore register 14
END_FASTAUTH_AUDIT BR     14
         EJECT
*----------------------------------------------------------------------
* $FRRDESC
*----------------------------------------------------------------------
* DSNX@FRR - FRR Recovery Routine:
*
*  Establish Addressability to
*  - SDWA (R1)
*  - 24 byte FRR parameter area (PARMAD)
*  - static area of DSNX@XAC
*  - dynamic area of DSNX@XAC
*  - EXPL
*  - XAPL
*  If unable to establish addressability, percolate immediately
*
*  Update the SDWA
*
*  Issue an SDUMPX to
*  - Take a summary dump.  Include from the PRIMARY address space
*    - the dynamic area contents
*    - the static area contents
*    - the EXPL
*    - the EXPL Work Area
*    - XAPL
*    - SQA,PSA,RGN,SPA,TRT,CSA if available
*  - dump the HOME address space
*
*  Delete the Access List Entry
*  Delete the cell/dynamic storage
*  Percolate
*
*  Register Contents on Entry:
*    R0     - Address of a 304-byte work area for the FRR - UNUSED
*    R1     - Address of the SDWA
*    R2     - Address of the 24-byte parameter area returned by
*             the SETFRR macro.  This parameter area is mapped by the
*             FRR_PARMP DSECT and contains the pointers
*             - FRR_EXPL  - Address of the EXPL
*             - FRR_XAPL  - Address of the XAPL
*             - FRR_CELLP - Address of the dynamic area
*             - FRR_CODEP - Address of the static area
*    R3-R13 - Available
*    R14    - Return address to the system
*    R15    - Address of the FRR
*
*   Attributes on Entry:
*     Location:       Private
*     State:          Supervisor
*     AMODE:          31
*     RMODE:          Any
*     Key:            0
*     Mode:           Task or SRB
*     ASC Mode:       Primary
*     Type:           Reentrant
*     Serialization:  None
*
*   Register Conventions:
*        R0-R2   - Reserve for system macros
*        R3      - Work register
*        R4      - SDWARC1 base register and work register
*        R5-R6   - Work register
*        R7      - EXPL base register
*        R8      - SDWA base register
*        R9      - Work register
*        R10     - XAPL base register
*        R11     - Data register
*        R12     - Code register
*        R13     - Savearea register
*        R14-R15 - BAL registers
*
*----------------------------------------------------------------------
DSNX@FRR DS    0H
*----------------------------------------------------------------------
* $FRRCODE - DSNX@FRR FRR Recovery Routine
*----------------------------------------------------------------------
* Establish addressability
* - IF FRR_CELLP is not initialized THEN
*   DO
*   | - Can't establish addressability to the dynamic area and may
*   |   not have addressability to the static area.
*   |   Percolate.
*   END
*----------------------------------------------------------------------
         PUSH  USING                    Save the current USINGs
         LR    R8,R1                    SDWA
         USING SDWA,R8
         L     R5,SDWAPARM              PARMAD
         USING FRR_PARMP,R5
         L     R12,FRR_CODEP            Static area
         L     R11,FRR_CELLP            Dynamic area
         LTR   R11,R11                  Is FRR_CELLP initialized?
         BNZ   TAKEDUMP                 Yes, take dump and do cleanup
         SETRP WKAREA=((R8)),RC=0       No, Unable to establish
*                                       addressability to dynamic and
*                                       static areas.  Percolate.
         BR    R14                      Return to RTM
*
TAKEDUMP DS    0H                       Have addressability to static
*                                       and dynamic areas.
         L     R7,FRR_EXPL              EXPL
         USING EXPL,R7
         L     R10,FRR_XAPL             XAPL
         DROP  R3                       DROP prior using for the XAPL
         USING XAPL,R10
         DROP  R5
         ST    R14,XFRR_RETURN          Save return address
*----------------------------------------------------------------------
* Update the SDWA
*----------------------------------------------------------------------
         SETRP WKAREA=((R8)),RECPARM=XACSRECPARM
         MVC SDWAMODN,MODN              Module name
         MVC SDWACSCT,CSCT              Csect name
         L   R4,SDWAXPAD                Establish addressability
         USING SDWAPTRS,R4              to additional SDWA fields
         L   R4,SDWASRVP
         USING SDWARC1,R4
         MVC SDWACID,CID                Component id
         MVC SDWACIDB,CIDB              Component base id
         MVC SDWAREXN,REXN              Recovery routine name
         MVC SDWARRL,REXN               Recovery routine label
         MVC SDWASC,SC                  Component
         MVC SDWAMDAT,MDAT              Assemble date
         MVC SDWAMVRS,MVRS              Version or APAR number
*----------------------------------------------------------------------
* Issue an SDUMPX to save diagnostic information
* - Initialize the dump header
* - IF there was a system abend THEN
*   | - Convert the system abend code to EBCIDIC
*   ELSE Convert the user abend code decimal and then to EBCIDIC
* - IF there was a reason code THEN
*   DO
*   | - Convert the reason code to EBCIDIC and add to the dump header
*   END
* - Convert the total module length to EBCIDIC and add to dump header
* - Issue the SDUMPX to capture the HOME address space and information
*   from the PRIMARY.
*----------------------------------------------------------------------
         MVC   SDUMPHDRD,SDUMPHDRS      Initialize the dynamic
*                                       storage
         SLR   R5,R5                    Check if system or user abend
         ICM   R5,7,SDWACMPC
         N     R5,SYSCODEMASK
         BZ    CONVERTUSERABEND
*----------------------------------------------------------------------
* Convert system abend code to EBCIDIC and put in dump header
*----------------------------------------------------------------------
         STCM  R5,15,PACKIN
         UNPK  PACKOUT(10),PACKIN(5)
         MVC   SYSCODE,PACKOUT+3        Put system abend code in
*                                       the header
         NC    SYSCODE,ZONECHARS3       Clear zone
         TR    SYSCODE,TRTABLE0         Convert code to EBCIDIC values
         B     CKREASONCODE             Go check for reason code
*----------------------------------------------------------------------
* Convert user abend code to EBCIDIC and put in dump header
*----------------------------------------------------------------------
CONVERTUSERABEND  DS  0H
         SLR   R5,R5
         ICM   R5,7,SDWACMPC
         N     R5,USERCODEMASK          Isolate user abend code
         CVD   R5,PACKIN                Convert hex code to
*                                       decimal number
         UNPK  PACKOUT(8),PACKIN(8)     Convert decimal number
*                                       to EBCIDIC
         OC    SIGNBYTE(1),SIGN         Make sign byte printable
         MVC   USERCODE,USERCODEEBCIDIC Put code into header
         MVC   ABENDTYPE,USERABEND      Indicate it is a user abend
*----------------------------------------------------------------------
* If a reason code exists, add it to the dump header
*----------------------------------------------------------------------
CKREASONCODE   DS  0H
         TM    SDWACMPF,SDWARCF         Is a reason code available?
         BZ    ADDMODLEN                No, skip reason code processing
         MVC   PACKIN(4),SDWACRC        Copy reason code to work area
         UNPK  PACKOUT,PACKIN(5)
         MVC   REASONCODE,PACKOUT+1     Copy code to the dump header
         NC    REASONCODE,ZONECHARS8    Clear zone
         TR    REASONCODE,TRTABLE0      Convert the code to EBCDIC
         DROP R4
*----------------------------------------------------------------------
* Add the total module length to the dump header
*----------------------------------------------------------------------
ADDMODLEN DS    0H
         L     R5,XACS_TOTAL_LEN        Get length of all CSECTs
         STCM  R5,15,PACKIN
         UNPK  PACKOUT,PACKIN(5)        Convert length to zoned format
         MVC   MODLEN,PACKOUT+1         Put module length in header
         NC    MODLEN,ZONECHARS8        Clear zones
         TR    MODLEN,TRTABLE0          Convert code to EBCIDIC values
*----------------------------------------------------------------------
* Initialize the list of storage to dump
* - The dynamic area
* - The static area
* - The EXPL contents
* - The EXPL Work Area contents
* - The XAPL contents
* Issue the SDUMPX
*----------------------------------------------------------------------
ISSUEDUMP DS    0H
         ST    R11,CELL_START           Start/End of dynamic area
         LA    R4,@ENDDATD
         ST    R4,CELL_END
         ST    R7,EXPL_START            Start/End of EXPL
         LA    R4,EXPLLEN(R7)
         ST    R4,EXPL_END
         L     R4,EXPLWA                Start/End of EXPL Work Area
         ST    R4,EXPLWA_START
         LA    R4,WA_LEN(R4)
         ST    R4,EXPLWA_END
         ST    R10,XAPL_START           Start/End of XAPL
         LH    R4,XAPLLEN
         AR    R4,R10
         ST    R4,XAPL_END
         DROP  R10
         ST    R12,STATIC_START         Start/End of static area
         NI    STATIC_START,X'7F'       Clear high order bit
         L     R4,XACS_TOTAL_LEN
         AR    R4,R12
         ST    R4,STATIC_END
         NI    STATIC_END,X'7F'         Clear high order bit
         LA    R4,STORAGE_LIST_LEN      Save the length in bytes
         ST    R4,LIST_LEN
         SR    R4,R4                    Set ALET to  PRIMARY
         ST    R4,LIST_ALET
         LA    R4,RANGE_COUNT           Set the number of ranges in
         ST    R4,LIST_RANGE_COUNT      the list
         LA    R13,SDUMPSAVE            Give SDUMP a save area
         MVC   SDUMPXD(SDUMPXSLEN),SDUMPXS Copy static to dynamic
         SDUMPX HDRAD=SDUMPHDRD,                                       X
               BRANCH=YES,                                             X
               SDATA=(SUMDUMP,SQA,PSA,RGN,LPA,TRT,CSA),                X
               SUMLSTL=STORAGE_LIST,                                   X
               SUSPEND=YES,                                            X
               TYPE=XMEME,                                             X
               MF=(E,SDUMPXD)
*----------------------------------------------------------------------
* CLEANUP:
* - Delete Access List Entry (DU-AL), if one was created
*----------------------------------------------------------------------
         TM    FLAGS,ALET_ADDED         Was ALET added to DU-AL?
         BNO   FRREXPL                  No, skip delete processing
         MVC   ALESERVD(ALESERVSLEN),ALESERVS Copy static to dynamic
         ALESERV DELETE,                Delete ALET                    X
               CHKEAX=NO,               Don't check EAX authority      X
               ALET=FAST_ALET,          Address of ALET to be deleted  X
               RELATED=ASERV,                                          X
               MF=(E,ALESERVD)
*----------------------------------------------------------------------
* Delete the Cell Pool
*----------------------------------------------------------------------
FRREXPL  L     R4,EXPLWA                Get address of EXPL work area
         USING WA_MAP,R4
         L     R4,WA_CPID               Get autodata cell pool address
         CPOOL FREE,CPID=(R4),CELL=(R11),REGS=USE
*----------------------------------------------------------------------
* Return to RTM
*----------------------------------------------------------------------
PERCOLATE DS 0H
         SETRP WKAREA=((R8)),RC=0       RTM should percolate
         L     R14,XFRR_RETURN          Restore return address
         POP   USING                    Restore USINGs
         BR    R14                      RETURN TO RTM
            EJECT
*----------------------------------------------------------------------
* Autodata Declares
*----------------------------------------------------------------------
@DATD             DSECT
@SAVE             DS 18F
IN_SAVE1          DS 5F
IN_SAVE2          DS 1F
FC_SAVE1          DS 5F
FC_SAVE2          DS 1F
RACROUTE_SA1      DS 4F
RACROUTE_SA2      DS 1F
EXPLPTR           DS A
DIAGNEXT          DS A
RACROUTE_WORKA    DS CL512
FAST_WKAREA       DS 16F
FAST_CLASS        DS CL8
*
FAST_ENTX         DS 0CL104
FAST_BUFL         DS H
FAST_ENTL         DS H
FAST_ENTY         DS CL100
FAST_ENTYL        EQU *-FAST_ENTY
*
FAST_RC           DS 0F
                  DS XL3
FAST_RC_BYTE      DS XL1
*
FLAGS             DS XL1
LOGSTR_SAVED      EQU X'01'
AUDIT_SAVED       EQU X'02'
ALET_ADDED        EQU X'04'
*
FLAGS2            DS XL1                                           @08A
CRTVUAUT_CHECK    EQU X'01'                                        @08A
DBADM_T_CHECK     EQU X'02'                                        @08A
*
                  DS CL2                                           @08C
*
                  AIF   ('&XAPLDBCK' EQ '0').SKIPDB7               @08A
DBINFPTR          DS A         Pointer for DBNAME structure        @08A
.SKIPDB7          ANOP                                             @08A
DBA_CODE          DS F                                             @08A
*
FAST_ACEE         DS A
FAST_ALET         DS A
HOME_ALET         EQU 2
PRIM_ALET         EQU 0
*
RSN_CODE          DS F
*
LEN$GPAT&RTNSUFX  DS H         Actual length of XAPLGPAT string    @05A
*
*----------------------------------------------------------------------
* The following are used to store the actual lengths of character
* strings passed as input in the XAPL.  Once the length of an input
* field has been calculated, the length will be stored to prevent
* repetitive length calculations.
*------------------------------------------------------------------@05A
LD$OBJN           DS 0F        XAPLOBJN length descriptor          @05A
FLG$OBJN           DS XL1       length calculated indicator        @05A
                   DS XL1       reserved for alignment             @05A
LEN$OBJN           DS H         length of input string             @05A
*
LD$OWNQ           DS 0F        XAPLOWNQ length descriptor          @05A
FLG$OWNQ           DS XL1       length calculated indicator        @05A
                   DS XL1       reserved for alignment             @05A
LEN$OWNQ           DS H         length of input string             @05A
*
LD$REL1           DS 0F        XAPLREL1 length descriptor          @05A
FLG$REL1           DS XL1       length calculated indicator        @05A
                   DS XL1       reserved for alignment             @05A
LEN$REL1          DS H          length of input string             @05A
*
LD$REL2           DS 0F        XAPLREL2 length descriptor          @05A
FLG$REL2           DS XL1       length calculated indicator        @05A
                   DS XL1       reserved for alignment             @05A
LEN$REL2           DS H         length of input string             @05A
*
LOGSTR            DS 0CL242                                        @02C
LOGSTR_LEN        DS 1B
LOGSTR_DATA       DS 0CL241                                        @02C
LOGSTR_TIME       DS CL8
                  DS CL1                                           @02A
LOGSTR_USER       DS CL8
                  DS CL1                                           @02A
LOGSTR_SUBSYSTEM  DS CL4                                           @02A
                  DS CL1                                           @02A
LOGSTR_OBJTYPE    DS CL1                                           @02A
                  DS CL1                                           @02A
LOGSTR_FLAGS      DS 0CL16                                         @02A
LOGSTR_SECNDRY_ID DS CL1                                           @02A
                  DS CL1                                           @02A
LOGSTR_USERTAB    DS CL1                                           @02A
                  DS CL13                                          @02A
LOGSTR_OBJNAME    DS CL20                                          @02A
                  DS CL1                                           @02A
LOGSTR_OBJOWNER   DS CL20                                          @02A
                  DS CL1                                           @02A
LOGSTR_REL1       DS CL20                                          @02A
                  DS CL1                                           @02A
LOGSTR_REL2       DS CL20      Contains first 20 bytes of XAPLREL2 @02A
                  DS CL1                                           @02A
LOGSTR_PRIV       DS CL3                                           @02A
                  DS CL1                                           @02A
LOGSTR_SOURCE     DS CL1                                           @02A
                  DS CL1                                           @02A
LOGSTR_CLASS      DS CL8
                  DS CL1                                           @02A
LOGSTR_FIXL       EQU *-LOGSTR_DATA
LOGSTR_ENTY       DS CL100
*
AUDIT             DS 0CL116
AUDIT_ATTR        DS F
AUDIT_CLASS       DS CL8
AUDIT_ENTX        DS 0CL104
AUDIT_BUFL        DS H
AUDIT_ENTL        DS H
AUDIT_ENTY        DS CL100
*
ALESERVD       ALESERV MF=L,RELATED=ASERV
*
FASTD          RACROUTE REQUEST=FASTAUTH,RELEASE=2.4,MF=L
                  EJECT
*----------------------------------------------------------------------
*  Recovery Declares
*----------------------------------------------------------------------
*
SDUMPXD        SDUMPX MF=L
*
SDUMPHDRD         DS    0CL100
SDUMPHDRLEN       DS    X
                  DS    CL60
                  DS    CL7',ABEND='
ABENDTYPE         DS    CL1'S'
USERCODE          DS    0CL4
                  DS    CL1'0'
SYSCODE           DS    CL3'xxx'
                  DS    CL8',REASON='
REASONCODE        DS    CL8'NONE    '
                  DS    CL3',L='
MODLEN            DS    CL8'zzzzzzzz'
*
SDUMPSAVE         DS    18F
XFRR_RETURN       DS    1F
*
                  DS    0D
PACKIN            DS    CL8
*
PACKOUT           DS    0CL10
                  DS    CL4
USERCODEEBCIDIC   DS    0CL4
                  DS    CL3
SIGNBYTE          DS    CL1
                  DS    CL2
*
STORAGE_LIST      DS    0A
LIST_LEN          DS    F
LIST_ALET         DS    F
LIST_RANGE_COUNT  DS    F
CELL_START        DS    A
CELL_END          DS    A
EXPL_START        DS    A
EXPL_END          DS    A
EXPLWA_START      DS    A
EXPLWA_END        DS    A
XAPL_START        DS    A
XAPL_END          DS    A
STATIC_START      DS    A
STATIC_END        DS    A
STORAGE_LIST_LEN  EQU   *-STORAGE_LIST
RANGE_COUNT       EQU   (STORAGE_LIST_LEN-12)/8
*
* The following must always appear at the end of the @DATD DSECT
@ENDDATD          DS    0X
@DYNSIZE          EQU   ((@ENDDATD-@DATD+7)/8)*8
                  EJECT
*----------------------------------------------------------------------
*  Constant Declares
*----------------------------------------------------------------------
DSNX@XAC          CSECT
                  DS   0F
@SIZDATD          DC   A(@DYNSIZE)
@FRR_RTN          DC   A(DSNX@FRR)
XACS_TOTAL_LEN    DC   A(DSNX@MSG_LEN+IRR@TOBJ_LEND+IRR@TPRV_LEN+IRR@TR*
               ES_LEN+IRR@TRUL_LEN+DSNX@XAC_LEN+IRR@XAC1_LEN)      @0CC
*
MINUS_ONE         DC   F'-1'
AUDIT_FAILURE     DC   F'4'                                        @02A
TRTAB             DC   A(TRANSTAB)
TPRV              DC   A(IRR@TPRV)
XAC1              DC   A(IRR@XAC1)
ZEROH             DC   H'0000'                                     @05C
XAC               DC   CL8'DSNX@XAC'
NOCLASS           DC   CL3'   '
YES               DC   CL1'Y'                                      @02A
NO                DC   CL1'N'                                      @02A
SYS_CTRL          DC   C'SYSCTRL'
SECONDARY_ID      EQU  B'10000000'                                 @02A
USERTAB           EQU  B'01000000'
BLANKS4           DC   CL4'    '                                   @08A
CRTVUAUT_PRIV     DC   F'108'                                      @08A
*----------------------------------------------------------------------
* Recovery Constants
*----------------------------------------------------------------------
SDUMPXS           SDUMPX MF=L
SDUMPXSLEN        EQU  *-SDUMPXS
*
SDUMPHDRS         DS   0CL100
                  DC   X'63'               Length of text
                  DC   CL11'COMPON=RACF'
                  DC   CL8',COMPID='
CIDB              DC   CL4'5752'
CID               DC   CL5'XXH00'
                  DC   CL16',ISSUER=DSNX@FRR'
                  DC   CL16',MODULE=DSNX@XAC'
                  DC   CL12',ABEND=S0xxx'
                  DC   CL16',REASON=NONE    '
                  DC   CL11',L=zzzzzzzz'
*
ZONECHARS8        DS  0XL8
ZONECHARS3        DC  XL3'0F0F0F'
                  DC  XL5'0F0F0F0F0F'
*
TRTABLE0          DC  CL16'0123456789ABCDEF'
*
SYSCODEMASK       DC   X'00FFF000'
USERCODEMASK      DC   X'00000FFF'
SIGN              DC   X'F0'
USERABEND         DC   CL1'U'
*
XACSRECPARM       DS   0CL24
MODN              DC   CL8'DSNX@XAC'       Load module name
CSCT              DC   CL8'DSNX@XAC'       CSECT name
REXN              DC   CL8'DSNX@FRR'       Recovery Routine Name
*
SC                DC   CL23'RACF/DB2 EXTRN SEC MOD'
MDAT              DC   CL8'&SYSDATE'
MVRS              DC   CL8'&SERVICELEVEL '
*----------------------------------------------------------------------
* Return and Reason Code constants
*----------------------------------------------------------------------
RC_ALLOW          EQU  0
RC_UNKNOWN        DC   F'4'                                        @08A
RC_ZERO           DS   0F                                          @08A
RSN_FASTAUTH      DC   F'0'
RSN_OWNER         DC   F'13'
RSN_MATCH         DC   F'14'                                      @L1A
*
RC_DEFER          EQU  4
RSN_NODFT_ACEE    DC   F'11'
RSN_NOALET        DC   F'14'
RSN_UNDEF_PRV     DC   F'15'
RSN_NORULES       DC   F'16'
RSN_AUTOBIND      DC   F'17'                                       @L1A
*
RC_FAIL           EQU  8
RC_NOCALL         EQU  12
                  EJECT
*----------------------------------------------------------------------
* Return Code Translation Table
*
* This table is used to translate the return codes received from
* FASTAUTH.  During execution, this routine keeps track of the
* return codes it has recieved from FASTAUTH in the FAST_RC bit string.
* Every time a non-zero return code (4 or 8) is received the FAST_RC
* bit string is ORed with the return code.   Before ORing the return
* code with FAST_RC, ADM class return codes will be shifted left two
* bits.  By doing this return codes for the ADM class can be
* distinguished from return codes for the object classes as indicated
* by the 1-byte bit string (FAST_RC_BYTE) below:
*
*      0000 WXYZ
*       where,
*        W - denotes RC=8 from object class profile
*        X - denotes RC=4 from object class profile
*        Y - denotes RC=8 from ADM class profile
*        Z - denotes RC=4 from ADM class profile
*
* NOTE: "none" in the ADM RC column below means that no ADM class
*       profiles were checked.  If ADM class profiles were checked
*       and returned with RC=0, this return code translation does not
*       occur.
*----------------------------------------------------------------------
RC_TABLE DS   0CL16
*       --------------------------------------------------------------
*       | Output    | Input | Input     | Object    | Object | ADM    |
*       | RC        | (dec) | (Binary)  | Profiles? | RC     | RC     |
*       |-----------|-------|-----------|-----------|--------|--------|
         DC   X'08' | 0     | 0000 0000 | n/a       | n/a    | n/a    |
         DC   X'04' | 1     | 0000 0001 | NO        | n/a    | All 4s |
         DC   X'08' | 2     | 0000 0010 | NO        | n/a    | All 8s |
         DC   X'04' | 3     | 0000 0011 | NO        | n/a    | Mix    |
         DC   X'04' | 4     | 0000 0100 | YES       | All 4s | none   |
         DC   X'04' | 5     | 0000 0101 | YES       | All 4s | All 4s |
         DC   X'04' | 6     | 0000 0110 | YES       | All 4s | All 8s |
         DC   X'04' | 7     | 0000 0111 | YES       | All 4s | Mix    |
         DC   X'08' | 8     | 0000 1000 | YES       | All 8s | none   |
         DC   X'08' | 9     | 0000 1001 | YES       | All 8s | All 4s |
         DC   X'08' | 10    | 0000 1010 | YES       | All 8s | All 8s |
         DC   X'08' | 11    | 0000 1011 | YES       | All 8s | Mix    |
         DC   X'08' | 12    | 0000 1100 | YES       | Mix    | none   |
         DC   X'08' | 13    | 0000 1101 | YES       | Mix    | All 4s |
         DC   X'08' | 14    | 0000 1110 | YES       | Mix    | All 8s |
         DC   X'08' | 15    | 0000 1111 | YES       | Mix    | Mix    |
*       |-------------------------------------------------------------
         EJECT
*----------------------------------------------------------------------
* ALESERV Static list form
*----------------------------------------------------------------------
ALESERVS       ALESERV MF=L,RELATED=ASERV
ALESERVSLEN    EQU *-ALESERVS
*----------------------------------------------------------------------
* FASTAUTH Static list form
*----------------------------------------------------------------------
FASTS             RACROUTE REQUEST=FASTAUTH,RELEASE=2.4,MF=L
FASTSLEN          EQU *-FASTS
*----------------------------------------------------------------------
* Patch Area
*----------------------------------------------------------------------
         PRINT ON,GEN,DATA
DSNX@XAC          CSECT
PATCH    DC    5S(*)                                              @L1C
DSNX@XAC_LEN   EQU   ((*-DSNX@XAC+7)/8*8)
         DROP  R11,R12           DROP DSNX@XAC data and code registers
         EJECT
         TITLE 'IRR@XAC1 - Initialization/Termination Routine'
**********************************************************************
* $XAC1DESC                                                          *
**********************************************************************
*                                                                    *
*01* MODULE NAME:                                                    *
*      IRR@XACS                                                      *
*                                                                    *
*02*   CSECT NAME:                                                   *
*        DSNX@XAC                                                    *
*                                                                    *
*02*   ENTRY NAME:                                                   *
*        IRR@XAC1                                                    *
*                                                                    *
*                                                                    *
*01* DESCRIPTIVE NAME:                                               *
*        RACF/DB2 External Security Module -                         *
*           Initialization/Termination Routine                       *
*                                                                    *
*01* FUNCTION:                                                       *
*      Initializes and terminates the DB2/RACF authority checking    *
*      environment.                                                  *
*                                                                    *
*01* OPERATION:                                                      *
*      For Initialization:                                           *
*        - Check for a valid input ACEE                              *
*        - Determine if RACF is active                               *
*        - Loop through DB2 object table, building a classname for   *
*          each object and then RACLISTing that class.               *
*        - Create and store a default ACEE to be used for future     *
*          authorization requests.                                   *
*                                                                    *
*      For Termination:                                              *
*        - Check for a valid input ACEE                              *
*        - Delete the RACLISTed profiles for each class in the DB2   *
*          object table.                                             *
*        - Delete the default ACEE                                   *
*                                                                    *
*                                                                    *
*02*   RECOVERY OPERATION:                                           *
*        None.                                                       *
*                                                                    *
*01* NOTES:                                                          *
*                                                                    *
*02*   DEPENDENCIES:                                                 *
*        None.                                                       *
*                                                                    *
*02*   CHARACTER CODE DEPENDENCIES:                                  *
*        None.                                                       *
*                                                                    *
*02*   RESTRICTIONS:                                                 *
*        EXPL work area is used as dynamic storage area              *
*                                                                    *
*02*   REGISTER CONVENTIONS:                                         *
*        R0-R1   - Used by system macros                             *
*        R2      - Base register for EXPL                            *
*        R3      - Base register for XAPL                            *
*        R4-R7   - Work registers for this module                    *
*        R8      - Address of entry in object table                  *
*        R9      - Index into object table                           *
*        R10     - Available register                                *
*        R11     - Data register (EXPL workarea)                     *
*        R12     - Code register                                     *
*        R13     - Callers savearea                                  *
*        R14-R15 - BALR registers                                    *
*                                                                    *
*02*   PATCH LABEL:                                                  *
*        PATCH                                                       *
*                                                                    *
*01* MODULE TYPE:                                                    *
*      CSECT                                                         *
*                                                                    *
*02*   PROCESSOR:                                                    *
*        High Level Assembler(HLASM)                                 *
*                                                                    *
*02*   MODULE SIZE:                                                  *
*        See External Symbol Dictionary                              *
*                                                                    *
*02*   ATTRIBUTES:                                                   *
*03*     LOCATION:       Private                                     *
*03*     STATE:          Supervisor                                  *
*03*     AMODE:          31                                          *
*03*     RMODE:          Any                                         *
*03*     KEY:            7                                           *
*03*     MODE:           Task                                        *
*03*     TYPE:           Reentrant                                   *
*03*     SERIALIZATION:  None                                        *
*                                                                    *
*                                                                    *
*01* ENTRY POINT:                                                    *
*      IRR@XAC1                                                      *
*                                                                    *
*02*   PURPOSE:      See FUNCTION section above                      *
*03*     OPERATION:  See OPERATION section above                     *
*03*     ATTRIBUTES: See ATTRIBUTES section above                    *
*                                                                    *
*02*   LINKAGE:                                                      *
*        BALR                                                        *
*03*     ENTRY REGISTERS:   Standard                                 *
*          0    - Irrelevant                                         *
*          1    - Parameter List Address                             *
*          2-12 - Irrelevant                                         *
*          13   - Save area address                                  *
*          14   - Return address                                     *
*          15   - Entry Point address                                *
*03*     CALLER: IRR@XACS                                            *
*                                                                    *
*01* INPUT:                                                          *
*      R1 - Points to a parameter list that contains the             *
*           addresses to the EXPL and XAPL.                          *
*                                                                    *
*                           EXPL (mapped     Work Area - 4096 bytes  *
*                           by DSNDEXPL)     (Mapped by WA_MAP)      *
*         +---------+      +---------+      +---------------------+  *
*    R1-->| EXPLPTR |----->| EXPLWA  |----->| WA_SAVE             |  *
*         |---------|      |---------|      |                     |  *
*     ----| XAPLPTR |      | EXPLWL  |      |---------------------|  *
*     |   +---------+      |---------|      | WA_CPID             |  *
*     |                    | EXPLRC1 |      |---------------------|  *
*     |                    |---------|      | WA_CSIZE            |  *
*     |                    | EXPLRC2 |      |---------------------|  *
*     |                    +---------+      | WA_DFTACEE          |  *
*     |                                     |---------------------|  *
*     |                                     | .      .      .     |  *
*     |                                     |                     |  *
*     |                                     +---------------------+  *
*     |     XAPL (mapped                                             *
*     |     by DSNDXAPL)                                             *
*     |    +----------+                                              *
*     ---->| XAPLCBID |    ** NOTE: The EXPL work area is used as    *
*          |----------|             a communication area between     *
*          | XAPLLEN  |             the initialization and           *
*          |----------|             authorization requests.          *
*          | XAPLEYE  |                                              *
*          |----------|                                              *
*          | ...      |                                              *
*          |----------|                                              *
*          | ...      |                                              *
*          |----------|                                              *
*          | ...      |                                              *
*          +----------+                                              *
*                                                                    *
*                                                                    *
*01* OUTPUT:                                                         *
*      Return code in EXPL mapping indicating the result from        *
*      the initialization/termination request.                       *
*                                                                    *
*                                                                    *
*01* EXIT NORMAL:                                                    *
*      BR 14 to caller                                               *
*                                                                    *
*02*   CONDITIONS:                                                   *
*        Successful completion of function                           *
*03*     EXIT REGISTERS:                                             *
*          0 - 14 - Restored to contents on entry                    *
*          15     - Return code                                      *
*                                                                    *
*02*   RETURN CODES:                                                 *
*      The return codes produced by IRR@XAC1 depend upon the     @09A*
*      setting of the &ERROROPT global variable and the version  @09A*
*      of DB2 (XAPLLVL) that is invoking this code.              @09A*
*                                                                @09A*
*      If &ERROROPT  is set to '2' then the codes that           @L3C*
*      are placed in EXPLRC1 (return code) and EXPLRC2 (reason   @L3C*
*      code) are:                                                @L3C*
*                                                                @09A*
*        0 - Successful completion                               @09A*
*            Reason Code:                                        @09A*
*             16 - If a subsequent call to this module returns a @09A*
*                  return code of 12, an unexpected return code, @09A*
*                  or if an abend is detected, terminate the DB2 @09A*
*                  subsystem.                                    @09A*
*                                                                @09A*
*       12 - Error encountered during initialization             @09A*
*            Reason Code:                                        @09A*
*             16 - Terminate the DB2 subsystem.                  @09A*
*                                                                @09A*
*                                                                @09A*
*      In all other cases, the return and reason codes that      @09A*
*      are placed in the EXPL mapping are:                       @09A*
*                                                                @09A*
*        0 - Successful completion                                   *
*            Reason Code:                                            *
*              0 - Successful completion of requested function       *
*              5 - Default ACEE could not be created                 *
*        8 - Error encountered during termination                    *
*            Reason Code:                                            *
*              1  - Input DB2 subsystem ACEE not provided            *
*              7  - RACROUTE REQUEST=LIST,ENVIR=DELETE failed        *
*              9  - Default ACEE could not be deleted                *
*              12 - Input DB2 subsystem ACEE not valid               *
*       12 - Error encountered during initialization                 *
*            Reason Code:                                            *
*              1  - Input DB2 subsystem ACEE not provided            *
*              2  - RACF is not active                               *
*              3  - RACROUTE REQUEST=LIST,ENVIR=CREATE failed        *
*              4  - No active DB2 classes                            *
*              12 - Input DB2 subsystem ACEE not valid               *
*                                                                    *
*02*   WAIT STATE CODES:                                             *
*        None                                                        *
*                                                                    *
*01* EXIT ERROR:                                                     *
*      None.                                                         *
*                                                                    *
*02*   CONDITIONS:                                                   *
*        None                                                        *
*03*     EXIT REGISTERS:                                             *
*          N/A                                                       *
*                                                                    *
*02*   RETURN CODES:                                                 *
*        None.                                                       *
*                                                                    *
*02*   WAIT STATE CODES:                                             *
*        None                                                        *
*                                                                    *
*01* EXTERNAL REFERENCES:                                            *
*                                                                    *
*02*   ROUTINES:                                                     *
*        None                                                        *
*                                                                    *
*02*   PANELS:                                                       *
*        None                                                        *
*                                                                    *
*02*   DIALOG VARIABLES:                                             *
*        None                                                        *
*                                                                    *
*02*   DATA AREAS:                                                   *
*        None                                                        *
*                                                                    *
*02*   CONTROL BLOCKS:                                               *
*    Macro Name   Description                                        *
*    ----------  ----------------------------------------------      *
*     IHAACEE     RACF Accessor Environment Element                  *
*     ICHSAFP     SAF Parameter List                                 *
*     DSNDEXPL    DB2 Exit Parameter List                            *
*     DSNDXAPL    Authorization Exit Parameter List                  *
*                                                                    *
*01* TABLES:                                                         *
*    Macro Name   Description                                        *
*    ----------  ----------------------------------------------      *
*     IRR@TOBJ    Authority Checking Object Table                    *
*                                                                    *
*                                                                    *
*01* MACROS:                                                         *
*                                                                    *
*02*   DECLARED:                                                     *
*        None                                                        *
*                                                                    *
*02*   EXECUTABLE:                                                   *
*    Macro Name   Description                                        *
*    ----------  ----------------------------------------------      *
*     BLD_CLASS   Constructs classname from class abbreviation       *
*                                                                    *
*                                                                    *
*01* SERIALIZATION:                                                  *
*      None.                                                         *
*                                                                    *
*                                                                    *
*01* MESSAGES:                                                       *
*      IRR900A                                                       *
*      IRR901A                                                       *
*      IRR902A                                                       *
*      IRR903A                                                       *
*      IRR904I                                                       *
*      IRR905I                                                       *
*      IRR906I                                                       *
*      IRR907I                                                       *
*      IRR908I                                                       *
*      IRR909I                                                       *
*      IRR910I                                                       *
*      IRR911I                                                       *
*      IRR912I                                                   @09A*
*      IRR913I                                                   @09A*
*      IRR914I                                                   @L3A*
*                                                                    *
*                                                                    *
*01* ABEND CODES:                                                    *
*      This module issues no ABENDs.                                 *
*                                                                    *
**********************************************************************
         EJECT
*----------------------------------------------------------------------
* $XAC1CODE - IRR@XAC1 Initialization and Termination Routine
*----------------------------------------------------------------------
DSNX@XAC CSECT
         ENTRY IRR@XAC1
IRR@XAC1 DS    0D
&RTNSUFX SETC  'XAC1'                                              @05A
         SPACE 3
*----------------------------------------------------------------------
*        REGISTER EQUATES
*----------------------------------------------------------------------
         SPACE 3
ENTRY_TABLE EQU   R8      ADDRESS OF ENTRY IN OBJECT TABLE
OBJ_INDEX   EQU   R9      USED FOR INDEXING INTO OBJECT TABLE
         SPACE 3
*----------------------------------------------------------------------
*        DSECTS
*----------------------------------------------------------------------
         SPACE 3
         PRINT   GEN
         IHAACEE               RACF ACCESSOR ENVIRONMENT ELEMENT
         EJECT
*----------------------------------------------------------------------
*        STANDARD ENTRY LINKAGE
*----------------------------------------------------------------------
DSNX@XAC CSECT
         USING *,R15
         B     @PROLOG1          BRANCH AROUND MODULE IDENTIFIER
@MAINENT1 DS    0H
         DC    CL8'IRR@XAC1'
         DC    CL8' &SERVICELEVEL'
         DC    CL8'&SYSDATE'
         DC    CL8'&SYSTIME'
         DROP  R15
@PROLOG1 DS    0H
         STM   R14,R12,12(R13)         Save callers registers
         LR    R12,R15                 Load module address into R12
@PSTART1 EQU   IRR@XAC1
         USING @PSTART1,R12            Set up base register
         LA    R15,229                 Set subpool register
         L     R0,@SIZDATD1            Set length register
         GETMAIN  RU,LV=(R0),SP=(R15)
         LR    R11,R1                  Address of getmained area
         USING @DATD1,R11              Set up data register
         ST    R13,@SAVE1+4            Set save area back pointer
         LA    R15,@SAVE1
         ST    R15,8(,R13)             Set save area forward pointer
         LM    R15,R1,16(R13)          Restore callers regs 15 and 1
         LA    R13,@SAVE1              Set save area for called rtns
         LM    R2,R3,0(R1)             Set EXPL and XAPL addresses
         EJECT
***********************************************************************
*
*        MAINLINE
*
*  Initialize return and reason codes in EXPL
*  If XAPLFUNC = initialization
*    Do;
*      Initialize default acee address
*      Call initialization routine
*    End;
*  Else
*    If XAPLFUNC = termination
*      Call termination routine
*  Return to caller
*
***********************************************************************
*
MAIN1    DS    0H
         USING EXPL,R2            SETUP ADDRESSIBILITY TO THE EXPL
         USING XAPL,R3            SETUP ADDRESSIBILITY TO THE XAPL
         LA    R5,XAPLGPAT           Get buffer address            @05A
         LA    R6,L'XAPLGPAT         Get buffer length             @05A
         STRLEN BUF=R5,BUFLEN=R6     Calculate string length       @05A
         STH   R6,LEN$GPAT&RTNSUFX   save length                   @05A
         SLR   R4,R4              ZERO OUT REGISTER
         STH   R4,EXPLRC1         INITIALIZE RETURN CODE IN EXPL
         ST    R4,EXPLRC2         INITIALIZE REASON CODE IN EXPL
         LH    R5,XAPLFUNC        LOAD REG WITH FUNCTION PASSED IN
         LA    R6,XAPLTERM        LOAD REG WITH INIT FUNCTION CODE @L3C
         CR    R5,R6              CHECK WHAT FUNCTION IS REQUESTED
         BE    TERMINAT                                            @L3C
*----------------------------------------------------------------* @L3A
*--      Note: At this point, this is either a normal          --* @L3A
*--            initialization request or the XAPLFUNC is       --* @L3A
*--            not valid because the XAPL is the wrong level.  --* @L3A
*----------------------------------------------------------------* @L3A
         L     R5,EXPLWA          GET ADDRESS OF EXPL WORK AREA
         USING WA_MAP,R5
         SLR   R4,R4              ZERO OUT REGISTER
         ST    R4,WA_CPID         INITIALIZE CELL POOL ID
         ST    R4,WA_DFTACEE      INITIALIZE DEFAULT ACEE ADDRESS
         DROP  R5
         BAL   R14,INITRTN        BRANCH TO INITIALIZATION FUNCTION
         B     FINISHED
TERMINAT BAL   R14,TERMRTN        BRANCH TO TERMINATION FUNCTION
FINISHED DS    0H
         EJECT
*----------------------------------------------------------------------
*        STANDARD EXIT LINKAGE
*----------------------------------------------------------------------
*
         L     R13,4(,R13)        Restore caller's R13
         LR    R1,R11             Address to free
         LA    R15,229            Subpool to free
         L     R0,@SIZDATD1       Length to free
         FREEMAIN RU,LV=(R0),A=(R1),SP=(R15)
         LM    R14,R12,12(R13)    RESTORE REGS
         BR    R14                RETURN TO CALLER
         EJECT
***********************************************************************
*
*        INITIALIZATION ROUTINE
*
*  Clear holding areas for messages IRR910I and IRR911I
*  If XAPLACEE is non-zero then
*    If XAPLACEE-> ACEEACEE = 'ACEE' then
*      Do;
*        Issue RACROUTE REQUEST=STAT to determine if RACF is active
*        If SAF return code is zero then
*          Do;
*            Initialize inactive class counter to zero
*            Loop through each object in object table while
*                return code is zero
*              Retrieve two character abbreviation for object
*              Invoke BLD_CLASS macro to build classname passing
*                it the two character abbreviation, classname field
*                to be filled in and a savearea.
*              Call raclist create routine to raclist the class
*            Endloop
*            If return code is zero
*              Do;
*                Invoke BLD_CLASS macro to build administrative
*                  authority classname passing it 'ADM' for class
*                  abbreviation, classname field to be filled in
*                  and a savearea.
*                Call raclist create routine to raclist the class
*                If return code is zero
*                  If the counter for inactive classes equals the
*                     number of objects in table plus one for the
*                     adminstrative class
*                    Do;
*                      Set EXPLRC1 to 12 and EXPLRC2 to 4
*                      Issue message IRR901A
*                    End;
*                  Else
*                    Do;
*                      Create Cell Pool to be used as a re-entrant
*                         workarea by authorization requests
*                      Issue RACROUTE REQUEST=VERIFY,ENVIR=CREATE,
*                         ACEE=WA_DFTACEE, to create a default
*                         acee for use during authorization checking
*                      If SAF return code is non-zero
*                        Do;
*                          Set EXPLRC1 to 0 and EXPLRC2 to 5
*                          Issue message IRR904I
*                        End;
*                    End;
*              End;
*          End;
*        Else RACROUTE REQUEST=STAT failed
*          Do;
*            Set EXPLRC1 to 12 and EXPLRC2 to 2
*            Issue message IRR903A
*          End;
*        If EXPLRC1 is non-zero
*          Call termination routine to do cleanup
*      End;
*    Else ACEE not valid
*      Do;
*        Set EXPLRC1 to 12 and EXPLRC2 to 12
*        Issue message IRR902A
*      End;
*  Else ACEE not provided
*    Do;
*      Set EXPLRC1 to 12 and EXPLRC2 to 1
*      Issue message IRR902A
*    End;
*  Invoke INFOMSGS subroutine to issue informational messages
*   describing configuration of this exit.
*  Return to caller
*
***********************************************************************
*
INITRTN  DS    0H
         STM   R14,R12,INIT_SAVEAREA
*----------------------------------------------------------------------
*        Clear holding areas for messages IRR910I and IRR911I
*----------------------------------------------------------------------
         LA    R4,USING_ARRAY
         ST    R4,USING_CURRENT   INIT CURRENT TO BEGINNING OF ARRAY
         MVI   USING_ARRAY,X'40'  CLEAR ARRAY OF CLASSES BEING USED
         MVC   USING_ARRAY+1(L'USING_ARRAY-1),USING_ARRAY
         MVC   USING_ARRAY(L'NONE),NONE MOVE IN INIT STRING
*
         LA    R4,RACL_ARRAY
         ST    R4,RACL_CURRENT    INIT CURRENT TO BEGINNING OF ARRAY
         MVI   RACL_ARRAY,X'40'   CLEAR ARRAY OF CLASSES RACLISTED
         MVC   RACL_ARRAY+1(L'RACL_ARRAY-1),RACL_ARRAY
         MVC   RACL_ARRAY(L'NONE),NONE  MOVE IN INIT STRING
*----------------------------------------------------------------------
*     Set DB2 Termination Option flag                              @09A
*     - If &ERROROPT is set to '2' then include the code which     @09A
*       - Checks to see if the DB2 version (XAPLLVL) is at least   @09A
*         DB2 Version 7 ('V7R1M0  ') and then                      @09A
*       - Sets the "Terminate DB2 on error" (TERM_DB2_OPT) flag    @09A
*----------------------------------------------------------------------
         LA    R4,0                 Initialize XAC1_FLAGS          @09A
         STC   R4,XAC1_FLAGS        to binary zero                 @09A
         AIF   ('&ERROROPT' EQ '2').TERMDB2OPT                     @09A
         AGO   .NOTERMDB2OPT                                       @09A
.TERMDB2OPT    ANOP                                                @09A
         CLC   XAPLLVL,DB2V7         Are we being invoked by a DB2 @09A
*                                    V7 or later system?           @09A
         BL    DONT_SET_TERM_DB2_OPT No? Leave the term flag off   @09A
         OI    XAC1_FLAGS,TERM_DB2_OPT Turn "term DB2" flag on     @09A
DONT_SET_TERM_DB2_OPT   EQU *                                      @09A
.NOTERMDB2OPT  ANOP                                                @09A
*----------------------------------------------------------------------
*     Check if valid ACEE exists
*----------------------------------------------------------------------
         L     R4,XAPLACEE         GET ACEE ADDRESS
         LTR   R4,R4               CHECK IF POINTER IS NON-ZERO
         BZ    NO$ACEE             ACEE DOES NOT EXIST
         USING ACEE,R4
         CLC   ACEEACEE,ACEE_EYECATCHER   CHECK FOR EYECATCHER
         BNE   BADACEE             ACEE IS NOT VALID
         DROP  R4
*------------------------------------------------------------------@L3A
*     The XAPL changed  substantially between DB2 V7 and DB2 V8.   @L3A
*     If this version of DSNX@XAC is invoked with a DB2V8 or later @L3A
*     XAPL, we need to set EXPLRC1 to 12 and EXPLRC2 to 10.        @L3A
*------------------------------------------------------------------@L3A
         CLC   XAPLLVL,DB2V8B      Check  the version of the XAPL  @L3A
         BL    XAPLVERS_OK        If V8 or later, issue IRR914I    @L3A
*----------------------------------------------------------------------
*     Set EXPLRC1 to 12 (severe error) and EXPLRC2 to 10 (NG XAPL) @L3A
*----------------------------------------------------------------------
         L     R4,SEVERE_ERROR                                     @L3A
         STH   R4,EXPLRC1            SAVE RETURN CODE IN EXPL      @L3A
         L     R4,XAPL_INVALID                                     @L3A
         ST    R4,EXPLRC2            SAVE REASON CODE IN EXPL      @L3A
*----------------------------------------------------------------------
*     Setup to issue error message IRR914I                         @L3A
*----------------------------------------------------------------------
         SLR   R0,R0                 ZERO OUT REG BEFORE WTO       @L3A
         L     R5,IRR914I_PTR                                      @L3A
         MVC   M914(L'M914),0(R5)                                  @L3A
         MVC   M914_XAPLLVL,XAPLLVL       Insert XAPLLVL           @L3A
         WTO   MF=(E,M914)                ISSUE MESSAGE            @L3A
         B     ENDINIT                                             @L3A
DB2V8B   DC    CL8'V8R1M0'         Located here to ensure          @L3A
*                                  addressability                  @L3A
XAPLVERS_OK    EQU  *                                              @L3A
*----------------------------------------------------------------------
*     XAPL version OK, continue processing                         @L3A
*----------------------------------------------------------------------
*----------------------------------------------------------------------
*     Check if RACF is active
*----------------------------------------------------------------------
         MVC   RACSTATD(RSTATLEN),RACSTATS
         RACROUTE REQUEST=STAT,                                        X
               WORKA=SAFWORK,                                          X
               REQSTOR=MODNAME,                                        X
               SUBSYS=XAPLGPAT,                                        X
               DECOUPL=YES,                                            X
               RELEASE=2.4,                                            X
               MF=(E,RACSTATD)     CHECK IF RACF IS ACTIVE
         LTR   R15,R15
         BNZ   NOTACTIV            RACF INACTIVE
*----------------------------------------------------------------------
*     Initialize variables in preparation for looping through the
*     object table. Within this loop, a classname is build based
*     on the two character abbreviation for that object. Once the
*     classname is built, then the class is RACLISTed. A count is
*     kept for every class that is found inactive.
*----------------------------------------------------------------------
         SLR   R4,R4
         STH   R4,INACT_CLASSCTR   INIT INACT/UNDEFINED COUNTER    @05C
         L     R5,OBJECT_TABLE_PTR GET ADDRESS OF OBJECT TABLE
         USING OBJTABHD,R5
         LH    R6,OBJNUM           RETRIEVE NUMBER OF OBJECTS IN TABLE
         LA    ENTRY_TABLE,OBJHDLEN(R5)   GET ADDRESS OF FIRST ENTRY
         DROP  R5
         SLR   OBJ_INDEX,OBJ_INDEX INITIALIZE INDEX INTO TABLE TO ZERO
LOOPSTRT DS    0H                  LOOP THROUGH EACH ENTRY IN TABLE
         LA    R7,0(OBJ_INDEX,ENTRY_TABLE) GET ADDRESS OF CURRENT ENTRY
         USING OBJENTRY,R7
         BLD_CLASS CLASSABBR=OBJABBRV,                                 X
               CLASSNAME=CLASSNAME,                                    X
               SAVE=BLD_CLASS_SAVEAREA   BUILD CLASSNAME FOR OBJECT
         BAL   R14,RACREATE        RACLIST THE OBJECT
         LTR   R15,R15             CHECK FOR ZERO RETURN CODE
         BNZ   CLEANUP             EXIT LOOP WHEN NON-ZERO RETURN CODE
         LA    OBJ_INDEX,OBJENTLN(OBJ_INDEX) INCREMENT INDEX INTO TABLE
LOOPEND  BCT   R6,LOOPSTRT         GET NEXT OBJECT IN TABLE OR DONE
         DROP  R7
*----------------------------------------------------------------------
*     If all is well so far, the administrative authority classname
*     is built and RACLISTed.
*----------------------------------------------------------------------
         BLD_CLASS CLASSABBR=ADM_CLASS,                                X
               CLASSNAME=CLASSNAME,                                    X
               SAVE=BLD_CLASS_SAVEAREA  BUILD CLASSNAME FOR ADMIN CLASS
         BAL   R14,RACREATE        RACLIST THE ADMIN CLASS
         LTR   R15,R15             CHECK FOR ZERO RETURN CODE
         BNZ   CLEANUP             BRANCH IF RACLIST FAILS
*----------------------------------------------------------------------
*     Check if all the classes for the DB2 objects were inactive
*----------------------------------------------------------------------
         L     R5,OBJECT_TABLE_PTR GET POINTER TO OBJECT TABLE
         USING OBJTABHD,R5
         LH    R6,OBJNUM           GET NUMBER OF OBJECTS IN TABLE
         AH    R6,ONE              ADD ONE FOR THE ADMIN CLASS
         CH    R6,INACT_CLASSCTR   WERE ALL CLASSES INACTIVE       @05C
         BNE   BLDCPOOL            NO, AT LEAST ONE CLASS WAS ACTIVE
         DROP  R5
         L     R7,SEVERE_ERROR
         STH   R7,EXPLRC1          SAVE RETURN CODE IN EXPL
         L     R7,ALL_CLASSES_INACTIVE
         ST    R7,EXPLRC2          SAVE REASON CODE IN EXPL
*----------------------------------------------------------------------
*     Setup to issue error message IRR901A
*----------------------------------------------------------------------
         SLR   R0,R0               ZERO OUT REG BEFORE ISSUING WTO
         L     R4,IRR901A_PTR
         MVC   M901(L'M901),0(R4)
         MVC   M901_SUBSYSTEM,XAPLGPAT   GET GROUP/SUBSYSTEM NAME
         WTO   MF=(E,M901)         ISSUE MESSAGE
         B     CLEANUP                                             @09A
*----------------------------------------------------------------------
*     Create a Cell Pool to be used as a re-entrant workarea for
*     IRR@XACS.
*     - The value specified for CSIZE must be large enough to
*       accomodate the size of IRR@XACS dynamic storage.
*----------------------------------------------------------------------
BLDCPOOL DS    0H
         L     R5,EXPLWA         Get address of EXPL work area
         USING WA_MAP,R5         Setup addressability to work area
         L     R4,WA_CSIZE       Size of cell to obtain (from DSNX@XAC)
         MVC   CPOOLD(CPOOLLEN),CPOOLS  Copy static to dynamic
         CPOOL BUILD,                                                  X
               PCELLCT=&PCELLCT, Primary cell count                    X
               SCELLCT=&SCELLCT, Secondary cell count                  X
               CSIZE=(R4),       Cell size                             X
               SP=229,           Subpool                               X
               LOC=ANY,                                                X
               HDR=CPOOLHDR,     hdr for initial and secondary extents X
               MF=(E,CPOOLD)
         ST    R0,WA_CPID        Save cell pool id in work area
*----------------------------------------------------------------------
*     Bypass code to build a default ACEE.  A default ACEE is only
*     effective when it provides the ability to perform authority
*     checking for un-authenticated users.  However, at this point
*     in time there are situations in which there is not an ACEE for
*     users that have already been authenticated.  When this occurs
*     RACF/DB2 External Security Module will not use a default ACEE
*     and will defere authority checking to DB2.
*------------------------------------------------------------------@03C
         AGO   .BYPASS_BLDACEE                                     @03A
BLDACEE  MVC   RACVERFD(RVERFLEN),RACVERFS
         RACROUTE REQUEST=VERIFY,                                      X
               ENVIR=CREATE,                                           X
               ACEE=WA_DFTACEE,                                        X
               WORKA=SAFWORK,                                          X
               REQSTOR=MODNAME,                                        X
               SUBSYS=XAPLGPAT,                                        X
               DECOUPL=YES,                                            X
               RELEASE=2.4,                                            X
               MF=(E,RACVERFD)   BUILD DEFAULT ACEE FOR AUTH CHECKING
         LTR   R15,R15           CHECK RETURN CODE
         BZ    ENDINIT           ACEE CREATE SUCCESSFUL - BRANCH TO END
         DROP  R5                Drop EXPL work area base register
*----------------------------------------------------------------------
*     Error path for building of ACEE failure
*----------------------------------------------------------------------
BLDFAIL  DS    0H
         SLR   R4,R4
         STH   R4,EXPLRC1            SET RETURN CODE IN EXPL TO ZERO
         L     R5,ACEE_BUILD_FAILED
         ST    R5,EXPLRC2            SAVE REASON CODE IN EXPL
*----------------------------------------------------------------------
*     Setup to issue error message IRR904I
*----------------------------------------------------------------------
         SLR   R0,R0               ZERO OUT REG BEFORE ISSUING WTO
         L     R4,IRR904I_PTR
         MVC   M904(L'M904),0(R4)
         MVC   M904_SUBSYSTEM,XAPLGPAT   GET GROUP/SUBSYSTEM NAME
         STCM  R15,7,PACKAREA      STORE LAST 3 BYTES OF RETURN CODE
         UNPK  UNPACKAREA,PACKAREA
         MVC   M904_RACROUTE_RC(L'M904_RACROUTE_RC),UNPACKAREA+3
         NC    M904_RACROUTE_RC,ZONECHARS  CLEAR ZONES
         TR    M904_RACROUTE_RC,TRTABLE    TRANSLATE RETURN CODE
         LA    R5,RACVERFD         SETUP REG TO RACROUTE PARMLIST
         USING SAFP,R5
         L     R6,SAFPRRET         LOAD REG WITH RACF RETURN CODE
         STCM  R6,7,PACKAREA       STORE LAST 3 BYTES OF RETURN CODE
         UNPK  UNPACKAREA,PACKAREA
         MVC   M904_RACF_RETCODE(L'M904_RACF_RETCODE),UNPACKAREA+3
         NC    M904_RACF_RETCODE,ZONECHARS  CLEAR ZONES
         TR    M904_RACF_RETCODE,TRTABLE    TRANSLATE RETURN CODE
         L     R7,SAFPRREA         LOAD REG WITH RACF REASON CODE
         STCM  R7,7,PACKAREA       STORE LAST 3 BYTES OF REASON CODE
         UNPK  UNPACKAREA,PACKAREA
         MVC   M904_RACF_REACODE(L'M904_RACF_REACODE),UNPACKAREA+3
         NC    M904_RACF_REACODE,ZONECHARS  CLEAR ZONES
         TR    M904_RACF_REACODE,TRTABLE    TRANSLATE RETURN CODE
         WTO   MF=(E,M904)         ISSUE MESSAGE
         DROP  R5
.BYPASS_BLDACEE ANOP                                               @03A
         B     CLEANUP
*----------------------------------------------------------------------
*     Error path for RACF not active
*----------------------------------------------------------------------
NOTACTIV DS    0H
         L     R4,SEVERE_ERROR
         STH   R4,EXPLRC1            SAVE RETURN CODE IN EXPL
         L     R4,RACF_NOT_ACTIVE
         ST    R4,EXPLRC2            SAVE REASON CODE IN EXPL
*----------------------------------------------------------------------
*     Setup to issue error message IRR903A
*----------------------------------------------------------------------
         SLR   R0,R0                 ZERO OUT REG BEFORE ISSUING WTO
         L     R5,IRR903A_PTR
         MVC   M903(L'M903),0(R5)
         MVC   M903_SUBSYSTEM,XAPLGPAT   GET GROUP/SUBSYSTEM NAME
         WTO   MF=(E,M903)               ISSUE MESSAGE
*----------------------------------------------------------------------
*     If there was an error during initialization, the termination
*     routine will be called to do cleanup. Any profiles that were
*     RACLISTed during this pass will be un-RACLISTed, and if an
*     acee was created, it will be deleted. The return and reason
*     codes will be saved prior to clean up and restored to the
*     original contents upon return.
*----------------------------------------------------------------------
CLEANUP  DS    0H
         LH    R5,EXPLRC1
         LTR   R5,R5          CHECK FOR NON-ZERO RETURN CODE IN EXPL
         BZ    ENDINIT        RETURN CODE ZERO, AVOID CLEANUP
         ST    R5,SAVE_EXPLRC1       SAVE EXPL RETURN CODE
         L     R6,EXPLRC2
         ST    R6,SAVE_EXPLRC2       SAVE EXPL REASON CODE
         BAL   R14,TERMRTN    CALL TERMINATE ROUTINE TO DO CLEANUP
         L     R5,SAVE_EXPLRC1
         STH   R5,EXPLRC1            RESTORE EXPL RETURN CODE
         L     R6,SAVE_EXPLRC2
         ST    R6,EXPLRC2            RESTORE EXPL REASON CODE
         B     ENDINIT
*----------------------------------------------------------------------
*     Error path for ACEE not valid
*----------------------------------------------------------------------
BADACEE  DS    0H
         L     R4,SEVERE_ERROR
         STH   R4,EXPLRC1            SAVE RETURN CODE IN EXPL
         L     R4,ACEE_INVALID
         ST    R4,EXPLRC2            SAVE REASON CODE IN EXPL
*----------------------------------------------------------------------
*     Setup to issue error message IRR902A
*----------------------------------------------------------------------
         SLR   R0,R0                 ZERO OUT REG BEFORE ISSUING WTO
         L     R5,IRR902A_PTR
         MVC   M902(L'M902),0(R5)
         MVC   M902_SUBSYSTEM,XAPLGPAT    GET GROUP/SUBSYSTEM NAME
         MVC   M902_ACEE_ERROR(L'NOT_VALID),NOT_VALID
         WTO   MF=(E,M902)                ISSUE MESSAGE
         B     ENDINIT
*----------------------------------------------------------------------
*     Error path for ACEE does not exist
*----------------------------------------------------------------------
NO$ACEE  DS    0H
         L     R4,SEVERE_ERROR
         STH   R4,EXPLRC1            SAVE RETURN CODE IN EXPL
         L     R4,ACEE_MISSING
         ST    R4,EXPLRC2            SAVE REASON CODE IN EXPL
*----------------------------------------------------------------------
*     Setup to issue error message IRR902A
*----------------------------------------------------------------------
         SLR   R0,R0                 ZERO OUT REG BEFORE ISSUING WTO
         L     R5,IRR902A_PTR
         MVC   M902(L'M902),0(R5)
         MVC   M902_SUBSYSTEM,XAPLGPAT   GET GROUP/SUBSYSTEM NAME
         MVC   M902_ACEE_ERROR(L'MISSING),MISSING
         WTO   MF=(E,M902)               ISSUE MESSAGE
*----------------------------------------------------------------------
*     Return to caller
*     - Issue either IRR912I ("Native DB2...") or                  @09A
*       IR913I ("DB2 Subsystem termination...') depending on the   @09A
*       setting of the TERM_DB2_OPT flag.                          @09A
*     - Issue messages IRR908I, IRR909I, IRR910I and IRR911I       @09A
*----------------------------------------------------------------------
ENDINIT  DS    0H
*----------------------------------------------------------------------
*     Setup to issue message indicating if DB2 is being terminated @09A
*     or if native DB2 authorization is being used.                @09A
*----------------------------------------------------------------------
         TM    XAC1_FLAGS,TERM_DB2_OPT Terminate DB2 subsystem?    @09A
         BZ    LEAVE_EXPLRC2_ALONE No? don't reset EXPLRC2         @09A
         L     R4,TERM_DB2_EXPLRC2     x'10' to tell DB2 to term   @09A
         ST    R4,EXPLRC2              if there is an error        @09A
*
LEAVE_EXPLRC2_ALONE EQU *
         LH    R0,EXPLRC1          Is the return code 0?           @09A
         LTR   R0,R0               If it is, then don't issue      @09A
*                                  IRR912I or IRR913I              @09A
         BZ    ISSUE_INFO_MESSAGES Issue the informational msgs    @09A
         TM    XAC1_FLAGS,TERM_DB2_OPT Terminate DB2 subsystem?    @09A
         BZ    NATIVE_DB2_MSG      No? issue IRR912I               @09A
TERM_DB2_MSG   EQU *                                               @09A
         LH    R0,EXPLRC1          Is the return code 0?           @09A
         LTR   R0,R0               If it is, then don't issue      @09A
         BZ    ISSUE_INFO_MESSAGES IRR912I or IRR913I              @09A
         SLR   R0,R0               ZERO OUT REG BEFORE ISSUING WTO @09A
         L     R4,IRR913I_PTR                                      @09A
         MVC   M913(L'M913),0(R4)                                  @09A
         WTO   MF=(E,M913)         ISSUE MESSAGE                   @09A
         B     ISSUE_INFO_MESSAGES                                 @09A
NATIVE_DB2_MSG EQU *                                               @09A
         SLR   R0,R0               ZERO OUT REG BEFORE ISSUING WTO @09A
         L     R4,IRR912I_PTR                                      @09A
         MVC   M912(L'M912),0(R4)                                  @09A
         WTO   MF=(E,M912)         ISSUE MESSAGE                   @09A
ISSUE_INFO_MESSAGES EQU *                                          @09A
         BAL   R14,INFOMSGS            Issue informational messages
         LM    R14,R12,INIT_SAVEAREA   RESTORE CALLERS REGISTERS
         BR    R14             RETURN TO CALLER
         EJECT
*----------------------------------------------------------------------
*
*        RACLIST CREATE ROUTINE
*
*  Initialize raclist return code
*  Issue RACROUTE REQUEST=LIST,GLOBAL=YES,ENVIR=CREATE,
*    to raclist the requested class
*  If SAF return code is non-zero
*    If SAF return code is 4 and RACF return code is either 8 or 10
*      Class is inactive or not defined, increment counter
*    Else
*      Do;
*        Set raclist return code to 12
*        Set EXPLRC1 to 12 and EXPLRC2 to 3
*        Issue message IRR900A
*      End;
*  Return to caller
*
*----------------------------------------------------------------------
*
RACREATE DS    0H
         STM   R14,R12,RACLIST_SAVEAREA
*----------------------------------------------------------------------
*        Save class name for IRR910I message
*----------------------------------------------------------------------
         L     R4,USING_CURRENT           Get current USING_ARRAY entry
         MVC   0(L'USING_ENTRY,R4),CLASSNAME Store class name
         LA    R4,L'USING_ENTRY(R4)       Bump current to next entry
         ST    R4,USING_CURRENT           Save current entry address
*
         SLR   R4,R4
         ST    R4,RACLIST_RC   INITIALIZE RACLIST RETURN CODE
         MVC   RACLISTD(RSTATLEN),RACLISTS
         L     R5,XAPLACEE
         RACROUTE REQUEST=LIST,                                        X
               GLOBAL=YES,                                             X
               ENVIR=CREATE,                                           X
               ACEE=(R5),                                              X
               CLASS=CLASSNAME,                                        X
               WORKA=SAFWORK,                                          X
               REQSTOR=MODNAME,                                        X
               SUBSYS=XAPLGPAT,                                        X
               DECOUPL=YES,                                            X
               RELEASE=2.4,                                            X
               MF=(E,RACLISTD) RACLIST THE REQUESTED CLASS
         LTR   R15,R15         CHECK RETURN CODE
         BNZ   CHKNZERO        NOT ZERO - CHECK RESULTS...
*----------------------------------------------------------------------
*     Return Code Zero - Save class name for IRR911I message
*----------------------------------------------------------------------
         L     R4,RACL_CURRENT            Get current RACL_ARRAY entry
         MVC   0(L'RACL_ENTRY,R4),CLASSNAME  Store class name
         LA    R4,L'RACL_ENTRY(R4)        Bump current to next entry
         ST    R4,RACL_CURRENT            Save current entry address
         B     ENDCREAT        RACLIST SUCCESSFUL - BRANCH TO END
*
*----------------------------------------------------------------------
*     Check if SAF and RACF return codes indicate class was
*     inactive. If so, increment the counter for inactive
*     classes.
*----------------------------------------------------------------------
CHKNZERO DS    0H
         LA    R4,RACLISTD     SETUP REG TO POINT TO RACLIST PARAMETERS
         USING SAFP,R4
         C     R15,FOUR        CHECK FOR RC OF 4 - COMMAND NOT EXECUTED
         BNE   CREATERR
         L     R5,SAFPRRET     LOAD REGISTER WITH RACF RETURN CODE
         C     R5,INACTIVE_RCODE   WAS THE CLASS INACTIVE?
         BE    NACTNDEF
         C     R5,NOTDEFINED_RCODE  WAS THE CLASS NOT DEFINED?
         BNE   CREATERR            NO, BRANCH TO ERROR PATH
NACTNDEF DS    0H
         LH    R6,INACT_CLASSCTR   LOAD REG WITH INACTIVE COUNT    @05C
         AH    R6,ONE              INCREMENT THE COUNTER
         STH   R6,INACT_CLASSCTR   SAVE UPDATED COUNTER            @05C
         B     ENDCREAT
*----------------------------------------------------------------------
*     Error path for raclist create failures
*----------------------------------------------------------------------
CREATERR DS    0H
         L     R7,SEVERE_ERROR
         ST    R7,RACLIST_RC         SET RETURN CODE TO SEVERE ERROR
         STH   R7,EXPLRC1            SAVE RETURN CODE IN EXPL
         L     R7,RACLIST_CREATE_FAILED
         ST    R7,EXPLRC2            SAVE REASON CODE IN EXPL
*----------------------------------------------------------------------
*     Setup to issue error message IRR900A
*----------------------------------------------------------------------
         SLR   R0,R0                 ZERO OUT REG BEFORE ISSUING WTO
         L     R5,IRR900A_PTR
         MVC   M900(L'M900),0(R5)    Copy the message text         @09C
*                                                                  @09D
         MVC   M900_SUBSYSTEM,XAPLGPAT   GET GROUP/SUBSYSTEM NAME
         MVC   M900_CLASSNAME,CLASSNAME  GET CLASSNAME TO RACLIST
         STCM  R15,7,PACKAREA      STORE LAST 3 BYTES OF RETURN CODE
         UNPK  UNPACKAREA,PACKAREA
         MVC   M900_RACROUTE_RC(L'M900_RACROUTE_RC),UNPACKAREA+3
         NC    M900_RACROUTE_RC,ZONECHARS  CLEAR ZONES
         TR    M900_RACROUTE_RC,TRTABLE    TRANSLATE RETURN CODE
         L     R6,SAFPRRET         LOAD REG WITH RACF RETURN CODE
         STCM  R6,7,PACKAREA       STORE LAST 3 BYTES OF RETURN CODE
         UNPK  UNPACKAREA,PACKAREA
         MVC   M900_RACF_RETCODE(L'M900_RACF_RETCODE),UNPACKAREA+3
         NC    M900_RACF_RETCODE,ZONECHARS  CLEAR ZONES
         TR    M900_RACF_RETCODE,TRTABLE    TRANSLATE RETURN CODE
         L     R7,SAFPRREA         LOAD REG WITH RACF REASON CODE
         STCM  R7,7,PACKAREA       STORE LAST 3 BYTES OF REASON CODE
         UNPK  UNPACKAREA,PACKAREA
         MVC   M900_RACF_REACODE(L'M900_RACF_REACODE),UNPACKAREA+3
         NC    M900_RACF_REACODE,ZONECHARS  CLEAR ZONES
         TR    M900_RACF_REACODE,TRTABLE    TRANSLATE RETURN CODE
         WTO   MF=(E,M900)         ISSUE MESSAGE
         DROP  R4
*----------------------------------------------------------------------
*     Return to caller
*----------------------------------------------------------------------
ENDCREAT DS    0H
         L     R15,RACLIST_RC   LOAD REGISTER WITH RACLIST RETURN CODE
         L     R14,RACLIST_SAVEAREA
         LM    R0,R12,RACLIST_SAVEAREA+8  RESTORE CALLERS REGISTERS
         BR    R14              RETURN TO CALLER
         EJECT
*----------------------------------------------------------------------
*
*        INFOMSGS ROUTINE - Issue informational messages
*
*  Issue information messages
*   - IRR908I - Module version and length
*   - IRR909I - Module options (value of SETC symbols)
*   - IRR910I - Classes being used
*   - IRR911I - Classes successfully RACLISTed
*  Return to caller
*
*----------------------------------------------------------------------
*
INFOMSGS DS    0H
         STM   R14,R12,INFO_SAVEAREA
*----------------------------------------------------------------------
*  Issue message IRR908I
*----------------------------------------------------------------------
         SLR   R0,R0                     Clear R0 for WTO macro
         L     R4,IRR908I_PTR            Get addr of static list macro
         MVC   M908(L'M908),0(R4)        Copy static to dynamic
         MVC   M908_SUBSYSTEM,XAPLGPAT   Move in DB2 subsystem name
         MVC   M908_MOD_VERS,MODVERS     Move in module version
         L     R5,XACS_TOTAL_LEN1        Get length of all CSECTs
         STCM  R5,15,PACK8
         UNPK  UNPACK10,PACK8(5)         Convert length to zoned format
         MVC   M908_MOD_LEN,UNPACK10+1   Put module length in message
         NC    M908_MOD_LEN,ZONECHAR8    Clear zones
         TR    M908_MOD_LEN,TRTABLE      Convert code to EBCIDIC values
         WTO   MF=(E,M908)               Issue the message
*
*----------------------------------------------------------------------
*  Issue message IRR909I
*----------------------------------------------------------------------
         SLR   R0,R0                     Clear R0 for WTO macro
         L     R4,IRR909I_PTR            Get addr of static list macro
         MVC   M909(256),0(R4)              Copy first 256 bytes
         MVC   M909+256(L'M909-256),256(R4) Copy remainder
         MVC   M909_SUBSYSTEM,XAPLGPAT   Move in DB2 subsystem name
         WTO   MF=(E,M909)               Issue the message
*
*----------------------------------------------------------------------
*  Issue message IRR910I
*----------------------------------------------------------------------
         SLR   R0,R0                     Clear R0 for WTO macro
         L     R4,IRR910I_PTR            Get addr of static list macro
         L     R5,LEN_M910I              Get length of parm list   @L1A
         LA    R6,M910                   Get address of dynamic
*                                        WTO parm list             @L1A
         L     R7,LEN_M910I              Get length of parm list   @L1A
         MVCL  R6,R4                     Copy the static area (R4)
*                                        to the dynamic            @L1C
         MVC   M910_SUBSYSTEM,XAPLGPAT   Move in DB2 subsystem name
*
         LA    R4,M910_CLASS1            Addr of 1st class in msg
         LA    R5,USING_ARRAY            Get address source array
         LA    R6,3                      Number of message lines   @L1C
         LA    R7,5                      Number of classes per line
M910LOOP DS    0H
         MVC   0(8,R4),0(R5)             Move in class name
         LA    R5,L'USING_ENTRY(R5)      Point to next source element
         LA    R4,L'M910_CLASS1(R4)      Point to next message element
         BCT   R7,M910LOOP               Were 5 names added to line?
         LA    R4,13(R4)                 Skip WTO stuff
         LA    R7,5                      Reset # of classes per line
         BCT   R6,M910LOOP               Were 3 lines processed?
*
         WTO   MF=(E,M910)               Issue the message
*
*----------------------------------------------------------------------
*  Issue message IRR911I
*----------------------------------------------------------------------
         SLR   R0,R0                     Clear R0 for WTO macro
         L     R4,IRR911I_PTR            Get addr of static list macro
         L     R5,LEN_M911I              Get length of parm list   @L1A
         LA    R6,M911                   Get address of dynamic    @L1A
*                                        WTO parm list             @L1A
         L     R7,LEN_M911I              Get length of parm list   @L1A
         MVCL  R6,R4                     Copy the static area (R4) @L1A
         MVC   M911_SUBSYSTEM,XAPLGPAT   Move in DB2 subsystem name
*
         LA    R4,M911_CLASS1            Addr of 1st class in msg
         LA    R5,RACL_ARRAY             Get address source array
         LA    R6,3                      Number of message lines   @L1C
         LA    R7,5                      Number of classes per line
M911LOOP DS    0H
         MVC   0(8,R4),0(R5)             Move in class name
         LA    R5,L'RACL_ENTRY(R5)       Point to next source element
         LA    R4,L'M911_CLASS1(R4)      Point to next message element
         BCT   R7,M911LOOP               Were 5 names added to line?
         LA    R4,13(R4)                 Skip WTO stuff
         LA    R7,5                      Reset # of classes per line
         BCT   R6,M911LOOP               Were 3 lines processed?
*
         WTO   MF=(E,M911)               Issue the message
*
         LM    R14,R12,INFO_SAVEAREA     Restore callers registers
         BR    R14                       Return to caller
         EJECT
*----------------------------------------------------------------------
*
*        TERMINATION ROUTINE
*
*  If XAPLACEE is non-zero then
*    If XAPLACEE-> ACEEACEE = 'ACEE' then
*      Do;
*        Loop through each object in object table
*          Retrieve two character abbreviation for object
*          Invoke BLD_CLASS macro to build classname passing
*            it the two character abbreviation, classname field to
*            be filled in and a savearea.
*          Call raclist delete routine to delete raclisted profiles
*        Endloop
*        Invoke BLD_CLASS macro to build administrative authority
*          classname passing it 'ADM' for the class abbreviation,
*          classname field to be filled in and a savearea.
*        Call raclist delete routine to delete the raclisted profiles
*          for the adminstrative class
*        Delete Cell Pool used for authorization requests
*        If a default acee exists
*          Do;
*            Issue RACROUTE REQUEST=VERIFY,ENVIR=DELETE,
*               ACEE=WA_DFTACEE, to delete the acee
*            If return code is non-zero
*              Do;
*                If both EXPLRC1 and EXPLRC2 are zero
*                  Set EXPLRC1 to 8 and EXPLRC2 to 9
*                Issue message IRR906I
*              End;
*          End;
*      End;
*    Else ACEE not valid
*      Do;
*        Set EXPLRC1 to 8 and EXPLRC2 to 12
*        Issue message IRR907I
*      End;
*  Else ACEE not provided
*    Do;
*      Set EXPLRC1 to 8 and EXPLRC2 to 1
*      Issue message IRR907I
*    End;
*
*----------------------------------------------------------------------
*
TERMRTN  DS    0H
         STM   R14,R12,TERM_SAVEAREA
*----------------------------------------------------------------------
*     Check if valid ACEE exists
*----------------------------------------------------------------------
         L     R4,XAPLACEE         GET ACEE ADDRESS
         LTR   R4,R4               CHECK IF POINTER IS NON-ZERO
         BZ    NO_ACEE             ACEE DOES NOT EXIST
         USING ACEE,R4
         CLC   ACEEACEE,ACEE_EYECATCHER   CHECK FOR EYECATCHER
         BNE   BAD_ACEE            ACEE IS NOT VALID
         DROP  R4
*----------------------------------------------------------------------
*     Initialize variables in preparation for looping through the
*     object table. Within this loop, a classname is build based
*     on the two character abbreviation for that object. The
*     profiles for that class are un-RACLISTed.
*----------------------------------------------------------------------
         L     R5,OBJECT_TABLE_PTR  GET ADDRESS OF OBJECT TABLE
         USING OBJTABHD,R5
         LH    R6,OBJNUM           RETRIEVE NUMBER OF OBJECTS IN TABLE
         LA    ENTRY_TABLE,OBJHDLEN(R5)  GET ADDRESS OF FIRST ENTRY
         DROP  R5
         SLR   OBJ_INDEX,OBJ_INDEX INITIALIZE INDEX INTO TABLE TO ZERO
LOOP     DS    0H                  LOOP THROUGH EACH ENTRY IN TABLE
         LA    R7,0(OBJ_INDEX,ENTRY_TABLE) GET ADDRESS OF CURRENT ENTRY
         USING OBJENTRY,R7
         BLD_CLASS CLASSABBR=OBJABBRV,                                 X
               CLASSNAME=CLASSNAME,                                    X
               SAVE=BLD_CLASS_SAVEAREA  BUILD CLASSNAME FOR OBJECT
         BAL   R14,RACDELET        DELETE RACLISTED PROFILES FOR OBJECT
         LA    OBJ_INDEX,OBJENTLN(OBJ_INDEX) INCREMENT INDEX INTO TABLE
ENDLOOP  BCT   R6,LOOP             GET NEXT OBJECT IN TABLE OR DONE
         DROP  R7
*----------------------------------------------------------------------
*     Build the administrative authority classname and un-RACLIST
*     the profiles for that class.
*----------------------------------------------------------------------
         BLD_CLASS CLASSABBR=ADM_CLASS,                                X
               CLASSNAME=CLASSNAME,                                    X
               SAVE=BLD_CLASS_SAVEAREA  BUILD CLASSNAME FOR ADMIN CLASS
         BAL   R14,RACDELET        DELETE PROFILES FOR ADMIN CLASS
*----------------------------------------------------------------------
*     Delete the Cell Pool
*----------------------------------------------------------------------
         L     R5,EXPLWA           Get address of EXPL work area
         USING WA_MAP,R5           Setup adressability to work area
         L     R4,WA_CPID          Get Cell Pool ID
         LTR   R4,R4               See if Cell Pool was created
         BZ    DELACEE             If not created, skip DELETE
         CPOOL DELETE,CPID=(R4)
*
*----------------------------------------------------------------------
*     Delete the default acee if it exists
*----------------------------------------------------------------------
DELACEE  DS    0H
         L     R4,WA_DFTACEE
         LTR   R4,R4               DOES DEFAULT ACEE EXIST?
         BZ    ENDTERM             NO, BRANCH TO END
         MVC   RACVERFD(RVERFLEN),RACVERFS
         RACROUTE REQUEST=VERIFY,                                      X
               ENVIR=DELETE,                                           X
               ACEE=WA_DFTACEE,                                        X
               WORKA=SAFWORK,                                          X
               REQSTOR=MODNAME,                                        X
               SUBSYS=XAPLGPAT,                                        X
               DECOUPL=YES,                                            X
               RELEASE=2.4,                                            X
               MF=(E,RACVERFD)     DELETE DEFAULT ACEE
         LTR   R15,R15             CHECK FOR ZERO RETURN CODE
         BZ    ENDTERM             DELETE WAS SUCCESSFUL - BRANCH
         DROP  R5                  Drop work area base register
*----------------------------------------------------------------------
*     Error path for deleting acee failure
*----------------------------------------------------------------------
         SLR   R4,R4
         LH    R5,EXPLRC1
         LTR   R4,R5               CHECK FOR NON-ZERO RETURN CODE
         BNZ   DELETMSG            PREVIOUS ERROR OCCURRED, BRANCH
         L     R5,EXPLRC2
         LTR   R4,R5               CHECK FOR NON-ZERO REASON CODE
         BNZ   DELETMSG            PREVIOUS ERROR OCCURRED, BRANCH
         L     R6,WARNING
         STH   R6,EXPLRC1          SAVE RETURN CODE IN EXPL
         L     R6,DELETE_ACEE_FAILED
         ST    R6,EXPLRC2          SAVE REASON CODE IN EXPL
*----------------------------------------------------------------------
*     Setup to issue error message IRR906I
*----------------------------------------------------------------------
DELETMSG SLR   R0,R0               ZERO OUT REG BEFORE ISSUING WTO
         L     R4,IRR906I_PTR
         MVC   M906(256),0(R4)     MOVE FIRST 256 BYTES OF MESSAGE @01C
         MVC   M906+256(L'M906-256),256(R4)  MOVE REST OF MESSAGE  @01A
         MVC   M906_SUBSYSTEM,XAPLGPAT   GET GROUP/SUBSYSTEM NAME
         STCM  R15,7,PACKAREA      STORE LAST 3 BYTES OF RETURN CODE
         UNPK  UNPACKAREA,PACKAREA
         MVC   M906_RACROUTE_RC(L'M906_RACROUTE_RC),UNPACKAREA+3
         NC    M906_RACROUTE_RC,ZONECHARS  CLEAR ZONES
         TR    M906_RACROUTE_RC,TRTABLE    TRANSLATE RETURN CODE
         LA    R5,RACVERFD         SETUP REG TO RACROUTE PARMLIST
         USING SAFP,R5
         L     R6,SAFPRRET         LOAD REG WITH RACF RETURN CODE
         STCM  R6,7,PACKAREA       STORE LAST 3 BYTES OF RETURN CODE
         UNPK  UNPACKAREA,PACKAREA
         MVC   M906_RACF_RETCODE(L'M906_RACF_RETCODE),UNPACKAREA+3
         NC    M906_RACF_RETCODE,ZONECHARS  CLEAR ZONES
         TR    M906_RACF_RETCODE,TRTABLE    TRANSLATE RETURN CODE
         L     R7,SAFPRREA         LOAD REG WITH RACF REASON CODE
         STCM  R7,7,PACKAREA       STORE LAST 3 BYTES OF REASON CODE
         UNPK  UNPACKAREA,PACKAREA
         MVC   M906_RACF_REACODE(L'M906_RACF_REACODE),UNPACKAREA+3
         NC    M906_RACF_REACODE,ZONECHARS  CLEAR ZONES
         TR    M906_RACF_REACODE,TRTABLE    TRANSLATE RETURN CODE
         WTO   MF=(E,M906)         ISSUE MESSAGE
         DROP  R5
         B     ENDTERM
*----------------------------------------------------------------------
*     Error path for ACEE not valid
*----------------------------------------------------------------------
BAD_ACEE DS    0H
         L     R4,WARNING
         STH   R4,EXPLRC1          SAVE RETURN CODE IN EXPL
         L     R4,ACEE_INVALID
         ST    R4,EXPLRC2          SAVE REASON CODE IN EXPL
*----------------------------------------------------------------------
*     Setup to issue error message IRR907I
*----------------------------------------------------------------------
         SLR   R0,R0               ZERO OUT REG BEFORE ISSUING WTO
         L     R5,IRR907I_PTR
         MVC   M907(L'M907),0(R5)
         MVC   M907_SUBSYSTEM,XAPLGPAT    GET GROUP/SUBSYSTEM NAME
         MVC   M907_ACEE_ERROR(L'NOT_VALID),NOT_VALID
         WTO   MF=(E,M907)                ISSUE MESSAGE
         B     ENDTERM
*----------------------------------------------------------------------
*     Error path for ACEE does not exist
*----------------------------------------------------------------------
NO_ACEE  DS    0H
         L     R4,WARNING
         STH   R4,EXPLRC1          SAVE RETURN CODE IN EXPL
         L     R4,ACEE_MISSING
         ST    R4,EXPLRC2          SAVE REASON CODE IN EXPL
*----------------------------------------------------------------------
*     Setup to issue error message IRR907I
*----------------------------------------------------------------------
         SLR   R0,R0               ZERO OUT REG BEFORE ISSUING WTO
         L     R5,IRR907I_PTR
         MVC   M907(L'M907),0(R5)
         MVC   M907_SUBSYSTEM,XAPLGPAT   GET GROUP/SUBSYSTEM NAME
         MVC   M907_ACEE_ERROR(L'MISSING),MISSING
         WTO   MF=(E,M907)               ISSUE MESSAGE
*----------------------------------------------------------------------
*     Return to caller
*----------------------------------------------------------------------
ENDTERM  DS    0H
         LM    R14,R12,TERM_SAVEAREA   RESTORE CALLERS REGISTERS
         BR    R14             RETURN TO CALLER
         EJECT
*----------------------------------------------------------------------
*
*        RACLIST DELETE ROUTINE
*
*  Issue RACROUTE REQUEST=LIST,GLOBAL=YES,ENVIR=DELETE,
*    to delete the raclisted profiles for the requested class
*  If SAF return code is non-zero
*    If SAF return code is 4 and RACF return code is 10
*      Do nothing, class is inactive
*    Else
*      Do;
*        Set EXPLRC1 to 8 and EXPLRC2 to 7
*        Issue message IRR905I
*      End;
*  Return to caller
*
*----------------------------------------------------------------------
*
RACDELET DS    0H
         STM   R14,R12,RACLIST_SAVEAREA
         MVC   RACLISTD(RLISTLEN),RACLISTS
         L     R4,XAPLACEE
         RACROUTE REQUEST=LIST,                                        X
               GLOBAL=YES,                                             X
               ENVIR=DELETE,                                           X
               ACEE=(R4),                                              X
               CLASS=CLASSNAME,                                        X
               WORKA=SAFWORK,                                          X
               REQSTOR=MODNAME,                                        X
               SUBSYS=XAPLGPAT,                                        X
               DECOUPL=YES,                                            X
               RELEASE=2.4,                                            X
               MF=(E,RACLISTD) DELETE RACLISTED PROFILES
         LTR   R15,R15         CHECK RETURN CODE
         BZ    ENDDELET        RACLIST SUCCESSFUL - BRANCH TO END
*----------------------------------------------------------------------
*     Check if SAF and RACF return codes indicate class was
*     inactive. If so, do nothing, return to caller.
*----------------------------------------------------------------------
         LA    R4,RACLISTD     SETUP REG TO POINT TO RACLIST PARAMETERS
         USING SAFP,R4
         C     R15,FOUR        CHECK FOR RC OF 4 - COMMAND NOT EXECUTED
         BNE   DELETERR
         L     R5,SAFPRRET     LOAD REGISTER WITH RACF RETURN CODE
         C     R5,INACTIVE_RCODE   WAS THE CLASS INACTIVE?
         BNE   DELETERR            NO, BRANCH TO ERROR PATH
         DROP  R4
         B     ENDDELET
*----------------------------------------------------------------------
*     Error path for raclist delete failures
*----------------------------------------------------------------------
DELETERR DS    0H
         L     R7,WARNING
         STH   R7,EXPLRC1          SAVE RETURN CODE IN EXPL
         L     R7,RACLIST_DELETE_FAILED
         ST    R7,EXPLRC2          SAVE REASON CODE IN EXPL
*----------------------------------------------------------------------
*     Setup to issue error message IRR905I
*----------------------------------------------------------------------
         SLR   R0,R0               ZERO OUT REG BEFORE ISSUING WTO
         L     R4,IRR905I_PTR
         MVC   M905(256),0(R4)     MOVE FIRST 256 BYTES OF MESSAGE @01C
         MVC   M905+256(L'M905-256),256(R4)  MOVE REST OF MESSAGE  @01A
         MVC   M905_SUBSYSTEM,XAPLGPAT   GET GROUP/SUBSYSTEM NAME
         MVC   M905_CLASSNAME,CLASSNAME
         STCM  R15,7,PACKAREA      STORE LAST 3 BYTES OF RETURN CODE
         UNPK  UNPACKAREA,PACKAREA
         MVC   M905_RACROUTE_RC(L'M905_RACROUTE_RC),UNPACKAREA+3
         NC    M905_RACROUTE_RC,ZONECHARS  CLEAR ZONES
         TR    M905_RACROUTE_RC,TRTABLE    TRANSLATE RETURN CODE
         LA    R5,RACLISTD         SETUP REG TO RACROUTE PARMLIST
         USING SAFP,R5
         L     R6,SAFPRRET         LOAD REG WITH RACF RETURN CODE
         STCM  R6,7,PACKAREA       STORE LAST 3 BYTES OF RETURN CODE
         UNPK  UNPACKAREA,PACKAREA
         MVC   M905_RACF_RETCODE(L'M905_RACF_RETCODE),UNPACKAREA+3
         NC    M905_RACF_RETCODE,ZONECHARS  CLEAR ZONES
         TR    M905_RACF_RETCODE,TRTABLE    TRANSLATE RETURN CODE
         L     R7,SAFPRREA         LOAD REG WITH RACF REASON CODE
         STCM  R7,7,PACKAREA       STORE LAST 3 BYTES OF REASON CODE
         UNPK  UNPACKAREA,PACKAREA
         MVC   M905_RACF_REACODE(L'M905_RACF_REACODE),UNPACKAREA+3
         NC    M905_RACF_REACODE,ZONECHARS  CLEAR ZONES
         TR    M905_RACF_REACODE,TRTABLE    TRANSLATE RETURN CODE
         WTO   MF=(E,M905)           ISSUE MESSAGE
         DROP  R5
*----------------------------------------------------------------------
*     Return to caller
*----------------------------------------------------------------------
ENDDELET DS    0H
         LM    R14,R12,RACLIST_SAVEAREA   RESTORE CALLERS REGISTERS
         BR    R14             RETURN TO CALLER
         EJECT
*----------------------------------------------------------------------
*        DEFINITIONS
*----------------------------------------------------------------------
*
@DATD1             DSECT
@SAVE1             DS 18F'0'
BLD_CLASS_SAVEAREA DS 18F'0'
INIT_SAVEAREA      DS 15F'0'
TERM_SAVEAREA      DS 15F'0'
RACLIST_SAVEAREA   DS 15F'0'
INFO_SAVEAREA      DS 15F'0'
                   DS 0D
PACK8              DS 0CL8
PACKAREA           DS CL4
                   DS CL4
UNPACK10           DS 0CL10
UNPACKAREA         DS CL7
                   DS CL3
SAFWORK            DS CL512
CLASSNAME          DS CL8
RACLIST_RC         DS F
SAVE_EXPLRC1       DS F
SAVE_EXPLRC2       DS F
INACT_CLASSCTR     DS H
LEN$GPAT&RTNSUFX   DS H         Actual length of XAPLGPAT string   @05A
*
XAC1_FLAGS        DS XL1                                           @09A
TERM_DB2_OPT      EQU X'01'                                        @09A
                   EJECT
*----------------------------------------------------------------------
*        MESSAGE DEFINITIONS
*----------------------------------------------------------------------
*
*----------------------------------------------------------------------
*        LAYOUT FOR IRR900A
*----------------------------------------------------------------------
M900              DS     0CL246                                    @09C
                  DS     XL4
M900_LINE1        DS     CL63                                      @01C
                  DS     XL12                                      @01C
M900_LINE2        DS     0CL67
                  DS      CL27
M900_SUBSYSTEM    DS      CL4    INSERT FOR GROUP/SUBSYSTEM NAME
                  DS      CL15
M900_CLASSNAME    DS      CL8    INSERT FOR CLASSNAME
                  DS      CL13
                  DS     XL4
M900_LINE3        DS     0CL67                                     @01C
                  DS      CL41                                     @01C
M900_RACROUTE_RC  DS      CL3    INSERT FOR RACROUTE RETURN CODE
                  DS      CL19
M900_RACF_RETCODE DS      CL3    INSERT FOR RACF RETURN CODE
                  DS      CL1
                  DS     XL4
M900_LINE4        DS     0CL25                                     @09C
                  DS      CL21                                     @01C
M900_RACF_REACODE DS      CL3    INSERT FOR RACF REASON CODE
                  DS      CL1    Space for terminating "."         @09A
*                              "NATIVE DB2 AUTHORIZATION USED"    2@09D
*                               text deleted.                      @09D
                  DS     0F      BOUNDARY ALIGNMENT
*----------------------------------------------------------------------
*        LAYOUT FOR IRR901A
*----------------------------------------------------------------------
M901              DS     0CL172                                    @09C
                  DS     XL4
M901_LINE1        DS     CL63                                      @01C
                  DS     XL12
M901_LINE2        DS     0CL69                                     @01C
                  DS      CL27                                     @01C
M901_SUBSYSTEM    DS      CL4    INSERT FOR GROUP/SUBSYSTEM NAME
                  DS      CL38                                     @01C
                  DS     XL4
M901_LINE3        DS     CL20                                      @09C
*                              "NATIVE DB2 AUTHORIZATION used"     @09D
*                               text deleted.                      @09D
                  DS     0F      BOUNDARY ALIGNMENT
*----------------------------------------------------------------------
*        LAYOUT FOR IRR902A
*----------------------------------------------------------------------
M902              DS     0CL148                                    @09C
                  DS     XL4
M902_LINE1        DS     CL63                                      @01C
                  DS     XL12
M902_LINE2        DS     0CL69                                     @01C
                  DS      CL27                                     @01C
M902_SUBSYSTEM    DS      CL4    INSERT FOR GROUP/SUBSYSTEM NAME
                  DS      CL28
M902_ACEE_ERROR   DS      CL10   INSERT FOR TYPE OF ACEE ERROR
*                              "NATIVE DB2 SECURITY USED" text    2@09D
*                               deleted                            @09D
                  DS     0F      BOUNDARY ALIGNMENT
*----------------------------------------------------------------------
*        LAYOUT FOR IRR903A
*----------------------------------------------------------------------
M903              DS     0CL139                                    @09C
                  DS     XL4
M903_LINE1        DS     CL63                                      @01C
                  DS     XL12
M903_LINE2        DS     0CL60                                     @09C
                  DS      CL27                                     @01C
M903_SUBSYSTEM    DS      CL4    INSERT FOR GROUP/SUBSYSTEM NAME
                  DS      CL29                                     @09C
*                              "NATIVE DB2 SECURITY USED" text    2@09D
*                               deleted                            @09D
                  DS     0F      BOUNDARY ALIGNMENT
*----------------------------------------------------------------------
*        LAYOUT FOR IRR904I
*----------------------------------------------------------------------
M904              DS     0CL249                                    @01C
                  DS     XL4
M904_LINE1        DS     CL59                                      @01C
                  DS     XL12
MS904LINE2        DS     0CL63                                     @01C
                  DS      CL36                                     @01C
M904_SUBSYSTEM    DS      CL4    INSERT FOR GROUP/SUBSYSTEM NAME
                  DS      CL23                                     @01C
                  DS     XL4
M904_LINE3        DS     0CL68                                     @01C
                  DS      CL52                                     @01C
M904_RACROUTE_RC  DS      CL3    INSERT FOR RACROUTE RETURN CODE
                  DS      CL13                                     @01C
                  DS     XL4                                       @01C
M904_LINE4        DS     0CL35                                     @01C
                  DS      CL14                                     @01C
M904_RACF_RETCODE DS      CL3    INSERT FOR RACF RETURN CODE       @01C
                  DS      CL14                                     @01C
M904_RACF_REACODE DS      CL3    INSERT FOR RACF REASON CODE
                  DS      CL1
                  DS     0F      BOUNDARY ALIGNMENT
*----------------------------------------------------------------------
*        LAYOUT FOR IRR905I
*----------------------------------------------------------------------
M905              DS     0CL273                                    @01C
                  DS     XL4
M905_LINE1        DS     CL63                                      @01C
                  DS     XL12
M905_LINE2        DS     0CL69                                     @01C
                   DS     CL51                                     @01C
M905_SUBSYSTEM     DS     CL4    INSERT FOR GROUP/SUBSYSTEM NAME   @01C
                   DS     CL14                                     @01C
                  DS     XL4
M905_LINE3        DS     0CL70                                     @01C
                   DS     CL9                                      @01C
M905_CLASSNAME     DS     CL8    INSERT FOR CLASSNAME TO PROCESS   @01C
                   DS     CL49                                     @01C
M905_RACROUTE_RC   DS     CL3    INSERT FOR RACROUTE RETURN CODE
                   DS     CL1                                      @01C
                  DS     XL4
M905_LINE4        DS     0CL47                                     @01C
                   DS     CL26                                     @01C
M905_RACF_RETCODE  DS     CL3    INSERT FOR RACF RETURN CODE       @01C
                   DS     CL14                                     @01C
M905_RACF_REACODE  DS     CL3    INSERT FOR RACF REASON CODE       @01C
                   DS     CL1                                      @01C
                  DS     0F     BOUNDARY ALIGNMENT
*----------------------------------------------------------------------
*        LAYOUT FOR IRR906I
*----------------------------------------------------------------------
M906              DS     0CL270                                    @01C
                  DS     XL4
M906_LINE1        DS     CL63                                      @01C
                  DS     XL12
M906_LINE2        DS     0CL67                                     @01C
                   DS     CL51                                     @01C
M906_SUBSYSTEM     DS     CL4    INSERT FOR GROUP/SUBSYSTEM NAME   @01C
                   DS     CL12                                     @01C
                  DS     XL4
M906_LINE3        DS     0CL69                                     @01C
                   DS     CL65                                     @01C
M906_RACROUTE_RC   DS     CL3    INSERT FOR RACROUTE RETURN CODE   @01C
                   DS     CL1                                      @01C
                  DS     XL4
M906_LINE4        DS     0CL47                                     @01C
                   DS     CL26                                     @01C
M906_RACF_RETCODE  DS     CL3    INSERT FOR RACF RETURN CODE       @01C
                   DS     CL14                                     @01C
M906_RACF_REACODE  DS     CL3    INSERT FOR RACF REASON CODE       @01C
                   DS     CL1                                      @01C
                  DS     0F      BOUNDARY ALIGNMENT
*----------------------------------------------------------------------
*        LAYOUT FOR IRR907I
*----------------------------------------------------------------------
M907              DS     0CL180                                    @01C
                  DS     XL4
M907_LINE1        DS     CL63                                      @01C
                  DS     XL12
M907_LINE2        DS     0CL67                                     @01C
                   DS     CL51                                     @01C
M907_SUBSYSTEM     DS     CL4    INSERT FOR GROUP/SUBSYSTEM NAME   @01C
                   DS     CL12                                     @01C
                  DS     XL4                                       @01A
M907_LINE3        DS     0CL34                                     @01A
                   DS     CL24                                     @01A
M907_ACEE_ERROR    DS     CL10   INSERT FOR TYPE OF ACEE ERROR     @01C
*----------------------------------------------------------------------
*       STORAGE FOR "IRR912I NATIVE DB2 SECURITY IS USED"          @09A
*----------------------------------------------------------------------
M912              DS     CL(LENGTH_M912)                           @09A
                  DS     0F      BOUNDARY ALIGNMENT                @09A
*----------------------------------------------------------------------
*       STORAGE FOR "IRR913I DB2 SUBSYSTEM TERMINATION REQUESTED"  @09A
*----------------------------------------------------------------------
M913              DS     CL(LENGTH_M913)                           @09A
                  DS     0F      BOUNDARY ALIGNMENT                @09A
*----------------------------------------------------------------------
*       STORAGE FOR "IRR914I INCORRECT DB2 VERSION"                @L3A
*----------------------------------------------------------------------
M914              DS     0CL(LENGTH_M914)                          @L3A
                  DS     XL4                                       @L3A
                  DS     CL45                                      @L3A
M914_XAPLLVL      DS     CL6           DB2 Version from the XAPL   @L3A
                  DS     CL16                                      @L3A
                  DS     0F      BOUNDARY ALIGNMENT                @L3A
*----------------------------------------------------------------------
*        Define storage for messages 908, 909, 910 and 911
*        - When one of these messages is issued it will be
*          overlaid on top of the INFO_MESSAGES area
*----------------------------------------------------------------------
INFO_MESSAGES     DS     CL400
END_INFO_MESSAGES DS     0F
*----------------------------------------------------------------------
*        LAYOUT FOR IRR908I
*----------------------------------------------------------------------
                  ORG    INFO_MESSAGES
M908              DS     0CL153
                  DS     XL4
M908_LINE1        DS     0CL68
                   DS     CL60
M908_SUBSYSTEM     DS     CL4    INSERT FOR GROUP/SUBSYSTEM NAME
                   DS     CL4
                  DS     XL12
M908_LINE2        DS     0CL69
                   DS     CL28
M908_MOD_VERS      DS     CL8    INSERT FOR MODULE VERSION
                   DS     CL24
M908_MOD_LEN       DS     CL8    INSERT FOR MODULE LENGTH
                   DS     CL1
                  DS     0F      BOUNDARY ALIGNMENT
*----------------------------------------------------------------------
*        LAYOUT FOR IRR909I
*----------------------------------------------------------------------
                  ORG    INFO_MESSAGES
M909              DS     0CL327
                  DS     XL4                                       @09C
M909_LINE1        DS     0CL64
                   DS     CL60
M909_SUBSYSTEM     DS     CL4    INSERT FOR GROUP/SUBSYSTEM NAME
                  DS     XL12
M909_LINE2        DS     CL37                                      @09C
                  DS     XL4
M909_LINE3        DS     CL39                                      @09C
                  DS     XL4
M909_LINE4        DS     CL36                                      @09C
                  DS     XL4
M909_LINE5        DS     CL37                                      @09C
                  DS     XL4
M909_LINE6        DS     CL37                                      @09C
                  DS     XL4                                       @09A
M909_LINE7        DS     CL37                                      @09A
                  DS     0F      BOUNDARY ALIGNMENT
*----------------------------------------------------------------------
*        LAYOUT FOR IRR910I
*----------------------------------------------------------------------
                  ORG    INFO_MESSAGES
M910              DS     0CL279
                  DS     XL4
M910_LINE1        DS     0CL64
                   DS     CL60
M910_SUBSYSTEM     DS     CL4    INSERT FOR GROUP/SUBSYSTEM NAME
                  DS     XL12
M910_LINE2        DS     CL38
                  DS     XL4
M910_LINE3        DS     0CL54
                   DS     CL9
M910_CLASS1        DS     CL9
M910_CLASS2        DS     CL9
M910_CLASS3        DS     CL9
M910_CLASS4        DS     CL9
M910_CLASS5        DS     CL9
                  DS     XL4
M910_LINE4        DS     0CL54
                   DS     CL9
M910_CLASS6        DS     CL9
M910_CLASS7        DS     CL9
M910_CLASS8        DS     CL9
M910_CLASS9        DS     CL9
M910_CLASS10       DS     CL9
                  DS     XL4                                      @L1A
M910_LINE5        DS     0CL54                                    @L1A
                   DS     CL9                                     @L1A
M910_CLASS11       DS     CL9                                     @L1A
M910_CLASS12       DS     CL9                                     @L1A
M910_CLASS13       DS     CL9                                     @L1A
M910_CLASS14       DS     CL9                                     @L1A
M910_CLASS15       DS     CL9                                     @08A
                  DS     0F      BOUNDARY ALIGNMENT
*----------------------------------------------------------------------
*        LAYOUT FOR IRR911I
*----------------------------------------------------------------------
                  ORG    INFO_MESSAGES
M911              DS     0CL279
                  DS     XL4
M911_LINE1        DS     0CL64
                   DS     CL60
M911_SUBSYSTEM     DS     CL4    INSERT FOR GROUP/SUBSYSTEM NAME
                  DS     XL12
M911_LINE2        DS     CL39
                  DS     XL4
M911_LINE3        DS     0CL54
                   DS     CL9
M911_CLASS1        DS     CL9
M911_CLASS2        DS     CL9
M911_CLASS3        DS     CL9
M911_CLASS4        DS     CL9
M911_CLASS5        DS     CL9
                  DS     XL4
M911_LINE4        DS     0CL54
                   DS     CL9
M911_CLASS6        DS     CL9
M911_CLASS7        DS     CL9
M911_CLASS8        DS     CL9
M911_CLASS9        DS     CL9
M911_CLASS10       DS     CL9
                  DS     XL4                                      @L1A
M911_LINE5        DS     0CL54                                    @L1A
                   DS     CL9                                     @L1A
M911_CLASS11       DS     CL9                                     @L1A
M911_CLASS12       DS     CL9                                     @L1A
M911_CLASS13       DS     CL9                                     @L1A
M911_CLASS14       DS     CL9                                     @L1A
M911_CLASS15       DS     CL9                                     @08A
                  DS     0F      BOUNDARY ALIGNMENT
*----------------------------------------------------------------------
* Holding area for IRR910I class names
*----------------------------------------------------------------------
                  ORG    END_INFO_MESSAGES
USING_CURRENT     DS     F                       Ptr to current entry
USING_ARRAY       DS     0CL((IRR@TOBJ_NUM+1)*8) Defines array
USING_ENTRY       DS     (IRR@TOBJ_NUM+1)CL8     Defines array entry
*----------------------------------------------------------------------
* Holding area for IRR911I class names
*----------------------------------------------------------------------
RACL_CURRENT      DS     F                       Ptr to current entry
RACL_ARRAY        DS     0CL((IRR@TOBJ_NUM+1)*8) Defines array
RACL_ENTRY        DS     (IRR@TOBJ_NUM+1)CL8     Defines array entry
                  EJECT
*----------------------------------------------------------------------
*        Macro DEFINITIONS - DYNAMIC FORM
*----------------------------------------------------------------------
*
RACSTATD RACROUTE REQUEST=STAT,MF=L,RELEASE=2.4
RACLISTD RACROUTE REQUEST=LIST,MF=L,RELEASE=2.4
RACVERFD RACROUTE REQUEST=VERIFY,MF=L,RELEASE=2.4
CPOOLD   CPOOL    BUILD,MF=L
*
* The following must always appear at the end of the @DATD1 DSECT
@ENDDATD1         DS    0X
@DYNSIZE1         EQU   ((@ENDDATD1-@DATD1+7)/8)*8
         EJECT
*
*----------------------------------------------------------------------
*        Macro DEFINITIONS - STATIC FORM
*----------------------------------------------------------------------
DSNX@XAC CSECT
*
RACSTATS RACROUTE REQUEST=STAT,MF=L,RELEASE=2.4
RSTATLEN EQU  *-RACSTATS
*
RACLISTS RACROUTE REQUEST=LIST,MF=L,RELEASE=2.4
RLISTLEN EQU  *-RACLISTS
*
RACVERFS RACROUTE REQUEST=VERIFY,MF=L,RELEASE=2.4
RVERFLEN EQU  *-RACVERFS
*
CPOOLS   CPOOL    BUILD,MF=L
CPOOLLEN EQU  *-CPOOLS
         EJECT
*----------------------------------------------------------------------
*        CONSTANTS
*----------------------------------------------------------------------
*
DSNX@XAC CSECT
@SIZDATD1             DC  A(@DYNSIZE1)
ONE                   DC  H'0001'
FOUR                  DC  F'4'
LEN_M910I             DC  A(END_M910I-START_M910I)
LEN_M911I             DC  A(END_M911I-START_M911I)
WARNING               DC  F'8'
NOTDEFINED_RCODE      DC  F'8'
SEVERE_ERROR          DC  F'12'
INACTIVE_RCODE        DC  F'16'
TERM_DB2_EXPLRC2      DC  F'16'                                    @09A
ACEE_MISSING          DC  F'1'
RACF_NOT_ACTIVE       DC  F'2'
RACLIST_CREATE_FAILED DC  F'3'
ALL_CLASSES_INACTIVE  DC  F'4'
ACEE_BUILD_FAILED     DC  F'5'
RACLIST_DELETE_FAILED DC  F'7'
DELETE_ACEE_FAILED    DC  F'9'
XAPL_INVALID          DC  F'10'                                    @L3A
ACEE_INVALID          DC  F'12'
DB2V7                 DC  CL8'V7R1M0'                              @09A
ACEE_EYECATCHER       DC  CL4'ACEE'
ADM_CLASS             DC  CL3'ADM'
MISSING               DC  CL10'MISSING.  '
NOT_VALID             DC  CL10'NOT VALID.'
MODNAME               DC  CL8'IRR@XAC1'
TRTABLE               DC  CL16'0123456789ABCDEF'
ZONECHAR8             DS  0XL8
ZONECHARS             DC  XL3'0F0F0F'
                      DC  XL5'0F0F0F0F0F'
CPOOLHDR              DC  CL24'RACF/DB2 EXTRN SEC CPOOL'
NONE                  DC  CL8'* NONE *'
MODVERS               DC  CL8'&SERVICELEVEL '
OBJECT_TABLE_PTR      DC  A(IRR@TOBJ)
IRR900A_PTR           DC  A(IRR900A)
IRR901A_PTR           DC  A(IRR901A)
IRR902A_PTR           DC  A(IRR902A)
IRR903A_PTR           DC  A(IRR903A)
IRR904I_PTR           DC  A(IRR904I)
IRR905I_PTR           DC  A(IRR905I)
IRR906I_PTR           DC  A(IRR906I)
IRR907I_PTR           DC  A(IRR907I)
IRR908I_PTR           DC  A(IRR908I)
IRR909I_PTR           DC  A(IRR909I)
IRR910I_PTR           DC  A(IRR910I)
IRR911I_PTR           DC  A(IRR911I)
IRR912I_PTR           DC  A(IRR912I)                               @09A
IRR913I_PTR           DC  A(IRR913I)                               @09A
IRR914I_PTR           DC  A(IRR914I)                               @L3A
XACS_TOTAL_LEN1   DC   A(DSNX@MSG_LEN+IRR@TOBJ_LEND+IRR@TPRV_LEN+IRR@TRX
               ES_LEN+IRR@TRUL_LEN+DSNX@XAC_LEN+IRR@XAC1_LEN)      @0CC
         EJECT
*----------------------------------------------------------------------
*        PATCH AREA
*----------------------------------------------------------------------
         PRINT ON,GEN,DATA
DSNX@XAC CSECT
PATCH1   DC    25S(*)
         ORG   PATCH1
         DC    ((((*-IRR@XAC1+99)/100)*5+1)/2)S(*)
         ORG
IRR@XAC1_LEN   EQU   ((*-IRR@XAC1+7)/8*8)
         EJECT
         TITLE 'DSNX@MSG - Message Module'
**********************************************************************
* $XMSGDESC                                                          *
**********************************************************************
*                                                                    *
*01* MODULE NAME:                                                    *
*      IRR@XACS                                                      *
*                                                                    *
*02*   CSECT NAME:                                                   *
*        DSNX@MSG                                                    *
*                                                                    *
*                                                                    *
*01* DESCRIPTIVE NAME:                                               *
*      RACF/DB2 External Security Module - Message Module            *
*                                                                    *
***********************************************************************
*----------------------------------------------------------------------
* $XMSGCODE - IRR@XMSG Message Module
*----------------------------------------------------------------------
DSNX@MSG CSECT
DSNX@MSG AMODE 31
DSNX@MSG RMODE ANY
IRR900A  WTO   ('IRR900A  RACF/DB2 EXTERNAL SECURITY MODULE FAILED TO I*
               NITIALIZE',D),                                      @01C*
               ('         FOR DB2 SUBSYSTEM xxxx BECAUSE CLASS xxxxxxxx*
                COULD NOT BE',D),                                  @01C*
               ('         RACLISTED. RACROUTE RETURN CODE xxx, RACF RET*
               URN CODE xxx,',D),                                  @01C*
               ('         REASON CODE xxx.',DE),                   @09C*
               ROUTCDE=(1,9),DESC=(2),MF=L
*              "NATIVE DB2 SECURITY USED" text deleted.            @09D
IRR901A  WTO   ('IRR901A  RACF/DB2 EXTERNAL SECURITY MODULE FAILED TO I*
               NITIALIZE',D),                                      @01C*
               ('         FOR DB2 SUBSYSTEM xxxx BECAUSE NO ACTIVE DB2 *
               RELATED CLASSES',D),                                @01C*
               ('         WERE FOUND.',DE),                        @09C*
               ROUTCDE=(1,9),DESC=(2),MF=L
*              "NATIVE DB2 SECURITY USED" text deleted.            @09D
IRR902A  WTO   ('IRR902A  RACF/DB2 EXTERNAL SECURITY MODULE FAILED TO I*
               NITIALIZE',D),                                      @01C*
               ('         FOR DB2 SUBSYSTEM xxxx BECAUSE THE INPUT ACEE*
                WAS xxxxxxxxxx.',DE),                              @09C*
               ROUTCDE=(1,9),DESC=(2),MF=L
*              "NATIVE DB2 SECURITY USED" text deleted.            @09D
IRR903A  WTO   ('IRR903A  RACF/DB2 EXTERNAL SECURITY MODULE FAILED TO I*
               NITIALIZE',D),                                      @01C*
               ('         FOR DB2 SUBSYSTEM xxxx BECAUSE RACF WAS NOT A*
               CTIVE.',DE),                                        @09C*
               ROUTCDE=(1,9),DESC=(2),MF=L
*              "NATIVE DB2 SECURITY USED" text deleted.            @09D
IRR904I  WTO   ('IRR904I  RACF/DB2 EXTERNAL SECURITY MODULE INITIALIZED*
                WITH',D),                                          @01C*
               ('         WARNINGS FOR DB2 SUBSYSTEM xxxx BECAUSE A DEF*
               AULT ACEE',D),                                      @01C*
               ('         COULD NOT BE CREATED. RACROUTE RETURN CODE xx*
               x, RACF RETURN',D),                                 @01C*
               ('         CODE xxx, REASON CODE xxx.',DE),         @01C*
               ROUTCDE=(2,9,10),DESC=(12),MF=L                     @00C
IRR905I  WTO   ('IRR905I  RACF/DB2 EXTERNAL SECURITY MODULE TERMINATION*
                FUNCTION',D),                                      @01C*
               ('         COMPLETED WITH WARNINGS FOR DB2 SUBSYSTEM xxx*
               x BECAUSE CLASS',D),                                @01C*
               ('         xxxxxxxx COULD NOT BE UN-RACLISTED. RACROUTE *
               RETURN CODE xxx,',D),                               @01C*
               ('         RACF RETURN CODE xxx, REASON CODE xxx.',DE), *
               ROUTCDE=(2,9,10),DESC=(12),MF=L                     @00C
IRR906I  WTO   ('IRR906I  RACF/DB2 EXTERNAL SECURITY MODULE TERMINATION*
                FUNCTION',D),                                      @01C*
               ('         COMPLETED WITH WARNINGS FOR DB2 SUBSYSTEM xxx*
               x BECAUSE THE',D),                                  @01C*
               ('         DEFAULT ACEE COULD NOT BE DELETED. RACROUTE R*
               ETURN CODE xxx,',D),                                @01C*
               ('         RACF RETURN CODE xxx, REASON CODE xxx.',DE), *
               ROUTCDE=(2,9,10),DESC=(12),MF=L                     @00C
IRR907I  WTO   ('IRR907I  RACF/DB2 EXTERNAL SECURITY MODULE TERMINATION*
                FUNCTION',D),                                      @01C*
               ('         COMPLETED WITH WARNINGS FOR DB2 SUBSYSTEM xxx*
               x BECAUSE THE',D),                                  @01C*
               ('         INPUT ACEE WAS xxxxxxxxxx',DE),          @01C*
               ROUTCDE=(2,9,10),DESC=(12),MF=L                     @00C
IRR908I  WTO   ('IRR908I RACF/DB2 EXTERNAL SECURITY MODULE FOR DB2 SUBS*
               YSTEM xxxx HAS',D),                                     *
               ('        A MODULE VERSION OF xxxxxxxx AND A MODULE LENG*
               TH OF xxxxxxxx.',DE),                                   *
               MCSFLAG=HRDCPY,ROUTCDE=(9,10),DESC=(4),MF=L         @00C
IRR909I  WTO   ('IRR909I RACF/DB2 EXTERNAL SECURITY MODULE FOR DB2 SUBS*
               YSTEM xxxx',D),                                         *
               ('        IS USING OPTIONS: &&CLASSOPT=&CLASSOPT',D),   *
               ('                          &&CLASSNMT=&CLASSNMT',D),   *
               ('                          &&CHAROPT=&CHAROPT',D),     *
               ('                          &&ERROROPT=&ERROROPT',D),   *
               ('                          &&PCELLCT=&PCELLCT',D),     *
               ('                          &&SCELLCT=&SCELLCT',DE),    *
               MCSFLAG=HRDCPY,ROUTCDE=(9,10),DESC=(4),MF=L         @09C
START_M910I    EQU *                                               @L1C
IRR910I  WTO   ('IRR910I RACF/DB2 EXTERNAL SECURITY MODULE FOR DB2 SUBS*
               YSTEM xxxx',D),                                         *
               ('        INITIATED RACLIST FOR CLASSES:',D),           *
               ('         xxxxxxxx xxxxxxxx xxxxxxxx xxxxxxxx xxxxxxxx *
               ',D),                                                   *
               ('         xxxxxxxx xxxxxxxx xxxxxxxx xxxxxxxx xxxxxxxx *
               ',D),                                               @L1C*
               ('         xxxxxxxx xxxxxxxx xxxxxxxx xxxxxxxx xxxxxxxx'*
               ,DE),                                               @08C*
               MCSFLAG=HRDCPY,ROUTCDE=(9,10),DESC=(4),MF=L         @00C
END_M910I      EQU *                                               @L1C
START_M911I    EQU *                                               @L1C
IRR911I  WTO   ('IRR911I RACF/DB2 EXTERNAL SECURITY MODULE FOR DB2 SUBS*
               YSTEM xxxx',D),                                         *
               ('        SUCCESSFULLY RACLISTED CLASSES:',D),          *
               ('         xxxxxxxx xxxxxxxx xxxxxxxx xxxxxxxx xxxxxxxx *
               ',D),                                                   *
               ('         xxxxxxxx xxxxxxxx xxxxxxxx xxxxxxxx xxxxxxxx *
               ',D),                                               @L1C*
               ('         xxxxxxxx xxxxxxxx xxxxxxxx xxxxxxxx xxxxxxxx'*
               ,DE),                                               @08C*
               MCSFLAG=HRDCPY,ROUTCDE=(9,10),DESC=(4),MF=L         @00C
END_M911I      EQU *                                               @L1C
START_M912I    EQU *                                               @09A
IRR912I  WTO   ('IRR912I NATIVE DB2 AUTHORIZATION IS USED.'),      @09A*
               ROUTCDE=(1,9),DESC=(2),MF=L                         @09A
END_M912I      EQU *                                               @09A
LENGTH_M912    EQU END_M912I-START_M912I                           @09A
START_M913I    EQU *                                               @09A
IRR913I  WTO   ('IRR913I DB2 SUBSYSTEM TERMINATION REQUESTED.'),   @09A*
               ROUTCDE=(1,9),DESC=(2),MF=L                         @09A
END_M913I      EQU *                                               @09C
LENGTH_M913    EQU END_M913I-START_M913I
START_M914I    EQU *                                               @L3A
IRR914I  WTO   ('IRR914I DSNX@XAC HAS BEEN INVOKED WITH A DB2 VvRrMm PA*
               RAMETER LIST.'),ROUTCDE=(1,9),DESC=(2),MF=L         @L3A
END_M914I      EQU *                                               @L3A
LENGTH_M914    EQU END_M914I-START_M914I
DSNX@MSG_LEN   EQU   ((*-DSNX@MSG+7)/8*8)
         EJECT
         TITLE 'IRR@TPRV - Privilege Table'
**********************************************************************
* $TPRVDESC                                                          *
**********************************************************************
*                                                                    *
*01* MODULE NAME:                                                    *
*      IRR@XACS                                                      *
*                                                                    *
*02*   CSECT NAME:                                                   *
*        IRR@TPRV                                                    *
*                                                                    *
*                                                                    *
*01* DESCRIPTIVE NAME:                                               *
*      RACF/DB2 External Security Module - Privilege Table           *
*                                                                    *
*                                                                    *
*01* FUNCTION:                                                       *
*      There is one Privilege Table and it contains an entry for     *
*      each unique privilege code.  Each entry contains a privilege  *
*      code, privilege name and one or more Rule Table addresses.    *
*      Since, some privilege codes are defined to more than one      *
*      object, the privilege entries must contain a Rule Table       *
*      address for each object which shares the privilege.  The one  *
*      character object abbreviations are stored with the Rule       *
*      Table addresses to allow he Rule table for a specific object  *
*      to be located.                                                *
*                                                                    *
*      The privilege table contains an index which is used to        *
*      locate privilege entries.  The index uses the privilege code  *
*      as its key and points to the actual privilege table entries.  *
*                                                                    *
*      The Privilege Table and entries are expanded by the PRIVILEGE *
*      macro and mapped by PRVDSECT.                                 *
*                                                                    *
*      Below is an illustration showing the linkage of the DB2       *
*      Authorization Tables.  An entry in the Privilege table points *
*      to a Rule Table.  Each Rule Table contains a entry for each   *
*      FASTAUTH request that can be made for the privilege.  Each    *
*      entry in the Rule Table points to an entry in the Resource    *
*      Table.  A Resource Table entry defines the class name,        *
*      resource name, DB2 authority and object owner (if any).       *
*                                                                    *
*   Privilege       Privilege       Rule            Resource         *
*   Table Index     Table           Table           Table            *
*   (IRR@TPRV)      (IRR@TPRV)      (IRR@TRUL)      (IRR@TRES)       *
*   +----------+    +----------+    +----------+    +--------------+ *
*  0|          |    |+--------+|    |    o     |    |      o       | *
*   |----------|    ||0012    ||    |    o     |    |      o       | *
*  1|          |    ||        ||    |    o     |    |      o       | *
*   |----------|    ||        ||    |+--------+|    |+------------+| *
*   |          |    |+--------+| +->||DROP db || +->||DROP  | | | || *
*   |    o     |    |    o     | |  ||--------|| |  |+------------+| *
*   |          |    |    o     | |  ||DROP   ----+  |      o       | *
*   |    o     |    |    o     | |  ||DBCTL  ----+  |      o       | *
*   |          |    |          | |  ||DBADM  ----+  |      o       | *
*   |    o     |    |+--------+| |  ||SYSCTRL || |  |+------------+| *
*   |          | +->||0073    || |  ||SYSADM  || +->||DBCTL | | | || *
*   |----------| |  ||--------|| |  |+--------+| |  |+------------+| *
* 73|    --------+  ||D    ------+  |+--------+| +->||DBADM | | | || *
*   |----------|    ||K    -------->||DROP pk ||    |+------------+| *
*   |          |    ||R    ------+  ||        ||    |      o       | *
*   |    o     |    |+--------+| |  ||        ||    |      o       | *
*   |          |    |          | |  |+--------+|    |      o       | *
*   |    o     |    |          | |  |+--------+|    |+------------+| *
*   |          |    |          | +->||DROP ts ||    ||SYSOPR| | | || *
*   |    o     |    |    o     |    ||        ||    |+------------+| *
*   |          |    |    o     |    ||        ||    ||SYSCTRL | | || *
*   |----------|    |    o     |    |+--------+|    |+------------+| *
*251|          |    |+--------+|    |    o     |    ||SYSADM| | | || *
*   +----------+    ||0251    ||    |    o     |    |+------------+| *
*                   ||        ||    |    o     |    |      o       | *
*                   ||        ||    |          |    |      o       | *
*                   |+--------+|    |          |    |      o       | *
*                   +----------+    +----------+    +--------------+ *
*                                                                    *
**********************************************************************
         EJECT
*----------------------------------------------------------------------
* $TPRVCODE - IRR@TPRV Privilege Table
*----------------------------------------------------------------------
IRR@TPRV CSECT
IRR@TPRV RMODE ANY
*----------------------------------------------------------------------
* DB2/RACF Privilege Table Header
*----------------------------------------------------------------------
         DS    0F                      Boundry alignment
         DC    CL8'IRR@TPRV'           Eyecatcher
         DC    CL8' &SERVICELEVEL'     FMID
         DC    CL8'&SYSDATE'           Date
         DC    CL8'&SYSTIME'           Time
         DC    A(PRV_INDEX_NO)         Number of privileges in index
*----------------------------------------------------------------------
* Privilege Table Index
*----------------------------------------------------------------------
PRV_INDEX DC   12F'0'                  Priv Codes 0-11: unsupported
         DC    A(PRIV0012)
         DC    A(PRIV0013)
         DC    A(PRIV0014)
         DC    A(PRIV0015)
         DC    A(PRIV0016)
         DC    A(PRIV0017)
         DC    F'0'                    Priv Code 18: unsupported
         DC    A(PRIV0019)
         DC    A(PRIV0020)
         DC    A(PRIV0021)
         DC    A(PRIV0022)
         DC    27F'0'                  Priv Codes 23-49: unsupported
         DC    A(PRIV0050)
         DC    A(PRIV0051)
         DC    A(PRIV0052)
         DC    A(PRIV0053)
         DC    A(PRIV0054)
         DC    A(PRIV0055)                                         @L1C
         DC    A(PRIV0056)
         DC    A(PRIV0057)
         DC    A(PRIV0058)
         DC    2F'0'                   Priv Codes 59-60: unsupported
         DC    A(PRIV0061)
         DC    A(PRIV0062)
         DC    F'0'                    Priv Code 63: unsupported
         DC    A(PRIV0064)
         DC    A(PRIV0065)
         DC    A(PRIV0066)
         DC    A(PRIV0067)
         DC    A(PRIV0068)
         DC    A(PRIV0069)
         DC    2F'0'                   Priv Codes 70-71: unsupported
         DC    A(PRIV0072)
         DC    A(PRIV0073)
         DC    A(PRIV0074)
         DC    A(PRIV0075)
         DC    A(PRIV0076)
         DC    A(PRIV0077)
         DC    A(PRIV0078)
         DC    A(PRIV0079)
         DC    A(PRIV0080)
         DC    F'0'                    Priv Code 81: unsupported
         DC    A(PRIV0082)
         DC    A(PRIV0083)
         DC    A(PRIV0084)
         DC    A(PRIV0085)
         DC    A(PRIV0086)
         DC    A(PRIV0087)
         DC    A(PRIV0088)
         DC    A(PRIV0089)
         DC    2F'0'                   Priv Codes 90-91: unsupported
         DC    A(PRIV0092)
         DC    A(PRIV0093)
         DC    A(PRIV0094)
         DC    A(PRIV0095)
         DC    F'0'                    Priv Code 96: unsupported
         DC    A(PRIV0097)
         DC    A(PRIV0098)
         DC    A(PRIV0099)
         DC    2F'0'                   Priv Codes 100-101: unsupported
         DC    A(PRIV0102)
         DC    A(PRIV0103)
         DC    A(PRIV0104)
         DC    A(PRIV0105)
         DC    F'0'                    Priv Code 106: unsupported
         DC    A(PRIV0107)
         DC    A(PRIV0108)
         DC    A(PRIV0109)
         DC    2F'0'                   Priv Codes 110-111: unsupported
         DC    A(PRIV0112)
         DC    A(PRIV0113)
         DC    110F'0'                 Priv Codes 114-223: unsupported
         DC    A(PRIV0224)
         DC    A(PRIV0225)
         DC    A(PRIV0226)
         DC    A(PRIV0227)
         DC    A(PRIV0228)
         DC    A(PRIV0229)
         DC    1F'0'                   Priv Code 230: unsupported
         DC    A(PRIV0231)
         DC    1F'0'                   Priv Code 232: unsupported
         DC    A(PRIV0233)
         DC    2F'0'                   Priv Codes 234-235: unsupported
         DC    A(PRIV0236)
         DC    A(PRIV0237)
         DC    A(PRIV0238)
         DC    A(PRIV0239)
         DC    A(PRIV0240)
         DC    A(PRIV0241)
         DC    A(PRIV0242)
         DC    A(PRIV0243)
         DC    A(PRIV0244)
         DC    A(PRIV0245)
         DC    A(PRIV0246)
         DC    A(PRIV0247)
         DC    A(PRIV0248)
         DC    2F'0'                   Priv Codes 249-250: unsupported
         DC    A(PRIV0251)
         DC    A(PRIV0252)                                         @L1A
         DC    8F'0'               Priv Codes 253-260: unsupported @L1A
*                                                                  @L1A
         DC    A(PRIV0261)                                         @L1A
         DC    A(PRIV0262)                                         @L1A
         DC    A(PRIV0263)                                         @L1A
         DC    F'0'                Priv Code  264: unsupported     @L1A
         DC    A(PRIV0265)                                         @L1A
         DC    A(PRIV0266)                                         @L1A
         DC    A(PRIV0267)                                         @L1A
PRV_INDEX_LEN  EQU  *-PRV_INDEX
PRV_INDEX_NO   EQU  PRV_INDEX_LEN/4
         EJECT
*----------------------------------------------------------------------
* Privilege Table Entries
*----------------------------------------------------------------------
         PRIVILEGE PRVCODE=0012,PRVNAME=CHKSTART,OBJECT=(U)
         PRIVILEGE PRVCODE=0013,PRVNAME=CHKSTOP,OBJECT=(U)
         PRIVILEGE PRVCODE=0014,PRVNAME=CHKDSPL,OBJECT=(U)
         PRIVILEGE PRVCODE=0015,PRVNAME=CRTALAUT,OBJECT=(U)
         PRIVILEGE PRVCODE=0016,PRVNAME=MON1AUT,OBJECT=(U)
         PRIVILEGE PRVCODE=0017,PRVNAME=MON2AUT,OBJECT=(U)
         PRIVILEGE PRVCODE=0019,PRVNAME=CHECKAUT,OBJECT=(D)
         PRIVILEGE PRVCODE=0020,PRVNAME=DRPALAUT,OBJECT=(T)
         PRIVILEGE PRVCODE=0021,PRVNAME=CHKDDF,OBJECT=(U)
         PRIVILEGE PRVCODE=0022,PRVNAME=CNVRTAUT,OBJECT=(T)
         PRIVILEGE PRVCODE=0050,PRVNAME=SELCTAUT,OBJECT=(T,V)      @0BC
         PRIVILEGE PRVCODE=0051,PRVNAME=INSRTAUT,OBJECT=(T,V)      @0BC
         PRIVILEGE PRVCODE=0052,PRVNAME=DELETAUT,OBJECT=(T,V)      @0BC
         PRIVILEGE PRVCODE=0053,PRVNAME=UPDTEAUT,OBJECT=(T,V)      @0BC
         PRIVILEGE PRVCODE=0054,PRVNAME=REFERAUT,OBJECT=(T)
         PRIVILEGE PRVCODE=0055,PRVNAME=TRIGAUT,OBJECT=(T)        @L1A
         PRIVILEGE PRVCODE=0056,PRVNAME=INDEXAUT,OBJECT=(T)
         PRIVILEGE PRVCODE=0057,PRVNAME=DBAAUTH,OBJECT=(D)
         PRIVILEGE PRVCODE=0058,PRVNAME=TERMDAUT,OBJECT=(D)
         PRIVILEGE PRVCODE=0061,PRVNAME=ALTERAUT,OBJECT=(R,S,T)
         PRIVILEGE PRVCODE=0062,PRVNAME=CHKDISPL,OBJECT=(U)
         PRIVILEGE PRVCODE=0064,PRVNAME=CHKEXEC,OBJECT=(F,K,P,O)   @L1C
         PRIVILEGE PRVCODE=0065,PRVNAME=BINDAUT,OBJECT=(K,P)
         PRIVILEGE PRVCODE=0066,PRVNAME=CRTDBAUT,OBJECT=(U)
         PRIVILEGE PRVCODE=0067,PRVNAME=CRTSGAUT,OBJECT=(U)
         PRIVILEGE PRVCODE=0068,PRVNAME=DBCTLAUT,OBJECT=(D)
         PRIVILEGE PRVCODE=0069,PRVNAME=DBMNTAUT,OBJECT=(D)
         PRIVILEGE PRVCODE=0072,PRVNAME=CHKRECOV,OBJECT=(U)
         PRIVILEGE PRVCODE=0073,PRVNAME=DROPAUT,                   @0BCX
               OBJECT=(D,K,R,S,T,V)                                @0BC
         PRIVILEGE PRVCODE=0074,PRVNAME=IMCOPAUT,OBJECT=(D)
         PRIVILEGE PRVCODE=0075,PRVNAME=LOADAUT,OBJECT=(D,T)
         PRIVILEGE PRVCODE=0076,PRVNAME=QUALAUT,OBJECT=(D,M,T)     @L1C
         PRIVILEGE PRVCODE=0077,PRVNAME=REORGAUT,OBJECT=(D)
         PRIVILEGE PRVCODE=0078,PRVNAME=REPARAUT,OBJECT=(D)
         PRIVILEGE PRVCODE=0079,PRVNAME=STARTAUT,OBJECT=(D)
         PRIVILEGE PRVCODE=0080,PRVNAME=CHKSUBSY,OBJECT=(U)
         PRIVILEGE PRVCODE=0082,PRVNAME=STATSAUT,OBJECT=(D)
         PRIVILEGE PRVCODE=0083,PRVNAME=STOPAUT,OBJECT=(D)
         PRIVILEGE PRVCODE=0084,PRVNAME=CHKTRACE,OBJECT=(U)
         PRIVILEGE PRVCODE=0085,PRVNAME=SYSAAUTH,OBJECT=(U)
         PRIVILEGE PRVCODE=0086,PRVNAME=SYSOAUTH,OBJECT=(U)
         PRIVILEGE PRVCODE=0087,PRVNAME=USEAUT,OBJECT=(B,R,S)
         PRIVILEGE PRVCODE=0088,PRVNAME=BINDAAUT,OBJECT=(U)
         PRIVILEGE PRVCODE=0089,PRVNAME=RECDBAUT,OBJECT=(D)
         PRIVILEGE PRVCODE=0092,PRVNAME=CRTDCAUT,OBJECT=(U)
         PRIVILEGE PRVCODE=0093,PRVNAME=CHKBSDS,OBJECT=(U)
         PRIVILEGE PRVCODE=0094,PRVNAME=CRTTBAUT,OBJECT=(D)
         PRIVILEGE PRVCODE=0095,PRVNAME=CRTTSAUT,OBJECT=(D)
         PRIVILEGE PRVCODE=0097,PRVNAME=COMNTAUT,                      X
               OBJECT=(M,T,V)                                      @0BA
         PRIVILEGE PRVCODE=0098,PRVNAME=LOCKAUT,OBJECT=(T)
         PRIVILEGE PRVCODE=0099,PRVNAME=DSPDBAUT,OBJECT=(D)
         PRIVILEGE PRVCODE=0102,PRVNAME=CRTSYAUT,OBJECT=(T)
         PRIVILEGE PRVCODE=0103,PRVNAME=ALTIXAUT,OBJECT=(T)
         PRIVILEGE PRVCODE=0104,PRVNAME=DRPSYAUT,OBJECT=(T)
         PRIVILEGE PRVCODE=0105,PRVNAME=DRPIXAUT,OBJECT=(T)
         PRIVILEGE PRVCODE=0107,PRVNAME=STOAUT,OBJECT=(U)
         PRIVILEGE PRVCODE=0108,PRVNAME=CRTVUAUT,OBJECT=(T,V)      @0BC
         PRIVILEGE PRVCODE=0109,PRVNAME=TERMAUT,OBJECT=(D)
         PRIVILEGE PRVCODE=0112,PRVNAME=CHKDSPBP,OBJECT=(U)
         PRIVILEGE PRVCODE=0113,PRVNAME=CHKALTBP,OBJECT=(U)
         PRIVILEGE PRVCODE=0224,PRVNAME=SYSCAUTH,OBJECT=(U)
         PRIVILEGE PRVCODE=0225,PRVNAME=COPYAUT,OBJECT=(K)
         PRIVILEGE PRVCODE=0226,PRVNAME=CRTINAUT,OBJECT=(C)
         PRIVILEGE PRVCODE=0227,PRVNAME=BNDAGAUT,OBJECT=(U)
         PRIVILEGE PRVCODE=0228,PRVNAME=ALLPKAUT,OBJECT=(K)
         PRIVILEGE PRVCODE=0229,PRVNAME=SUBPKAUT,OBJECT=(K)
         PRIVILEGE PRVCODE=0231,PRVNAME=ARCHAUT,OBJECT=(U)
         PRIVILEGE PRVCODE=0233,PRVNAME=ANYTBAUT,OBJECT=(T,V)      @0BC
         PRIVILEGE PRVCODE=0236,PRVNAME=DIAGAUT,OBJECT=(D)
         PRIVILEGE PRVCODE=0237,PRVNAME=MERGEAUT,OBJECT=(D)
         PRIVILEGE PRVCODE=0238,PRVNAME=MODAUT,OBJECT=(D)
         PRIVILEGE PRVCODE=0239,PRVNAME=QUIESAUT,OBJECT=(D)
         PRIVILEGE PRVCODE=0240,PRVNAME=REPRTAUT,OBJECT=(D)
         PRIVILEGE PRVCODE=0241,PRVNAME=RDBDAUT,OBJECT=(D)
         PRIVILEGE PRVCODE=0242,PRVNAME=PKADMAUT,OBJECT=(C)
         PRIVILEGE PRVCODE=0243,PRVNAME=SARCHAUT,OBJECT=(U)
         PRIVILEGE PRVCODE=0244,PRVNAME=DARCHAUT,OBJECT=(U)
         PRIVILEGE PRVCODE=0245,PRVNAME=STRPRAUT,OBJECT=(U)
         PRIVILEGE PRVCODE=0246,PRVNAME=STPPRAUT,OBJECT=(U)
         PRIVILEGE PRVCODE=0247,PRVNAME=DSPPRAUT,OBJECT=(U)
         PRIVILEGE PRVCODE=0248,PRVNAME=CRTTMAUT,OBJECT=(U)
         PRIVILEGE PRVCODE=0251,PRVNAME=RNTABAUT,OBJECT=(T)
         PRIVILEGE PRVCODE=0252,PRVNAME=ALTINAUT,OBJECT=(M)        @L1A
         PRIVILEGE PRVCODE=0261,PRVNAME=CRTINAUT,OBJECT=(M)        @L1A
         PRIVILEGE PRVCODE=0262,PRVNAME=DRPINAUT,OBJECT=(M)        @L1A
         PRIVILEGE PRVCODE=0263,PRVNAME=USAGEAUT,OBJECT=(E,J)      @08C
         PRIVILEGE PRVCODE=0265,PRVNAME=STRTAUT,OBJECT=(F,O)       @L1A
         PRIVILEGE PRVCODE=0266,PRVNAME=STPAUT,OBJECT=(F,O)        @L1A
         PRIVILEGE PRVCODE=0267,PRVNAME=DISPLAUT,OBJECT=(F,O)      @L1A
IRR@TPRV_LEN   EQU   ((*-IRR@TPRV+7)/8*8)
         EJECT
         TITLE 'IRR@TRUL - Rule Table'
**********************************************************************
* $TRULDESC                                                          *
**********************************************************************
*                                                                    *
*01* MODULE NAME:                                                    *
*      IRR@XACS                                                      *
*                                                                    *
*02*   CSECT NAME:                                                   *
*        IRR@TRUL                                                    *
*                                                                    *
*                                                                    *
*01* DESCRIPTIVE NAME:                                               *
*      RACF/DB2 External Security Module - Rule Tables               *
*                                                                    *
*                                                                    *
*01* FUNCTION:                                                       *
*      Defines the REQUEST=FASTAUTH invocations that are required    *
*      to determine authority to the object/privilege pair. There    *
*      is one rule table per object/privilege pair. Each rule table  *
*      contains the privilege code, the number of FASTAUTH checks    *
*      for the privilege and an entry for each FASTAUTH check.       *
*      Each entry contains the address of a Resource Table entry.    *
*                                                                    *
*      The Rule Table and entries are expanded by the RULE macro     *
*      and mapped by RULDSECT.                                       *
*                                                                    *
*      For an illustration of the Authorization tables see IRR@TPRV. *
*                                                                    *
**********************************************************************
         EJECT
*----------------------------------------------------------------------
* $TRULCODE - IRR@TRUL Rule Table
*----------------------------------------------------------------------
IRR@TRUL CSECT
IRR@TRUL RMODE ANY
*----------------------------------------------------------------------
* DB2/RACF Rule Tables - Common Header
*
* This table contains one CSECT for each privilege supported by
* the DB2/RACF Authorization Exit.  Each CSECT contains the
* authorization questions that must be asked to satisfy that
* privilege.
*----------------------------------------------------------------------
         DS    0F                   Boundry alignment
         DC    CL8'IRR@TRUL'        Eyecatcher
         DC    CL8' &SERVICELEVEL'  FMID
         DC    CL8'&SYSDATE'        Date
         DC    CL8'&SYSTIME'        Time
*----------------------------------------------------------------------
* CHECKAUT/STATSAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0019,0082),OBJECT=D,                              X
               RES=(STATS,DBMNT_D,DBCTRL_D,DBADM_D,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* DBAAUTH Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0057),OBJECT=D,                                   X
               RES=(DBADM_D,SYSADM)
*----------------------------------------------------------------------
* TERMDAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0058),OBJECT=D,                                   X
               RES=(DBMNT_D,DBCTRL_D,DBADM_D)
*----------------------------------------------------------------------
* DBCTLAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0068),OBJECT=D,                                   X
               RES=(DBCTRL_D,DBADM_D,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* DBMNTAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0069),OBJECT=D,                                   X
               RES=(DBMNT_D,DBCTRL_D,DBADM_D,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* DROPTAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0073),OBJECT=D,                                   X
               RES=(DROP,DBCTRL_D,DBADM_D,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* IMCOPAUT/MERGEAUT/MODAUT/QUIESAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0074,0237,0238,0239),OBJECT=D,                    X
               RES=(IMAGCOPY,DBMNT_D,DBCTRL_D,DBADM_D,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* LOADAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0075),OBJECT=D,                                   X
               RES=(LOAD_D,DBCTRL_D,DBADM_D,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* QUALAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0076),OBJECT=D,                                   X
               RES=(DBCTRL_D,DBADM_D,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* REORGAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0077),OBJECT=D,                                   X
               RES=(REORG,DBCTRL_D,DBADM_D,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* REPARAUT/DIAGAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0078,0236),OBJECT=D,                              X
               RES=(REPAIR,DBCTRL_D,DBADM_D,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* STARTAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0079),OBJECT=D,                                   X
               RES=(STARTDB,DBMNT_D,DBCTRL_D,DBADM_D,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* STOPAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0083),OBJECT=D,                                   X
               RES=(STOPDB,DBMNT_D,DBCTRL_D,DBADM_D,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* RECDBAUT/REPRTAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0089,0240),OBJECT=D,                              X
               RES=(RECOVRDB,DBCTRL_D,DBADM_D,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* CRTTBAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0094),OBJECT=D,                                   X
               RES=(CREATT_D,DBMNT_D,DBCTRL_D,DBADM_D,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* CRTTSAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0095),OBJECT=D,                                   X
               RES=(CREATETS,DBMNT_D,DBCTRL_D,DBADM_D,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* DSPDBAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0099),OBJECT=D,                                   X
               RES=(DISPLYDB,DBMNT_D,DBCTRL_D,DBADM_D,SYSOPR,DISPLAY,  X
               SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* TERMAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0109),OBJECT=D,                                   X
               RES=(SYSOPR,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* RDBDAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0241),OBJECT=D,                                   X
               RES=(SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* CHKEXEC Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0064),OBJECT=K,                                   X
               RES=(EXECUT_K,PACKAD_K,SYSADM)
*----------------------------------------------------------------------
* BINDAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0065),OBJECT=K,                                   X
               RES=(OWNER_K,BIND_K,BINDAG_K,PACKAD_K,SYSCTRL,SYSADM)
*                                                                  @L2A
*----------------------------------------------------------------------
* DROPAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0073),OBJECT=K,                                   X
               RES=(PACKAD_K,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* COPYAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0225),OBJECT=K,                                   X
               RES=(OWNER_K,COPY,BINDAG_K,PACKAD_K,SYSCTRL,SYSADM) @L2A
*----------------------------------------------------------------------
* ALLPKAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0228),OBJECT=K,                                   X
               RES=(PACKAD_K,SYSADM)
*----------------------------------------------------------------------
* SUBPKAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0229),OBJECT=K,                                   X
               RES=(PACKAD_K,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* CHKEXEC Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0064),OBJECT=P,                                   X
               RES=(EXECUT_P,SYSADM)
*----------------------------------------------------------------------
* BINDAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0065),OBJECT=P,                                   X
               RES=(OWNER_P,BIND_P,BINDAG_P,SYSCTRL,SYSADM)        @L2A
*----------------------------------------------------------------------
* USEAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0087),OBJECT=B,                                   X
               RES=(USE_B,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* CRTINAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0226),OBJECT=C,                                   X
               RES=(CREATEIN,PACKAD_C,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* PKADMAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0242),OBJECT=C,                                   X
               RES=(PACKAD_C,SYSADM)
*----------------------------------------------------------------------
* ALTERAUT/DROPAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0061,0073),OBJECT=R,                              X
               RES=(DBADM_R,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* USEAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0087),OBJECT=R,                                   X
               RES=(USE_R,DBADM_R,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* ALTERAUT/DROPAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0061,0073),OBJECT=S,                              X
               RES=(SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* USEAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0087),OBJECT=S,                                   X
               RES=(USE_S,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* DRPALAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0020),OBJECT=T,                                   X
               RES=(OWNER_T,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* CNVRTAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0022),OBJECT=T,                                   X
               RES=(DBADM_T,SYSCTRL,SYSADM)                        @04A
*----------------------------------------------------------------------
* SELCTAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0050),OBJECT=T,                                   X
               RES=(OWNER_T,SELECT,DBADM_T,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* INSRTAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0051),OBJECT=T,                                   X
               RES=(OWNER_T,INSERT,DBADM_T,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* DELETAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0052),OBJECT=T,                                   X
               RES=(OWNER_T,DELETE,DBADM_T,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* UPDTEAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0053),OBJECT=T,                                   X
               RES=(OWNER_T,UPD_ALL,UPD_COL,DBADM_T,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* REFERAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0054),OBJECT=T,                                   X
               RES=(OWNER_T,REFR_ALL,ALTER,REFR_COL,DBADM_T,SYSCTRL,   X
               SYSADM)
*----------------------------------------------------------------------
* TRIGAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0055),OBJECT=T,                                   X
               RES=(OWNER_T,TRIGGER,ALTER,DBADM_T,SYSCTRL,SYSADM)  @L1A
*----------------------------------------------------------------------
* INDEXAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0056),OBJECT=T,                                   X
               RES=(OWNER_T,INDEX,DBADM_T,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* ALTERAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0061),OBJECT=T,                                   X
               RES=(OWNER_T,ALTER,DBADM_T,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* DROPAUT/COMNTAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0073,0097),OBJECT=T,                              X
               RES=(OWNER_T,DBADM_T,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* COMNTAUT Authority Rules Table for Views
*----------------------------------------------------------------------
         RULE  PRIV=(0097),OBJECT=V,                               @0BAX
               RES=(OWNER_T,SYSCTRL,SYSADM)                        @0BA
*----------------------------------------------------------------------
* LOADAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0075),OBJECT=T,                                   X
               RES=(OWNER_T,LOAD_T,DBADM_T,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* QUALAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0076),OBJECT=T,                                   X
               RES=(DBCTRL_T,DBADM_T,SYSCTRL,SYSADM)               @04C
*----------------------------------------------------------------------
* LOCKAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0098),OBJECT=T,                                   X
               RES=(OWNER_T,SELECT,DBADM_T,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* CRTSYAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0102),OBJECT=T
*----------------------------------------------------------------------
* ALTIXAUT/DRPIXAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0103,0105),OBJECT=T,                              X
               RES=(OWNER_T,DBADM_T,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* DRPSYAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0104),OBJECT=T
*----------------------------------------------------------------------
* CRTVUAUT Authority Rules Table
* NOTE: the conditional logic here is used because we only check   @08A
* the DBADM_T resource if we are called by DB2V7. Also note that   @08A
* if the DBADM_T is moved out of the fourth position, then in the  @08A
* AUTHREQUEST body of the code you will need to adjust the         @08A
* instruction LA R5,8 to be the appropiate offset for the          @08A
* resource.                                                        @08A
*----------------------------------------------------------------------
         AIF   ('&XAPLDBCK' EQ '0').SKIPDB8                        @08A
         RULE  PRIV=(0108),OBJECT=T,                                   X
               RES=(SYSCTRL,SYSADM,DBADM_T)                        @08C
.SKIPDB8 ANOP                                                      @08A
         AIF   ('&XAPLDBCK' NE '0').SKIPDB9                        @08A
         RULE  PRIV=(0108),OBJECT=T,                                   X
               RES=(OWNER_T,SYSCTRL,SYSADM)
.SKIPDB9 ANOP                                                      @08A
*----------------------------------------------------------------------
* CRTVUAUV Authority Rules For Views                               @0BA
*----------------------------------------------------------------------
         RULE  PRIV=(0108),OBJECT=V,                               @0BAX
               RES=(SYSCTRL,SYSADM)                                @0BA
*----------------------------------------------------------------------
* ANYTBAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0233),OBJECT=T,                                   X
               RES=(OWNER_T,REFR_ALL,ALTER,INDEX,SELECT,               X
               INSERT,DELETE,UPD_ALL,DBADM_T,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* RNTABAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0251),OBJECT=T,                                   X
               RES=(OWNER_T,DBMNT_T,DBCTRL_T,DBADM_T,SYSCTRL,SYSADM)
*------------------------------------------------------------------@0BA
* ANYTBAUT Authority Rules Table for Views                         @0BA
*------------------------------------------------------------------@0BA
         RULE  PRIV=(0233),OBJECT=V,                               @0BAX
               RES=(SELECT_V,                                      @0BAX
               INSERT_V,UPD_ALL_V,DELETE_V,SYSCTRL,SYSADM)         @0BA
*------------------------------------------------------------------@0BA
* DELETAUT Authority Rules Table                                   @0BA
*------------------------------------------------------------------@0BA
         RULE  PRIV=(0052),OBJECT=V,                               @0BAX
               RES=(DELETE_V,SYSADM)                               @0BA
*------------------------------------------------------------------@0BA
* DROPAUT Authority Rules Table                                    @0BA
*------------------------------------------------------------------@0BA
         RULE  PRIV=(0073),OBJECT=V,                               @0BAX
               RES=(OWNER_T,SYSCTRL,SYSADM)                        @0BA
*------------------------------------------------------------------@0BA
* UPDTEAUT Authority Rules Table                                   @0BA
*------------------------------------------------------------------@0BA
         RULE  PRIV=(0053),OBJECT=V,                               @0BAX
               RES=(UPD_ALL_V,UPD_COL,SYSADM)                      @0BA
*------------------------------------------------------------------@0BA
* INSRTAUT Authority Rules Table                                   @0BA
*------------------------------------------------------------------@0BA
         RULE  PRIV=(0051),OBJECT=V,                               @0BAX
               RES=(INSERT_V,SYSADM)                               @0BA
*----------------------------------------------------------------------
* SELCTAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0050),OBJECT=V,                               @0BAX
               RES=(SELECT_V,SYSADM)                               @0BA
*----------------------------------------------------------------------
* CHKSTART/CHKSTOP/CHKDSPL/CHKDDF/STRPRAUT/STPPRAUT
*              Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0012,0013,0014,0021,0245,0246),OBJECT=U,          X
               RES=(SYSOPR,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* CRTALAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0015),OBJECT=U,                                   X
               RES=(CREATALI,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* MON1AUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0016),OBJECT=U,                                   X
               RES=(MONITOR1,MONITOR2,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* MON2AUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0017),OBJECT=U,                                   X
               RES=(MONITOR2,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* CHKDISPL/CHKDSPBP/DSPPRAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0062,0112,0247),OBJECT=U,                         X
               RES=(DISPLAY,SYSOPR,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* CRTDBAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0066),OBJECT=U,                                   X
               RES=(CREATDBA,CREATDBC,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* CRTSGAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0067),OBJECT=U,                                   X
               RES=(CREATESG,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* CHKRECOV Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0072),OBJECT=U,                                   X
               RES=(RECOVER,SYSOPR,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* CHKSUBSY Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0080),OBJECT=U,                                   X
               RES=(STOPALL,SYSOPR,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* CHKTRACE Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0084),OBJECT=U,                                   X
               RES=(TRACE,SYSOPR,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* SYSAAUTH Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0085),OBJECT=U,                                   X
               RES=(SYSADM)
*----------------------------------------------------------------------
* SYSOAUTH/CHKALTBP Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0086,0113),OBJECT=U,                              X
               RES=(SYSOPR,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* BINDAAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0088),OBJECT=U,                                   X
               RES=(BINDADD,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* CRTDCAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0092),OBJECT=U,                                   X
               RES=(CREATDBC,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* CHKBSDS Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0093),OBJECT=U,                                   X
               RES=(BSDS,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* STOAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0107),OBJECT=U,                                   X
               RES=(STOSPACE,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* SYSCAUTH Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0224),OBJECT=U,                                   X
               RES=(SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* BNDAGAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0227),OBJECT=U,                                   X
               RES=(BINDAG_P,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* ARCHAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0231),OBJECT=U,                                   X
               RES=(ARCHIVE,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* SARCHAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0243),OBJECT=U,                                   X
               RES=(ARCHIVE,SYSOPR,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* DARCHAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0244),OBJECT=U,                                   X
               RES=(DISPLAY,ARCHIVE,SYSOPR,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* CRTTMAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE  PRIV=(0248),OBJECT=U,                                   X
               RES=(CREATTMT,CREATT_U,SYSCTRL,SYSADM)
*----------------------------------------------------------------------
* USAGEAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE PRIV=(0263),OBJECT=E,                                @L1AX
               RES=(OWNER_E,USE_E,SYSADM)                          @L1A
*----------------------------------------------------------------------
* STRTAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE PRIV=(0265),OBJECT=F,                                @L1AX
               RES=(OWNER_F,SYSOPR,SYSCTRL,SYSADM)                 @L1A
*----------------------------------------------------------------------
* STPAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE PRIV=(0266),OBJECT=F,                                @L1AX
               RES=(OWNER_F,SYSOPR,SYSCTRL,SYSADM)                 @L1A
*----------------------------------------------------------------------
* DISPLAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE PRIV=(0267),OBJECT=F,                                @L1AX
               RES=(OWNER_F,DISPLAY_F,SYSOPR,SYSCTRL,              @L1AX
               SYSADM)                                             @L1A
*----------------------------------------------------------------------
* CHKEXEC Authority Rules Table
*----------------------------------------------------------------------
         RULE PRIV=(0064),OBJECT=F,                                @L1AX
               RES=(EXECUT_F,SYSADM)                               @L1A
*----------------------------------------------------------------------
* CRTINAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE PRIV=(0261),OBJECT=M,                                @L1AX
               RES=(CREATEIN_M,SYSCTRL,SYSADM)                     @L1A
*----------------------------------------------------------------------
* ALTINAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE PRIV=(0252),OBJECT=M,                                @L1AX
               RES=(OWNERM_M,ALTERIN,SYSCTRL,SYSADM)               @L1A
*----------------------------------------------------------------------
* DRPINAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE PRIV=(0262),OBJECT=M,                                @L1AX
               RES=(OWNERM_M,DROPIN,SYSCTRL,SYSADM)                @L1A
*----------------------------------------------------------------------
* CMNTAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE PRIV=(0097),OBJECT=M,                                @L1AX
               RES=(OWNERM_M,ALTERIN,SYSCTRL,SYSADM)               @L1A
*----------------------------------------------------------------------
* QUALAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE PRIV=(0076),OBJECT=M,                                @L1AX
               RES=(SYSCTRL,SYSADM)                                @L1A
*----------------------------------------------------------------------
* STRTAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE PRIV=(0265),OBJECT=O,                                @L1AX
               RES=(OWNER_O,SYSOPR,SYSCTRL,SYSADM)                 @L1A
*----------------------------------------------------------------------
* STPAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE PRIV=(0266),OBJECT=O,                                @L1AX
               RES=(OWNER_O,SYSOPR,SYSCTRL,SYSADM)                 @L1A
*----------------------------------------------------------------------
* DISPLAUT Authority Rules Table
*----------------------------------------------------------------------
         RULE PRIV=(0267),OBJECT=O,                                @L1AX
               RES=(OWNER_O,DISPLAY_O,SYSOPR,SYSCTRL,              @L1AX
               SYSADM)                                             @L1A
*----------------------------------------------------------------------
* CHKEXEC Authority Rules Table
*----------------------------------------------------------------------
         RULE PRIV=(0064),OBJECT=O,                                @L1AX
               RES=(EXECUT_O,SYSADM)                               @L1A
*----------------------------------------------------------------------
* USAGEAUTJ Authority Rules Table
*----------------------------------------------------------------------
         RULE PRIV=(0263),OBJECT=J,                                @08AX
               RES=(OWNER_J,USE_J,SYSADM)                          @08A
*
IRR@TRUL_LEN   EQU   ((*-IRR@TRUL+7)/8*8)
         EJECT
         TITLE 'IRR@TRES - TRES'
**********************************************************************
* $TRESDESC                                                          *
**********************************************************************
*                                                                    *
*01* MODULE NAME:                                                    *
*      IRR@XACS                                                      *
*                                                                    *
*02*   CSECT NAME:                                                   *
*        IRR@TRES                                                    *
*                                                                    *
*                                                                    *
*01* DESCRIPTIVE NAME:                                               *
*      RACF/DB2 External Security Module - Resource Table            *
*                                                                    *
*                                                                    *
*01* FUNCTION:                                                       *
*      There is one Resource Table and it contains an entry for      *
*      each unique "resource" (some entries from the Rule Table      *
*      point to the same entry in the resource table).  Each entry   *
*      will contain enough information to perform implicit privilege *
*      checking and/or complete a RACROUTE REQUEST=FASTAUTH.         *
*                                                                    *
*      Each entry contains:                                          *
*      1) Type of entry:                                             *
*         > Object Entry                                             *
*         > Administrative Authority entry (ADM class)               *
*         > Owner Entry                                              *
*      2) Class Abbreviation                                         *
*      3) Resource Name                                              *
*         > Object Name Qualifier offsets                            *
*         > Column Qualifier offset                                  *
*         > DB2 Authority Qualifier                                  *
*         > Access Authority (READ, UPDATE, ALTER or CONTROL)        *
*      3) Object Owner offset (if any)                               *
*                                                                    *
*      When the resource table is defined the resource name and      *
*      object owner are not known.  As a result, the values for the  *
*      object name qualifiers, column qualifer and object owner      *
*      will be offsets into the XAPL.  These offsets will be used    *
*      at run time by the Authorization Exit to locate the object    *
*      qualifiers, column qualifier and object owner                 *
*                                                                    *
*      The Resource Table and entries are expanded by the RESOURCE   *
*      macro and mapped by RESDSECT.                                 *
*                                                                    *
*      For an illustration of the Authorization tables see IRR@TPRV. *
*                                                                    *
**********************************************************************
         EJECT
*----------------------------------------------------------------------
* $TRESCODE - IRR@TRES Resource Table
*----------------------------------------------------------------------
IRR@TRES CSECT
IRR@TRES RMODE ANY
*----------------------------------------------------------------------
* DB2/RACF RESOURCE TABLE - HEADER
*
* THIS TABLE CONTAINS ONE CSECT FOR EACH RESOURCE SUPPORTED BY
* THE DB2/RACF AUTHORIZATION EXIT.  EACH CSECT CONTAINS THE
* RESOURCE CLASS AND RESOURCE QUALIFIERS USED TO CONSTRUCT THE
* RESOURCE NAME
*----------------------------------------------------------------------
         DS    0F                   BOUNDRY ALIGNMENT
         DC    CL8'IRR@TRES'        EYECATCHER
         DC    CL8' &SERVICELEVEL'  FMID
         DC    CL8'&SYSDATE'        DATE
         DC    CL8'&SYSTIME'        TIME
*----------------------------------------------------------------------
* RESOURCE DEFINITIONS
*----------------------------------------------------------------------
      RESOURCE NAME=DBADM_D,                                           +
               AUTHORITY=DBADM,                                        +
               CLASS=ADM,                                              +
               OBJECT=(XAPLOBJN)
      RESOURCE NAME=DBADM_T,                                           +
               AUTHORITY=DBADM,                                        +
               CLASS=ADM,                                              +
               OBJECT=(XAPLREL2)
      RESOURCE NAME=DBADM_R,                                           +
               AUTHORITY=DBADM,                                        +
               CLASS=ADM,                                              +
               OBJECT=(XAPLOWNQ)
      RESOURCE NAME=DBADM_U,                                           +
               AUTHORITY=DBADM,                                        +
               CLASS=ADM
      RESOURCE NAME=DBCTRL_D,                                          +
               AUTHORITY=DBCTRL,                                       +
               CLASS=ADM,                                              +
               OBJECT=(XAPLOBJN)
      RESOURCE NAME=DBCTRL_T,                                          +
               AUTHORITY=DBCTRL,                                       +
               CLASS=ADM,                                              +
               OBJECT=(XAPLREL2)
      RESOURCE NAME=DBCTRL_U,                                          +
               AUTHORITY=DBCTRL,                                       +
               CLASS=ADM
      RESOURCE NAME=DBMNT_D,                                           +
               AUTHORITY=DBMAINT,                                      +
               CLASS=ADM,                                              +
               OBJECT=(XAPLOBJN)
      RESOURCE NAME=DBMNT_T,                                           +
               AUTHORITY=DBMAINT,                                      +
               CLASS=ADM,                                              +
               OBJECT=(XAPLREL2)
      RESOURCE NAME=DBMNT_U,                                           +
               AUTHORITY=DBMAINT,                                      +
               CLASS=ADM
      RESOURCE NAME=SYSADM,                                            +
               AUTHORITY=SYSADM,                                       +
               CLASS=ADM
      RESOURCE NAME=SYSCTRL,                                           +
               AUTHORITY=SYSCTRL,                                      +
               CLASS=ADM
      RESOURCE NAME=SYSOPR,                                            +
               AUTHORITY=SYSOPR,                                       +
               CLASS=ADM
      RESOURCE NAME=PACKAD_K,                                          +
               AUTHORITY=PACKADM,                                      +
               CLASS=ADM,                                              +
               OBJECT=(XAPLOWNQ)
      RESOURCE NAME=PACKAD_C,                                          +
               AUTHORITY=PACKADM,                                      +
               CLASS=ADM,                                              +
               OBJECT=(XAPLOBJN)
      RESOURCE NAME=CREATT_D,                                          +
               AUTHORITY=CREATETAB,                                    +
               CLASS=DB,                                               +
               OBJECT=(XAPLOBJN)
      RESOURCE NAME=CREATT_U,                                          +
               AUTHORITY=CREATETAB,                                    +
               CLASS=DB
      RESOURCE NAME=CREATETS,                                          +
               AUTHORITY=CREATETS,                                     +
               CLASS=DB,                                               +
               OBJECT=(XAPLOBJN)
      RESOURCE NAME=DISPLYDB,                                          +
               AUTHORITY=DISPLAYDB,                                    +
               CLASS=DB,                                               +
               OBJECT=(XAPLOBJN)
      RESOURCE NAME=DROP,                                              +
               AUTHORITY=DROP,                                         +
               CLASS=DB,                                               +
               OBJECT=(XAPLOBJN)
      RESOURCE NAME=IMAGCOPY,                                          +
               AUTHORITY=IMAGCOPY,                                     +
               CLASS=DB,                                               +
               OBJECT=(XAPLOBJN)
      RESOURCE NAME=LOAD_D,                                            +
               AUTHORITY=LOAD,                                         +
               CLASS=DB,                                               +
               OBJECT=(XAPLOBJN)
      RESOURCE NAME=LOAD_T,                                            +
               AUTHORITY=LOAD,                                         +
               CLASS=DB,                                               +
               OBJECT=(XAPLREL2)
      RESOURCE NAME=REORG,                                             +
               AUTHORITY=REORG,                                        +
               CLASS=DB,                                               +
               OBJECT=(XAPLOBJN)
      RESOURCE NAME=RECOVRDB,                                          +
               AUTHORITY=RECOVERDB,                                    +
               CLASS=DB,                                               +
               OBJECT=(XAPLOBJN)
      RESOURCE NAME=REPAIR,                                            +
               AUTHORITY=REPAIR,                                       +
               CLASS=DB,                                               +
               OBJECT=(XAPLOBJN)
      RESOURCE NAME=STARTDB,                                           +
               AUTHORITY=STARTDB,                                      +
               CLASS=DB,                                               +
               OBJECT=(XAPLOBJN)
      RESOURCE NAME=STATS,                                             +
               AUTHORITY=STATS,                                        +
               CLASS=DB,                                               +
               OBJECT=(XAPLOBJN)
      RESOURCE NAME=STOPDB,                                            +
               AUTHORITY=STOPDB,                                       +
               CLASS=DB,                                               +
               OBJECT=(XAPLOBJN)
      RESOURCE NAME=DISPLAY,                                           +
               AUTHORITY=DISPLAY,                                      +
               CLASS=SM
      RESOURCE NAME=BINDAG_K,                                          +
               AUTHORITY=BINDAGENT,                                    +
               CLASS=SM,                                               +
               OBJECT=(XAPLREL1)
      RESOURCE NAME=BINDAG_P,                                          +
               AUTHORITY=BINDAGENT,                                    +
               CLASS=SM,                                               +
               OBJECT=(XAPLOWNQ)
      RESOURCE NAME=BINDADD,                                           +
               AUTHORITY=BINDADD,                                      +
               CLASS=SM
      RESOURCE NAME=BSDS,                                              +
               AUTHORITY=BSDS,                                         +
               CLASS=SM
      RESOURCE NAME=CREATDBA,                                          +
               AUTHORITY=CREATEDBA,                                    +
               CLASS=SM
      RESOURCE NAME=CREATDBC,                                          +
               AUTHORITY=CREATEDBC,                                    +
               CLASS=SM
      RESOURCE NAME=CREATESG,                                          +
               AUTHORITY=CREATESG,                                     +
               CLASS=SM
      RESOURCE NAME=RECOVER,                                           +
               AUTHORITY=RECOVER,                                      +
               CLASS=SM
      RESOURCE NAME=STOPALL,                                           +
               AUTHORITY=STOPALL,                                      +
               CLASS=SM
      RESOURCE NAME=TRACE,                                             +
               AUTHORITY=TRACE,                                        +
               CLASS=SM
      RESOURCE NAME=STOSPACE,                                          +
               AUTHORITY=STOSPACE,                                     +
               CLASS=SM
      RESOURCE NAME=MONITOR1,                                          +
               AUTHORITY=MONITOR1,                                     +
               CLASS=SM
      RESOURCE NAME=MONITOR2,                                          +
               AUTHORITY=MONITOR2,                                     +
               CLASS=SM
      RESOURCE NAME=CREATALI,                                          +
               AUTHORITY=CREATEALIAS,                                  +
               CLASS=SM
      RESOURCE NAME=ARCHIVE,                                           +
               AUTHORITY=ARCHIVE,                                      +
               CLASS=SM
      RESOURCE NAME=CREATTMT,                                          +
               AUTHORITY=CREATETMTAB,                                  +
               CLASS=SM
      RESOURCE NAME=BIND_P,                                            +
               AUTHORITY=BIND,                                         +
               CLASS=PN,                                               +
               OBJECT=(XAPLOBJN)
      RESOURCE NAME=BIND_K,                                            +
               AUTHORITY=BIND,                                         +
               CLASS=PK,                                               +
               OBJECT=(XAPLOWNQ,XAPLOBJN)
      RESOURCE NAME=EXECUT_P,                                          +
               AUTHORITY=EXECUTE,                                      +
               CLASS=PN,                                               +
               OBJECT=(XAPLOBJN)
      RESOURCE NAME=EXECUT_K,                                          +
               AUTHORITY=EXECUTE,                                      +
               CLASS=PK,                                               +
               OBJECT=(XAPLOWNQ,XAPLOBJN)
      RESOURCE NAME=COPY,                                              +
               AUTHORITY=COPY,                                         +
               CLASS=PK,                                               +
               OBJECT=(XAPLOWNQ,XAPLOBJN)
      RESOURCE NAME=OWNER_P,                                       @L2A+
               OWNER=XAPLOWNQ                                      @L2A
      RESOURCE NAME=OWNER_K,                                       @L2A+
               OWNER=XAPLREL1                                      @L2A
      RESOURCE NAME=USE_B,                                             +
               AUTHORITY=USE,                                          +
               CLASS=BP,                                               +
               OBJECT=(XAPLOBJN)
      RESOURCE NAME=USE_R,                                             +
               AUTHORITY=USE,                                          +
               CLASS=TS,                                               +
               OBJECT=(XAPLOWNQ,XAPLOBJN)                          @06C
      RESOURCE NAME=USE_S,                                             +
               AUTHORITY=USE,                                          +
               CLASS=SG,                                               +
               OBJECT=(XAPLOBJN)
      RESOURCE NAME=CREATEIN,                                          +
               AUTHORITY=CREATEIN,                                     +
               CLASS=CL,                                               +
               OBJECT=(XAPLOBJN)
      RESOURCE NAME=ALTER,                                             +
               AUTHORITY=ALTER,                                        +
               CLASS=TB,                                               +
               OBJECT=(XAPLOWNQ,XAPLOBJN),                             +
               OWNER=XAPLOWNQ
      RESOURCE NAME=INDEX,                                             +
               AUTHORITY=INDEX,                                        +
               CLASS=TB,                                               +
               OBJECT=(XAPLOWNQ,XAPLOBJN),                             +
               OWNER=XAPLOWNQ
      RESOURCE NAME=SELECT,                                            +
               AUTHORITY=SELECT,                                       +
               CLASS=TB,                                               +
               OBJECT=(XAPLOWNQ,XAPLOBJN),                             +
               OWNER=XAPLOWNQ
      RESOURCE NAME=SELECT_V,                                      @0BA+
               AUTHORITY=SELECT,                                   @0BA+
               CLASS=TB,                                           @0BA+
               OBJECT=(XAPLOWNQ,XAPLOBJN)                          @0BA
      RESOURCE NAME=INSERT,                                            +
               AUTHORITY=INSERT,                                       +
               CLASS=TB,                                               +
               OBJECT=(XAPLOWNQ,XAPLOBJN),                             +
               OWNER=XAPLOWNQ
      RESOURCE NAME=INSERT_V,                                      @0BA+
               AUTHORITY=INSERT,                                   @0BA+
               CLASS=TB,                                           @0BA+
               OBJECT=(XAPLOWNQ,XAPLOBJN)                          @0BA
      RESOURCE NAME=DELETE,                                            +
               AUTHORITY=DELETE,                                       +
               CLASS=TB,                                               +
               OBJECT=(XAPLOWNQ,XAPLOBJN),                             +
               OWNER=XAPLOWNQ
      RESOURCE NAME=DELETE_V,                                      @0BA+
               AUTHORITY=DELETE,                                   @0BA+
               CLASS=TB,                                           @0BA+
               OBJECT=(XAPLOWNQ,XAPLOBJN)                          @0BA
      RESOURCE NAME=UPD_ALL,                                           +
               AUTHORITY=UPDATE,                                       +
               CLASS=TB,                                               +
               OBJECT=(XAPLOWNQ,XAPLOBJN),                             +
               OWNER=XAPLOWNQ
      RESOURCE NAME=UPD_ALL_V,                                     @0BA+
               AUTHORITY=UPDATE,                                   @0BA+
               CLASS=TB,                                           @0BA+
               OBJECT=(XAPLOWNQ,XAPLOBJN)                          @0BA
      RESOURCE NAME=UPD_COL,                                           +
               AUTHORITY=UPDATE,                                       +
               CLASS=TB,                                               +
               OBJECT=(XAPLOWNQ,XAPLOBJN),                             +
               COLUMN=XAPLREL1
      RESOURCE NAME=REFR_ALL,                                          +
               AUTHORITY=REFERENCES,                                   +
               CLASS=TB,                                               +
               OBJECT=(XAPLOWNQ,XAPLOBJN),                             +
               OWNER=XAPLOWNQ
      RESOURCE NAME=TRIGGER,                                       @L1A+
               AUTHORITY=TRIGGER,                                  @L1A+
               CLASS=TB,                                           @L1A+
               OBJECT=(XAPLOWNQ,XAPLOBJN),                         @L1A+
               OWNER=XAPLOWNQ                                      @L1A
      RESOURCE NAME=REFR_COL,                                          +
               AUTHORITY=REFERENCES,                                   +
               CLASS=TB,                                               +
               OBJECT=(XAPLOWNQ,XAPLOBJN),                             +
               COLUMN=XAPLREL1
      RESOURCE NAME=OWNER_T,                                           +
               OWNER=XAPLOWNQ
      RESOURCE NAME=USE_E,                                         @L1A+
               AUTHORITY=USAGE,                                    @L1A+
               CLASS=UT,                                           @L1A+
               OBJECT=(XAPLOWNQ,XAPLOBJN),                         @L1A+
               OWNER=XAPLREL1                                      @L1A
      RESOURCE NAME=OWNER_E,                                       @L1A+
               OWNER=XAPLREL1                                      @L1A
      RESOURCE NAME=OWNER_F,                                       @L1A+
               OWNER=XAPLREL1                                      @L1A
      RESOURCE NAME=EXECUT_F,                                      @L1A+
               AUTHORITY=EXECUTE,                                  @L1A+
               CLASS=UF,                                           @L1A+
               OBJECT=(XAPLOWNQ,XAPLOBJN),                         @L1A+
               OWNER=XAPLREL1                                      @L1A
      RESOURCE NAME=OWNERM_M,                                      @L1A+
               OWNER=XAPLREL1                                      @L1A
      RESOURCE NAME=CREATEIN_M,                                    @L1A+
               AUTHORITY=CREATEIN,                                 @L1A+
               CLASS=SC,                                           @L1A+
               OBJECT=(XAPLOBJN)                                   @L1A
      RESOURCE NAME=ALTERIN,                                       @L1A+
               AUTHORITY=ALTERIN,                                  @L1A+
               CLASS=SC,                                           @L1A+
               OBJECT=(XAPLOWNQ,XAPLOBJN),                         @L1A+
               OWNER=XAPLREL1                                      @L1A
      RESOURCE NAME=DROPIN,                                        @L1A+
               AUTHORITY=DROPIN,                                   @L1A+
               CLASS=SC,                                           @L1A+
               OBJECT=(XAPLOWNQ,XAPLOBJN),                         @L1A+
               OWNER=XAPLREL1                                      @L1A
      RESOURCE NAME=OWNER_O,                                       @L1A+
               OWNER=XAPLREL1                                      @L1A
      RESOURCE NAME=EXECUT_O,                                      @L1A+
               AUTHORITY=EXECUTE,                                  @L1A+
               CLASS=SP,                                           @L1A+
               OBJECT=(XAPLOWNQ,XAPLOBJN),                         @L1A+
               OWNER=XAPLREL1                                      @L1A
      RESOURCE NAME=DISPLAY_O,                                     @L1A+
               AUTHORITY=DISPLAY,                                  @L1A+
               CLASS=SP,                                           @L1A+
               OBJECT=(XAPLOWNQ,XAPLOBJN),                         @L1A+
               OWNER=XAPLREL1                                      @L1A
      RESOURCE NAME=DISPLAY_F,                                     @L1A+
               AUTHORITY=DISPLAY,                                  @L1A+
               CLASS=UF,                                           @L1A+
               OBJECT=(XAPLOWNQ,XAPLOBJN),                         @L1A+
               OWNER=XAPLREL1                                      @L1A
      RESOURCE NAME=USE_J,                                         @08A+
               AUTHORITY=USAGE,                                    @08A+
               CLASS=JR,                                           @08A+
               OBJECT=(XAPLOWNQ,XAPLOBJN),                         @08A+
               OWNER=XAPLREL1                                      @08A
      RESOURCE NAME=OWNER_J,                                       @08A+
               OWNER=XAPLREL1                                      @08A
*
*                                                                 1@0CD
         EJECT
**********************************************************************
* TRTAB                                                              *
**********************************************************************
*       |-------------------------------------------------------------
*----------------------------------------------------------------------
* Table to convert blanks (x'40') to underscores (x'6D')
*----------------------------------------------------------------------
TRANSTAB  DS  0CL256                                               @08C
          DC  X'000102030405060708090A0B0C0D0E0F'     0 -  15      @05A
          DC  X'101112131415161718191A1B1C1D1E1F'    16 -  31      @05A
          DC  X'202122232425262728292A2B2C2D2E2F'    32 -  47      @05A
          DC  X'303132333435363738393A3B3C3D3E3F'    48 -  63      @05A
          DC  X'6D'                                  64 (X'40')    @05A
          DC  X'4142434445464748494A4B4C4D4E4F'      65 -  79      @05A
          DC  X'505152535455565758595A5B5C5D5E5F'    80 -  95      @05A
          DC  X'606162636465666768696A6B6C6D6E6F'    96 - 111      @05A
          DC  X'707172737475767778797A7B7C7D7E7F'   112 - 127      @05A
          DC  X'808182838485868788898A8B8C8D8E8F'   128 - 143      @05A
          DC  X'909192939495969798999A9B9C9D9E9F'   144 - 159      @05A
          DC  X'A0A1A2A3A4A5A6A7A8A9AAABACADAEAF'   160 - 175      @05A
          DC  X'B0B1B2B3B4B5B6B7B8B9BABBBCBDBEBF'   176 - 191      @05A
          DC  X'C0C1C2C3C4C5C6C7C8C9CACBCCCDCECF'   192 - 207      @05A
          DC  X'D0D1D2D3D4D5D6D7D8D9DADBDCDDDEDF'   208 - 223      @05A
          DC  X'E0E1E2E3E4E5E6E7E8E9EAEBECEDEEEF'   224 - 239      @05A
          DC  X'F0F1F2F3F4F5F6F7F8F9FAFBFCFDFEFF'   240 - 255      @05A
IRR@TRES_LEN   EQU   ((*-IRR@TRES+7)/8*8)                         1@0CM
         EJECT
**********************************************************************
         TITLE 'IRR@TOBJ - TOBJ'
**********************************************************************
* $TOBJDESC                                                          *
**********************************************************************
*                                                                    *
*01* MODULE NAME:                                                    *
*      IRR@XACS                                                      *
*                                                                    *
*02*   CSECT NAME:                                                   *
*        IRR@TOBJ                                                    *
*                                                                    *
*                                                                    *
*01* DESCRIPTIVE NAME:                                               *
*      RACF/DB2 External Security Module - Object Table              *
*                                                                    *
*                                                                    *
*01* FUNCTION:                                                       *
*      Describes the table entries for each DB2 object type. Each    *
*      entry contains the object type and the object abbreviation    *
*      for building the classname.                                   *
*                                                                    *
*      The object table is used by the initialization and            *
*      termination functions (XAPLFUNC=1|3) to determine the set     *
*      RACF general resource classes to RACLIST or unRACLIST.        *
*                                                                    *
*      The Object Table does not contain the complete class name.    *
*      Instead it contains a two character abbreviation that is      *
*      used to build the class name.  The exit will dynamically      *
*      build the class names (using the BLD_CLASS macro) according   *
*      to the Classification Models specified by &CLASSOPT.          *
*                                                                    *
*      The Object Table entries are mapped by the OBJDSECT DSECT.    *
*                                                                    *
**********************************************************************
         EJECT
*----------------------------------------------------------------------
* $TOBJCODE - IRR@TOBJ Object Table
*----------------------------------------------------------------------
IRR@TOBJ CSECT
IRR@TOBJ RMODE ANY
*----------------------------------------------------------------------
* DB2/RACF Object Table - Header
*----------------------------------------------------------------------
         DS    0F                   Boundry alignment
         DC    CL8'IRR@TOBJ'        Eyecatcher
         DC    CL8' &SERVICELEVEL'  FMID
         DC    CL8'&SYSDATE'        Date
         DC    CL8'&SYSTIME'        Time
         DC    Y(IRR@TOBJ_NUM)      Number of object types
         DS    CL2                  reserved
*----------------------------------------------------------------------
* DB2/RACF Object Table - Entries
*----------------------------------------------------------------------
* Database
         DC    CL1'D'               Object Type D - DATABASE
         DC    CL3'DB'              Object abbreviation for class name
* Package
         DC    CL1'K'               Object Type K - PACKAGE
         DC    CL3'PK'              Object abbreviation for class name
* Plan
         DC    CL1'P'               Object Type P - PLAN
         DC    CL3'PN'              Object abbreviation for class name
* Bufferpool
         DC    CL1'B'               Object Type B - BUFFERPOOL
         DC    CL3'BP'              Object abbreviation for class name
* Collection
         DC    CL1'C'               Object Type C - COLLECTION
         DC    CL3'CL'              Object abbreviation for class name
* Table Space
         DC    CL1'R'               Object Type R - TABLESPACE
         DC    CL3'TS'              Object abbreviation for class name
* Storage Group
         DC    CL1'S'               Object Type S - STO GROUP
         DC    CL3'SG'              Object abbreviation for class name
* Table/Index/View
         DC    CL1'T'               Object Type T - TABLE
         DC    CL3'TB'              Object abbreviation for class name
* System
         DC    CL1'U'               Object Type U - System
         DC    CL3'SM'              Object abbreviation for class name
* Schema
         DC    CL1'M'           Object Type M - Schema             @L1A
         DC    CL3'SC'          Object abbreviation for class name @L1A
* User defined distinct type
         DC    CL1'E'           Object Type E - UDT                @L1A
         DC    CL3'UT'          Object abbreviation for class name @L1A
* User defined function
         DC    CL1'F'           Object Type F - UDF                @L1A
         DC    CL3'UF'          Object abbreviation for class name @L1A
* Stored procedure
         DC    CL1'O'           Object Type O - Stored procedure   @L1A
         DC    CL3'SP'          Object abbreviation for class name @L1A
* JAR
         DC    CL1'J'           Object Type J - JAR                @08A
         DC    CL3'JR'          Object abbreviation for class name @08A
*
IRR@TOBJ_LEND  EQU   ((*-IRR@TOBJ+7)/8*8)                          @0CC
IRR@TOBJ_LEN   EQU   ((*-IRR@TOBJ+3)/4*4)                          @08C
IRR@TOBJ_NUM   EQU   (IRR@TOBJ_LEN-OBJHDLEN)/OBJENTLN
         END   DSNX@XAC

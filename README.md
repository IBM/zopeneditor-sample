# Sample COBOL, PL/I, HLASM, and REXX files for the "IBM Z® Open Editor" for COBOL, PL/I, HLASM, and REXX


This repository provides sample COBOL, PL/I, HLASM, and REXX programs, along with JCL and data files to compile and run them.

These examples are provided to allow you to not only experience the [IBM Z® Open Editor](https://marketplace.visualstudio.com/items?itemName=IBM.zopeneditor), but also in conjunction with the [Zowe VS Code Extension](https://marketplace.visualstudio.com/items?itemName=Zowe.vscode-extension-for-zowe), experience the powerful capabilities for IBM z/OS development and processing.

The sample applications consist of the following files:

## COBOL Examples

- COBOL programs: `SAM1`, `SAM2`, and `SAM1LIB`
  - `SAM1LIB` is a copy of `SAM1` but shows resolving copybooks with the local and MVS library options
- COPYBOOKS: `CUSTCOPY` and `TRANREC`
- Libraries COPYBOOKS: `DATETIME` (local under COPYLIB) and `REPTTOTL` (MVS under COPYLIB-MVS)
- Data source files: `SAMPLE.CUSTFILE` and `SAMPLE.TRANFILE`
- JCL members that set up and run the application: `ALLOCATE` and `RUN`.
  - _Please Note - the JCL files are to be used as templates, you may need to update the compiler library name and you will need to update the `HLQ` parm with your TSO user id_

`SAM1` reads in both the `CUSTFILE` and `TRANFILE` data files, then performs different actions on the `CUSTFILE` based on transactions from `TRANFILE`. Valid transactions are `ADD`, `UPDATE`, and `DELETE`. When an `UPDATE` transaction is processed, `SAM1` calls `SAM2` to perform the requested update. At the end of processing the `TRANFILE`, `SAM1` generates a report on the transactions processed and produces an updated `CUSTFILE`.

`SAM2` also includes some base code in place for `CRUNCH` transactions which are mentioned in the Use Case below.

The `ALLOCATE.jcl` file will allocate the necessary data sets on the MVS host that need to be in place prior to using the `Zowe CLI` commands to copy the files from your local workspace into the pre-allocated data sets and to run the application.  The `RUN.jcl` will compile, link, and run the programs.

The files created with the `ALLOCATE.jcl` are:

```ascii
USER1.SAMPLE.COBOL
USER1.SAMPLE.COBCOPY
USER1.SAMPLE.COPYLIB
USER1.SAMPLE.OBJ
USER1.SAMPLE.LOAD
USER1.SAMPLE.CUSTFILE
USER1.SAMPLE.TRANFILE
```

The application creates a new `CUSTFILE` and produces a customer report in `USER1.SAMPLE.CUSTRPT`.

### A Sample COBOL Use Case

The repository for these example files also has another branch called `Tutorial-Complete` which contains files that are the result of the following use case.  Using VS Code's GIT capabilities, you can switch branches to `Tutorial-Complete` where you will notice some new files.

A sample use case might be that you have received requirements to enhance the Daily Customer File Update Report to include the total number of customers as well as information regarding "Crunch" transactions.  A "Crunch" transaction is a request to calculate the average monthly order revenue for a specific customer.  The current daily report simply displays the first 80 bytes of each transaction record as well as total counts for each type of transaction.

In looking at the files, you will notice a new COPYBOOK, `SAM2PARM`, which was created to contain the parameters necessary for `SAM1.cbl` to pass to `SAM2.cbl` in order to process a new transaction type.  There is also a new `TRANFILE` which contains a record for the new `CRUNCH` transaction.

## PL/I Examples

- PL/I programs: `PSAM1`, `PSAM2`, and `PSAM1LIB`
  - `PSAM1LIB` is a copy of `PSAM1` but shows resolving includes with the local and MVS library options
- INCLUDES: `BALSTATS` and `CUSTPLI`
- Libraries INCLUDES: `DATETIME` (local under INCLUDELIB) and `REPTTOTL` (MVS under INCLUDELIB-MVS)
- Data source files: `SAMPLE.PLI.TRANFILE` and `SAMPLE.PLI.CUSTFILE`
- JCL members that set up and run the application: `PLIALLOC` and `RUNPSAM1`.
  - _Please Note - the JCL files are to used as templates, you may need to update the compiler library name and you will need to update the `HLQ` parm with your TSO user id_

`PSAM1` reads in both the `PLI.CUSTFILE` and `PLI.TRANFILE` data files, then produces a report with customer information and a Totals summary section. Valid transactions are `PRINT` and `TOTALS`. A `PRINT` transaction prints the Customer records to the Customer section of the report. When `PSAM1` reads in a `TOTALS` transaction, it generates the Totals Report section.

`PSAM2` generates running totals from amounts passed in from `PSAM1`.

The `PLIALLOC.jcl` file will allocate the necessary data sets on the MVS host that need to be in place prior to using the Zowe CLI commands to copy the files from your local workspace into the pre-allocated data sets and to run the application.  The `RUNPSAM1.jcl` will compile, link, and run the programs.

The files created with the `PLIALLOC.jcl` are:

```ascii
USER1.SAMPLE.PLIOBJ
USER1.SAMPLE.PLILOAD
USER1.SAMPLE.PLI
USER1.SAMPLE.PLINC
USER1.SAMPLE.PLI.INCLLIB
USER1.SAMPLE.PLI.CUSTFILE
USER1.SAMPLE.PLI.TRANFILE
```

The application creates a report, `USER1.SAMPLE.PLI.CUSTRPT`.

### A Sample PL/I Use Case

A sample use case for the PL/I programs might be that `PSAM1` needs to process a new type of Customer record called a Product record and generate a new line for Service Calls in the Totals Report section.  You could accomplish this by creating a new program, `PSAM3` to process these new records and produce the product statistics needed on the report.

Again, in the `Tutorial-Complete` branch, notice the new program `PSAM3`, the new Include `PRODSTATS` which is used for the data being passed between `PSAM1` and `PSAM3`.

## HLASM Examples

- HLASM programs: `ASAM1` and `IRR@XACS`
  - _`IRR@XACS` is included to provide a better example for the Outline View, it can be found in the `SYS1.SAMPLIB` on the z host_

- Copybook (in ASMCOPY): `REGISTRS`
- Data source file: `SAMPLE.ASM.FILEIN`
- JCL members that set up and run the application: `ASMALLOC` and `RUNASAM1`.
  - _Please Note - the JCL files are to used as templates, you may need to update the compiler library, the z/OS Macro library, the Assembler Macro library, and the Assembler Modgen library names.  You will also need to update the `HLQ` parm with your TSO user id_

`ASAM1` reads in a record from the `SAMPLE.ASM.FILEIN` dataset.  It will then write it to the output file `ASM.FILEOUT` as well as the record number and column number records.

The `ASMALLOC.jcl` file will allocate the necessary data sets on the MVS host that need to be in place prior to using the Zowe CLI commands to copy the files from your local workspace into the pre-allocated data sets and to run the application.  The `RUNASAM1.jcl` will compile, link, and run the programs.

The files created with the `ASMALLOC.jcl` are:

```ascii
USER1.SAMPLE.ASMOBJ
USER1.SAMPLE.ASMLOAD
USER1.SAMPLE.ASM
USER1.SAMPLE.ASMCOPY
USER1.SAMPLE.ASM.FILEIN
```

The application creates a file, `USER1.SAMPLE.ASM.FILEOUT`.

### A Sample HLASM Use Case

A sample use case for the ASM programs might be that `ASAM1` needs to also write the character string in hexadecimal format.  You could accomplish this by creating a new program, `ASAM2` to translate the string into hex format and return to `ASAM1`.

`ASAM2` can be found in the `Tutorial-Complete` branch as well as an updated `ASAM1` with the necessary code to complete the use case.

## REXX Examples

- REXX program: `RSAM1`
- Data source files: `SAMPLE.REXX.FILEIN1` and `SAMPLE.REXX.FILEIN2`
- JCL member to allocate files necessary to run the exec: `REXALLOC`.
  - _Please Note - You will need to update the `HLQ` parm with your TSO user id_

`RSAM1` reads in the records from the `SAMPLE.REXX.FILEIN1` and `SAMPLE.REXX.FILEIN2` data sets.  It will then write them to the output file `SAMPLE.REXX.FILEOUT`.

The `RSMALLOC.jcl` file will allocate the necessary data sets on the MVS host that need to be in place prior to using the Zowe CLI commands to copy the files from your local workspace into the pre-allocated data sets and to run the application.

The files created with the `REXALLOC.jcl` are:

```ascii
USER1.SAMPLE.REXX
USER1.SAMPLE.REXX.FILEIN1
USER1.SAMPLE.REXX.FILEIN2
USER1.SAMPLE.REXX.FILEOUT
```

### A Sample REXX Use Case

A sample use case for the REXX program might be that `RSAM1` needs to also display the contents of the output file.  You could accomplish this by creating a new subroutine `sub3` to read and display the contents of `FILEOUT`.

This version of `RSAM1` can be found in the `Tutorial-Complete` branch with the necessary code to complete the use case.

## Using Property Groups to resolve Copybooks/Includes

One of the major functions of the editor is the ability to resolve copybooks and includes that reside on either a local file system or on a remote z host.  In order to experience the copybook/include resolution feature, we have provided sample property group files, that when configured, will demonstrate the ability of the editor to resolve copybooks and includes from both local file systems and remote z host data sets.

The default sample programs, `SAM1`, `PSAM1`, and `ASAM1` all use include files that are available on your local file system.  We have provided a property group file, `zapp.yaml` which is already pre-configured with the necessary properties.  You simply need to update the system name to your z host  and the TSO ID `USER1` to your TSO ID.

We also provide other options for property group files listed below. The method you use to configure property groups depends on your own preference, but the recommended method is using the `zapp.yaml` file.

Alternative methods are

- `.vscode/settings.json` which is the native VS Code Workspace settings file.
  - [Documentation on configuring](https://ibm.github.io/zopeneditor-about/Docs/setting_preferences.html#user-preferences-versus-workspace-preferences) `settings.json`
- `zapp.json` - a json version of the z application configuration file
  - [Documentation on configuring](https://ibm.github.io/zopeneditor-about/Docs/zapp.html#zapp-use-cases) `zapp.json` and `zapp.yaml`

We provided sample programs `SAM1LIB` and `PSAM1LIB` to demonstrate resolving library based copybooks and includes from both a local file system and a remote z host.  To resolve copybooks from a local file system, the `zapp.yaml` file contains the **libraries** property below.  The **libraries: name** `MYFILE` matches the library name in the `COPY DATETIME IN MYFILE` statement in `SAM1LIB`.

```ascii
  - name: cobol-local
    language: cobol
    type: local
    syslib:
      - "**/COPYBOOK"
    libraries:
      - name: MYFILE
        locations:
          - "**/COPYLIB"
```

To demonstrate resolving library based copybooks and includes on a remote z host.  The following steps are listed to take advantage of remote access capabilities.  This example uses the RSE REST API.

- Create a Zowe CLI profile.
  - Instructions on the use and setup of Zowe CLI profiles are found [here](https://ibm.github.io/zopeneditor-about/Docs/interact_zos_overview.html) for both RSE and z/OSMF
- Creating a TSO data set on the remote z host using the following command:

  `zowe rse create pds USER1.SAMPLE.COPYLIB`
  _Note: This command uses the default values for RECFM(FB), LRECL(80), and Directory Blocks(5)._
- Uploading the copybook/include to the TSO data set

  `zowe rse-api-for-zowe-cli upload file-to-data-set "COPYLIB-MVS/REPTTOTL.cpy" "USER1.SAMPLE.COPYBLIB(REPTTOTL)"`

- Update the `zapp.yaml` file property replacing the **system** id and the **libraries: locations** dataset name

```ascii
  - name: zowe-mvs-cbl
    language: cobol
    type: mvs
    system: zos1000.example.com
    syslib:
      - USER1.SAMPLE.COBCOPY
    libraries:
      - name: MYLIB
        locations:
          - USER1.SAMPLE.COPYLIB
```

Notice the **libraries: name** `MYLIB` matches the libray name in the `SAM1LIB` copy statement `COPY REPTTOTL IN MYLIB`

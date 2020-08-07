## Sample COBOL, PL/I, and HLASM files for the "IBM Z® Open Editor" for COBOL, PL/I, and HLASM

This repository provides sample COBOL, PL/I, and HLASM programs, along with JCL and data files to compile and run them.

These examples are provided to allow you to not only experience the [IBM Z® Open Editor](https://marketplace.visualstudio.com/items?itemName=IBM.zopeneditor), but also in conjunction with the [Zowe VS Code Extension](https://marketplace.visualstudio.com/items?itemName=Zowe.vscode-extension-for-zowe), experience the powerful capabilities for IBM z/OS development and processing.

The sample applications consist of the following files:

### COBOL Examples

- COBOL programs: `SAM1` and `SAM2`
- COPYBOOKS: `CUSTCOPY` and `TRANREC`
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

### PL/I Examples

- PL/I programs: `PSAM1` and `PSAM2`
- INCLUDES: `BALSTATS` and `CUSTPLI`
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
USER1.SAMPLE.PLI.CUSTFILE
USER1.SAMPLE.PLI.TRANFILE
```

The application creates a report, `USER1.SAMPLE.PLI.CUSTRPT`.

### A Sample PL/I Use Case

A sample use case for the PL/I programs might be that `PSAM1` needs to process a new type of Customer record called a Product record and generate a new line for Service Calls in the Totals Report section.  You could accomplish this by creating a new program, `PSAM3` to process these new records and produce the product statistics needed on the report.

Again, in the `Tutorial-Complete` branch, notice the new program `PSAM3`, the new Include `PRODSTATS` which is used for the data being passed between `PSAM1` and `PSAM3`.

### HLASM Examples

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

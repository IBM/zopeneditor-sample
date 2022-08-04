# Sample code for IBM Z Open Editor and IBM Wazi Developer

Welcome to the sample repository, which provides sample code for you to explore the features of [IBM Z Open Editor](https://ibm.github.io/zopeneditor-about/Docs/introduction.html#key-capabilities) and [IBM Wazi Developer for Red Hat CodeReady Workspaces (IBM Wazi Developer)](https://www.ibm.com/products/wazi-developer).

## Product introduction

IBM Z Open Editor, a component of IBM Wazi Developer, is a free modern editing experience for IBM Z Enterprise languages. [Learn more](https://ibm.github.io/zopeneditor-about/Docs/introduction.html#key-capabilities).

IBM Wazi Developer is a single integrated solution, which delivers a cloud native development experience for z/OS. [Learn more](https://www.ibm.com/docs/en/wdfrhcw/1.3.0?topic=solution-overview).

## Content

This repository provides sample COBOL, PL/I, HLASM, and REXX programs, along with JCL and data files to compile and run them. The JCL files have defaults that can be used with the IBM Wazi Sandbox default image out of box, but can be adjusted to fit your z/OS configuration.

Depending on the product that you want to explore, choose the appropriate Git branch.

### Branches for Z Open Editor only

The following branches provide code samples with editor configuration settings such as ZAPP, as well as JCL and Bash build scripts that use Zowe CLI and the IBM RSE API Plug-in for Zowe CLI to build and run the samples:

- `main` branch: sample applications
- `tutorial-complete` branch: extended sample applications.

These two branches represent a before and after view of working sample applications for each language that were extended with a new capability as documented below.

You can use these branches with IBM Z Open Editor and Zowe Explorer installations on MacOS or Windows, as well as on [Eclipse Che](https://github.com/IBM/zopeneditor-about/tree/master/che).

### Branches for IBM Wazi Developer

The following branches provide additional sample code for Wazi Developer and its integrations with other zDevOps products:

- `wazi-main` branch:  sample application
- `wazi-tutorial-complete` branch: extended sample application

These branches represent two different states of development in the same application, and include the following samples:

- All samples, such as JCL file, that are pre-configured and tested to be used with the IBM Wazi Sandbox
- IBM Debug for z/OS configuration settings, VS Code launches, and JCL
- User Build configuration files to be used with IBM Dependency Based Build
- Groovy-based set-up scripts that build and deploy the COBOL sample application to a fresh Wazi Sandbox or any other z/OS system
- Ansible set-up scripts that build and deploy the COBOL sample application to a fresh Wazi Sandbox or any other z/OS system
- A GitLab CI sample to build and run the application as part of a GitLab pipeline

**Note:** The automation scripts currently cover the COBOL samples `SAM1` and `SAM2` only, but you can easily copy and adjust them for the PL/I and Assembler samples. To learn more about how to use these scripts, check the [Section "Building and running the COBOL example"](#building-and-running-the-cobol-example) in this file for the Bash with Zowe CLI scripts, and in the `wazi-main` branch for the Groovy and Ansible variants.

## Prerequisites

Before you run and use the sample code, ensure that the following prerequisites are met:

- Set up IBM Z Open Editor by following the [procedure](https://ibm.github.io/zopeneditor-about/Docs/getting_started.html).
- To use the user build function, IBM Dependency Based Build (DBB) is required to be set up.
- To use the Z Open Debug function, IBM z/OS Debugger is required to be set up.

## Running COBOL sample files

### Sample files

- COBOL programs: `SAM1`, `SAM2`, and `SAM1LIB`
  - `SAM1LIB` is a copy of `SAM1` but shows resolving copybooks with the local and MVS library options
- Copybooks: `CUSTCOPY` and `TRANREC`
- Libraries copybooks: `DATETIME` (local under COPYLIB) and `REPTTOTL` (MVS under COPYLIB-MVS)
- Data source files: `SAMPLE.CUSTFILE.txt` and `SAMPLE.TRANFILE.txt`
- JCL members that set up and run the application: `ALLOCATE` and `RUN`.
  **Note:** The JCL files are to be used as templates, so you might need to update the compiler library name and the `HLQ` parm with your TSO user ID.

`SAM1` reads in both the `CUSTFILE` and `TRANFILE` data files, then performs different actions on the `CUSTFILE` based on transactions from `TRANFILE`. Valid transactions are `ADD`, `UPDATE`, and `DELETE`. When an `UPDATE` transaction is processed, `SAM1` calls `SAM2` to perform the requested update. At the end of processing the `TRANFILE`, `SAM1` generates a report on the transactions processed and produces an updated `CUSTFILE`.

`SAM2` also includes some base code in place for `CRUNCH` transactions that are mentioned in the use case below.

### Sample use case

You have received requirements to enhance the Daily Customer File Update Report to include the total number of customers as well as information regarding "Crunch" transactions.  A "Crunch" transaction is a request to calculate the average monthly order revenue for a specific customer.  The current daily report simply displays the first 80 bytes of each transaction record as well as total counts for each type of transaction.

### Building and running the sample files

The `ALLOCATE.jcl` file will allocate the necessary data sets on the MVS host that need to be in place before using the `Zowe CLI` commands to copy the files from your local workspace into the pre-allocated data sets and to run the application.  The `RUN.jcl` will compile, link, and run the programs.

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

The folder called `zowe` contains Bash shell scripts that can be used with [Zowe CLI](https://ibm.github.io/zopeneditor-about/Docs/setup_integration.html) profiles to upload the COBOL program files, copybooks, and JCL files to MVS and execute the JCL conveniently. All the scripts assume that you execute them from the workspace directory, so for example as the command `zowe/zowecli-cobol-upload-run-simple.sh`.

- `zowe/zowecli-create-profiles.sh`: This script contains Zowe CLI commands to create profiles for RSE API, z/OSMF, SSH. You can edit the variables in the beginning for your account. The script can also be used for updates, such as changed passwords, as it overwrites existing profiles with new values.
- `zowe/zowecli-cobol-upload-run-simple.sh`: A simple example that executes one Zowe CLI command after the other required to build and run the SAM1 example using JCL files. It main purpose is to demonstrate the command usage without distracting with too much scripting code.
- `zowe/zowecli-cobol-upload-run-tutorial.sh`: Is discussed in the [RSE API Plugin for Zowe CLI tutorial](https://ibm.github.io/zopeneditor-about/Docs/rse_tutorial.html#approach-3-using-a-script-to-automate-command-line-operations-against-z-os-resources) of the Z Open Editor user documentation. It performs essentially the same steps as the previous script, but is written more in the style how an automation script would work, but actually querying JCL job statuses and waiting.
- `zowe/zowecli-cobol-clean.sh`: A simple script that deletes all the data sets created by the other scripts.

### Results

After you successfully run the programs, you can see the resulting new files of the sample use case from the `tutorial-complete` branch. You can copy and modify these sample scripts if you want to use them for the other examples in this repository.

In looking at the files, you will notice a new copybook called `SAM2PARM`, which was created to contain the parameters necessary for `SAM1.cbl` to pass to `SAM2.cbl` in order to process a new transaction type.  There is also a new `TRANFILE` which contains a record for the new `CRUNCH` transaction.

### Multi-root example

The COBOL sample above shows how to use VS Code as a single-root workspace. You also find the folder called [multiroot](./multiroot) in this repository that contains a simple example for how to utilize IBM Z Open Editor with a [VS Code multi-roor workspace](https://code.visualstudio.com/docs/editor/multi-root-workspaces) setup. See the [README](./multiroot/README.md) in that folder for more details.

## Running PL/I sample files

### Sample files

- PL/I programs: `PSAM1`, `PSAM2`, and `PSAM1LIB`
  - `PSAM1LIB` is a copy of `PSAM1` but shows resolving includes with the local and MVS library options
- Includes: `BALSTATS` and `CUSTPLI`
- Libraries includes: `DATETIME` (local under INCLUDELIB) and `REPTTOTL` (MVS under INCLUDELIB-MVS)
- Data source files: `SAMPLE.PLI.TRANFILE.txt` and `SAMPLE.PLI.CUSTFILE.txt`
- JCL members that set up and run the application: `PLIALLOC` and `RUNPSAM1`.
  **Note:** The JCL files are to be used as templates, so you might need to update the compiler library name and you will need to update the `HLQ` parm with your TSO user ID.

`PSAM1` reads in both the `PLI.CUSTFILE` and `PLI.TRANFILE` data files, then produces a report with customer information and a **Totals** summary section. Valid transactions are `PRINT` and `TOTALS`. A `PRINT` transaction prints the Customer records to the Customer section of the report. When `PSAM1` reads in a `TOTALS` transaction, it generates the **Totals Report** section.

`PSAM2` generates running totals from amounts passed in from `PSAM1`.

The `PLIALLOC.jcl` file will allocate the necessary data sets on the MVS host that need to be in place before using the Zowe CLI commands to copy the files from your local workspace into the pre-allocated data sets and to run the application.  The `RUNPSAM1.jcl` will compile, link, and run the programs.

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

The application creates a report called `USER1.SAMPLE.PLI.CUSTRPT`.

### Sample use case

`PSAM1` needs to process a new type of Customer record called a Product record and generate a new line for Service Calls in the Totals Report section. You can accomplish this by creating a new program called `PSAM3` to process these new records and produce the product statistics needed on the report.

### Building and running the PL/I sample files

Follow the same steps as for the COBOL sample above, but replace the respective JCL files with `PLIALLOC.jcl` and `RUNPSAM1.jcl`.

### Results

After you successfully run the programs, you can see these resulting new files of the sample use case from the `tutorial-complete` branch:

- `PSAM3`
- Include `PRODSTATS` that is used for the data being passed between `PSAM1` and `PSAM3`

## Running HLASM sample files

### Sample files

- HLASM programs: `ASAM1` and `IRR@XACS`. `IRR@XACS` is included to provide a better example for the Outline View, and can be found in the `SYS1.SAMPLIB` on the Z host.
- Copybook (in ASMCOPY): `REGISTRS`
- Data source file: `SAMPLE.ASM.FILEIN.txt`
- JCL members that set up and run the application: `ASMALLOC` and `RUNASAM1`. **Note:** The JCL files are to be used as templates, so you might need to update the compiler library, the z/OS Macro library, the Assembler Macro library, and the Assembler Modgen library names. You will also need to update the `HLQ` parm with your TSO user ID.

`ASAM1` reads in a record from the `SAMPLE.ASM.FILEIN` data set.  It will then write it to the output file `ASM.FILEOUT` and the record number and column number records.

The `ASMALLOC.jcl` file will allocate the necessary data sets on the MVS host that need to be in place before using the Zowe CLI commands to copy the files from your local workspace into the pre-allocated data sets and to run the application.  The `RUNASAM1.jcl` will compile, link, and run the programs.

The files created with the `ASMALLOC.jcl` are:

```ascii
USER1.SAMPLE.ASMOBJ
USER1.SAMPLE.ASMLOAD
USER1.SAMPLE.ASM
USER1.SAMPLE.ASMCOPY
USER1.SAMPLE.ASM.FILEIN
```

The application creates a file, `USER1.SAMPLE.ASM.FILEOUT`.

### Sample use case

`ASAM1` needs to also write the character string in hexadecimal format. You can accomplish this by creating a new program called `ASAM2` to translate the string into hex format and return to `ASAM1`.

### Building and running the HLASM sample files

Follow the same steps as for the COBOL sample above, but replace the respective JCL files with `ASMALLOC.jcl` and `RUNASAM1.jcl`.

### Results

After you successfully run the programs, you can see these resulting new files of the sample use case from the `tutorial-complete` branch:

- `ASAM2`
- Updated `ASAM1` with the necessary code to complete the use case

## Running REXX sample files

### Sample files

- REXX program: `RSAM1`
- Data source files: `SAMPLE.REXX.FILEIN1.txt` and `SAMPLE.REXX.FILEIN2.txt`
- JCL member to allocate files necessary to run the exec: `REXALLOC`. **Note:** You will need to update the `HLQ` parm with your TSO user ID.

`RSAM1` reads in the records from the `SAMPLE.REXX.FILEIN1` and `SAMPLE.REXX.FILEIN2` data sets.  It will then write them to the output file `SAMPLE.REXX.FILEOUT`.

The `RSMALLOC.jcl` file will allocate the necessary data sets on the MVS host that need to be in place before using the Zowe CLI commands to copy the files from your local workspace into the pre-allocated data sets and to run the application.

The files created with the `REXALLOC.jcl` are:

```ascii
USER1.SAMPLE.REXX
USER1.SAMPLE.REXX.FILEIN1
USER1.SAMPLE.REXX.FILEIN2
USER1.SAMPLE.REXX.FILEOUT
```

### Sample use case

`RSAM1` needs to also display the contents of the output file. You can accomplish this by creating a new subroutine called `sub3` to read and display the contents of `FILEOUT`.

### Building and running the REXX examples

Follow the [REXX tutorial](https://ibm.github.io/zopeneditor-about/Docs/tutorial_rexx.html).

### Results

After you successfully run the programs, you can see `RSAM1` with the necessary code to complete the use case from the `tutorial-complete` branch.

## Using property groups sample files

Z Open Editor can resolve copybooks and includes that reside on either a local file system or on a remote Z host. You can use the following methods to configure property groups:

- `.vscode/settings.json`: Native VS Code Workspace settings file. See
  [configuring `settings.json`](https://ibm.github.io/zopeneditor-about/Docs/setting_preferences.html#user-preferences-versus-workspace-preferences).
- `zapp.json`: Recommended. A JSON version of the Z application configuration file. See [Configuring `zapp.json` and `zapp.yaml`](https://ibm.github.io/zopeneditor-about/Docs/zapp.html#zapp-use-cases).

Sample property group files are provided for you to experience the copybook and include resolution feature.

The default sample programs, `SAM1`, `PSAM1`, and `ASAM1` all use include files that are available on your local file system.  You can use the property group file called `zapp.yaml` for resolution, which is already pre-configured with the necessary properties. Remember to update the system name to your Z host and the TSO ID `USER1` to your TSO ID.

Sample programs `SAM1LIB` and `PSAM1LIB` are provided to demonstrate resolving library-based copybooks and includes from both a local file system and a remote Z host. To resolve copybooks from a local file system, the `zapp.yaml` file contains the **libraries** property below.  The **libraries: name** `MYFILE` matches the library name in the `COPY DATETIME IN MYFILE` statement in `SAM1LIB`.

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

### Resolving copybooks and includes on Z remotely

To resolve library-based copybooks and includes on a remote Z host, take the following steps to take advantage of remote access capabilities. This example uses the RSE REST API.

1. Create a Zowe CLI profile. For instructions on how to use and set up Zowe CLI profiles, see [here](https://ibm.github.io/zopeneditor-about/Docs/interact_zos_overview.html) for both RSE and z/OSMF.
1. Create a TSO data set on the remote Z host using the following command:

    ```bash
    zowe rse create pds USER1.SAMPLE.COPYLIB
    ```

    **Note:** This command uses the default values for `RECFM` (FB), `LRECL` (80), and `Directory Blocks` (5).
1. Upload the copybook and include to the TSO data set.

    ```bash
    zowe rse-api-for-zowe-cli upload file-to-data-set "COPYLIB-MVS/REPTTOTL.cpy" "USER1.SAMPLE.COPYBLIB(REPTTOTL)"
    ```

1. Update the `zapp.yaml` file property, replacing the **system** ID and the **libraries: locations** data set name.

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

    **Note:** The **libraries: name** `MYLIB` matches the library name in the `SAM1LIB` copy statement `COPY REPTTOTL IN MYLIB`.

## Support and Feedback

If you encounter issues when running the sample code, or have feedback on the sample code, create a pull request or issue in this [GitHub repository](https://github.com/IBM/zopeneditor-sample).

## Next steps

- Learn more about [IBM Z Open Editor](https://ibm.github.io/zopeneditor-about/Docs/introduction.html#key-capabilities) and [IBM Wazi Developer](https://www.ibm.com/docs/en/wdfrhcw/1.3.0?topic=solution-overview).
- Try [IBM Wazi Developer (IBM Z Open Editor included)](https://www.ibm.com/account/reg/uk-en/signup?formid=urx-49545) that is hosted on IBM Z Trial at no cost.

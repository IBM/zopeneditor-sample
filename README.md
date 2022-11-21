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

### Branches for IBM Wazi for VS Code and IBM Wazi for Dev Spaces

The following branches provide additional sample code for Wazi for VS Code and IBM Wazi for Dev Spaces and its integrations with other zDevOps products:

- `wazi-main` branch:  sample applications
- `wazi-tutorial-complete` branch: extended sample applications
- `analyze-sidecar` branch: sample applications for Wazi Analyze
- `analyze-sidecar-complete` branch: extended sample applications for Wazi Analyze

These branches represent two different states of development in the same application, and include the following samples:

- All samples, such as JCL file, that are pre-configured and tested to be used with the IBM Wazi Sandbox
- IBM Debug for z/OS configuration settings, VS Code launches, and JCL
- User Build configuration files to be used with IBM Dependency Based Build (DBB)
- Groovy-based set-up scripts that build and deploy the COBOL sample application to a fresh Wazi Sandbox or any other z/OS system
- Ansible set-up scripts that build and deploy the COBOL sample application to a fresh Wazi Sandbox or any other z/OS system
- Wazi Analyze configuration files that can be used to scan all source code files (except REXX) in the entire branch
- A GitLab CI sample to build and run the application as part of a GitLab pipeline

**Note:** The automation scripts currently cover the COBOL samples `SAM1` and `SAM2` only, but you can easily copy and adjust them for the PL/I and Assembler samples. To learn more about how to use these scripts, check the [Section "Building and running the COBOL example"](#building-and-running-the-cobol-example) in this file for the Bash with Zowe CLI scripts, and in the `wazi-main` branch for the Groovy and Ansible variants.

## Prerequisites

Before you run and use the sample code, ensure that the following prerequisites are met:

- Set up IBM Z Open Editor by following the [procedure](https://ibm.github.io/zopeneditor-about/Docs/getting_started.html).
- To use the user build function, DBB is required to be set up.
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

#### Running Zowe scripts

You can use the folder called `zowe` that contains Bash shell scripts with [Zowe CLI](https://ibm.github.io/zopeneditor-about/Docs/setup_integration.html) profiles to upload the COBOL program files, copybooks, and JCL files to MVS and execute the JCL conveniently. 

**Note:** All the scripts assume that you execute them from the workspace directory, for example, the command `zowe/zowecli-cobol-upload-run-simple.sh`.

|Script|Function|
|---|---|
|`zowe/zowecli-create-profiles.sh`|Contains Zowe CLI commands to create profiles for RSE API, z/OSMF, SSH. You can edit the variables in the beginning for your account. You can also use this script to update profiles, such as change passwords, as it overwrites existing profiles with new values.|
|`zowe/zowecli-cobol-upload-run-simple.sh`|Executes one Zowe CLI command after the other that is required to build and run the `SAM1` example using JCL files. It shows the command usage without distracting with too much scripting code.|
|`zowe/zowecli-cobol-upload-run-tutorial.sh`|As discussed in the [RSE API Plug-in for Zowe CLI tutorial](https://ibm.github.io/zopeneditor-about/Docs/rse_tutorial.html#approach-3-using-a-script-to-automate-command-line-operations-against-z-os-resources) of the Z Open Editor user documentation, it performs essentially the same steps as the previous script, but is written more in the style how an automation script would work, but querying JCL job statuses and waiting.|
|`zowe/zowecli-cobol-clean.sh`|Deletes all the data sets created by the other scripts.|
|`zowe/dbb-prepare-uss-folder.sh`|If you use DBB with Z Open Editor's user build, use this script to set up the USS. It will create a project directory and then clone the required `dbb-zappbuild` GitHub repository (requires Git being installed and available in the PATH) that contains the Groovy files used by user build. Also, the script will upload the file `application-conf/datasets-sandbox.properties` to the cloned Git repository. This file contains all the defaults for IBM Wazi Sandbox. If you use a different z/OS system, you might have to update the values in that file.|

#### Using Groovy scripts

If you use DBB, you can use the example Groovy scripts provided in the folder `groovy` to:

- Perform operations remotely on USS and get started with DBB setting up a remote workspace on z/OS USS. 
- Run complete builds, opposed to running single program builds with Z Open Editor's user build, 
- Execute the build results. 
  
The Groovy scripts have corresponding Bash scripts that upload and execute the Groovy to and on USS.

|Script|Function|
|---|---|
|`groovy/dbb-sam-prepare-and-build.sh`|Calls `zowe/dbb-prepare-uss-folder.sh` and builds the entire SAM application by executing the `groovy/dbb-sam-build.groovy` script. It can be used as a starting point for developers to ensure that everything builds before they make changes. You can use the `groovy/dbb-sam-build.groovy` in other automation scripts, such as the GitLab pipeline example provided in `.gitlab-ci.yml`, to execute a fully automated build.|
|`groovy/dbb-sam-run.sh`|Executes `groovy/dbb-sam-run.groovy`, which is uploaded by `groovy/dbb-sam-prepare-and-build.sh`, to run the application. You can use the script after performing a user build with changes to verify that the SAM application still works correctly.|
|`groovy/dbb-utilities.groovy`|Contains a collection of utilities that realize the functionality that are currently not available in DBB, such as the creation of sequential data set for test data required to run the script.|

#### Running Ansible scripts

You can use the Ansible scripts provided in the `ansible` folder to automate setting up remote workspaces on USS for user build, running builds, and running the SAM application. 

Instead of Zowe CLI, it uses the [Ansible framework](https://docs.ansible.com/ansible/latest/user_guide/index.html) and [Red Hat Ansible Certified Content for IBM Z](https://ibm.github.io/z_ansible_collections_doc/index.html), which are collections for Ansible created by IBM for interactions with z/OS. In addition to the documentation, you can find many examples at <https://github.com/IBM/z_ansible_collections_samples> for more use cases than the ones implemented here. 

##### Prerequisites

To run these scripts, ensure that the following requirements are met: 
- Install Ansible on your local machine.
- Install the IBM z/OS collections on your local machine.
- [Prerequisites for Ansible](https://ibm.github.io/z_ansible_collections_doc/requirements/requirements.html) are available on z/OS USS. 
- Other specific prerequisites required for the sample scripts, for example, the availability of Git on your system to clone the repository and perform other Git operations. If these are not available, use other ways to achieve the same results, such as downloading the repository as a .zip file and extracting it.

Run these scripts from within the `ansible` folder with a command, for example,

```bash
ansible-playbook -i ~/ansible/inventories --extra-vars "host=sandbox1" dbb-sam-build.yml
```

|Script|Function|
|---|---|
|`ansible/inventories`|Provides templates for creating an inventory of your z/OS machines. Under the `host_vars` folder, provide one file for each machine with the respective values completed and a corresponding entry in the `ansible/inventories/inventory.yml` file for that machine providing specific username and ssh port number. It is recommended to copy and paste this folder into your local home or `/etc/ansible` directory, as these settings are often specific to your individual z/OS system, such as your personal Wazi Sandbox instance.|
|`ansible/templates`|Contains templated versions of scripts and JCL files that will be completed based on the variables provides in the `host_vars` files. When you have to update the scripts and JCL in the other script examples for each of your z/OS system's specific values, the ansible template mechanism allows you to use the same files for different systems with all different values based in the inventory settings.|
|`ansible/dbb-prepare-userbuild.yml`|Prepares the user's remote USS folder for user build by creating a project's working directory and cloning the required `dbb-zappbuild` GitHub repository in that folder. It uses a template to generate a system-specific `datasets.properties` file and uploads it into the cloned `dbb-zappbuild` repository. It also generates the VS Code user settings required for user build that you can copy and paste from the console output into your VS Code settings editor.|
|`ansible/dbb-sam-build.yml`|Performs a complete build of the SAM application. You can use it after setting up your development workspace to build the entire application before making changes and building on the updated program.|
|`ansible/dbb-sam-run.yml`|Executes the compiled application on your z/OS System, which can be used after running a user build to check whether the application works correctly.|
|`ansible/initialize-local-files.yaml`|Shows you examples for setting up your local VS Code workspace. It generates and executes a file to create Zowe CLI profiles that can then be used with Zowe Explorer. It also generates launch files for IBM Debug for z/OS that can be used with the `DEBUG.JCL` that was generated and uploaded by the `ansible/dbb-sam-build.yml` to start a remote debug session and connect to it.|

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
USER1.SAMPLE.EQALANGX
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

## Running a debug session on Wazi Sandbox

Take the following main steps to run a debug session with IBM Z Open Debug in VS Code or IBM Wazi Developer. For more details on running the session, refer to the [Z Open Debug documentation](https://www.ibm.com/docs/en/wdfrhcw/1.2.0?topic=code-debugging-applications).

### Configure Z Open Debug

1. Update the  `launch.json` file with your hostname that is `zos.mycompany.com` and the port of your Z Open Debug "remote-debug-service".
     - Keep the file in the `.vscode` folder for VS Code
     - Move the file to the `.theia` folder for IBM Wazi Developer for Workspaces
2. Configure Z Open Debug:
     1. Click `File > Preferences > Settings > User`.
     2. Type `zopendebug` in the search bar.
     3. Enter the following settings:
          - Host name: `zos.mycompany.com`
          - Port: The port of your Z Open Debug "debug-profile-service"
          - Context Root: `api/v1`
          - Connection Secured: ensure that box is checked
          - User Name: `ibmuser`
          - Profile View settings can be left unchecked

### Create a Z Open Debug profile

1. Open Command Palette.
1. Enter `Debug` in the command bar.
1. Select `IBM Z Open Debug Profiles View`.
1. Select `Create Profile`.
1. Select `Batch, IMS, DB2`.
1. Use the default profile name or enter your own one. 
1. The connection information will be pre-populated.
1. Select `Create`.

### Troubleshooting: Self-signed certificates workarounds

If you run into problems with your Debug profile showing you a connection error, it might be because you are using a self-signed certificate for your Debug services. In that case, loosen the security configuration in your editor or browser. If you have valid certificates and your Z Open Debug profile connection showing you a blue checkmark icon, ignore these steps.

- VS Code workaround:
  1. Exit VS Code.
  1. Open a command prompt.
  1. Start VS Code by using the command `code --ignore-certificate-errors`.
  1. When VS Code starts, return to the `Debug Profiles view` tab.
  1. Click the `Edit` icon for the profile that is just created.
A blue checkmark with a `Connected` label should appear after the connection setting.
- IBM Wazi Developer for Workspaces workaround:
  1. Open another tab in the same browser
  1. Paste this url: https://zos.mycompany.com:30858/api/v1/profile/dtcn/, replace `30858` with your "debug-profile-service" port.
  1. The browser will show a security error.
  1. Click `Advanced`.
  1. Click `Proceed to unsafe`.
  1. Browser will ignore certificate errors.
  1. Return to the `Debug Profiles view` tab.
  1. Click the `Edit` icon for the profile that is just created.
  A blue checkmark with a `Connected` label should appear after the connection setting.

### Run a debug session

- Submit `DEMODBG.jcl` to run `SAM1`. Or submit `DEBUGASM.jcl` to run `ASAM1`.
- Click the `Debug` icon in left panel.
- Select `List parked IBM Z Open Debug Sessions` and click the green arrow to run.
- The `Debug Console` is opened with a list of parked sessions. It might take about a minute to show the sessions `SAM1` or `ASAM1` will display in the Debug Console.
- Return to the Debug view, select `Connect to parked IBM Z Open Debug Sessions` and click the green arrow to run.
- Enter the password for `IBMUSER`.
- `SAM1` or `ASAM1` should appear in the editor window in debug mode.  Use the various debug buttons to control your session.

## Running a DBB user build on Wazi Sandbox

Take the following main steps to run a DBB user build in VS Code or in IBM Wazi Developer.

1. Check the [prerequisites and settings required for user build](https://www.ibm.com/docs/en/wdfrhcw/1.2.0?topic=code-setting-up-user-build)
1. Switch to the `wazi-master` branch of the sample repository.
1. Open the `zowecli-create-profiles.sh` script and replace the parameter values with the appropriate values for Wazi Sandbox.
1. Run the script to create the RSE and SSH profiles that will also set them as default profiles.
1. Verify the RSE profile using either Zowe Explorer or Zowe CLI commands:
     - Zowe Explorer
       1. Click the refresh button and add the new RSE profile.
       1. Click the magnifying glass icon and run a search on `IMBUSER.*` data sets and `/u/ibmuser` USS files
     - Zowe CLI
       - In the terminal window, run the commands:

         ``` ascii
         zowe rse ls ds "IBMUSER"
         ```

         ``` ascii
         zowe rse ls uss "/u/ibmuser"
         ```

1. Open the `dbb-prepare-uss-folder.sh` script and verify the parameter values for Wazi Sandbox.
1. Run the script to clone the DBB `zappbuild` repository to the USS working directory and to upload the pre-configured `datasets.properties` file.
1. Open a COBOL, PL/I, or HLASM file.
1. Right click and select `Run Setup for IBM User Build Setup`.
1. When completed, right click and select `Run IBM User Build`.
1. To start with a fresh setup or remove the working directory when finished, run the `dbb-remove-uss-filder.sh` script.

## Support and feedback

If you encounter issues when running the sample code, or have feedback on the sample code, create a pull request or issue in this [GitHub repository](https://github.com/IBM/zopeneditor-sample).

## Next steps

- Learn more about [IBM Z Open Editor](https://ibm.github.io/zopeneditor-about/Docs/introduction.html#key-capabilities) and [IBM Wazi Developer](https://www.ibm.com/docs/en/wdfrhcw/1.3.0?topic=solution-overview).
- Try [IBM Wazi Developer (IBM Z Open Editor included)](https://www.ibm.com/account/reg/uk-en/signup?formid=urx-49545) that is hosted on IBM Z Trial at no cost.

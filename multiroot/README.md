# Multi-root VS Code workspace example

This folder contains an example for a [VS Code multi-root workspace](https://code.visualstudio.com/docs/editor/multi-root-workspaces) demonstrating how it can be utilized for IBM Z Open Editor for ZAPP and IBM User Build.  For the extended User Build example switch to the branch `wazi-main`. The branch `main` will only cover ZAPP.

## Opening the multi-root workspace

See the [VS Code documentation](https://code.visualstudio.com/docs/editor/multi-root-workspaces) for more details about how multi-root workspaces are used. To open this example, use the VS Code menu **File > Open Workspace from File...** and select the file [multiroot/workspace/sam.code-workspace](./workspace/sam.code-workspace). VS Code will reload itself and now show the folders that make up the multi-root workspace comrpising of the `common`, `copybooks`, `sam`, and `workspace` folders. Each of these has been configured to be its own individual workspace. They could have been distributed to all kinds of other folders on your system, each having their own Git repository, but we kept here in one hierarchy to provide them as an easy to install example in our [https://github.com/IBM/zopeneditor-sample](https://github.com/IBM/zopeneditor-sample) GitHub repository.

## Reviewing the workspaces

Expand the workspace folder `sam` and open the file [SAM1.cbl](./sam/SAM1.cbl). You see that Z Open Editor resolves the copybooks included in (around) lines 65, 71 and 75 although the `sam` workspace does not include any copybooks.

Open and examine the [zapp.yaml](./copybooks/zapp.yaml) file in `copybooks` ([See here](https://ibm.github.io/zopeneditor-about/Docs/zapp.html) to learn more about ZAPP). You see that it specifies a property-group with the name `cobol-copybooks` with the two `syslib` entries `cust` and `trans`, which are subfolders in this `copybooks` workspace containing COBOL copybooks. Open the the [zapp.yaml](./sam/zapp.yaml) in `sam` which contains the COBOL sample programs and see that it does not contain a property group. However, when you open the programs [SAM1.cbl](./sam/SAM1.cbl) or [SAM2.cbl](./sam/SAM2.cbl) you will see that the property group in the other workspace is being used to resolve the referenced copybooks.

Z Open Editor will look in all workspaces of the multi-root workspace for these folders relative to the workspace root folder as specified in the [sam.code-workspace](./workspace/sam.code-workspace) file and combine the property groups of all the ZAPP files it finds in the root folder of each workspace. It will search in the order in which the workspaces are listed in that file. So if both ZAPP files would have defined property groups it would have searched the property groups listed in the `sam` workspace first, as it is listed before the `copybooks` workspace. So you can decide where you want to define property groups: with the application code or with the copybook workspace.

These principles for property groups also apply to ZCodeScan profiles. (To learn more about ZCodeScan check the [documentation](https://ibm.github.io/zopeneditor-about/Docs/advanced_zcodescan.html).) Z Open Editor will use the ZCodeScan files listed in ZAPP files in the order of the workspaces. You can see that the [zapp.yaml](./common/zapp.yaml) in the `common` workspace defines the location of the `customRuleModels` and the [zapp.yaml](./sam/zapp.yaml) in `sam` defines a `rules` location. Both will be used in combination when running a ZCodeScan on a program located in the `sam` workspace.

## Running a User Build

To build the two programs with IBM Dependency-based Build (DBB) you can use the profile defined in the the [zapp.yaml](./sam/zapp.yaml) file. To learn more about how to setup User Build and its prerequsites see the [IBM Documentation here](https://www.ibm.com/docs/en/cloud-paks/z-modernization-stack/2022.2?topic=code-building-cobol-pli-hlasm-programs-user-build).

We assume that you followed the instruction of this documentation to setup DBB, [dbb-zappbuild](https://github.com/IBM/dbb-zappbuild), you have created an RSE API or z/OSMF Zowe CLI profile, and defined user settings in VS Code such as these:

```json
"zopeneditor.userbuild.userSettings": {
  "dbbHlq": "IBMUSER.SAMPLE",
  "dbbLogDir": "/u/ibmuser/projects/logs",
  "dbbWorkspace": "/u/ibmuser/projects"
},
  ```

The [zapp.yaml](./sam/zapp.yaml) file defines a profile that will execute the build script provided by the [dbb-zappbuild](https://github.com/IBM/dbb-zappbuild) repository available on your USS system.

The rules for running User Build from a multi-root workspace are that

1. You manage the ZAPP file with the user build profile in the same workspace as the program file.
2. You manage all files and folders that you want to upload to USS via the `additionalDependencies` property in the same workspace as the ZAPP file and specify it location relative to that workspace root directory.
3. Include files such as copybooks can be in any other workspace in any sub-folder as the same rules applies as desribed above for property groups.

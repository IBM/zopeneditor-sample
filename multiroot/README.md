# Multi-root VS Code workspace example

This folder contains an example for a [VS Code multi-root workspace](https://code.visualstudio.com/docs/editor/multi-root-workspaces) demonstrating how it can be utilized for IBM Z Open Editor for ZAPP and IBM User Build.  For the extended User Build example switch to the branch `wazi-main`. The branch `main` will only cover ZAPP.

## Opening the multi-root workspace

See the [VS Code documentation](https://code.visualstudio.com/docs/editor/multi-root-workspaces) for more details about how multi-root workspaces are used. To open this example, use the VS Code menu **File > Open Workspace from File...** and select the file [multiroot/workspace/sam.code-workspace](./workspace/sam.code-workspace). VS Code will reload itself and now show the folders that make up the multi-root workspace comrpising of the `copybooks`, `sam`, and `workspace` folders. Each of these has been configured to be its own individual workspace. They could have been distributed to all kinds of other folders on your system, each having their own Git repository, but we kept here in one hierarchy to provide them as an easy to install example in our [https://github.com/IBM/zopeneditor-sample](https://github.com/IBM/zopeneditor-sample) GitHub repository.

## Reviewing the workspaces

Expand the workspace folder `sam` and open the file [SAM1.cbl](./sam/SAM1.cbl). You see that Z Open Editor resolves the copybooks included in (around) lines 65, 71 and 75 although the `sam` workspace does not include any copybooks.

Open and examine the [zapp.yaml](./sam/zapp.yaml) file in `sam` ([See here](https://ibm.github.io/zopeneditor-about/Docs/zapp.html#zapp-use-cases) to learn more about ZAPP). You see that it specifies a property-group with the name `sam-local` with the two `syslib` entries `cust` and `trans`.  These folders are located in a different workspace as you find them in the [copybooks](./copybooks) workspace folder. Z Open Editor will look in all workspaces of the multi-root workspace for these folders relative to the workspace root folder as specified in the [sam.code-workspace](./workspace/sam.code-workspace) file.

It is possible to have multiple ZAPP files in your multi-root workspaces. They must be in the root folder of each workspace. Z Open Editor will combine all the property-groups it finds in all of these ZAPP files and try to resolve them. The order will somewhat arbitrary, but can be described as the workspace folder first and then the other workspaces in alphabetical order of their path names. We recommend to keep ZAPP files in the workspace of the application programs for which they are used for.

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

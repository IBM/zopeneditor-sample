# Sample code for IBM Developer for z/OS v17 (Eclipse)

Welcome to the `eclipse-main` branch, which provides sample code for you to explore the features shared between [IBM Developer for z/OS Enterprise Edition](https://www.ibm.com/products/developer-for-zos) and [IBM Z Open Editor](https://ibm.github.io/zopeneditor-about/Docs/introduction.html#key-capabilities) and related offerings.

Note, check the Readme in the `main` branch for an overview to all the branches in this repository.

## Content

This branch repository provides sample COBOL, PL/I, HLASM, and REXX programs, along with JCL and data files to compile and run them. The JCL files have defaults that can be used with the [IBM Wazi as a Service](https://www.ibm.com/cloud/wazi-as-a-service) stock image out of box, but can be adjusted to fit your z/OS configuration.

IBM Developer for z/OS on VS Code and on Eclipse share common solution components such as the language parsers as well as to ability to configure property groups with include file locations via ZAPP configuration files. It can also use ZAPP files for running user builds utilizing IBM Dependency Based-Build 3.0.0 or newer. The branch provides examples for the capabilities IDz on Eclipse shares with Z Open Editor

- `eclipse-main` branch: Language samples and ZAPP file that can be used in IBM Developer for z/OS 17.0.0 or newer.

## Using property groups sample files

IBM Developer for z/OS can resolve copybooks and includes that reside on either a local file system or on a remote Z host. You can use the following methods to configure property groups. See [Configuring `zapp.json` and `zapp.yaml`](https://ibm.github.io/zopeneditor-about/Docs/zapp.html#zapp-use-cases).

Sample property group files are provided for you to experience the copybook and include resolution feature.

The default sample programs, `SAM1`, `PSAM1`, and `ASAM1` all use include files that are available on your local file system.  You can use the property group file called `zapp.yaml` for resolution, which is already pre-configured with the necessary properties. Remember to update the system name to your Z host and the TSO ID `USER1` to your TSO ID.

Sample programs `SAM1LIB` and `PSAM1LIB` are provided to demonstrate resolving library-based copybooks and includes from both a local file system and a remote Z host. To resolve copybooks from a local file system, the `zapp.yaml` file contains the **libraries** property below.  The **libraries: name** `MYFILE` matches the library name in the `COPY DATETIME IN MYFILE` statement in `SAM1LIB`.

```yaml
  - name: cobol-local
    language: cobol
    libraries:
      - name: syslib
        type: local
        locations:
          - "**/COPYBOOK"
      - name: MYLIB
        type: local
        locations:
          - "**/COPYLIB-MVS"
      - name: MYFILE
        type: local
        locations:
          - "**/COPYLIB"
```

### Resolving copybooks and includes on Z remotely

To resolve library-based copybooks and includes on a remote Z host, take the following steps to take advantage of remote access capabilities.

1. Update the `zapp.yaml` file property, replacing the **libraries: locations** data set name.

```ascii
  - name: zowe-mvs-cbl
    language: cobol
    libraries:
      - name: syslib
        type: mvs
        locations:
          - IBMUSER.SAMPLE.COBCOPY"
      - name: MYLIB
        type: mvs
        locations:
          - IBMUSER.SAMPLE.COPYLIB
```

**Note:** The **libraries: name** `MYLIB` matches the library name in the `SAM1LIB` copy statement `COPY REPTTOTL IN MYLIB`.

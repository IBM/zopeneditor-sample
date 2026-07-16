# ZCodeScan configuration

This folder contains the ZCodeScan configuration files used for code scanning in this workspace. These files help define which built-in rules are enabled, which custom rules are added, and which existing findings are already accepted as part of the current baseline.

## Files

- [`baseline.json`](baseline.json): Contains the list of known findings for this repository. This file is useful when you want to separate already known issues from newly introduced ones during future scans.
- [`psam-rules.yaml`](psam-rules.yaml): Contains the PL/I rule selection for the PSAM application in this workspace. It defines which ZCodeScan PL/I rules should run and the severity assigned to them.
- [`sam-rules.yaml`](sam-rules.yaml): Contains the COBOL rule selection for the SAM application in this workspace. It is used to apply a focused set of ZCodeScan COBOL rules during scanning.
- [`zcodescan-rules.yaml`](zcodescan-rules.yaml): Provides the catalog of available built-in ZCodeScan rules for COBOL and PL/I. This file can be used as a reference when choosing rules to enable in application-specific rule files.
- [`rules-domains.yaml`](rules-domains.yaml): Defines custom rules that users can create and maintain themselves, using the ZCodeScan-supported rule structure and fields. Users can create regex-based rules in the same format expected by ZCodeScan.

## Directories

- [`customrules/`](customrules/): Contains the Java Maven project for creating custom ZCodeScan rules using the ZCodeScan API. This includes:
  - Maven project configuration (`pom.xml`)
  - ZCodeScan API JAR dependencies (`lib/` directory)
  - Java source code for custom rules (`src/` directory)
  - Example custom rule: `CobolProgramIdRule` that validates COBOL PROGRAM-ID length
  
  See the [detailed documentation](customrules/README.md) for instructions on building and using custom Java-based rules.

## Summary

Together, these files and directories provide the baseline, built-in rule configuration, custom rule definitions, and Java-based custom rule implementations needed to run ZCodeScan for this repository.

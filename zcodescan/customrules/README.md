# IBM ZCodeScan Java custom rules overview

This directory contains a Maven project demonstrating how to create custom ZCodeScan rules for COBOL analysis. PROGRAM-ID length violations.

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Example Rule](#example-rule)
- [Dependencies](#dependencies)
- [Configuration](#configuration)
- [Creating Custom Rules](#creating-custom-rules)

---

## Prerequisites

### Obtaining Required JAR Files

Before building custom rules, you need to obtain the ZCodeScan API JAR files and place them in the `lib/` folder.

Follow the guidelines in the IBM documentation to get the JAR files: [ZCodeScan Java Custom Rules Overview](https://www.ibm.com/docs/en/developer-for-zos/17.0.x?topic=overview-zcodescan-java-custom-rules)

---

## Quick Start

### 1. Build the Custom Rule JAR

In IDz switch to the Java perspective.

From IDz menu click **File >> Import >> Existing Maven Projects**

Select the `zcodescan/customrules/COBOL/cobol-customrules` folder in this project and import the selected Maven project.

You will see a new Maven project named `zcodescan`.

Right-click on the `zcodescan` project and select **Run As >> Maven install**

This creates the ZCodeScan Custom rule jar file:

- `target/zcodescan-1.0-SNAPSHOT.jar`

### 2. Configure ZCodeScan

The workspace is already configured in [../../../../zapp.yaml](../../../../zapp.yaml):

```yaml
profiles:
  - name: zcodescan
    type: zcodescan
    settings:
      customRuleJars:
        - type: local
          locations:
            - "zcodescan/customrules/COBOL/cobol-customrules/target/zcodescan-1.0-SNAPSHOT.jar"
```

### 3. Test the Rule

1. Open [../../../../COBOL/SAM1.cbl](../../../../COBOL/SAM1.cbl)
2. Check the Problems panel for violations (PROGRAM-ID length check)

**Expected Result**: If PROGRAM-ID exceeds the configured length (default: 3 characters), you'll see a BLOCKER severity issue in the Problems panel.

---

## Project Structure

```text
cobol-customrules/
├── README.md                                  # This file
├── pom.xml                                    # Maven configuration (uses maven-shade-plugin)
├── lib/                                       # ZCodeScan JAR dependencies
│   ├── com.ibm.etools.cobol.application.model_2.5.3.jar
│   ├── com.ibm.etools.cobol.application.model.cobol.ast_1.4.33.jar
│   ├── com.ibm.etools.pli.application.model_1.1.8.jar
│   ├── com.ibm.zcodescan.lsp.cobol.core_6.6.0.jar
│   ├── com.ibm.zcodescan.lsp.common.core_6.6.0.jar
│   └── com.ibm.zcodescan.lsp.pli.core_6.6.0.jar
├── src/main/java/com/ibm/zcodescan/cobol/api/impl/
│   └── CobolProgramIdRule.java                 # Example custom rule
└── target/
    └── zcodescan-1.0-SNAPSHOT.jar             # Shaded JAR with dependencies
```

---

## Example Rule

### CobolProgramIdRule

The included `CobolProgramIdRule` demonstrates:

- Implementing both `IZCodeScanCobolRule` and `IZCodeScanRule` interfaces
- Using the COBOL AST visitor pattern with `COBOLVisitorAdapter`
- Accessing rule parameters from configuration
- Creating issues using `ZCodeScanFactory`
- Proper error handling with parameter validation

**What it does**: Checks if COBOL PROGRAM-ID names exceed a configurable length limit.

**Implementation**: See [CobolProgramIdRule.java](COBOL/cobol-customrules/src/main/java/com/ibm/zcodescan/cobol/api/impl/CobolProgramIdRule.java)

---

## Dependencies

## API Architecture Overview

### Understanding the API Layers

ZCodeScan custom rule development uses two distinct API layers that work together:

1. **ZCodeScan Custom Rules API** - Framework for creating and executing rules
2. **Language-Specific Application Model APIs** - Parsed representation of source code
   - **CAM (COBOL Application Model) API** - For COBOL programs
   - **PAM (PL/I Application Model) API** - For PL/I programs

---

#### 1. **ZCodeScan Custom Rules API**

**Package**: `com.ibm.zcodescan.api` (core), `com.ibm.zcodescan.cobol.api` (COBOL), `com.ibm.zcodescan.pli.api` (PL/I)

This API provides the framework for creating and executing custom code analysis rules:

##### Core Interfaces (`com.ibm.zcodescan.api`)

**Note**: For simple text-based rules (pattern matching, regex, line length checks, etc.), you only need the core API. Language-specific extensions (COBOL/PL/I) are only required when you need to analyze the parsed AST structure.

**Simple Rule Example** (text-based analysis only):

```java
import com.ibm.zcodescan.api.IZCodeScanRule;
import com.ibm.zcodescan.api.IZCodeScanIssue;
import com.ibm.zcodescan.api.IZCodeScanLocation;
import com.ibm.zcodescan.api.IZCodeScanTextRange;
import com.ibm.zcodescan.api.ZCodeScanFactory;

public class SimpleTextRule implements IZCodeScanRule {
    @Override
    public List<IZCodeScanIssue> scan(String uri, String source, Map<String, String> parameters) {
        // Analyze source code as plain text (no AST needed)
        // Example: Check line length, find patterns, etc.
        return issues;
    }
}
```

**Core API Components:**

- **`IZCodeScanRule`** - Base interface that all custom rules must implement
  - Method: `scan(String uri, String source, Map<String, String> parameters)`
  - Returns: `List<IZCodeScanIssue>` - List of issues found
  - Purpose: Entry point for rule execution

- **`IZCodeScanIssue`** - Represents a code quality issue
  - Contains: severity, message, primary location, secondary locations
  - Created via: `ZCodeScanFactory.getInstance().createIssue()`

- **`IZCodeScanLocation`** - Represents where an issue occurs
  - Contains: file URI, text range
  - Used for: Highlighting problematic code in the editor

- **`IZCodeScanTextRange`** - Defines the exact position of an issue
  - Properties: startLine, endLine, startColumn, endColumn, startOffset
  - Purpose: Precise issue location for IDE integration

- **`ZCodeScanFactory`** - Factory pattern for creating API objects
  - Singleton: `ZCodeScanFactory.getInstance()`
  - Creates: Issues, Locations, TextRanges
  - Ensures: Proper object initialization and consistency

##### COBOL-Specific Extensions (`com.ibm.zcodescan.cobol.api`)

- **`IZCodeScanCobolRule`** - COBOL-specific rule interface
  - Method: `scan(String uri, String source, ASTNode astNode, Map<String, String> parameters)`
  - Provides: Access to parsed COBOL Abstract Syntax Tree (AST) from CAM
  - Purpose: Enable deep COBOL code analysis

- **`COBOLVisitorAdapter`** - Visitor pattern implementation
  - Method: `accept(ASTNode node, AbstractCOBOLVisitor visitor)`
  - Purpose: Traverse the CAM AST tree structure
  - Pattern: Implements the Visitor design pattern for tree traversal

- **`AbstractCOBOLVisitor`** - Base class for CAM AST traversal
  - Override: `visit(Program)`, `visit(DataDivision)`, etc.
  - Purpose: Define custom logic for each CAM AST node type
  - Must implement: `unimplementedVisitor(String)` for unhandled nodes

##### PL/I-Specific Extensions (`com.ibm.zcodescan.pli.api`)

- **`IZCodeScanPliRule`** - PL/I-specific rule interface
  - Method: `scan(String uri, String source, ASTNode astNode, Map<String, String> parameters)`
  - Provides: Access to parsed PL/I Abstract Syntax Tree (AST) from PAM
  - Purpose: Enable deep PL/I code analysis

- **`PLIVisitorAdapter`** - Visitor pattern implementation for PL/I
  - Method: `accept(ASTNode node, AbstractPLIVisitor visitor)`
  - Purpose: Traverse the PAM AST tree structure
  - Pattern: Implements the Visitor design pattern for PL/I tree traversal

- **`AbstractPLIVisitor`** - Base class for PAM AST traversal
  - Override: `visit(Procedure)`, `visit(DeclareStatement)`, etc.
  - Purpose: Define custom logic for each PAM AST node type
  - Must implement: `unimplementedVisitor(String)` for unhandled nodes

#### 2. **CAM (COBOL Application Model) API**

**Package**: `com.ibm.etools.cobol.application.model.cobol`
**JAR**: `com.ibm.etools.cobol.application.model_2.5.3.jar`

CAM provides the Abstract Syntax Tree (AST) representation of parsed COBOL programs. This is the data model that your custom rules analyze.

##### **CAM AST Node Hierarchy**

```text
ASTNode (base class for all AST nodes)
├── Program (represents a complete COBOL program)
│   ├── IdentificationDivision
│   │   └── getProgramId() - Returns the PROGRAM-ID name
│   ├── EnvironmentDivision
│   ├── DataDivision
│   │   ├── WorkingStorageSection
│   │   └── FileSection
│   └── ProcedureDivision
│       └── Paragraphs, Statements, etc.
```

##### **Key CAM Model Classes**

- **`ASTNode`** - Base class for all COBOL syntax elements
  - Extends: Eclipse EMF `EObject`
  - Properties: beginLine, endLine, beginColumn, endColumn
  - Purpose: Common interface for all COBOL language constructs

- **`Program`** - Represents a complete COBOL program
  - Methods: `getIdentificationDivision()`, `getDataDivision()`, `getProcedureDivision()`
  - Purpose: Root node of the COBOL AST

- **`IdentificationDivision`** - IDENTIFICATION DIVISION representation
  - Method: `getProgramId()` - Returns the program name as String
  - Properties: Line and column positions for the entire division
  - Purpose: Access program metadata (PROGRAM-ID, AUTHOR, etc.)

- **`DataDivision`** - DATA DIVISION representation
  - Contains: Working-Storage, File Section, Linkage Section
  - Purpose: Access data declarations and structures

- **`ProcedureDivision`** - PROCEDURE DIVISION representation
  - Contains: Paragraphs, sections, statements
  - Purpose: Access program logic and control flow

#### 3. **PAM (PL/I Application Model) API**

**Package**: `com.ibm.etools.pli.application.model`  
**JAR**: `com.ibm.etools.pli.application.model_1.1.8.jar`

PAM provides the Abstract Syntax Tree (AST) representation of parsed PL/I programs. Similar to CAM for COBOL, this is the data model that your custom PL/I rules analyze.

##### **PAM AST Node Hierarchy**

```text
ASTNode (base class for all PL/I AST nodes)
├── Procedure (represents a PL/I procedure)
│   ├── ProcedureStatement
│   ├── DeclareStatement
│   ├── BeginBlock
│   └── Statements (assignments, calls, etc.)
```

##### **Key PAM Model Classes**

- **`ASTNode`** - Base class for all PL/I syntax elements
  - Extends: Eclipse EMF `EObject`
  - Properties: beginLine, endLine, beginColumn, endColumn
  - Purpose: Common interface for all PL/I language constructs

- **`Procedure`** - Represents a PL/I procedure
  - Methods: `getProcedureStatement()`, `getStatements()`
  - Purpose: Root node of the PL/I AST

- **`DeclareStatement`** - DECLARE statement representation
  - Contains: Variable declarations, data types
  - Purpose: Access variable and data structure definitions

- **`BeginBlock`** - BEGIN-END block representation
  - Contains: Nested statements and declarations
  - Purpose: Access block-scoped code structures

---

### How the APIs Work Together

The ZCodeScan Custom Rules API works with language-specific Application Model APIs (CAM for COBOL, PAM for PL/I) to enable custom code analysis:

#### **Execution Flow (COBOL Example)**

1. **ZCodeScan Runtime** parses COBOL source code into a CAM AST (Abstract Syntax Tree)
2. **Your Custom Rule** (implementing `IZCodeScanCobolRule`) receives the CAM AST via `scan()` method
3. **COBOLVisitorAdapter** (from ZCodeScan COBOL API) traverses the CAM AST tree structure
4. **AbstractCOBOLVisitor** callbacks execute your analysis logic on each CAM node
5. **ZCodeScanFactory** creates issue objects when violations are found
6. **Issues** are returned to ZCodeScan and displayed in IDz Problems view

#### **Execution Flow (PL/I Example)**

1. **ZCodeScan Runtime** parses PL/I source code into a PAM AST (Abstract Syntax Tree)
2. **Your Custom Rule** (implementing `IZCodeScanPliRule`) receives the PAM AST via `scan()` method
3. **PLIVisitorAdapter** (from ZCodeScan PL/I API) traverses the PAM AST tree structure
4. **AbstractPLIVisitor** callbacks execute your analysis logic on each PAM node
5. **ZCodeScanFactory** creates issue objects when violations are found
6. **Issues** are returned to ZCodeScan and displayed in IDz Problems panel

#### **Data Flow Diagram**

```text
COBOL Source Code                    PL/I Source Code
      ↓                                    ↓
[ZCodeScan Parser]              [ZCodeScan Parser]
      ↓                                    ↓
CAM AST (ASTNode/Program)       PAM AST (ASTNode/Procedure)
      ↓                                    ↓
[IZCodeScanCobolRule.scan()]    [IZCodeScanPliRule.scan()]
      ↓                                    ↓
[COBOLVisitorAdapter]           [PLIVisitorAdapter]
      ↓                                    ↓
[AbstractCOBOLVisitor.visit()]  [AbstractPLIVisitor.visit()]
      ↓                                    ↓
      └────────────[ZCodeScanFactory]─────┘
                          ↓
              [IZCodeScanIssue created]
                          ↓
              [IDz Problems Panel]
```

#### **Key Takeaway**

- **CAM API** = The "what" (data model of COBOL programs)
- **PAM API** = The "what" (data model of PL/I programs)
- **ZCodeScan Custom Rules API** = The "how" (framework for analyzing the data models)
- Your custom rule bridges the ZCodeScan API with the appropriate Application Model API (CAM or PAM)

---

The project uses 6 ZCodeScan JAR files (in `lib/` folder) plus Eclipse EMF from Maven Central:

1. **com.ibm.etools.cobol.application.model_2.5.3.jar**
   - Contains COBOL model classes: `ASTNode`, `Program`, `IdentificationDivision`, `ProgramId`
   - Required for accessing COBOL AST structure

2. **com.ibm.etools.cobol.application.model.cobol.ast_1.4.33.jar**
   - Contains AST factory and visitor classes: `COBOLVisitorAdapter`, `AbstractCOBOLVisitor`
   - Required for traversing the COBOL AST

3. **com.ibm.zcodescan.lsp.cobol.core_6.6.0.jar**
   - Contains ZCodeScan COBOL core interfaces: `IZCodeScanCobolRule`, `IZCodeScanIssue`
   - Required for implementing custom rules

4. **com.ibm.zcodescan.lsp.common.core_6.6.0.jar**
   - Contains common ZCodeScan classes and `IZCodeScanRule` interface
   - Required for rule execution

5. **com.ibm.etools.pli.application.model_1.1.8.jar**
   - PL/I model for PL/I rules

6. **org.eclipse.emf.ecore** (from Maven Central, **provided** scope)
   - Eclipse Modeling Framework dependency
   - Required for `EObject` base class used by COBOL model
   - **Important**: Use `provided` scope as ZCodeScan runtime already includes this

---

---

## Configuration

Configure ZCodeScan to use the custom rule:

1. **Define Rule Metadata** in `zcodescan/rules-domains.yaml`
2. **Activate the Rule** in `zcodescan/sam-rules.yaml`
3. **Configure JAR Location** in `zapp.yaml`
4. **Build the JAR**

---

## Creating Custom Rules

1. **Implement Both Required Interfaces**: `IZCodeScanCobolRule` and `IZCodeScanRule`
2. **Use Visitor Pattern**: Traverse AST with `COBOLVisitorAdapter` and `AbstractCOBOLVisitor`
3. **Use Factory Pattern**: Create issues with `ZCodeScanFactory.getInstance()`
4. **Update Configuration**: Add rule to `rules-domains.yaml` and `sam-rules.yaml`

---

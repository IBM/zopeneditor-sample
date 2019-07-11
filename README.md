# Welcome to the IDE for IBM Z® Developer Experience

## Table of Contents

1. [Overview](#overview)
2. [Known issues and limitations](#known-issues-and-limitations)
3. [Setting preferences](#setting-preferences)
4. [Creating Git branches](#creating-git-branches)
5. [Searching for COBOL and PL/I components](#searching-for-cobol-and-pli-components)
6. [Making code changes](#making-code-changes)
7. [Review your code using COBOL Metrics](#review-your-code-using-cobol-metrics)
8. [Committing changes into Git branches](#committing-changes-into-git-branches)
9. [Interacting with z/OS®](#interacting-with-z%2Fos)
10. [Manipulating data sets](#manipulating-data-sets)
11. [Submitting JCL to compile, link, and run jobs](#submitting-jcl-to-compile%2C-link%2C-and-run-jobs)
12. [Debugging applications with Debugger](#debugging-applications-with-debugger)
13. [Running IBM® Dependency Based Build](#running-ibm-dependency-based-build)

## Overview

The IDE for IBM Z Developer Experience (referred to as IDE below) uses and extends the [Zowe Open Mainframe](https://zowe.org) project for mainframe development to deliver new capabilities for Z Open Development.

The IDE is a Theia web IDE that runs in the browser and contains the IDE for IBM Z Developer Experience extension, Zowe VS Code extension, Debug for Z VS Code extension, and a Custom Theia extension. The IDE experience is based on the popular [Theia](https://theia-ide.org) open source project, which provides an extensible framework for developing multi-language IDEs for the cloud and desktop using state-of-the-art web technologies. It offers the following key capabilities:

- An editor for COBOL and PL/I programs

    Using the Language Server Protocol (LSP), the IDE supports COBOL and PL/I outline view, syntax highlighting, code completion, code templates, finding all references, peek definition, search, and renaming refactoring across multiple program files, and other features.

    The IDE dynamically computes a number of software quality metrics such as Cyclomatic Complexity and Halstead Complexity Measures’ Delivered Bugs, Program Volume, Effort, and Difficulty. You can observe the impact of your changes on your code as you work, and set thresholds on the metrics that you want to track and get notified about.

- Modern Software configuration management (SCM)

    With the integrated Git, you can use code control capabilities that include snapshotting work in time, branching into alternative explorations, and reverting code. You can also explore the history of all changes for files in your workspace chronologically in a viewer.

- z/OS interaction

  The IDE makes heavy use of the Zowe CLI of the Zowe project, which allows you to work on z/OS resources directly within the IDE. Zowe is an open source software framework that enables you to securely manage, control, script, and develop on the Mainframe like on cloud platforms. To learn more about Zowe, see the [Blog post](https://developer.ibm.com/code/2018/08/23/zowe-open-source-project-mainframe/) and the [Zowe Documentation home page](https://zowe.github.io/docs-site/latest/getting-started/overview.html).

- IBM Dependency Based Build (DBB) integration

  After you push your changes to COBOL and PL/I programs to the z/OS host with the integrated Git, you can compile, run, and test your applications by using the integrated DBB to run a build on the remote host. You can view the results and logs of builds in the IDE and fix issues based on the logs.

- IBM z/OS Debugger integration

    You can set breakpoints, step through COBOL and PL/I source listings, as well as view and modify variables.

[Back to top](#table-of-contents)

## Exploring the user interface

Get familiar with some of the key user interface capabilities and views that are most relevant for working with COBOL and PL/I program files.

1. Activity bar: Groups different views. You can click the icons on the bar a second time to hide its views.

2. File explorer: Manages your projects and files.

3. Search: Provides various search capabilities.

4. Git: Manages changes to the repository. This is the default SCM tool.

5. Zowe extension: Lets you interact with z/OS.

6. Problems: Displays errors of files. You can open the Problems view via View menu or by clicking the error and warning icons in the editor status bar at the bottom.

7. Terminal: Provides a command line interface that you can use to type any shell command, including advanced Git commands and Zowe Command Line operations to interact with z/OS. You can open the terminal through the Terminal menu or ``Ctrl+` ``.

8. Edit and Selection: Provides essential operations for editing.

9. Go: Provides essential navigation controls.

[Back to top](#table-of-contents)

## Exploring the sample files

A set of sample files is provided within the IDE to help you explore the editor features. You can open the directory using the `File > Open..` menu. You find the sample in the docker container under `projects > sample`. Select the `sample` folder to open it. Then click the file `README.md` to see this document.

The sample application consists of the following files:

- COBOL programs: `SAM1` and `SAM2`

   `SAM1` reads in both the `CUSTFILE` and `TRANFILE` data files, then performs different actions on the `CUSTFILE` based on transactions from `TRANFILE`. Valid transactions are `ADD`, `UPDATE`, and `DELETE`. When an `UPDATE` transaction is processed, `SAM1` calls `SAM2` to perform the requested update.

  `SAM2` includes some base code in place for `CRUNCH` transactions, which can be enhanced later in the following exercise. At the end of processing the `TRANFILE`, `SAM1` generates a report on the transactions processed and produces an updated `CUSTFILE`.

- COPYBOOKS: `CUSTCOPY` and `TRANREC`
- PL/I programs: `PSAM1` and `PSAM2`

  `PSAM1` reads in both the `PLI.CUSTFILE` and `PLI.TRANFILE` data files, then produces a report with customer information and a Totals summary section. Valid transactions are `PRINT` and `TOTALS`. A `PRINT` transaction prints the Customer records to the Customer section of the report. When `PSAM1` reads in a `TOTALS` transaction, it generates the Totals Report section. The instructions provided later in this document guide you through making the necessary code changes to allow `PSAM1` to process a new type of Customer record called a Product record and generate a new line for Service Calls in the Totals Report section.

- INCLUDES: `BALSTATS` and `CUSTPLI`
- JCL members that set up and run the application: `ALLOCATE`, `PLIALLOC`, `RUN`, `RUNPSAM1`, `DBBRUN`, `DEBUG`, and `DEBUGPLI`

  **Tip**: The `DBBRUN` and `DEBUG` jcl members can be used only when you are able to use the IBM Dependency Based Build and IBM z/OS Debugger.

- Data source files: `CUSTFILE`, `TRANFILE`, `PLI.TRANFILE`, and `PLI.CUSTFILE`

[Back to top](#table-of-contents)

## Known issues and limitations

The IDE has the following known issues and limitations now:

- Single-user support: Supports a single-user at the time. You can share program files with others using Git. If multiple users access and modify files directly on MVS™ using Zowe, the concurrent access is controlled as in many web applications, where the second user saving updates is told they are using an outdated version and asked to reload. Make sure that you copy your changes before doing so.

- Limited browser support: Requires a recent release of a modern web browser.

   Supported browsers: Google Chrome, Mozilla Firefox, or MacOS Safari.

   Unsupported browsers: Internet Explorer, Microsoft Edge (see this [Theia Issue](https://github.com/theia-ide/theia/issues/1716) for details), and mobile platforms.

- Incomplete features: The following features are implemented partially now:
  - Limited MVS support: You can access only partitioned data sets from the Remote Systems explorer now. Other data set formats such as Physical Sequential or partitioned data set extended to store COBOL files need to be accessed via Zowe CLI. You can open the data sets that contain valid content as text files.
  - Limited z/OS UNIX System Services (USS) support: The USS Remote System explorer is limited in how files get converted. All USS files are assumed to be in EBCDIC and converted now. If a file is in another format such as UTF-8, it cannot be recognized and is shown incorrectly.
  - Limited debugging capabilities: Not all capabilities of IBM z/OS Debugger are supported by the IDE now. Using IBM z/OS Debugger requires prerequisite component software [**IBM z/OS Debugger**](https://developer.ibm.com/mainframe/products/ibm-zos-debugger/) to be installed and configured on the target z/OS host.
  - No LSP support for JCL: When you open JCL files, syntax highlighting is enabled, but no additional Language Server capabilities are available for these files yet. The limitations include:
    - No contents are shown in the Outline view,
    - Ctrl+Space shows code templates, but no syntactical completions
    - Many menu options are unavailable.

[Back to top](#table-of-contents)

## Setting preferences

### Setting workspace preferences and user preferences

You can set your workspace preferences and user preferences by clicking `File > Settings > Preferences`, both of which are represented in JSON format.

- Workspace preferences: Apply to the current workspace and stored inside the `.theia` directory at the root of that workspace. If you share the workspace with other users through Git, the settings can be shared if the settings are intended to be the same for all users. You would set preferences that should apply regardless of who makes the edits, such as the Tab size, and path names for includes and other preferences.

- User preferences: Apply to the current user and across different workspaces. The settings are stored for the user in the home directory and not shared with other users, which includes not only typical user preferences related to accessibility such font sizes, editor behavior for code completion, but also z/OS host connections that include user names and passwords and so on.

**Note**: The workspace preferences override user preferences.

[Back to top](#table-of-contents)

### Setting property groups

Property groups are required to define how the COBOL and PL/I editors look for component files such as copybooks and includes when you edit a program. To do that, add the following JSON snippet into the existing JSON settings file for the IDE User Settings. You need to replace the path with the location of your actual IDE workspace directory.

```json
   "zde.propertygroups": [
    {
      "name": "local-files",
      "type": "local",
      "syslib": [
          "COPYBOOK",
          "INCLUDES",
      ],
      "libraries": [
       {
         "name": "MYFILE",
         "locations": []
       }
      ]
    },
    {
      "name": "mvs-members",
      "type": "mvs",
      "syslib": [
        "TSOUSER.SAMPLE.COBCOPY",
        "TSOUSER.SAMPLE.PLINC"
      ],
      "libraries": [
        {
          "name": "MYLIB",
            "locations": []
        }
      ]
    }
 ]
]
```

For the `syslib` property, you provide an array of directory path names to find includes. You can provide multiple paths to resolve includes in different folders. You can specify a path relative to your IDE workspace (only one workspace folder is supported now) or an absolute path on your development machine.

In the example above, a relative path is provided first. Two different ways of specifying Windows path names are provided in entries 2 and 3. A Unix/Mac path name that might be used is provided in Entry 4.

Libraries setting is used when you have statements such as `COPY <COPYBOOK_NAME> IN <LIBRARY_NAME>` or when you find a library name in the libraries setting of the Property Group in the COBOL or PL/I program. The setting looks into the folder path that you provided in locations for that library name to resolve the copybook or include. You can provide multiple libraries within the `zde.propertygroups`.

### Setting file associations

Within the `zde.datasets` property, you can specify data sets names that should contain COBOL or PL/I programs, copybooks, includes, and JCL. This means that when you open members of these data sets using the Zowe VS Code extension in the editor, they shall be considered the designated type of file. In the following example, when you open any member of `ZOWE.SAMPLE.COBOL` in MVS, the contents of the member is opened in a COBOL editor, and likewise for PL/I and JCL. To accomplish such a mapping in the IDE, save the property into your settings file, and the IDE uses the entry to map the file to the appropriate editor.

**Rule 1**: By default, members in the COBOL data set that ends with `.COBOL`, `.COBCOPY`, or `.COPYBOOK` are supposed to be COBOL, COPYBOOKs, or COBCOPY. Members in the PL/I data set that ends with `.PLI`, `.PLINC`, or `.INCLUDE` are supposed to be PL/I, PLINC, or INCLUDES.

**Rule 2**: The data sets are listed in a mapping `files.associations` in the preferences.

```json
"zde.datasets": {
    "cobolDatasets": [
      ".COBOL",
      ".COB",
      ".COBCOPY",
      ".COPYBOOK",
      ".COPY"
    ],
    "jclDatasets": [
      ".JCL"
    ],
    "pl1Datasets": [
      ".PL1",
      ".PLI",
      ".INC",
      ".INCLUDE"
    ]
  },

```

Alternatively, you can directly specify an array of associations instead of using the `"zde.dataset"` property above. For example,

```json
"files.associations": {
  "*.COBOL*": "cobol",
  "*.COB*": "cobol",
  "*.COBCOPY*": "cobol",
  "*.COPYBOOK*": "cobol",
  "*.COPY*": "cobol",
  "*.PL1*": "pl1",
  "*.PLI*": "pl1",
  "*.INC*": "pl1",
  "*.INCLUDE*": "pl1",
  "*.JCL*": "jcl"
}

```

Such a setting is used to recognize any file names, including data set and member names, which contain the noted strings as the appropriate type of file.

Using this setting, you can navigate to the path specified, and see a downloaded copy of all remote files edited via the Zowe VS Code extension.

**Note**: All files temp are deleted on startup and shutdown.

[Back to top](#table-of-contents)

## Creating Git branches

To manage your codes for parallel development, you can create a new branch using the integrated Git. To create a new Git branch:

1. Select the branch icon at the lower left of the browser page in the colored status bar. A drop-down box at the top of the browser page appears with various options.
1. Select the branch icon at the bottom again and then `Create new branch..`.
1. Enter the name of the new branch.

**Next step**: [Searching for Cobol and PL/I Components](#Searching-for-cobol-and-pli-components)

[Back to top](#table-of-contents)

## Searching for COBOL and PL/I components

You can search for strings and regular expression across all files or a specific subset of files based on location or name patterns by using the Search view. The Search view also enables you to preview side by side how each change would look like, giving you the option to perform and reject each change one by one, or all at once.

Take the sample files as an example. To search for components that generate and reference the "Daily Customer File Update" in the example program, take the following steps:

1. Right-click the Explorer, and select `Find in Folder...`.

2. Enter the search term `CUSTOMER-FILE` and press the Return key.
    - Review some of the other search options such as using regular expression and specifying patterns for files and folders to be excluded or included in the search.
    - To perform a regular expression search, select the `.*` icon and change the search term to `CUST.*FILE` and review the results.

3. Optional: Perform a second search for the `CRUNCH` transaction to determine the affected components.

**Next step**: [Making code changes](#Making-code-changes)

[Back to top](#table-of-contents)

## Making code changes

The IDE's editor supports COBOL and PL/I editing. Select the program or copybook to open in the editor. The editor provides the following features and capabilities:

- Syntax highlighting

  Allows you to quickly distinguish between COBOL and PL/I reserved words, comments, constants, and variables.
- Grey lines marking the COBOL and PL/I areas

  Assists you in determining correct areas for comments, boundaries for coding in areas A and B, and so on.
- Outline view

  You can use this view to:
  - Expand and collapse sections such as Division Headings, Section Headings, and Variable Group Names in the Outline View.
  - Recognize includes, procedures, loops quickly via the icons located by the various items.
  - Go to a wanted location in the code by clicking that section header in the view.
  - Searching for identifiers within the outline by pressing `CTRL+SHIFT+O` on Windows, or `CMD+SHIFT+O` on a Mac within the Editor window.

  When you move your cursor over the program, outline nodes are automatically selected. To turn on or off the capabilities of this view, click `...` on the upper right corner of Outline view and you can find multiple options to organize your outline view such as `Follow on Cursor`, `Filter by Type`, and `Sort by Name`, `Position and Type`.
- Code completion

  When you start typing a command, a selection list of commands and code snippets are displayed automatically or by typing `Ctrl+Space` depending on your preferences settings.

  This feature also works for variable names defined in the program.
- Cursor hover

  To preview the contents of a copybook, move your mouse cursor over the copybook name in a COPY statement. To open the copybook in a separate editor, press `Ctrl+Click`.

  To see the working storage definition or DCL definition and the parent group of a variable name, move your mouse cursor over to the variable name.

- Operation on variable names

  When you double-click a variable name to highlight the entire name and then right-click it, you can see the following available actions:

  - `Change All Occurrences (CtrlCmd+F2)`\
    When you type the new name, all occurrences are changed simultaneously.

    **NOTE**: In the scroll bar on the right side of the editor, each occurrence is noted with a location bar.
  - `Find All References (Shift+Alt/Option+F12)`\
    A Results References view is displayed on left side of the screen. Click any result to go to that location in the file.
  - `Peek References (Shift+F12)`\
    A Results References view is displayed on left side of the screen. Click any result to go to that location in the file.
  - `Go to Definition (F12)`\
    Go to the location where the variable is defined. It opens the copybook or include if applicable.
  - `Go to Symbol (CtrlCmd+Shift+O)`\
    When you enter object name in search bar or scroll through items to select object, the cursor is moved to that location.
  - `Peek Definition (CtrlCmd+F12)`\
    Open a codelens box showing where the variable was defined in the code.
  - `Rename Symbol (F2)`\
    Rename the selected symbol, and the changes are done in the whole program and copybook or include if it is attached to that symbol.
- Syntax checking

  The syntax checking feature underlines unrecognized statements and expressions in red, which enables you to make quick corrections and reduce compile errors.

  Syntax checking also works for misspelled COBOL and PL/I reserved words and unknown variable names.

  To see all the syntax errors in the open files, open the `Problems` view through the `View` menu or by clicking the error and warning icon at the bottom in the status bar. Double-click the list item to directly go to the problem.

- Undo and Redo

  You can undo your changes by pressing `Ctrl+Z`. Redo your changes by pressing `Ctrl+Shift+Z`.

**Next step**: [Review your code using COBOL Metrics](#Review-your-code-using-cobol-metrics)

[Back to top](#table-of-contents)

## Review your code using COBOL Metrics

The IDE's COBOL language server provides you with all the editing capabilities discussed above and can also utilize its knowledge about COBOL to provide you with statistical counters for COBOL language elements such as Operators and Operands, as well as use those to compute various complexity metrics, such as [Halstead metrics](https://en.wikipedia.org/wiki/Halstead_complexity_measures) (also see [[1]](https://www.verifysoft.com/en_halstead_metrics.html), [[2]](https://www.geeksforgeeks.org/software-engineering-halsteads-software-metrics/), [[3]](https://www.tutorialspoint.com/software_engineering/software_design_complexity.htm)). You can use these metrics to assess the complexity of your COBOL programs as well as set thresholds for various quality metrics that you do not want violate.

To view COBOL program metrics (for example, for `COBOL/SAM1.cbl`), right-click your COBOL program and select `Program Metrics` from the context menu. This will open the metrics view on the right side of the editor. You can scroll through the list to review the metrics that are available. To learn about each metric, click the `(i)` to access a tooltip.

The table is interactive, reacting to your edits as values get recomputed every time you save and showing you change deltas. For example,

- In `SAM1.cbl`, go to Line 243 and cut out the entire `IF` block until Line 270 and save.
- Check the table again as the `Your Change` column was updated, showing relative changes for each metric that was impacted. For example, as nested `IF-ELSE` statements were removed, the `Cyclomatic Complexity` of the program went down by 5. You can see how many other metrics were also updated. The IDE presents these changes relative to the time you opened the editor. If you close and reopen it the numbers will be reset.
- As the code that branches out to other paragraphs was cut out, you can see red squiggles and errors in the Problems view telling you about `Unreachable Code` as no other code calls these paragraphs now.
- Go back into the editor and press `Ctrl+z` (or `Command+z` on Mac) to restore the code you cut out to get back to a consistent state.

You can also set thresholds for your metrics either in your personal User Preferences or in Workspace Preferences if you want to share these with your team. Follow these steps to set thresholds for your metrics:

  1. Open the Preferences editor with `File > Settings > Open Preferences` and select the Workspace Preferences tab.
  1. In the preferences list, expand `Zde` and select `cobol.metrics > Add Value`. This adds an empty `"zde.cobol.metrics": [],` entry to your settings on the right.
  1. Put the cursor inside the array's square brackets, type `{}`, place the cursor inside the braces, and press `Ctrl+Space`.
  1. The code completion drop down is opened and you can select the `"metric"` property.
  1. Select `"cyclomatic-complexity"` from the metrics available for threshold that are proposed.
  1. Type a comma and press `Enter`. Then, press `Ctrl+Space` again to select `"direction": "larger",` and once more to select `"value":`. Set the `value` to 15.
  1. You can now use code completion to quickly provide complex preference data objects.
  1. Complete the preferences entry to look like this and save:

```json
"zde.cobol.metrics": [
    {
        "metric": "comments-percentage",
        "direction": "smaller",
        "value": 15
    },
    {
        "metric": "comments-percentage",
        "direction": "larger",
        "value": 60
    },
    {
        "metric": "cyclomatic-complexity",
        "direction": "larger",
        "value": 15
    }
],
```

If you go back to the `SAM1.cbl` editor and review the metrics table, you can now see:

- Another column in the table called `Threshold` that contains the values you just entered.
- Messages about threshold violations are displayed on the far right of the table. For example, for `SAM1`, the Cyclomatic complexity is 29 and therefore larger than the threshold. The comments percentage is smaller than 15% and therefore also shown as a violation.
- If you open the `SAM2.cbl` program, both metrics are in the acceptable range.

**Next step**: [Committing changes into Git branches](#Committing-changes-into-Git-branches)

[Back to top](#table-of-contents)

## Committing changes into Git branches

After making code changes and refinements, you can commit changed files to the Git repository.

To commit changed files:

1. Open the Git view by clicking `View > Git` or pressing `Ctrl+Shift+G`, which lists all the files that you added or modified.
2. To review changes to a changed file that is marked by the `M`, double-click the file to open a diff editor view.
3. Take one of the following actions:

   - Open the file.
   - Discard changes.
   - Add your file for the next commit that is called Staging by clicking the `+` icon to stage it.
4. Provide a short description in the `Commit message` text box at the top, such as `Implemented Update Report`.
5. Make sure that the branch you want to commit to is selected at the bottom of the browser page.
6. Click `Commit` on the top of the Git view. The list of files is empty now as all changes were committed to the branch.

You can review these changes in the Git History viewer after completing the commit.

[Back to top](#table-of-contents)

## Interacting with z/OS

You can interact with z/OS resources by using the following methods within the IDE:

### The Zowe Data Sets view

Shows your data sets and members and allows you to directly open, edit, and save your programs against MVS.

### The Terminal window

Lets you interact with Git and perform file-based operations.

To open the Terminal window, click `Terminal > New Terminal` or type ``(Ctrl+`)``. The terminal is opened at the bottom below the editor and inside the working directory that contains all the files that are shown in the Files view. You can execute Linux command on your files.

Commonly used commands:

- `ls -al`: Lists the directory of all your files.
- `git status`: Shows a summary of your Git status and changed files.

**Tip**: You can execute any kind of [Git commands](https://git-scm.com/docs) on your local files right from this terminal.

### Zowe CLI

Provides various capabilities for interacting with z/OS that includes interacting with MVS, jobs, user account, and other files.

Before using Zowe CLI, you must create a profile and connect to z/OS. Follow these steps to create a profile:

1. Issue this command with your host name, z/OSMF port, user name and password:

    ```bash
    zowe profiles create zosmf-profile zoweCLI --host host.company.com --port 443 --user USER1 --pass password --reject-unauthorized false
    ```

1. Test this profile with this command:

    ```bash
    zowe zosmf check status
    ```

After you created your profile for the user `USER1` and a data set with your COBOL programs called `USER1.SAMPLE.COBOL`, you can work on your MVS data sets with the following commands:

- List your data sets and members:

    ```bash
    zowe files ls ds USER1
    zowe files ls all-members USER1.SAMPLE.COBOL
    ```

- Download members:

    ```bash
    zowe files download ds "USER1.SAMPLE.COBOL(SAM1)"
    ```

You can see that new folders appear on the left with the names based on your data set that contains the file SAM1. You can rename it to add a `.cbl` extension to edit it in the COBOL editor and then later use drag-and-drop or the command line to upload it again.

- Check the status of your jobs:

    ```bash
    zowe jobs ls js | grep ACTIVE
    ```

You can see an example of how Zowe CLI commands can be used in combination with other Linux commands and scripts. This example returns the complete list of jobs and pipes that list into the Linux `grep` command to filter it down to show only the active jobs. This kind of capability enables you to define all kinds of batch jobs and automation for remotely interacting with z/OS.

For an overview of available Zowe CLI commands, type `zowe --help`.

To learn about all capabilities of Zowe CLI, see [Zowe CLI Online Documentation](https://zowe.github.io/docs-site/latest/user-guide/cli-usingcli.html).

[Back to top](#table-of-contents)

## Manipulating data sets

When you are connected to Zowe, you can work with your COBOL and PL/I data sets in the Zowe explorer.

Switch to the Zowe plug-in to see the `Data Sets` view by clicking the Zowe icon in the Activity bar. If the Data Sets view is not opened by default, right-click one of the headers, select the check box `Data Sets`.

**Prerequisite**: Before working on your data sets, you must connect to the Zowe server by expanding the node in the explorer that has the name of connection profile you created.
A list of existing zosmf profiles is shown.

### Creating new data sets

The data set is created with the parameters defined in the User Preferences. To create a new date set, take the following steps:

1. Click the menu of the first `ZOSMF Profile` name, and select `Create New Dataset`.

2. Select one option from a menu such as `Data Set Binary`, `Data Set C`, `Data Set Classic`, `Data Set Partitioned`, `Data Set Sequential`.

3. Provide a name such as `USER1.SAMPLE.COBOL`. Use your actual user name instead of USER1 and click Ok.

4. A new data set appears in the Explorer View. You might need to refresh the browser to see the new data set in the Explorer View.

[Back to top](#table-of-contents)

### Creating new data set members

To create a new data set member, take the following steps:

  1. Right-click the PDS and select `Create New Member`.
  2. Provide a name for the new member and press Enter.
  3. Expand the PDS to see the new member.

[Back to top](#table-of-contents)

### Deleting data sets or data set members

To delete a data set or data set member, take the following steps:

  1. Right-click the data set or member to delete.
  2. Select `Delete PDS` or `Delete Member`.

[Back to top](#table-of-contents)

### Adding or removing Favorites in the Data Sets view or USS explorer

  1. Right-click a data set or member
  2. Select `Add Favorite` or `Remove Favorite` to add to or remove from the Favorites tree.

[Back to top](#table-of-contents)

## Submitting JCL to compile, link, and run jobs

After you complete coding changes, you can test your changes.  To test your changes, upload all the necessary files to z/OS with Zowe CLI by following these steps:

1. To ensure that you have a working set of files, switch your local workspace to the `tutorial-complete` Git branch that has the final updated set of programs and support files through the branch icon at the lower left.

2. Allocate the data sets on z/OS. Sample JCL files such as  `ALLOCATE.jcl` are provided to allocate the necessary files. Alternatively, you can use your own existing PDS, or create new data sets in the Data Sets view or with Zowe CLI commands.

   Before you use a JCL file, adjust it for your user name with these steps:

   1. Click the JCL file to open it in the editor.\
  **Note**: Language support for JCl is unavailable now. But JCL syntax highlighting is enabled.
   2. Review the file. It creates data sets in the format `HLQ.SAMPLE.*`.
   3. Modify the value for the symbolic `HLQ` to the high-level qualifier you want to use and save the file. For example, replace `TSOUSER` with the wanted value.
   4. Execute the JCL with one of the following methods:
      - Zowe CLI command:

       ```bash
        zowe jobs submit local-file "JCL/ALLOCATE.jcl"
       ```

      - The `Submit Job` option in the Zowe Extension

         Take ALLOCATE.jcl as an example. To execute the job, take the following steps:
         1. Switch to Zowe Extension.
         2. Click the `USER1.SAMPLE.JCL(ALLOCATE)` data set member you created to open it in the editor.
         3. Copy and paste the contents of JCL/ALLOCATE.jcl in the file tree into the PDS member, and save the member.
         4. From the Zowe Extension view, right-click the `ALLOCATE` member of `SAMPLE.JCL`, and select `Submit Job`.

         After you submit the job, a message box that shows the jcl was submitted and a job number in the lower right corner.

         You can go to the `JOBS` view in the Zowe Extension to see the return code of the job. If the job does not exist in `JOBS` view, you might need to set the job owner to your USERID by right-clicking the `zoweCLI` line and selecting `Set Owner`.

   5. Verify the creation of these data sets using your user name by refreshing your data sets view. You might see the following lines:

      ```ascii
      HLQ.SAMPLE.COBOL
      HLQ.SAMPLE.COPYLIB
      HLQ.SAMPLE.OBJ
      HLQ.SAMPLE.LOAD
      HLQ.SAMPLE.CUSTFILE
      HLQ.SAMPLE.TRANFILE
      HLQ.SAMPLE.SYSDEBUG
      ```

3. After the data sets are created, upload the sample files to the appropriate data sets. Replace the user name with your name. Take COBOL as an example.

   For COBOL and COPYBOOK PDS members, right-click the data set and select `Create New Member` to create files in MVS data set. You need to create the members as follows:

     - Create `SAM1` and `SAM2` members to `USER1.SAMPLE.COBOL`.
     - Create `CUSTCOPY`, `SAM2PARM`, `TRANREC` members to `USER1.SAMPLE.COPYLIB`.
     - Manually copy the contents of the local files in the editor and paste into the newly created Members of MVS data sets.

     **Limitation**: Drag and drop support to upload files in MVS data sets from the local file system is unavailable now.

   For sequential files, use these Zowe CLI upload commands:

   ```bash
    zowe files ul ftds "RESOURCES/SAMPLE.CUSTFILE" "USER1.SAMPLE.CUSTFILE"

    zowe files ul ftds "RESOURCES/SAMPLE.TRANFILE" "USER1.SAMPLE.TRANFILE"
   ```

   After uploading to the data sets, click the COBOL data set members to open them in the editor. You see that the extension recognizes files as COBOL based on the defined files.associations preferences. Based on those settings, the editor is now using COBOL syntax highlight and provides all the other language server features mentioned earlier. Making changes and saving writes back to the MVS data set member directly.

4. Before executing the `RUN.jcl` that contains the COMPILE, LINK, and RUN steps for the program, modify the data set names again by following these steps:

   1. Click `RUN.jcl` in the File view to open it in the editor.
   2. Perform the same modification to the `HLQ` symbolic, replacing `TSOUSER` with the same value used previously.
   3. You might or might not need to modify the other symbolics depending on the compile and link libraries your host system uses.
   4. You might or might not change the `SPACE1` and `SPACE2` symbolics, and save the file.
   5. Submit the job with this Zowe CLI command:
      ```bash
      zowe jobs submit local-file "JCL/RUN.jcl"
      ```
   6. Verify the completion of the job with Zowe JES Explorer or using this Zowe CLI command:
      ```bash
       zowe jobs ls js
      ```
      A response showing your job ID is displayed.
   7. Check the job status with this command, replacing the job ID with yours:
      ```bash
      zowe jobs view jsbj JOB03772
      ```
   8. Refresh the Remote Systems view to locate the data sets created by the `RUN.jcl` file.

   If the job succeeded, you can examine the results directly from the data sets explorer. Click the `USER1.SAMPLE.CUSTOUT` and `USER1.SAMPLE.CUSTRPT` data set. They are opened in the editor as text files that you can inspect.

   You can use Zowe CLI commands to download the files as well. Get the contents of `SAMPLE.CUSTOUT` and `SAMPLE.CUSTRPT` with the following commands using your user name:
   ```bash
   zowe files download ds "USER1.SAMPLE.CUSTOUT"
   zowe files download ds "USER1.SAMPLE.CUSTRPT"
   ```
   These two downloaded files are now on the left in your editor and ready for review. You also can open these files directly from the Remote Systems explorer by double-clicking each file or dragging these files to the editor.

[Back to top](#table-of-contents)

## Debugging applications with Debugger

Before debugging applications, follow the instructions in [Submitting JCL to compile, link, and run jobs](#Submitting-JCL-to-compile,-link,-and-run-jobs) to allocate the sample data sets, copy the sample files into those data sets, and customize the sample JCL for your system.

To build the sample application with debug options and start it under control of the debugger, follow these steps:

1. Customize the `DBGLIB` symbolic variable in `DEBUG.jcl` or `DEBUGPLI.JCL` to contain the location of your IBM z/OS Debugger SEQAMOD data set.

2. Launch your sample application under control of the IBM z/OS Debugger backend by submitting `DEBUG.jcl` or `DEBUGPLI.JCL`.

3. Open the `Debug` view by clicking `View > Debug`, or  pressing `Ctrl+Shift+D`.

4. Open the `launch.json` file by clicking `Debug > Open Configuration`, and update the `host` attribute in the `Connect to parked IBM Compiled Language Debugger session` to contain your z/OS host name.

5. Start the `Connect to parked IBM Compiled Language Debugger session` launch configuration by ensuring that it is selected in the drop-down widget at the top of the `Debug` view, and  pressing `F5`. The source listing for the sample application is displayed in the editor.

6. Debug the sample application by using the `Continue (F5)`, `Step Over (F10)`, and `Step Out (Shift+F11)` commands. You can set breakpoints by clicking the left ruler area of the editor, and view and modify variables and registers in the `Debug` view.

For more information about IBM z/OS Debugger, see [IBM z/OS Debugger product page](https://developer.ibm.com/mainframe/products/ibm-zos-debugger/). For information about using its features, see [IBM z/OS Debugger documentation](https://www.ibm.com/support/knowledgecenter/SSQ2R2_14.1.0/com.ibm.debug.pdt.zpcl.doc/topics/czdcmn004.html).

[Back to top](#table-of-contents)

## Running IBM Dependency Based Build

### Prerequistes and Preparation

IBM Dependency Based Build will need to be installed and set up on z/OS and the DBB Web App will also need to be set up. Installation Overview can be found in the [IBM Knowledge Center](https://www.ibm.com/support/knowledgecenter/en/SS6T76_1.0.3/install_overview.html).

Here is a checklist of prerequisites for Dependency Based Build launches:

- [Rocket's Git](https://www.rocketsoftware.com/zos-open-source/tools) installed on z/OS.  Git, Gzip, Bash, and Perl will be needed.
- DBB's Toolkit SMP/E installed on z/OS
- DBB's Web Application zip file installed on a Linux workstation. This server must be accessible from the z/OS machine.

Then each of the z/OS USS profile that will be working with DBB needs to be updated with the steps below.

#### Update .profile on the host

The DBB Environment Variables and PATH need to be added to the .profile file for each z/OS USS profile.

If you are unable to edit the .profile from the terminal window, enter this command:

```bash
export TERM="xterm"
vi .profile
```

This should open the vi editor in the terminal window where you can make the following updates.
You can also add the `export TERM="xterm"` command as the first line in the .profile before adding the following lines.

Here is an example of a .profile file. Adjust it to the specifics of your system:

```sh
# Rocket's GIT environment variables
export ROCKET=/var/rocket
export GIT_SHELL=${ROCKET}/bin/bash
export GIT_EXEC_PATH=${ROCKET}/libexec/git-core
export GIT_TEMPLATE_DIR=${ROCKET}/share/git-core/templates
export MANPATH=$MANPATH:${ROCKET}/man
export PERL5LIB=$PERL5LIB:${ROCKET}/lib/perl5
export _BPXK_AUTOCVT=ON
export _CEE_RUNOPTS='FILETAG(AUTOCVT,AUTOTAG) POSIX(ON)'
export _TAG_REDIR_ERR=txt
export _TAG_REDIR_IN=txt
export _TAG_REDIR_OUT=txt

# DBB environment variables
export DBB_HOME=/var/dbb
export DBB_CONF=${DBB_HOME}/conf

export JAVA_HOME=/usr/lpp/java/J8.0_64

# add DBB, Java, and Rocket bin folders to PATH
export PATH=/bin:${DBB_HOME}/bin:${JAVA_HOME}/bin:${ROCKET}/bin::$PATH
```

#### Configure SSH and Git

You need to configure password-less shh authentication, which will enable you to perform many Git operations such as `git push` form the IDE Git user-interface view. If you cannot do this you need to execute such Git operations from the command line entering the TSO password every time.

In the IDE's terminal perform the following. Accept the default location for the key and when prompted for a "passphrase" type return for an empty one. Remember to replace user with your TSO username and host.machine.com with the ip or address of your z/OS host:

```bash
$ cd ~
$ ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/home/zde/.ssh/id_rsa):
Created directory '/home/zde/.ssh'.
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/zde/.ssh/id_rsa.
Your public key has been saved in /home/zde/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:6sAwtoZeEkjaIcEwZuYorJ3XZFa/RC/wtMR+sRlDkFQ zde@15dff13c64e7

$ ssh-copy-id -i ~/.ssh/id_rsa.pub user@host.machine.com
user@host.machine.com's password:
```

Enter the password of the TSO user. Once complete, you can test the password less setup by logging on again:

```bash
ssh 'user@host.machine.com'
```

This should lead you right into the USS prompt without asking for a password anymore. If this did not work then check out the troubleshooting section of the second blog post above. Often it is related to permission not set correctly on the z/OS host's `~/.ssh` directory and files.

Finally, to allow the IDE sample build scripts to access Git repositories located in your USS profile directories, you need to configure ssh for non-login shells to use the same environment variables as specified earlier in the .profile file. An easy way to accomplish that is by providing a symbolic link inside your `.ssh` directory back to the `.profile` file. So in the z/OS USS shell execute these commands:

```bash
cd ~/.ssh
ln -s ~/.profile rc
```

#### Running the DBB-setup task

A pre-filled *setup task* is provided to run a Dependency Based Build. You can view it by expanding the `.theia` node in the file explorer and clicking the `tasks.json` file to open it in the editor.

Remove the comment symbols or copy the task example from the comments section and paste it. Then enter the paths, replacing `${input:...}` with the required data under the `Setup for Dependency Based Build` task in the `args` section:

```bash
{
        "label": "Setup for Dependency Based Build",
        "type": "shell",
        "cwd": "${workspaceFolder}",
        "command": "./dbb-setup.sh",
        "args": [
            "${input:user}",
            "${input:zos-machine}",
            "${input:project}",
            "git@github.com:IBM/dbb.git"
        ]
    }
```

Make sure `dbb-setup.sh` is an executable file.

- From a terminal, enter `ls -la` within the Workspace directory.
- If `dbb-setup.sh` is not an executable file enter the command `chmod +x dbb-setup.sh`

To run a setup task, take the following steps:

1. Select `Terminal > Run Task` from the menu.
2. Select `Setup for Dependency Based Build`. A terminal window showing the progress of the build opens at the bottom of the IDE.
3. Enter your password if prompted.

When the message `Setup is finished` is shown in the terminal window, the setup process ends. You can check the build output for errors.

[Back to top](#table-of-contents)

### Configuring the project

You need to configure the project in the Zowe extension as follows:

- Update the `~/zAppBuild/build-conf` folder in the USS view as follows:

  - For the `build.properties` file, add Dependency Based Build Web App URL in the style of `https://server:9443/dbb` with your user name and password.
  - For the `dataset.properties` file, check if the system-specific data set is in place.

- Edit the `application.properties` file located in the `projects/SAM/application-conf` folder in the USS view.

To commit changes that are made on the local folder to the host, use the IDE's Git view or push changes to `zos master` with this command line:

```bash
git push zos master
```

[Back to top](#table-of-contents)

### Running a first build against master

A pre-filled *build task* is provided to run a Dependency Based Build task. You can view it by expanding the `.theia` node in the file explorer and clicking the `tasks.json` to open it in the editor.

Enter the paths, replacing `${input:...}` with the required data under the `Start a Dependency Based Build` task in the `args` section:

```bash
"${input:user}@${input:zos-machine}",
"/u/${input:user}/zAppBuild/dbb-branch-build.sh",
"${input:git-branch}",
"/u/${input:user}/zAppBuild",
"${input:user}",
"/u/${input:user}/projects",
"${input:project}",
"/u/${input:user}/projects/${input:project}/logs"
```

Follow these steps to run the build:

1. Select `Terminal > Run Task` from the menu.
2. Select `Start a Dependency Based Build`. A terminal window showing the progress of the build opens at the bottom of the IDE.
3. Enter your password if prompted.

When the build succeeds, you can see messages such as `Build State: CLEAN` and `Build finished` in the terminal window.

[Back to top](#table-of-contents)

### Accessing the build reports and build logs

You can see a URL to a build report within the build output, for example, \
`** Build result created for BuildGroup:SAM-master BuildLabel:build.20190612.010858.008 at https://host:9443/dbb/rest/buildResult/2521`

To view the build report, open the URL in a browser by pressing `Ctrl` and clicking it, and log in to the DBB server.
You can see each file that was compiled when you select the `view` link in the build report. To see all the dependencies that were required to build a program such as `COBOL\SAM1`, click `Show Dependencies`.

You can also see a build log within the build output. The build log is above the row with the URL, which looks like\
`** Build output located at /u/user1/projects/SAM/logs/build.2019`

This is the location of the log file folder on USS. You can access the log file by using the USS File System Explorer available in the Zowe Extension. Click `SAM1.log` or `SAM2.log` in the folder to review it in the editor.

The log file that has the contents of the messages that are shown in the terminal window is available in the parent folder `/u/user1/projects/logs/`.

[Back to top](#table-of-contents)

### Running a branch build

1. Create a branch such as `feature1` and make COBOL changes. Or switch to the `tutorial-complete` branch that has the completed changes.
2. Commit changes to the branch.
3. Push the branch to the host by using the IDE's Git view or using this command line:

   ```bash
   git push --set-upstream origin feature1
   ```

4. Open the `.theia/tasks.json` file, copy the `Start a Dependency Based Build` launch that you created, and append it to the JSON list, or change the `gitbranch` in the launch created.

5. Change the `name` and `gitbranch` of the new launch.

6. Follow the steps that are specified in [Running a First Build Against Master](#Running-a-first-build-against-master) choosing the Dependency Based Build Launch with the `Branch Build` configuration.

[Back to top](#table-of-contents)

### Running the program

After creating a successful build and completing the steps above, you can run the `SAM1` program. Follow these steps to run the `SAMPLE` application after a DBB build:

1. Click the `DBBRUN.jcl` file to open it in the editor.
2. Replace `TSOUSER` with the wanted value.
3. Submit the JCL file by right-clicking it and selecting `Submit Job` or using this Zowe CLI command:
```bash
zowe jobs submit local-file "JCL/DBBRUN.jcl"
```
[Back to top](#table-of-contents)

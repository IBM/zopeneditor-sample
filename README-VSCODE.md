# Welcome to the Wazi for VS Code Technology Preview

_(Updated May 20th, 2019 for the second Wazi Technology Preview ifix 1, v0.2.1. See [What's New](#whats-new) below for details.)_

This extension provides a fully functional [language server](https://langserver.org/) for COBOL that together with core editing capabilities enables COBOL developers to utilize features such as

- syntax highlighting
- outline view
- declaration hovers
- peek definition code lenses
- go to definition
- find all references code lenses as well as explorer
- code completion
- code template snippets
- finding and navigating references
- previewing of included copybooks (local file system only)
- navigate to copybooks
- refactoring such as "rename symbol"
- search and replace refactoring across multiple program files

This technology preview is a first snapshot of our ongoing work of creating new capabilities for z/OS developers to get your early feedback that can guide us in the direction to follow next.

This document and tutorial is maintained in public on [github.com/IBM/wazi-tutorial](https://github.com/IBM/wazi-tutorial/blob/master/README-VSCODE.md). Please, visit  us there for any updates to this document and the sample application. In the tutorial below you will also learn how to use Git to pull in the latest versions directly into your Docker image. Also make sure to frequently visit our [Wazi Community Landing page](https://ibm.github.io/wazi-about) with videos, blog post, and feedback links.

Before continuing, please read the introduction to Wazi and Zowe in our main [README.md](./README.md) file first.

This document contains the following sections:

1. [Prerequisites](#prerequisites)
1. [Installing Wazi for VS Code](#installing-wazi-for-vs-code)
1. [Limitations](#limitations)
1. [Wazi for Visual Studio Code Tutorial](#wazi-for-visual-studio-code-tutorial)
1. [Evaluation Survey](#evaluation-and-feedback-survey)

## What's New

### Technology Preview 2, ifix 1

- Fixed resolution algorithm for including copybooks from multiple different locations and added support for relative path names.

## Prerequisites

Here are the prerequisites for installation:

- *Visual Studio Code*: In order to install Wazi for VS Code, you must install [Microsoft Visual Studio Code](https://code.visualstudio.com/download). See the [VS Code documentation](https://code.visualstudio.com/docs/setup/setup-overview) for installation and configuration instructions.
- *IBM JAVA 8 - 64 bit*: The COBOL language server included in this extension has been implemented in Java. Therefore you need to install and configure a Java 8 Runtime - 64 bit in order to start it. As a result of this installation you must have Java 8 in the path so that VS Code will see it.
  - The preferred Java SDK to use is [IBM Java 8](https://developer.ibm.com/javasdk/downloads/sdk8).
  - Alternatively, you can use [Oracle Java SDK 8](https://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html).
- *Git*: To be able to perform some of the tutorial steps that involve Git we assume that you have it installed and available in your system path so that VS Code can see it. On Macs Git comes out of the box, for Linux you can install it with your distribution's package manager, and for Windows we recommend getting it directly from <https://git-scm.com>.
- *Zowe CLI 2.14*: Optionally, to make use of Zowe to open and edit files directly from z/OS MVS you need the Zowe Extension, which gets installed automatically with this extension. That extension however has the prerequisite called Zowe CLI. You must [install ZOWE CLI version 2.14 or higher](https://zowe.github.io/docs-site/latest/user-guide/cli-installcli.html#methods-to-install-zowe-cli). Find some [additional documentation here in the VS Code Marketplace](https://marketplace.visualstudio.com/items?itemName=Zowe.vscode-extension-for-zowe#user-content-prerequisites). Once installed you must [create a Zowe CLI user profile](https://zowe.github.io/docs-site/latest/user-guide/cli-usingcli.html#creating-zowe-cli-profiles) so that data sets can be found and accessed.

Note: If you do not have access to a z/OS system with Zowe 1.0.1 installed then you can **request trial access from IBM**. Go to this [Zowe Tutorial Web site](https://developer.ibm.com/tutorials/zowe-step-by-step-tutorial/) and follow the steps in the "Prerequisites" section to sign up for a trial account. With that account you can perform all of the steps describes in this document.

## Installing Wazi for VS Code

Make sure that you have installed and configure the prerequisites above.

This extension is provided by IBM only as a download from ibm.com. It is not available in the VS Code Marketplace. The downloaded file is called `ibm-wazi-vscode-0.2.1.vsix`. To install this extension file there are two alternative methods:

1. Use the VS Code Command Line providing the path to the `.vsix` file:

    ```bash
    code myExtensionFolder\myExtension.vsix
    ```

1. Use Extensions activity bar to install the `.vsix` file

    1. Bring up the Extensions view by clicking on the Extensions icon in the activity bar on the left side of VS Code.
    1. On the top right corner of the Extension View, select the option  `...` to open More Options.
    1. In the menu section, you will find `Install from VSIX...`
    1. In the file dialog you can select your downloaded `.vsix` file install it.
    1. You will see that the Zowe extension, if you do not have it already, will be automatically installed as well.

## Limitations

- *No COPYBOOK resolving on MVS data sets*: When you open a member from Zowe files (Data Sets Explorer View), i.e. from a data set HLQ.SAMPLE.COBOL, you have opened a SAM1.CBL File. If your file contains COPYBOOK Statement such as (COPY CUSTCOPY or COPY CUSTCOPY IN MYFILE). In this release, we have not yet included a feature for resolving Copybooks located in MVS. So the rich hover on copybook inclusions does not yet work for MVS.

# Wazi for Visual Studio Code Tutorial

## Overview

This tutorial provides a complete end-to-end walk-through of the COBOL development capabilities and scenarios supported by this environment. We will cover the following capabilities:

1. [Explore the GUI](#explore-the-gui)
1. [Get the sample files](#get-the-sample-files)
1. [Set user and workspace preferences](#set-user-and-workspace-preferences)
1. [Search for components referencing items of interest](#search-for-components-referencing-items-of-interest)
1. [Make coding changes using the COBOL editor](#make-coding-changes-using-the-cobol-editor)
1. [Commit your changes into your SCM branch](#commit-your-changes-into-your-scm-branch)
1. [Configure the Zowe CLI with a zOSMF profile](#configure-the-zowe-cli-with-a-zosmf-profile)
1. [Navigate Data Sets the Zowe Explorer](#navigate-data-sets-with-the-zowe-explorer)
1. [Use the Terminal and Zowe CLI to interact with z/OS](#use-the-terminal-and-zowe-cli-to-interact-with-zos)
1. [Edit and Submit JCL to compile, link, and run jobs](#edit-and-submit-jcl-to-compile-link-and-run-jobs)

## Explore the GUI

If you have not worked with VS Code before then you first want to familiarize yourself with some of the key user interface capabilities and views that are most relevant for working with COBOL program files. Perhaps you even want to go through the [VS Code User Guide](https://code.visualstudio.com/docs/editor/codebasics) and [demo videos](https://code.visualstudio.com/docs/getstarted/introvideos) to get a basic understanding.

Here are some of the UI elements and views that you will use during this tutorial. Views can be opened using the `View` Menu option as well as right-click context menus in some places.

- The black activity bar on the left that provides different groupings of views. Click icons in there a second time to hide its views.
- Explorer: this activity bar groups various important views together. You can configure and change order or select what to appear, but key views are Open Editors, File Explorer and the Outline view.
- Search: Open via the activity bar providing various search capabilities.
- Source Control: Activity bar that provides access to change management tools. The default SCM tool used is Git. If you work with Git you also want to explore the VS Code Marketplace for additional essential Git extensions such as [GitLens](https://gitlens.amod.io/).
- Problems panel: Opens via View menu or by clicking on the error and warning icons in the editor status bar at the bottom.
- Terminal: Opens via the Terminal menu or `Ctrl-`\`. Provides a command line interface at the bottom of the editor panel that you can use to issue any shell command, including advanced Git commands as well as Zowe Command Line operations to interact with z/OS.
- Go menu: provides essential navigation controls. Often you want to memorize the keyboard shortcuts of the menu options listed there.
- Edit and Selection menu: Essential tools for editing. Also here the keyboard shortcuts are typically the most efficient ways of using the operations listed.
- Data Sets: is provided by the Zowe extension. Before you can use it you need to configure a Zowe CLI profile as explained further below. The view appears in the Explorer activity group below the on left side of screen, allows user to view files on z/OS.

## Get the sample files

For this tutorial we provide a set of sample files that you can use to explore the editor features. These samples are provided on Github. Assuming that you have Git installed as described in the Prerequisites, create a work directory somewhere on your machine and clone the sample repository:

```bash
git clone https://github.com/IBM/wazi-tutorial.git
```

Then open the directory `wazi-tutorial` using the `File > Open..` menu. Right-click on the file `README-VSCODE.md` and select `Open Preview` to see this tutorial.

## Set user and workspace preferences

To get up and running in Wazi, you start exploring editor preferences first. To do that select the the `Code > Preferences >Settings` menu on the Mac. On Windows you find it in the `File` menu.

- In the editor panel, a list of preference groups is displayed, along with editor tabs for both the User and Workspace Preferences. Switch these tabs respectively in the steps below to decide in which scope you want to add a preference.
- Workspace preferences, as the name suggests are specific to the current workspace and stored inside the `.vscode` directory at the root of that workspace. If you share the workspace with other users via Git then these should be shared as well as they are intended to be the same for all users. Here you would set preferences that should apply regardless of who makes the edits, such as the Tab size, or pathnames for copybooks etc.
- User preferences, are for the current user and apply across different workspaces. These will be stored for the user in their home directory and are not shared. Examples, for typical user preferences are related to accessibility such as font sizes, editor behavior for code completion. Note, that workspace preferences override any user preference setting you define in both places.
- In the list on the left you find under Extensions an entry for `WAZI-COBOL`.
- All the preferences shown in the visual editor are represented as JSON. Complex preferences that are not just simple values have to be entered using the JSON editor itself. To open it, select the scope tab first, User or Workspace, and then click the `{}` icon on the top-right of the editor to switch to the JSON view.
- Explore some of the Editor Settings to customize your workspace if needed:
  - Expand the **Editor** preference group.
  - Select `cursorStyle` and/or `cursorBlinking`, review and set to your user preferences.
  - Review `fontSize` and `fontWeight`.
  - Turn on/off the `lineNumbers`.
  - Review the `tabSize` value and set for the workspace preferences.
  - Select `quickSuggestions` and `False` - this will allow you to control if code suggestions and snippets are activated in addition to manual code completion requests.
  - Save the settings.
- For this tutorial we also need to provide so-called COBOL property groups that define how the COBOL editor should look for component files, such as included Copybooks, when editing a COBOL program. To do that add the follow JSON snippet into the existing JSON settings file for the VS Code User Settings replacing the path with the location of your actual VS Code workspace directory.

```json
"wazi.cobol.propertygroup": [
  {
    "name": "my-copybooks",
    "locations": [
      "COPYBOOK",
      "C:\\Users\\user1\\Dev\\wazi-sample\\CPYB2",
      "C:/Users/user1/Dev/wazi-sample/COPYBOOK",
      "/Users/user1/projects/SAM/COPYBOOK"
    ],
    "cobolDatasets": ["ZOWE.SAMPLE.COBOL"],
    "libraries": [{
      "name": "MYLIB",
      "locations": ["Users/user/projects/SAM/COPYBOOK"]
    }]
  }
]
```

- For the `locations` property you provide an array of directory path names to find Copybooks. You can provide multiple paths to resolve copybooks in different folders. You can specify a path relative to your VS Code workspace (currently only one workspace folder is supported) or an absolute path on your development machine. The example above shows first a relative path and then two different ways of specifying Windows path names with Entries 2 and 3, as well as a Unix/Mac pathname that could be used in Entry 4. For this tutorial you only need the first entry. The other three were just added for illustration.
- With the `cobolDatasets` property you can specify names of data sets names that should be considered containing COBOL programs or copybooks. This means that when you open members of these data sets using the Zowe VS Code extension in the editor that they shall be considered COBOL files. In the example above, when you open any member of `ZOWE.SAMPLE.COBOL` in MVS, it will be opened the contents of the member in a COBOL editor. To accomplish such a mapping in VS Code you will see that once you save the property into your settings file that that also the following entry was added automatically, which VS Code will use to map the file to the COBOL editor.

```json
"files.associations": {
  "*ZOWE.SAMPLE.COBOL*": "cobol"
}
```

- Alternatively, you could directly specify an array of associations yourself instead of using the `"cobolDataset"` property above. For example,

```json
"files.associations": {
  "*.COBOL*": "cobol",
  "*.COB*": "cobol",
  "*.COBCOPY*": "cobol",
  "*.COPYBOOK*": "cobol",
  "*.COPY*": "cobol"
}
```

- Such a setting will now be used to recognise any file names, including data set and member names, which contain strings such as `.COBOL, .COB, .COPYBOOK, .COBCOY, .COPY` as COBOL files.

- Libraries setting is basically used when in the cobol program you have statements such as `COPY <COPYBOOK_NAME> IN <LIBRARY_NAME>` or `COPY <COPYBOOK_NAME> OF <LIBRARY_NAME>` which finds a library name in the libraries setting of Cobol Property Group and it will look into the folder path that you've provided in locations for that library name to resolve the copybook. You can provide multiple libraries within the Cobol-Property-Group.

- Workspace settings override user settings.

## Search for components referencing items of interest

Wazi for VS Code users can utilize the advanced Search capabilities provided by the VS Code editor out of the box. Its Search view allows searching for strings as well as regular expression across all files or a specific subset of files based on location or name patterns. The Search view even provides advances Query-Replace features that allow you to preview side-by-side, how each change would look like, giving users the option to perform and reject each change one by one, or all at once. Let's have a look at how Deb can use these features for impact analysis.

Let's assume a COBOL development situation in which you would start reviewing your code by analyzing the impact of some new requirements you received to determine the modifications needed to accomplish the requested updates.  You want to search for components that generate and reference the "Daily Customer File Update" in our example program.

- In the Explorer right-click in the background of the WAZI-SAMPLE, not showing any particular file or folder to initiate a search on all files:
  - Select `Find in Folder...`
  - Enter the search term `CUSTOMER-FILE` and start the search with the Return key.
    - Review some of the other search options such as using regular expression and specifying patterns for files and folders to be excluded or included in the search.
    - To perform a regular expression search select the `.*` icon and change the search term to `CUST.*FILE` and review the results.
  - Results will appear in the Search Panel.
    - Clicking on the result will allow the user to navigate to that location file in the Editor panel.
  - A second search can also be done for the `CRUNCH` transaction to determine the affected components.

## Make coding changes using the COBOL editor

You are now ready to begin making your coding changes.  Select the program or copybook you want to edit and it will appear in the editor panel.  Listed below are features and capabilities of the Wazi for VS Code COBOL editor.

- Syntax highlighting
  - Allows you to quickly distinguish between COBOL reserved words, comments, constants, and variables.
- Grey lines marking the COBOL areas
  - Assists you in determining correct areas for comments, boundaries for coding in areas A and B, etc.
- Outline View Panel
  - You can expand and collapse sections in the Outline View.\
    _(This works on Division Headings, Section Headings, and even Variable Group Names)_
  - Note the icons located by the various items allowing quick recognition of copybooks, paragraphs, etc.
  - You can also navigate to a desired location in the code by clicking on that section header in the view.
  - This view also allows expansion and collapsing of items.
  - When you move your cursor in the program, outline nodes are automatically gets selected. There are various options are provided to Turn on or off such functionalities. Go to Outline View, on the top right corner of Outline View, You'll see option `...` where you can find multiple options to organize your outline view such as `Follow on Cursor, Filter by Type and Sort by Name, Position and Type` .
- Code completion
  - Start typing a command and a selection list of commands will display either automatically or by typing `(Ctrl+Space)`, depending on your preferences settings.
  - This also works for variable names already defined in the program.
  - Code Snippets also appear in selection list with commands or `Ctrl+Space` to have selection box appear.
- Cursor hover
  - Hover the mouse pointer over the copybook name in a COPY statement to see a preview of its contents.\
  _(`Ctrl+Click` will open the copybook in a separate editor.)_
  - Hover the mouse pointer over variable name and see the working storage definition and the parent group.
- Double-click on a variable name to highlight the entire name.
  - Right-click to get a menu of available actions to take
  - `Change All Occurrences (CtrlCmd+F2)`\
    _Start typing the new name and all occurrences are changed simultaneously._\
    _NOTE: In the scroll bar on the right side of the editor, each occurrence will be noted with a location bar._
  - `Find All References (Shift+Alt/Option+F12)`\
    _A Results References View appears on left side of the screen, click on any result to navigate to that location in file._
  - `Peek References (Shift+F12)`\
    _A Results References View appears on left side of the screen, click on any result to navigate to that location in file._
  - `Go to Definition (F12)`\
    _Navigates to the where the variable is defined. It will even open the copybook if applicable._
  - `Go to Symbol (CtrlCmd+Shift+O)`\
    _Enter object name in search bar or scroll through items to select object, cursor is navigated to that location._
  - `Peek Definition (CtrlCmd+F12)`\
    _Opens a codelens box showing where in the code the variable was defined._
  - `Rename Symbol (F2)`\
    _You can Rename selected symbol and that changes will be done in whole program as well as copybook if it is attached to that symbol._
- Syntax checking
  - Will underline statements and expressions in red that are unrecognized to allow quick corrections and to cut down on compile errors.\
  _Works on misspelled COBOL reserved words and unknown variable names._
  - There is also a `Problems` view that can be opened via the `View` menu or by clicking the error/warning icon at the bottom in the status bar. It shows a list of all the syntax errors in all the open files. Double-click on any list item to directly navigate to the problem.
- Undo and Redo
  - Undo: `(Ctrl+Z)`
  - Redo: `(Ctrl+Shift+Z)`

## Commit your changes into your SCM branch

Now that you have performed various code changes and refinements you can commit this file version of the application to the SCM to preserve and share it.

- If it is not already available on the left, open the Git view using the menu `View > Git (Ctrl+Shift+G)`.
- This view shows you a list of all the files that you added and modified. You can now decide which of these you want to include in your Commit operation.
- Double-click a file that was changed _(recognizable by the `M` annotation next to the file name)_: Wazi for VS Code will open a diff editor view that shows side by side all the changes you made.
- Go back to the Git view on the left and hover over each file to see the operations available.
- You see operations for opening the file, discarding all changes made, or adding your file for the next commit, called Staging.
- Click for all your files that you changed or created the `+` icon to stage them.
- Provide a short description in the `Commit message` text box at the top, such as `Implemented Update Report`.
- Make sure that the `update-report` branch is still selected at the bottom of the browser page.
- Click the `Commit` button on the top of the Git view.
- The list of files should be empty now as all changes were committed to the branch.

You have not committed you file changes to the Git SCM and you can review these changes next in the Git History viewer.

## Configure the Zowe CLI with a zOSMF profile

Let's assume that you have now finished your first set of edits in he local workspace. You now want to connect to your z/OS host's MVS to create new data sets and upload the modified files.

This is an optional exercise assuming that you have a z/OS host with Zowe available to you. See the [Prerequisites](#prerequisites) section above for how to request a trial account with IBM.

- To connect to a host you need to create a so-called zOSMF profile for the Zowe CLI.
- A first step could be to use the help built into Zowe's CLI. To do that open the Terminal is VS Code (`Ctrl-`\`) and issue the following command. Refer to the available options in the help text to define your profile:

```bash
zowe profiles create zosmf  --help
```

- Now create your profile the following command substituting all the parameters provided below in `<>` with your actual values for your z/OS host.

```bash
zowe profiles create zosmf-profile zoweCLI --host <host.company.com> --port 443 --user <username> --pass <password> --reject-unauthorized false`
```

- then to test your connection status execute

```bash
zowe zosmf check status
```

## Navigate data sets with the Zowe explorer

Now you are connected to Zowe and can start exploring your data sets in the visual explorer, as well as create new ones, drag over files, etc.

- If not already visible open (right-click one of those grep dividers and select the checkbox `Data Sets`) and expand the Data Sets view in the Explorer activity group.
- Connect to Zowe server by expanding the node in the explorer that has the name of your connection profile created above.
- Review the list of any existing zosmf profiles shown.
- Default profile will be added in the favorites section of the menu.
- Create a new data set using the right side of the menu of the first `ZOSMF Profile` name and select first icon with `Create New Dataset`
  - Select one option from a menu such as `Data Set Binary`, `Data Set C`, `Data Set Classic`, `Data Set Partitioned`, `Data Set Sequential`.
  - Provide a name such as `USER1.SAMPLE.COBOL` (using your actual user name instead of USER1) and click Ok.
  - You will see a new Dataset is appeared in the Explorer View.
  - The data set was created with the parameters defined in the User Preferences.
- Now you can create a new data set member with
  - Right-click on the PDS data set and select `Create New Member`.
  - Provide a name for the new member and hit Enter.
  - Expand the PDS to see the new member.
- Delete a data set or data set Member
  - right-click on the data set or member to delete.
  - Select `Delete PDS` or `Delete Member`, respectively.
- Rule 1: The data set ends with `.COBOL`, `.COBCOPY`, `.COPYBOOK`. By default Wazi for VS Code will assume that all members in such data sets are COBOL, COPYBOOKs or COBCOPY, respectively.
- Rule 2: The data sets are listed in a mapping `files.associations` in the preferences. The next section will explain the details behind that rule.

## Use the Terminal and Zowe CLI to interact with z/OS

The Data Sets explorer view showed you your data sets and members and allowed you to directly open, edit, and save your programs against MVS. In this technology preview other capabilities, such as right-clicking a JCL to execute it, are still missing. However, by integrating with the Zowe Command Line Interface (CLI) users such as Deb can still use Wazi for VS Code to compile and run her application.

The way to use any command line operations in Wazi, including Git and other file-based operations, is the Terminal window, which is provided by the underlying Theia platform. You see the Terminal menu in the menu bar.

- Open the command line terminal using `Terminal > New Terminal` or just type ``(Ctrl+`)``

The terminal is opened at the bottom below your editor and inside the working directory that contains all the files shown in the Files view. You can now execute Linux command on your files.

- Type the command `ls -al` to list the directory of all your files.
- Type `git status` to see a summary of your Git status and changed files. As you can see you can execute any kind of [git command](https://git-scm.com/docs) on your local files right from this terminal.
- Type `zowe --help` to get an overview to the Zowe CLI commands available.

Zowe CLI provides various capabilities for interacting with z/OS that includes interacting with MVS, jobs, user account etc. To learn about all of its capabilities review the [Zowe CLI Online Documentation](https://zowe.github.io/docs-site/latest/user-guide/cli-usingcli.html).

Zowe CLI requires its own connection that is separate from the connection we defined in the User Preferences for the Remote Systems view. In the CLI a connection is called a Profile.

- Create a profile with this command using your hostname, z/OSMF port, username and password.
  - `zowe profiles create zosmf-profile zoweCLI --host host.company.com --port 443 --user username --pass password --reject-unauthorized false`
- Once created test this profile with
  - `zowe zosmf check status`

Now you are ready to explore some of the commands available. Let's assume you created your profile for the user `USER1` and you have created a data set with your COBOL programs earlier called `USER1.SAMPLE.COBOL`. If not adjust the command examples accordingly. Then you can run these commands on your MVS data sets:

- List your data sets and members:
  - `zowe files ls ds USER1`
  - `zowe files ls all-members USER1.SAMPLE.COBOL`
- Download members
  - `zowe files download ds "USER1.SAMPLE.COBOL(SAM1)"`\
    _(You will new folders appear on left with the names based on your data set that contains the file SAM1. You can rename it to add a `.cbl` extension to edit it in the COBOL editor and the later use drag-and-drop or the command line to upload it again.)_
- Check on the status of your jobs
  - `zowe jobs ls js | grep ACTIVE`\
    _(You can see here an example how Zowe CLI command can be used in combination with other Linux commands as well as scripts. This example returns the complete list of jobs and pipes that list into the Linux `grep` command to filter it down to show only the active jobs. This kind of capability enables user now to define all kinds of batch jobs and automation for remotely interacting with z/OS.)_

## Edit and Submit JCL to compile, link, and run jobs

Now that Deb has finished all her coding changes, she wants to test her changes.  In order to do that, she needs to get all the necessary files uploaded to z/OS, which he is going to do with Zowe CLI in the command terminal.

To make sure you have a working set of file we recommend that you switch your local workspace to the `tutorial-complete` Git branch (via the branch icon at the bottom left) that has the final updated set of programs and support files.

Next, you will need to allocate the data sets on z/OS that will be used for this example. We provided you with a JCL file to allocate the necessary files. Alternatively, you could also use your own existing PDS data sets, or create new data sets in the data sets view or Zowe CLI commands.

To use the `ALLOCATE.jcl` you need to adjust it for your username first:

- Click on the `ALLOCATE.jcl` file to open it in Wazi for VS Code's editor.\
  _Note: No language support for JCl right now, but it's in our future deliverables._
- Review the file. It creates data sets in the format `HLQ.SAMPLE.*`.
- Modify the value for the symbolic `HLQ` to the high level qualifier you wish to use for this tutorial.
  - Replace `TSOUSER` with the desired value
- Save the file.
- Now you can execute the JCL with the ZOWE CLI:
  - `zowe jobs submit local-file "JCL/ALLOCATE.jcl"`
- Verify creation of these data sets (using your username instead) by refreshing your data sets view

```ascii
HLQ.SAMPLE.COBOL
HLQ.SAMPLE.COPYLIB
HLQ.SAMPLE.OBJ
HLQ.SAMPLE.LOAD
HLQ.SAMPLE.CUSTFILE
HLQ.SAMPLE.TRANFILE
HLQ.SAMPLE.SYSDEBUG
```

Once the data sets are created, upload the sample files to the appropriate data sets. Replace the username with your name.

- For the COBOL and COPYBOOK PDS members, simply use `Create New Member` option by doing right click on the data set to create files in MVS data set:
  - Create `SAM1` and `SAM2` members to `USER1.SAMPLE.COBOL` \
  - Create `CUSTCOPY`, `SAM2PARM`, `TRANREC` members to `USER1.SAMPLE.COPYLIB`
  - You also need to manually copy the editor window contents of the local files and paste into the newly created Members of MVS data sets.(_Note: No Drag & Dropp Support to upload files in MVS data sets from Local File system nut may be in future deliverables_)
- For sequential files, use this Zowe CLI upload command:
  - `zowe files ul ftds "RESOURCES/SAMPLE.CUSTFILE" "USER1.SAMPLE.CUSTFILE"`
  - `zowe files ul ftds "RESOURCES/SAMPLE.TRANFILE" "USER1.SAMPLE.TRANFILE"`

Once uploaded, click on the COBOL data set members to open them in the editor. You see that the extension recognises file as COBOL based on the files.associations preferences we defined earlier. Based on those settings the editor is now using COBOL syntax highlight as well as provided all the other language server features that we had explored earlier. Making changes and saving will write back to the MVS data set member directly.

Before executing the `RUN.jcl` that contains the COMPILE, LINK, and RUN steps for our program you need to adjust the data set names again.

- Click `RUN.jcl` in the File view to open it in the editor.
- Perform the same modification to the `HLQ` symbolic, replacing `TSOUSER` with the same value used previously.
- You may or may not need to modify the other symbolics depending on the compile and link libraries your host system uses.
- The `SPACE1` and `SPACE2` symbolics should be fine as set, but you may change these if necessary.
- Save the file.
- Submit the job using Zowe CLI:
  - `zowe jobs submit local-file "JCL/RUN.jcl"`
- You can verify the completion of the job
  - `zowe jobs ls js` or, if you prefer, use the Zowe JES Explorer
- You will see a response showing your job id.
- Check the job status with this command replacing the job id with yours:
  - `zowe jobs view jsbj JOB03772`
- Refresh the Remote Systems View again to locate the data sets created by the `RUN.jcl` file.

If the job succeeded you can now examine the results directly from the data sets explorer:

- Click the `USER1.SAMPLE.CUSTOUT` and `USER1.SAMPLE.CUSTRPT` data set.
- They will be opened in the editor as text files that you can inspect.
- you can use Zowe CLI commands to download the files as well:
- Get the contents of `SAMPLE.CUSTOUT` and `SAMPLE.CUSTRPT` using your username:
  - `zowe files download ds "USER1.SAMPLE.CUSTOUT"`
  - `zowe files download ds "USER1.SAMPLE.CUSTRPT"`

You see the two downloaded files now on the left in your editor and can review them. You also can open these files directly from the Remote Systems explorer by double-click on each file or drag and drop to the Editor panel.

# Evaluation and Feedback Survey

We hope you enjoyed working through this tutorial learning about Wazi for VS Code. Perhaps you had even some time to experiment and use Wazi for VS Code with your own COBOL sources. Now, we would like to hear from you. What worked well for you, and what did not? Where do you see the future of development in your organization and in what areas should we invest building a better development experience for you?

We assembled a couple of survey questions that we would like you to answer as well as any other feedback you want to share. There are three ways of giving us feedback:

1. Using our online survey tool @ <https://ibm.biz/wazisurvey>
1. Via our [public Github community filing an Issue](https://github.com/IBM/wazi-tutorial/issues/new?title=Wazi%20Technology%20Preview%20Feedback) in which you can provide any kind of feedback. You can also copy-paste the survey and fill in answers there. Note, that posting there will be **public** and anyone can see your feedback and engage in a conversation with you and us adding more comments to your feedback. In will also the place in which we will respond publicly hoping to draw in others that will chip in and provide their points of view. On Github the [Github Privacy Statement](https://github.com/site/privacy) applies.
1. Via direct Email using the Help menu in the Wazi for VS Code editor. Select the menu item `Help > Provide Feedback to IBM by EMail`, which will open your default email tool (configured in your browser for mailto hyperlinks) and fill in an email address and subject line. You can copy-paste the survey question below and enter your answers. Your replies will be sent directly to the development team and not be shared outside of the team.

## Survey Questions

You find the survey question in our main [README.md](https://github.com/IBM/wazi-tutorial#survey-questions). If you prefer to send these answer by email, copy-paste them from there.

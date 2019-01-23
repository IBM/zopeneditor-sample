# Welcome to the Wazi Technology Preview
_(Updated January 24th, 2019 for Wazi 0.1.1. See [What's New](#what's-new) below for details.)_

Welcome to Wazi, a technology preview of new capabilities for Z Open Development, which utilizes and extends the [Zowe Open Mainframe](https://zowe.org) project for mainframe development.

This document and tutorial is maintained in public on [github.com/ibm](https://github.com/IBM/wazi-tutorial). Please, visit  us there for any updates to this document and the sample application. In the tutorial below you will also learn how to use Git to pull in the latest versions directly into your Docker image. Also make sure to frequently visit our [Wazi Community Landing page](https://ibm.github.io/wazi-about) with videos, blog post, and feedback links.

Wazi contains a Web IDE entirely in the browser and is provided to you via an easy to use Docker image ([download it from here](https://epwt-www.mybluemix.net/software/support/trial/cst/programwebsite.wss?siteId=491&tabId=902&w=tw5nkes&p=8nuiscmr)) that runs on any platform that can run Docker, including laptops. That Docker image contains all the required prerequisites and runs the editor's Web server. The IDE experience is based on the popular [Theia](https://theia-ide.org) open source project, which provides an extensible framework for developing multi-language IDEs for the cloud and desktop using state-of-the-art web technologies.

This Wazi technology preview extends Theia with two new extension components:
1. A **COBOL** editing experience: we are providing a fully functional [language server](https://langserver.org/) for COBOL that enables code completion, finding and navigating references, refactoring etc. We also provide various editor extensions such as syntax highlighting, preview of included copybooks, code templates and many other advanced capabilities that we want to explore with you in the tutorial below.
2. An integration with **Zowe** REST APIs to interact with z/OS remotely for creating and reading datasets, loading and saving COBOL program files, and as an integration with the Zowe CLI to provide additional command line operations such as for running JCL to compile and run your applications.

The COBOL extension can be used entirely without Zowe. So if you do not have access to a z/OS host with Zowe installed you can still participate in many parts of this evaluation, focusing on the COBOL editing experience only. You could also just read through our tutorial steps to get an impression of what can be done and let us know what else we should focus on adding.

This document contains the following sections:

1. [What is Zowe](#what-is-zowe)
1. [Wazi's Key Capabilities](#key-capabilities-of-wazi)
1. [Goals and Limitations](#goals-and-limitations-of-this-technology-preview)
1. [What's New](#what's-new)
1. [Installation](#installation-of-the-docker-image)
1. [Wazi Tutorial](#wazi-tutorial)
1. [Evaluation Survey](#evaluation-and-feedback-survey)

## What is Zowe?

Zowe is a new open source software framework that provides solutions that allow development and operations teams to securely manage, control, script, and develop on the Mainframe like any other cloud platform. Zowe is the first open source project based on z/OS and was initiated by IBM, CA Technologies/Broadcom, and Rocket Software.

Key solution components developed in the Zowe projects are
- Zowe Application Framework: Contains a Web user interface (UI) that provides a full screen interactive experience. The Web UI includes many interactions that exist in 3270 terminals and web interfaces such as IBM z/OSMF.
- Explorer server: Provides a range of APIs for the management of jobs, data sets and z/OS UNIX System Services files.
- API Mediation Layer: Provides an API abstraction layer through which APIs can be discovered, catalogued, and presented uniformly.
- Zowe CLI: Provides a command-line interface that lets you interact with the mainframe remotely and use common tools such as Integrated Development Environments (IDEs), shell commands, bash scripts, and build tools for mainframe development. It provides a set of utilities and services for application developers that want to become efficient in supporting and building z/OS applications quickly. Some Zowe extensions are powered by Zowe CLI, for example the Visual Studio Code Extension for Zowe.

Wazi makes heavy use of the Explorer server and the CLI in this Technology Preview, but expect all capabilities to be usable directly in or with Wazi in the future.

To learn more about Zowe visit this [Blog post](https://developer.ibm.com/code/2018/08/23/zowe-open-source-project-mainframe/) and the [Zowe Documentation home page](https://zowe.github.io/docs-site/latest/getting-started/overview.html).

## Key capabilities of Wazi

Wazi is an exploration of technologies and capabilities to evaluate new DevOps user-experiences with z/OS developers. Just like Zowe, it targets developers of all generations combining the "Old" with the "New" by providing access to trusted tools and interfaces in new experiences and deployment models. Here are some of those new experiences and added-value capabilities in Wazi that we would like your feedback on:

- **Zero-client install experience using the Web**: what if your editor with your settings and your application files would just be there on any machine that you just have logged on to. By navigating to a URL in a browser you would be able to get there and see everything the way you left it in your previous session. No installation required, but still a full modern editing experience with all the language-specific features and technology integrations that you would expect from an IDE? The editor and files could be hosted in your organization's protected private-cloud or using Docker and virtual drives, plus you would be able to open your z/OS resources directly in the editor as well. All changes you make can optionally be saved automatically back to its source to make sure you do not lose anything if the connection is lost.
- **An editor that speaks COBOL**: even though your editor would run on the Web and in your browser it would be just as fast and responsive as a local IDE with all the tools you expect for working with COBOL. Plus there would be many news tools that you have seen in other modern IDEs for other languages. Some of such tools that Wazi provides for COBOL are outline view, syntax highlighting, code completion, code templates, find all references, peek definition, search and rename refactoring across multiple program files, and many other capabilities you want from a modern language-sensitive editor.
- **Boost productivity and control with a modern SCM**: even if your organization does not standardize on an SCM, using one such as Git locally in a workspace will give you a boost in productivity. You can snapshot work at any point in time, go back or branch into alternative explorations, merge your or your colleagues' branches back in, or just revert back to any earlier state of your code in a flash. Use side-by-side views and "blame" annotations to explore exactly what changed between snapshots, when and how it looked before. See exactly for each line when it last changed and by whom. Explore the entire history of all changes for specific file or all files in your workspace in a chronological history viewer.
- **Directly interact with your z/OS system**: if you have Zowe configured then you can load and edit your files directly from z/OS or download them into your local workspace, add them to Git to control your changes, and then later upload the changed files into the same or new datasets to compile and run our application. Do all this from within Wazi with simple drag-and-drop, as well as command line interactions using a Terminal that integrates right below your editor, giving you one central view to everything.

## Goals and Limitations of this Technology Preview

This technology preview of Wazi is a first snapshot of our ongoing work of creating new capabilities to get your early feedback that can guide us in the direction to follow next. The tutorial below will walk you through the features available, but there are obviously some limitations and missing features that we want to call out.

- *Docker 18*: The Wazi technology preview is provided as a Docker image to minimize setup work. The one thing you need to have installed as a minimum is the Docker Community Edition version 2 with Docker Engine 2. This can be installed on most laptop and workstation computers. We tested it on Windows 10 as well as MacOS computers. For Windows 7 [special preparation steps](https://docs.docker.com/toolbox/toolbox_install_windows/) would be required. On Windows you also need to provide Docker with access to a local directory if you want to try Wazi with your own COBOL programs. It will prompt you for username and password of a local Windows user that has access to that directory. If you just want to use the "built-in" example programs then that is not needed.
- *Single-user support*: Even though the Web-technology used for Wazi will eventually be used for multi-user support, in which users can share workspaces and directly collaborate on programs, this release is limited to supporting a single-user at the time for each Docker container. Multiple users can start separate Docker containers using different ports. They could also share program files via Git as well. If multiple users access and modify files directly on MVS using Zowe then the concurrent access will be controlled as in many Web-applications, where the second user saving updates will be told about using an outdated version and being asked to reload. Make sure you copy you changes before doing so. We want to provide a better user-experience for these types of scenarios in the future.
- *Supported browser*: This early version requires a recent release of a modern Web browser. We recommend Google Chrome, Mozilla Firefox, or MacOS Safari.  Microsoft Edge is currently not supported (see this [Theia Issue](https://github.com/theia-ide/theia/issues/1716) for details), but we want to add it or its already announced successor in the future. There is no plan to support Internet Explorer. Support for mobile platforms is also not available, yet, but something we would like to support in the future as well.
- *Incomplete features*: there are a couple of features that we have only been implemented partially at this point and which will be completed or enhanced in the short term. Please, provide us with feedback on how you want these to be completed:
  - *Limited drag-and-drop*: At this point we only provide a limited set of drag-and-drop operations. You can either drag a single file from the Files explorer over to an MVS Partitioned Dataset in the Remote Systems explorer to upload that file as a dataset member, or you can drag one dataset member or dataset from the Remote Systems to the Files explorer.
  - *Limited MVS support*: This technology preview and its Remote Systems explorer focuses on Partitioned Datasets. Other dataset formats such as Physical Sequential or Partitioned Dataset Extended to store COBOL files need to be accessed via the Zowe CLI at the moment. Some datasets can be opened a text files if they contain valid content.
  - *Compile and Run*: all these operations need to be executed via the Zowe CLI as no UI operations are available, yet.
  - *Debug*: although you see the Debug menu included into the IDE, it is not hooked up to z/OS, yet. We plan to add that in the future.
  - *No support for COBOL Libraries*: We do support a visual presentation of included copybooks by showing their contents in  rich hovers inside program files. This is done by providing a list of locations in the Preferences editor. The ability to define named libraries is currently missing.
  - *Copybook file changes not refreshed in the browser*: When you edit a copybook the rich hovers in other open program files will not be refreshed immediately. Close and open the program file to accomplish that or reload the entire browser.
  - *No LSP support for Copybooks and JCL*: When you open copybooks or JCL file, i.e. files with a .cpy or .jcl extension, syntax highlighting will be enabled, but no additional Language Server capabilities will be available for these files, yet. This means you will see no contents in the Outline view, Ctrl+Space will only show code templates, but no syntactical completions, many context menu options will be disabled, etc.

# What's New

In this minor hotfix release 0.1.1 of the Technology Preview 1 we added and fixed the following items:

- Expanded drag-and-drop support: You can now drag items from the Remote Systems explorer to your local workspace. Either drag a dataset member or an entire dataset over to the Files view to copy these as files.
- You can now open non-partitioned datasets in the editor as well. Please, limit this use case to datasets with text content only.
- Partitioned datasets without members now show an `Empty Dataset` label.
- The Remote Systems view can now be toggled, i.e. closed and reopened.
- Improved loading animation for MVS operations: when you upload and download files the icon in the Remote Systems explorer animates correctly letting you know that an operation is in progress.
- Added simple MVS name validations in dialogs.
- Added new more readable file icons for COBOL and JCL.
- Added additional Outline view icons.
- Fixed various bugs in presenting and ordering MVS datasets and members correctly.
- Fixed the sample JCL to work on more system configurations.
- Fixed the link in the Help menu for the Wazi Community.
- Updated this tutorial with additional steps explaining the new features as well as refinements of the previous steps.


# Installation of the Docker image

The following details the steps required for installing the Docker Desktop client and running the downloaded Wazi Docker image.

## Install Docker

To install Docker you need to download a Docker Desktop client or have access to a Docker Enterprise host. If you are new to Docker, you might want to read the [Docker Documentation's Get Started](https://docs.docker.com/get-started) pages first to get an introduction and learn about the potential and flexibility achieved when deploying software in this way.

- To get the freely available Docker Desktop Community Edition for your laptop or desktop computer go to the [Get Started with Docker downloads](https://www.docker.com/get-started) page and click the Download button for your platform.
- Register for an account and download Docker.
- Follow the installation wizard to setup Docker on your machine.
  - On Windows: when prompted to use Windows or Linux containers select Linux. If you already installed previously, switch by right-clicking the Docker icon in the Windows Taskbar and select `Switch to Linux containers..` and confirm.

## Download and start the Docker image

Once your Docker environment is up and running you can use the following commands in a command line Window such as Terminal on Mac or CMD on Windows to start the Wazi container.

Set this environment variable. On Mac or Linux:
```bash
$ export USE_LOCAL_GIT=true
```
On Windows:
```cmd
$ set USE_LOCAL_GIT=true
```

Then load the image you downloaded from ibm.com with the following command. This only has to be done once until you receive a new version as this image can be instantiated multiple times into different containers.

```bash
docker load --input wazi-tp1i1.tar.gz
```

Then finally this is the command to start the docker image creating a fresh new container:

```bash
docker run -it -p 3000:3000 ibmcom/wazi:tp1i1
```

The parameter `-it` made it an interactive command that will now scroll status messages in the terminal window you ran it in. You can stop the Docker container later by simply typing `Ctrl+C`. You can also start the container in the background by leaving the parameter out. The you stop the container with the stop command described further below.

Once the container is up you will be able to open a browser at `http://localhost:3000`. Here you then see the Wazi editor with a predefined example project that is directly available in the workspace that got opened.

## Stopping and Starting the Wazi Docker container

Running the run command from above a second time will create a new container instance. To stop and start the container you created above, or to stop and start your session with it and reuse your settings and file changes you need to the following commands:

```bash
docker ps
```

to find the ID of your container, for example, `3edcea8dc079`.  Then use that id with the stop and start commands. For example,

```bash
docker stop 3edcea8dc079
docker start -i 3edcea8dc079
```

assuming your id is `3edcea8dc079`. Replace that value with your actual id. If your container is stopped the `docker ps` command will not show any information. Use the command `docker ps -a` to show all containers including the ones currently not running.

## Using your own folder as a workspace

Once you have completed the tutorial and want to specify a local directory with your COBOL files to be used instead, you can use the following command that uses shared folders.

On Linux or Mac, you can start such a container directly from the folder with your examples, making that local directory the virtual workspace folder by using this command:

```bash
docker run -it -p 3000:3000 -v "$(pwd):/home/project:cached" ibmcom/wazi:tp1i1
```

On Windows you have to specify the absolute path to the directory, such as

```bash
docker run -it -p 3000:3000 -v "C:\Users\user1\projects\COBOL:/home/project:cached" ibmcom/wazi:tp1i1
```

On Windows, Docker will then prompt you for permissions by asking you to supply a username and password of a local Windows user that has full write access to this directory.

## Making changes to an existing container

If you want to make changes to your existing docker container, such as create more top-level workspace directories, which require root access you can use command line options.

Assuming that your docker container is running, to start a root bash from your host's terminal, first run this command to find your container's docker id.
```bash
docker ps
```
Then use that id in this command (i.e. replace f48dfb04c3da with your container's id):
```
docker exec -u 0 -it f48dfb04c3da bash
```

The you can run operations as root. For example, to create more project folders:

```bash
cd /home
mkdir myproj
chown wazi:wazi myproj
```
Then you could use in Wazi the menu `File > Open Workspace` to switch to that `myproj` directory as you new workspace.

# Wazi Tutorial

## Overview

This tutorial provides a complete end-to-end walk-through of the COBOL development capabilities and scenarios supported by this environment. We will cover the following capabilities:

1. [Explore the GUI](#explore-the-gui)
1. [Tutorial Use Case](#tutorial-use-case)
1. [Set User and Workspace Preferences](#set-user-and-workspace-preferences)
1. [Review of the current application code](#review-of-the-current-application-code)
1. [Search for components referencing the Customer File Update Report](#search-for-components-referencing-the-customer-file-update-report)
1. [Prepare a new release stream using Git branches](#prepare-a-new-release-stream-using-git-branches)
1. [Create a new copybook](#create-a-new-copybook)
1. [Make coding changes using the Wazi COBOL editor](#make-coding-changes-using-the-wazi-cobol-editor)
1. [Commit your changes into your SCM branch](#commit-your-changes-into-your-scm-branch)
1. [Review all changes in Git History view](#review-all-changes-in-git-history-view)
1. [Prepare to work with Zowe](#prepare-to-work-with-zowe)
1. [Create a Zowe connection to z/OS](#create-a-zowe-connection-to-zos)
1. [Navigate MVS with Wazi's Remote Systems Explorer](#navigate-mvs-with-wazis-remote-systems-explorer)
1. [Define property groups to map MVS datasets](#define-property-groups-to-map-mvs-datasets)
1. [Use the Wazi Terminal and Zowe CLI to interact with z/OS](#use-the-wazi-terminal-and-zowe-cli-to-interact-with-z%2Fos)
1. [Edit and Submit JCL to compile, link, and run jobs](#edit-and-submit-jcl-to-compile%2C-link%2C-and-run-jobs)


## Explore the GUI
When you navigate to `http://localhost:3000` for the very first time, you may see a predominantly blank screen with a horizontal menu bar at the top of the page.  On the left side of the page you will see a vertical bar with a Files tab.  On the right side, you may see the Outline tab.
- If it is still collapsed then start by clicking on the vertical `Files` tab to open the file browser.  You will then see the example files needed to go through the following exercise.
- If you have not done so earlier based on the instructions that came with the Docker image file, open this tutorial file by right-clicking `README.md` and selecting `Open With > Preview` from the context menu. Now you can scroll down to this line in that copy of the tutorial and continue working entirely from within Wazi.
- Next, click on `SAM1.cbl` to open the file in the Editor panel.  This panel is where all of your refactoring will occur.  You will notice some features when the Editor panel opens, these will be explained later in the exercise.
- Now, click on `Outline` in the far right edge of the screen.  The Outline view panel will open but with no content.
- Click in the `Editor` panel in the COBOL program to get the Outline Content to populate.
- Now you should select the menu item `File > Settings > Change Color Theme` to explore the alternative color themes available. Once you clicked the menu item the two choices `Dark Theme` (the initial default) and `Light Theme` will be displayed in a drop-down at the top. Try them both and select the one that you prefer. You will see that also the COBOL syntax highlighting and outline view will be different in each setting.
- The editor will remember your theme choice in-between browser session as well as which views and editors you had open using browser storage.

There are other views that you will use during this tutorial, which can be opened using the `View` Menu option, if they are not already visible on the vertical bars left or right. You can also drag these around and place them in different locations.
- Search
- Git (to view changes of refactored components)
- Git History (to view a history of committed changes)
- Remote System (appears on right side of screen, allows user to view files on z/OS, connection instructions listed below)
- Problems panel (opens at bottom of editor panel, displays error messages)
- Debug and Debug Console (Future Release)
- Toggle Bottom Panel (hides or exposes bottom panel)
- Collapse All Side Panels (useful when you want enlarge the editor panel)

The `Terminal` Menu opens a Command Line Interface at the bottom of the editor panel that you can use to issue advanced Git commands as well as Zowe Command Line operations to interact with z/OS.

## Tutorial Use Case

In the file browser on the left you already see sample program files that have been added to a Git repository that you will use while walking through all the exercises in this tutorial.

For the tutorial, you will assume the role of COBOL developer Deb who has received requirements to enhance the Daily Customer File Update Report to include the total number of customers as well as information regarding "Crunch" transactions.  A "Crunch" transaction is a request to calculate the average monthly order revenue for a specific customer.  The current daily report simply displays the first 80 bytes of each transaction record as well as total counts for each type of transaction.

Deb opens a browser and starts Wazi to begin her work. We assume that she has created a local workspace, i.e. a workspace directory with all her program and data files on a local workstation directory or within her Docker image, in which she maintains all the files under Git control. She could also work directly against MVS datasets without the need to move any files off z/OS, but we will explore that option later in the tutorial.

## Set User and Workspace Preferences

To get up and running in Wazi, you (as Deb) start exploring editor preferences first.

- Select the the `File > Settings > Open Preferences` menu.
	- In the editor panel, a list of preference groups is displayed, along with editor tabs for both the User and Workspace Preferences. Switch these tabs respectively in the steps below to decide in which scope you want to add a preference. Selecting a preference on the left will insert it into the selected JSON editor tab on the right. Every preference option has a default that gets displayed in a hover together with a description. Adding a preference into the workspace or user preference editor means that you want to change the default to a new value.
    - Workspace preferences, as the name suggests are specific to the current workspace and stored inside the `.theia` directory at the root of that workspace. If you share the workspace with other users via Git then these should be shared as well as they are intended to be the same for all users. Here you would set preferences that should apply regardless of who makes the edits, such as the Tab size, or pathnames for copybooks etc.
    - User preferences, are for the current user and apply across different workspaces. These will be stored for the user in their home directory and not shared. Examples, for typical user preferences are related to accessibility such font sizes, editor behavior for code completion, but also z/OS host connections that include usernames and passwords, etc. Note, that workspace preferences override any user preference setting you define in both places.
- Select the Workspace Preferences tab to see that the example workspace of the Wazi Docker image comes with a few preferences out of the box. These include the `"editor.autoSave"` setting, as well as a `"cobol.property-groups"` that defines the location of copybooks for the example programs.
- Explore some of the Editor Settings to customize your workspace if needed:
	- Expand the **Editor** preference group.
	- Select `cursorStyle` and/or `cursorBlinking`, review and set to your user preferences.
	- Review `fontSize` and `fontWeight`.
	- Turn on/off the `lineNumbers`.
	- Review the `tabSize` value and set for the workspace preferences.
	- Select `quickSuggestions` and `False` - this will allow you to control if code suggestions and snippets are activated in addition to manual code completion requests.
	- Save the settings

## Review of the current application code

The current sample application consists of two COBOL programs (`SAM1` and `SAM2`), COPYBOOKS (`CUSTCOPY` and `TRANREC`), JCL to set up and run the application (`ALLOCATE` and `RUN`), and the datasource files (`CUSTFILE` and `TRANFILE)`.

`SAM1` reads in both the `CUSTFILE` and `TRANFILE` datafiles, then performs different actions on the `CUSTFILE` based on transactions from `TRANFILE`.  Valid transactions are `ADD`, `UPDATE`, and `DELETE`.  When encountering an `UPDATE` transaction, `SAM1` will call `SAM2` to perform the requested update.

As you review `SAM2`, you will notice there is already some base code in place for `CRUNCH` transactions which will be enhanced later in the following exercise.  At the end of processing the `TRANFILE`, `SAM1` will then generate a report on the transactions processed and will also produce an updated `CUSTFILE`.

## Search for components referencing the Customer File Update Report

Wazi users can utilize the advanced Search capabilities provided by the underlying Theia framework. Its Search view allows searching of strings as well as regular expression across all files or a specific subset of files based on location or name patterns. The Search view even provides advances Query-Replace features that allow you to preview side-by-side, how each change would look like, giving users the option to perform and reject each change one by one, or all at once. Let's have a look at how Deb can use these features for impact analysis.

Deb starts her work by analyzing the impact of the new requirements to determine the modifications needed to accomplish the requested updates.  She wants to search for components that generate and reference the Daily Customer File Update.

- Right Click on the top-level `project` folder to initiate a search on all files:
  - Select `Find in Folder..`
  - Enter the search term `CUSTOMER-FILE` and start the search with the Return key.
    - Review some of the other search options such as using regular expression and specifying patterns for files and folders to be excluded or included in the search.
    - To perform a regular expression search select the `.*` icon and change the search term to `CUST.*FILE` and review the results.
  - Results will appear in the Search Panel.
      - Clicking on the result will allow the user to navigate to that location file in the Editor panel.
  - A second search can also be done for the `CRUNCH` transaction to determine the affected components.

## Prepare a new release stream using Git branches

Now that Deb has determined the components that need to be modified, she could create a new folder and copy the existing program artifacts into that folder to start working on the program modification for a new release of her application.  Instead, she decides to try out Wazi's built-in capabilities for using the Software Configuration Management (SCM) software Git, to manage a parallel development stream for the different variants of her application. As you will see, the underlying Theia framework provides some great views to work with Git.

She decides that this new release should be managed as a new Git branch of the current code base in her Git repository. She uses Wazi's UI to create and switch her workspace to that new branch:

- Select the small branch icon at the bottom left of the browser page in the colored status bar. The text next to it will either say `NO-HEAD`, if no working branch was selected previously, or show a current branch name such as `master`.
- A drop-down box at the top of the browser page will appear with various options. One of the options is selecting the `master` branch, which is the default branch of the current version of the sample application as well as this tutorial document. You also see a branch called `tutorial-complete`, which has the completed solution of all the code changes made in this tutorial. You can switch to that branch to see the final results later. Selecting a branch here is all that it takes to switch between different branches of your codebase. Just remember to commit changes you made before switching. Will get to that later as well.
- This tutorial's Git repository is even connected to the remote repository on [github.com](https://github.com/IBM/wazi-tutorial). So you can use the Git view of Wazi to pull in the latest updates IBM made to this tutorial. Try it out by
  - Selecting the `master` branch again.
  - Opening the Git view via the menu `View > Git`
  - In the Git view on the left select the ellipsis icon under the `Commit message` text field
  - In the pop-menu select the option `Pull..`
  - In the drop-down view that gets opened in the center-top of the browser select `origin`.
  - It will then load the latest changes and update your tutorial and program files with the latest version.
- Coming back to Deb's scenario and her creating now a new branch for her code changes, select the branch icon at the bottom again and then `Create new branch..`.
- The drop-down will refresh and ask you to enter the name of the new branch. Enter `update-report` or any other name that you want to use for the new branch.

You have now created a new SCM branch for your work. All changes that you make here now and commit will be local to that branch not impacting the files in the original master branch.

## Create a new copybook

Deb decides that she wants to create a new copybook for the new Crunch transaction count parameters that will be passed from `SAM2` back to `SAM1.` This can be accomplished a couple of ways:

1. Create a new file from scratch:
    - Right-click in the File view on the left.
	- Select `New File` from the context menu.
	- Name the new file in pop-up box (such as `SAM2PARM.cpy`).\
	_(Be sure to include file extension of .cpy for copybooks and .cbl for cobol programs.)_
	- Either begin typing in the copybook information or paste information from an existing file being used as a base.\
	_(In this example, we are going to put the new Crunch Counts being passed between SAM1 and SAM2 into a new copybook.)_
2. Copy an existing base component file and modify it:
    - Right-click the existing file in the File view on the left.
    - Select `Duplicate` from the context menu.
	- Right-click on the new file.
	- Select `Rename (F2)`\
	_(Remember to include file extension in the new name.)_

## Make coding changes using the Wazi COBOL editor

You are now ready to begin making your coding changes.  Select the program or copybook you want to edit and it will appear in the editor panel.  Listed below are features and capabilities of the Wazi editor.

- Syntax highlighting
  - Allows you to quickly distinguish between COBOL reserved words, comments, constants, and variables.
- Grey lines marking the COBOL areas
  - Assists you in determining correct areas for comments, boundaries for coding in areas A and B, etc.
- Column Ruler at top of editor. _(When editing a COBOL or COPYBOOK file, the COBOL areas are identified as well.)_
- Keyboard shortcuts (default are Wazi keybindings)
  - If the user is familiar with ISPF and its keyboard shortcuts, Wazi provides the ability to use alternative ISPF shortcut bindings.
	- To see a list of available keyboard shortcuts.
		- Menu `File > Settings > Open Keyboard Shortcuts` or `F1`
		- Enter `ISPF` in the search box to see the ISPF keybindings available.
	- To switch between ISPF like and the default Theia keyboard bindings:
		- Menu `File > Settings > Open Preferences`.
		- Expand the `Zowe` preference group.
		- Select `keybinding`.
		- Select `ISPF` or `Theia`.
      - Save the preferences.
- Page Up and Page Down
	- `PgUp` and `PgDn` keys on Windows
    - `(fn+down-arrow)` and `(fn+down-arrow)` on Mac
- Expand and Collapse code sections
	- Move the mouse pointer to position 1 in the editor to expose the `-` and `+` icons, useful to hide code that is not being refactored.
- Outline View Panel
	- You can expand and collapse sections in the Outline View.\
		_(This works on Division Headings, Section Headings, and even Variable Group Names)_
	- Note the icons located by the various items allowing quick recognition of copybooks, paragraphs, etc.
	- You can also navigate to a desired location in the code by clicking on that section header in the view.
	- This view also allows expansion and collapsing of items.
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
		- `Change All Occurrences (Ctrl+F2)`\
			_Start typing the new name and all occurrences are changed simultaneously._
			_NOTE: In the scroll bar on the right side of the editor, each occurrence will be noted with a location bar._
		- `Find All References (Shift+F2)`\
			_A Results codelens box appears on screen, click on any result to navigate to that location in file._
		- `Go to Definition (Ctrl+F12)`\
			_Navigates to the where the variable is defined. It will even open the copybook if applicable._
		- `Go to Symbol (Ctrl+Shift+O)`\
		       _Enter object name in search bar or scroll through items to select object, cursor is navigated to that location._
		- `Peek Definition (Alt+F12)`\
			_Opens a codelens box showing where in the code the variable was defined._
- Syntax checking
	- Will underline statements and expressions in red that are unrecognized to allow quick corrections and to cut down on compile errors.\
		_Works on misspelled COBOL reserved words and unknown variable names._
    - There is also a Problems view that can be opened via the `View` menu or by clicking the error/warning icon at the bottom in the status bar. It shows a list of all the syntax errors in all the open files. Double-click on any list item to directly navigate to the problem.
- Undo and Redo
	- Undo: `(Ctrl+Z)`
	- Redo: `(Ctrl+Shift+Z)`


## Commit your changes into your SCM branch

Now that Deb performed various code changes and refinements she wants to commit this version of her application to the SCM to preserve and share it.

- If it is not already available on the left, open the Git view using the menu `View > Git (Ctrl+Shift+G)`.
- This view shows you a list of all the files that you added and modified. You can now decide which of these you want to include in your Commit operation.
- Double-click a file that was changed _(recognizable by the `M` annotation next to the file name)_: Wazi will open a diff editor view that shows side by side all the changes you made.
- Go back to the Git view on the left and hover over each file to see the operations available.
  - You see operations for opening the file, discarding all changes made, or adding your file for the next commit, called Staging.
- Click for all your files that you changed or created the `+` icon to stage them.
- Provide a short description in the `Commit message` text box at the top, such as `Implemented Update Report`.
- Make sure that the `update-report` branch is still selected at the bottom of the browser page.
- Click the `Commit` button on the top of the Git view.
- The list of files should be empty now as all changes were committed to the branch.

You have not committed you file changes to the Git SCM and you can review these changes next in the Git History viewer.

## Review all changes in the Git History view

Deb can use Theia's SCM views to review the entire timeline of all the Commit made for each of her SCM branches. By switching between branches she can see exactly what content changes were contributed into each branch at what time and what person.

- To Open the Git History view use the menu `View > Git History (Alt+H)`.
- As you are still in the `update-report` branch you can see now at the top of the history view the Commit you just performed.\
  _(You see that user that created the commit is called Wazi User. If you want to use Wazi for you own Git repositories you need to change the `/home/wazi/.gitconfig` file with your details.)_
- You can expand it and see all the file changes again. You could double-click each file to again see side-by-side the before and after view of all changes.
- Switch to the `master` branch using the branch icon at the bottom of the page in the colored status bar and the selection list appearing at the top.
- Observe that your commit vanished from the list as it does not exist in this branch until your merge your commits into the master branch.
- Switch back to the `update-report` branch to see your commit again in the history view.
- Also switch to the `tutorial-complete` branch to examine another set of changes. This branch contains a fully modified final version of the files that you can execute later.


## Prepare to work with Zowe

So far you have worked entirely in a local workspace of COBOL files, indirectly using the underlying Alpine Linux OS provided by the Wazi Docker image, working with a local Git control repository, and performing file-local operations such as Search. In addition to the local file system model, Wazi also supports interacting with MVS resources on a z/OS host directly with our graphical Remote Systems Explorer, which is using the [Zowe Explorer REST APIs](https://zowe.github.io/docs-site/latest/user-guide/usingapis.html#using-explorer-server-rest-apis) under the covers.

To be able to perform the following steps in the tutorial we assume that you have Zowe installed and configured on your z/OS host. See the [Zowe Install Guide](https://zowe.github.io/docs-site/latest/user-guide/installandconfig.html) for details. As a result of that installation you need to know the following information about your Zowe configuration for the steps below:

- Your Zowe Explorer base URL.
  - The format of that URL for Zowe 0.9.3 or newer is like this: `https://<zOS-hostname>:<zowe-explorer-port>/api/v1`. The port is configured before running the Zowe installation script, but the default is normally `7443`.
  - If you are using an older version of Zowe then the URL format was like this: `https://<zOS-hostname>:<zowe-explorer-port>/Atlas/api`.
- Your TSO username.
- Your TSO password.

## Create a Zowe connection to z/OS

In our scenario, Deb has finished her first set of edits in he local workspace. She now wants to connect to her z/OS host's MVS to create new datasets, upload her new files, compile and run them.

- Click on the menu item `File > Settings > Open Preferences` to bring back the preferences editor that we used in the [Set User and Workspace Preferences](#set-user-and-workspace-preferences) section earlier.
	- Setting up a connection to a z/OS host should now be entered as a user preference, because that connection will include your username and password. This is information you do not want to share in the workspace. So select the `User Preferences` tab.
- Expand the Zowe preferences group and select the `connections` item.
  - Select `Add Value` _(sometimes, you have to click that options twice)_
  - On the right side you see that a new `zowe.connections` JSON object will be placed in the User Preference tab. This is already pre-populated with default values that you can now edit.
	- `"name"`: Provide a name for this connection. This name will be shown at the top of the Remote Systems Explorer tree browser to identify the connection, in case you would define multiple connections.
    - `"type"`: should remain `Atlas` as that is the only currently supported type.
    - `"url"`: here you need to provide the connection url in the schema documented above.
    - `"username"` and `"password"`: your TSO credentials that have access to Zowe.\
	    Note, that after you enter the password and do a Save that the password will be obfuscated in the editor and an `{XOR}` prefix will be added to tell the system that. This is just an obfuscation to prevent others from reading your screen to see your password, but it is not an encryption. So, keep you password save and only store in in the User Preferences in a Docker image that only you have access to.
    - `"defaultFilter"`: defines which datasets should be retrieved. Wazi by default it will use the username for filtering. Only if you want to override that default you can use this option. Otherwise, just delete it from the editor.
    - `"datasetAllocation"`: provides all the parameters needed for creating new datasets. This is the only place at the moment to specify these parameters until we add interactive dialogs to Wazi. Note, that currently Wazi is also limited to Portioned Datasets (PO). So if this is the first time trying Wazi, leave these defaults as is.
- Once you made all your changes Save the preferences.

## Navigate MVS with Wazi's Remote Systems Explorer

Now you are connected to Zowe and can start exploring your datasets, create new ones, drag over files, etc.

- Open the Remote Systems view by using the `View > Remote Systems` menu
- Connect to Zowe server by expanding the node in the explorer that has the name of your connection created above.
- Review the list of any existing datasets shown.
- Create a new dataset using the right-click context menu of the first `MVS Files` child node below your connection name and select `Create Dataset`
  - Provide a name such as `USER1.SAMPLE.COBOL` (using your actual user name instead of USER1) and click Ok.
  - You will see a message at the top of the screen indicating whether or not the action was successful.
  - The dataset was created with the parameters defined in the User Preferences.
  - To change those values for creating your next dataset, simply edit the User Preferences, and save the file.
- To create another dataset such as `USER1.SAMPLE.CBL` with the same parameters
  - Right-click that datasets and select `Allocate Like` (only works with PDS datasets).
- Now you can create a new dataset member with
  - Right-click on the PDS dataset and select `Create Member`.
  - Provide a name for the new member and hit Enter.
  - Expand the PDS to see the new member.
- Delete a Dataset or Dataset Member
  - right-click on dataset or member to delete.
  - Select `Delete Dataset` or `Delete Member`, respectively.
  - Select `OK` when prompted.
- Add a local file as a dataset member using drag and drop
  - Select the file SAM1.cbl from the Files view on the left.
  - Drag it over your dataset created earlier called `USER1.SAMPLE.COBOL`.
  - After a light delay you will see a message at the top of the screen indicating whether or not the operation was successful.
  - You now see that dataset member listed as `SAM1.cbl`.
  - Click on that new member to open it in the editor.
  - Drag the same file over the other dataset that was called `USER1.SAMPLE.CBL` you created earlier.
  - After the operation finished you see the file listed as `SAM1` without an extension.
  - Click on that file to open it in the editor.

You see that the same file was listed different for the two datasets. Also opening them in the editor showed two different results. The first was opened in a fully enabled COBOL editor and the second only in a text editor. The reason is that Wazi follows two rules for identifying dataset members as COBOL or COPYBOOKs and the adds visual extensions to the display.

- Rule 1: The dataset ends with `.COBOL`, `.COBCOPY`, `.JCL`. By default Wazi will assume that all members in such datasets are COBOL, COPYBOOKs or JCL, respectively.
- Rule 2: The datasets are listed in a mapping Property Group in the preferences. The next section will explain the details behind that rule.

## Define property groups to map MVS datasets

In addition to specifying a Zowe connection, Wazi also allows you to define so-called Property Groups preferences for your COBOL application. These groups define the names of datasets for COBOL programs, copybooks, JCL files etc. Without such property groups Wazi - at the moment - will not be able to identify that an MVS member contains COBOL or copybook or JCL contents, as it cannot rely on file extensions in MVS. However, once you define these property groups, Wazi will use these mapping to add visual file extensions into the Remote Systems Explorer. These will make it clear to users how the property group mappings have affected the way the files will be interpreted and opened in the editor.

Property Groups can be defined for the Workspace and shared in Git to all users, if these users share MVS datasets, or for defining property groups for local files. If you use personal datasets then you want to enter the property group in the user preferences. Both variants will work.

- Select the preference tab that you want to use: User or Workspace.
- If you selected the Workspace tab you see that one property group is already present, which was used for the local copybooks that we explored so far.
  - Note, that currently expanding the property group objects on the left and selecting Add Value will override any existing property groups already in the editor, as Theia had designed this feature mainly for single value parameters. So use this for a property not yet available, but for adding another property to an array of property objects as it is the case you need to use the editor and the JSON code completion it provides.
- To add just another group for MVS to this existing list in the Workspace Preferences tab
  - Place the editor cursor behind the closed `}` of that existing property group.
  - Type a comma and `{` to start the new property group.
  - Then type `Ctrl+Space` on your keyboard to open the code-completion panel to see all your choices.
  - Start by selecting `name` and fill in descriptive name such as `"SAM MVS Property Group"`.
  - Type `Ctrl+Space` again. Select `type`, which is a multiple-choice value. Select `"mvs"` from the drop-down list that appears automatically.
  - Type `Ctrl+Space` again. Select `system`. Provide here your hostname of your z/OS system. That name will be matches to the connection url you specified earlier. If it is a substring then this property group will be applied to all datasets coming from that connection.
  - Type `Ctrl+Space` again. Now you can add the actual datasets to the group, each listing arrays of dataset names defining for how their members should be interpreted:
    - `cobolDatasets`: COBOL members
    - `copyDatasets`: Copybook members
    - `jclDatasets`: JCL members
    - `syslib`: the locations of Copybooks included into COBOL programs. You see this one already used in the property group of type `local` that came with the example. For local it provides an array of absolute file-path'. For type `mvs` it will be an array of datasets.

A typical example for the final list of property groups in your Workspace Preferences tab could look like this:

```json
"cobol.property-groups": [
    {
       "name": "SAM-Copybooks",
       "type": "local",
       "syslib": ["/home/project"]
    },
    {
        "name": "zowe-mvs",
        "type": "mvs",
        "system": "zos1000.example.com",
        "syslib": [
            "USER1.SAMPLE.COBCOPY"
        ],
        "copyDatasets": [
            "USER1.SAMPLE.CPY",
            "USER1.SAMPLE.COPY"
        ],
        "cobolDatasets": [
            "USER1.SAMPLE.CBL"
        ],
        "jclDatasets": [
            "USER1.SAMPLE.JCL"
        ]
    }
]
```

As you see, each group is a JSON array in `[]`, with double-quoted and comma separated values. As mentioned above you do not have to list datasets that end with `.COBOL` and `.COBCOPY` here, but it could still be done, if you want list all your datasets for completeness.

- After you entered your property group use `Shift-Alt-F` to format that JSON nicely.
- Save your preferences.
- Use the circular Refresh button in the top-right of the Remote Systems explorer.
- Now your dataset members should be shown with correct extensions and open in the correct editor.

## Use the Wazi Terminal and Zowe CLI to interact with z/OS

The Remote Systems explorer view showed you your datasets and members and allowed you to directly open, edit, and save your programs against MVS. In this technology preview other capabilities, such as right-clicking a JCL to execute it, are still missing. However, by integrating with the Zowe Command Line Interface (CLI) users such as Deb can still use Wazi to compile and run her application.

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

Now you are ready to explore some of the commands available. Let's assume you created your profile for the user `USER1` and you have created a dataset with your COBOL programs earlier called `USER1.SAMPLE.COBOL`. If not adjust the command examples accordingly. Then you can run these commands on your MVS datasets:

- List your datasets and members:
  - `zowe files ls ds USER1`
  - `zowe files ls all-members USER1.SAMPLE.COBOL`
- Download members
  - `zowe files download ds "USER1.SAMPLE.COBOL(SAM1)"`\
    _(You will new folders appear on left with the names based on your dataset that contains the file SAM1. You can rename it to add a `.cbl` extension to edit it in the COBOL editor and the later use drag-and-drop or the command line to upload it again.)_
- Check on the status of your jobs
  - `zowe jobs ls js | grep ACTIVE`\
    _(You can see here an example how Zowe CLI command can be used in combination with other Linux commands as well as scripts. This example returns the complete list of jobs and pipes that list into the Linux `grep` command to filter it down to show only the active jobs. This kind of capability enables user now to define all kinds of batch jobs and automation for remotely interacting with z/OS.)_

## Edit and Submit JCL to compile, link, and run jobs

Now that Deb has finished all her coding changes, she wants to test her changes.  In order to do that, she needs to get all the necessary files uploaded to z/OS, which he is going to do with Zowe CLI in the command terminal.

To make sure you have a working set of file we recommend that you switch your local workspace to the `tutorial-complete` Git branch (via the branch icon at the bottom left) that has the final updated set of programs and support files.

Next, you will need to allocate the datasets on z/OS that will be used for this example. We provided you with a JCL file to allocate the necessary files. Alternatively, you could also use your own existing PDS datasets, or create new datasets in the Remote Systems view and upload files with drag-and-drop or Zowe CLI commands.

To use the `ALLOCATE.jcl` you need to adjust it for your username first:
- Click on the `ALLOCATE.jcl` file to open it in Wazi's JCL editor.
- Review the file. It creates datasets in the format `HLQ.SAMPLE.*`.
- Type `(Ctrl+F)` to bring up the Find feature at the top-right of the editor.
- Click the little triangle/twisty icon next to the Find field to bring up the Replace field.
- Fill `HLQ.` into the Find field and your username such as `USER1.` into the Replace field.
- Then use the right-arrow icon on the right to find the first occurrence.
- Next to the Replace field you see icons to replace the current occurrence or all of them.
- After you replaced all `HLQ.` occurrences with your name, Save the file.

Now you can execute the JCL with the ZOWE CLI:
- `zowe jobs submit local-file "ALLOCATE.jcl"`
- Verify creation of these datasets (using your username instead) by refreshing your Remote Systems view
	- HLQ.SAMPLE.COBOL
	- HLQ.SAMPLE.COPYLIB
	- HLQ.SAMPLE.OBJ
	- HLQ.SAMPLE.LOAD
	- HLQ.SAMPLE.CUSTFILE
	- HLQ.SAMPLE.TRANFILE
	- HLQ.SAMPLE.SYSDEBUG

Once the datasets are created, upload the sample files to the appropriate datasets. Replace the username with your name.
- For the COBOL and COPYBOOK PDS members, simply use the drag-and-drop method to move files from your workspace to the MVS dataset:
  - Drag `SAM1.cbl` and `SAM2.cbl` to `USER1.SAMPLE.COBOL` \
    _(Drag one file at the time at the moment. Wait for the confirmation dialog for each file before moving on.)_
  - Drag `CUSTCOPY.cpy`, `SAM2PARM.cpy`, `TRANREC.cpy` to `USER1.SAMPLE.COPYLIB`
- For sequential files, use this Zowe CLI upload command:
    - `zowe files ul ftds "SAMPLE.CUSTFILE" "USER1.SAMPLE.CUSTFILE"`
    - `zowe files ul ftds "SAMPLE.TRANFILE" "USER1.SAMPLE.TRANFILE"`

Once uploaded, click on the COBOL dataset members to open them in the editor. You see that the extension `.cbl` was added to the member based on the property group settings we defined earlier. Based on those settings the editor is now using COBOL syntax highlight as well as provided all the other language server features that we had explored earlier. Making changes and saving will write back to the MVS dataset member directly.

Although not relevant for execution of the program, note, that you can also drag and drop in the other direction. To try it out,
- Drag and drop the dataset `USER1.SAMPLE.COBOL` from the right Remote Systems explorer into the Files explorer.
- Once, the operation finises, you will see a new folder hierarchy, such as `USER1 > SAMPLE > COBOL` being created with the two COBOL programs inside.

Before executing the `RUN.jcl` that contains the COMPILE, LINK, and RUN steps for our program you need to adjust the dataset names again.

- Click `RUN.jcl` in the File view to open it in the JCL editor.
- Perform the same Find-Replace operation described above replacing `HLQ.` with your TSO username.
- Submit the job using Zowe CLI:
  - `zowe jobs submit local-file "RUN.jcl"`
- You can verify the completion of the job
  	- `zowe jobs ls js` or, if you prefer, use the Zowe JES Explorer
- You will see a response showing your job id.
- Check the job status with this command replacing the job id with yours:
  - `zowe jobs view jsbj JOB03772`
- Refresh the Remote Systems View again to locate the datasets created by the `RUN.jcl` file.

If the job succeeded you can now examine the results directly from the Remote Systems explorer:
- Click the `USER1.SAMPLE.CUSTOUT` and `USER1.SAMPLE.CUSTRPT` dataset.
- They will be opened in the editor as text files that you can inspect.
- Drag these datasets (one at the time) from the right over to the `project` folder in the File explorer and drop.
- They will be downloaded and placed into a folder hierarchy such as `USER1 > SAMPLE`.

Alternatively, you can use Zowe CLI commands to download the files as well:
- Get the contents of `SAMPLE.CUSTOUT` and `SAMPLE.CUSTRPT` using your username:
  - `zowe files download ds "USER1.SAMPLE.CUSTOUT"`
  - `zowe files download ds "USER1.SAMPLE.CUSTRPT"`

You see the two downloaded files now on the left in your editor and can review them. In the future we want to open these directly from the Remote Systems explorer.

# Evaluation and Feedback Survey

We hope you enjoyed working through this tutorial learning about Wazi. Perhaps you had even some time to experiment and use Wazi with your own COBOL sources. Now, we would like to hear from you. What worked well for you, and what did not? Where do you see the future of development in your organization and in what areas should we invest building a better development experience for you?

We assembled a couple of survey questions that we would like you to answer as well as any other feedback you want to share. There are three ways of giving us feedback:

1. Using our online survey tool @ https://ibm.biz/wazisurvey
1. Via our [public Github community filing an Issue](https://github.com/IBM/wazi-tutorial/issues/new?title=Wazi%20Technology%20Preview%20Feedback) in which you can provide any kind of feedback. You can also copy-paste the survey and fill in answers there. Note, that posting there will be **public** and anyone can see your feedback and engage in a conversation with you and us adding more comments to your feedback. In will also the place in which we will respond publicly hoping to draw in others that will chip in and provide their points of view. On Github the [Github Privacy Statement](https://github.com/site/privacy) applies. You can click the link above or directly in Wazi use the menu `Help > Provide Feedback to IBM on Github` to open a new Issue in the `wazi-tutorial` Github repository.
1. Via direct Email using the Help menu in the Wazi editor. Select the menu item `Help > Provide Feedback to IBM by EMail`, which will open your default email tool (configured in your browser for mailto hyperlinks) and fill in an email address and subject line. You can copy-paste the survey question below and enter your answers. Your replies will be sent directly to the development team and not be shared outside of the team.

## Survey Questions

These are the question in the [Online Survey](https://ibm.biz/wazisurvey). If you prefer to send these answer by email, copy-paste them from here:

- What is your current job title or job responsibility?

- How did you learn about the Wazi Technology Preview?
  - [ ] Email
  - [ ] Feedback menu in Wazi
  - [ ] Newsletter
  - [ ] Blog
  - [ ] A conference presentation or lab
  - [ ] Linkedin
  - [ ] IBM.com
  - [ ] Other:

- How would rate your overall experience with Wazi?\
  Scale 1 - 5. 1 Very Difficult, 5 Very Easy.

- What aspects of Wazi do you find is valuable to you? (Select all that apply)
  - [ ] No Client install
  - [ ] Zowe Integration
  - [ ] Browser based code editing
  - [ ] Modern SCM Integration
  - [ ] Building on Theia
  - [ ] Building on open source
  - [ ] COBOL language server
  - [ ] Refactoring features
  - [ ] Command line integration
  - [ ] Overall ease of use
  - [ ] Other:

- Based on your first experience with Wazi, what aspects of Wazi could be improved?

- How would you rate your initial “up and running” experience?\
  Scale 1 - 5. 1 Very Difficult, 5 Very Easy.

- Was the tutorial helpful in your Wazi evaluation?
  - [ ] Did not use it
  - [ ] I used some of it as a reference
  - [ ] It helped a lot

- What editors/IDEs do you currently use for zOS application maintenance and support? (Select all that apply)
  - [ ] ISPF
  - [ ] RDFz
  - [ ] IDz
  - [ ] ADDI
  - [ ] VS Code
  - [ ] Other:

 - How does the Wazi Tech Preview compare to your current editor?
   - [ ] Better
   - [ ] No difference
   - [ ] Not as good

- Briefly describe the main difference to your current editor.

- Which COBOL language-specific editing capabilities in Wazi did you find most useful?
  - [ ] Code Completion
  - [ ] Rich hovers and navigate to copybooks
  - [ ] Rename
  - [ ] Find all References
  - [ ] Go to Definition
  - [ ] Peek Definition
  - [ ] Change all Occurrences
  - [ ] Syntax checking
  - [ ] Other

- What other general editing features would you use? (Please list all you can think of)

- Is there any other feedback you would like to share with us?

- Can we contact you in the future to get your feedback on the design of our future solutions or products? If yes, please provide your contact details.

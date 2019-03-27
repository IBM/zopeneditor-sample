# Welcome to Wazi with IBM Dependency Based Build (DBB) Integration

Welcome to Wazi's integration with [IBM Dependency Based Build](https://www.ibm.com/support/knowledgecenter/en/SS6T76_1.0.3/intro.html) (DBB). DBB provides some automation capabilities based on a modern scripting language that can be used on z/OS.

This document and the tutorial are maintained on our public GitHub page: [github.com/IBM/wazi-tutorial](https://github.com/IBM/wazi-tutorial). Please visit  us there for updates to this document and the sample application. In the tutorial below, you will also learn how to use Git to pull the latest versions directly into your Docker image and also make sure to frequently visit our [Wazi Community Landing page](https://ibm.github.io/wazi-about) for videos, blog posts, and feedback links.

Prior to this tutorial, IBM Dependency Based Build will need to be installed and set up on z/OS and the DBB Web App will also need to be set up. Installation Overview can be found in the [IBM Knowledge Center](https://www.ibm.com/support/knowledgecenter/en/SS6T76_1.0.3/install_overview.html).

Here is a checklist of prerequisites for Dependency Based Build launches on Wazi:

- [Rocket's Git](https://www.rocketsoftware.com/zos-open-source/tools) installed on z/OS.  Git, Gzip, Bash, and Perl will be needed.
- DBB's Toolkit SMP/E installed on z/OS
- DBB's Web Application zip file installed on a Linux workstation. This server must be accessible from the z/OS machine.

This document contains the following sections:

1. [Summary of High-level Steps to Run Dependency Based Builds from Wazi](#summary-of-high-level-steps-to-run-dependency-based-builds-from-wazi)
1. [Setting up z/OS Environment for Dependency Based Build](#setting-up-zos-environment-for-dependency-based-build)
1. [Push your workspace Git repository to the host](#push-your-workspace-git-repository-to-the-host)
1. [Configure the Project](#configure-the-project)
1. [Commit the Project Configuration Changes](#commit-the-project-configuration-changes)
1. [Create a Dependency Based Build Launch for Wazi](#create-a-dependency-based-build-launch-for-wazi)
1. [Running a Dependency Based Build with Wazi](#running-a-dependency-based-build-with-wazi)
1. [Expanding this workflow for a production system](#expanding-this-workflow-for-a-production-system)

## Summary of High-level Steps to Run Dependency Based Builds from Wazi

In this tutorial we will perform the following steps with Wazi and DBB.

- Prepare your z/OS host for Dependency Based Builds and SSH access.
- Create an empty build directory and git repository on z/OS.
- Create a Git remote in Wazi's Git repository pointing to the z/OS host using SSH.
- Push the master branch of the Wazi Git repository to the z/OS remote.
- Create a Dependency Based Build Launch in Wazi that specifies the z/OS build locations for building.
- Execute the launch in Wazi.
- Wazi will connect to the host via SSH and execute the build scripts using the parameters specified in the launch.
- Once the build of the master branch succeeded create a new branch in Wazi's Git repository and start working on COBOL program modifications.
- Commit the changes in Git and push the new branch to the z/OS Git remote using Git via SSH.
- Execute a Wazi build launch with the new branch.
- The z/OS host-side script will checkout the new branch specified by the Wazi launch and run a build against it.

You can also find a [demo video](https://youtu.be/z_6uV2OlRIA) of these steps (except for the setup) on YouTube; jump to time index 2:22.

## Setting up z/OS Environment for Dependency Based Build

To setup the host, ssh into the host machine from the Wazi terminal window

```bash
ssh user@host.machine.com
```

Enter password if prompted.

### Update .profile on the host

After installation of DBB, the DBB, Rocket's GIT, and JAVA_HOME environment variables and PATH updates need to be added to the .profile file for each z/OS profile that will be working with DBB.

If you are unable to edit the .profile from the Wazi terminal window, then try entering this:

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

### Configure SSH and Git

First, you should configure password-less shh authentication, which will enable you to perform many Git operations such as `git push` form the Wazi Git user-interface view. If you cannot do this you need to execute such Git operations from the command line entering the TSO password every time.

There are several blog-posts that describe how to achieve such a setup giving you a bit more back-ground:

- [Configure password-less ssh from Wazi to the Host](https://makingdeveloperslivesbetter.wordpress.com/2018/11/27/z-os-automated-provisioning-of-my-application-environment/) so as to ssh into the host without being prompted for a password.
- [How to setup passwordless SSH login in Linux](https://www.thegeekdiary.com/centos-rhel-how-to-setup-passwordless-ssh-login/)

If you are familiar with the principles, then the basic steps are as follows. In the Wazi terminal perform the following. Accept the default location for the key and when prompted for a "passphrase" type return for an empty one. Remember to replace user with your TSO username and host.machine.com with the ip or address of your z/OS host:

```bash
$ cd ~
$ ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/home/wazi/.ssh/id_rsa):
Created directory '/home/wazi/.ssh'.
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/wazi/.ssh/id_rsa.
Your public key has been saved in /home/wazi/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:6sAwtoZeEkjaIcEwZuYorJ3XZFa/RC/wtMR+sRlDkFQ wazi@15dff13c64e7

$ ssh-copy-id -i ~/.ssh/id_rsa.pub user@host.machine.com
user@host.machine.com's password:
```

Enter the password of the TSO user. Once complete, you can test the password less setup by logging on again:

```bash
ssh 'user@host.machine.com'
```

This should lead you right into the USS prompt without asking for a password anymore. If this did not work then check out the troubleshooting section of the second blog post above. Often it is related to permission not set correctly on the z/OS host's `~/.ssh` directory and files.

Finally, to allow the Wazi build scripts to access Git repositories located in your USS profile directories, you need to configure ssh for non-login shells to use the same environment variables as specified earlier in the .profile file. An easy way to accomplish that is by providing a symbolic link inside your `.ssh` directory back to the `.profile` file. So in the z/OS USS shell execute these commands:

```bash
cd ~/.ssh
ln -s ~/.profile rc
```

## Push your workspace Git repository to the host

Now we need to create a place in USS to which to push the Git repository for building as well as a place for creating build logs.

On the z/OS host, create the directories and create an empty Git repository:

```bash
mkdir projects
mkdir logs
mkdir projects/SAM
cd projects/SAM
git init
git config --local receive.denyCurrentBranch updateInstead
```

Then in Wazi (open a second terminal window if you have not done so already), replace the default origin with the z/OS git repository just created.

```bash
git remote remove origin
git remote add origin user@host.machine.com:projects/SAM
git push --set-upstream origin master
```

Now check back on your host using Wazi's USS Explorer in the Remote Systems view or via command line in your USS terminal window.

```bash
ls -al ~/projects/SAM
```

It should show you your entire Wazi project directory mirrored here on the host as well as the .git directory.

## Configure the Project

In the Wazi File explorer, navigate to the `build/conf` folder within the wazi-tutorial project. You will need to edit the **build.properties** file to add the

Dependency Based Build Web App URL in the style of `https://server:9443/dbb`

## Commit the Project Configuration Changes

These changes should now be committed and pushed back to the host's master branch as they are essential for building the project.

- Switch to the Git view
- See the changed files. Use the `+` icon to stage all staged files.
- Provide a commit message at the top of the view.
- Click the `Commit` button to commit the changes.
- If you set up password-less ssh, then you can now use the kebab menu (`...`) at the top left and select the `Push` menu option to push the changes back to the host. If you did not, then manually perform the push operation in the terminal

```bash
git push
```

- Go back to your command window that has your ssh shell on USS.
- Go to the directory `~/projects/wazi-tutorial/build/conf`
- Do a `more build.properties` to confirm that your changes have made it to the host.

## Create a Dependency Based Build Launch for Wazi

- Click on `File > Settings > Open Preferences`.
- Select `Workspace Preferences` tab within the Preferences editor page.
- Then select `ZBuild > Launches > Add Value`. A section will then be added to Workspace Preferences:

```json
{
  "zBuild.launches": [
    {
      "label": "Launch Dependency Based Build",
      "host": "zos.company.com",
      "ussUser": "USER1",
      "gitBranch": "master",
      "scriptPath": "~/projects/SAM/build",
      "script": "wazi-branch-build.sh",
      "hlq": "USER1",
      "sourceDirectory": "~/projects/SAM",
      "workDirectory": "~/projects/logs"
    }
  ]
}
```

Fill in the appropriate values for each such as the directory where you created the SAM and logs folder earlier if you place them in a different location. The values will be passed to a `script`, which should be named in the preference, by the launch that you find in the workspace under the build folder `wazi-branch-build.sh`.

## Running a Dependency Based Build with Wazi

### Run a First Build Against Master

- With `master` set as `gitbranch` in DBB Preferences, on Wazi's Menu Tabs select `Terminal > Run Dependency Based Build Launch`.
- A text box will pop up asking the user to type the name of a task, select `Launch Dependency Based Build`.
- A new terminal window will open at the bottom of your Wazi screen, showing the progress of the build.
- When the build succeeds it will show you messages such as `Build State: CLEAN` and `Build finished`.

### Accessing and Reading the Build Logs and Build Reports

#### HTML Build Report

- At the end of the build output, you will also see a URL to a build report, such as \
  `** Build result created at https://server.com:9443/dbb/rest/buildResult/1390`.
- Copy this URL and open it in another browser tab. After logging in to the DBB server you will see a build report table that you can examine.
- In the table row Build Report select the `view` link.
- It will bring you to another table that list each file that was compiled.
- For `COBOL\SAM1` click on `Show Dependencies`.
- The table expands showing you all the dependencies that were required to build that program.

#### Build Logs

- If you have not done it before, [Set User and Workspace Preferences](https://github.ibm.com/Zowe-Commercial/wazi-sample#create-a-zowe-connection-to-zos) to access USS on the Host.
- Select `View > Remote System`
- Within the Remote System view select `USS Explorer`
- Now go back to the Wazi build output. You find another line above the row with the URL from above that looks like \
  `** Build output located at /u/user1/projects/logs/build.20190318.081246.012`
- This is the location of the log file folder on USS. Use the USS explorer in the Remote Systems view to navigate to that location. Use the `Home` folder or even a favorite created earlier.
- Inside the folder you find the files `SAM1.log` and `SAM2.log`. Click on the these files to open them in Wazi and examine the contents.
- If you navigate to the parent folder `/u/user1/projects/logs/` you will also find the log file that has the contents of the messages shown in the terminal window. Open that log file in Wazi as well.

#### Run the Sample Application

After creating a successful build, you can run the `SAM1` program.  The data source files were uploaded to the z/OS system earlier in the Wazi tutorial, so you should be ready to run `SAM1`.

To run the SAMPLE application after a DBB build:
    - In Wazi, click on the `DBBRUN.jcl` to open it in the editor.
    - Replace `TSOUSER` with the desired value
    - `zowe jobs submit local-file "JCL/DBBRUN.jcl"`

### Create a Branch in Wazi

- Create branch `feature1` and make COBOL changes, or you can switch to the `tutorial-complete` branch which has the completed changes.
- If you make your own coding changes, commit them to your branch
- Push new branch to host using Wazi's Git view or via command line

```bash
git push --set-upstream origin feature1
```

- Open the workspace preferences and copy the launch that you created earlier and append it to the json list.
- Modify the new preference by changing its `name` (e.g. to `Branch Build`) and `gitbranch` (to `feature1` or `tutorial-complete`) values.
- Follow the steps above in `Running a First Build Against Master` choosing the Dependency Based Build Launch with the `feature1` branch.

## Expanding this workflow for a production system

In the tutorial above we have used the Wazi out of the box example in the Docker image and pushed its Git repository to the host. In many real development scenario the flow would be slightly different. Teams would maintain their Git repository on GitHub or GitBucket and would clone that repository into their Wazi workspace and then follow the steps described above. It should also be possible to clone the Github repository on the host first and then clone that into a Wazi workspace. Both directions of cloning are possible. You just have to remember adjust the git remote settings accordingly.
